# Configuration
#  |
#  |Host Machiche
#  |--> Config
log=true
owner="${USER}"
#  |--> Paths/Folders
vms_path="vms/"
log_path="logs/"
tools_path="$(pwd)/tools/"
selenium_path="selenium_conf/"
#  |--> Filenames
nginx_filename="nginx.zip"
deuac_filename="deuac.iso"
chrome_filename="chrome.exe"
firefox_filename="firefox.exe"
java_filename="jre-windows-i586.exe"
selenium_helper_filename="selenium.bat"
ie_driver_filename="IEDriverServer.zip"
selenium_filename="selenium-server-standalone.jar"
#  |----> Registry filenames
ie_cache_reg_filename="ie_disablecache.reg"
ie_protectedmode_reg_filename="ie_protectedmode.reg"
#  |
#  |Remote Resources
#  |--> Dependencies URLs
nginx_url="http://nginx.org/download/nginx-1.8.0.zip"
deuac_url="https://github.com/tka/SeleniumBox/blob/master/deuac.iso?raw=true"
chrome_url="https://dl.google.com/update2/installers/ChromeStandaloneSetup.exe"
firefox_url="https://download.mozilla.org/?product=firefox-34.0.5-SSL&os=win&lang=en-GB"
ie_driver_url="http://selenium-release.storage.googleapis.com/2.44/IEDriverServer_Win32_2.44.0.zip"
selenium_url="http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar"
#  |--> Virtual Machines URLs
#  |-----> Win XP & 7
XP_6_FILENAME="IE6.XP.For.Linux.VirtualBox.zip"
XP_6_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE6/Linux/${XP_6_FILENAME}{.001,.002}"
XP_8_FILENAME="IE8.XP.For.Linux.VirtualBox.zip"
XP_8_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE8/Linux/${XP_8_FILENAME}{.001,.002}"
VISTA_7_FILENAME="IE7.Vista.For.Linux.VirtualBox.zip"
VISTA_7_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE7/Linux/${VISTA_7_FILENAME}{.001,.002,.003,.004,.005}"
#  |-----> Win 7
SEVEN_8_FILENAME="IE8.Win7.For.Linux.VirtualBox.zip"
SEVEN_8_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE8/Linux/${SEVEN_8_FILENAME}{.001,.002,.003,.004}"
SEVEN_9_FILENAME="IE9.Win7.For.Linux.VirtualBox.zip"
SEVEN_9_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE9/Linux/${SEVEN_9_FILENAME}{.001,.002,.003,.004}"
SEVEN_10_FILENAME="IE10.Win7.For.Linux.VirtualBox.zip"
SEVEN_10_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE10/Linux/${SEVEN_10_FILENAME}{.001,.002,.003,.004}"
SEVEN_11_FILENAME="IE11.Win7.For.Linux.VirtualBox.zip"
SEVEN_11_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE11/Linux/${SEVEN_11_FILENAME}{.001,.002,.003,.004}"
#  |-----> Win 8 & 8.1
EIGHT_10_FILENAME="IE10.Win8.For.Linux.VirtualBox.zip"
EIGHT_10_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE10/Linux/${EIGHT_10_FILENAME}{.001,.002,.003,.004,.005,.006,.007}"
EIGHT_ONE_11_FILENAME="IE11.Win8.1.For.Linux.VirtualBox.zip"
EIGHT_ONE_11_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE11/Linux/${EIGHT_ONE_11_FILENAME}{.001,.002,.003,.004,.005,.006}"
#  |-----> Win 10
TEN_EDGE_FILENAME="Microsoft%20Edge.Win10.For.Linux.VirtualBox.zip"
TEN_EDGE_URL="http://az792536.vo.msecnd.net/vms/VMBuild_20150801/VirtualBox/MSEdge/Linux/${TEN_EDGE_FILENAME}{.001,.002,.003,.004,.005,.006}"
#  |
#  |Guest Machine
#  |--> Config
vm_mem="1024"
vm_mem_xp="512"
vm_nic_bridge="eth0"
vm_create_snapshot=False
#  |--> Paths
vm_temp_path="C:/Temp/"