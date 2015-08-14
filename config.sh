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
deuac_iso="deuac.iso"
chrome_exe="chrome.exe"
firefox_exe="firefox.exe"
nginx_folder="nginx-1.8.0"
java_exe="jre-windows-i586.exe"
ie_cache_reg="ie_disablecache.reg"
ie_protectedmode_reg="ie_protectedmode.reg"
selenium_jar="selenium-server-standalone.jar"
#  |
#  | Guest machine
#  |--> Config
vm_mem="1024"
vm_mem_xp="512"
vm_nic_bridge="eth0"
vm_create_snapshot=False
#  |--> Paths
temp_path="C:/Temp/"