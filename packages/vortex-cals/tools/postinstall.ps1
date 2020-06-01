# Runs after the choco package is installed

#Move Project Folders to accessible location
move-item $env:%SYSTEMDRIVE%\Vortex10Projects $env:%SYSTEMDRIVE%\Users\Default\Documents\Vortex10Projects
move-item $env:%SYSTEMDRIVE%\VortexAMProjects $env:%SYSTEMDRIVE%\Users\Default\Documents\VortexAMProjects
