@echo off
set _Debug=0

set Online=0
set KMS_IP=172.16.0.2
set KMS_Port=1688
set KMS_ActivationInterval=120
set KMS_RenewalInterval=10080
set KMS_HWID=0x3A1C049600B60076

set KMS38=1

set "SysPath=%Windir%\System32"
if exist "%Windir%\Sysnative\reg.exe" (set "SysPath=%Windir%\Sysnative")
set "Path=%SysPath%;%Windir%;%SysPath%\Wbem;%SysPath%\WindowsPowerShell\v1.0\"

fsutil dirty query %systemdrive% >nul 2>&1 || goto :E_Admin

if %Online%==0 (
if not exist "%SystemRoot%\system32\SppExtComObj*.dll" goto :E_Patcher
if exist "%SystemRoot%\system32\SppExtComObj*.dll" dir /b /al "%SystemRoot%\system32\SppExtComObjHook.dll" >nul 2>&1 && goto :E_Patcher
set KMS_IP=172.16.0.2
)

set "_tempdir=%SystemRoot%\Temp"
set "_logpath=%~dpn0"
set "_workdir=%~dp0"
if "%_workdir:~-1%"=="\" set "_workdir=%_workdir:~0,-1%"
setlocal EnableExtensions EnableDelayedExpansion
set "IFEO=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"

if %_Debug% EQU 0 (
  set "_Nul_1=1>nul"
  set "_Nul_2=2>nul"
  set "_Nul_2e=2^>nul"
  set "_Nul_1_2=1>nul 2>nul"
  set "_Pause=pause >nul"
  call :Begin
) else (
  set "_Nul_1="
  set "_Nul_2="
  set "_Nul_2e="
  set "_Nul_1_2="
  set "_Pause="
  echo.
  echo Running in Debug Mode...
  echo The window will be closed when finished
  copy /y nul "!_workdir!\#.rw" 1>nul 2>nul && (if exist "!_workdir!\#.rw" del /f /q "!_workdir!\#.rw") || (set "_logpath=!_tempdir!\%~n0")
  @echo on
  @prompt $G
  @call :Begin >"!_logpath!.tmp" 2>&1 &cmd /u /c type "!_logpath!.tmp">"!_logpath!_Debug.log"&del "!_logpath!.tmp"
)
exit /b

:Begin
color 1F
title KMS_VL_ALL Auto Renewal
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G
if %winbuild% GEQ 9600 (
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /f /v NoGenTicket /t REG_DWORD /d 1 %_Nul_1_2%
)
SET Win10Gov=0
if %winbuild% LSS 14393 goto :Main

SET "RegKey=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages"
SET "Pattern=Microsoft-Windows-*Edition~31bf3856ad364e35"
SET "EditionPKG=NUL"
FOR /F "TOKENS=8 DELIMS=\" %%A IN ('REG QUERY "%RegKey%" /f "%Pattern%" /k %_Nul_2e% ^| FIND /I "CurrentVersion"') DO (
  REG QUERY "%RegKey%\%%A" /v "CurrentState" %_Nul_2% | FIND /I "0x70" %_Nul_1% && (
    FOR /F "TOKENS=3 DELIMS=-~" %%B IN ('ECHO %%A') DO SET "EditionPKG=%%B"
  )
)
IF /I "%EditionPKG:~-7%"=="Edition" (
SET "EditionID=%EditionPKG:~0,-7%"
) ELSE (
FOR /F "TOKENS=3 DELIMS=: " %%A IN ('DISM /English /Online /Get-CurrentEdition %_Nul_2e% ^| FIND /I "Current Edition :"') DO SET "EditionID=%%A"
)
FOR /F "TOKENS=2 DELIMS==" %%A IN ('"WMIC PATH SoftwareLicensingProduct WHERE (Name LIKE 'Windows%%' AND PartialProductKey is not NULL) GET LicenseFamily /VALUE" %_Nul_2e%') DO IF NOT ERRORLEVEL 1 SET "EditionWMI=%%A"
IF NOT DEFINED EditionWMI (
IF %winbuild% GEQ 17063 FOR /F "SKIP=2 TOKENS=3 DELIMS= " %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionId') DO SET "EditionID=%%A"
GOTO :Main
)
FOR %%A IN (Cloud,CloudN,IoTEnterprise,IoTEnterpriseS) DO (IF /I "%EditionWMI%"=="%%A" GOTO :Main)
SET EditionID=%EditionWMI%
FOR %%A IN (EnterpriseG,EnterpriseGN) DO (IF /I "%EditionID%"=="%%A" SET Win10Gov=1)

:Main
reg query HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration /v ProductReleaseIds %_Nul_1_2% && set "_C2R=HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
if not defined _C2R reg query HKLM\SOFTWARE\WOW6432Node\Microsoft\Office\ClickToRun\Configuration /v ProductReleaseIds %_Nul_1_2% && set "_C2R=HKLM\SOFTWARE\WOW6432Node\Microsoft\Office\ClickToRun\Configuration"
for %%A in (14,15,16,19) do call :officeLoc %%A
if %Online%==0 (
if %winbuild% GEQ 9200 call :UpdateIFEOEntry SppExtComObj.exe
if %winbuild% LSS 9200 call :UpdateIFEOEntry sppsvc.exe
call :UpdateIFEOEntry osppsvc.exe
)
call :SPP
call :OSPP
if exist "!_tempdir!\*chk.txt" del /f /q "!_tempdir!\*chk.txt"
if exist "!_tempdir!\slmgr.vbs" del /f /q "!_tempdir!\slmgr.vbs"
net stop sppsvc /y %_Nul_1_2% || sc stop sppsvc %_Nul_1_2%
sc start sppsvc trigger=timer;sessionid=0 %_Nul_1_2%
echo.
echo.
echo Press any key to exit...
%_Pause%
exit /b

:SPP
set spp=SoftwareLicensingProduct
set sps=SoftwareLicensingService
set W1nd0ws=1
wmic path %spp% where (Description like '%%KMSCLIENT%%') get Name %_Nul_2% | findstr /i Office %_Nul_1% && (set 0ff1ce15=1)
set "aword=No Supported KMS Client"
if %loc_off15% equ 0 if %loc_off16% equ 0 if %loc_off19% equ 0 (set "0ff1ce15="&set "aword=No Installed")
if not defined 0ff1ce15 if %winbuild% GEQ 9200 (echo.&echo %aword% Office 2013/2016/2019 Product Detected...)
wmic path %spp% where (Description like '%%KMSCLIENT%%') get Name %_Nul_2% | findstr /i Windows %_Nul_1% && (set WinVL=1) || (echo.&echo No Supported KMS Client Windows Detected...)
if not defined 0ff1ce15 if not defined WinVL exit /b
wmic path %spp% where (Description like '%%KMSCLIENT%%' and PartialProductKey is not NULL) get Name %_Nul_2% | findstr /i Windows %_Nul_1% && (set gvlk=1) || (set gvlk=0)
set gpr=0
if %winbuild% geq 10240 if %KMS38% equ 1 if %gvlk% equ 1 for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Description like '%%KMSCLIENT%%' and Name like 'Windows%%' and PartialProductKey is not NULL) get GracePeriodRemaining /VALUE" %_Nul_2e%') do set "gpr=%%A"
if %gpr% neq 0 if %gpr% gtr 259200 (
set W1nd0ws=0
wmic path %spp% where "Description like '%%KMSCLIENT%%' and Name like 'Windows%%' and PartialProductKey is not NULL" get LicenseFamily %_Nul_2% | findstr /i EnterpriseG %_Nul_1% && (set W1nd0ws=1)
)
for /f "tokens=2 delims==" %%A in ('"wmic path %sps% get Version /VALUE"') do set ver=%%A
wmic path %sps% where version='%ver%' call SetKeyManagementServiceMachine MachineName="%KMS_IP%" %_Nul_1_2%
wmic path %sps% where version='%ver%' call SetKeyManagementServicePort %KMS_Port% %_Nul_1_2%
for /f "tokens=2 delims==" %%G in ('"wmic path %spp% where (Description like '%%KMSCLIENT%%' and Name like 'Windows%%') get ID /VALUE"') do (set app=%%G&call :sppchkwin)
if defined 0ff1ce15 for /f "tokens=2 delims==" %%G in ('"wmic path %spp% where (Description like '%%KMSCLIENT%%' and Name like 'Office%%') get ID /VALUE"') do (set app=%%G&call :sppchkoff)
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceDnsPublishing 0 %_Nul_1_2%
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceHostCaching 0 %_Nul_1_2%
exit /b

:sppchkoff
wmic path %spp% where ID='%app%' get Name > "!_tempdir!\sppchk.txt"
find /i "Office 15" "!_tempdir!\sppchk.txt" %_Nul_1% && (if %loc_off15% equ 0 exit /b)
find /i "Office 16" "!_tempdir!\sppchk.txt" %_Nul_1% && (if %loc_off16% equ 0 exit /b)
find /i "Office 19" "!_tempdir!\sppchk.txt" %_Nul_1% && (if %loc_off19% equ 0 exit /b)
set office=1
wmic path %spp% where (PartialProductKey is not NULL) get ID %_Nul_2% | findstr /i "%app%" %_Nul_1% && (echo.&call :activate %app%&exit /b)
for /f "tokens=3 delims==, " %%G in ('"wmic path %spp% where ID='%app%' get Name /value"') do set OffVer=%%G
call :offchk%OffVer%
exit /b

:sppchkwin
set office=0
if %winbuild% GEQ 14393 if %gvlk% equ 0 wmic path %spp% where (Description like '%%KMSCLIENT%%' and PartialProductKey is not NULL) get Name %_Nul_2% | findstr /i Windows %_Nul_1% && (set gvlk=1)
wmic path %spp% where ID='%app%' get LicenseStatus %_Nul_2% | findstr "1" %_Nul_1% && (echo.&call :activate %app%&exit /b)
wmic path %spp% where (PartialProductKey is not NULL) get ID %_Nul_2% | findstr /i "%app%" %_Nul_1% && (echo.&call :activate %app%&exit /b)
if %gvlk% equ 1 exit /b
if defined WinPerm exit /b
if %winbuild% LSS 10240 (call :winchk&exit /b)
for %%A in (
b71515d9-89a2-4c60-88c8-656fbcca7f3a,af43f7f0-3b1e-4266-a123-1fdb53f4323b,075aca1f-05d7-42e5-a3ce-e349e7be7078
11a37f09-fb7f-4002-bd84-f3ae71d11e90,43f2ab05-7c87-4d56-b27c-44d0f9a3dabd,2cf5af84-abab-4ff0-83f8-f040fb2576eb
6ae51eeb-c268-4a21-9aae-df74c38b586d,ff808201-fec6-4fd4-ae16-abbddade5706,34260150-69ac-49a3-8a0d-4a403ab55763
4dfd543d-caa6-4f69-a95f-5ddfe2b89567,5fe40dd6-cf1f-4cf2-8729-92121ac2e997,903663f7-d2ab-49c9-8942-14aa9e0a9c72
2cc171ef-db48-4adc-af09-7c574b37f139,5b2add49-b8f4-42e0-a77c-adad4efeeeb1
) do (
if /i '%app%' equ '%%A' exit /b
)
if not defined EditionID (call :winchk&exit /b)
if /i '%app%' equ '0df4f814-3f57-4b8b-9a9d-fddadcd69fac' if /i %EditionID% neq CloudE exit /b
if /i '%app%' equ 'e0c42288-980c-4788-a014-c080d2e1926e' if /i %EditionID% neq Education exit /b
if /i '%app%' equ '73111121-5638-40f6-bc11-f1d7b0d64300' if /i %EditionID% neq Enterprise exit /b
if /i '%app%' equ '2de67392-b7a7-462a-b1ca-108dd189f588' if /i %EditionID% neq Professional exit /b
if /i '%app%' equ '3f1afc82-f8ac-4f6c-8005-1d233e606eee' if /i %EditionID% neq ProfessionalEducation exit /b
if /i '%app%' equ '82bbc092-bc50-4e16-8e18-b74fc486aec3' if /i %EditionID% neq ProfessionalWorkstation exit /b
if /i '%app%' equ '3c102355-d027-42c6-ad23-2e7ef8a02585' if /i %EditionID% neq EducationN exit /b
if /i '%app%' equ 'e272e3e2-732f-4c65-a8f0-484747d0d947' if /i %EditionID% neq EnterpriseN exit /b
if /i '%app%' equ 'a80b5abf-76ad-428b-b05d-a47d2dffeebf' if /i %EditionID% neq ProfessionalN exit /b
if /i '%app%' equ '5300b18c-2e33-4dc2-8291-47ffcec746dd' if /i %EditionID% neq ProfessionalEducationN exit /b
if /i '%app%' equ '4b1571d3-bafb-4b40-8087-a961be2caf65' if /i %EditionID% neq ProfessionalWorkstationN exit /b
if /i '%app%' equ '58e97c99-f377-4ef1-81d5-4ad5522b5fd8' if /i %EditionID% neq Core exit /b
if /i '%app%' equ 'cd918a57-a41b-4c82-8dce-1a538e221a83' if /i %EditionID% neq CoreSingleLanguage exit /b
if /i '%app%' equ 'ec868e65-fadf-4759-b23e-93fe37f2cc29' if /i %EditionID% neq ServerRdsh exit /b
if /i '%app%' equ 'e4db50ea-bda1-4566-b047-0ca50abc6f07' if /i %EditionID% neq ServerRdsh exit /b
if /i '%app%' equ 'e4db50ea-bda1-4566-b047-0ca50abc6f07' (
wmic path %spp% where 'Description like "%%KMSCLIENT%%"' get ID | findstr /i "ec868e65-fadf-4759-b23e-93fe37f2cc29" %_Nul_1_2% && (exit /b)
)
call :winchk
exit /b

:winchk
if not defined tok (if %winbuild% GEQ 9200 (set "tok=4") else (set "tok=7"))
if not defined wApp set wApp=55c92734-d682-4d71-983e-d6ec3f16059f
wmic path %spp% where (LicenseStatus='1' and Description like '%%KMSCLIENT%%') get Name %_Nul_2% | findstr /i "Windows" %_Nul_1_2% && (exit /b)
echo.
wmic path %spp% where (LicenseStatus='1' and GracePeriodRemaining='0' and PartialProductKey is not NULL) get Name %_Nul_2% | findstr /i "Windows" %_Nul_1_2% && (
set WinPerm=1
)
if not defined WinPerm (
wmic path %spp% where "ApplicationID='%wApp%' and LicenseStatus='1'" get Name %_Nul_2% | findstr /i "Windows" %_Nul_1_2% && (
for /f "tokens=%tok% delims=, " %%G in ('"wmic path %spp% where (ApplicationID='%wApp%' and LicenseStatus='1') get Description /VALUE"') do set "channel=%%G"
  for %%A in (VOLUME_MAK, RETAIL, OEM_DM, OEM_SLP, OEM_COA, OEM_COA_SLP, OEM_COA_NSLP, OEM_NONSLP, OEM) do if /i "%%A"=="!channel!" set WinPerm=1
  )
)
if not defined WinPerm (
copy /y %Windir%\System32\slmgr.vbs "!_tempdir!\slmgr.vbs" %_Nul_1_2%
cscript //nologo "!_tempdir!\slmgr.vbs" /xpr %_Nul_2% | findstr /i "permanently" %_Nul_1_2% && set WinPerm=1
)
if defined WinPerm (
for /f "tokens=2 delims==" %%x in ('"wmic path %spp% where (ApplicationID='%wApp%' and LicenseStatus='1') get Name /VALUE"') do echo Checking: %%x
echo Product is Permanently Activated.
exit /b
)
call :insKey %app%
exit /b

:OSPP
set spp=OfficeSoftwareProtectionProduct
set sps=OfficeSoftwareProtectionService
if %winbuild% LSS 9200 (set "aword=2010/2013/2016/2019") else (set "aword=2010")
wmic path %sps% get Version /VALUE %_Nul_1_2% || (echo.&echo No Installed Office %aword% Product Detected...&exit /b)
wmic path %spp% where (Description like '%%KMSCLIENT%%') get Name /VALUE %_Nul_1_2% || (echo.&echo No Supported KMS Client Office %aword% Product Detected...&exit /b)
for /f "tokens=2 delims==" %%A in ('"wmic path %sps% get Version /VALUE" %_Nul_2e%') do set ver=%%A
wmic path %sps% where version='%ver%' call SetKeyManagementServiceMachine MachineName="%KMS_IP%" %_Nul_1_2%
wmic path %sps% where version='%ver%' call SetKeyManagementServicePort %KMS_Port% %_Nul_1_2%
for /f "tokens=2 delims==" %%G in ('"wmic path %spp% where (Description like '%%KMSCLIENT%%') get ID /VALUE"') do (set app=%%G&call :osppchk)
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceDnsPublishing 0 %_Nul_1_2%
wmic path %sps% where version='%ver%' call DisableKeyManagementServiceHostCaching 0 %_Nul_1_2%
exit /b

:osppchk
wmic path %spp% where ID='%app%' get Name > "!_tempdir!\osppchk.txt"
find /i "Office 14" "!_tempdir!\osppchk.txt" %_Nul_1% && (if %loc_off14% equ 0 exit /b)
find /i "Office 15" "!_tempdir!\osppchk.txt" %_Nul_1% && (if %loc_off15% equ 0 exit /b)
find /i "Office 16" "!_tempdir!\osppchk.txt" %_Nul_1% && (if %loc_off16% equ 0 exit /b)
find /i "Office 19" "!_tempdir!\osppchk.txt" %_Nul_1% && (if %loc_off19% equ 0 exit /b)
set office=0
wmic path %spp% where (PartialProductKey is not NULL) get ID | findstr /i "%app%" %_Nul_1_2% && (echo.&call :activate %app%&exit /b)
for /f "tokens=3 delims==, " %%G in ('"wmic path %spp% where ID='%app%' get Name /value"') do set OffVer=%%G
call :offchk%OffVer%
exit /b

:offchk
set ls=0
set ls2=0
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%Office%~2%%') get LicenseStatus /VALUE" %_Nul_2e%') do set /a ls=%%A
if "%~4" neq "" (
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%Office%~4%%') get LicenseStatus /VALUE" %_Nul_2e%') do set /a ls2=%%A
)
if "%ls2%" equ "1" (
echo Checking: %~5
echo Product is Permanently Activated.
exit /b
)
if "%ls%" equ "1" (
echo Checking: %~3
echo Product is Permanently Activated.
exit /b
)
call :insKey %app%
exit /b

:offchk19
if /i '%app%' equ '0bc88885-718c-491d-921f-6f214349e79c' exit /b
if /i '%app%' equ 'fc7c4d0c-2e85-4bb9-afd4-01ed1476b5e9' exit /b
if /i '%app%' equ '500f6619-ef93-4b75-bcb4-82819998a3ca' exit /b
if /i '%app%' equ '85dd8b5f-eaa4-4af3-a628-cce9e77c9a03' (
wmic path %spp% where 'PartialProductKey is not NULL' get ID | findstr /i "0bc88885-718c-491d-921f-6f214349e79c" %_Nul_1_2% && (exit /b)
)
if /i '%app%' equ '2ca2bf3f-949e-446a-82c7-e25a15ec78c4' (
wmic path %spp% where 'PartialProductKey is not NULL' get ID | findstr /i "fc7c4d0c-2e85-4bb9-afd4-01ed1476b5e9" %_Nul_1_2% && (exit /b)
)
if /i '%app%' equ '5b5cf08f-b81a-431d-b080-3450d8620565' (
wmic path %spp% where 'PartialProductKey is not NULL' get ID | findstr /i "500f6619-ef93-4b75-bcb4-82819998a3ca" %_Nul_1_2% && (exit /b)
)
if /i '%app%' equ '85dd8b5f-eaa4-4af3-a628-cce9e77c9a03' (
call :offchk "%app%" "19ProPlus2019VL_MAK_AE" "Office ProPlus 2019" "19ProPlus2019XC2RVL_MAKC2R" "Office ProPlus 2019 C2R"
exit /b
)
if /i '%app%' equ '6912a74b-a5fb-401a-bfdb-2e3ab46f4b02' (
call :offchk "%app%" "19Standard2019VL_MAK_AE" "Office Standard 2019"
exit /b
)
if /i '%app%' equ '2ca2bf3f-949e-446a-82c7-e25a15ec78c4' (
call :offchk "%app%" "19ProjectPro2019VL_MAK_AE" "Project Pro 2019" "19ProjectPro2019XC2RVL_MAKC2R" "Project Pro 2019 C2R"
exit /b
)
if /i '%app%' equ '1777f0e3-7392-4198-97ea-8ae4de6f6381' (
call :offchk "%app%" "19ProjectStd2019VL_MAK_AE" "Project Standard 2019"
exit /b
)
if /i '%app%' equ '5b5cf08f-b81a-431d-b080-3450d8620565' (
call :offchk "%app%" "19VisioPro2019VL_MAK_AE" "Visio Pro 2019" "19VisioPro2019XC2RVL_MAKC2R" "Visio Pro 2019 C2R"
exit /b
)
if /i '%app%' equ 'e06d7df3-aad0-419d-8dfb-0ac37e2bdf39' (
call :offchk "%app%" "19VisioStd2019VL_MAK_AE" "Visio Standard 2019"
exit /b
)
call :insKey %app%
exit /b

:offchk16
if /i '%app%' equ 'd450596f-894d-49e0-966a-fd39ed4c4c64' (
call :offchk "%app%" "16ProPlusVL_MAK" "Office ProPlus 2016"
exit /b
)
if /i '%app%' equ 'dedfa23d-6ed1-45a6-85dc-63cae0546de6' (
call :offchk "%app%" "16StandardVL_MAK" "Office Standard 2016"
exit /b
)
if /i '%app%' equ '4f414197-0fc2-4c01-b68a-86cbb9ac254c' (
call :offchk "%app%" "16ProjectProVL_MAK" "Project Pro 2016"
exit /b
)
if /i '%app%' equ 'da7ddabc-3fbe-4447-9e01-6ab7440b4cd4' (
call :offchk "%app%" "16ProjectStdVL_MAK" "Project Standard 2016"
exit /b
)
if /i '%app%' equ '6bf301c1-b94a-43e9-ba31-d494598c47fb' (
call :offchk "%app%" "16VisioProVL_MAK" "Visio Pro 2016"
exit /b
)
if /i '%app%' equ 'aa2a7821-1827-4c2c-8f1d-4513a34dda97' (
call :offchk "%app%" "16VisioStdVL_MAK" "Visio Standard 2016"
exit /b
)
if /i '%app%' equ '829b8110-0e6f-4349-bca4-42803577788d' (
call :offchk "%app%" "16ProjectProXC2RVL_MAKC2R" "Project Pro 2016 C2R"
exit /b
)
if /i '%app%' equ 'cbbaca45-556a-4416-ad03-bda598eaa7c8' (
call :offchk "%app%" "16ProjectStdXC2RVL_MAKC2R" "Project Standard 2016 C2R"
exit /b
)
if /i '%app%' equ 'b234abe3-0857-4f9c-b05a-4dc314f85557' (
call :offchk "%app%" "16VisioProXC2RVL_MAKC2R" "Visio Pro 2016 C2R"
exit /b
)
if /i '%app%' equ '361fe620-64f4-41b5-ba77-84f8e079b1f7' (
call :offchk "%app%" "16VisioStdXC2RVL_MAKC2R" "Visio Standard 2016 C2R"
exit /b
)
call :insKey %app%
exit /b

:offchk15
if /i '%app%' equ 'b322da9c-a2e2-4058-9e4e-f59a6970bd69' (
call :offchk "%app%" "ProPlusVL_MAK" "Office ProPlus 2013"
exit /b
)
if /i '%app%' equ 'b13afb38-cd79-4ae5-9f7f-eed058d750ca' (
call :offchk "%app%" "StandardVL_MAK" "Office Standard 2013"
exit /b
)
if /i '%app%' equ '4a5d124a-e620-44ba-b6ff-658961b33b9a' (
call :offchk "%app%" "ProjectProVL_MAK" "Project Pro 2013"
exit /b
)
if /i '%app%' equ '427a28d1-d17c-4abf-b717-32c780ba6f07' (
call :offchk "%app%" "ProjectStdVL_MAK" "Project Standard 2013"
exit /b
)
if /i '%app%' equ 'e13ac10e-75d0-4aff-a0cd-764982cf541c' (
call :offchk "%app%" "VisioProVL_MAK" "Visio Pro 2013"
exit /b
)
if /i '%app%' equ 'ac4efaf0-f81f-4f61-bdf7-ea32b02ab117' (
call :offchk "%app%" "VisioStdVL_MAK" "Visio Standard 2013"
exit /b
)
call :insKey %app%
exit /b

:offchk14
set "vPrem="&set "vPro="
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeVisioPrem-MAK%%') get LicenseStatus /VALUE" %_Nul_2e%') do set vPrem=%%A
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where (Name like '%%OfficeVisioPro-MAK%%') get LicenseStatus /VALUE" %_Nul_2e%') do set vPro=%%A
if /i '%app%' equ '6f327760-8c5c-417c-9b61-836a98287e0c' (
call :offchk "%app%" "ProPlus-MAK" "Office ProPlus 2010" "ProPlusAcad-MAK" "Office Professional Academic 2010"
exit /b
)
if /i '%app%' equ '9da2a678-fb6b-4e67-ab84-60dd6a9c819a' (
call :offchk "%app%" "Standard-MAK" "Office Standard 2010"
exit /b
)
if /i '%app%' equ 'ea509e87-07a1-4a45-9edc-eba5a39f36af' (
call :offchk "%app%" "SmallBusBasics-MAK" "Office Home and Business 2010"
exit /b
)
if /i '%app%' equ 'df133ff7-bf14-4f95-afe3-7b48e7e331ef' (
call :offchk "%app%" "ProjectPro-MAK" "Project Pro 2010"
exit /b
)
if /i '%app%' equ '5dc7bf61-5ec9-4996-9ccb-df806a2d0efe' (
call :offchk "%app%" "ProjectStd-MAK" "Project Standard 2010"
exit /b
)
if /i '%app%' equ '92236105-bb67-494f-94c7-7f7a607929bd' (
call :offchk "%app%" "VisioPrem-MAK" "Visio Premium 2010" "VisioPro-MAK" "Visio Pro 2010"
exit /b
)
if defined vPrem exit /b
if /i '%app%' equ 'e558389c-83c3-4b29-adfe-5e4d7f46c358' (
call :offchk "%app%" "VisioPro-MAK" "Visio Pro 2010" "VisioStd-MAK" "Visio Standard 2010"
exit /b
)
if defined vPro exit /b
if /i '%app%' equ '9ed833ff-4f92-4f36-b370-8683a4f13275' (
call :offchk "%app%" "VisioStd-MAK" "Visio Standard 2010"
exit /b
)
call :insKey %app%
exit /b

:officeLoc
set loc_off%1=0
if %1 equ 19 (
if defined _C2R reg query %_C2R% /v ProductReleaseIds %_Nul_2% | findstr 2019 %_Nul_1% && set loc_off%1=1
exit /b
)

for /f "tokens=2*" %%a in ('"reg query HKLM\SOFTWARE\Microsoft\Office\%1.0\Common\InstallRoot /v Path" %_Nul_2e%') do if exist "%%b\OSPP.VBS" set loc_off%1=1
for /f "tokens=2*" %%a in ('"reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Office\%1.0\Common\InstallRoot /v Path" %_Nul_2e%') do if exist "%%b\OSPP.VBS" set loc_off%1=1

if %1 equ 16 if defined _C2R (
for /f "skip=2 tokens=2*" %%a in ('reg query %_C2R% /v ProductReleaseIds') do echo %%b> "!_tempdir!\c2rchk.txt"
for %%a in (Mondo,ProPlus,Standard,ProjectProX,ProjectStdX,ProjectPro,ProjectStd,VisioProX,VisioStdX,VisioPro,VisioStd,Access,Excel,OneNote,Outlook,PowerPoint,Publisher,SkypeforBusiness,Word) do (
  findstr /I /C:"%%aVolume" "!_tempdir!\c2rchk.txt" %_Nul_1% && set loc_off%1=1
  findstr /I /C:"%%aRetail" "!_tempdir!\c2rchk.txt" %_Nul_1% && set loc_off%1=1
  )
exit /b
)

if exist "%ProgramFiles%\Microsoft Office\Office%1\OSPP.VBS" set loc_off%1=1
if exist "%ProgramFiles(x86)%\Microsoft Office\Office%1\OSPP.VBS" set loc_off%1=1
exit /b

:insKey
echo.
set "key="
for /f "tokens=2 delims==" %%A in ('"wmic path %spp% where ID='%1' get Name /VALUE"') do echo Installing Key for: %%A
call "!_workdir!\Win32\key.cmd" %1
if "%key%" EQU "" (echo Could not find matching KMS Client key&exit /b)
wmic path %sps% where version='%ver%' call InstallProductKey ProductKey="%key%" %_Nul_1_2%
set ERRORCODE=%ERRORLEVEL%
if %ERRORCODE% neq 0 (
cmd /c exit /b %ERRORCODE%
echo Failed: 0x!=ExitCode!
exit /b
)

:activate
wmic path %spp% where ID='%1' call ClearKeyManagementServiceMachine %_Nul_1_2%
wmic path %spp% where ID='%1' call ClearKeyManagementServicePort %_Nul_1_2%
if %W1nd0ws% equ 0 if %office% equ 0 if %sps% equ SoftwareLicensingService (
wmic path %spp% where ID='%1' call SetKeyManagementServiceMachine MachineName="127.0.0.2" %_Nul_1_2%
wmic path %spp% where ID='%1' call SetKeyManagementServicePort %KMS_Port% %_Nul_1_2%
for /f "tokens=2 delims==" %%x in ('"wmic path %spp% where ID='%1' get Name /VALUE"') do echo Checking: %%x
echo Product is KMS 2038 Activated.
exit /b
)
for /f "tokens=2 delims==" %%x in ('"wmic path %spp% where ID='%1' get Name /VALUE"') do echo Activating: %%x
wmic path %spp% where ID='%1' call Activate %_Nul_1_2%
set ERRORCODE=%ERRORLEVEL%
if /i %sps% equ SoftwareLicensingService wmic path %sps% where version='%ver%' call RefreshLicenseStatus %_Nul_1_2%
for /f "tokens=2 delims==" %%x in ('"wmic path %spp% where ID='%1' get GracePeriodRemaining /VALUE"') do (set gpr=%%x&set /a gpr2=%%x/1440)
if %gpr% equ 43200 if %office% equ 0 if %winbuild% geq 9200 (echo Windows Core/ProfessionalWMC Activation Successful&echo Remaining Period: 30 days ^(%gpr% minutes^)&exit /b)
if %gpr% equ 64800 (echo Windows Core/ProfessionalWMC Activation Successful&echo Remaining Period: 45 days ^(%gpr% minutes^)&exit /b)
if %gpr% gtr 259200 if %Win10Gov% equ 1 (echo Windows 10 %EditionID% Activation Successful&echo Remaining Period: %gpr2% days ^(%gpr% minutes^)&exit /b)
if %gpr% equ 259200 (
echo Product Activation Successful
) else (
cmd /c exit /b %ERRORCODE%
echo Product Activation Failed: 0x!=ExitCode!
)
echo Remaining Period: %gpr2% days ^(%gpr% minutes^)
exit /b

:UpdateIFEOEntry
reg query "%IFEO%\%1" /v KMS_Emulation %_Nul_1_2% || exit /b
reg add "%IFEO%\%1" /f /v KMS_ActivationInterval /t REG_DWORD /d %KMS_ActivationInterval% %_Nul_1_2%
reg add "%IFEO%\%1" /f /v KMS_RenewalInterval /t REG_DWORD /d %KMS_RenewalInterval% %_Nul_1_2%
if /i %1 EQU SppExtComObj.exe if %winbuild% GEQ 9600 reg add "%IFEO%\%1" /f /v KMS_HWID /t REG_QWORD /d "%KMS_HWID%" %_Nul_1_2%
exit /b

:E_Admin
echo ==== ERROR ====
echo This script require administrator privileges.
echo To do so, right click on this script and select 'Run as administrator'
echo.
echo Press any key to exit...
pause >nul
goto :eof

:E_Patcher
echo ==== ERROR ====
echo SppExtComObjPatcher is not installed on the system.
echo use SppExtComObjPatcher.cmd to install it first
echo before you can use this script for auto renewal offline activation.
echo.
echo Press any key to exit...
pause >nul
goto :eof

:UnsupportedVersion
echo ==== ERROR ====
echo Unsupported OS version Detected.
echo Project is supported only for Windows 7/8/8.1/10 and their Server equivalent.
echo.
echo Press any key to exit...
%_Pause%
goto :eof