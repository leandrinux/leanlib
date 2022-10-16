@echo off
rem this file expects the following args
rem   xyz      to build and run program xyz 
rem this is not intended to build the libraries
cd %1
tpc -q -b -ec:\bin -dDEBUG %2.pas
if errorlevel 1 goto fail
echo.
c:\bin\%2
goto end

:fail
echo.
pause

:end