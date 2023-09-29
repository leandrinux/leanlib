@echo off
rem this file expects the following args
rem   xyz      to build and run program xyz 
rem this is not intended to build the libraries
cd %1
config -set "cpu cycles=max"
tpc -q -b -ec:\bin -dDEBUG %2.pas
if errorlevel 1 goto fail
echo.
config -set "cpu cycles=240"
c:\bin\%2
echo.
pause
goto end

:fail
echo.
pause

:end