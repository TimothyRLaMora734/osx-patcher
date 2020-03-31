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

	resources_path="$directory_path/patch"

	if [[ -d "/patch" ]]; then
		resources_path="/patch"
	fi
	
	if [[ -d "/Volumes/Image Volume/patch" ]]; then
		resources_path="/Volumes/Image Volume/patch"
	fi
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

Check_Resources()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking for resources."${erase_style}
	if [[ -d "$resources_path" ]]; then
		resources_check="passed"
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Resources check passed."${erase_style}
	fi
	if [[ ! -d "$resources_path" ]]; then
		resources_check="failed"
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Resources check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool with the required resources."${erase_style}
		Input_On
		exit
	fi
}

Input_Model()
{
model_list="/     iMac4,1
/     iMac4,2
/     iMac5,1
/     iMac5,2
/     MacBook2,1
/     MacBook3,1
/     MacBook4,1
/     MacBookAir1,1
/     MacBookPro2,1
/     MacBookPro2,2
/     Macmini1,1
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

	if [[ $environment == "installer" ]]; then
		system_volume_version="$(defaults read /System/Library/CoreServices/SystemVersion.plist ProductVersion)"
		system_volume_version_short="$(defaults read /System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5)"
	
		system_volume_build="$(defaults read /System/Library/CoreServices/SystemVersion.plist ProductBuildVersion)"

		if [[ ${#volume_version} == "6" ]]; then
			system_volume_version_short="$(defaults read /System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-4)"
		fi
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

Patch_Volume()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching boot.efi."${erase_style}
	if [[ $volume_version_short == "10."[8-9] || $volume_version_short == "10.10" ]]; then
		chflags nouchg "$volume_path"/System/Library/CoreServices/boot.efi
		cp "$resources_path"/EFI/10.8/boot.efi "$volume_path"/System/Library/CoreServices
		chflags uchg "$volume_path"/System/Library/CoreServices/boot.efi
	fi
	
	if [[ $volume_version_short == "10.11" ]]; then
		chflags nouchg "$volume_path"/System/Library/CoreServices/boot.efi
		cp "$resources_path"/EFI/10.11/boot.efi "$volume_path"/System/Library/CoreServices
		chflags uchg "$volume_path"/System/Library/CoreServices/boot.efi
	fi
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched boot.efi."${erase_style}

	if [[ $volume_version_short == "10.11" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching input drivers."${erase_style}
		rm -R "$volume_path"/System/Library/Extensions/IOUSBHostFamily.kext
		cp -R "$resources_path"/AppleHIDMouse.kext "$volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/AppleIRController.kext "$volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/AppleTopCase.kext "$volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/AppleUSBMultitouch.kext "$volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/AppleUSBTopCase.kext "$volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/IOBDStorageFamily.kext "$volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/IOBluetoothFamily.kext "$volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/IOBluetoothHIDDriver.kext "$volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/IOSerialFamily.kext "$volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/IOUSBFamily.kext "$volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/IOUSBHostFamily.kext "$volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/IOUSBMassStorageClass.kext "$volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/SIPManager.kext "$volume_path"/System/Library/Extensions/
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched input drivers."${erase_style}
	fi

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching graphics drivers."${erase_style}
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

	cp -R "$resources_path"/AppleIntelGMA950.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/AppleIntelGMA950GA.plugin "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/AppleIntelGMA950GLDriver.bundle "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/AppleIntelGMA950VADriver.bundle "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/AppleIntelGMAX3100.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/AppleIntelGMAX3100FB.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/AppleIntelGMAX3100GA.plugin "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/AppleIntelGMAX3100GLDriver.bundle "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/AppleIntelGMAX3100VADriver.bundle "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/AppleIntelIntegratedFramebuffer.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/ATI1300Controller.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/ATI1600Controller.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/ATI1900Controller.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/ATIFramebuffer.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/ATIRadeonX1000.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/ATIRadeonX1000GA.plugin "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/ATIRadeonX1000GLDriver.bundle "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/ATIRadeonX1000VADriver.bundle "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/ATISupport.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/GeForce.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/GeForce7xxx.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/GeForce7xxxGA.plugin "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/GeForce7xxxGLDriver.bundle "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/GeForce7xxxVADriver.bundle "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/GeForceGA.plugin "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/GeForceGLDriver.bundle "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/GeForceVADriver.bundle "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/NoSleep.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/NVDAGF100Hal.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/NVDAGK100Hal.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/NVDANV40HalG7xxx.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/NVDANV50Hal.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/NVDAResman.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/NVDAResmanG7xxx.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/NVSMU.kext "$volume_path"/System/Library/Extensions/

	Output_Off cp -R "$resources_path"/Brightness\ Slider.app "$volume_path"/Applications/Utilities
	Output_Off cp -R "$resources_path"/NoSleep.app "$volume_path"/Applications/Utilities
	Output_Off cp -R "$resources_path"/NoSleep.prefPane "$volume_path"/System/Library/PreferencePanes
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched graphics drivers."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching audio drivers."${erase_style}
	cp -R "$resources_path"/AppleHDA.kext "$volume_path"/System/Library/Extensions/
	cp -R "$resources_path"/IOAudioFamily.kext "$volume_path"/System/Library/Extensions/
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched audio drivers."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching platform support check."${erase_style}
	Output_Off rm "$volume_path"/System/Library/CoreServices/PlatformSupport.plist
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched platform support check."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching kernel flags."${erase_style}
	sed -i '' 's|<string></string>|<string>kext-dev-mode=1 mbasd=1</string>|' "$volume_path"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched kernel flags."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching kernel cache."${erase_style}
	Output_Off rm "$volume_path"/System/Library/Caches/com.apple.kext.caches/Startup/kernelcache
	Output_Off rm "$volume_path"/System/Library/PrelinkedKernels/prelinkedkernel
	Output_Off kextcache -f -u "$volume_path"
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched kernel cache."${erase_style}
}

Repair()
{
	chown -R 0:0 "$@"
	chmod -R 755 "$@"
}

Repair_Permissions()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Repairing permissions."${erase_style}
	if [[ $volume_version_short == "10.11" ]]; then
		Repair "$volume_path"/System/Library/Extensions/AppleHIDMouse.kext
		Repair "$volume_path"/System/Library/Extensions/AppleIRController.kext
		Repair "$volume_path"/System/Library/Extensions/AppleTopCase.kext
		Repair "$volume_path"/System/Library/Extensions/AppleUSBMultitouch.kext
		Repair "$volume_path"/System/Library/Extensions/AppleUSBTopCase.kext
		Repair "$volume_path"/System/Library/Extensions/IOBDStorageFamily.kext
		Repair "$volume_path"/System/Library/Extensions/IOBluetoothFamily.kext
		Repair "$volume_path"/System/Library/Extensions/IOBluetoothHIDDriver.kext
		Repair "$volume_path"/System/Library/Extensions/IOSerialFamily.kext
		Repair "$volume_path"/System/Library/Extensions/IOUSBFamily.kext
		Repair "$volume_path"/System/Library/Extensions/IOUSBHostFamily.kext
		Repair "$volume_path"/System/Library/Extensions/IOUSBMassStorageClass.kext
		Repair "$volume_path"/System/Library/Extensions/SIPManager.kext
	fi

	Repair "$volume_path"/System/Library/Extensions/AppleIntelGMA950.kext
	Repair "$volume_path"/System/Library/Extensions/AppleIntelGMA950GA.plugin
	Repair "$volume_path"/System/Library/Extensions/AppleIntelGMA950GLDriver.bundle
	Repair "$volume_path"/System/Library/Extensions/AppleIntelGMA950VADriver.bundle
	Repair "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100.kext
	Repair "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100FB.kext
	Repair "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100GA.plugin
	Repair "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100GLDriver.bundle
	Repair "$volume_path"/System/Library/Extensions/AppleIntelGMAX3100VADriver.bundle
	Repair "$volume_path"/System/Library/Extensions/AppleIntelIntegratedFramebuffer.kext
	Repair "$volume_path"/System/Library/Extensions/ATI1300Controller.kext
	Repair "$volume_path"/System/Library/Extensions/ATI1600Controller.kext
	Repair "$volume_path"/System/Library/Extensions/ATI1900Controller.kext
	Repair "$volume_path"/System/Library/Extensions/ATIFramebuffer.kext
	Repair "$volume_path"/System/Library/Extensions/ATIRadeonX1000.kext
	Repair "$volume_path"/System/Library/Extensions/ATIRadeonX1000GA.plugin
	Repair "$volume_path"/System/Library/Extensions/ATIRadeonX1000GLDriver.bundle
	Repair "$volume_path"/System/Library/Extensions/ATIRadeonX1000VADriver.bundle
	Repair "$volume_path"/System/Library/Extensions/ATISupport.kext
	Repair "$volume_path"/System/Library/Extensions/GeForce.kext
	Repair "$volume_path"/System/Library/Extensions/GeForce7xxx.kext
	Repair "$volume_path"/System/Library/Extensions/GeForce7xxxGA.plugin
	Repair "$volume_path"/System/Library/Extensions/GeForce7xxxGLDriver.bundle
	Repair "$volume_path"/System/Library/Extensions/GeForce7xxxVADriver.bundle
	Repair "$volume_path"/System/Library/Extensions/GeForceGA.plugin
	Repair "$volume_path"/System/Library/Extensions/GeForceGLDriver.bundle
	Repair "$volume_path"/System/Library/Extensions/GeForceVADriver.bundle
	Repair "$volume_path"/System/Library/Extensions/NVDAGF100Hal.kext
	Repair "$volume_path"/System/Library/Extensions/NVDAGK100Hal.kext
	Repair "$volume_path"/System/Library/Extensions/NVDANV40HalG7xxx.kext
	Repair "$volume_path"/System/Library/Extensions/NVDANV50Hal.kext
	Repair "$volume_path"/System/Library/Extensions/NVDAResman.kext
	Repair "$volume_path"/System/Library/Extensions/NVDAResmanG7xxx.kext
	Repair "$volume_path"/System/Library/Extensions/NVSMU.kext

	Repair "$volume_path"/Applications/Utilities/Brightness\ Slider.app
	Repair "$volume_path"/Applications/Utilities/NoSleep.app
	Repair "$volume_path"/System/Library/PreferencePanes/NoSleep.prefPane
	
	Repair "$volume_path"/System/Library/Extensions/AppleHDA.kext
	Repair "$volume_path"/System/Library/Extensions/IOAudioFamily.kext
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Repaired permissions."${erase_style}
}

Patch_Volume_Helpers()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching Recovery partition."${erase_style}

		if [[ $volume_version_short == "10."[8-9] && $system_volume_version == $volume_version ]]; then
			recovery_identifier="$(dm ensureRecoveryPartition "$volume_path" /BaseSystem.dmg 0 0 /BaseSystem.chunklist|grep "RecoveryPartitionBSD"|sed 's/.*\=\ //'|sed 's/.$//')"
		fi

		if [[ $volume_version_short == "10.1"[0-1] ]]; then
			recovery_identifier="$(diskutil info "$volume_name"|grep "Recovery Disk"|sed 's/.*\ //')"
		fi

		if [[ ! "$(diskutil info "${recovery_identifier}"|grep "Volume Name"|sed 's/.*\  //')" == "Recovery HD" ]]; then
			echo -e $(date "+%b %m %H:%M:%S") ${text_warning}"! Error patching Recovery partition."${erase_style}
		else
			Output_Off diskutil mount "$recovery_identifier"
	
			chflags nouchg /Volumes/Recovery\ HD/com.apple.recovery.boot/boot.efi
			cp "$volume_path"/System/Library/CoreServices/boot.efi /Volumes/Recovery\ HD/com.apple.recovery.boot
			chflags uchg /Volumes/Recovery\ HD/com.apple.recovery.boot/boot.efi
	
			if [[ $volume_version_short == "10.11" ]]; then
				chflags nouchg /Volumes/Recovery\ HD/com.apple.recovery.boot/prelinkedkernel
				rm /Volumes/Recovery\ HD/com.apple.recovery.boot/prelinkedkernel
				cp "$volume_path"/System/Library/PrelinkedKernels/prelinkedkernel /Volumes/Recovery\ HD/com.apple.recovery.boot
				chflags uchg /Volumes/Recovery\ HD/com.apple.recovery.boot/prelinkedkernel
			fi
		
			Output_Off rm /Volumes/Recovery\ HD/com.apple.recovery.boot/PlatformSupport.plist
			Output_Off sed -i '' 's|dmg</string>|dmg -no_compat_check kext-dev-mode=1 mbasd=1</string>|' /Volumes/Recovery\ HD/com.apple.recovery.boot/com.apple.boot.plist
		
			Output_Off diskutil unmount /Volumes/Recovery\ HD
	
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched Recovery partition."${erase_style}
	fi
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
Check_Resources
Input_Model
Input_Volume
Check_Volume_Version
Check_Volume_Support
Patch_Volume
Repair_Permissions
Patch_Volume_Helpers
End