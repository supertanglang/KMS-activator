# KMS-activator

This is a community based project, which was released on MDL and got several patches from me and other people. 


To use this solution for one-time standalone activation, run this script only:
`KMS_VL_ALL.cmd`


To install this solution for auto renewal activation, run these scripts respectively:<br />
* `Clear-KMS-Cache.cmd`         	   - (Optional)
* `SppExtComObjPatcher.cmd`     	   - for install/uninstall the Patcher Hook
* `Activate-Local.cmd`          	   - to activate local machine, you must run it at least once!
* `Check-Activation-Status.cmd` 	   - (Optional)


OEM installation:<br />
`$oem$` folder for pre-activating the system during install.
Copy $oem$ to "sources" folder in the install media (iso/usb)
use SppExtComObjPatcher.cmd if you want to uninstall the project afterwards.


Notes:<br />
* This project support activating KMS-Client editions of:
* Windows 7/8/8.1/10
* Windows Server 2008R2/2012/2012R2
* Office 2010/2013/2016

Credits:<br />
* qad            	- SppExtComObjPatcher
* MasterDisaster 	- initial script / WMI methods
* qewpal         	- KMS_VL_ALL author
* Nucleus        	- Special assistance
* abbodi1406     	- MDL
* CHEF-KOCH     	- MDL
