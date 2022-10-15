@echo off
rem this file expects the following args
rem   (nothing) to build all libraries
rem   xyz      to build library xyz 
rem this is not intended to compile and run a file

if "%1"=="" goto buildall

:build
echo.
echo Building %1
cd %1
tpc -q -b -ec:\bin build.pas
if errorlevel 1 goto fail
echo success
cd ..
goto end

:fail
echo.
echo fail
exit

:buildall
echo.
echo Building all libraries
del /q c:\bin\*.* >nul
call build base
call build classlib
call build sys
call build gui

:end