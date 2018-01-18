import json
import logging
import subprocess
import sqlite3
import yaml
from boto3.session import Session
from botocore.exceptions import ClientError, WaiterError
from datetime import datetime, timedelta
from glob import glob
from os import chdir, environ, getcwd, makedirs, path, remove
from shutil import copyfile, copytree
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
        self.logPath = path.join(environ['ALLUSERSPROFILE'], 'choco-install-{Timestamp}.log'.format(
            Timestamp=datetime.utcnow().strftime('%Y%m%d-%H%M%S'),
        ))

        self.logFile = open(self.logPath, 'a')
        self.logger = logging.getLogger()
        self.logger.setLevel(logging.DEBUG)

        formatter = logging.Formatter('[%(levelname)s] %(asctime)s %(message)s')
        handlerConsole = logging.streamHandler(stdout)
        handlerFile = logging.streamHandler(self.logFile)
        handlerConsole.setFormatter(formatter)
        handlerFile.setFormatter(formatter)

        self.logger.addHandler(handlerConsole)
        self.logger.addHandler(handlerFile)

        logging.getLogger('boto').propagate = False
        logging.getLogger('boto3').propagate = False
        logging.getLogger('botocore').propagate = False

    def save_logs(self):
        self.logFile.close()

        with open(self.logPath, 'r') as logFile:
            s3 = self.aws.resource('s3')

            s3LogPath = 'builds/{Build}/choco-packages.log'.format(
                Build=self.buildId,
            )

            s3Log = s3.Object(self.bucket_name, s3LogPath)

            s3Log.put(
                Body=logFile,
                ContentType='text/plain',
            )

    def get_stack_outputs(self):
        cfn = self.aws.resource('cloudformation')
        stack = cfn.Stack('{App}{Env}Serverless'.format(
            App=self.appName, 
            Env=self.envName,
        ))

        outputs = { }
        for output in stack.outputs:
            outputs[output['OutputKey']] = {
                'value': output['OutputValue'],
                'exportName': output['ExportName'] if 'ExportName' in output else None,
            }

        return outputs

    def init_federated_session(self):
        try:
            sessionPath = 'https://s3.amazonaws.com/{Bucket}/builds/{BuildId}/federated-session.json'.format(
                Bucket=self.bucketName, 
                BuildId=self.buildId
            )

            self.logger.info('Downloading Session Credentials: {Path}'.format(Path=sessionPath))
            self.sessionInfo = json.load(urlopen(sessionPath))
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

        p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, error = p.communicate()

        self.logger.info(out.decode('ascii').replace('\r\n', '\n'))

        if len(error) > 0:
            self.logger.warning(error.decode('ascii').replace('\r\n', '\n'))

        return p.returncode

    def heartbeat(self, taskToken):
        sfn = self.aws.client('stepfunctions')
        t = currentThread()
        self.logger.info('Heartbeat Starting')

        while getattr(t, 'heartbeat', True):
            try:
                sfn.send_task_heartbeat(taskToken=taskToken)

            except Exception as e:
                self.logger.error(e)
                logging.exception('HEARTBEAT_ERROR')

            sleep(30)

        self.logger.info('Heartbeat Stopped')

    def bootstrap(self):
        sfn = self.aws.client('stepfunctions')

        bootstrapOutput = '{App}{Env}AppStreamImageBootstrapActivity'.format(
            App=self.appName, 
            Env=self.envName,
        )

        bootstrapActivity = self.outputs[bootstrapOutput]['value']

        try: 
            task = sfn.get_activity_task(
                activityArn=bootstrapActivity,
                workerName=self.buildId,
            )

        except Exception as e:
            logging.exception('BAD_BOOTSTRAP_ACTIVITY')
            raise ImageBuildException('BAD_BOOTSTRAP_ACTIVITY')

        try:
            output = json.loads(task['input'])
            output['BootstrapComplete'] = True

            sfn.send_task_success(
                taskToken=task['taskToken'],
                output=json.dumps(output),
            )

        except Exception as e:
            logging.exception('BOOTSTRAP_FAILURE')
            raise ImageBuildException('BOOTSTRAP_FAILURE')

        self.logger.info('Bootstrapped')

    def install_packages(self):
        sfn = self.aws.client('stepfunctions')

        installOutput = '{App}{Env}AppStreamImageInstallActivity'.format(
            App=self.appName, 
            Env=self.envName,
        )

        installActivity = self.outputs[installOutput]['value']

        try:
            task = sfn.get_activity_task(
                activityArn=installActivity,
                workerName=self.buildId,
            )

            self.inputParams = json.loads(task['input'])

        except Exception as e:
            logging.exception('BAD_INSTALL_ACTIVITY')
            raise ImageBuildException('BAD_INSTALL_ACTIVITY')

        self.heartbeat = Thread(target=self.heartbeat, args=(task['taskToken'],))
        self.heartbeat.daemon = True
        self.heartbeat.heartbeat = True
        self.heartbeat.start()

        self.chocoTempDir = path.abspath(getcwd())
        self.chocoLogDir = path.join(environ['ALLUSERSPROFILE'], 'chocolatey', 'logs')
        self.packages = self.inputParams['Packages']
        environ['CHOCO_BUCKET'] = self.bucketName

        packageLogs = { }
        for package in self.packages:
            self.logger.info('Installing Package: {Package}'.format(Package=package))
            packageDir = path.join(self.chocoTempDir, 'choco-packages', 'packages', package)

            try:
                chdir(packageDir)

            except Exception as e:
                logging.exception('BAD_PACKAGE_NAME')
                raise ImageBuildException('BAD_PACKAGE_NAME')

            ##############################
            # Create Choco Nuget Package #
            ##############################

            try:
                nugetPath = path.join(packageDir, 'nuget')
                nugetToolsPath = path.join(nugetPath, 'tools')
                installScriptPath = path.join(nugetToolsPath, 'chocolateyinstall.ps1')
                packageConfigPath = path.join(packageDir, 'config.yml')
                packageConfigJsonPath = path.join(nugetToolsPath, 'config.json')

                nuspecTemplatePath = path.join(
                    self.chocoTempDir, 
                    'choco-packages', 
                    'bootstrap', 
                    'templates', 
                    'package.nuspec',
                )

                installTemplatePath = path.join(
                    self.chocoTempDir, 
                    'choco-packages', 
                    'bootstrap', 
                    'templates', 
                    'chocolateyinstall.ps1',
                )

                copytree(path.join(packageDir, 'tools'), nugetToolsPath)
                copyfile(installTemplatePath, installScriptPath)
                #copyfile(packageConfigPath, packageConfigYamlPath)

                with open(packageConfigPath, 'r') as configYaml:
                    config = yaml.load(configYaml)

                with open(packageConfigJsonPath, 'w') as configJson:
                    json.dump(config, configJson)

                packageNuspecPath = path.join(nugetPath, '{Package}.nuspec'.format(
                    Package=config['Id'],
                ))

                with open(nuspecTemplatePath, 'r') as nuspecTemplateXml:
                    nuspecTemplate = nuspecTemplateXml.read().format(
                        Package=config['Id'],
                        Version=config['Version'],
                        Description=config['Description'],
                    )

                with open(packageNuspecPath, 'w') as packageNuspec:
                    packageNuspec.write(nuspecTemplate)

            except Exception as e:
                logging.exception('BAD_PACKAGE_CONFIG')
                raise ImageBuildException('BAD_PACKAGE_CONFIG')

            try: 
                chocoPath = path.join(
                    environ['ALLUSERSPROFILE'], 
                    'chocolatey', 
                    'bin', 
                    'choco.exe',
                )

                packCmd = (
                    '{Choco} pack {Nuspec} '
                    '--out {PackageDir} '
                    '-r -y'
                ).format(
                    Choco=chocoPath, 
                    Nuspec=packageNuspecPath, 
                    PackageDir=packageDir,
                )

                installCmd = (
                    '{Choco} install {Package} '
                    '-s ".;https://chocolatey.org/api/v2" '
                    '--no-progress '
                    '-r -y'
                ).format(
                    Choco=chocoPath, 
                    Package=config['Id'],
                )

                if self.run_command(packCmd) != 0:
                    self.logger.error('CHOCO_PACK_ERROR')
                    raise ImageBuildException('CHOCO_PACK_ERROR')

                self.run_command(installCmd)

                #if self.run_command(installCmd) not in config['ExitCodes']:
                #    self.logger.error('CHOCO_INSTALL_ERROR')
                #    raise ImageBuildException('CHOCO_INSTALL_ERROR')

            except Exception as e:
                self.heartbeat.heartbeat = False

                sfn.send_task_failure(
                    taskToken=task['taskToken'],
                    error=str(e),
                )

                if isinstance(e, ImageBuildException):
                    raise e

                else:
                    logging.exception('PACKAGE_INSTALL_CRASH')
                    raise ImageBuildException('PACKAGE_INSTALL_CRASH')

            self.logger.info('Package Installed: {Package}'.format(Package=package))
            chdir(self.chocoTempDir)

        try:
            self.heartbeat.heartbeat = False
            output = json.loads(task['input'])
            output['PackagesInstalled'] = True

            sfn.send_task_success(
                taskToken=task['taskToken'],
                output=json.dumps(output),
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

        if len(builderName) != 3:
            raise ImageBuildException('BAD_APPSTREAM_IMAGE_BUILDER_NAME')

        self.appName = builderName[0]
        self.envName = builderName[1]
        self.buildId = builderName[2]

        self.bucketName = '{App}-{Env}-adminimages'.format(
            App=self.appName.lower(),
            Env=self.envName.lower(),
        )

    def init_appstream_catalog(self):
        self.appstream_catalog = path.join(
            environ['ALLUSERSPROFILE'], 
            'Amazon', 
            'Photon', 
            'PhotonAppCatalog.sqlite',
        )

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

        makedirs(path.dirname(self.appstream_catalog), exist_ok=True)

        if path.exists(self.appstream_catalog):
            self.logger.warning('Removing Existing AppStream Catalog')
            remove(self.appstream_catalog)

        try:
            sql = sqlite3.connect(self.appstream_catalog)
            c = sql.cursor()
            c.execute(catalog_sql)
            sql.commit()
            sql.close()
        except Exception as e:
            logging.exception('APPSTREAM_CATALOG_CREATION_ERROR')
            raise ImageBuildException('APPSTREAM_CATALOG_CREATION_ERROR')

        self.logger.info('AppStream Catalog Initialized')

    def catalog_applications(self):
        try:
            appSql = (
                'INSERT INTO Applications ('
                    'Name,' 
                    'AbsolutePath,' 
                    'DisplayName,' 
                    'IconFilePath,'
                    'LaunchParameters,' 
                    'WorkingDirectory'
                ') VALUES ('
                    '"{Id}",'
                    '"{Path}",'
                    '"{DisplayName}",'
                    '"{IconPath}",'
                    '"{LaunchParams}",'
                    '"{WorkDir}"'
                ');'
            )

            sql = sqlite3.connect(self.appstream_catalog)
            c = sql.cursor()

            for package in self.packages:
                packageDir = path.join(
                    self.chocoTempDir, 
                    'choco-packages', 
                    'packages', 
                    package,
                )

                packageConfigPath = path.join(packageDir, 'config.yml')

                iconDir = path.join(
                    environ['ALLUSERSPROFILE'], 
                    'Amazon', 
                    'Photon', 
                    'AppCatalogHelper', 
                    'AppIcons',
                )

                with open(packageConfigPath, 'r') as configYaml:
                    config = yaml.load(configYaml)

                for app, appConfig in config['Applications'].items():
                    iconFile = '{App}.png'.format(App=app)
                    iconFilePath = path.join(packageDir, 'icons', iconFile)
                    appstreamIcon = path.join(iconDir, iconFile)
                    copyfile(iconFilePath, appstreamIcon)

                    c.execute(appSql.format(
                        Id=app,
                        Path=path.expandvars(appConfig['Path']),
                        DisplayName=appConfig['DisplayName'],
                        IconPath=appstreamIcon,
                        LaunchParams=path.expandvars(appConfig['LaunchParams']),
                        WorkDir=path.expandvars(appConfig['WorkDir']),
                    ))

            sql.commit()
            sql.close()

        except Exception as e:
            logging.exception('APPSTREAM_APPLICATION_CATALOG_ERROR')
            raise ImageBuildException('APPSTREAM_APPLICATION_CATALOG_ERROR')

class EC2ImageBuild(ImageBuild):

    def __init__(self):
        super().__init__()

class GenericImageBuild(ImageBuild):

    def __init__(self):
        super().__init__()
