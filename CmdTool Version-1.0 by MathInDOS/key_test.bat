@echo off

:main
echo.
echo Press q!
cmdtool k
if %errorlevel%== 113 goto :yes
goto :main

:yes
cls
echo Yes you pressed q!
pause
exit


