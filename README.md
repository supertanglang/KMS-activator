[![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/fold_left.svg?style=social&label=Follow%20%40CHEF-KOCH)](https://twitter.com/CKsTechNews)
[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/CHEF-KOCH)
[![Discord](https://discordapp.com/api/guilds/418256415874875402/widget.png)](https://discord.me/CHEF-KOCH)

# KMS-Activator

This is a community-based project, which was released on MDL and got several patches from me and other people.
The overall project goal isn't to bypass the Windows activation process, but for research reasons we want to show and explain how Windows activation holes could _theoretically_ be bypassed.


To use the official KMS solution for one-time standalone activation systems, run the following script:
* `KMS_VL_ALL.cmd`


To install this solution for auto renewal activation, run these scripts respectively:<br />
* `SppExtComObjPatcher.cmd`     	   - For install/uninstall the Patcher Hook
* `Activate-Local.cmd`          	   - To activate local machine, you must run it at least once!
* `Check-Activation-Status.cmd` 	   - (Optional)
* `Clear-KMS-Cache.cmd`         	   - (Optional)


#### OEM installation
`$oem$` folder for pre-activating the system during install.
Copy $oem$ to "sources" folder in the install media (iso/usb)
use SppExtComObjPatcher.cmd if you want to uninstall the project afterward.


#### Supported operating systems 
This project support _activating_ (**for tests only!**) KMS-Client editions of:
* Windows 7/8/8.1/10
* Windows Server 2008 + R2/2012 + R2 (LTSC)
* Office 2010/2013/2016/2019
* Server Standard/Datacenter 2016/2019


## Project Credits
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


## Difference between KMS, KMS38 & HWIDGEN

KMS38 is basically a renamed and modified version of the original KMS solution designed to activate the _problematic_ Windows versions such as [LTSB/LTSC](https://techcommunity.microsoft.com/t5/Windows-IT-Pro-Blog/LTSC-What-is-it-and-when-should-it-be-used/ba-p/293181). It is not a newly invented method, the developer just decided it's cool to rename it (_maybe to get more attention_) and add some support for Windows versions which didn't exist back in the "old" KMS days (KMS_VL_ALL is still under development!). 38 itself means 2038 which is the year until LTSB gets supported.

* HWID activation is done only once and windows will be automatically activated after a format/reinstall. Your hardware ID is stored on Microsoft servers, which means they can blacklist or close the loophole (if they want). 
* You can't uninstall or remove HWID once you activate it - you can only remove the executable but the activation files are still on the partition.
* HWID doesn't work for LTSB/LTSC (requires KMS/KMS38).
* HWID needs an active internet connection (without VPN) which might cause additional security problems (since MS gets your real data such as [IP etc.](https://en.wikipedia.org/wiki/Microsoft_Product_Activation)).
* KMS38/KMS19 works for LTSC/LTSB or Server Standard/Datacenter 2016 and 2019 and can also work in an _offline_ mode.
* MSToolkit (the current version doesn't detect KMS38) and only works (or was tested) up to RS 4.
* KMS38/KMS19 works in a VM same like HWID.
* HWID is depending on the current hardware, once you change it you have to re-activate Windows while KMS does it automatically in the background (if you allow it).
* The activation server (fake) is 69.69.69.69 which is only required to make Windows happy. Windows don't accept localhost IPs for KMS since Windows 10 anymore.

A detailed explanation/documentation incl. source code can be found [here](https://github.com/CHEF-KOCH/HWIDGEN-SRC).


## Anti-Virus programs

Usually batch and GUI programs are "_safe_". Windows itself has several internal protection mechanisms since their integrated Windows Defender & some PowerShell security mechanism, however most AV's getting triggered by potentially unwanted application ([pua](https://en.wikipedia.org/wiki/Potentially_unwanted_program)) because Microsoft decides that this loophole bypasses certain activation mechanism. Technically it doesn't bypass anything, but since their ToS explicitly mentioned that "tricks" are disallowed it will be marked as dangerous (_HackTool:Win32/AutoKMS_). 

This, of course, means that such programs (every single one of them, KMSPico, etc.) getting flagged. It's called a [false positive](https://en.wikipedia.org/wiki/False_positives_and_false_negatives) however, since there are a lot of fake repacks and fake versions available ensure that you always compare the checksums and download the program from trusted and verified sources (_if possible with source code_).


## OEM Integration (automatically activate Windows) 

The "slipstream" process allows you to integrate any _activator_ directly into an MS Windows/Office image. Keep in mind that providing such Frankenstein Builds to the public/forums are illegal, it's also illegal to sell such pre-activated products/images on e.g. eBay. Use this methods for e.g. a Virtual Machine for test reasons.

* You need the latest [HWID](https://github.com/CHEF-KOCH/KMS-activator/releases/) version.
* Extract the ISO and put the script(s) + `hwidgen.mk6.exe` + `Setupcomplete.cmd` (you can take it from KMS_VL_All) into `$oem$\$$\Setup\Scripts`.
* You have two files in `Sources\$OEM$\$$\Setup\Scripts`: hwidgen.mk3.exe + Setupcomplete.cmd and _optional_ other scripts (as shown below to automate the activation process in the folder).

```bash
@echo off
%~dp0"hwid.kms38.gen.mk6.exe" kms38
cd %~dp0
attrib -r -a -s -h *.*
rmdir /s /q "%windir%\setup\scripts"
exit
```

You can suppress the popups with the silent switches (HWID) `%~dp0"hwidkms38genmk6.exe" hwid` (KMS38) `%~dp0"hwidkms38genmk6.exe" kms38` In the above example, it's for the KMS38 (LTSB/LTSC/Server) activation process.


## Auto Renewal

To install this solution for auto renewal activation, run these scripts respectively:

1.) SppExtComObjPatcher.cmd
Install/uninstall the Patcher Hook.

2.) Activate-Local.cmd
Activate installed supported products (you must run it at least once).
You may need to run it again if you installed Office product afterward.


## Online KMS

You may use `Activate-Local.cmd` for online activation,
if you have valid/trusted external KMS host server.

- Edit Activate-Local.cmd with Notepad
- Change KMS_IP=172.16.0.2 to the IP/address of online KMS server
- Change Online=0 from zero 0 to 1
- Save the script, and run it as administrator


## Setup Pre-activation

* To preactivate the system during installation, copy $oem$ to "sources" folder in the installation media (iso/usb)
* If you already use another `setupcomplete.cmd`, rename this one to `KMS_VL_ALL.cmd` or similar name then add a command to run it in your setupcomplete.cmd, example call it `KMS_VL_ALL.cmd`.
* Use `SppExtComObjPatcher.cmd` if you want to uninstall the project afterward.
* **Note:** `setupcomplete.cmd` is disabled if the default installed key for the Windows edition is set to an OEM Channel.


## Remarks

- Some security programs will report infected files, that is false-positive due KMS emulating.
- Remove any other KMS solutions. Temporary turn off AV security protection. Run as administrator.
- If you installed the solution for auto-renewal, exclude this file in AV security protection:
`C:\Windows\system32\SppExtComObjHook.dll`


## KMS Options for advanced users

You can modify KMS-related options by editing SppExtComObjPatcher.cmd or KMS_VL_ALL.cmd or setupcomplete.cmd

### KMS_Emulation
Enable embedded KMS Emulator functions, never change this option!

### KMS_RenewalInterval
Set interval (minutes) for activated clients to auto-renew KMS activation this does not affect the overall KMS period (6 months) allowed values range from 15 to 43200.

### KMS_ActivationInterval
Set interval (minutes) for products to attempt KMS activation, whether unactivated or failed activation renewal this does not affect the overall KMS period (6 months). Aallowed values range from 15 to 43200.

### KMS_HWID
Set custom KMS host Hardware ID hash, 0x prefix is mandatory - only affects Windows 8.1 / 10 versions.

### Windows, Office 2010, Office 2013, Office 2016 & Office 2019
Set custom fixed KMS host ePID for each product, instead of generating it randomly. 

**Warning:** Some MS Office versions **must** be [converted from Retail to VLC (Volume License)](https://old.reddit.com/r/sjain_guides/comments/9m4m0k/microsoft_office_201319_simple_method_to_download/) e.g. Office 2019 otherwise the activator will not detect the product and the activation will automatically be aborted or it fails.



## Debugging

If the activation failed, you may want to run the debug mode to help to determine whjat caused the activation to fail.

* Move SppExtComObjPatcher-kms folder to a short path
* With e.g. Notepad/Notepad++/Visual Code open/edit KMS_VL_ALL.cmd
* Change the zero 0 to 1 in set _Debug=0
* Save the script, and run it as administrator
* Wait until command prompt window is closed and Debug.log is created
* Then upload or copy/post the log file, this can be helpful to improve or fix possible issues.

**Note:** This will automatically remove SppExtComObjPatcher if it was installed.

Reference:
* [Turn off KMS Client Online AVS Validation](https://getadmx.com/?Category=Windows_10_2016&Policy=Microsoft.Policies.SoftwareProtectionPlatform::NoAcquireGT)
