# Runs after the choco package is installed
# Removing file based on Autodesk doc - https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/Warning-1909-Could-not-create-Shortcut-Add-A-Plot-Style-Table-Wizzard-lnk-Verify-that-the-destination-folder-exists-and-that-you-can-access-it-or-similar-error-error-when-launching-AutoCAD-2023-or-verticals.html
rm "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\AutoCAD 2026 - English\Reference Manager.lnk" -Force
