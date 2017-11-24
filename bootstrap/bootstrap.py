from utils import *

try:
    builder = AppStreamImageBuild()
except ImageBuildException as e:
    print(e) # TODO Open other types of builds 

try:
    builder.bootstrap()
except Exception as e:
    print(e)

