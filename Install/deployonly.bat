@echo off

set /p vernum=<version.txt
echo Version number %vernum%
call ftpupload.bat Output\LiveMirrorSetup_%vernum%.exe
call ftpupload.bat Output\LiveMirrorEval_%vernum%.exe
pause