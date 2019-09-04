# Runs after the choco package is installed
start-sleep -second 60
start-process "$env:programFiles\Anaconda\Scripts\conda.exe" -argumentlist "install -y numpy" -NoNewWindow
start-sleep -second 60
start-process "$env:programFiles\Anaconda\Scripts\conda.exe" -argumentlist "install -y Kivy" -NoNewWindow
start-sleep -second 60
start-process "$env:programFiles\Anaconda\Scripts\conda.exe" -argumentlist "install -y pypiwin32" -NoNewWindow
start-sleep -second 60
start-process "$env:programFiles\Anaconda\Scripts\conda.exe" -argumentlist "install -y docutils pygments" -NoNewWindow
start-sleep -second 60
start-process "$env:programFiles\Anaconda\Scripts\conda.exe" -argumentlist "install -y kivy_deps.sdl2==0.1.22 kivy_deps.glew==0.1.12" -NoNewWindow
start-sleep -second 60
start-process "$env:programFiles\Anaconda\Scripts\conda.exe" -argumentlist "install -y kivy_deps.gstreamer==0.1.17" -NoNewWindow
start-sleep -second 60
start-process "$env:programFiles\Anaconda\Scripts\conda.exe" -argumentlist "install -y kivy --upgrade" -NoNewWindow
