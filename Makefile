all: fetch fetch_vms

fetch: tools/selenium_conf/selenium-server-standalone.jar tools/deuac.iso tools/selenium_conf/IEDriverServer.exe tools/selenium_conf/chromedrive.exe tools/jre-windows-i586.exe tools/firefox.exe tools/chrome.exe

fetch_vms:  vms/IE11\ -\ Win7.ova  vms/IE8\ -\ Win7.ova  vms/IE10\ -\ Win7.ova  vms/IE9\ -\ Win7.ova

 vms/IE11\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?browserOS=IE11-Win7&parts=4&platform=Linux&virtPlatform=virtualbox&filename=VMBuild_20141027/VirtualBox/IE11/Linux/IE11.Win7.For.Linux.VirtualBox.zip{.001,.002,.003,.004}"
	cat IE11.Win7.For.Linux.VirtualBox.* >IE11.Win7.For.Linux.VirtualBox.zip
	unzip IE11.Win7.For.Linux.VirtualBox.zip
	mkdir vms || true
	mv "$(@F)" vms
	rm IE11.Win7.For.Linux.VirtualBox.zip IE11.Win7.For.Linux.VirtualBox.zip.001 IE11.Win7.For.Linux.VirtualBox.part2.rar IE11.Win7.For.Linux.VirtualBox.zip.003 IE11.Win7.For.Linux.VirtualBox.zip.004

 vms/IE10\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?browserOS=IE10-Win7&parts=4&platform=Linux&virtPlatform=virtualbox&filename=VMBuild_20141027/VirtualBox/IE10/Linux/IE10.Win7.For.Linux.VirtualBox.zip{.001,.002,.003,.004}"
	cat IE10.Win7.For.Linux.VirtualBox.* >IE10.Win7.For.Linux.VirtualBox.zip
	unzip IE10.Win7.For.Linux.VirtualBox.zip
	mkdir vms || true
	mv "$(@F)" vms
	rm IE10.Win7.For.Linux.VirtualBox.zip IE10.Win7.For.Linux.VirtualBox.zip.001 IE10.Win7.For.Linux.VirtualBox.zip.002 IE10.Win7.For.Linux.VirtualBox.zip.003 IE10.Win7.For.Linux.VirtualBox.zip.004

 vms/IE9\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?browserOS=IE9-Win7&parts=4&platform=Linux&virtPlatform=virtualbox&filename=VMBuild_20141027/VirtualBox/IE9/Linux/IE9.Win7.For.Linux.VirtualBox.zip{.001,.002,.003,.004}"
	cat IE9.Win7.For.Linux.VirtualBox.* >IE9.Win7.For.Linux.VirtualBox.zip
	unzip IE9.Win7.For.Linux.VirtualBox.zip
	mkdir vms || true
	mv "$(@F)" vms
	rm IE9.Win7.For.Linux.VirtualBox.zip IE9.Win7.For.Linux.VirtualBox.zip.001 IE9.Win7.For.Linux.VirtualBox.zip.002 IE9.Win7.For.Linux.VirtualBox.zip.003 IE9.Win7.For.Linux.VirtualBox.zip.004

 vms/IE8\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?browserOS=IE8-Win7&parts=4&platform=Linux&virtPlatform=virtualbox&filename=VMBuild_20141027/VirtualBox/IE8/Linux/IE8.Win7.For.Linux.VirtualBox.zip{.001,.002,.003,.004}"
	cat IE8.Win7.For.Linux.VirtualBox.* >IE8.Win7.For.Linux.VirtualBox.zip
	unzip IE8.Win7.For.Linux.VirtualBox.zip
	mkdir vms || true
	mv "$(@F)" vms
	rm IE8.Win7.For.Linux.VirtualBox.zip IE8.Win7.For.Linux.VirtualBox.zip.001 IE8.Win7.For.Linux.VirtualBox.zip.002 IE8.Win7.For.Linux.VirtualBox.zip.003 IE8.Win7.For.Linux.VirtualBox.zip.004

tools/selenium_conf/selenium-server-standalone.jar:
	curl -o tools/selenium_conf/selenium-server-standalone.jar -L http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar

tools/deuac.iso:
	curl -o tools/deuac.iso -L https://github.com/tka/SeleniumBox/blob/master/deuac.iso?raw=true

tools/selenium_conf/IEDriverServer.exe:
	curl -o tools/selenium_conf/IEDriverServer.zip -L http://selenium-release.storage.googleapis.com/2.44/IEDriverServer_Win32_2.44.0.zip
	cd tools/selenium_conf && unzip IEDriverServer.zip

tools/selenium_conf/chromedrive.exe:
	curl -o tools/selenium_conf/chromedriver.zip -L http://chromedriver.storage.googleapis.com/2.15/chromedriver_win32.zip
	cd tools/selenium_conf && unzip chromedriver.zip

tools/jre-windows-i586.exe:
	curl -j -o tools/jre-windows-i586.exe -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u75-b13/jre-7u75-windows-i586.exe

tools/firefox.exe:
	curl -o $@ -L "https://download.mozilla.org/?product=firefox-34.0.5-SSL&os=win&lang=en-GB"

tools/chrome.exe:
	curl -o $@ -L "https://dl.google.com/update2/installers/ChromeStandaloneSetup.exe"