@echo off
rem this file expects the following args
rem   (nothing) to build all libraries
rem   xyz      to build library xyz 
rem this is not intended to compile and run a file

if "%1"=="" goto buildall

:build
echo.
apps\lab\basedir > basedir.bat
call basedir
echo Building %1
cd %1
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
apps\lab\basedir > basedir.bat
call basedir
apps\ats\ats > %currentdir%\ats.pas
echo.
echo Building all libraries
del /q c:\bin\*.* >nul
call build base
call build classlib
call build sys
call build gui
call build lsystem\common
call build lsystem\lc
call build lsystem\lrt
del /q c:\bin\*.exe >nul

:end
del basedir.bat >nul
del /q %currentdir%\ats.pas >nul