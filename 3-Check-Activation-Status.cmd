@echo off
chcp 437 >nul
openfiles >nul 2>&1
if %errorlevel% NEQ 0 goto :UACPrompt
goto :gotAdmin

:UACPrompt
Echo CreateObject^("Shell.Application"^).ShellExecute WScript.Arguments^(0^),"%*","","runas",1 >"%temp%\elevating.vbs"
%systemroot%\system32\cscript.exe //nologo "%temp%\elevating.vbs" "%~dpnx0"
del /f /q "%temp%\elevating.vbs" >nul 2>&1
exit /b

:gotAdmin
setlocal enableextensions
setLocal EnableDelayedExpansion
echo ************************************************************
echo ***                   Windows Status                     ***
echo ************************************************************
cscript //nologo %systemroot%\System32\slmgr.vbs /dli
cscript //nologo %systemroot%\System32\slmgr.vbs /xpr
echo ____________________________________________________________________________
echo.

:office2016
SET office=
FOR /F "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Microsoft\Office\16.0\Common\InstallRoot /v Path" 2^>nul') do (set "office=%%b")
if exist "%office%\OSPP.VBS" (
echo ************************************************************
if exist %systemroot%\SysWOW64\cmd.exe (echo ***              Office 2016 64-bit Status               ***) else (echo ***              Office 2016 32-bit Status               ***)
echo ************************************************************
cd /d "%office%"
cscript //nologo ospp.vbs /dstatus
cd /d "%~dp0"
)
if not exist %systemroot%\SysWOW64\cmd.exe goto :office2013
SET office=
FOR /F "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Office\16.0\Common\InstallRoot /v Path" 2^>nul') do (set "office=%%b")
if exist "%office%\OSPP.VBS" (
echo ************************************************************
echo ***              Office 2016 32-bit Status               ***
echo ************************************************************
cd /d "%office%"
cscript //nologo ospp.vbs /dstatus
cd /d "%~dp0"
)
echo ____________________________________________________________________________
echo.

:office2013
SET office=
FOR /F "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Microsoft\Office\15.0\Common\InstallRoot /v Path" 2^>nul') do (set "office=%%b")
if exist "%office%\OSPP.VBS" (
echo ************************************************************
if exist %systemroot%\SysWOW64\cmd.exe (echo ***              Office 2013 64-bit Status               ***) else (echo ***              Office 2013 32-bit Status               ***)
echo ************************************************************
cd /d "%office%"
cscript //nologo ospp.vbs /dstatus
cd /d "%~dp0"
)

if not exist %systemroot%\SysWOW64\cmd.exe goto :office2010
SET office=
FOR /F "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Office\15.0\Common\InstallRoot /v Path" 2^>nul') do (set "office=%%b")
if exist "%office%\OSPP.VBS" (
echo ************************************************************
echo ***              Office 2013 32-bit Status               ***
echo ************************************************************
cd /d "%office%"
cscript //nologo ospp.vbs /dstatus
cd /d "%~dp0"
)
echo ____________________________________________________________________________
echo.

:office2010
SET office=
FOR /F "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Microsoft\Office\14.0\Common\InstallRoot /v Path" 2^>nul') do (set "office=%%b")
if exist "%office%\OSPP.VBS" (
echo ************************************************************
if exist %systemroot%\SysWOW64\cmd.exe (echo ***              Office 2010 64-bit Status               ***) else (echo ***              Office 2010 32-bit Status               ***)
echo ************************************************************
cd /d "%office%"
cscript //nologo ospp.vbs /dstatus
cd /d "%~dp0"
)
if not exist %systemroot%\SysWOW64\cmd.exe goto :officeC2R
SET office=
FOR /F "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Office\14.0\Common\InstallRoot /v Path" 2^>nul') do (set "office=%%b")
if exist "%office%\OSPP.VBS" (
echo ************************************************************
echo ***              Office 2010 32-bit Status               ***
echo ************************************************************
cd /d "%office%"
cscript //nologo ospp.vbs /dstatus
cd /d "%~dp0"
)

:officeC2R
SET office=
for /f "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Microsoft\Office\ClickToRun /v InstallPath" 2^>nul') do (set "office=%%b\Office16")
if exist "%office%\OSPP.VBS" (
echo ************************************************************
echo ***                Office 2016 C2R Status                ***
echo ************************************************************
cd /d "%office%"
cscript //nologo ospp.vbs /dstatus
cd /d "%~dp0"
)
SET office=
for /f "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Microsoft\Office\15.0\ClickToRun /v InstallPath" 2^>nul') do (set "office=%%b\Office15")
if exist "%office%\OSPP.VBS" (
echo ************************************************************
echo ***                Office 2013 C2R Status                ***
echo ************************************************************
cd /d "%office%"
cscript //nologo ospp.vbs /dstatus
cd /d "%~dp0"
)
SET office=
for /f "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Microsoft\Office\14.0\ClickToRun /v InstallPath" 2^>nul') do (set "office=%%b\Office14")
if exist "%office%\OSPP.VBS" (
echo ************************************************************
echo ***                Office 2010 C2R Status                ***
echo ************************************************************
cd /d "%office%"
cscript //nologo ospp.vbs /dstatus
cd /d "%~dp0"
)
echo ____________________________________________________________________________
echo.

:end
echo ____________________________________________________________________________
echo.
echo Press any key to Exit
pause >nul
exit