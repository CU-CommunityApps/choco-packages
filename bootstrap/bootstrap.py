from utils import *

try:
    builder = AppStreamImageBuild()

except ImageBuildException as e:
    print(e) # TODO Open other types of builds 

