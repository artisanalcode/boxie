#!/bin/bash
# Required: bash, curl
#
# Usage examples:
# Will fetch dependencies(including ModernIE Windows machines) to setup a Windows virtual machine (Virtual Box) for testing with Selenium.
#
# Example:
# fetch.sh -a

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

# Print proper usage
usage() {
    echo "Usage:"
    echo "fetch.sh <-v|--virtual-machines> <-d|--dependencies> <-l|--log>"
}

# Print help
help() {
    echo "Looks like you are trying to fetch dependencies to setup a Windows virtual machine (Virtual Box)"
    echo "for testing with Selenium."
    echo "Would you like help?"
    echo ""
    usage
    echo ""
    echo "Arguments:"
    echo "-v|--virtual-machine        Will download chosen virtual machine."
    echo "-d|--dependencies           Will download all dependencies, excluding virtual machines."
    echo "-l|--log                    Optional. Save results in a log file."
    echo ""
    echo "Example"
    echo "fetch.sh -v -a -l"
    echo ""
}

# Global variables
# -- Colors
# -- @see https://en.wikipedia.org/wiki/ANSI_escape_code
RED="\033[0;31m"
CYAN="\033[0;36m"
NOCOLOR="\033[0m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
MAGENTA="\033[0;35m"
# -- Logs
date_prefix=$(date +%Y%m%d%H%M%S)
# -- Options
log_enabled=false


# Write Logfile and STDOUT.
log() {
    if [ "$log_enabled" = true ];
    then
        echo ${1} | tee -a "${log_path}fetch.${date_prefix}.log"
    fi
}

# Fetch dependencies
fetch() {
    # ${1} dest filename, ${2} dest folder, ${3} fetch url
    log "Will fetch ${1} from ${3}"
    echo -e "Downloading: ${1}"
    curl -# -o "${2}${1}" -L "${3}"
}

fetch_selenium() {
    fetch ${selenium_filename} ${tools_path}${selenium_path} ${selenium_url}
}

fetch_deuac() {
    fetch ${deuac_filename} ${tools_path} ${deuac_url}
}

fetch_web_driver_IE() {
    fetch ${ie_driver_filename} ${tools_path}${selenium_path} ${ie_driver_url}
    unzip ${tools_path}${selenium_path}${ie_driver_filename} -d ${tools_path}${selenium_path}
}

fetch_java() {
    # Need to improve fetch method
    log "Will fetch ${java_filename} from http://download.oracle.com/otn-pub/java/jdk/7u75-b13/"
    echo -e "Downloading: ${java_filename}"
    curl -# -j -o ${tools_path}${java_filename} -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u75-b13/jre-7u75-windows-i586.exe"
}

fetch_firefox() {
    fetch ${firefox_filename} ${tools_path} ${firefox_url}
}

fetch_chrome() {
    fetch ${chrome_filename} ${tools_path} ${chrome_url}
}

fetch_nginx(){
    fetch ${nginx_filename} ${tools_path} ${nginx_url}
    # Will not unzip since VBoxmage won't copy whole folders from host to guest
}

fetch_dependencies() {
    fetch_deuac
    fetch_java
    fetch_selenium
    fetch_web_driver_IE
    fetch_firefox
    fetch_chrome
    fetch_nginx
}

fetch_virtual_machine() {
    # Define variables
    resource=${selected_os}_${select_browser}
    resource_filename=${resource}_FILENAME
    resource_url=${resource}_URL

    mkdir -p "${vms_path}"

    # Will initiate download and concatenate files
    log "Will ${resource} fetch from ${!resource}"

    curl -# -O -L "${!resource_url}"
    cat "${!resource_filename}"* > "${vms_path}${!resource_filename}"
    rm "${!resource_filename}"*
}

# Virtual machine Assistant
select_os() {
    echo -e "Please select a Windows version."
    PS3="Your choice:"
    options=("XP" "Vista" "7" "8" "8.1" "10")

    select opt in "${options[@]}"
    do
        case $opt in
            "${options[0]}" )
                selected_os="XP"
                os_selected=true
                echo -e "Windows XP selected                            ${GREEN}[OK]${NOCOLOR}"
                break
                ;;
            "${options[1]}" )
                selected_os="VISTA"
                os_selected=true
                echo -e "Windows Vista selected                         ${GREEN}[OK]${NOCOLOR}"
                break
                ;;
            "${options[2]}" )
                selected_os="SEVEN"
                os_selected=true
                echo -e "Windows 7 selected                             ${GREEN}[OK]${NOCOLOR}"
                break
                ;;
            "${options[3]}" )
                selected_os="EIGHT"
                os_selected=true
                echo -e "Windows 8 selected                             ${GREEN}[OK]${NOCOLOR}"
                break
                ;;
            "${options[4]}" )
                selected_os="EIGHT_ONE"
                os_selected=true
                echo -e "Windows 8.1 selected                           ${GREEN}[OK]${NOCOLOR}"
                break
                ;;
            "${options[5]}" )
                selected_os="TEN"
                os_selected=true
                echo -e "Windows 10 selected                            ${GREEN}[OK]${NOCOLOR}"
                break
                ;;
            *)
                os_selected=false
                echo -e "Invalid option selected                       ${RED}[ERROR]${NOCOLOR}"
                ;;
        esac
    done
    echo ""
}

# Select a browser for your OS
select_browser() {
    echo "Please select an Internet Explorer/Edge version."
    choices=None

    # Adjust browser selection based on OS version
    if [ "${os_selected}" = true ] && [ "${selected_os}" = "XP" ];then
        options=("6" "8")
        choices=("6" "8")
    elif [ "${os_selected}" = true ] && [ "${selected_os}" = "VISTA" ]; then
        options=("7")
    elif [ "${os_selected}" = true ] && [ "${selected_os}" = "SEVEN" ]; then
        options=("8" "9" "10" "11")
    elif [ "${os_selected}" = true ] && [ "${selected_os}" = "EIGHT" ]; then
        options=("10")
    elif [ "${os_selected}" = true ] && [ "${selected_os}" = "EIGHT_ONE" ]; then
        options=("11")
    elif [ "${os_selected}" = true ] && [ "${selected_os}" = "TEN" ]; then
        options=("EDGE")
    fi

    PS3="Your choice:"

    select opt in "${options[@]}"
    do
        if [[ " ${options[*]} " == *" ${opt} "* ]]; then
            select_browser="${opt}"
            browser_selected=true
            echo -e "Browser selected                               ${GREEN}[OK]${NOCOLOR}"
            break
        else
            browser_selected=false
            echo -e "Invalid option selected                       ${RED}[ERROR]${NOCOLOR}"
        fi

    done

    echo -e "Browser selected                               ${GREEN}[OK]${NOCOLOR}"
    echo ""
}

# Execute getopt.
# @see http://www.bahmanm.com/blogs/command-line-options-how-to-parse-in-bash-using-getopt
ARGS=$(getopt -o vdlh -l "virtual-machine,dependencies,log,help" -n "fetch.sh" -- "$@");

# Feedback on wrong arguments.
if [ $? -ne 0 ]; then
    usage
    exit -1
fi

# Execute eval set for proper format
eval set -- "$ARGS";

# Display title bar
echo -e "${CYAN}BoxIE (pronounced bok-see)"
echo -e "${MAGENTA}=========================="
echo -e "${NOCOLOR}"

# Parse options
while true; do
    case $1 in
        -v|--virtual-machine)
            virtual_machine=true
            echo -e "Will download virtual machine...               ${GREEN}[OK]${NOCOLOR}"
            shift
            ;;
        -d|--dependencies)
            dependencies=true
            echo -e "Will download all dependencies...              ${GREEN}[OK]${NOCOLOR}"
            shift
            ;;
        -l|--log)
            log_enabled=true
            echo -e "Log...                                   ${YELLOW}[DISABLED]${NOCOLOR}"
            shift
            ;;
        -h|--help)
            shift
            help
            exit -1
            ;;
        --)
            shift
            break
            ;;
    esac
done

# Provide feedback if there are are missing arguments, end exit script.
if [ -z "$dependencies" ] && [ -z "$virtual_machine" ]; then
    echo "Please provide missing argument(s)."
    usage
    exit -1
fi

# Virtual machine assistant
if [ "$virtual_machine" = true ]; then
    echo -e "Virtual machine download assistant...     ${GREEN}[STARTED]${NOCOLOR}"
    echo ""
    echo "Looks like you are trying to to download Windows virtual machine (Virtual Box)."
    echo "Would you like help?"
    echo ""

    select_os
    select_browser
fi

# Fetch all dependencies
if [ "$dependencies" = true ]; then
    echo -e "Dependencies download                     ${GREEN}[STARTED]${NOCOLOR}"
    fetch_dependencies
fi

# Fetch selected virtual machine
if [ "$os_selected" = true ] && [ "$browser_selected" = true ];then
    echo -e "Virtual machine download                  ${GREEN}[STARTED]${NOCOLOR}"
    fetch_virtual_machine
fi