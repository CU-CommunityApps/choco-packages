import json
import logging
import subprocess
import sqlite3
from boto3.session import Session
from botocore.exceptions import ClientError, WaiterError
from io import StringIO
from multiprocessing import cpu_count, Process, JoinableQueue as Queue
from os import environ, mkdir, path, remove
from sys import stdout, stderr
from urllib.request import urlopen

class ImageBuildException(Exception):
    pass

class ImageBuild(object):

    def __init__(self):
        self.init_logging()

    def init_logging(self):
        self.logger = logging.getLogger()
        self.logger.setLevel(logging.INFO)
        self.loggerText = StringIO()

        sh = logging.StreamHandler(stdout)
        shText = logging.StreamHandler(self.loggerText)
        formatter = logging.Formatter('[%(levelname)s] %(asctime)s %(message)s')
        sh.setFormatter(formatter)
        shText.setFormatter(formatter)
        self.logger.addHandler(sh)
        self.logger.addHandler(shText)

        logging.getLogger('boto').propagate = False
        logging.getLogger('boto3').propagate = False
        logging.getLogger('botocore').propagate = False

    def get_log_stream(self):
        logger = logging.getLogger()
        logger.setLevel(logging.DEBUG)

        log = StringIO()
        sh = logging.StreamHandler(stream)
        formatter = logging.Formatter('[%(levelname)s] %(asctime)s %(message)s')
        sh.setFormatter(formatter)
        logger.addHandler(sh)

        return logger, log

    def get_stack_outputs(self):
        aws = Session()
        cfn = self.aws.resource('cloudformation')
        stack = cfn.Stack('{App}{Env}Serverless'.format(App=self.appName, Env=self.envName))

        outputs = { }
        for output in stack.outputs:
            outputs[output['OutputKey']] = {
                'value': output['OutputValue'],
                'exportName': output['ExportName'] if 'ExportName' in output else None,
            }

        return outputs

class AppStreamImageBuild(ImageBuild):

    def __init__(self):
        super().__init__()

    def bootstrap(self):
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

        if len(builderName) < 2:
            raise ImageBuildException('BAD_APPSTREAM_IMAGE_BUILDER_NAME')

        self.buildId = builderName[0]
        self.appName = builderName[1]
        self.envName = builderName[2]
        self.bucketName = builderName[3]

        sessionPath = 'https://s3.amazonaws.com/{Bucket}/federated-sessions/{BuildId}.json'.format(Bucket=self.bucketName, BuildId=self.buildId)

        try:
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

        self.sfn = self.aws.client('stepfunctions')
        self.outputs = self.get_stack_outputs()
        bootstrapActivity = '{App}{Env}AppStreamImageBootstrapActivity'.format(App=self.appName, Env=self.envName)
        bootstrapArn = self.outputs[bootstrapActivity]['value']
        
        task = self.sfn.get_activity_task(
            activityArn=bootstrapArn,
            workerName=self.buildId,
        )

        self.sfn.send_task_success(
            taskToken=task['taskToken'],
            output=task['input'],
        )

        self.logger.info('AppStreamImageBuild {Build} Bootstrapped!'.format(Build=self.buildId))

class EC2ImageBuild(ImageBuild):

    def __init__(self):
        super().__init__()

class GenericImageBuild(ImageBuild):

    def __init__(self):
        super().__init__()
