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

	resources_path="$directory_path/resources"
}

Input_Off()
{
	stty -echo
}

Input_On()
{
	stty echo
}

Output_Off()
{
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

Input_Operation()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What operation would you like to run?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an operation number."${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     1 - Patch installer"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     2 - Patch update"${erase_style}
	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " operation
	Input_Off

	if [[ $operation == "1" ]]; then
		Input_Installer
		Check_Installer_Stucture
		Check_Installer_Version
		Check_Installer_Support
		Installer_Variables
		Input_Volume
		Create_Installer
		Patch_Installer
	fi
	if [[ $operation == "2" ]]; then
		Input_Package
		Patch_Package
	fi
}

Input_Installer()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What installer would you like to use?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an installer path."${erase_style}
	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " installer_application_path
	Input_Off

	installer_sharedsupport_path="$installer_application_path/Contents/SharedSupport"
}

Check_Installer_Stucture()
{
	Output_Off hdiutil attach "$installer_sharedsupport_path"/InstallESD.dmg -mountpoint /tmp/InstallESD -nobrowse  -noverify
	installer_images_path="/tmp/InstallESD"

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Mounting installer disk images."${erase_style}
	Output_Off hdiutil attach "$installer_images_path"/BaseSystem.dmg -mountpoint /tmp/Base\ System -nobrowse  -noverify
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Mounted installer disk images."${erase_style}
}

Check_Installer_Version()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking installer version."${erase_style}	
	installer_version="$(defaults read /tmp/Base\ System/System/Library/CoreServices/SystemVersion.plist ProductVersion)"
	installer_version_short="$(defaults read /tmp/Base\ System/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5)"

	if [[ ${#installer_version} == "6" ]]; then
		installer_version_short="$(defaults read /tmp/Base\ System/System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-4)"
	fi
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Checked installer version."${erase_style}	
}

Check_Installer_Support()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking installer support."${erase_style}
	if [[ $installer_version_short == "10."[8-9] || $installer_version_short == "10.1"[0-1] ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Installer support check passed."${erase_style}
	else
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Installer support check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool with a supported installer."${erase_style}
		Input_On
		exit
	fi
}

Installer_Variables()
{
	if [[ 1 == 1 ]]; then
		installer_prelinkedkernel="$installer_version_short"
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
	read -e -p "$(date "+%b %m %H:%M:%S") / " installer_volume_name
	Input_Off

	installer_volume_path="/Volumes/$installer_volume_name"
}

Create_Installer()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Restoring installer disk image."${erase_style}
	Output_Off asr restore -source "$installer_images_path"/BaseSystem.dmg -target "$installer_volume_path" -noprompt -noverify -erase
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Restored installer disk image."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Renaming installer volume."${erase_style}
	Output_Off diskutil rename /Volumes/*Base\ System "$installer_volume_name"
	bless --folder "$installer_volume_path"/System/Library/CoreServices --label "$installer_volume_name"
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Renamed installer volume."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Copying installer packages."${erase_style}
	rm "$installer_volume_path"/System/Installation/Packages
	cp -R /tmp/InstallESD/Packages "$installer_volume_path"/System/Installation/
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Copied installer packages."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Copying installer disk images."${erase_style}
	cp "$installer_images_path"/BaseSystem.dmg "$installer_volume_path"/
	cp "$installer_images_path"/BaseSystem.chunklist "$installer_volume_path"/
	
	if [[ -e "$installer_images_path"/AppleDiagnostics.dmg ]]; then
		cp "$installer_images_path"/AppleDiagnostics.dmg "$installer_volume_path"/
		cp "$installer_images_path"/AppleDiagnostics.chunklist "$installer_volume_path"/
	fi
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Copied installer disk images."${erase_style}

	if [[ $installer_version_short == "10.8" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Copying installer mach_kernel."${erase_style}
		cp /tmp/InstallESD/mach_kernel "$installer_volume_path"/
		chflags hidden "$installer_volume_path"/mach_kernel
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Copied installer mach_kernel."${erase_style}
	fi

	if [[ $installer_version_short == "10.9" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Copying installer mach_kernel."${erase_style}
		cp "$resources_path"/Kernels/"$installer_version_short"/mach_kernel "$installer_volume_path"/
		chflags hidden "$installer_volume_path"/mach_kernel
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Copied installer mach_kernel."${erase_style}
	fi

	if [[ $installer_version_short == "10.1"[0-1] ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Copying installer kernel."${erase_style}
		mkdir -p "$installer_volume_path"/System/Library/Kernels
		cp "$resources_path"/Kernels/"$installer_version_short"/kernel "$installer_volume_path"/System/Library/Kernels
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Copied installer kernel."${erase_style}
	fi

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Unmounting installer disk images."${erase_style}
	Output_Off hdiutil detach /tmp/Base\ System
	Output_Off hdiutil detach /tmp/InstallESD
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Unmounted installer disk images."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Replacing installer utilities menu."${erase_style}
	cp "$resources_path"/InstallerMenuAdditions.plist "$installer_volume_path"/System/Installation/CDIS/OS\ X\ Installer.app/Contents/Resources
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Replacing installer utilities menu."${erase_style}
}

Patch_Installer()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching installer package."${erase_style}
	cp "$installer_volume_path"/System/Installation/Packages/OSInstall.mpkg "$installer_volume_path"/tmp
	pkgutil --expand "$installer_volume_path"/tmp/OSInstall.mpkg "$installer_volume_path"/tmp/OSInstall
	sed -i '' 's/cpuFeatures\[i\] == "VMM"/1 == 1/' "$installer_volume_path"/tmp/OSInstall/Distribution
	sed -i '' 's/boardID == platformSupportValues\[i\]/1 == 1/' "$installer_volume_path"/tmp/OSInstall/Distribution
	sed -i '' 's/!boardID || platformSupportValues.length == 0/1 == 0/' "$installer_volume_path"/tmp/OSInstall/Distribution
	pkgutil --flatten "$installer_volume_path"/tmp/OSInstall "$installer_volume_path"/tmp/OSInstall.mpkg
	cp "$installer_volume_path"/tmp/OSInstall.mpkg "$installer_volume_path"/System/Installation/Packages
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched installer package."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching boot.efi."${erase_style}
	if [[ $installer_version_short == "10."[8-9] || $installer_version_short == "10.10" ]]; then
		chflags nouchg "$installer_volume_path"/System/Library/CoreServices/boot.efi
		cp "$resources_path"/patch/EFI/10.8/boot.efi "$installer_volume_path"/System/Library/CoreServices
		chflags uchg "$installer_volume_path"/System/Library/CoreServices/boot.efi
	fi

	if [[ $installer_version_short == "10.11" ]]; then
		chflags nouchg "$installer_volume_path"/System/Library/CoreServices/boot.efi
		cp "$resources_path"/patch/EFI/10.11/boot.efi "$installer_volume_path"/System/Library/CoreServices
		cp "$resources_path"/patch/EFI/10.11/boot.efi "$installer_volume_path"/System/Library/CoreServices/bootbase.efi
		chflags uchg "$installer_volume_path"/System/Library/CoreServices/boot.efi
		chflags uchg "$installer_volume_path"/System/Library/CoreServices/bootbase.efi
	fi
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched boot.efi."${erase_style}

	if [[ $installer_version_short == "10.11" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching drivers."${erase_style}
		rm -R "$installer_volume_path"/System/Library/Extensions/IOUSBHostFamily.kext
		cp -R "$resources_path"/patch/AppleHIDMouse.kext "$installer_volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/patch/AppleIRController.kext "$installer_volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/patch/AppleTopCase.kext "$installer_volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/patch/AppleUSBMultitouch.kext "$installer_volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/patch/AppleUSBTopCase.kext "$installer_volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/patch/IOBDStorageFamily.kext "$installer_volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/patch/IOBluetoothFamily.kext "$installer_volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/patch/IOBluetoothHIDDriver.kext "$installer_volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/patch/IOSerialFamily.kext "$installer_volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/patch/IOUSBFamily.kext "$installer_volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/patch/IOUSBHostFamily.kext "$installer_volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/patch/IOUSBMassStorageClass.kext "$installer_volume_path"/System/Library/Extensions/
		cp -R "$resources_path"/patch/SIPManager.kext "$installer_volume_path"/System/Library/Extensions/
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched drivers."${erase_style}
	fi

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching platform support check."${erase_style}
	rm "$installer_volume_path"/System/Library/CoreServices/PlatformSupport.plist
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched platform support check."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching kernel flags."${erase_style}
	sed -i '' 's|<string></string>|<string>kext-dev-mode=1 mbasd=1</string>|' "$installer_volume_path"/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched kernel flags."${erase_style}

	if [[ $installer_version_short == "10.11" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching kernel cache."${erase_style}
		rm "$installer_volume_path"/System/Library/PrelinkedKernels/prelinkedkernel
		cp "$resources_path"/PrelinkedKernel/10.11/prelinkedkernel "$installer_volume_path"/System/Library/PrelinkedKernels
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched kernel cache."${erase_style}
	fi

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Copying patcher utilities."${erase_style}
	cp -R "$resources_path"/patch "$installer_volume_path"/
	cp "$resources_path"/dm "$installer_volume_path"/usr/bin
	cp "$resources_path"/patch.sh "$installer_volume_path"/usr/bin/patch
	cp "$resources_path"/restore.sh "$installer_volume_path"/usr/bin/restore
	chmod +x "$installer_volume_path"/usr/bin/dm
	chmod +x "$installer_volume_path"/usr/bin/patch
	chmod +x "$installer_volume_path"/usr/bin/restore
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Copied patcher utilities."${erase_style}
}

Input_Package()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What update would you like to use?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an update path."${erase_style}
	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " package_path
	Input_Off

	package_folder="${package_path%.*}"
}

Patch_Package()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Expanding update package."${erase_style}
	pkgutil --expand "$package_path" "$package_folder"
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Expanded update package."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Patching update package."${erase_style}
	sed -i '' 's|<pkg-ref id="com\.apple\.pkg\.FirmwareUpdate" auth="Root" packageIdentifier="com\.apple\.pkg\.FirmwareUpdate">#FirmwareUpdate\.pkg<\/pkg-ref>||' "$package_folder"/Distribution
	sed -i '' 's/cpuFeatures\[i\] == "VMM"/1 == 1/' "$package_folder"/Distribution
	sed -i '' 's/nonSupportedModels.indexOf(currentModel)&gt;= 0/1 == 0/' "$package_folder"/Distribution
	sed -i '' 's/boardIds.indexOf(boardId)== -1/1 == 0/' "$package_folder"/Distribution
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Patched update package."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Preparing update package."${erase_style}
	pkgutil --flatten "$package_folder" "$package_path"
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Prepared update package."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing temporary files."${erase_style}
	Output_Off rm -R "$package_folder"
	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed temporary files."${erase_style}
}

End()
{
	if [[ $operation == "1" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing temporary files."${erase_style}
		Output_Off rm -R "$installer_volume_path"/tmp/*
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed temporary files."${erase_style}
	fi

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
Input_Operation
End