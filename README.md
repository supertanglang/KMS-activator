[![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/fold_left.svg?style=social&label=Follow%20%40CHEF-KOCH)](https://twitter.com/CKsTechNews)
[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/CHEF-KOCH)
[![Discord](https://discordapp.com/api/guilds/418256415874875402/widget.png)](https://discord.me/CHEF-KOCH)

# KMS-Activator

This is a community-based project, which was released on [MDL](https://forums.mydigitallife.net/threads/kms-vl-all-online-offline-kms-activator-for-microsoft-products.63471/) and got several patches from me and other people.

The overall project goal isn't to bypass the Microsoft's Windows activation process. The project was created for research reasons, we want to show and explain how Windows activation holes could _theoretically_ be bypassed, we do not support any kind of Warez.


### Overview 
To use the official [KMS solution](https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys) for one-time standalone activation systems, run the following script with admin-rights:
* `KMS_VL_ALL.cmd`


For auto-renewal activation, run these scripts respectively:
* `SppExtComObjPatcher.cmd`     	   - For install/uninstall the Patcher-Hook
* `Activate-Local.cmd`          	   - To activate local machine, you must run it at least once!
* `Check-Activation-Status.cmd` 	   - (_optional_)
* `Clear-KMS-Cache.cmd`         	   - (_optional_)


#### Supported products

This project supports (**for tests only!**) the following products:

* Windows 7/8/8.1/10 (incl. LTSB / now LTSC)
* Windows Server 2008 + R2/2012 + R2 (LTSC)
* Server Standard/Datacenter 2016/2019
* Office 2010/2013/2016 & 2019
* _.. or in other words, all official supported MS OS/Office versions_.

This project **does not support** the following products:
* Any homebrew SKU such as CMB, CG or other "self-made" products.


## Credits

* qad            	- SppExtComObjPatcher
* MasterDisaster 	- initial script / WMI methods
* qewpal         	- KMS_VL_ALL (original?) author
* Nucleus        	- MDL (special assistance)
* abbodi1406     	- MDL
* CHEF-KOCH     	- MDL
* vyvojar			    - MDL
* s1ave77			    - MDL
* WindowsAddict 	- MDL
* AveYo           - MDL
* abbodi1406      - MDL
* Any contributor - YOU!


## Contribution

It is **permitted**:
* Creation of useful pull request which overall brings the project a step forward.
* Creation of useful (support) related issue ticket(s) with debug information according to the contribution guidelines.
* Everything which is not explicitly disallowed (see "not permitted" below).

It is **not permitted** to:
* Absuing GitHub's issue ticket or pull system for support questions without any information ala "does not work". In case there is a problem ensure you provide as much as possible on details otherwise the issue ticket will be closed without warning.
* Posting non-generic (default) keys here on GitHub, the key's which are official allowed to be mention in public are listed over [here](https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys).
* Links to warez, forums or software programs. Any topic/ticket with such links in it will be edited, you will be excluded from the project and it gets removed or/and locked.
* Creating multiple issue tickets with the same matter, use GitHub's issue ticket search function to avoid creating dublicates.
* Everything which bypasses the contribution guidelines, GitHUb ToS or the projects own Code of Conduct.


#### OEM installation

The `$oem$` folder for pre-activating the system during install, parses any script you put in. Copy the `$oem$` folder into `sources"` folder on the install media e.g. your ISO/USB drive. Use `SppExtComObjPatcher.cmd` if you want to uninstall the project afterwards.



## Difference between KMS, KMS38 & HWIDGEN

KMS38 is basically a renamed and modified version of the original KMS solution designed to activate the _problematic_ Windows versions such as [LTSB/LTSC](https://techcommunity.microsoft.com/t5/Windows-IT-Pro-Blog/LTSC-What-is-it-and-when-should-it-be-used/ba-p/293181). It is not a newly invented method, the developer just decided it's cool to rename it and add some support for Windows versions which didn't exist back in the "old" KMS days. 38 itself means 2038 which is the year until LTSB gets supported, it does not mean "for 38 years".

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

To install this solution to auto-renewal your action status, run these scripts respectively.

### SppExtComObjPatcher.cmd
Install/uninstall the patcher hook.

### Activate-Local.cmd
Activate any supported product (you must run it at least once). You may need to run it again if you installed an Office product afterward.

**Notice:** If you use the auto-renewal option ensure that you exclude this file in your AV security solution: `C:\Windows\system32\SppExtComObjHook.dll`


## Online KMS (own KMS server)

You may want to use `Activate-Local.cmd` for the online KMS activation in case you have an external trusted KMS address or your own KMS-Server running.

* Edit `Ativate-Local.cmd` with e.g. Notepad.
* Change `KMS_IP=172.16.0.2` to the IP/address of your own or trusted online KMS server.
* Change `Online=0` from zero `0` to `1`, this will enable the usage of the given IP-address.
* Save the script, and run it under admin-rights.

***Warning:** It is not permitted to ask for KMS VM server images to create your own "fake" KMS server. Topics or requests regarding this matter getting automatically closed.


## Setup (Pre-activation method)

Allows you to pre-activating the system during the OS installation process.

* Copy `$oem$` to `"sources"` folder in the installation media, your OS image (ISO/USB drive).
* If you already use another `setupcomplete.cmd`, rename this one to `KMS_VL_ALL.cmd` or similar name then add a command to run it in your setupcomplete.cmd, example call it `KMS_VL_ALL.cmd`.
* Use `SppExtComObjPatcher.cmd` if you want to uninstall the project afterward.

**Note:** `setupcomplete.cmd` is disabled if the default (pre)installed key for the Windows edition is set to an OEM Channel.


## Some Important Remarks

* The scripts or tools **must** run under administrator rights.
* Most if not all Windows activation programs will trigger AV programs (see above why).


## KMS Options (advance users only!)

You can modify KMS-related options by editing `SppExtComObjPatcher.cmd` or `KMS_VL_ALL.cmd` and `setupcomplete.cmd`.

### KMS_Emulation
Enable embedded KMS Emulator functions, never change this option!

### KMS_RenewalInterval
Set interval (minutes) for activated clients to auto-renew KMS activation, this does not affect the overall KMS period (6 months) allowed values range from 15 to 43200.

### KMS_ActivationInterval
Set interval (minutes) for products to attempt KMS activation, whether unactivated or failed activation renewal this does not affect the overall KMS period (6 months). Aallowed values range from 15 to 43200.

### KMS_HWID
Set custom KMS host Hardware ID hash, `0x` prefix is mandatory - only affects Windows 8.1 and 10 versions.

### Windows, Office 2010, Office 2013, Office 2016 & Office 2019
Set custom fixed KMS host ePID for each product, instead of generating it randomly. 

**Warning:** Some MS Office versions **must** be [converted from Retail to VLC (Volume License)](https://old.reddit.com/r/sjain_guides/comments/9m4m0k/microsoft_office_201319_simple_method_to_download/) e.g. Office 2019 otherwise the activator will not detect the product and the activation will automatically be aborted or it fails.


## Converting Office versions from Retail to VL Editions

The following tools/scripts are able to convert your Office versions from a Retail channel to a Volume channel. This is required to activate Office with a KMS key, otherwise the activation will fail.

* OfficeRTool
* Microsoft Toolkit
* [C2R-R2V_X.X.7z](https://github.com/abbodi1406/WHD/tree/master/scripts) - This is the most secure option, it's FOSS & tested, run the script under admin-rights and follow the steps shown in the CMD/PowerShell window.

## Debugging

If the activation failed, you may want to run the debug mode to help to determine what caused the activation to fail.

* Move `SppExtComObjPatcher-kms` folder to a short path.
* With e.g. Notepad/Notepad++/Visual Code open/edit `KMS_VL_ALL.cmd`.
* Change the zero `0` to `1` in `set _Debug=0`.
* Save the script, and run it under admin rights.
* Wait until command prompt window is closed and Debug.log is created.
* Then upload or copy/post the log file, this can be helpful to improve or fix possible issues.

**Note:** This will automatically remove `SppExtComObjPatcher` if it was installed.

Reference:
* [Turn off KMS Client Online AVS Validation](https://getadmx.com/?Category=Windows_10_2016&Policy=Microsoft.Policies.SoftwareProtectionPlatform::NoAcquireGT)
