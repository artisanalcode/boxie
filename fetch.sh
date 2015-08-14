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
#set -o

# Access configuration variables
source config.sh

# Print proper usage
usage() {
    echo 'Usage: fetch.sh <-a|--all-dependencies>'
}

# Print help
help() {
    echo ''
    echo 'BoxIE'\''s fetch.sh'
    echo ''
    echo 'Looks like you are trying to fetch dependencies to setup a Windows virtual machine (Virtual Box)'
    echo 'for testing with Selenium.'
    echo 'Would you like help?'
    echo ''
    echo 'Usage:'
    echo 'fetch.sh <-a|--all-dependencies>'
    echo ''
    echo 'Arguments:'
    echo '-a|--all-dependencies  Will attempt to download all dependencies, excluding VM. Default: true'
    echo ''
    echo 'Example'
    echo 'fetch.sh -a'
    echo ''
}

date_prefix=$(date +%Y%m%d%H%M%S)

# Write Logfile and STDOUT.
log() {
    echo ${1} | tee -a "${log_path}fetch.${date_prefix}.log"
}

# Fetch dependencies

fetch() {
    # ${1} dest filename, ${2} dest folder, ${3} fetch url
    log "Will fetch ${1} from ${3}"
    curl -o "${2}${1}" -L "${3}"
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
    log "Will fetch ${java_filename}"
    curl -j -o ${tools_path}${java_filename} -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u75-b13/jre-7u75-windows-i586.exe
}

fetch_firefox() {
    fetch {firefox_filename} ${tools_path} ${firefox_url}
}

fetch_chrome() {
    curl -o ${tools_path}${chrome_filename} -L ${chrome_url}
}

fetch_nginx(){
    curl -o ${tools_path}${nginx_filename} -L ${nginx_url}
}

fetch_all() {
    fetch_deuac
    fetch_java
    fetch_selenium
    fetch_web_driver_IE
    fetch_firefox
    fetch_chrome
    fetch_nginx
}

# Execute getopt.
ARGS=$(getopt -o a:h -l "all-dependencies:,help" -n "fetch.sh" -- "$@");

# Feedback on wrong arguments.
if [ $? -ne 0 ];
then
    echo -e "\nInvalid option: -$OPTARG" >&2
    usage
    exit -1
fi
# Execute eval set for proper format
eval set -- "$ARGS";
echo -e '\n'


while true; do
    case $1 in
        -a|--all-dependencies)
            shift
            all_dependencie=true
            echo "Will download all dependencies... [OK]"
            log "Will download all dependencies"
            fetch_all
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
