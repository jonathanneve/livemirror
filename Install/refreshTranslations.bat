@echo off

echo Refreshing service translations...
cd ..\service
call ..\gettext.bat
IF ERRORLEVEL 1 GOTO error

echo Refreshing Manager translations...
cd ..\Manager
call ..\gettext.bat
IF ERRORLEVEL 1 GOTO error

echo Refreshing Guardian translations...
cd ..\Guardian
call ..\gettext.bat
IF ERRORLEVEL 1 GOTO error

goto end

:error
echo.
echo *** There is an error! ***
echo.

:end
pause