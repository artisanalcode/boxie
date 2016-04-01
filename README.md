BoxIE (pronounced bok-see)
=======================

BoxIE(pronounced "bok-see", sort-of like Clippy!) automate the installation of Modern IE virtual boxes and Selenium support.

This series of scripts allows you to download, install and setup virtual Windows machines using images provided by Microsoft (http://modern.ie/tools/vms). Since these images "expire" every few months it is very practical to automate the download, installation and configuration.

BoxIE (pronounced bok-see) is a fork of modernie_selenium. It focuses on multi-environment support (Linux and Mac OS), friendly UI (as much as possible for a shell script). And adds a cute mascot.

Requirements
=================

  * VirtualBox (tested with 5.0.16 on Mac OS X).


What it does
=================

  * Downloads virtual machines from MS Modern.IE
  * Downloads  dependencies (Selenium and Selenium Drivers, Deuac, etc.).
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
  * Installs Selenium drivers on virtual machine.

:warning: A bug on Virtual Box prevents the `create.sh` script from successfully installing dependencies on the virtual machine. We will update as soon as a fix is available. 

What will be installed in the virtual machine
=================

  * Selenium Standalone Server.
  * Deuac.iso (User Account Control disabler).
  * IEDriverServer (for Selenium).
  * Chrome.
  * Chromedriver (for Selenium).
  * Java JRE (for Selenium).
  * Firefox.
  * Nginx (only copied to machine, must install manually).
  
  
To do
==================

  * Refactor `hosts.sh` script.
  * Improve UI/UX for `create.sh` script.
  * Create "unifying" script to call create right after fetch.

Getting started
===============

  * Install and configure Virtual Box.
  * Clone this repository.
  * Run ```./fetch.sh -v -d``` to fetch virtual machine images.
  * Run ```create.sh /path/to/your/appliance/foobar.ova``` to auto-configure/install dependencies.

Fetching the Appliances
=======================

If you only want to get virtual machine images:

```
./fetch.sh -v
```

The script will detect your OS (Mac OS X or Linux).

Configure
=========

Adjust ```config.sh``` to your needs. There are already default settings and the names are pretty self explanatory.



Known Problems
==============

Issues with `VBoxManage guestcontrol copyto` prevent the create script from properly installing dependencies. The bug is acknowledged by VirtualBox team. As soon as a fix is available we will update documentation.

XP-Machines don't set their new hostname automatically. You can use ```C:\Temp\rename.bat``` to set the correct name. Restart the virtual machine afterwards. This is only needed if you run more than one instance of the same appliance.


Acknowledgements
================
Thanks to @bernhard-appdirect for the digital version(`.ai`) of the BoxIE mascot.


Legacy
================
BoxIE is a fork of the original project [modernie_selenium](https://github.com/conceptsandtraining/modernie_selenium) this content is from their original README.md.

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