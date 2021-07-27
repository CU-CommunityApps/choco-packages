# Runs after the choco package is installed

start-sleep -second 60
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y --upgrade pip wheel setuptools" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y pypiwin32" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y docutils pygments" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y kivy_deps.sdl2==0.1.22 kivy_deps.glew==0.1.12" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y kivy_deps.gstreamer==0.1.17" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y kivy --upgrade" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y introcs --upgrade" -NoNewWindow
