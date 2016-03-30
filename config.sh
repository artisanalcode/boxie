#!/bin/bash

# If using shellcheck add -e SC2034 to disable rule SC2034.

# Configuration
#  |
#  |Host Machiche
#  |--> Config
OWNER="${USER}"
#  |--> Paths/Folders
VMS_PATH="vms/"
LOG_PATH="logs/"
TOOLS_PATH="$(pwd)/tools/"
SELENIUM_PATH="selenium_conf/"
#  |--> Filenames
NGINX_FILENAME="nginx.zip"
DEUAC_FILENAME="deuac.iso"
CHROME_FILENAME="chrome.exe"
FIREFOX_FILENAME="firefox.exe"
JAVA_FILENAME="jre-windows-i586.exe"
SELENIUM_HELPER_FILENAME="selenium.bat"
IE_DRIVER_FILENAME="IEDriverServer.zip"
SELENIUM_FILENAME="selenium-server-standalone.jar"
#  |----> Registry filenames
IE_CACHE_REG_FILENAME="ie_disablecache.reg"
IE_PROTECTEDMODE_REG_FILENAME="ie_protectedmode.reg"
#  |
#  |Remote Resources
#  |--> Dependencies URLs
NGINX_URL="http://nginx.org/download/nginx-1.8.0.zip"
DEUAC_URL="https://github.com/tka/SeleniumBox/blob/master/deuac.iso?raw=true"
CHROME_URL="https://dl.google.com/update2/installers/ChromeStandaloneSetup.exe"
FIREFOX_URL="https://download.mozilla.org/?product=firefox-34.0.5-SSL&os=win&lang=en-GB"
IE_DRIVER_URL="http://selenium-release.storage.googleapis.com/2.44/IEDriverServer_Win32_2.44.0.zip"
SELENIUM_URL="http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar"
#  |--> Virtual Machines URLs
#  |-----> Win XP & 7
#  |--------> FOR LINUX
LINUX_XP_6_FILENAME="IE6.XP.For.Linux.VirtualBox.zip"
LINUX_XP_6_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE6/Linux/${LINUX_XP_6_FILENAME}{.001,.002}"
LINUX_XP_8_FILENAME="IE8.XP.For.Linux.VirtualBox.zip"
LINUX_XP_8_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE8/Linux/${LINUX_XP_8_FILENAME}{.001,.002}"
LINUX_VISTA_7_FILENAME="IE7.Vista.For.Linux.VirtualBox.zip"
LINUX_VISTA_7_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE7/Linux/${LINUX_VISTA_7_FILENAME}{.001,.002,.003,.004,.005}"
#  |--------> FOR MAC OSX
OSX_XP_6_FILENAME="IE6.XP.For.Windows.VirtualBox.zip"
OSX_XP_6_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE6/Windows/${OSX_XP_6_FILENAME}{.001,.002}"
OSX_XP_8_FILENAME="IE8.XP.For.Windows.VirtualBox.zip"
OSX_XP_8_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE8/Windows/${OSX_XP_8_FILENAME}{.001,.002}"
OSX_VISTA_7_FILENAME="IE7.Vista.For.Windows.VirtualBox.zip"
OSX_VISTA_7_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE7/Windows/${OSX_VISTA_7_FILENAME}{.001,.002,.003,.004,.005}"
#  |-----> Win 7
#  |--------> FOR LINUX
LINUX_SEVEN_8_FILENAME="IE8.Win7.For.Linux.VirtualBox.zip"
LINUX_SEVEN_8_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE8/Linux/${LINUX_SEVEN_8_FILENAME}{.001,.002,.003,.004}"
LINUX_SEVEN_9_FILENAME="IE9.Win7.For.Linux.VirtualBox.zip"
LINUX_SEVEN_9_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE9/Linux/${LINUX_SEVEN_9_FILENAME}{.001,.002,.003,.004}"
LINUX_SEVEN_10_FILENAME="IE10.Win7.For.Linux.VirtualBox.zip"
LINUX_SEVEN_10_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE10/Linux/${LINUX_SEVEN_10_FILENAME}{.001,.002,.003,.004}"
LINUX_SEVEN_11_FILENAME="IE11.Win7.For.Linux.VirtualBox.zip"
LINUX_SEVEN_11_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE11/Linux/${LINUX_SEVEN_11_FILENAME}{.001,.002,.003,.004}"
#  |--------> FOR MAC
OSX_SEVEN_8_FILENAME="IE8.Win7.For.Windows.VirtualBox.zip"
OSX_SEVEN_8_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE8/Windows/${OSX_SEVEN_8_FILENAME}{.001,.002,.003,.004}"
OSX_SEVEN_9_FILENAME="IE9.Win7.For.Windows.VirtualBox.zip"
OSX_SEVEN_9_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE9/Windows/${OSX_SEVEN_9_FILENAME}{.001,.002,.003,.004}"
OSX_SEVEN_10_FILENAME="IE10.Win7.For.Windows.VirtualBox.zip"
OSX_="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE10/Windows/${OSX_SEVEN_10_FILENAME}{.001,.002,.003,.004}"
OSX_SEVEN_11_FILENAME="IE11.Win7.For.Windows.VirtualBox.zip"
OSX_SEVEN_11_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE11/Windows/${OSX_SEVEN_11_FILENAME}{.001,.002,.003,.004}"
#  |-----> Win 8 & 8.1
#  |--------> FOR LINUX
LINUX_EIGHT_10_FILENAME="IE10.Win8.For.Linux.VirtualBox.zip"
LINUX_EIGHT_10_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE10/Linux/${LINUX_EIGHT_10_FILENAME}{.001,.002,.003,.004,.005,.006,.007}"
LINUX_EIGHT_ONE_11_FILENAME="IE11.Win8.1.For.Linux.VirtualBox.zip"
LINUX_EIGHT_ONE_11_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE11/Linux/${LINUX_EIGHT_ONE_11_FILENAME}{.001,.002,.003,.004,.005,.006}"
#  |--------> FOR MAC
OSX_EIGHT_10_FILENAME="IE10.Win8.For.Windows.VirtualBox.zip"
OSX_EIGHT_10_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE10/Windows/${OSX_EIGHT_10_FILENAME}{.001,.002,.003,.004,.005,.006,.007}"
OSX_EIGHT_ONE_11_FILENAME="IE11.Win8.1.For.Windows.VirtualBox.zip"
OSX_EIGHT_ONE_11_URL="http://virtualization.modern.ie/vhd/VMBuild_20141027/VirtualBox/IE11/Windows/${OSX_EIGHT_ONE_11_FILENAME}{.001,.002,.003,.004,.005,.006}"
#  |-----> Win 10
#  |--------> FOR LINUX
LINUX_TEN_EDGE_FILENAME="Microsoft%20Edge.Win10.For.Linux.VirtualBox.zip"
LINUX_TEN_EDGE_URL="http://az792536.vo.msecnd.net/vms/VMBuild_20150801/VirtualBox/MSEdge/Linux/${LINUX_TEN_EDGE_FILENAME}{.001,.002,.003,.004,.005,.006}"
#  |--------> FOR MAC
OSX_TEN_EDGE_FILENAME="Microsoft%20Edge.Win10.For.Windows.VirtualBox.zip"
OSX_TEN_EDGE_URL="http://az792536.vo.msecnd.net/vms/VMBuild_20150801/VirtualBox/MSEdge/Windows/${OSX_LINUX_TEN_EDGE_FILENAME}{.001,.002,.003,.004,.005,.006}"
#  |
#  |Guest Machine
#  |--> Config
VM_MEM="1024"
VM_MEM_XP="512"
VM_NIC_BRIDGE="eth0"
VM_CREATE_SNAPSHOT=False
#  |--> Paths
VM_TEMP_PATH="C:/Temp/"
