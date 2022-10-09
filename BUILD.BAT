@echo off
if "%1"=="" goto buildall

cd %1
tpc -b -ec:\bin %1.pas 
if errorlevel 0 goto ok
cd ..
echo.
echo Build error
goto end

:ok
cd ..
echo Build complete
goto end

:buildall
echo Building all libraries
call build base
call build classlib
call build sys

:end