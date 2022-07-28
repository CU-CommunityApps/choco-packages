# Runs after the choco package is installed

Unregister-ScheduledTask GoogleUpdateTaskMachine* -Confirm:$false
