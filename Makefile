all: fetch fetch_vms

fetch: Tools/selenium_conf/selenium-server-standalone.jar Tools/deuac.iso Tools/selenium_conf/IEDriverServer.exe Tools/jre-windows-i586.exe Tools/firefox.exe Tools/chrome.exe

fetch_vms: VMs/IE11\ -\ Win7.ova VMs/IE8\ -\ Win7.ova VMs/IE10\ -\ Win7.ova VMs/IE9\ -\ Win7.ova

VMs/IE11\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?browserOS=IE11-Win7&parts=4&platform=Linux&virtPlatform=virtualbox&filename=VMBuild_20141027/VirtualBox/IE11/Linux/IE11.Win7.For.Linux.VirtualBox.zip{.001,.002,.003,.004}"
	cat IE11.Win7.For.Linux.VirtualBox.* >IE11.Win7.For.Linux.VirtualBox.zip
	unzip IE11.Win7.For.Linux.VirtualBox.zip
	mkdir VMs || true
	mv "$(@F)" VMs
	rm IE11.Win7.For.Linux.VirtualBox.zip IE11.Win7.For.Linux.VirtualBox.zip.001 IE11.Win7.For.Linux.VirtualBox.part2.rar IE11.Win7.For.Linux.VirtualBox.zip.003 IE11.Win7.For.Linux.VirtualBox.zip.004

VMs/IE10\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?browserOS=IE10-Win7&parts=4&platform=Linux&virtPlatform=virtualbox&filename=VMBuild_20141027/VirtualBox/IE10/Linux/IE10.Win7.For.Linux.VirtualBox.zip{.001,.002,.003,.004}"
	cat IE10.Win7.For.Linux.VirtualBox.* >IE10.Win7.For.Linux.VirtualBox.zip
	unzip IE10.Win7.For.Linux.VirtualBox.zip
	mkdir VMs || true
	mv "$(@F)" VMs
	rm IE10.Win7.For.Linux.VirtualBox.zip IE10.Win7.For.Linux.VirtualBox.zip.001 IE10.Win7.For.Linux.VirtualBox.zip.002 IE10.Win7.For.Linux.VirtualBox.zip.003 IE10.Win7.For.Linux.VirtualBox.zip.004

VMs/IE9\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?browserOS=IE9-Win7&parts=4&platform=Linux&virtPlatform=virtualbox&filename=VMBuild_20141027/VirtualBox/IE9/Linux/IE9.Win7.For.Linux.VirtualBox.zip{.001,.002,.003,.004}"
	cat IE9.Win7.For.Linux.VirtualBox.* >IE9.Win7.For.Linux.VirtualBox.zip
	unzip IE9.Win7.For.Linux.VirtualBox.zip
	mkdir VMs || true
	mv "$(@F)" VMs
	rm IE9.Win7.For.Linux.VirtualBox.zip IE9.Win7.For.Linux.VirtualBox.zip.001 IE9.Win7.For.Linux.VirtualBox.zip.002 IE9.Win7.For.Linux.VirtualBox.zip.003 IE9.Win7.For.Linux.VirtualBox.zip.004

VMs/IE8\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?browserOS=IE8-Win7&parts=4&platform=Linux&virtPlatform=virtualbox&filename=VMBuild_20141027/VirtualBox/IE8/Linux/IE8.Win7.For.Linux.VirtualBox.zip{.001,.002,.003,.004}"
	cat IE8.Win7.For.Linux.VirtualBox.* >IE8.Win7.For.Linux.VirtualBox.zip
	unzip IE8.Win7.For.Linux.VirtualBox.zip
	mkdir VMs || true
	mv "$(@F)" VMs
	rm IE8.Win7.For.Linux.VirtualBox.zip IE8.Win7.For.Linux.VirtualBox.zip.001 IE8.Win7.For.Linux.VirtualBox.zip.002 IE8.Win7.For.Linux.VirtualBox.zip.003 IE8.Win7.For.Linux.VirtualBox.zip.004

Tools/selenium_conf/selenium-server-standalone.jar:
	curl -o Tools/selenium_conf/selenium-server-standalone.jar -L http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar

Tools/deuac.iso:
	curl -o Tools/deuac.iso -L https://github.com/tka/SeleniumBox/blob/master/deuac.iso?raw=true

Tools/selenium_conf/IEDriverServer.exe:
	curl -o Tools/selenium_conf/IEDriverServer.zip -L http://selenium-release.storage.googleapis.com/2.44/IEDriverServer_Win32_2.44.0.zip
	cd Tools/selenium_conf && unzip IEDriverServer.zip

Tools/jre-windows-i586.exe:
	curl -j -o Tools/jre-windows-i586.exe -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u75-b13/jre-7u75-windows-i586.exe

Tools/firefox.exe:
	curl -o $@ -L "https://download.mozilla.org/?product=firefox-34.0.5-SSL&os=win&lang=en-GB"

Tools/chrome.exe:
	curl -o $@ -L "https://dl.google.com/update2/installers/ChromeStandaloneSetup.exe"