@echo off
:::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set this flag to 1 for installing osppsvc hook
:::::::::::::::::::::::::::::::::::::::::::::::::::::::
set OsppHook=1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Adjust these settings for your use
:::::::::::::::::::::::::::::::::::::::::::::::::::::::
set KMS_Emulation=1
set KMS_ActivationInterval=120
set KMS_RenewalInterval=10080
set Windows=Random
set Office2010=Random
set Office2013=Random

chcp 437 >nul
%windir%\system32\reg.exe query "HKU\S-1-5-19" >nul 2>&1 || (
echo      -------
echo  *** WARNING ***
echo      -------
echo.
echo.
echo ADMINISTRATOR PRIVILEGES NOT DETECTED
echo ____________________________________________________________________________
echo.
echo This script require administrator privileges.
echo.
echo To do so, right click on this script and select 'Run as administrator'
echo.
echo.
echo.
echo Press any key to exit...
pause >nul
goto :eof
)
title SppExtComObjPatcher
setlocal enableextensions
setlocal EnableDelayedExpansion
cd /d "%~dp0"
set xOS=Win32
reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE | find /i "amd64" 1>nul && set xOS=x64
wmic path OfficeSoftwareProtectionService get version >nul 2>&1 || set OsppHook=0

for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G
if %winbuild% GEQ 9200 (
    set OSType=Win8
) else if %winbuild% GEQ 7600 (
    set OSType=Win7
) else (
    goto :UnsupportedVersion
)
echo.
echo Microsoft (R) Windows Software Licensing.
echo Copyright (C) Microsoft Corporation. All rights reserved.
echo =========================================================
echo.
IF EXIST "%SystemRoot%\system32\SppExtComObjPatcher.exe" goto :uninst

:inst
choice /C YN /N /M "SppExtComObjPatcher will be installed on your computer. Continue? [y/n]: "
echo.
IF ERRORLEVEL 2 exit
IF ERRORLEVEL 1 goto :run1
:run1
call :StopService sppsvc
if %OsppHook% NEQ 0 call :StopService osppsvc
echo.
echo Copying Files...
copy /y "%xOS%\SppExtComObjPatcher.exe" "%SystemRoot%\system32" >nul 2>&1 && echo status: OK
IF ERRORLEVEL 1 echo status: Error
copy /y "%xOS%\SppExtComObjHook.dll" "%SystemRoot%\system32" >nul 2>&1 && echo status: OK
IF ERRORLEVEL 1 echo status: Error
echo.
echo Creating Registry Entries...
if %OSType% EQU Win8 (
    echo Creating Registry Entry for SppExtComObj.exe of Windows 8/8.1/10
    call :CreateIFEOEntry "SppExtComObj.exe"
)
if %OSType% EQU Win7 (
    echo Creating Registry Entry for sppsvc.exe of Windows 7
    call :CreateIFEOEntry "sppsvc.exe"
)
if %OsppHook% NEQ 0 (
    echo Creating Registry Entry for osppsvc.exe of Office 2010/2013/2016
    call :CreateIFEOEntry "osppsvc.exe"
)
goto :end

:uninst
choice /C YN /N /M "SppExtComObjPatcher will be removed from your computer. Continue? [y/n]: "
echo.
IF ERRORLEVEL 2 exit
IF ERRORLEVEL 1 goto :run2
:run2
call :StopService2 sppsvc
if %OsppHook% NEQ 0 call :StopService2 osppsvc
echo.
echo Removing Installed Files...
if exist "%SystemRoot%\system32\SppExtComObjPatcher.exe" (
	echo SppExtComObjPatcher.exe Found. Removing...
	del /f /q "%SystemRoot%\system32\SppExtComObjPatcher.exe"
)
if exist "%SystemRoot%\system32\SppExtComObjHook.dll" (
	echo SppExtComObjHook.dll Found. Removing...
	del /f /q "%SystemRoot%\system32\SppExtComObjHook.dll"
)
echo.
echo Removing Registry Entries...
if %OSType% EQU Win8 (
    echo Removing Registry Entry for SppExtComObj.exe of Windows 8/8.1/10
    call :RemoveIFEOEntry "SppExtComObj.exe"
)
if %OSType% EQU Win7 (
    echo Removing Registry Entry for sppsvc.exe of Windows 7
    call :RemoveIFEOEntry "sppsvc.exe"
)
if %OsppHook% NEQ 0 (
    echo Removing Registry Entry for osppsvc.exe of Office 2010/2013/2016
    call :RemoveIFEOEntry "osppsvc.exe"
)
schtasks /query /tn "\Microsoft\Windows\SoftwareProtectionPlatform\SvcTrigger" >nul 2>&1 && (
schtasks /delete /f /tn "\Microsoft\Windows\SoftwareProtectionPlatform\SvcTrigger" >nul 2>&1
)
if %winbuild% GEQ 9600 (
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v "NoGenTicket" /f >nul 2>&1
)
goto :end

:CreateIFEOEntry
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "Debugger" /t REG_SZ /d "SppExtComObjPatcher.exe" >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "KMS_Emulation" /t REG_DWORD /d %KMS_Emulation% >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "KMS_ActivationInterval" /t REG_DWORD /d %KMS_ActivationInterval% >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "KMS_RenewalInterval" /t REG_DWORD /d %KMS_RenewalInterval% >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "Office2013" /t REG_SZ /d "%Office2013%" >nul 2>&1
if %~1 NEQ osppsvc.exe (
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "Windows" /t REG_SZ /d "%Windows%" >nul 2>&1
)
if %~1 EQU osppsvc.exe (
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "Office2010" /t REG_SZ /d "%Office2010%" >nul 2>&1
)
goto :EOF

:RemoveIFEOEntry
if %~1 NEQ osppsvc.exe (
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f >nul 2>&1
)
if %~1 EQU osppsvc.exe (
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "Debugger" >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "KMS_Emulation" >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "KMS_ActivationInterval" >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "KMS_RenewalInterval" >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "Office2010" >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "Office2013" >nul 2>&1
)
goto :EOF

:StopService
sc query %1 | find /i "STOPPED" >nul 2>&1
if %ERRORLEVEL% NEQ 0 net stop %1 /y >nul 2>&1
sc query %1 | find /i "STOPPED" >nul 2>&1
if %ERRORLEVEL% NEQ 0 sc stop %1 >nul 2>&1
goto :EOF

:StopService2
sc query %1 | find /i "RUNNING" >nul 2>&1
if %ERRORLEVEL% EQU 0 net stop %1 /y >nul 2>&1
sc query %1 | find /i "RUNNING" >nul 2>&1
if %ERRORLEVEL% EQU 0 sc stop %1 >nul 2>&1
goto :EOF

:UnsupportedVersion
echo ==== ERROR ====
echo Unsupported OS version Detected.
echo This project is only supported for Windows 7/8/8.1/10
echo.
echo Press any key to exit...
pause >nul
exit

:end
echo.
echo Done.
echo Press any key to exit...
pause >nul
exit