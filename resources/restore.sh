#!/bin/bash

parameters="${1}${2}${3}${4}${5}${6}${7}${8}${9}"

Escape_Variables()
{
	text_progress="\033[38;5;113m"
	text_success="\033[38;5;113m"
	text_warning="\033[38;5;221m"
	text_error="\033[38;5;203m"
	text_message="\033[38;5;75m"

	text_bold="\033[1m"
	text_faint="\033[2m"
	text_italic="\033[3m"
	text_underline="\033[4m"

	erase_style="\033[0m"
	erase_line="\033[0K"

	move_up="\033[1A"
	move_down="\033[1B"
	move_foward="\033[1C"
	move_backward="\033[1D"
}

Parameter_Variables()
{
	if [[ $parameters == *"-v"* || $parameters == *"-verbose"* ]]; then
		verbose="1"
		set -x
	fi
}

Path_Variables()
{
	script_path="${0}"
	directory_path="${0%/*}"
}

Input_Off()
{
	stty -echo
}
Input_On()
{
	stty echo
}

Output_Off() {
	if [[ $verbose == "1" ]]; then
		"$@"
	else
		"$@" &>/dev/null
	fi
}

Check_Environment()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking system environment."${erase_style}
	if [ -d /Install\ *.app ]; then
		environment="installer"
	fi
	if [ ! -d /Install\ *.app ]; then
		environment="system"
	fi
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Checked system environment."${erase_style}
}

Check_Root()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking for root permissions."${erase_style}
	if [[ $environment == "installer" ]]; then
		root_check="passed"
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Root permissions check passed."${erase_style}
	else
		if [[ $(whoami) == "root" && $environment == "system" ]]; then
			root_check="passed"
			echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Root permissions check passed."${erase_style}
		fi
		if [[ ! $(whoami) == "root" && $environment == "system" ]]; then
			root_check="failed"
			echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Root permissions check failed."${erase_style}
			echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool with root permissions."${erase_style}
			Input_On
			exit
		fi
	fi
}

Input_Model()
{
model_list="/     iMac5,1
/     iMac5,2
/     MacBook2,1
/     MacBook3,1
/     MacBook4,1
/     MacBookAir1,1
/     MacBookPro2,1
/     MacBookPro2,2
/     Macmini2,1
/     MacPro1,1
/     MacPro2,1
/     Xserve1,1
/     Xserve2,1"

	model_detected="$(sysctl -n hw.model)"

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Detecting model."${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Detected model as $model_detected."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What model would you like to use?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an model option."${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     1 - Use detected model"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     2 - Use manually selected model"${erase_style}
	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " model_option
	Input_Off

	if [[ $model_option == "1" ]]; then
		model="$model_detected"
		echo -e $(date "+%b %m %H:%M:%S") ${text_success}"+ Using $model_detected as model."${erase_style}
	fi

	if [[ $model_option == "2" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What model would you like to use?"${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input your model."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"$model_list"${erase_style}
		Input_On
		read -e -p "$(date "+%b %m %H:%M:%S") / " model_selected
		Input_Off
		model="$model_selected"
		echo -e $(date "+%b %m %H:%M:%S") ${text_success}"+ Using $model_selected as model."${erase_style}
	fi
}

Input_Volume()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What volume would you like to use?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input a volume name."${erase_style}
	for volume_path in /Volumes/*; do 
		volume_name="${volume_path#/Volumes/}"
		if [[ ! "$volume_name" == com.apple* ]]; then
			echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     ${volume_name}"${erase_style} | sort
		fi
	done
	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " volume_name
	Input_Off

	volume_path="/Volumes/$volume_name"
}

Check_Volume_Version()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking system version."${erase_style}
	volume_version="$(defaults read "$volume_path"/System/Library/CoreServices/SystemVersion.plist ProductVersion)"
	volume_version_short="$(defaults read "$volume_path"/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5)"
	
	volume_build="$(defaults read "$volume_path"/System/Library/CoreServices/SystemVersion.plist ProductBuildVersion)"

	if [[ ${#volume_version} == "6" ]]; then
		volume_version_short="$(defaults read "$volume_path"/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-4)"
	fi
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Checked system version."${erase_style}
}

Check_Volume_Support()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking system support."${erase_style}
	if [[ $volume_version_short == "10."[8-9] || $volume_version_short == "10.1"[0-1] ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ System support check passed."${erase_style}
	else
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- System support check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool on a supported system."${erase_style}
		Input_On
		exit
	fi
}

Repair()
{
	chown -R 0:0 "$@"
	chmod -R 755 "$@"
}

Restore_Volume()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing boot.efi patch."${erase_style}
	chflags nouchg "$volume_path"/System/Library/CoreServices/boot.efi
	rm "$volume_path"/System/Library/CoreServices/boot.efi
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed boot.efi patch."${erase_style}

	if [[ $volume_version_short == "10.11" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing input drivers patch."${erase_style}
		rm -R "$volume_path"/System/Library/Extensions/AppleHIDMouse.kext
		rm -R "$volume_path"/System/Library/Extensions/AppleIRController.kext
		rm -R "$volume_path"/System/Library/Extensions/AppleTopCase.kext
		rm -R "$volume_path"/System/Library/Extensions/AppleUSBMultitouch.kext
		rm -R "$volume_path"/System/Library/Extensions/AppleUSBTopCase.kext
		rm -R "$volume_path"/System/Library/Extensions/IOBDStorageFamily.kext
		rm -R "$volume_path"/System/Library/Extensions/IOBluetoothFamily.kext
		rm -R "$volume_path"/System/Library/Extensions/IOBluetoothHIDDriver.kext
		rm -R "$volume_path"/System/Library/Extensions/IOSerialFamily.kext
		rm -R "$volume_path"/System/Library/Extensions/IOUSBFamily.kext
		rm -R "$volume_path"/System/Library/Extensions/IOUSBHostFamily.kext
		rm -R "$volume_path"/System/Library/Extensions/IOUSBMassStorageClass.kext
		rm -R "$volume_path"/System/Library/Extensions/SIPManager.kext
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed input drivers patch."${erase_style}
	fi

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing graphics drivers patch."${erase_style}
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMD2400Controller.kext 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMD2600Controller.kext 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMD3800Controller.kext 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMD4600Controller.kext 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMD4800Controller.kext 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMD5000Controller.kext 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMD6000Controller.kext 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMD7000Controller.kext 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMD8000Controller.kext 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMD9000Controller.kext 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMDFramebuffer.kext 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMDMTLBronzeDriver.bundle 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMDRadeonVADriver.bundle 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMDRadeonX3000.kext 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMDRadeonX3000GLDriver.bundle 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMDRadeonX4000.kext 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMDRadeonX4000GLDriver.bundle 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMDShared.bundle 
	Output_Off rm -R "$volume_path"/System/Library/Extensions/AMDSupport.kext

	rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMA950.kext
	rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMA950GA.plugin
	rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMA950GLDriver.bundle
	rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMA950VADriver.bundle
	rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100.kext
	rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100FB.kext
	rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100GA.plugin
	rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100GLDriver.bundle
	rm -R "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100VADriver.bundle
	rm -R "$volume_path"/System/Library/Extensions/AppleIntelIntegratedFramebuffer.kext
	rm -R "$volume_path"/System/Library/Extensions/ATI1300Controller.kext
	rm -R "$volume_path"/System/Library/Extensions/ATI1600Controller.kext
	rm -R "$volume_path"/System/Library/Extensions/ATI1900Controller.kext
	rm -R "$volume_path"/System/Library/Extensions/ATIFramebuffer.kext
	rm -R "$volume_path"/System/Library/Extensions/ATIRadeonX1000.kext
	rm -R "$volume_path"/System/Library/Extensions/ATIRadeonX1000GA.plugin
	rm -R "$volume_path"/System/Library/Extensions/ATIRadeonX1000GLDriver.bundle
	rm -R "$volume_path"/System/Library/Extensions/ATIRadeonX1000VADriver.bundle
	rm -R "$volume_path"/System/Library/Extensions/ATISupport.kext
	rm -R "$volume_path"/System/Library/Extensions/GeForce.kext
	rm -R "$volume_path"/System/Library/Extensions/GeForce7xxx.kext
	rm -R "$volume_path"/System/Library/Extensions/GeForce7xxxGA.plugin
	rm -R "$volume_path"/System/Library/Extensions/GeForce7xxxGLDriver.bundle
	rm -R "$volume_path"/System/Library/Extensions/GeForce7xxxVADriver.bundle
	rm -R "$volume_path"/System/Library/Extensions/GeForceGA.plugin
	rm -R "$volume_path"/System/Library/Extensions/GeForceGLDriver.bundle
	rm -R "$volume_path"/System/Library/Extensions/GeForceVADriver.bundle
	rm -R "$volume_path"/System/Library/Extensions/NVDAGF100Hal.kext
	rm -R "$volume_path"/System/Library/Extensions/NVDAGK100Hal.kext
	rm -R "$volume_path"/System/Library/Extensions/NVDANV40HalG7xxx.kext
	rm -R "$volume_path"/System/Library/Extensions/NVDANV50Hal.kext
	rm -R "$volume_path"/System/Library/Extensions/NVDAResman.kext
	rm -R "$volume_path"/System/Library/Extensions/NVDAResmanG7xxx.kext
	rm -R "$volume_path"/System/Library/Extensions/NVSMU.kext
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed graphics drivers patch."${erase_style}

	if [[ $volume_version_short == "10.8" && -d $volume_path"/System/Library/Frameworks.backup" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Restoring original graphics frameworks."${erase_style}
		rm -R "$volume_path"/System/Library/Frameworks/OpenCL.framework
		rm -R "$volume_path"/System/Library/Frameworks/OpenGL.framework
		cp -R "$volume_path"/System/Library/Frameworks.backup/OpenCL.framework "$volume_path"/System/Library/Frameworks/
		cp -R "$volume_path"/System/Library/Frameworks.backup/OpenGL.framework "$volume_path"/System/Library/Frameworks/
		Repair "$volume_path"/System/Library/Frameworks/OpenCL.framework
		Repair "$volume_path"/System/Library/Frameworks/OpenGL.framework
		rm -R "$volume_path"/System/Library/Frameworks.backup
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Restored original graphics frameworks."${erase_style}
	fi

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing audio drivers patch."${erase_style}
	rm -R "$volume_path"/System/Library/Extensions/AppleHDA.kext
	rm -R "$volume_path"/System/Library/Extensions/IOAudioFamily.kext
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed audio drivers patch."${erase_style}
}

End()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Thank you for using OS X Patcher."${erase_style}
	Input_On
	exit
}

Input_Off
Escape_Variables
Parameter_Variables
Path_Variables
Check_Environment
Check_Root
Input_Model
Input_Volume
Check_Volume_Version
Check_Volume_Support
Restore_Volume
End
