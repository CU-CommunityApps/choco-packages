# Runs after the choco package is installed

#Move Project Folders to accessible location
move-item %SYSTEMDRIVE%\Vortex10Projects %SYSTEMDRIVE%\Users\Default\Documents\Vortex10Projects
move-item %SYSTEMDRIVE%\VortexAMProjects %SYSTEMDRIVE%\Users\Default\Documents\VortexAMProjects
