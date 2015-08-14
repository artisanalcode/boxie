# Configuration
#  |
#  |Host Machiche
#  |--> Config
owner="${USER}"
log=true
#  |--> Paths/Folders
vms_path="vms/"
log_path="logs/"
tools_path="$(pwd)/tools/"
selenium_path="selenium_conf/"
#  |--> Filenames
deuac_filename="deuac.iso"
chrome_filename="chrome.exe"
firefox_filename="firefox.exe"
nginx_filename="nginx.zip"
java_filename="jre-windows-i586.exe"
selenium_filename="selenium-server-standalone.jar"
selenium_helper_filename="selenium.bat"
ie_driver_filename="IEDriverServer.zip"
#  |----> Registry filenames
ie_cache_reg_filename="ie_disablecache.reg"
ie_protectedmode_reg_filename="ie_protectedmode.reg"
#  |
#  |Remote Resources
#  |--> URLs
deuac_url="https://github.com/tka/SeleniumBox/blob/master/deuac.iso?raw=true"
selenium_url="http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar"
ie_driver_url="http://selenium-release.storage.googleapis.com/2.44/IEDriverServer_Win32_2.44.0.zip"
firefox_url="https://download.mozilla.org/?product=firefox-34.0.5-SSL&os=win&lang=en-GB"
chrome_url="https://dl.google.com/update2/installers/ChromeStandaloneSetup.exe"
nginx_url="http://nginx.org/download/nginx-1.8.0.zip"
#  |
#  |Guest Machine
#  |--> Config
vm_mem="1024"
vm_mem_xp="512"
vm_nic_bridge="eth0"
vm_create_snapshot=False
#  |--> Paths
temp_path="C:/Temp/"