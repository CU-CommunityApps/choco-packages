import logging
from os import environ, path
from utils import *

try:
    builder = AppStreamImageBuild()
except ImageBuildException as e:
    logging.exception('Init Exception:')
    # TODO Open other types of builds 

try:

    if not 'CHOCO_BOOTSTRAP_COMPLETE' in environ:
        builder.bootstrap()

    elif not 'CHOCO_INSTALL_COMPLETE' in environ:
        builder.install_packages()
    
        if isinstance(builder, AppStreamImageBuild):
            builder.catalog_applications()

except Exception as e:
    logging.exception('Build Exception:')
    builder.logger.critical(e)

finally:
    builder.save_logs()

