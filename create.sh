#!/bin/bash

# Debug
#set -x
#set -e

source config.sh

# Basic-Checks.
if [ "${1}" = "--help" ]; then
    echo "Usage: $0 path_to_ova [--delete VM-Name/UID]"
    exit 0
fi

if [ -z "${1}" ]; then
    echo "Appliance-Path is missing..."
    exit 1
fi

if [ ! -f "${1}" ]; then
    echo "Appliance ${1} not found..."
    exit 1
fi

if [ ! "$(which VBoxManage)" ]; then
    echo "VBoxManage not found..."
    exit 1
fi

if [ "${USER}" != "${OWNER}" ]; then
    echo "This script must be run by user \'${OWNER}\'..."
    exit 1
fi

# Init; Do not change.
appliance=${1}
remove_vm=${3}
vm_name=False
vm_pretty_name=False

copyto() {
    # $1 = filename, $2 = source directory, $3 destination directory
    if [ ! -f "${2}${1}" ]
    then
        echo "Local file '${2}${1}' doesn't exist"
    fi
    execute "VBoxManage guestcontrol '${vm_name}' --username 'IEUser' --password 'Passw0rd!' copyto --target-directory '${3}${1}' '${2}${1}' "
}

# Loop VBoxManage guestcontrol commands as they are unreliable.
execute() {
    counter=0
    while [ $counter -lt 10 ]; do

        echo "Running $*"
        bash -c "$*"

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
        check skip 1 "Error running $*"
    fi
}

# Write Logfile and STDOUT.
log() {
    echo ${1} | tee -a "${LOG_PATH}${vm_pretty_name}.log"
}

# Error-Handling.
check() {
    if [ "${2}" != "0" ]; then
        if [ "${1}" = "fatal" ]; then
            log "[FATAL] ${3}"
            exit ${2}
        fi
        if [ "${1}" = "skip" ]; then
            log "[WARNING] ${3}"
        fi
        if [ "${1}" = "error" ]; then
            log "[ERROR] ${3}"
        fi
    else
        log "[OK]"
    fi
}

# Get VM OS-Type.
execute_os_specific() {
    case "${vm_os_type}" in
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
            check skip 1 "Unexpected OS-Type, skipping ${1}..."
        ;;
    esac
}

# Check if the VM is still running.
check_shutdown() {
    counter=0
    echo -n "Waiting for shutdown"
    while VBoxManage showvminfo "${vm_name}" | grep -q 'running'; do
        echo -n "."
        sleep 1
        let counter=counter+1
        if [ ${counter} -ge 120 ]; then
            check skip 1 "Unable to shutdown/restart..."
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

# Get informations about the given Appliance (Name, OS-Type, IE-Version)
get_vm_info() {
    vm_info=$(VBoxManage import "${appliance}" -n)
    check fatal $? "Error getting Appliance Info"
    vm_name=$(echo "${vm_info}" | grep "Suggested VM name" | awk -F'"' '{print $2}')
    vm_pretty_name=$(echo "${vm_info}" | grep "Suggested VM name" | awk -F'"' '{print $2}' | sed 's/_/-/g' | sed 's/ //g' | sed 's/\.//g')
    vm_os_type=$(echo "${vm_info}" | grep 'Suggested OS type' | awk -F'"' '{print $2}')
    vm_ie=$(echo "${vm_name}" | awk -F' -' '{print $1}')
}

#Internal: Helper-Functions to install the Appliance (called by import_vm)
ex_import_vm_xp() {
    VBoxManage import "${appliance}" --vsys 0 --memory ${VM_MEM_XP}
    check fatal $? "Could not import VM"
}

ex_import_vm_w7() {
    VBoxManage import "${appliance}" --vsys 0 --memory ${VM_MEM}
    check fatal $? "Could not import VM"
}

ex_import_vm_wv() {
    ex_import_vm_w7
}

ex_import_vm_w8() {
    ex_import_vm_w7
}

# Import the given Appliance-File; OS-Specific
import_vm() {
    log "Importing ${appliance} as ${vm_name}..."
    execute_os_specific ex_import_vm
}

# Set VM Network-Config.
set_network_config() {
    log "Setting network bridge ${VM_NIC_BRIDGE}..."
    execute "VBoxManage modifyvm '${vm_name}' --nic1 bridged --bridgeadapter1 '${VM_NIC_BRIDGE}'"
    check error $? "Could not set Bridge"
}

# Find and set free Port for RDP-Connection.
set_rdp_config() {
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
        execute "VBoxManage modifyvm '${vm_name}' --vrde on --vrdeport '${vrdeport}'"
        check error $? "Could not set VRDE-Port"
    fi
}

# Internal: Helper-Functions to disable UAC (called by disable_uac)
ex_disable_uac_w7() {
    log "Mounting Disk..."
    VBoxManage storageattach "${vm_name}" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "${TOOLS_PATH}${DEUAC_FILENAME}"
    check fatal $? "Could not mount ${TOOLS_PATH}${DEUAC_FILENAME}"
    log "Disabling UAC..."

    start_vm

    check_shutdown
    log "Removing Disk..."
    VBoxManage storageattach "${vm_name}" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium none
    check fatal $? "Could not unmount ${DEUAC_FILENAME}"
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
    execute_os_specific ex_disable_uac
}

# Start the VM; Wait some seconds afterwards to give the VM time to start up completely.
start_vm() {
    log "Starting VM ${vm_name}..."
    VBoxManage startvm "${vm_name}" --type headless
    check fatal $? "Could not start VM"
    waiting 60
}

# Internal: Helper-Functions to disable the Windows Firewall (called by disable_firewall)
ex_disable_firewall_xp() {
    log "Disabling Windows XP Firewall..."
    execute "VBoxManage guestcontrol '${vm_name}' run --exe 'C:/windows/system32/cmd.exe' --username 'IEUser' --password 'Passw0rd!' -- netsh firewall set opmode mode=DISABLE"
    check error $? "Could not disable Firewall"
}

ex_disable_firewall_w7() {
    log "Disabling Windows Firewall..."
    execute "VBoxManage guestcontrol '${vm_name}' run --exe 'C:/windows/system32/cmd.exe' --username 'IEUser' --password 'Passw0rd!' -- netsh advfirewall set allprofiles state off"
    check error $? "Could not disable Firewall"
}

ex_disable_firewall_wv() {
    ex_disable_firewall_w7
}

ex_disable_firewall_w8() {
    ex_disable_firewall_w7
}

# Disable the Windows Firewall; OS-Specific
disable_firewall() {
    execute_os_specific ex_disable_firewall
}

# Create C:\<LOG_PATH>\; Most Functions will log to this folder.
create_log_path() {
    log "Creating ${VM_LOG_PATH}..."
    execute "VBoxManage guestcontrol '${vm_name}' createdirectory '${VM_LOG_PATH}' --username 'IEUser' --password 'Passw0rd!'"
    check fatal $? "Could not create ${VM_LOG_PATH}"
}

# Create C:\Temp\; Most Functions who copy files to the VM are relying on this folder and will fail is he doesn't exists.
create_temp_path() {
    log "Creating ${VM_TEMP_PATH}..."
    execute "VBoxManage guestcontrol '${vm_name}' createdirectory '${VM_TEMP_PATH}' --username 'IEUser' --password 'Passw0rd!'"
    check fatal $? "Could not create ${VM_TEMP_PATH}"
}

# Apply registry changes to configure Internet Explorer settings (Protected-Mode, Cache)
set_ie_config() {
    log "Apply IE Protected-Mode Settings..."
    copyto "${IE_PROTECTEDMODE_REG_FILENAME}" "${TOOLS_PATH}" "${VM_TEMP_PATH}"
    execute "VBoxManage guestcontrol '${vm_name}' run --exe 'C:\\Windows\\Regedit.exe' --username 'IEUser' --password 'Passw0rd!' -- /S '${VM_TEMP_PATH}${IE_PROTECTEDMODE_REG_FILENAME}'"
    check error $? "Could not apply IE Protected-Mode-Settings"
    log "Disabling IE-Cache..."
    copyto "${IE_CACHE_REG_FILENAME}" "${TOOLS_PATH}" "${VM_TEMP_PATH}"
    execute "VBoxManage guestcontrol '${vm_name}' run --exe 'C:\\Windows\\Regedit.exe' --username 'IEUser' --password 'Passw0rd!' -- -S '${VM_TEMP_PATH}${IE_CACHE_REG_FILENAME}'"
    check error $? "Could not disable IE-Cache"
}

# Install Java (required by Selenium); We don't use --wait-exit as it may cause trouble with XP-VMs, instead we just wait some time to ensure the Java-Installer can finish.
install_java() {
    log "Installing Java..."
    copyto "${JAVA_FILENAME}" "${TOOLS_PATH}" "${VM_TEMP_PATH}"
    execute "VBoxManage guestcontrol '${vm_name}' run --exe \"${VM_TEMP_PATH}${JAVA_FILENAME}\" --username 'IEUser' --password 'Passw0rd!' -- /S"
    check error $? "Could not install Java"
    waiting 120
}

# Install Firefox.
install_firefox() {
    log "Installing Firefox..."
    copyto "${FIREFOX_FILENAME}" "${TOOLS_PATH}" "${VM_TEMP_PATH}"
    execute "VBoxManage guestcontrol '${vm_name}' run --exe \"${VM_TEMP_PATH}${FIREFOX_FILENAME}\" --username 'IEUser' --password 'Passw0rd!' -- /S"
    check error $? "Could not install Firefox"
    waiting 120
}

# Install Chrome-Driver for Selenium
install_chrome_driver() {
    log "Installing Chrome Driver..."
    copyto chromedriver.exe "${TOOLS_PATH}${SELENIUM_PATH}" "C:/Windows/system32/"
    check error $? "Could not install Chrome Driver"
    waiting 5
}

# Install Chrome.
install_chrome() {
    log "Installing Chrome..."
    copyto "${CHROME_FILENAME}" "${TOOLS_PATH}" "${VM_TEMP_PATH}"
    execute "VBoxManage guestcontrol '${vm_name}' run --exe \"${VM_TEMP_PATH}${CHROME_FILENAME}\" --username 'IEUser' --password 'Passw0rd!' -- /S"
    check error $? "Could not install Chrome"
    waiting 120
    install_chrome_driver
}

# Install ngnix
copy_nginx() {
    log "Copying Ngnix to guest machine..."
    copyto "${NGINX_FILENAME}" "${TOOLS_PATH}" "${VM_TEMP_PATH}"
}

# Internal: Helper-Functions to Install Selenium (called by install_selenium)
start_selenium_xp() {
    copyto "${SELENIUM_HELPER_FILENAME}" "${TOOLS_PATH}${SELENIUM_PATH}/" 'C:/Documents and Settings/All Users/Start Menu/Programs/Startup/'
    check error $? "Could not copy Selenium-Startup-File"
}

start_selenium_w7() {
    copyto "${SELENIUM_HELPER_FILENAME}" "${TOOLS_PATH}${SELENIUM_PATH}" 'C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/'
    check error $? "Could not copy Selenium-Startup-File"
}

start_selenium_wv() {
    start_selenium_w7
}

start_selenium_w8() {
    start_selenium_w7
}

config_selenium_xp() {
    copyto config.json "${TOOLS_PATH}${SELENIUM_PATH}XP/${vm_ie}/" "C:/selenium/"
    check error $? "Could not copy Selenium-Config"
}

config_selenium_w7() {
    copyto config.json "${TOOLS_PATH}${SELENIUM_PATH}WIN7/${vm_ie}/" "C:/selenium/"
    check error $? "Could not copy Selenium-Config"
}

config_selenium_wv() {
    copyto config.json "${TOOLS_PATH}${SELENIUM_PATH}VISTA/${vm_ie}/" "C:/selenium/"
    check error $? "Could not copy Selenium-Config"
}

config_selenium_w8() {
    copyto config.json "${TOOLS_PATH}${SELENIUM_PATH}WIN8/${vm_ie}/" "C:/selenium/"
    check error $? "Could not copy Selenium-Config"
}

ie11_driver_reg() {
    if [ "${vm_ie}" = "IE11" ]; then
        log "Copy ie11_win32.reg..."
        copyto ie11_win32.reg "${TOOLS_PATH}" "${VM_TEMP_PATH}"
        check skip $? "Could not copy ie11_win32.reg"
        log "Setting ie11_win32.reg..."
        execute "VBoxManage guestcontrol '${vm_name}' run --exe 'C:\\Windows\\Regedit.exe' --username 'IEUser' --password 'Passw0rd!' -- /s '${VM_TEMP_PATH}ie11_win32.reg'"
        check skip $? "Could not set ie11_win32.reg"
    fi
}

# Install Selenium
install_selenium() {
    log "Creating C:/selenium/..."
    execute "VBoxManage guestcontrol '${vm_name}' createdirectory C:/selenium/ --username 'IEUser' --password 'Passw0rd!'"
    check fatal $? "Could not create C:/Selenium/"
    log "Installing Selenium..."
    copyto "${SELENIUM_FILENAME}" "${TOOLS_PATH}${SELENIUM_PATH}" "C:/selenium/"
    check error $? "Could not install Selenium"
    log "Installing IEDriverServer..."
    copyto "IEDriverServer.exe" "${TOOLS_PATH}${SELENIUM_PATH}" "C:/Windows/system32/"
    check error $? "Could not install IEDriverServer.exe"
    log "Configure Selenium..."
    execute_os_specific config_selenium
    log "Prepare Selenium-Autostart..."
    execute_os_specific start_selenium
    ie11_driver_reg
}

# Create a Snapshot; Disabled by default.
snapshot_vm() {
    log "Creating Snapshot ${1}..."
    VBoxManage snapshot "${vm_name}" take "${1}"
    check skip $? "Could not create Snapshot ${1}"
}

# Reboot the VM; Ensure to wait some time after sending the reboot-Command so that the machine can start up before other actions will applied.
# shutdown.exe is used because VBox ACPI-Functions are sometimes unreliable with XP-VMs.
reboot_vm() {
    log "Rebooting..."
    execute "VBoxManage guestcontrol '${vm_name}' run --exe C:/Windows/system32/shutdown.exe --username 'IEUser' --password 'Passw0rd!' -- /t 5 /r /f"
    check skip $? "Could not reboot"
    waiting 90
}

# Shutdown the VM and control the success via showvminfo; shutdown.exe is used because VBox ACPI-Functions are sometimes unreliable with XP-VMs.
shutdown_vm() {
    log "Shutting down..."
    execute "VBoxManage guestcontrol '${vm_name}' run --exe C:/Windows/system32/shutdown.exe --username 'IEUser' --password 'Passw0rd!' -- /t 5 /s /f"
    check skip $? "Could not shut down"
    check_shutdown
}

shutdown_vm_for_removal() {
    log "Shutting down for removal..."
    execute "VBoxManage guestcontrol \"${remove_vm}\" run --exe C:/Windows/system32/shutdown.exe --username 'IEUser' --password 'Passw0rd!' -- /t 5 /s /f"
    check skip $? "Could not shut down for removal"
}

# Remove the given Machine from VBox and delete all associated files. Shut down the VM beforehand, if needed.
delete_vm() {
    log "Removing ${remove_vm}..."
    if [ ! "$(VBoxManage showvminfo "${remove_vm}" | grep -q 'running')" ]; then
        shutdown_vm_for_removal
        waiting 30
    fi
    execute "VBoxManage unregistervm '${remove_vm}' --delete"
    check skip $? "Could not remove VM ${remove_vm}"
    waiting 10
}

# Change the Hostname of the VM; Avoids duplicate Names on the Network in case you set up several instances of the same Appliance.
# We copy the rename.bat because the VBox exec doesn't provide the needed Parameters in a way wmic.exe is able to apply correctly.
# Also WinXP usually fails to set the name, you can use C:\Temp\rename.bat to set it manually on the VM. Make sure to restart afterwards.
rename_vm() {
    case ${vm_name} in
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
    log "Preparing to change Hostname ${vm_orig_name} to ${vm_pretty_name}..."
    echo 'c:\windows\system32\wbem\wmic.exe computersystem where caption="'${vm_orig_name}'" call rename "'${vm_pretty_name}'"' > "${TEMP_PATH}""${RENAME_FILENAME}"
    check skip $? "Could not create rename.bat"

    log "Copy rename.bat..."
    copyto "${RENAME_FILENAME}" "${TEMP_PATH}" "${VM_TEMP_PATH}"
    check skip $? "Could not copy rename.bat"

    log "Launch rename.bat..."
    execute "VBoxManage guestcontrol '${vm_name}' run --exe '${VM_TEMP_PATH}rename.bat' --username 'IEUser' --password 'Passw0rd!'"
    check skip $? "Could not change Hostname"
    waiting 5
}

configure_clipboard() {
    log "Changing Clipboard-Mode to bidirectional..."
    VBoxManage controlvm "${vm_name}" clipboard bidirectional
    check skip $? "Could not set Clipboard-Mode"
    waiting 5
}

# Check if --delete was given as second parameter to this script. The VM-Name is expected to be the third parameter.
# If no VM-Name is given --delete will be ignored.
if [ "${2}" = "--delete" ]; then
    if [ ! -z "${3}" ]; then
        delete_vm
    else
        log "Delete VM"
        check skip "--delete was given, but no VM, skipping..."
    fi
fi

ex_activate_vm_xp() {
    check skip 0 "Nothing to do..."
}

ex_activate_vm_w7() {
    execute "VBoxManage guestcontrol '${vm_name}' run --exe cmd.exe --username 'IEUser' --password 'Passw0rd!' -- /C slmgr /ato"
    check skip $? "Could not activate Windows"
}

ex_activate_vm_wv() {
    ex_activate_vm_w7
}

ex_activate_vm_w8() {
    ex_activate_vm_w7
}

activate_vm() {
    execute_os_specific ex_activate_vm
}

# Basic install
get_vm_info
import_vm
# Config VM
# |-- Config while off
set_network_config
set_rdp_config
disable_uac
# |-- Config while on
start_vm
create_log_path
create_temp_path
disable_firewall
rename_vm
set_ie_config
# |--- Install dependencies
install_java
install_firefox
# No reliable Chrome installer link found, uncomment if properly configured
# install_chrome
install_selenium
copy_nginx
# Additional steps
configure_clipboard
activate_vm

if [ "${VM_CREATE_SNAPSHOT}" = "True" ]; then
    shutdown_vm "${vm_name}"
    snapshot_vm "Selenium"
    start_vm
else
    reboot_vm
fi
