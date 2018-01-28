@echo off
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
setlocal EnableExtensions
setlocal EnableDelayedExpansion
call :SPP
call :OSPP
exit

:SPP
set spp=SoftwareLicensingProduct
set sps=SoftwareLicensingService
for /f "tokens=2 delims==" %%A in ('"wmic path %sps% get version /format:list"') do set ver=%%A
for /f "tokens=2 delims==" %%G in ('"wmic path %spp% where (Description like '%%KMSCLIENT%%') get ID /format:list"') do (set app=%%G&call :clear)
wmic path %sps% where version='%ver%' call ClearKeyManagementServiceMachine >nul 2>&1
wmic path %sps% where version='%ver%' call ClearKeyManagementServicePort >nul 2>&1
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceDnsPublishing 1 >nul 2>&1
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceHostCaching 1 >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\55c92734-d682-4d71-983e-d6ec3f16059f" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\0ff1ce15-a989-479d-af46-f275c6370663" /f >nul 2>&1
reg delete "HKEY_USERS\S-1-5-20\Software\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\55c92734-d682-4d71-983e-d6ec3f16059f" /f >nul 2>&1
reg delete "HKEY_USERS\S-1-5-20\Software\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\0ff1ce15-a989-479d-af46-f275c6370663" /f >nul 2>&1
exit /b

:OSPP
set spp=OfficeSoftwareProtectionProduct
set sps=OfficeSoftwareProtectionService
wmic path %sps% get version >nul 2>&1 || exit /b
for /f "tokens=2 delims==" %%A in ('"wmic path %sps% get version /format:list" 2^>nul') do set ver=%%A
for /f "tokens=2 delims==" %%G in ('"wmic path %spp% where (Description like '%%KMSCLIENT%%') get ID /format:list"') do (set app=%%G&call :clear)
wmic path %sps% where version='%ver%' call ClearKeyManagementServiceMachine >nul 2>&1
wmic path %sps% where version='%ver%' call ClearKeyManagementServicePort >nul 2>&1
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceDnsPublishing 1 >nul 2>&1
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceHostCaching 1 >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\OfficeSoftwareProtectionPlatform\59a52881-a989-479d-af46-f275c6370663" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\OfficeSoftwareProtectionPlatform\0ff1ce15-a989-479d-af46-f275c6370663" /f >nul 2>&1
exit /b

:clear
wmic path %spp% where ID='%app%' call ClearKeyManagementServiceMachine >nul 2>&1
wmic path %spp% where ID='%app%' call ClearKeyManagementServicePort >nul 2>&1
exit /b