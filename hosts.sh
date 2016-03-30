#!/bin/bash
source config.sh

# Init; Do not change.
appliance=${1}
vm_name=False
vm_pretty_name=False
fatal=False
error=False
warning=False

# Get informations about the given Appliance (Name, OS-Type, IE-Version)
get_vm_info() {
  vm_info=$(VBoxManage import "${appliance}" -n)
  chk fatal $? "Error getting Appliance Info"

  vm_name=$(echo "${vm_info}" | grep "Suggested VM name" | awk -F'"' '{print $2}')
  vm_pretty_name=$(echo "${vm_info}" | grep "Suggested VM name" | awk -F'"' '{print $2}' | sed 's/_/-/g' | sed 's/ //g' | sed 's/\.//g')
  vm_os_type=$(echo "${vm_info}" | grep 'Suggested OS type' | awk -F'"' '{print $2}')
  vm_ie=$(echo "${vm_name}" | awk -F' -' '{print $1}')
}

copyto() {
  # $1 = filename, $2 = source directory, $3 destination directory
  if [ ! -f "${2}${1}" ]
  then
    echo "Local file '${2}${1}' doesn't exist"
  fi
  execute "VBoxManage guestcontrol '${vm_name}' copyto '${2}${1}' '${3}${1}' --username 'IEUser' --password 'Passw0rd!'"
}

# Error-Handling.
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

# Write Logfile and STDOUT.
log() {
  echo ${1} | tee -a "${LOG_PATH}${vm_pretty_name}.log"
}

get_vm_info

# Create a hosts file
ifconfig ${nic_bridge} | grep "inet " | awk '{print $2 " localhost"}' | sed 's/addr://' > /tmp/hosts

# Send it to the VM
copyto hosts /tmp/ "C:/Windows/System32/drivers/etc/hosts"