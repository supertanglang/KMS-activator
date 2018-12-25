[![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/fold_left.svg?style=social&label=Follow%20%40CHEF-KOCH)](https://twitter.com/CKsTechNews)
[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/CHEF-KOCH)
[![Discord](https://discordapp.com/api/guilds/418256415874875402/widget.png)](https://discord.me/CHEF-KOCH)

# About KMS-Activator + 20(38)

This is a community based project, which was released on MDL and got several patches from me and other people.<br />
The goal isn't to bypass Windows activation, the project is for research and to (if used) activation KMS with a legit key, it simplify the activation process. 


To use this solution for one-time standalone activation, run this script only:
`KMS_VL_ALL.cmd`


To install this solution for auto renewal activation, run these scripts respectively:<br />
* `SppExtComObjPatcher.cmd`     	   - For install/uninstall the Patcher Hook
* `Activate-Local.cmd`          	   - To activate local machine, you must run it at least once!
* `Check-Activation-Status.cmd` 	   - (Optional)
* `Clear-KMS-Cache.cmd`         	   - (Optional)


OEM installation:<br />
`$oem$` folder for pre-activating the system during install.
Copy $oem$ to "sources" folder in the install media (iso/usb)
use SppExtComObjPatcher.cmd if you want to uninstall the project afterwards.


This project support _activating_ (for tests only!) KMS-Client editions of:<br />
* Windows 7/8/8.1/10
* Windows Server 2008 + R2/2012 + R2 (LTSC)
* Office 2010/2013/2016
* Server Standard/Datacenter 2016/2019

Credits:<br />
* qad            	- SppExtComObjPatcher
* MasterDisaster 	- initial script / WMI methods
* qewpal         	- KMS_VL_ALL (original?) author
* Nucleus        	- MDL (Special assistance)
* abbodi1406     	- MDL
* CHEF-KOCH     	- MDL
* vyvojar			    - MDL
* s1ave77			    - MDL
* WindowsAddict 	- MDL
* AveYo           - MDL


## Difference between HWID and KMS38

KMS38 is only a renamed and modified version of the original KMS solution designed to activate the _problematic_ Windows versions such as [LTSB/LTSC](https://techcommunity.microsoft.com/t5/Windows-IT-Pro-Blog/LTSC-What-is-it-and-when-should-it-be-used/ba-p/293181). It is not a new invented method, the developer just decided it's cool to rename it (_maybe to get more attention_) and add some support for Windows versions which didn't exist back in the "old" KMS days (KMS_VL_ALL is still under development!). 38 itself means 2038 which is the year until LTSB gets supported.

* HWID activation is done only once and windows will be automatically activated after a format/reinstall. Your hardware ID is stored on microsoft servers, which means they can blacklist or close the loophole (if they want). 
* You can't uninstall or remove HWID once you activate it - you can only remove the exectuable but the activation files are still on the partition.
* HWID doesn't work for LTSB/LTSC
* HWID needs an active internet connection (without VPN) which might causes additional security problems (since MS gets your real data such as [IP etc](https://en.wikipedia.org/wiki/Microsoft_Product_Activation)).
* KMS38/KMS19 works for LTSC/LTSB or Server Standard/Datacenter 2016 and 2019 and can also work in an _offline_ mode.
* MSToolkit (the current version doesn't detect KMS38) and only works (or was tested) up to RS 4.
* KMS38/KMS19 works in a VM same like HWID.
* HWID is depending on the current hardware, once you change it you have to re-activate Windows while KMS does it automatically in the background (if you allow it).
* The activation server (fake) is 69.69.69.69 which is only required to make Windows happy. Windows doesn't accept localhost IPs for KMS since Windows 10 anymore.


## Anti-Virus programs

Usually batch and GUI programs are _safe_ (Windows has several internal protection mechanism since PowerShell integration), however most AV's getting triggered by potentially unwanted application ([pua](https://en.wikipedia.org/wiki/Potentially_unwanted_program)) because MS decides that this loophole bypass certain activation mechanism (techniqually it doesn't bypass anything) which is against their ToS. This of course, means that such programs (every of them, KMSPico etc) gets flagged, this is a [false positive](https://en.wikipedia.org/wiki/False_positives_and_false_negatives) however since there are a lot of fake repacks and fake versions avaible ensure you always compare the checksums!



## OEM Integration to automatically activate Windows 

* You need the latest [HWID](https://github.com/CHEF-KOCH/KMS-activator/releases/tag/0.5) version.
* Extract the ISO and put the script(s) + `hwidgen.mk3.exe` + `Setupcomplete.cmd` (you can take it from KMS_VL_All) into `$oem$\$$\Setup\Scripts`.
* You have two files in `Sources\$OEM$\$$\Setup\Scripts`: hwidgen.mk3.exe + Setupcomplete.cmd and _optional_ other scripts (as shown below to automate the activation process in the folder).

```bash
@echo off
%~dp0"hwid.kms38.gen.mk6.exe" kms38
cd %~dp0
attrib -r -a -s -h *.*
rmdir /s /q "%windir%\setup\scripts"
exit
```

You can supress the popups with the silent switches (HWID) `%~dp0"hwidkms38genmk6.exe" hwid` (KMS38) `%~dp0"hwidkms38genmk6.exe" kms38` In the above example it's for KMS38.


## Auto Renewal

To install this solution for auto renewal activation, run these scripts respectively:

1.) SppExtComObjPatcher.cmd
Install/uninstall the Patcher Hook.

2.) Activate-Local.cmd
Activate installed supported products (you must run it at least once).
You may need to run it again if you installed Office product afterwards.


## Online KMS

You may use Activate-Local.cmd for online activation,
if you have valid/trusted external KMS host server.

- Edit Activate-Local.cmd with Notepad
- Change KMS_IP=172.16.0.2 to the IP/address of online KMS server
- Change Online=0 from zero 0 to 1
- Save the script, and run it as administrator

## Setup Preactivate

- To preactivate the system during installation, copy $oem$ to "sources" folder in the installation media (iso/usb)

- If you already use another setupcomplete.cmd, rename this one to KMS_VL_ALL.cmd or similar name
then add a command to run it in your setupcomplete.cmd, example:
call KMS_VL_ALL.cmd

- Use SppExtComObjPatcher.cmd if you want to uninstall the project afterwards.

- Note: setupcomplete.cmd is disabled if the default installed key for the edition is OEM Channel

## Remarks

- Some security programs will report infected files, that is false-positive due KMS emulating.
- Remove any other KMS solutions. Temporary turn off AV security protection. Run as administrator.
- If you installed the solution for auto renewal, exclude this file in AV security protection:
`C:\Windows\system32\SppExtComObjHook.dll`

## KMS Options for advanced users

You can modify KMS-related options by editing SppExtComObjPatcher.cmd or KMS_VL_ALL.cmd or setupcomplete.cmd

- KMS_Emulation
Enable embedded KMS Emulator functions
never change this option

- KMS_RenewalInterval
Set interval (minutes) for activated clients to auto renew KMS activation
this does not affect the overall KMS period (6 months)
allowed values: from 15 to 43200

- KMS_ActivationInterval
Set interval (minutes) for products to attempt KMS activation, whether unactivated or failed activation renewal
this does not affect the overall KMS period (6 months)
allowed values: from 15 to 43200

- KMS_HWID
Set custom KMS host Hardware ID hash, 0x prefix is mandatory
only affect Windows 8.1/ 10

- Windows, Office2010, Office2013, Office2016, Office2019
Set custom fixed KMS host ePID for each product, instead generating it randomly

## Debug

If the activation failed, you may run the debug mode to help determining the reason

Move SppExtComObjPatcher-kms folder to a short path
With Notepad open/edit KMS_VL_ALL.cmd
Change the zero 0 to 1 in set _Debug=0
Save the script, and run it as administrator
Wait until command prompt window is closed and Debug.log is created
Then upload or copy/post the log file

Note: this will auto remove SppExtComObjPatcher if it was installed
