@echo off
if "%1"=="" goto buildall

:build
cd %1
tpc -q -b -ec:\bin %1.pas 
if errorlevel 0 goto ok
echo.
echo %1 failed to build
exit

:ok
cd ..
echo.
echo %1 built successfully
echo.
goto end

:buildall
echo.
echo Building all libraries
call build base
call build classlib
call build sys
call build gui

:end