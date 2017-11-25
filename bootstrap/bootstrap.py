import logging
from utils import *

try:
    builder = AppStreamImageBuild()
except ImageBuildException as e:
    logging.exception('Init Exception:')
    # TODO Open other types of builds 

try:
    builder.bootstrap()
    builder.install_packages()
except Exception as e:
    logging.exception('Build Exception:')

with open('C:\\quicklog.log', 'w') as quicklog:
    builder.logString.seek(0)
    quicklog.write(builder.logString.read())

