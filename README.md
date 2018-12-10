[![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/fold_left.svg?style=social&label=Follow%20%40CHEF-KOCH)](https://twitter.com/CKsTechNews)
[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/CHEF-KOCH)
[![Discord](https://discordapp.com/api/guilds/418256415874875402/widget.png)](https://discord.me/CHEF-KOCH)

# About KMS-Activator + 2038

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
