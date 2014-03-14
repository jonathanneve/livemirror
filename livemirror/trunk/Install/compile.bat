@echo off
call "C:\Program Files\Embarcadero\RAD Studio\12.0\bin\rsvars.bat"
msbuild /target:Build /property:config=Release;UsePackages=false c:\projects\livemirror\LiveMirror.groupproj
pause