@echo off
cd c:\projects\livemirror\install
type ..\version.rc | perl getversionnumber.pl > version.txt
IF ERRORLEVEL 1 GOTO error

call "C:\Program Files\Embarcadero\Studio\14.0\bin\rsvars.bat"

brcc32 c:\projects\livemirror\version.rc

echo Compiling Trial ...
msbuild /target:Build /property:config=Eval;UsePackages=false c:\projects\livemirror\LiveMirror.groupproj 
IF ERRORLEVEL 1 GOTO error

ecc32.exe --el_alter_exe"C:\Projects\livemirror\Service\LiveMirrorSrv.dproj;C:\Projects\livemirror\Service\Win32\Eval\LiveMirrorSrv.exe"
IF ERRORLEVEL 1 GOTO error
ecc32.exe --el_alter_exe"C:\Projects\livemirror\Manager\LiveMirrorMgr.dproj;C:\Projects\livemirror\Manager\Win32\Eval\LiveMirrorMgr.exe"
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling Trial setup...
"C:\program files\Inno Setup 5\iscc.exe" eval.iss 
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling Registered ...
msbuild /target:Build /property:config=Release;UsePackages=false c:\projects\livemirror\LiveMirror.groupproj
IF ERRORLEVEL 1 GOTO error

ecc32.exe --el_alter_exe"C:\Projects\livemirror\Service\LiveMirrorSrv.dproj;C:\Projects\livemirror\Service\Win32\Release\LiveMirrorSrv.exe"
IF ERRORLEVEL 1 GOTO error
ecc32.exe --el_alter_exe"C:\Projects\livemirror\Manager\LiveMirrorMgr.dproj;C:\Projects\livemirror\Manager\Win32\Release\LiveMirrorMgr.exe"
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling Registered setup...
"C:\program files\Inno Setup 5\iscc.exe" registered.iss 
IF ERRORLEVEL 1 GOTO error

goto end

:error
echo.
echo *** There is an error! ***
echo.

:end
pause