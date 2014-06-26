@echo off
call "C:\Program Files\Embarcadero\Studio\14.0\bin\rsvars.bat"

brcc32 c:\projects\livemirror\version.rc

echo Compiling Trial ...
msbuild /target:Build /property:config=Eval;UsePackages=false c:\projects\livemirror\LiveMirror.groupproj 
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling Trial setup...
"C:\program files\Inno Setup 5\iscc.exe" eval.iss 
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling Registered ...
msbuild /target:Build /property:config=Release;UsePackages=false c:\projects\livemirror\LiveMirror.groupproj
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