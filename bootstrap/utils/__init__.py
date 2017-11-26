import json
import logging
import subprocess
import sqlite3
import yaml
from boto3.session import Session
from botocore.exceptions import ClientError, WaiterError
from glob import glob
from io import StringIO

from os import (
    chdir,
    environ, 
    getcwd, 
    makedirs, 
    path, 
    remove,
)

from shutil import copytree
from sys import stdout, stderr
from time import sleep
from threading import currentThread, Thread
from urllib.request import urlopen

class ImageBuildException(Exception):
    pass

class ImageBuild(object):

    def __init__(self):
        self.init_logging()

    def init_logging(self):
        handlerConsole, handlerString, self.logString = self.create_log_stream()
        self.logger = logging.getLogger()
        self.logger.setLevel(logging.INFO)
        self.logger.addHandler(handlerConsole)
        self.logger.addHandler(handlerString)

        logging.getLogger('boto').propagate = False
        logging.getLogger('boto3').propagate = False
        logging.getLogger('botocore').propagate = False

    def create_log_stream(self):
        logString = StringIO()
        formatter = logging.Formatter('[%(levelname)s] %(asctime)s %(message)s')
        handlerConsole = logging.StreamHandler(stdout)
        handlerString = logging.StreamHandler(logString)
        handlerConsole.setFormatter(formatter)
        handlerString.setFormatter(formatter)

        return handlerConsole, handlerString, logString

    def get_stack_outputs(self):
        cfn = self.aws.resource('cloudformation')
        stack = cfn.Stack('{App}{Env}Serverless'.format(App=self.appName, Env=self.envName))

        outputs = { }
        for output in stack.outputs:
            outputs[output['OutputKey']] = {
                'value': output['OutputValue'],
                'exportName': output['ExportName'] if 'ExportName' in output else None,
            }

        return outputs

    def init_federated_session(self):
        try:
            self.logger.info('Downloading Session Credentials: {Path}'.format(Path=self.sessionPath))
            self.sessionInfo = json.load(urlopen(self.sessionPath))
            self.sessionCredentials = self.sessionInfo['Credentials']

        except Exception as e:
            logging.exception('CREDENTIAL_RETRIEVAL_ERROR')
            raise ImageBuildException('CREDENTIAL_RETRIEVAL_ERROR')

        self.aws = Session(
            aws_access_key_id=self.sessionCredentials['AccessKeyId'],
            aws_secret_access_key=self.sessionCredentials['SecretAccessKey'],
            aws_session_token=self.sessionCredentials['SessionToken'],
            region_name=self.region,
        )

        try:
            self.outputs = self.get_stack_outputs()
        except Exception as e:
            logging.exception('BAD_CREDENTIALS')
            raise ImageBuildException('BAD_CREDENTIALS')

    def run_command(self, cmd):
        self.logger.info('Running Command: {Cmd}'.format(Cmd=cmd)) 

        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, error = p.communicate()

        self.logger.warning(json.dumps({
            'returncode': p.returncode,
            'stdout': out.decode('ascii'),
            'stderr': error.decode('ascii'),
        }, indent=4))
        
        return p.returncode

    def heartbeat(self, taskToken):
        t = currentThread()
        self.logger.info('Heartbeat Starting')
        while getattr(t, 'heartbeat', True):
            try:
                self.sfn.send_task_heartbeat(taskToken=taskToken)
            except Exception as e:
                self.logger.error(e)
                logging.exception('HEARTBEAT_ERROR')

            sleep(30)

        self.logger.info('Heartbeat Stopped')
        
    def bootstrap(self):
        self.sfn = self.aws.client('stepfunctions')
        bootstrapOutput = '{App}{Env}AppStreamImageBootstrapActivity'.format(App=self.appName, Env=self.envName)
        bootstrapActivity = self.outputs[bootstrapOutput]['value']

        try: 
            task = self.sfn.get_activity_task(
                activityArn=bootstrapActivity,
                workerName=self.buildId,
            )

        except Exception as e:
            logging.exception('BAD_BOOTSTRAP_ACTIVITY')
            raise ImageBuildException('BAD_BOOTSTRAP_ACTIVITY')

        try:
            self.sfn.send_task_success(
                taskToken=task['taskToken'],
                output=task['input'],
            )

        except Exception as e:
            logging.exception('BOOTSTRAP_FAILURE')
            raise ImageBuildException('BOOTSTRAP_FAILURE')

        self.logger.info('Bootstrapped')

    def install_packages(self):
        installOutput = '{App}{Env}AppStreamImageInstallActivity'.format(App=self.appName, Env=self.envName)
        installActivity = self.outputs[installOutput]['value']

        try:
            task = self.sfn.get_activity_task(
                activityArn=installActivity,
                workerName=self.buildId,
            )
            self.logger.info('Task Input: \n' + task['input'])
            taskInput = json.loads(task['input'])

        except Exception as e:
            logging.exception('BAD_INSTALL_ACTIVITY')
            raise ImageBuildException('BAD_INSTALL_ACTIVITY')

        self.heartbeat = Thread(target=self.heartbeat, args=(task['taskToken'],))
        self.heartbeat.daemon = True
        self.heartbeat.heartbeat = True
        self.heartbeat.start()
        inputParams = taskInput['state_machine_params']
        packages = inputParams['packages']

        packageLogs = { }
        for package in packages:
            #handlerConsole, handlerString, logString = self.create_log_stream()
            #self.logger.addHandler(handlerConsole)
            #self.logger.addHandler(handlerString)
            self.logger.info('Installing Package: {Package}'.format(Package=package))

            chocoTempDir = path.abspath(getcwd())
            packageDir = path.join(chocoTempDir, 'choco-packages', 'packages', package)

            try:
                chdir(packageDir)
            except Exception as e:
                logging.exception('BAD_PACKAGE_NAME')
                raise ImageBuildException('BAD_PACKAGE_NAME')
            
            try:
                packageConfigPath = path.join(packageDir, 'config.yml')
                packageTemplatePath = path.join(chocoTempDir, 'choco-packages', 'bootstrap', 'templates', 'package.nuspec')
                installTemplatePath = path.join(chocoTempDir, 'choco-packages', 'bootstrap', 'templates', 'chocolateyinstall.ps1')


                with open(packageConfigPath, 'r') as configYaml:
                    config = yaml.load(configYaml)

                with open(packageTemplatePath, 'r') as nuspecTemplateXml:
                    nuspecTemplate = nuspecTemplateXml.read().format(
                        Package=config['Id'],
                        Version=config['Version'],
                        Description=config['Description'],
                    )

                with open(installTemplatePath, 'r') as installTemplate:
                    installCode = installTemplate.read().format(
                        Package=config['Id'],
                        Bucket=self.bucketName,
                        Installer=config['Installer'],
                        FileType=config['FileType'],
                        Arguments=config['Arguments'],
                        ValidCodes=config['ValidCodes'],
                    )

                nugetDir = path.join(packageDir, 'nuget')
                nugetTools = path.join(nugetDir, 'tools')
                copytree(path.join(packageDir, 'tools'), nugetTools)
                packageNuspecPath = path.join(nugetDir, '{Package}.nuspec'.format(Package=config['Id']))
                installScriptPath = path.join(nugetTools, 'chocolateyinstall.ps1')

                with open(packageNuspecPath, 'w') as packageNuspec:
                    packageNuspec.write(nuspecTemplate)

                with open(installScriptPath, 'w') as installScript:
                    installScript.write(installCode)

            except Exception as e:
                logging.exception('BAD_PACKAGE_CONFIG')
                raise ImageBuildException('BAD_PACKAGE_CONFIG')
            
            try: 
                choco = path.join(environ['ALLUSERSPROFILE'], 'chocolatey', 'bin', 'choco.exe')
                packCmd = '{Choco} pack {Nuspec} --out {PackageDir} -r -y'.format(Choco=choco, Nuspec=packageNuspecPath, PackageDir=packageDir)
                installCmd = '{Choco} install {Package} -s ".;https://chocolatey.org/api/v2" -r -y'.format(Choco=choco, Package=config['Id'])
            
                if self.run_command(packCmd) != 0:
                    self.logger.error('PACKAGE_PACK_ERROR')
                    raise ImageBuildException('PACKAGE_PACK_ERROR')

                if self.run_command(installCmd) != 0:
                    self.logger.error('PACKAGE_INSTALL_ERROR')
                    raise ImageBuildException('PACKAGE_INSTALL_ERROR')

            except ImageBuildException as e:
                raise e

            except Exception as e:
                logging.exception('PACKAGE_INSTALL_CRASH')
                raise ImageBuildException('PACKAGE_INSTALL_CRASH')
            

            self.logger.info('Package Installed: {Package}'.format(Package=package))
            chdir(startDir)
            #self.logger.removeHandler(handlerConsole)
            #self.logger.removeHandler(handlerString)
            
            #logPath = path.join(chocoTempDir, '{Package}.log'.format(Package=package))
            #with open(logPath, 'r') as packageLog:
            #    logString.seek(0)
            #    packageLog.write(logString.read())


        try:
            self.heartbeat.heartbeat = False
            #self.heartbeat.join()

            self.sfn.send_task_success(
                taskToken=task['taskToken'],
                output=task['input'],
            )
        
        except Exception as e:
            logging.exception('INSTALL_SEND_SUCCESS_ERROR')
            raise ImageBuildException('INSTALL_SEND_SUCCESS_ERROR')

        self.logger.info('Packages Installed')

class AppStreamImageBuild(ImageBuild):

    def __init__(self):
        super().__init__()

        self.init_user_data()
        self.init_appstream_catalog()
        self.init_federated_session()

        self.logger.info('AppStreamImageBuild Initialized')

    def init_user_data(self):
        try:
            self.logger.info('Getting System User-Data')
            self.user_data = json.load(urlopen('http://169.254.169.254/latest/user-data'))
        except Exception as e:
            logging.exception('NO_USER_DATA')
            raise ImageBuildException('NO_USER_DATA')

        if 'imageBuilder' not in self.user_data or not self.user_data['imageBuilder']:
            raise ImageBuildException('NOT_APPSTREAM_IMAGE_BUILDER')

        self.arn = self.user_data['resourceArn'].split(':')
        self.partition = self.arn[1]
        self.region = self.arn[3]
        self.account = self.arn[4]
        builderName = self.arn[5].replace('image-builder/', '').split('.')

        if len(builderName) != 4:
            raise ImageBuildException('BAD_APPSTREAM_IMAGE_BUILDER_NAME')

        self.buildId = builderName[0]
        self.appName = builderName[1]
        self.envName = builderName[2]
        self.bucketName = builderName[3]

        self.sessionPath = 'https://s3.amazonaws.com/{Bucket}/builds/{BuildId}/federated-session.json'.format(Bucket=self.bucketName, BuildId=self.buildId)

    def init_appstream_catalog(self):
        appstream_catalog = path.join(environ['ALLUSERSPROFILE'], 'Amazon', 'Photon', 'PhotonAppCatalog.sqlite')
        catalog_sql = (
            'CREATE TABLE Applications ('
                'Name TEXT NOT NULL CONSTRAINT PK_Applications PRIMARY KEY,' 
                'AbsolutePath TEXT,' 
                'DisplayName TEXT,' 
                'IconFilePath TEXT,' 
                'LaunchParameters TEXT,'
                'WorkingDirectory TEXT'
            ');'
        )

        makedirs(path.dirname(appstream_catalog), exist_ok=True)
        if path.exists(appstream_catalog):
            self.logger.warning('Removing Existing AppStream Catalog')

        try:
            sql = sqlite3.connect(appstream_catalog)
            c = sql.cursor()
            c.execute(catalog_sql)
            sql.commit()
            sql.close()
        except Exception as e:
            logging.exception('APPSTREAM_CATALOG_CREATION_ERROR')
            raise ImageBuildException('APPSTREAM_CATALOG_CREATION_ERROR')

        self.logger.info('AppStream Catalog Initialized')

class EC2ImageBuild(ImageBuild):

    def __init__(self):
        super().__init__()

class GenericImageBuild(ImageBuild):

    def __init__(self):
        super().__init__()
