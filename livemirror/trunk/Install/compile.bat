@echo off
call "C:\Program Files\Embarcadero\RAD Studio\12.0\bin\rsvars.bat"

echo Compiling Trial ...
msbuild /target:Build /property:config=Eval;UsePackages=false c:\projects\livemirror\LiveMirror.groupproj 
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling Trial setup...
iscc eval.iss 
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling Registered ...
msbuild /target:Build /property:config=Release;UsePackages=false c:\projects\livemirror\LiveMirror.groupproj
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling Registered setup...
iscc registered.iss 
IF ERRORLEVEL 1 GOTO error

goto end

:error
echo.
echo *** There is an error! ***
echo.

:end
pause