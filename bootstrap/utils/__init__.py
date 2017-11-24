import json
import logging
import subprocess
import sqlite3
from boto3.session import Session
from botocore.exceptions import ClientError, WaiterError
from io import StringIO
from multiprocessing import cpu_count, Process, JoinableQueue as Queue
from os import mkdir, path, remove
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

        sh = logging.StreamHandler(stdout)
        formatter = logging.Formatter('[%(levelname)s] %(asctime)s %(message)s')
        sh.setFormatter(formatter)
        self.logger.addHandler(sh)

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

class AppStreamImageBuild(ImageBuild):

    def __init__(self):
        super().__init__()

        try:
            self.logger.info('Getting System User-Data')
            self.user_data = json.load(urlopen('http://169.254.169.254/latest/user-data'))
        except Exception as e:
            logging.exception('NO_USER_DATA')
            raise ImageBuildException('NO_USER_DATA')

        if 'imageBuilder' not in self.user_data or not self.user_data['imageBuilder']:
            raise ImageBuildException('NOT_APPSTREAM_IMAGE_BUILDER')

        self.arn = self.user_data['resourceArn'].split(':')
        self.region = self.arn[3]
        builderName = self.arn[5].replace('image-builder/', '').split('.')

        if len(builderName) < 2:
            raise ImageBuildException('BAD_APPSTREAM_IMAGE_BUILDER_NAME')

        self.buildId = builderName[0]
        self.bucketName = builderName[1]

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

        self.logger.info('AppStreamImageBuild {Build} Initialized'.format(Build=self.buildId))

class EC2ImageBuild(ImageBuild):

    def __init__(self):
        super().__init__()

class GenericImageBuild(ImageBuild):

    def __init__(self):
        super().__init__()
