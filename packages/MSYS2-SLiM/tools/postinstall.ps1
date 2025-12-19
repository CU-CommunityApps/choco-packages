# Runs after the choco package is installed

#start-sleep -second 60
#start-process "C:\msys64\msys2_shell.cmd" -argumentlist "-defterm -no-start -mingw64 -c "pacman -Syu --noconfirm" -wait
#start-process "C:\msys64\msys2_shell.cmd" -argumentlist "-defterm -no-start -mingw64 -c "pacman -S --noconfirm mingw-w64-x86_64-slim-simulator"