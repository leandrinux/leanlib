@echo off
if "%1"=="" goto buildall

md d:\%1 >nul
deltree /y d:\%1\*.* >nul
md d:\tpu >nul

copy %1\*.pas d:\%1 >nul
d:
cd d:\%1
tpc -b -ed:\tpu app.pas 
if errorlevel 0 goto ok
echo.
echo Build error
goto end

:ok
cd \
c:
echo Build complete
goto end

:buildall
echo Building all libraries
call build base
call build classlib
call build sys

:end
