#!/bin/bash

# Uncomment for debugging
#
# Print each command to stdout before executing it, expands commands
# set -x
# Abort script at first error, when a command exits with non-zero status
# set -e
# Attempt to use undefined variable outputs error message, and forces an exit
# set -u
# Causes a pipeline to return the exit status of the last command in the pipe that returned a non-zero return value.
# set -o

# Access configuration variables
source config.sh

APPLIANCE=${1}
REMOVE_VM=${3}
VM_NAME=False
VM_PRETTY_NAME=False

fatal=False
error=False
warning=False

# UTILITIES AND HELPERS
# Error handling.
chk() {
    if [ "${2}" != "0" ]; then
        if [ "${1}" = "fatal" ]; then
            log "[FATAL] ${3}"
            fatal=True
            sendmessage
            exit ${2}
        fi
        if [ "${1}" = "skip" ]; then
            log "[WARNING] ${3}"
            warning=True
        fi
        if [ "${1}" = "error" ]; then
            log "[ERROR] ${3}"
            error=True
        fi
    else
        log "[OK]"
    fi
}
# Will execute method based on guest OS.
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
            chk skip 1 "Unexpected OS. Skipping ${1}..."
        ;;
    esac
}

#Install the appliance (called by 'import_vm')
import_vm_xp() {
    VBoxManage import "${APPLIANCE}" --vsys 0 --memory ${VM_MEM_XP}
    chk fatal $? "Could not import VM"
}

import_vm_w7() {
    VBoxManage import "${APPLIANCE}" --vsys 0 --memory ${VM_MEM}
    chk fatal $? "Could not import VM"
}

import_vm_wv() {
    import_vm_w7
}

import_vm_w8() {
    import_vm_w7
}

# BASIC VM INSTALLATION
# Self explanatory, execute basic checks.
excecute_basic_checks() {
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
}

# Get information about the appliance (Name, OS, IE version)
get_vm_info() {
    vm_info=$(VBoxManage import "${APPLIANCE}" -n)
    chk fatal $? "Error getting appliance Info"

    VM_NAME=$(echo "${vm_info}" | grep "Suggested VM name" | awk -F'"' '{print $2}')
    readonly VM_NAME
    VM_PRETTY_NAME=$(echo "${vm_info}" | grep "Suggested VM name" | awk -F'"' '{print $2}' | sed 's/_/-/g' | sed 's/ //g' | sed 's/\.//g')
    readonly VM_PRETTY_NAME
    VM_OS_TYPE=$(echo "${vm_info}" | grep 'Suggested OS type' | awk -F'"' '{print $2}')
    readonly VM_OS_TYPE
    VM_IE=$(echo "${VM_NAME}" | awk -F' -' '{print $1}')
    readonly VM_IE
}

# Import the given appliance
import_vm() {
    log "Importing ${APPLIANCE} as ${VM_NAME}..."
    execute_based_on_guest_os import_vm
}

# PROVISION VM - CONFIGURATION
# Create C:\<LOG_PATH>\ on VM
create_log_folder() {
    log "Creating ${LOG_PATH}..."
    execute "VBoxManage guestcontrol '${VM_NAME}' createdirectory '${LOG_PATH}' --username 'IEUser' --password 'Passw0rd!'"
    chk fatal $? "Could not create ${LOG_PATH}"
}

# Set VM network configuration
set_network_config() {
    # Can configure on config.sh
    log "Setting network bridge ${VM_NIC_BRIDGE}..."
    execute "VBoxManage modifyvm '${VM_NAME}' --nic1 bridged --bridgeadapter1 \"${VM_NIC_BRIDGE}\""
    chk error $? "Could not set Bridge"
}

# Find free port and set for RDP(Remote Desktop Protocol) connection.
# See https://en.wikipedia.org/wiki/Remote_Desktop_Protocol
# See https://msdn.microsoft.com/en-us/library/cc240446.aspx
set_rdp_config() {
    # see https://www.virtualbox.org/manual/ch07.html
    log "Setting VRDE-Port ${vrdeport}..."
    vrdeports=$(find "${vm_path}" -name *.vbox -print0 | xargs -0 grep "TCP/Ports" | awk -F'"' '{print $4}' | sort)

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
    if [[ ${vrdeport} < 9000 ]]; then
        vrdeport="9000"
    fi
    if [ "${vrdeport}" = "10000" ]; then
        chk skip $? "Could not find free VRDE-Port"
    else
        execute "VBoxManage modifyvm '${VM_NAME}' --vrde on --vrdeport \"${vrdeport}\""
        chk error $? "Could not set VRDE-Port"
    fi
}

# PROVISION VM - ADDITIONAL DEPENDENCIES

# PROVISION VM - ADDITIONAL CONFIGURATION

copyto() {
    # $1 = filename, $2 = source directory, $3 destination directory
    if [ ! -f "${2}${1}" ]
    then
        echo "Local file '${2}${1}' doesn't exist"
    fi
    execute "VBoxManage guestcontrol '${VM_NAME}' copyto '${2}${1}' '${3}${1}' --username 'IEUser' --password 'Passw0rd!'"
}

# Loop VBoxManage guestcontrol commands as they are unreliable.
execute() {
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
        chk skip 1 "Error running" + "$@"
    fi
}

# Write Logfile and STDOUT.
log() {
    echo ${1} | tee -a "${LOG_PATH}${VM_PRETTY_NAME}.log"
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
            chk skip 1 "Unable to shutdown/restart..."
            break
        fi
    done
    echo ""
    waiting 5
}

# Print some dots.
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











# Internal: Helper-Functions to disable UAC (called by disable_uac)
ex_disable_uac_w7() {
    log "Mounting Disk..."
    VBoxManage storageattach "${VM_NAME}" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "${tools_path}${DEUAC_FILENAME}"
    chk fatal $? "Could not mount ${tools_path}${DEUAC_FILENAME}"
    log "Disabling UAC..."
    VBoxManage startvm "${VM_NAME}" --type headless
    chk fatal $? "Could not start VM to disable UAC"
    waiting 60
    check_shutdown
    log "Removing Disk..."
    VBoxManage storageattach "${VM_NAME}" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium none
    chk fatal $? "Could not unmount ${DEUAC_FILENAME}"
}

ex_disable_uac_wv() {
    ex_disable_uac_w7
}

ex_disable_uac_w8() {
    ex_disable_uac_w7
}

ex_disable_uac_xp() {
    return 1
}

# Disable UAC; Required to install Java successfully later; OS-Specific
disable_uac() {
    execute_based_on_guest_os ex_disable_uac
}

# Start the VM; Wait some seconds afterwards to give the VM time to start up completely.
start_vm() {
    log "Starting VM ${VM_NAME}..."
    VBoxManage startvm "${VM_NAME}" --type headless
    chk fatal $? "Could not start VM"
    waiting 60
}

# Internal: Helper-Functions to disable the Windows Firewall (called by disable_firewall)
ex_disable_firewall_xp() {
    log "Disabling Windows XP Firewall..."
    execute "VBoxManage guestcontrol '${VM_NAME}' execute --image 'C:/windows/system32/netsh.exe' --username 'IEUser' --password 'Passw0rd!' -- firewall set opmode mode=DISABLE"
    chk error $? "Could not disable Firewall"
}

ex_disable_firewall_w7() {
    log "Disabling Windows Firewall..."
    execute "VBoxManage guestcontrol '${VM_NAME}' execute --image 'C:/windows/system32/netsh.exe' --username 'IEUser' --password 'Passw0rd!' -- advfirewall set allprofiles state off"
    chk error $? "Could not disable Firewall"
}

ex_disable_firewall_wv() {
    ex_disable_firewall_w7
}

ex_disable_firewall_w8() {
    ex_disable_firewall_w7
}

# Disable the Windows Firewall; OS-Specific
disable_firewall() {
    execute_based_on_guest_os ex_disable_firewall
}


# Create C:\Temp\; Most Functions who copy files to the VM are relying on this folder and will fail is he doesn't exists.
create_temp_path() {
    log "Creating ${VM_TEMP_PATH}..."
    execute "VBoxManage guestcontrol '${VM_NAME}' createdirectory '${VM_TEMP_PATH}' --username 'IEUser' --password 'Passw0rd!'"
    chk fatal $? "Could not create ${VM_TEMP_PATH}"
}

# Apply registry changes to configure Internet Explorer settings (Protected-Mode, Cache)
set_ie_config() {
    log "Apply IE Protected-Mode Settings..."
    copyto "${IE_PROTECTEDMODE_REG_FILENAME}" "$tools_path" "$temp_path"
    execute "VBoxManage guestcontrol '${VM_NAME}' execute --image 'C:\\Windows\\Regedit.exe' --username 'IEUser' --password 'Passw0rd!' -- /s '${VM_TEMP_PATH}ie_protectedmode.reg'"
    chk error $? "Could not apply IE Protected-Mode-Settings"
    log "Disabling IE-Cache..."
    copyto ie_disablecache.reg "${tools_path}" "${VM_TEMP_PATH}"
    execute "VBoxManage guestcontrol '${VM_NAME}' execute --image 'C:\\Windows\\Regedit.exe' --username 'IEUser' --password 'Passw0rd!' -- /s '${VM_TEMP_PATH}ie_disablecache.reg'"
    chk error $? "Could not disable IE-Cache"
}

# Install Java (required by Selenium); We don't use --wait-exit as it may cause trouble with XP-VMs, instead we just wait some time to ensure the Java-Installer can finish.
install_java() {
    log "Installing Java..."
    copyto "${JAVA_FILENAME}" "${tools_path}" "${VM_TEMP_PATH}"
    execute "VBoxManage guestcontrol '${VM_NAME}' execute --image \"${VM_TEMP_PATH}${JAVA_FILENAME}\" --username 'IEUser' --password 'Passw0rd!' -- /s"
    chk error $? "Could not install Java"
    waiting 120
}

# Install Firefox.
install_firefox() {
    log "Installing Firefox..."
    copyto "${FIREFOX_FILENAME}" "${tools_path}" "${VM_TEMP_PATH}"
    execute "VBoxManage guestcontrol '${VM_NAME}' execute --image \"${VM_TEMP_PATH}${FIREFOX_FILENAME}\" --username 'IEUser' --password 'Passw0rd!' -- /S"
    chk error $? "Could not install Firefox"
    waiting 120
}

# Install Chrome-Driver for Selenium
install_chrome_driver() {
    log "Installing Chrome Driver..."
    copyto chromedriver.exe "${tools_path}${TOOLS_PATH}" "C:/Windows/system32/"
    chk error $? "Could not install Chrome Driver"
    waiting 5
}

# Install Chrome.
install_chrome() {
    log "Installing Chrome..."
    #execute "VBoxManage guestcontrol '${VM_NAME}' copyto \"${tools_path}${CHROME_FILENAME}\" "${VM_TEMP_PATH}" --username 'IEUser' --password 'Passw0rd!'"
    copyto "${CHROME_FILENAME}" "${tools_path}" "${VM_TEMP_PATH}"
    execute "VBoxManage guestcontrol '${VM_NAME}' execute --image \"${VM_TEMP_PATH}${CHROME_FILENAME}\" --username 'IEUser' --password 'Passw0rd!' -- /S"
    chk error $? "Could not install Chrome"
    waiting 120
    install_chrome_driver
}

# Install ngnix
copy_nginx() {
    log "Copying Ngnix to guest machine..."

    copyto "${ngnix_filename}" "${tools_path}" "C:/${VM_TEMP_PATH}"
}

# Internal: Helper-Functions to Install Selenium (called by install_selenium)
start_selenium_xp() {
    copyto "${SELENIUM_HELPER_FILENAME}" "${tools_path}${TOOLS_PATH}/" 'C:/Documents and Settings/All Users/Start Menu/Programs/Startup/'
    chk error $? "Could not copy Selenium-Startup-File"
}

start_selenium_w7() {
    copyto "${SELENIUM_HELPER_FILENAME}" "${tools_path}${TOOLS_PATH}" 'C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/'
    chk error $? "Could not copy Selenium-Startup-File"
}

start_selenium_wv() {
    start_selenium_w7
}

start_selenium_w8() {
    start_selenium_w7
}

config_selenium_xp() {
    #execute "VBoxManage guestcontrol '${VM_NAME}' copyto \"${tools_path}${TOOLS_PATH}XP/${VM_IE}/config.json\" C:/selenium/ --username 'IEUser' --password 'Passw0rd!'"
    copyto config.json "${tools_path}${TOOLS_PATH}XP/${VM_IE}/" "C:/selenium/"
    chk error $? "Could not copy Selenium-Config"
}

config_selenium_w7() {
    #execute "VBoxManage guestcontrol '${VM_NAME}' copyto \"${tools_path}${TOOLS_PATH}WIN7/${VM_IE}/config.json\" C:/selenium/ --username 'IEUser' --password 'Passw0rd!'"
    copyto config.json "${tools_path}${TOOLS_PATH}WIN7/${VM_IE}/" "C:/selenium/"
    chk error $? "Could not copy Selenium-Config"
}

config_selenium_wv() {
    #execute "VBoxManage guestcontrol '${VM_NAME}' copyto \"${tools_path}${TOOLS_PATH}VISTA/${VM_IE}/config.json\" C:/selenium/ --username 'IEUser' --password 'Passw0rd!'"
    copyto config.json "${tools_path}${TOOLS_PATH}VISTA/${VM_IE}/" "C:/selenium/"
    chk error $? "Could not copy Selenium-Config"
}

config_selenium_w8() {
    #execute "VBoxManage guestcontrol '${VM_NAME}' copyto \"${tools_path}${TOOLS_PATH}WIN8/${VM_IE}/config.json\" C:/selenium/ --username 'IEUser' --password 'Passw0rd!'"
    copyto config.json "${tools_path}${TOOLS_PATH}WIN8/${VM_IE}/" "C:/selenium/"
    chk error $? "Could not copy Selenium-Config"
}

ie11_driver_reg() {
    if [ "${VM_IE}" = "IE11" ]; then
        log "Copy ie11_win32.reg..."
        #execute "VBoxManage guestcontrol '${VM_NAME}' copyto \"${tools_path}ie11_win32.reg\" "${VM_TEMP_PATH}" --username 'IEUser' --password 'Passw0rd!'"
        copyto ie11_win32.reg "${tools_path}" "${VM_TEMP_PATH}"
        chk skip $? "Could not copy ie11_win32.reg"
        log "Setting ie11_win32.reg..."
        execute "VBoxManage guestcontrol '${VM_NAME}' execute --image 'C:\\Windows\\Regedit.exe' --username 'IEUser' --password 'Passw0rd!' -- /s '${VM_TEMP_PATH}ie11_win32.reg'"
        chk skip $? "Could not set ie11_win32.reg"
    fi
}

# Install Selenium
install_selenium() {
    log "Creating C:/selenium/..."
    execute "VBoxManage guestcontrol '${VM_NAME}' createdirectory C:/selenium/ --username 'IEUser' --password 'Passw0rd!'"
    chk fatal $? "Could not create C:/Selenium/"
    log "Installing Selenium..."
    #execute "VBoxManage guestcontrol '${VM_NAME}' copyto \"${tools_path}${TOOLS_PATH}${selenium_jar}\" C:/selenium/ --username 'IEUser' --password 'Passw0rd!'"
    copyto "${selenium_jar}" "${tools_path}${TOOLS_PATH}" "C:/selenium/"
    chk error $? "Could not install Selenium"
    log "Installing IEDriverServer..."
    #execute "VBoxManage guestcontrol '${VM_NAME}' copyto \"${tools_path}${TOOLS_PATH}IEDriverServer.exe\" C:/Windows/system32/ --username 'IEUser' --password 'Passw0rd!'"
    copyto "IEDriverServer.exe" "${tools_path}${TOOLS_PATH}" "C:/Windows/system32/"
    chk error $? "Could not install IEDriverServer.exe"
    log "Configure Selenium..."
    execute_based_on_guest_os config_selenium
    log "Prepare Selenium-Autostart..."
    execute_based_on_guest_os start_selenium
    ie11_driver_reg
}

# Create a Snapshot; Disabled by default.
snapshot_vm() {
    log "Creating Snapshot ${1}..."
    VBoxManage snapshot "${VM_NAME}" take "${1}"
    chk skip $? "Could not create Snapshot ${1}"
}

# Reboot the VM; Ensure to wait some time after sending the reboot-Command so that the machine can start up before other actions will applied.
# shutdown.exe is used because VBox ACPI-Functions are sometimes unreliable with XP-VMs.
reboot_vm() {
    log "Rebooting..."
    execute "VBoxManage guestcontrol '${VM_NAME}' execute --image C:/Windows/system32/shutdown.exe --username 'IEUser' --password 'Passw0rd!' -- /t 5 /r /f"
    chk skip $? "Could not reboot"
    waiting 90
}

# Shutdown the VM and control the success via showvminfo; shutdown.exe is used because VBox ACPI-Functions are sometimes unreliable with XP-VMs.
shutdown_vm() {
    log "Shutting down..."
    execute "VBoxManage guestcontrol '${VM_NAME}' execute --image C:/Windows/system32/shutdown.exe --username 'IEUser' --password 'Passw0rd!' -- /t 5 /s /f"
    chk skip $? "Could not shut down"
    check_shutdown
}

shutdown_vm_for_removal() {
    log "Shutting down for removal..."
    execute "VBoxManage guestcontrol \"${REMOVE_VM}\" execute --image C:/Windows/system32/shutdown.exe --username 'IEUser' --password 'Passw0rd!' -- /t 5 /s /f"
    chk skip $? "Could not shut down for removal"
}

# Remove the given Machine from VBox and delete all associated files. Shut down the VM beforehand, if needed.
delete_vm() {
    log "Removing ${REMOVE_VM}..."
    if [ ! $(VBoxManage showvminfo "${REMOVE_VM}" | grep -q 'running') ]; then
        shutdown_vm_for_removal
        waiting 30
    fi
    execute "VBoxManage unregistervm '${REMOVE_VM}' --delete"
    chk skip $? "Could not remove VM ${REMOVE_VM}"
    waiting 10
}

# Change the Hostname of the VM; Avoids duplicate Names on the Network in case you set up several instances of the same Appliance.
# We copy the rename.bat because the VBox exec doesn't provide the needed Parameters in a way wmic.exe is able to apply correctly.
# Also WinXP usually fails to set the name, you can use C:\Temp\rename.bat to set it manually on the VM. Make sure to restart afterwards.
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
            chk skip 1 "Could not find hostname, skip renaming..."
            return 1
        ;;
    esac
    log "Preparing to change Hostname ${vm_orig_name} to ${VM_PRETTY_NAME}..."
    echo 'c:\windows\system32\wbem\wmic.exe computersystem where caption="'${vm_orig_name}'" call rename "'${VM_PRETTY_NAME}'"' > /tmp/rename.bat
    chk skip $? "Could not create rename.bat"
    log "Copy rename.bat..."
    #execute "VBoxManage guestcontrol '${VM_NAME}' copyto '/tmp/rename.bat' "${VM_TEMP_PATH}" --username 'IEUser' --password 'Passw0rd!'"
    copyto 'rename.bat' '/tmp/' "${VM_TEMP_PATH}"
    chk skip $? "Could not copy rename.bat"
    log "Launch rename.bat..."
    execute "VBoxManage guestcontrol '${VM_NAME}' execute --image '${VM_TEMP_PATH}rename.bat' --username 'IEUser' --password 'Passw0rd!'"
    chk skip $? "Could not change Hostname"
    waiting 5
}

configure_clipboard() {
    log "Changing Clipboard-Mode to bidirectional..."
    VBoxManage controlvm "${VM_NAME}" clipboard bidirectional
    chk skip $? "Could not set Clipboard-Mode"
    waiting 5
}

# Check if --delete was given as second parameter to this script. The VM-Name is expected to be the third parameter.
# If no VM-Name is given --delete will be ignored.
if [ "${2}" = "--delete" ]; then
    if [ ! -z "${3}" ]; then
        delete_vm
    else
        log "Delete VM"
        chk skip "--delete was given, but no VM, skipping..."
    fi
fi

ex_activate_vm_xp() {
    chk skip 0 "Nothing to do..."
}

ex_activate_vm_w7() {
    execute "VBoxManage guestcontrol '${VM_NAME}' execute --image cmd.exe --username 'IEUser' --password 'Passw0rd!' -- /C slmgr /ato"
    chk skip $? "Could not activate Windows"
}

ex_activate_vm_wv() {
    ex_activate_vm_w7
}

ex_activate_vm_w8() {
    ex_activate_vm_w7
}

activate_vm() {
    execute_based_on_guest_os ex_activate_vm
}

# BASIC VM INSTALLATION
execute_basic_checks
get_vm_info
import_vm
# Config VM
create_log_folder
set_network_config
set_rdp_config
disable_uac
start_vm
disable_firewall
create_temp_path
rename_vm
set_ie_config
# Install dependencies
install_java
install_firefox
install_chrome
install_selenium
copy_nginx
# Additional steps
configure_clipboard
activate_vm

if [ "${VM_CREATE_SNAPSHOT}" = "True" ]; then
    shutdown_vm "${VM_NAME}"
    snapshot_vm "Selenium"
    start_vm
else
    reboot_vm
fi
