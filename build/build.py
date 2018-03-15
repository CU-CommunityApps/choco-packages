import json
import logging
import yaml
import boto3
import os
import shutil
import hashlib
import time
import utils

from botocore.exceptions import ClientError, WaiterError
from datetime import datetime, timedelta
from glob import glob
from os import chdir, environ, getcwd, makedirs, path, remove
from shutil import copyfile, copytree
from sys import stdout, stderr

logging.basicConfig(stream=stdout, level=logging.INFO)

BUCKET_NAME = 'cornellstream-prod-adminimages'
ARCHIVE_TEMP_DIR = '/tmp'
BUILD_ENV = os.getenv('CODEBUILD_INITIATOR', '-dev').split('-')[-1]

s3 = boto3.resource('s3')
bucket = s3.Bucket(BUCKET_NAME)


def upload_package(package):
    packageKey = "choco-packages/{Env}/{Package}.nupkg".format(
        Bucket=BUCKET_NAME,
        Env=BUILD_ENV,
        Package=package
    )

    existingObject = s3.Object(bucket_name=BUCKET_NAME, key=packageKey)
    try:
        existingObjectMd5 = existingObject.e_tag.strip('"')
    except ClientError:
        existingObjectMd5 = ""

    with open('/tmp/{}.nupkg'.format(package), 'rb') as f:
        data = f.read()
        archiveMd5 = hashlib.md5(data).hexdigest()

    if archiveMd5 != existingObjectMd5:
        logging.info("Uploading {Package}, MD5 mismatch. (Local {LocalMd5}, Remote {RemoteMd5})".format(
            Package=package,
            LocalMd5=archiveMd5,
            RemoteMd5=existingObjectMd5
        ))
        with open('/tmp/{}.nupkg'.format(package), 'rb') as archiveData:
            bucket.put_object(Key=packageKey, Body=archiveData)
    else:
        logging.info("Did NOT upload {Package}, MD5 match. (Local {LocalMd5}, Remote {RemoteMd5})".format(
            Package=package,
            LocalMd5=archiveMd5,
            RemoteMd5=existingObjectMd5
        ))


def build_package(packageDir):
    try:
        nugetPath = path.join(packageDir, 'nuget')
        nugetToolsPath = path.join(nugetPath, 'tools')
        installScriptPath = path.join(nugetToolsPath, 'chocolateyinstall.ps1')
        packageConfigPath = path.join(packageDir, 'config.yml')
        packageConfigJsonPath = path.join(nugetToolsPath, 'config.json')

        templatePath = path.join(
            os.getcwd(),
            'bootstrap',
            'templates'
        )
        nuspecTemplatePath = path.join(templatePath, 'package.nuspec')
        installTemplatePath = path.join(templatePath, 'chocolateyinstall.ps1')
        relsTemplatePath = path.join(templatePath, 'rels')
        contentTypesTemplatePath = path.join(templatePath, '[Content_Types].xml')
        metadataTemplatePath = path.join(templatePath, 'placeholder.psmdcp')

        copytree(path.join(packageDir, 'tools'), nugetToolsPath)
        copyfile(installTemplatePath, installScriptPath)

        with open(packageConfigPath, 'r') as configYaml:
            config = yaml.load(configYaml)

        with open(packageConfigJsonPath, 'w') as configJson:
            json.dump(config, configJson, sort_keys=True)

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

        # Write the minimum neccessary files so our zip looks like an OPC Package
        # https://en.wikipedia.org/wiki/Open_Packaging_Conventions
        # https://github.com/NuGet/NuGet2/blob/master/src/Core/Authoring/PackageBuilder.cs
        # ./[Content_Types].xml
        # ./_rels/.rels
        # ./package/services/metadata/core-properties/{package-name}.psmdcp
        opcContentTypesPath = path.join(nugetPath, '[Content_Types].xml')
        copyfile(contentTypesTemplatePath, opcContentTypesPath)

        opcRelsPath = path.join(
            nugetPath,
            '_rels',
            '.rels'
        )
        makedirs(os.path.dirname(opcRelsPath), exist_ok=True)
        with open(relsTemplatePath, 'r') as relsTemplate:
            relsContent = relsTemplate.read().format(
                Package=config['Id']
            )
        with open(opcRelsPath, 'w') as relsFile:
            relsFile.write(relsContent)

        opcMetadataPath = path.join(
            nugetPath,
            'package',
            'services',
            'metadata',
            'core-properties',
            '{}.psmdcp'.format(config['Id'])
        )
        makedirs(os.path.dirname(opcMetadataPath), exist_ok=True)
        with open(metadataTemplatePath, 'r') as metadataTemplate:
            metadataContent = metadataTemplate.read().format(
                Package=config['Id'],
                Description=config['Description'],
                Version=config['Version']
            )
        with open(opcMetadataPath, 'w') as metadataFile:
            metadataFile.write(metadataContent)

    except Exception as e:
        logging.exception('BAD_PACKAGE_CONFIG')
        logging.exception(e)
        raise e

    try:
        archive_base_name = '/{TempLocation}/{Package}.nupkg'.format(
            Package=config['Id'],
            TempLocation=ARCHIVE_TEMP_DIR
        )
        utils.zip_directory(nugetPath, archive_base_name)

        upload_package(config['Id'])
    except Exception as e:
        logging.exception("Failed to build and upload archive.")
        logging.exception(e)
        raise e


basePackageDir = os.path.join(os.getcwd(), 'packages')
packageList = [os.path.join(basePackageDir, d)
               for d in os.listdir(basePackageDir)
               if d != '_template']
for package in packageList:
    build_package(package)
