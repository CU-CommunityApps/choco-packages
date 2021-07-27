# Runs after the choco package is installed

start-sleep -second 60
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y --upgrade pip wheel setuptools" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y pypiwin32" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y docutils pygments" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "uninstall -y kivy.deps.glew kivy.deps.gstreamer kivy.deps.sd12 kivy.deps.angle" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y kivy_deps.sdl2==0.1.* kivy_deps.glew==0.1.*" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y kivy_deps.gstreamer kivy_deps.gstreamer==0.1.*" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y kivy_deps.angle==0.1*" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y kivy==1.11.1" -NoNewWindow
start-process "c:\program Files\Anaconda\Scripts\conda.exe" -argumentlist "install -y introcs" -NoNewWindow
