@echo off
title KMS_VL_ALL
color 1F
set port=1688
set kmsip=1.2.7.0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set this flag to 1 for installing osppsvc hook
:::::::::::::::::::::::::::::::::::::::::::::::::::::::
set OsppHook=1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Adjust these settings for your use
:::::::::::::::::::::::::::::::::::::::::::::::::::::::
set KMS_ActivationInterval=43200
set KMS_RenewalInterval=43200

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
IF EXIST "%SystemRoot%\system32\SppExtComObjPatcher.exe" (
echo      -------
echo  *** WARNING ***
echo      -------
echo.
echo.
echo SppExtComObjPatcher is already installed on the system.
echo ____________________________________________________________________________
echo.
echo use SppExtComObjPatcher.cmd to uninstall it first
echo before you can use this script for standalone activation
echo.
echo.
echo Press any key to exit...
pause >nul
goto :eof
)
setlocal EnableExtensions
setlocal EnableDelayedExpansion
cd /d "%~dp0"
set xOS=Win32
reg query "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE | find /i "amd64" 1>nul && set xOS=x64
wmic path OfficeSoftwareProtectionService get version >nul 2>&1 || set OsppHook=0

for /f "tokens=3 delims=: " %%G in ('dism /Online /Get-CurrentEdition /English ^| find /i "Current Edition :"') do set EditionID=%%G
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G
if %winbuild% GEQ 9200 (
    set OSType=Win8
) else if %winbuild% GEQ 7600 (
    set OSType=Win7
) else (
    goto :UnsupportedVersion
)

call :StopService sppsvc
if %OsppHook% NEQ 0 call :StopService osppsvc

copy /y "%xOS%\SppExtComObjPatcher.exe" "%SystemRoot%\system32" >nul 2>&1
copy /y "%xOS%\SppExtComObjHook.dll" "%SystemRoot%\system32" >nul 2>&1

if %OSType% EQU Win8 call :CreateIFEOEntry "SppExtComObj.exe"
if %OSType% EQU Win7 call :CreateIFEOEntry "sppsvc.exe"
if %OsppHook% NEQ 0 call :CreateIFEOEntry "osppsvc.exe"

if %winbuild% GEQ 9600 (
%windir%\system32\reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v NoGenTicket /t REG_DWORD /d 1 /f >nul 2>&1
)

set /a loc_off16=0
for /f "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Microsoft\Office\16.0\Common\InstallRoot /v Path" 2^>nul') do (set "msi16=%%b")
for /f "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Office\16.0\Common\InstallRoot /v Path" 2^>nul') do (set "msi16wow=%%b")
if exist "%msi16%\OSPP.VBS" (
  set /a loc_off16=1
) else if exist "%msi16wow%\OSPP.VBS" (
  set /a loc_off16=1
) else if exist "%ProgramFiles%\Common Files\Microsoft Shared\ClickToRun\*" (
  set /a loc_off16=1
) else if exist "%ProgramFiles%\Microsoft Office\Office16\OSPP.VBS" (
  set /a loc_off16=1
) else if exist "%ProgramFiles(x86)%\Microsoft Office\Office16\OSPP.VBS" (
  set /a loc_off16=1
)

set /a loc_off15=0
for /f "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Microsoft\Office\15.0\Common\InstallRoot /v Path" 2^>nul') do (set "msi15=%%b")
for /f "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Office\15.0\Common\InstallRoot /v Path" 2^>nul') do (set "msi15wow=%%b")
if exist "%msi15%\OSPP.VBS" (
  set /a loc_off15=1
) else if exist "%msi15wow%\OSPP.VBS" (
  set /a loc_off15=1
) else if exist "%ProgramFiles%\Common Files\Microsoft Shared\ClickToRun\*" (
  set /a loc_off15=1
) else if exist "%ProgramFiles%\Microsoft Office\Office15\OSPP.VBS" (
  set /a loc_off15=1
) else if exist "%ProgramFiles(x86)%\Microsoft Office\Office15\OSPP.VBS" (
  set /a loc_off15=1
)
set /a loc_off14=0
for /f "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Microsoft\Office\14.0\Common\InstallRoot /v Path" 2^>nul') do (set "msi14=%%b")
for /f "tokens=2*" %%a IN ('"reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Office\14.0\Common\InstallRoot /v Path" 2^>nul') do (set "msi14wow=%%b")
if exist "%msi14%\OSPP.VBS" (
  set /a loc_off14=1
) else if exist "%msi14wow%\OSPP.VBS" (
  set /a loc_off14=1
) else if exist "%ProgramFiles%\Common Files\Microsoft Shared\ClickToRun\*" (
  set /a loc_off14=1
) else if exist "%ProgramFiles%\Microsoft Office\Office14\OSPP.VBS" (
  set /a loc_off14=1
) else if exist "%ProgramFiles(x86)%\Microsoft Office\Office14\OSPP.VBS" (
  set /a loc_off14=1
)

call :SPP
call :OSPP

call :StopService2 sppsvc
if %OsppHook% NEQ 0 call :StopService2 osppsvc

del /f /q "%SystemRoot%\system32\SppExtComObjPatcher.exe" >nul 2>&1
del /f /q "%SystemRoot%\system32\SppExtComObjHook.dll" >nul 2>&1

if %OSType% EQU Win8 call :RemoveIFEOEntry "SppExtComObj.exe"
if %OSType% EQU Win7 call :RemoveIFEOEntry "sppsvc.exe"
if %OsppHook% NEQ 0 call :RemoveIFEOEntry "osppsvc.exe"

sc start sppsvc trigger=timer;sessionid=0 >nul 2>&1
echo.
echo.
echo Press any key to exit...
pause >nul
exit

:CreateIFEOEntry
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "Debugger" /t REG_SZ /d "SppExtComObjPatcher.exe" >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "KMS_Emulation" /t REG_DWORD /d 1 >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "KMS_ActivationInterval" /t REG_DWORD /d %KMS_ActivationInterval% >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "KMS_RenewalInterval" /t REG_DWORD /d %KMS_RenewalInterval% >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "Office2013" /t REG_SZ /d "Random" >nul 2>&1
if %~1 NEQ osppsvc.exe (
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f /v "Windows" /t REG_SZ /d "Random" >nul 2>&1
)
if %~1 EQU osppsvc.exe (
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\osppsvc.exe" /f /v "Office2010" /t REG_SZ /d "Random" >nul 2>&1
)
goto :EOF

:RemoveIFEOEntry
if %~1 NEQ osppsvc.exe (
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /f >nul 2>&1
)
if %~1 EQU osppsvc.exe (
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\osppsvc.exe" /f /v "Debugger" >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\osppsvc.exe" /f /v "KMS_Emulation" >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\osppsvc.exe" /f /v "KMS_ActivationInterval" >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\osppsvc.exe" /f /v "KMS_RenewalInterval" >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\osppsvc.exe" /f /v "Office2010" >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\osppsvc.exe" /f /v "Office2013" >nul 2>&1
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

:SPP
set hSpp="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"
reg delete %hSpp%\55c92734-d682-4d71-983e-d6ec3f16059f /f >nul 2>&1
reg delete %hSpp%\0ff1ce15-a989-479d-af46-f275c6370663 /f >nul 2>&1
set spp=SoftwareLicensingProduct
set sps=SoftwareLicensingService
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G
if %winbuild% LSS 9200 set /a win7=1
wmic path %spp% where (Description like '%%KMSCLIENT%%') get Name /format:list 2>nul | findstr /i Office >nul 2>&1
if %errorlevel% equ 0 set /a office15=1
if %errorlevel% neq 0 (if not defined win7 echo.&echo No Supported KMS Client Office 2013/2016 Detected...)
wmic path %spp% where (Description like '%%KMSCLIENT%%') get Name /format:list 2>nul | findstr /i Windows >nul 2>&1
if %errorlevel% equ 0 set /a WinVL=1
if %errorlevel% neq 0 (echo.&echo No Supported KMS Client Windows Detected...)
if not defined office15 if not defined WinVL exit /b
for /f "tokens=2 delims==" %%A in ('"wmic path %sps% get version /format:list"') do set ver=%%A
wmic path %sps% where version='%ver%' call SetKeyManagementServiceMachine MachineName="%kmsip%" >nul 2>&1
wmic path %sps% where version='%ver%' call SetKeyManagementServicePort %port% >nul 2>&1
for /f "tokens=2 delims==" %%G in ('"wmic path %spp% where (Description like '%%KMSCLIENT%%') get ID /format:list"') do (set app=%%G&call :sppchk)
wmic path %sps% where version='%ver%' call ClearKeyManagementServiceMachine >nul 2>&1
wmic path %sps% where version='%ver%' call ClearKeyManagementServicePort >nul 2>&1
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceDnsPublishing 1 >nul 2>&1
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceHostCaching 1 >nul 2>&1
set hSpp="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"
reg delete %hSpp%\55c92734-d682-4d71-983e-d6ec3f16059f /f >nul 2>&1
reg delete %hSpp%\0ff1ce15-a989-479d-af46-f275c6370663 /f >nul 2>&1
set hSpp="HKEY_USERS\S-1-5-20\Software\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"
reg delete %hSpp%\55c92734-d682-4d71-983e-d6ec3f16059f /f >nul 2>&1
reg delete %hSpp%\0ff1ce15-a989-479d-af46-f275c6370663 /f >nul 2>&1
exit /b

:sppchk
set /a ls=0
set /a office=0
set /a off15=0
set /a off16=0
wmic path %spp% where ID='%app%' get Name /format:list | findstr /i "Office" 1>nul && set /a office=1
wmic path %spp% where ID='%app%' get Name /format:list | findstr /i /C:"Office 15" 1>nul && set /a off15=1
wmic path %spp% where ID='%app%' get Name /format:list | findstr /i /C:"Office 16" 1>nul && set /a off16=1
if %off15% equ 1 if %loc_off15% equ 0 exit /b
if %off16% equ 1 if %loc_off16% equ 0 exit /b
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where ID='%app%' get LicenseStatus /format:list"') do set /a ls=%%A
if %ls% equ 1 (call :activate %app%&exit /b)
if /i '%app%' equ 'b71515d9-89a2-4c60-88c8-656fbcca7f3a' exit /b
if /i '%app%' equ '3f1afc82-f8ac-4f6c-8005-1d233e606eee' if /i %EditionID% equ Professional exit /b
if /i '%app%' equ '73111121-5638-40f6-bc11-f1d7b0d64300' if /i %EditionID% equ Professional exit /b
if /i '%app%' equ '2de67392-b7a7-462a-b1ca-108dd189f588' if /i %EditionID% equ ProfessionalEducation exit /b
if /i '%app%' equ '73111121-5638-40f6-bc11-f1d7b0d64300' if /i %EditionID% equ ProfessionalEducation exit /b
if /i '%app%' equ '2de67392-b7a7-462a-b1ca-108dd189f588' if /i %EditionID% equ Enterprise exit /b
if /i '%app%' equ '3f1afc82-f8ac-4f6c-8005-1d233e606eee' if /i %EditionID% equ Enterprise exit /b
if /i '%app%' equ '5300b18c-2e33-4dc2-8291-47ffcec746dd' if /i %EditionID% equ ProfessionalN exit /b
if /i '%app%' equ 'e272e3e2-732f-4c65-a8f0-484747d0d947' if /i %EditionID% equ ProfessionalN exit /b
if /i '%app%' equ 'a80b5abf-76ad-428b-b05d-a47d2dffeebf' if /i %EditionID% equ ProfessionalEducationN exit /b
if /i '%app%' equ 'e272e3e2-732f-4c65-a8f0-484747d0d947' if /i %EditionID% equ ProfessionalEducationN exit /b
if /i '%app%' equ 'a80b5abf-76ad-428b-b05d-a47d2dffeebf' if /i %EditionID% equ EnterpriseN exit /b
if /i '%app%' equ '5300b18c-2e33-4dc2-8291-47ffcec746dd' if /i %EditionID% equ EnterpriseN exit /b
if %office% equ 1 (call :sppchkOffice15 %app%) else (call :sppchkWindows %app%)
exit /b

:OSPP
set hOspp=HKLM\SOFTWARE\Microsoft\OfficeSoftwareProtectionPlatform
reg delete %hOspp%\59a52881-a989-479d-af46-f275c6370663 /f >nul 2>&1
reg delete %hOspp%\0ff1ce15-a989-479d-af46-f275c6370663 /f >nul 2>&1
set spp=OfficeSoftwareProtectionProduct
set sps=OfficeSoftwareProtectionService
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G
if %winbuild% LSS 9200 set /a win7=1
wmic path %sps% get version >nul 2>&1
if %errorlevel% neq 0 (if defined win7 (echo.&echo No Installed Office 2010/2013/2016 Product Detected...&exit /b) else (echo.&echo No Installed Office 2010 Product Detected...&exit /b))
for /f "tokens=2 delims==" %%A in ('"wmic path %sps% get version /format:list" 2^>nul') do set ver=%%A
wmic path %spp% where (Description like '%%KMSCLIENT%%') get Name /format:list >nul 2>&1
if %errorlevel% neq 0 (if defined win7 (echo.&echo No Supported KMS Client Office 2010/2013/2016 Product Detected...&exit /b) else (echo.&echo No Supported KMS Client Office 2010 Product Detected...&exit /b))
wmic path %sps% where version='%ver%' call SetKeyManagementServiceMachine MachineName="%kmsip%" >nul 2>&1
wmic path %sps% where version='%ver%' call SetKeyManagementServicePort %port% >nul 2>&1
for /f "tokens=2 delims==" %%G in ('"wmic path %spp% where (Description like '%%KMSCLIENT%%') get ID /format:list"') do (set app=%%G&call :osppchk)
wmic path %sps% where version='%ver%' call ClearKeyManagementServiceMachine >nul 2>&1
wmic path %sps% where version='%ver%' call ClearKeyManagementServicePort >nul 2>&1
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceDnsPublishing 1 >nul 2>&1
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceHostCaching 1 >nul 2>&1
set hOspp=HKLM\SOFTWARE\Microsoft\OfficeSoftwareProtectionPlatform
reg delete %hOspp%\59a52881-a989-479d-af46-f275c6370663 /f >nul 2>&1
reg delete %hOspp%\0ff1ce15-a989-479d-af46-f275c6370663 /f >nul 2>&1
exit /b

:osppchk
set /a ls=0
set /a off14=0
set /a off15=0
set /a off16=0
wmic path %spp% where ID='%app%' get Name /format:list | findstr /i /C:"Office 14" 1>nul && set /a off14=1
wmic path %spp% where ID='%app%' get Name /format:list | findstr /i /C:"Office 15" 1>nul && set /a off15=1
wmic path %spp% where ID='%app%' get Name /format:list | findstr /i /C:"Office 16" 1>nul && set /a off16=1
if %off14% equ 1 if %loc_off14% equ 0 exit /b
if %off15% equ 1 if %loc_off15% equ 0 exit /b
if %off16% equ 1 if %loc_off16% equ 0 exit /b
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where ID='%app%' get LicenseStatus /format:list"') do set /a ls=%%A
if %ls% equ 1 (call :activate %app%&exit /b)
if %off14% equ 1 (call :osppchkOffice14 %app%) else (call :sppchkOffice15 %app%)
exit /b

:sppchkWindows
echo.
wmic path %spp% where (Description like '%%KMSCLIENT%%' AND Name like '%%Windows%%') get LicenseStatus /format:list 2>nul | findstr /i 1 >nul 2>&1
if %errorlevel% equ 0 (exit /b)
wmic path %spp% where (Description like '%%VOLUME_MAK%%') get LicenseStatus /format:list 2>nul | findstr /i 1 >nul 2>&1
if %errorlevel% equ 0 (echo Detected Windows is permanently activated.&exit /b)
wmic path %spp% where (Description like '%%OEM%%') get LicenseStatus /format:list 2>nul | findstr /i 1 >nul 2>&1
if %errorlevel% equ 0 (echo Detected Windows is permanently activated.&exit /b)
wmic path %spp% where (Description like '%%System, RETAIL%%') get LicenseStatus /format:list 2>nul | findstr /i 1 >nul 2>&1
if %errorlevel% equ 0 (echo Detected Windows is permanently activated.&exit /b)
wmic path %spp% where (Description like '%%7, RETAIL%%') get LicenseStatus /format:list 2>nul | findstr /i 1 >nul 2>&1
if %errorlevel% equ 0 (echo Detected Windows is permanently activated.&exit /b)
call :insKey %1
exit /b

:sppchkOffice15
set /a ls=0
if '%1' equ 'b322da9c-a2e2-4058-9e4e-f59a6970bd69' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeProPlusVL_MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Office ProPlus 2013 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ 'e13ac10e-75d0-4aff-a0cd-764982cf541c' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeVisioProVL_MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Visio Pro 2013 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ '4a5d124a-e620-44ba-b6ff-658961b33b9a' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeProjectProVL_MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Project Pro 2013 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ 'b13afb38-cd79-4ae5-9f7f-eed058d750ca' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeStandardVL_MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Office Standard 2013 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ 'ac4efaf0-f81f-4f61-bdf7-ea32b02ab117' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeVisioStdVL_MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Visio Standard 2013 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ '427a28d1-d17c-4abf-b717-32c780ba6f07' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeProjectStdVL_MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Project Standard 2013 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ 'd450596f-894d-49e0-966a-fd39ed4c4c64' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%Office16ProPlusVL_MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Office ProPlus 2016 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ '6bf301c1-b94a-43e9-ba31-d494598c47fb' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%Office16VisioProVL_MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Visio Pro 2016 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ '4f414197-0fc2-4c01-b68a-86cbb9ac254c' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%Office16ProjectProVL_MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Project Pro 2016 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ 'dedfa23d-6ed1-45a6-85dc-63cae0546de6' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%Office16StandardVL_MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Office Standard 2016 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ 'aa2a7821-1827-4c2c-8f1d-4513a34dda97' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%Office16VisioStdVL_MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Visio Standard 2016 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ 'da7ddabc-3fbe-4447-9e01-6ab7440b4cd4' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%Office16ProjectStdVL_MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Project Standard 2016 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
call :insKey %1
exit /b

:osppchkOffice14
set /a ls=0
set /a ls2=0
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeVisioPrem-MAK%%') get LicenseStatus /format:list" 2^>nul') do set /a vPrem=%%A
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeVisioPro-MAK%%') get LicenseStatus /format:list" 2^>nul') do set /a vPro=%%A
if '%1' equ '6f327760-8c5c-417c-9b61-836a98287e0c' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeProPlus-MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeProPlusAcad-MAK%%') get LicenseStatus /format:list"') do set /a ls2=%%A
if !ls! equ 1 (echo Detected Office ProPlus 2010 is permanently activated.&exit /b) 
if !ls2! equ 1 (echo Detected Office ProPlus Academic 2010 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ 'df133ff7-bf14-4f95-afe3-7b48e7e331ef' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeProjectPro-MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Project Pro 2010 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ '5dc7bf61-5ec9-4996-9ccb-df806a2d0efe' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeProjectStd-MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Project Standard 2010 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ '9da2a678-fb6b-4e67-ab84-60dd6a9c819a' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeStandard-MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Office Standard 2010 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ 'ea509e87-07a1-4a45-9edc-eba5a39f36af' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeSmallBusBasics-MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Office Small Business 2010 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if '%1' equ '92236105-bb67-494f-94c7-7f7a607929bd' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeVisioPrem-MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeVisioPro-MAK%%') get LicenseStatus /format:list"') do set /a ls2=%%A
if !ls! equ 1 (echo Detected Visio Premium 2010 is permanently activated.&exit /b)
if !ls2! equ 1 (echo Detected Visio Pro 2010 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if defined vPrem exit /b
if '%1' equ 'e558389c-83c3-4b29-adfe-5e4d7f46c358' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeVisioPro-MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeVisioStd-MAK%%') get LicenseStatus /format:list"') do set /a ls2=%%A
if !ls! equ 1 (echo Detected Visio Pro 2010 is permanently activated.&exit /b)
if !ls2! equ 1 (echo Detected Visio Standard 2010 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
if defined vPro exit /b
if '%1' equ '9ed833ff-4f92-4f36-b370-8683a4f13275' (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeVisioStd-MAK%%') get LicenseStatus /format:list"') do set /a ls=%%A
if !ls! equ 1 (echo Detected Visio Standard 2010 is permanently activated.&exit /b) else (call :insKey %1&exit /b)
)
call :insKey %1
exit /b

:activate
echo.
wmic path %spp% where ID='%1' call ClearKeyManagementServiceMachine >nul 2>&1
wmic path %spp% where ID='%1' call ClearKeyManagementServicePort >nul 2>&1
for /f "tokens=2 delims==" %%x in ('"wmic path %spp% where ID='%1' get Name /format:list"') do echo Attempting to activate: %%x
wmic path %spp% where ID='%1' call Activate >nul 2>&1
for /f "tokens=2 delims==" %%x in ('"wmic path %spp% where ID='%1' get GracePeriodRemaining /format:list"') do set gpr=%%x
if %gpr% equ 43200 (echo Windows Core/ProfessionalWMC Activation Successful&echo Remaining Period: 30 days ^(%gpr% minutes^)&exit /b)
if %gpr% equ 64800 (echo Windows Core/ProfessionalWMC Activation Successful&echo Remaining Period: 45 days ^(%gpr% minutes^)&exit /b)
if %gpr% equ 259200 (echo Product Activation Successful) else (echo Product Activation Failed)
set /a gpr2=%gpr%/60/24
echo Remaining Period: %gpr2% days ^(%gpr% minutes^)
exit /b

:insKey
echo.
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where ID='%1' get Name /format:list"') do echo Installing Key for: %%A
(echo edition = "%1"
echo Set keys = CreateObject ^("Scripting.Dictionary"^)
echo keys.Add "7b4433f4-b1e7-4788-895a-c45378d38253", "VP34G-4NPPG-79JTQ-864T4-R3MQX"
echo keys.Add "5300b18c-2e33-4dc2-8291-47ffcec746dd", "YVWGF-BXNMC-HTQYQ-CPQ99-66QFC"
echo keys.Add "3f1afc82-f8ac-4f6c-8005-1d233e606eee", "6TP4R-GNPTD-KYYHQ-7B7DP-J447Y"
echo keys.Add "2d5a5a60-3040-48bf-beb0-fcd770c20ce0", "DCPHK-NFMTC-H88MJ-PFHPY-QJ4BJ"
echo keys.Add "9f776d83-7156-45b2-8a5c-359b9c9f22a3", "QFFDN-GRT3P-VKWWX-X7T3R-8B639"
echo keys.Add "2b5a1b0f-a5ab-4c54-ac2f-a6d94824a283", "JCKRF-N37P4-C2D82-9YXRT-4M63B"
echo keys.Add "8c1c5410-9f39-4805-8c9d-63a07706358f", "WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY"
echo keys.Add "21c56779-b449-4d20-adfc-eece0e1ad74b", "CB7KF-BWN84-R7R2Y-793K2-8XDDG"
echo keys.Add "3dbf341b-5f6c-4fa7-b936-699dce9e263f", "QN4C6-GBJD2-FB422-GHWJK-GJG2R"
echo keys.Add "9caabccb-61b1-4b4b-8bec-d10a3c3ac2ce", "HFTND-W9MK4-8B7MJ-B6C4G-XQBR2"
echo keys.Add "d450596f-894d-49e0-966a-fd39ed4c4c64", "XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99"
echo keys.Add "dedfa23d-6ed1-45a6-85dc-63cae0546de6", "JNRGM-WHDWX-FJJG3-K47QV-DRTFM"
echo keys.Add "4f414197-0fc2-4c01-b68a-86cbb9ac254c", "YG9NW-3K39V-2T3HJ-93F3Q-G83KT"
echo keys.Add "da7ddabc-3fbe-4447-9e01-6ab7440b4cd4", "GNFHQ-F6YQM-KQDGJ-327XX-KQBVC"
echo keys.Add "6bf301c1-b94a-43e9-ba31-d494598c47fb", "PD3PC-RHNGV-FXJ29-8JK7D-RJRJK"
echo keys.Add "aa2a7821-1827-4c2c-8f1d-4513a34dda97", "7WHWN-4T7MP-G96JF-G33KR-W8GF4"
echo keys.Add "67c0fc0c-deba-401b-bf8b-9c8ad8395804", "GNH9Y-D2J4T-FJHGG-QRVH7-QPFDW"
echo keys.Add "c3e65d36-141f-4d2f-a303-a842ee756a29", "9C2PK-NWTVB-JMPW8-BFT28-7FTBF"
echo keys.Add "d8cace59-33d2-4ac7-9b1b-9b72339c51c8", "DR92N-9HTF2-97XKM-XW2WJ-XW3J6"
echo keys.Add "ec9d9265-9d1e-4ed0-838a-cdc20f2551a1", "R69KK-NTPKF-7M3Q4-QYBHW-6MT9B"
echo keys.Add "d70b1bba-b893-4544-96e2-b7a318091c33", "J7MQP-HNJ4Y-WJ7YM-PFYGF-BY6C6"
echo keys.Add "041a06cb-c5b8-4772-809f-416d03d16654", "F47MM-N3XJP-TQXJ9-BP99D-8K837"
echo keys.Add "83e04ee1-fa8d-436d-8994-d31a862cab77", "869NQ-FJ69K-466HW-QYCP2-DDBV6"
echo keys.Add "bb11badf-d8aa-470e-9311-20eaf80fe5cc", "WXY84-JN2Q9-RBCCQ-3Q3J3-3PFJ6"
echo keys.Add "2de67392-b7a7-462a-b1ca-108dd189f588", "W269N-WFGWX-YVC9B-4J6C9-T83GX"
echo keys.Add "a80b5abf-76ad-428b-b05d-a47d2dffeebf", "MH37W-N47XK-V7XM9-C7227-GCQG9"
echo keys.Add "73111121-5638-40f6-bc11-f1d7b0d64300", "NPPR9-FWDCX-D2C8J-H872K-2YT43"
echo keys.Add "e272e3e2-732f-4c65-a8f0-484747d0d947", "DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4"
echo keys.Add "e0c42288-980c-4788-a014-c080d2e1926e", "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2"
echo keys.Add "3c102355-d027-42c6-ad23-2e7ef8a02585", "2WH4N-8QGBV-H22JP-CT43Q-MDWWJ"
echo keys.Add "7b51a46c-0c04-4e8f-9af4-8496cca90d5e", "WNMTR-4C88C-JK8YV-HQ7T2-76DF9"
echo keys.Add "87b838b7-41b6-4590-8318-5797951d8529", "2F77B-TNFGY-69QQF-B8YKP-D69TJ"
echo keys.Add "58e97c99-f377-4ef1-81d5-4ad5522b5fd8", "TX9XD-98N7V-6WMQ6-BX7FG-H8Q99"
echo keys.Add "7b9e1751-a8da-4f75-9560-5fadfe3d8e38", "3KHY7-WNT83-DGQKR-F7HPR-844BM"
echo keys.Add "cd918a57-a41b-4c82-8dce-1a538e221a83", "7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH"
echo keys.Add "a9107544-f4a0-4053-a96a-1479abdef912", "PVMJN-6DFY6-9CCP6-7BKTT-D3WVR"
echo keys.Add "e9942b32-2e55-4197-b0bd-5ff58cba8860", "3PY8R-QHNP9-W7XQD-G6DPH-3J2C9"
echo keys.Add "c6ddecd6-2354-4c19-909b-306a3058484e", "Q6HTR-N24GM-PMJFP-69CD8-2GXKR"
echo keys.Add "b8f5e3a3-ed33-4608-81e1-37d6c9dcfd9c", "KF37N-VDV38-GRRTV-XH8X6-6F3BB"
echo keys.Add "ba998212-460a-44db-bfb5-71bf09d1c68b", "R962J-37N87-9VVK2-WJ74P-XTMHR"
echo keys.Add "e58d87b5-8126-4580-80fb-861b22f79296", "MX3RK-9HNGX-K3QKC-6PJ3F-W8D7B"
echo keys.Add "cab491c7-a918-4f60-b502-dab75e334f40", "TNFGH-2R6PB-8XM3K-QYHX2-J4296"
echo keys.Add "81671aaf-79d1-4eb1-b004-8cbbe173afea", "MHF9N-XY6XB-WVXMC-BTDCT-MKKG7"
echo keys.Add "c06b6981-d7fd-4a35-b7b4-054742b7af67", "GCRJD-8NW9H-F2CDX-CCM8D-9D6T9"
echo keys.Add "096ce63d-4fac-48a9-82a9-61ae9e800e5f", "789NJ-TQK6T-6XTH8-J39CJ-J8D3P"
echo keys.Add "fe1c3238-432a-43a1-8e25-97e7d1ef10f3", "M9Q9P-WNJJT-6PXPY-DWX8H-6XWKK"
echo keys.Add "c72c6a1d-f252-4e7e-bdd1-3fca342acb35", "BB6NG-PQ82V-VRDPW-8XVD2-V8P66"
echo keys.Add "db78b74f-ef1c-4892-abfe-1e66b8231df6", "NCTT7-2RGK8-WMHRF-RY7YQ-JTXG3"
echo keys.Add "ffee456a-cd87-4390-8e07-16146c672fd0", "XYTND-K6QKT-K2MRH-66RTM-43JKP"
echo keys.Add "113e705c-fa49-48a4-beea-7dd879b46b14", "TT4HM-HN7YT-62K67-RGRQJ-JFFXW"
echo keys.Add "7476d79f-8e48-49b4-ab63-4d0b813a16e4", "HMCNV-VVBFX-7HMBH-CTY9B-B4FXY"
echo keys.Add "78558a64-dc19-43fe-a0d0-8075b2a370a3", "7B9N3-D94CG-YTVHR-QBPX3-RJP64"
echo keys.Add "0ab82d54-47f4-4acb-818c-cc5bf0ecb649", "NMMPB-38DD4-R2823-62W8D-VXKJB"
echo keys.Add "cd4e2d9f-5059-4a50-a92d-05d5bb1267c7", "FNFKF-PWTVT-9RC8H-32HB2-JB34X"
echo keys.Add "f7e88590-dfc7-4c78-bccb-6f3865b99d1a", "VHXM3-NR6FT-RY6RT-CK882-KW2CJ"
echo keys.Add "b3ca044e-a358-4d68-9883-aaa2941aca99", "D2N9P-3P6X9-2R39C-7RTCD-MDVJX"
echo keys.Add "b743a2be-68d4-4dd3-af32-92425b7bb623", "3NPTF-33KPT-GGBPR-YX76B-39KDD"
echo keys.Add "00091344-1ea4-4f37-b789-01750ba6988c", "W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9"
echo keys.Add "21db6ba4-9a7b-4a14-9e29-64a60c59301d", "KNC87-3J2TX-XB4WP-VCPJV-M4FWM"
echo keys.Add "aa6dd3aa-c2b4-40e2-a544-a6bbb3f5c395", "73KQT-CD9G6-K7TQG-66MRP-CQ22C"
echo keys.Add "db537896-376f-48ae-a492-53d0547773d0", "YBYF6-BHCR3-JPKRB-CDW7B-F9BK4"
echo keys.Add "6f327760-8c5c-417c-9b61-836a98287e0c", "VYBBJ-TRJPB-QFQRF-QFT4D-H3GVB"
echo keys.Add "9da2a678-fb6b-4e67-ab84-60dd6a9c819a", "V7QKV-4XVVR-XYV4D-F7DFM-8R6BM"
echo keys.Add "ea509e87-07a1-4a45-9edc-eba5a39f36af", "D6QFG-VBYP2-XQHM7-J97RH-VVRCK"
echo keys.Add "8ce7e872-188c-4b98-9d90-f8f90b7aad02", "V7Y44-9T38C-R2VJK-666HK-T7DDX"
echo keys.Add "cee5d470-6e3b-4fcc-8c2b-d17428568a9f", "H62QG-HXVKF-PP4HP-66KMR-CW9BM"
echo keys.Add "8947d0b8-c33b-43e1-8c56-9b674c052832", "QYYW6-QP4CB-MBV6G-HYMCJ-4T3J4"
echo keys.Add "ca6b6639-4ad6-40ae-a575-14dee07f6430", "K96W8-67RPQ-62T9Y-J8FQJ-BT37T"
echo keys.Add "ab586f5c-5256-4632-962f-fefd8b49e6f4", "Q4Y4M-RHWJM-PY37F-MTKWH-D3XHX"
echo keys.Add "ecb7c192-73ab-4ded-acf4-2399b095d0cc", "7YDC2-CWM8M-RRTJC-8MDVC-X3DWQ"
echo keys.Add "45593b1d-dfb1-4e91-bbfb-2d5d0ce2227a", "RC8FX-88JRY-3PF7C-X8P67-P4VTT"
echo keys.Add "df133ff7-bf14-4f95-afe3-7b48e7e331ef", "YGX6F-PGV49-PGW3J-9BTGG-VHKC6"
echo keys.Add "5dc7bf61-5ec9-4996-9ccb-df806a2d0efe", "4HP3K-88W3F-W2K3D-6677X-F9PGB"
echo keys.Add "b50c4f75-599b-43e8-8dcd-1081a7967241", "BFK7F-9MYHM-V68C7-DRQ66-83YTP"
echo keys.Add "2d0882e7-a4e7-423b-8ccc-70d91e0158b1", "HVHB3-C6FV7-KQX9W-YQG79-CRY7T"
echo keys.Add "92236105-bb67-494f-94c7-7f7a607929bd", "D9DWC-HPYVV-JGF4P-BTWQB-WX8BJ"
echo keys.Add "e558389c-83c3-4b29-adfe-5e4d7f46c358", "7MCW8-VRQVK-G677T-PDJCM-Q8TCP"
echo keys.Add "9ed833ff-4f92-4f36-b370-8683a4f13275", "767HD-QGMWX-8QTDB-9G3R2-KHFGJ"
echo keys.Add "09ed9640-f020-400a-acd8-d7d867dfd9c2", "YBJTT-JG6MD-V9Q7P-DBKXJ-38W9R"
echo keys.Add "ef3d4e49-a53d-4d81-a2b1-2ca6c2556b2c", "7TC2V-WXF6P-TD7RT-BQRXR-B8K32"
echo keys.Add "ae2ee509-1b34-41c0-acb7-6d4650168915", "33PXH-7Y6KF-2VJC9-XBBR8-HVTHH"
echo keys.Add "46bbed08-9c7b-48fc-a614-95250573f4ea", "C29WB-22CC8-VJ326-GHFJW-H9DH4"
echo keys.Add "1cb6d605-11b3-4e14-bb30-da91c8e3983a", "YDRBP-3D83W-TY26F-D46B2-XCKRJ"
echo keys.Add "b92e9980-b9d5-4821-9c94-140f632f6312", "FJ82H-XT6CR-J8D7P-XQJJ2-GPDD4"
echo keys.Add "5a041529-fef8-4d07-b06f-b59b573b32d2", "W82YF-2Q76Y-63HXB-FGJG9-GF7QX"
echo keys.Add "54a09a0d-d57b-4c10-8b69-a842d6590ad5", "MRPKT-YTG23-K7D7T-X2JMM-QY7MG"
echo keys.Add "7482e61b-c589-4b7f-8ecc-46d455ac3b87", "74YFP-3QFB3-KQT8W-PMXWJ-7M648"
echo keys.Add "620e2b3d-09e7-42fd-802a-17a13652fe7a", "489J6-VHDMP-X63PK-3K798-CPX3Y"
echo keys.Add "8a26851c-1c7e-48d3-a687-fbca9b9ac16b", "GT63C-RJFQ3-4GMB6-BRFB9-CB83V"
echo keys.Add "f772515c-0e87-48d5-a676-e6962c3e1195", "736RG-XDKJK-V34PF-BHK87-J6X3K"
echo keys.Add "cda18cf3-c196-46ad-b289-60c072869994", "TT8MH-CG224-D3D7Q-498W2-9QCTX"
echo keys.Add "68531fb9-5511-4989-97be-d11a0f55633f", "YC6KT-GKW9T-YTKYR-T4X34-R7VHC"
echo keys.Add "a78b8bd9-8017-4df5-b86a-09f756affa7c", "6TPJF-RBVHG-WBW2R-86QPH-6RTM4"
echo keys.Add "b322da9c-a2e2-4058-9e4e-f59a6970bd69", "YC7DK-G2NP3-2QQC3-J6H88-GVGXT"
echo keys.Add "b13afb38-cd79-4ae5-9f7f-eed058d750ca", "KBKQT-2NMXY-JJWGP-M62JB-92CD4"
echo keys.Add "4a5d124a-e620-44ba-b6ff-658961b33b9a", "FN8TT-7WMH6-2D4X9-M337T-2342K"
echo keys.Add "427a28d1-d17c-4abf-b717-32c780ba6f07", "6NTH3-CW976-3G3Y2-JK3TX-8QHTT"
echo keys.Add "e13ac10e-75d0-4aff-a0cd-764982cf541c", "C2FG9-N6J68-H8BTJ-BW3QX-RM3B3"
echo keys.Add "ac4efaf0-f81f-4f61-bdf7-ea32b02ab117", "J484Y-4NKBF-W2HMG-DBMJC-PGWR7"
echo keys.Add "6ee7622c-18d8-4005-9fb7-92db644a279b", "NG2JY-H4JBT-HQXYP-78QH9-4JM2D"
echo keys.Add "f7461d52-7c2b-43b2-8744-ea958e0bd09a", "VGPNG-Y7HQW-9RHP7-TKPV3-BG7GB"
echo keys.Add "a30b8040-d68a-423f-b0b5-9ce292ea5a8f", "DKT8B-N7VXH-D963P-Q4PHY-F8894"
echo keys.Add "1b9f11e3-c85c-4e1b-bb29-879ad2c909e3", "2MG3G-3BNTT-3MFW9-KDQW3-TCK7R"
echo keys.Add "efe1f3e6-aea2-4144-a208-32aa872b6545", "TGN6P-8MMBC-37P2F-XHXXK-P34VW"
echo keys.Add "771c3afa-50c5-443f-b151-ff2546d863a0", "QPN8Q-BJBTJ-334K3-93TGY-2PMBT"
echo keys.Add "8c762649-97d1-4953-ad27-b7e2c25b972e", "4NT99-8RJFH-Q2VDH-KYG2C-4RD4F"
echo keys.Add "00c79ff1-6850-443d-bf61-71cde0de305f", "PN2WF-29XG2-T9HJ7-JQPJR-FCXK4"
echo keys.Add "d9f5b1c6-5386-495a-88f9-9ad6b41ac9b3", "6Q7VD-NX8JD-WJ2VH-88V73-4GBJ7"
echo keys.Add "a98bcd6d-5343-4603-8afe-5908e4611112", "NG4HW-VH26C-733KW-K6F98-J8CK4"
echo keys.Add "ebf245c1-29a8-4daf-9cb1-38dfc608a8c8", "XCVCF-2NXM9-723PB-MHCB7-2RYQQ"
echo keys.Add "a00018a3-f20f-4632-bf7c-8daa5351c914", "GNBB8-YVD74-QJHX6-27H4K-8QHDG"
echo keys.Add "458e1bec-837a-45f6-b9d5-925ed5d299de", "32JNW-9KQ84-P47T8-D8GGY-CWCK7"
echo keys.Add "e14997e7-800a-4cf7-ad10-de4b45b578db", "JMNMF-RHW7P-DMY6X-RF3DR-X2BQT"
echo keys.Add "c04ed6bf-55c8-4b47-9f8e-5a1f31ceee60", "BN3D2-R7TKB-3YPBD-8DRP2-27GG4"
echo keys.Add "197390a0-65f6-4a95-bdc4-55d58a3b0253", "8N2M2-HWPGY-7PGT9-HGDD8-GVGGY"
echo keys.Add "8860fcd4-a77b-4a20-9045-a150ff11d609", "2WN2H-YGCQR-KFX6K-CD6TF-84YXQ"
echo keys.Add "9d5584a2-2d85-419a-982c-a00888bb9ddf", "4K36P-JN4VD-GDC6V-KDT89-DYFKP"
echo keys.Add "f0f5ec41-0d55-4732-af02-440a44a3cf0f", "XC9B7-NBPP2-83J2H-RHMBY-92BT4"
echo keys.Add "7d5486c7-e120-4771-b7f1-7b56c6d3170c", "HM7DN-YVMH3-46JC3-XYTG7-CYQJJ"
echo keys.Add "95fd1c83-7df5-494a-be8b-1300e1c9d1cd", "XNH6W-2V9GX-RGJ4K-Y8X6F-QGJ2G"
echo keys.Add "d3643d60-0c42-412d-a7d6-52e6635327f6", "48HP8-DN98B-MYWDG-T2DCC-8W83P"
echo if keys.Exists^(edition^) then
echo WScript.Echo keys.Item^(edition^)
echo End If)>"%temp%\key.vbs"
set key=Unknown
for /f %%A in ('cscript /nologo "%temp%\key.vbs"') do set key=%%A
del /f /q "%temp%\key.vbs" >nul 2>&1
if %key%==Unknown (echo.&echo Could not find matching KMS Client key&exit /b)
wmic path %sps% where version='%ver%' call InstallProductKey ProductKey="%key%" >nul 2>&1
wmic path %spp% where ID='%1' call ClearKeyManagementServiceMachine >nul 2>&1
wmic path %spp% where ID='%1' call ClearKeyManagementServicePort >nul 2>&1
for /f "tokens=2 delims==" %%x in ('"wmic path %spp% where ID='%1' get Name /format:list"') do echo Attempting to activate: %%x
wmic path %spp% where ID='%1' call Activate >nul 2>&1
for /f "tokens=2 delims==" %%x in ('"wmic path %spp% where ID='%1' get GracePeriodRemaining /format:list"') do set gpr=%%x
if %gpr% equ 43200 (echo Windows Core/ProfessionalWMC Activation Successful&echo Remaining Period: 30 days ^(%gpr% minutes^)&exit /b)
if %gpr% equ 64800 (echo Windows Core/ProfessionalWMC Activation Successful&echo Remaining Period: 45 days ^(%gpr% minutes^)&exit /b)
if %gpr% equ 259200 (echo Product Activation Successful) else (echo Product Activation Failed)
set /a gpr2=%gpr%/60/24
echo Remaining Period: %gpr2% days ^(%gpr% minutes^)
exit /b