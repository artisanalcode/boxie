BoxIE (pronounced bok-see)
=======================

BoxIE(pronounced "bok-see", sort-of like Clippy!) Automate the installation of Modern IE virtual boxes and Selenium support.

This series of scripts allows you to download, install and setup virtual Windows machines using images provided by Microsoft (http://modern.ie/tools/vms). Since these images "expire" every few months it is very practical to automate the download, installation and configuration.

BoxIE (pronounced bok-see) is a fork of modernie_selenium. It focuses on Linux environment (vs. Mac OS), simplifies and reduces the scope of the project, and adds a cute mascot.

Requirements
=================

  * VirtualBox (tested with 4.3 on Ubuntu)
  * VirtualBox Extension Pack

What will be installed in the virtual machine
=================

  * Selenium Standalone Server.
  * Deuac.iso (User Account Control disabler).
  * IEDriverServer (for Selenium).
  * Chrome.
  * Chromedriver (for Selenium).
  * Java JRE (for Selenium).

What it does
=================

  * Downloads  necessary tools (Selenium and Selenium Drivers, Deuac, etc.).
  * Imports Modern.ie appliances into Virtual Box.
  * Configures virtual machine network settings.
  * Configures virtual machine RDP port setting (VRDE).
  * Configures virtual machine clipboard behavior.
  * Disables UAC(User Account Control).
  * Disables virtual machine firewall.
  * Renames the virtual machine (hostname).
  * Configures IE protected-mode (to work with Selenium).
  * Disables IE cache in virtual machine.
  * Installs  Java in virtual machine.
  * Installs Firefox in virtual machine.
  * Installs Chrome in virtual machine.
  * Installs Selenium virtual machine.

To do
==================

  * Create script to download and install Virtual Box.
  * Automatize Virtual Box configuration.
  * Parameterize virtual box download URLs.
  *  Refactor ```Makefile``` into Bash script.

Getting started
===============

  * Install and configure Virtual Box.
  * Clone this repository.
  * Fetch virtual machine images:  ```make fetch_vms```
  * Fetch other dependencies: ```make fetch```
  * Edit the Selenium Config-Files (```./tools/Selenium_conf/*/config.json```).
  * Edit ```config.sh``` (see below for details).
  * Run ```create.sh /path/to/your/appliance/foobar.ova```.

Fetching the Appliances
=======================

You can get virtual machines directly from Microsoft (this script is configured for IE8-11 on Windows 7) using this command:

```
make fetch_vms
```

Please note: The ```Makefile``` will fetch Windows/IE virtual machine images for Linux.

Configure
=========

Adjust ```config.sh``` to your needs.

If you use the Makefile to get the binary files then you shouldn't have to alter the config script.

By default the script assumes that your VirtualBox-Machines are placed in ```vms/``` and that the script is run by the User the script is run as. All supplemental files should be placed in ```tools/``` .

These are the configuration settings:

Filename of your Java installer.

```
java_exe="jre-windows-i586.exe"
```

Filename of your Selenium server.

```
selenium_jar="selenium-server-standalone.jar"
```

Name of your network interface (to use as bridge for your virtual machine).

```
nic_bridge="eth0"
```

Path for your virtual machines.

```
vm_path="vms/"
```

Memory (RAM) for Windows Vista, 7 and 8.x virtual machines, in MB.

```
vm_mem="768"
```

Memory (RAM) for Windows XP virtual machines, in MB.

```
vm_mem_xp="512"
```

Filename for deuac.iso (UAC disabler).

```
deuac_iso="deuac.iso"
```

Path to tools folder (dependencies to install, scripts, helpers, etc.)

```
TOOLS_PATH="tools/"
```

Path to your Selenium config files (relative to tools). It's important that you keep the folder structure below this point, otherwise the config will not be copied to the virtual machines.

```
SELENIUM_PATH="selenium_conf/"
```

Filename for ```ie_disablecache.reg``` (Disables Internet Explorer Cache).

```
ie_cache_reg="ie_disablecache.reg"
```

Filename for ```ie_protectedmode.reg``` (Enables Protected Mode for all IE Security Zones).

```
ie_protectedmode_reg="Tools/ie_protectedmode.reg"
```

Path to the temporary log files.

```
LOG_PATH="/logs"
```

Username of Virtual Box user.

```
vbox_user="${USER}"
```

Create a snapshot after all changes are made.

```
create_snapshot=False
```

Usage
=====

To fetch the virtual machine image for a Windows 7, Internet Explorer 10 combo:

```
make vms/IE10\ -\ Win7.ova
```

To fetch all other dependencies:

```
make fetch
```

To import the IE10-Win7 Appliance simply run (notice spaces have been escaped):

```
create.sh vms/IE10\ -\ Win7.ova
```

If you already have an IE10-Win7 instance (must be running),  and want to recreate it, run:

```
create.sh VMs/IE10\ -\ Win7.ova --delete "IE10 - Win7"
```

Notice the spaces escaped for path, and quotes for virtual machine name.

Additionally, you can set a ```hosts``` file on your Windows guest to point ```localhost``` (on the guest) to your host's IP. Beware of the issues this might cause.

```
updateip.sh vms/IE10\ -\ Win7.ova
```

We recommend creating a cronjob or other automatization script to recreate virtual machines before their expiration.

Known Problems
==============

XP-Machines don't set their new hostname automatically. You can use ```C:\Temp\rename.bat``` to set the correct name. Restart the virtual machine afterwards. This is only needed if you run more than one instance of the same appliance.



From modernie_selenium's README.md
================

###In the Spotlight###
Thanks a lot for mentioning modernie_selenium!
  * Automated Testing by Ben Emmons<br>
    http://itsummit.arizona.edu/sites/default/files/2014/emmons-ben-automated-testing-final.pdf
  * Testen von Rich-Web-UI (German) by Mark Michaelis<br>
    http://de.slideshare.net/MarkMichaelis2/sokahh-testing
  * DailyJS introduction<br>
    http://dailyjs.com/2015/01/13/testharness-call-modern/
  * Japanese JavaScript Blog<br>
    http://jser.info/2015/01/13/6to5-jspm-refactoring-javascript/

###Acknowledgements###
  * deuac.iso comes from https://github.com/tka/SeleniumBox
  * Inspired by https://github.com/xdissent/ievms
  * http://modern.ie is a Service offered by Microsoft, so thanks for that.
  * Thanks to [@dsuckau](https://github.com/dsuckau) for the Selenium-Config Part
  * Thanks to [@tobyontour](https://github.com/tobyontour) for [pull request #8](https://github.com/conceptsandtraining/modernie_selenium/pull/8)