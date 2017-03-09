@echo off
cd  c:\git\livemirror\install
type ..\version.rc | perl getversionnumber.pl > version.txt
IF ERRORLEVEL 1 GOTO error

call "C:\Program Files (x86)\Embarcadero\Studio\14.0\bin\rsvars.bat"

brcc32 c:\git\livemirror\version.rc

echo Compiling Registered ...
msbuild /target:Build /property:config=Release;UsePackages=false c:\git\livemirror\LiveMirror.groupproj
IF ERRORLEVEL 1 GOTO error

ecc32.exe --el_alter_exe"c:\git\livemirror\Service\LiveMirrorSrv.dproj;c:\git\livemirror\Service\Win32\Release\LiveMirrorSrv.exe"
IF ERRORLEVEL 1 GOTO error
ecc32.exe --el_alter_exe"c:\git\livemirror\Manager\LiveMirrorMgr.dproj;c:\git\livemirror\Manager\Win32\Release\LiveMirrorMgr.exe"
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling Registered setup...
"C:\program files (x86)\Inno Setup 5\iscc.exe" registered.iss 
IF ERRORLEVEL 1 GOTO error

goto end

echo Compiling Trial ...
msbuild /target:Build /property:config=Eval;UsePackages=false c:\git\livemirror\LiveMirror.groupproj 
IF ERRORLEVEL 1 GOTO error

ecc32.exe --el_alter_exe"c:\git\livemirror\Service\LiveMirrorSrv.dproj;c:\git\livemirror\Service\Win32\Eval\LiveMirrorSrv.exe"
IF ERRORLEVEL 1 GOTO error
ecc32.exe --el_alter_exe"c:\git\livemirror\Manager\LiveMirrorMgr.dproj;c:\git\livemirror\Manager\Win32\Eval\LiveMirrorMgr.exe"
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling Trial setup...
"C:\program files (x86)\Inno Setup 5\iscc.exe" eval.iss 
IF ERRORLEVEL 1 GOTO error

echo.

:error
echo.
echo *** There is an error! ***
echo.

:end