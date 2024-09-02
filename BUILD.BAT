@echo off
rem this file expects the following args
rem   (nothing) to build all libraries
rem   xyz      to build library xyz 
rem this is not intended to compile and run a file

if "%1"=="" goto buildall

:build
echo.
echo Building %1
md c:\bin >nul
config -set "cpu cycles=max"
tpc -q -b -ec:\bin -u%currentdir% -dDEBUG build.pas
if errorlevel 1 goto fail
echo success
cd %currentdir%
goto end

:fail
echo.
echo fail
exit

:buildall
echo.
echo Building all libraries
del /q c:\bin\*.* >nul
call build .
del /q c:\bin\*.exe >nul

:end
exit