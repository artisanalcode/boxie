# Configuration
#  |
#  | Host machiche
owner="${USER}"
#  |--> Paths/Folders
vms_path="vms/"
log_path="logs/"
tools_path="$(pwd)/tools/"
selenium_path="selenium_conf/"
#  | --> Filenames
deuac_filename="deuac.iso"
chrome_filename="chrome.exe"
firefox_filename="firefox.exe"
nginx_filename="nginx.zip"
java_filename="jre-windows-i586.exe"
selenium_filename="selenium-server-standalone.jar"
# | ---> Registry filenames
ie_cache_reg="ie_disablecache.reg"
ie_protectedmode_reg="ie_protectedmode.reg"

#  |
#  | Guest machine
#  |--> Config
vm_mem="1024"
vm_mem_xp="512"
vm_nic_bridge="eth0"
vm_create_snapshot=False
#  |--> Paths
temp_path="C:/Temp/"