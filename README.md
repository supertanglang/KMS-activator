[![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/fold_left.svg?style=social&label=Follow%20%40CHEF-KOCH)](https://twitter.com/FZeven)
[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/CHEF-KOCH)
[![Discord](https://discordapp.com/api/guilds/204394292519632897/widget.png)](https://discord.me/NVinside)

# KMS-activator

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


This project support activating KMS-Client editions of:<br />
* Windows 7/8/8.1/10
* Windows Server 2008 R2/2012/2012 R2
* Office 2010/2013/2016

Credits:<br />
* qad            	- SppExtComObjPatcher
* MasterDisaster 	- initial script / WMI methods
* qewpal         	- KMS_VL_ALL author
* Nucleus        	- Special assistance
* abbodi1406     	- MDL
* CHEF-KOCH     	- MDL
* vyvojar			- MDL