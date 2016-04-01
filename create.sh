#!/bin/bash
# Required: bash, VirtualBox 5 and up
#
# Usage examples:
# Will create and provision a new VM using downloaded dependencies.
#
# Example:
# ./create.sh vms/IE8\ -\ WinXP.ova

# Uncomment for debugging.
#
# Print each command to stdout before executing it, expands commands.
# set -x
# Abort script at first error, when a command exits with non-zero status.
# set -e
# Attempt to use undefined variable outputs error message, and forces an exit.
# set -u
# Causes a pipeline to return the exit status of the last command in the pipe that returned a non-zero return value.
# set -o

# Access configuration variables.
# Use shellcheck -x to allow following other files.
source config.sh

# VM Constants
APPLIANCE=${1}
REMOVE_VM=${3}
VM_NAME=False
VM_PRETTY_NAME=False
# -- Defaults to Linux
current_os="LINUX"
# -- Colors
# -- @see https://en.wikipedia.org/wiki/ANSI_escape_code
RED="\033[0;31m"
CYAN="\033[0;36m"
NOCOLOR="\033[0m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
MAGENTA="\033[0;35m"
# @todo Renable when error checking is refactored.
# shellcheck disable=SC2034
fatal=False
error=False
warning=False

# UTILITIES AND HELPERS.

# Error handling.
check() {
    if [ "${2}" != "0" ]; then
        if [ "${1}" = "fatal" ]; then
            log "[FATAL] ${3}"
            # shellcheck disable=SC2034
            fatal=True
            exit "${2}"
        fi
        if [ "${1}" = "skip" ]; then
            log "[WARNING] ${3}"
            # shellcheck disable=SC2034
            warning=True
        fi
        if [ "${1}" = "error" ]; then
            log "[ERROR] ${3}"
            # shellcheck disable=SC2034
            error=True
        fi
    else
        log "[OK]"
    fi
}

# Write log file and STDOUT.
log() {
    echo "${1}" | tee -a "${LOG_PATH}${VM_PRETTY_NAME}.log"
}

# Wait while task complete.
waiting() {
    counter=0
    echo -n "Waiting ${1} seconds"
    while [ ${counter} -lt ${1} ]; do
        echo -n "."
        let counter=counter+1
        sleep 1
    done
    echo ""
}

# Copy files from host top guest.
copyto() {
    # $1 = filename, $2 = source directory, $3 destination directory
    if [ ! -f "${2}${1}" ]
    then
        echo "Local file '${2}${1}' doesn't exist"
    fi
    run "VBoxManage guestcontrol '${VM_NAME}' copyto '${2}${1}' '${3}${1}' --username 'IEUser' --password 'Passw0rd!'"
}

# Loop VBoxManage guestcontrol commands as they are unreliable.
run() {
    counter=0
    while [ $counter -lt 10 ]; do

        echo "Running" + "$@"
        bash -c "$@"

        if [ "$?" = "0" ]; then
            guestcontrol_error=0
            break
        else
            guestcontrol_error=1
        fi
        let counter=counter+1
        sleep 10
    done

    if [ "$guestcontrol_error" = "0" ]; then
        return 0
    else
        check skip 1 "Error running" + "$@"
    fi
}

# Will run method based on guest OS.
# Executed method must use suffix to differentiate by OS.
execute_based_on_guest_os() {
    case "${VM_OS_TYPE}" in
        WindowsXP)
            ${1}_xp
        ;;
        WindowsVista)
            ${1}_wv
        ;;
        Windows7)
            ${1}_w7
        ;;
        Windows8*)
            ${1}_w8
        ;;
        *)
            check skip 1 "Unexpected OS. Skipping ${1}..."
        ;;
    esac
}

# Install the appliance (called by 'import_vm').
import_vm_xp() {
    VBoxManage import "${APPLIANCE}" --vsys 0 --memory ${VM_MEM_XP}
    check fatal $? "Could not import VM"
}

import_vm_w7() {
    VBoxManage import "${APPLIANCE}" --vsys 0 --memory ${VM_MEM}
    check fatal $? "Could not import VM"
}

import_vm_wv() {
    import_vm_w7
}

import_vm_w8() {
    import_vm_w7
}

# Disables User account control.
disable_uac_w7() {
    log "Mounting Disk..."
    VBoxManage storageattach "${VM_NAME}" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "${TOOLS_PATH}${DEUAC_FILENAME}"
    check fatal $? "Could not mount ${TOOLS_PATH}${DEUAC_FILENAME}"

    log "Disabling UAC..."
    VBoxManage startvm "${VM_NAME}" --type headless
    check fatal $? "Could not start VM to disable UAC"
    waiting ${STANDARD_WAIT}
    check_shutdown

    log "Removing Disk..."
    VBoxManage storageattach "${VM_NAME}" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium none
    check fatal $? "Could not unmount ${DEUAC_FILENAME}"
}

disable_uac_wv() {
    ex_disable_uac_w7
}

disable_uac_w8() {
    ex_disable_uac_w7
}

disable_uac_xp() {
    return 1
}

# Disable the Firewall.
disable_firewall_xp() {
    log "Disabling Windows XP Firewall..."
    run "VBoxManage guestcontrol '${VM_NAME}' start --exe 'C:/Windows/system32/netsh.exe' --username 'IEUser' -- 'firewall set opmode mode=DISABLE'"
    check error $? "Could not disable Firewall"
}

disable_firewall_w7() {
    log "Disabling Windows Firewall..."
    run "VBoxManage guestcontrol '${VM_NAME}' start --exe 'C:/windows/system32/netsh.exe' --username 'IEUser' --password 'Passw0rd!' -- 'advfirewall set allprofiles state off'"
    check error $? "Could not disable Firewall"
}

disable_firewall_wv() {
    ex_disable_firewall_w7
}

disable_firewall_w8() {
    ex_disable_firewall_w7
}

# Configures Selenium.
config_selenium_xp() {
    copyto config.json "${TOOLS_PATH}${TOOLS_PATH}XP/${VM_IE}/" "C:/selenium/"
    check error $? "Could not copy Selenium-Config"
}

config_selenium_w7() {
    copyto config.json "${TOOLS_PATH}${TOOLS_PATH}WIN7/${VM_IE}/" "C:/selenium/"
    check error $? "Could not copy Selenium-Config"
}

config_selenium_wv() {
    copyto config.json "${TOOLS_PATH}${TOOLS_PATH}VISTA/${VM_IE}/" "C:/selenium/"
    check error $? "Could not copy Selenium-Config"
}

config_selenium_w8() {
    copyto config.json "${TOOLS_PATH}${TOOLS_PATH}WIN8/${VM_IE}/" "C:/selenium/"
    check error $? "Could not copy Selenium-Config"
}

# Start Selenium.
start_selenium_xp() {
    copyto "${SELENIUM_HELPER_FILENAME}" "${TOOLS_PATH}${TOOLS_PATH}/" 'C:/Documents and Settings/All Users/Start Menu/Programs/Startup/'
    check error $? "Could not copy Selenium-Startup-File"
}

start_selenium_w7() {
    copyto "${SELENIUM_HELPER_FILENAME}" "${TOOLS_PATH}${TOOLS_PATH}" 'C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/'
    check error $? "Could not copy Selenium-Startup-File"
}

start_selenium_wv() {
    start_selenium_w7
}

start_selenium_w8() {
    start_selenium_w7
}

ie11_driver_reg() {
    if [ "${VM_IE}" = "IE11" ]; then
        log "Copy ie11_win32.reg..."
        copyto ie11_win32.reg "${TOOLS_PATH}" "${VM_TEMP_PATH}"
        check skip $? "Could not copy ie11_win32.reg"

        log "Setting ie11_win32.reg..."
        run "VBoxManage guestcontrol '${VM_NAME}' run --exe 'C:/Windows/Regedit.exe' --username 'IEUser' --password 'Passw0rd!' -- /s '${VM_TEMP_PATH}ie11_win32.reg'"
        check skip $? "Could not set ie11_win32.reg"
    fi
}

# Activates VM OS.
activate_vm_xp() {
    check skip 0 "Nothing to do..."
}

activate_vm_w7() {
    run "VBoxManage guestcontrol '${VM_NAME}' run --exe cmd.exe --username 'IEUser' --password 'Passw0rd!' -- /C slmgr /ato"
    check skip $? "Could not activate Windows"
}

activate_vm_wv() {
    ex_activate_vm_w7
}

activate_vm_w8() {
    activate_vm_w7
}

# Check if the VM is still running.
check_shutdown() {
    counter=0
    echo -n "Waiting for shutdown"
    while $(VBoxManage showvminfo "${VM_NAME}" | grep -q 'running'); do
        echo -n "."
        sleep 1
        let counter=counter+1
        if [ ${counter} -ge 120 ]; then
            check skip 1 "Unable to shutdown/restart..."
            break
        fi
    done
    echo ""
    waiting ${SHORT_WAIT}
}

# VM CONTROL UTILITIES AND HELPERS.

# Create a snapshot. Disabled by default.
snapshot_vm() {
    log "Creating Snapshot ${1}..."
    VBoxManage snapshot "${VM_NAME}" take "${1}"
    check skip $? "Could not create Snapshot ${1}"
}

# Reboot the VM.
# VBox ACPI functions are sometimes unreliable with XP-VMs.
reboot_vm() {
    log "Rebooting..."
    run "VBoxManage guestcontrol '${VM_NAME}' run --exe C:/Windows/system32/shutdown.exe --username 'IEUser' --password 'Passw0rd!' -- /t 5 /r /f"
    check skip $? "Could not reboot"
    waiting ${LONG_WAIT}
}

# Shutdown the VM and control the success via showvminfo.
shutdown_vm() {
    log "Shutting down..."
    run "VBoxManage guestcontrol '${VM_NAME}' run --exe C:/Windows/system32/shutdown.exe --username 'IEUser' --password 'Passw0rd!' -- /t 5 /s /f"
    check skip $? "Could not shut down"
    check_shutdown
}

# Will shutdown for removal.
shutdown_vm_for_removal() {
    log "Shutting down for removal..."
    run "VBoxManage guestcontrol \"${REMOVE_VM}\" run --exe C:/Windows/system32/shutdown.exe --username 'IEUser' --password 'Passw0rd!' -- /t 5 /s /f"
    check skip $? "Could not shut down for removal"
}

# Remove the given VM and delete associated files.
delete_vm() {
    log "Removing ${REMOVE_VM}..."
    if [ ! "$(VBoxManage showvminfo "${REMOVE_VM}" | grep -q 'running')" ]; then
        shutdown_vm_for_removal
        waiting ${STANDARD_WAIT}
    fi
    run "VBoxManage unregistervm '${REMOVE_VM}' --delete"
    check skip $? "Could not remove VM ${REMOVE_VM}"
    waiting ${SHORT_WAIT}
}

# BASIC VM INSTALLATION.

# Self explanatory, run basic checks.
execute_basic_checks() {
    # Is the user requesting usage help
    if [ "${1}" = "--help" ]; then
        echo "Usage: $0 path_to_ova [--delete VM-Name/UID]"
        exit 0
    fi

    # Is the user passing an appliance path
    if [ -z "${1}" ]; then
        echo "Appliance-Path is missing..."
        exit 1
    fi

    # Is there and 'appliance' in the provided path
    if [ ! -f "${1}" ]; then
        echo "Appliance ${1} not found..."
        exit 1
    fi

    # Is VBoxManage available
    if [ ! "$(which VBoxManage)" ]; then
        echo "VBoxManage not found..."
        exit 1
    fi

    # Is the user the "correct" user
    if [ "${USER}" != "${OWNER}" ]; then
        echo "This script must be run by user \'${OWNER}\'..."
        exit 1
    fi

    # Set os to OSX, if running on a Mac
    if [[ $OSTYPE = darwin* ]]; then
        current_os="OSX"
    fi
}

# Get information about the appliance (Name, OS, IE version).
get_vm_info() {
    vm_info=$(VBoxManage import "${APPLIANCE}" -n)
    check fatal $? "Error getting appliance Info"

    VM_NAME=$(echo "${vm_info}" | grep "Suggested VM name" | awk -F'"' '{print $2}')
    readonly VM_NAME
    VM_PRETTY_NAME=$(echo "${vm_info}" | grep "Suggested VM name" | awk -F'"' '{print $2}' | sed 's/_/-/g' | sed 's/ //g' | sed 's/\.//g')
    readonly VM_PRETTY_NAME
    VM_OS_TYPE=$(echo "${vm_info}" | grep 'Suggested OS type' | awk -F'"' '{print $2}')
    readonly VM_OS_TYPE
    VM_IE=$(echo "${VM_NAME}" | awk -F' -' '{print $1}')
    readonly VM_IE
}

# Import the given appliance.
import_vm() {
    log "Importing ${APPLIANCE} as ${VM_NAME}..."
    execute_based_on_guest_os import_vm
}

# PROVISION VM - CONFIGURATION.

# Set VM network configuration.
set_network_config() {
    # Can configure on config.sh
    if [[ $current_os = "OSX" ]]; then
        log "Setting network bridge ${MAC_VM_NIC_BRIDGE}..."
        run "VBoxManage modifyvm '${VM_NAME}' --nic1 bridged --bridgeadapter1 \"${MAC_VM_NIC_BRIDGE}\""
    else
        log "Setting network bridge ${LINUX_VM_NIC_BRIDGE}..."
        run "VBoxManage modifyvm '${VM_NAME}' --nic1 bridged --bridgeadapter1 \"${LINUX_VM_NIC_BRIDGE}\""
    fi

    check error $? "Could not set Bridge"
}

# Find free port and set for RDP(Remote Desktop Protocol) connection.
# See https://en.wikipedia.org/wiki/Remote_Desktop_Protocol
# See https://msdn.microsoft.com/en-us/library/cc240446.aspx
set_rdp_config() {
    # see https://www.virtualbox.org/manual/ch07.html
    log "Setting VRDE-Port ${vrdeport}..."
    vrdeports=$(find "${VMS_PATH}" -name '*.vbox' -print0 | xargs -0 grep "TCP/Ports" | awk -F'"' '{print $4}' | sort)

    for ((i=9000;i<=10000;i++)); do
        echo ${vrdeports} | grep -q ${i}
        if [[ $? -ne 0 ]]; then
            vrdeport=$i
            break
        fi
    done

    if [ -z "${vrdeport}" ]; then
        vrdeport="9000"
    fi
    if [[ ${vrdeport} -lt 9000 ]]; then
        vrdeport="9000"
    fi
    if [ "${vrdeport}" = "10000" ]; then
        check skip $? "Could not find free VRDE-Port"
    else
        run "VBoxManage modifyvm '${VM_NAME}' --vrde on --vrdeport \"${vrdeport}\""
        check error $? "Could not set VRDE-Port"
    fi
}

# Disable UAC (User Account Control).
# Required to install Java successfully later.
disable_uac() {
    execute_based_on_guest_os disable_uac
}

# Start VM. Wait to give the VM time to start up completely.
start_vm() {
    log "Starting VM ${VM_NAME}..."
    VBoxManage startvm "${VM_NAME}" --type headless
    check fatal $? "Could not start VM"
    waiting ${STANDARD_WAIT}
}

# Windows XP exclusive
pause_for_group_policy_confirm() {
    if [ "${VM_OS_TYPE}" = "WindowsXP" ]; then
        echo -e "${RED}********************************************************************************${NOCOLOR}"
        echo -e "${RED}IMPORTANT${NOCOLOR}"
        echo ""
        echo "This is the only 'manual' step."
        echo "Open the group policy editor on the command line by typing ${RED}gpedit.msc${NOCOLOR},"
        echo "Open the key:"
        echo -e "Computer Configuration\\Windows Settings\\Security Settings\\Local Policies\\${RED}Security Options${NOCOLOR}"
        echo "Change the value of"
        echo -e "Accounts: ${RED}Limit local account use of blank passwords to console logon only${NOCOLOR} to Disabled."
        echo ""
        echo -e "${RED}********************************************************************************${NOCOLOR}"
        waiting 120
    fi
}

# Disable the Windows firewall.
disable_firewall() {
    execute_based_on_guest_os disable_firewall
}

# Create temporary folder on guest.
create_temp_folder() {
    log "Creating ${VM_TEMP_PATH}..."
    run "VBoxManage guestcontrol '${VM_NAME}' createdirectory '${VM_TEMP_PATH}' --username 'IEUser' --password 'Passw0rd!'"
    check fatal $? "Could not create ${VM_TEMP_PATH}"
}

# Change the Hostname of the VM. Avoids duplicate names on the network.
# Copy rename.bat since the VBox exec doesn't provide the needed parameters
# in a way wmic.exe is able to apply correctly.
# WinXP usually fails to set the name, you can use C:\Temp\rename.bat to set it manually on the VM.
rename_vm() {
    case ${VM_NAME} in
        IE6*WinXP*)
            vm_orig_name="ie6winxp"
        ;;
        IE8*WinXP*)
            vm_orig_name="ie8winxp"
        ;;
        IE7*Vista*)
            vm_orig_name="IE7Vista"
        ;;
        IE8*Win7*)
            vm_orig_name="IE8Win7"
        ;;
        IE9*Win7*)
            vm_orig_name="IE9Win7"
        ;;
        IE10*Win7*)
            vm_orig_name="IE10Win7"
        ;;
        IE11*Win7*)
            vm_orig_name="IE11Win7"
        ;;
        IE10*Win8*)
            vm_orig_name="IE10Win8"
        ;;
        IE11*Win8*)
            vm_orig_name="IE11Win8_1"
        ;;
        *)
            check skip 1 "Could not find hostname, skip renaming..."
            return 1
        ;;
    esac

    log "Preparing to change Hostname ${vm_orig_name} to ${VM_PRETTY_NAME}..."
    echo 'c:\windows\system32\wbem\wmic.exe computersystem where caption="'${vm_orig_name}'" call rename "'${VM_PRETTY_NAME}'"' > /tmp/rename.bat
    check skip $? "Could not create rename.bat"

    log "Copy rename.bat..."
    # run "VBoxManage guestcontrol '${VM_NAME}' copyto '/tmp/rename.bat' "${VM_TEMP_PATH}" --username 'IEUser' --password 'Passw0rd!'"
    copyto 'rename.bat' '/tmp/' "${VM_TEMP_PATH}"
    check skip $? "Could not copy rename.bat"

    log "Launch rename.bat..."
    run "VBoxManage guestcontrol '${VM_NAME}' run --exe '${VM_TEMP_PATH}rename.bat' --username 'IEUser' --password 'Passw0rd!'"
    check skip $? "Could not change Hostname"
    waiting ${SHORT_WAIT}
}

# Change registry to configure IE (Protected-Mode, Cache)
set_ie_config() {
    log "Apply IE Protected-Mode Settings..."
    copyto "${IE_PROTECTEDMODE_REG_FILENAME}" "${TOOLS_PATH}" "${TEMP_PATH}"
    run "VBoxManage guestcontrol '${VM_NAME}' run --exe 'C:\\Windows\\Regedit.exe' --username 'IEUser' --password 'Passw0rd!' -- /s '${VM_TEMP_PATH}ie_protectedmode.reg'"
    check error $? "Could not apply IE Protected-Mode-Settings"

    log "Disabling IE-Cache..."
    copyto ie_disablecache.reg "${TOOLS_PATH}" "${VM_TEMP_PATH}"
    run "VBoxManage guestcontrol '${VM_NAME}' run --exe 'C:\\Windows\\Regedit.exe' --username 'IEUser' --password 'Passw0rd!' -- /s '${VM_TEMP_PATH}ie_disablecache.reg'"
    check error $? "Could not disable IE-Cache"
}

# PROVISION VM - ADDITIONAL DEPENDENCIES
# We don't use ""--wait-exit" as it may cause trouble with XP VMs.
# Instead, we just wait to provide enough time for the install.
# Install Java (Selenium requirement)

# instead we just wait some time to ensure the Java-Installer can finish.
install_java() {
    log "Installing Java..."
    copyto "${JAVA_FILENAME}" "${TOOLS_PATH}" "${VM_TEMP_PATH}"
    run "VBoxManage guestcontrol '${VM_NAME}' run --exe \"${VM_TEMP_PATH}${JAVA_FILENAME}\" --username 'IEUser' --password 'Passw0rd!' -- /s"
    check error $? "Could not install Java"
    waiting ${LONG_WAIT}
}

# Install Firefox.
install_firefox() {
    log "Installing Firefox..."
    copyto "${FIREFOX_FILENAME}" "${TOOLS_PATH}" "${VM_TEMP_PATH}"
    run "VBoxManage guestcontrol '${VM_NAME}' run --exe \"${VM_TEMP_PATH}${FIREFOX_FILENAME}\" --username 'IEUser' --password 'Passw0rd!' -- /S"
    check error $? "Could not install Firefox"
    waiting ${LONG_WAIT}
}

# Install Chrome.
install_chrome() {
    log "Installing Chrome..."
    #run "VBoxManage guestcontrol '${VM_NAME}' copyto \"${TOOLS_PATH}${CHROME_FILENAME}\" "${VM_TEMP_PATH}" --username 'IEUser' --password 'Passw0rd!'"
    copyto "${CHROME_FILENAME}" "${TOOLS_PATH}" "${VM_TEMP_PATH}"
    run "VBoxManage guestcontrol '${VM_NAME}' run --exe \"${VM_TEMP_PATH}${CHROME_FILENAME}\" --username 'IEUser' --password 'Passw0rd!' -- /S"
    check error $? "Could not install Chrome"
    waiting ${LONG_WAIT}
    install_chrome_driver
}

# Install Selenium
install_selenium() {
    log "Creating C:/selenium/..."
    run "VBoxManage guestcontrol '${VM_NAME}' createdirectory C:/selenium/ --username 'IEUser' --password 'Passw0rd!'"
    check fatal $? "Could not create C:/Selenium/"

    log "Installing Selenium..."
    copyto "${SELENIUM_FILENAME}" "${TOOLS_PATH}${TOOLS_PATH}" "C:/selenium/"
    check error $? "Could not install Selenium"

    log "Installing IEDriverServer..."
    copyto "IEDriverServer.exe" "${TOOLS_PATH}${TOOLS_PATH}" "C:/Windows/system32/"
    check error $? "Could not install IEDriverServer.exe"

    log "Configure Selenium..."
    execute_based_on_guest_os config_selenium

    log "Prepare Selenium-Autostart..."
    execute_based_on_guest_os start_selenium
    ie11_driver_reg
}

# Install Chrome-Driver for Selenium
install_chrome_driver() {
    log "Installing Chrome Driver..."
    copyto chromedriver.exe "${TOOLS_PATH}${TOOLS_PATH}" "C:/Windows/system32/"
    check error $? "Could not install Chrome Driver"
    waiting ${SHORT_WAIT}
}

# Copies Ngnix to guest machine
copy_nginx() {
    log "Copying Ngnix to guest machine..."
    copyto "${NGINX_FILENAME}" "${TOOLS_PATH}" "C:/${VM_TEMP_PATH}"
}

# PROVISION VM - ADDITIONAL CONFIGURATION

# Configures bi-directional clipboard
configure_clipboard() {
    log "Changing Clipboard-Mode to bidirectional..."
    VBoxManage controlvm "${VM_NAME}" clipboard bidirectional
    check skip $? "Could not set Clipboard-Mode"
    waiting ${SHORT_WAIT}
}

# Activates VM to prevent Genuine Windows messages.
activate_vm() {
    execute_based_on_guest_os activate_vm
}

# Creates an snapshot if enabled in script
create_snapshot() {
  if [ "${VM_CREATE_SNAPSHOT}" = "True" ]; then
      shutdown_vm "${VM_NAME}"
      snapshot_vm "Selenium"
      start_vm
  else
      reboot_vm
  fi
}

# Check if --delete was given as second parameter to this script.
# The VM name is expected to be the third parameter.
# If no VM name is given --delete will be ignored.
if [ "${2}" = "--delete" ]; then
    if [ ! -z "${3}" ]; then
        delete_vm
    else
        log "Delete VM"
        check skip "--delete was given, but no VM, skipping..."
    fi
fi

# BASIC VM INSTALLATION.
execute_basic_checks "${1}"
get_vm_info
import_vm
# PROVISION VM - CONFIGURATION.
set_network_config
set_rdp_config
disable_uac
start_vm
pause_for_group_policy_confirm
disable_firewall
create_temp_folder
rename_vm
set_ie_config
# PROVISION VM - ADDITIONAL DEPENDENCIES.
install_java
install_firefox
install_chrome
install_selenium
install_chrome_driver
copy_nginx
# PROVISION VM - ADDITIONAL CONFIGURATION.
configure_clipboard
activate_vm
create_snapshot
