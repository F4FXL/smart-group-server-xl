smart-group-server-xl
==================

## Our Vision
To provide Smart Groups on every ircddb based network in order to offer a continuous experience to radio users.

## Introduction

The original smart-group-server is based from G4KLX's original Starnet software by N7TAE. While it was written expressly for the Quadnet ircddb network this fork aims to provide an ircddb network agnostic smart group server. Since there are still dozens of repeaters out there not running on Quadnet but only on ircddb.net our vision is to offer a software allowing groups to ba avaialble from every network. Users should not be impaired by a balkanized system.

** Original text from N7TAE **
>“This smart-group-server is based on an original idea by John Hays K7VE for a routing group server he called **STARnet Digital**. This idea was first coded by Jonathan G4KLX and he called the resulting program **StarNetServer**. The smart-group-server is derrived from Jonathan's code and still contains his original copyrights and GPLV#2 license. This new implementation of a group routing server has many improvements and new features compared to its predecessor. The main features for the end-user is that Smart Groups allow a user to "listen first" before transmitting and also be able to see the status of the Smart Groups and users. The smart-group-server can now also handle connections from mobile clients (hotspots that get their internet connection from a cellphone). The most useful feature for provider is that a single smart-group-server can serve both DCS- **and** DExtra-linked groups and only the required UDP ports are created. In addtion, by using the remote control application, Smart Groups can be unlinked and linked dynamically, freeing and reallocating resources as required."


## Server OS Requirements

The smart-group-server requires a modern OS to compile and run. At least Debian 8 or Ubuntu 16.10, or equivilent. The command
```
g++ --version
```
must return at least Version 4.9. The latest Debian and Ubuntu will be far above this. Unlike the StarNetServer, smart-group-server does not use wxWidgits. Modern C++ calls to the standard library (c++11 standard) are used instead of wxWidgets: std::string replaces wxString, std::future replaces wxThreads and standard std::map, std::list, std::queue and std::vector replace the older wx containers. The only external library used is libconfig++. The smart-group-server is significantly improved regarding resource utiliztion compared to the ancestral StarNetServer. The smart-group-server only creates resources for the channel you define in your configuration file. Also, there is no theoretical limit to the number of channels you can create. Of course there is a practical limit based on the underlying hardware.

The smart-group-server is installed as a systemd service. If you want to run this on a system without systemd, you are on your own. I am done dealing with init.d scripts in SysVInit!

## Adminstrative Requirements

This Smart Group Server should have a unique IP address when it logs into QuadNet. That means you probably won't be able to run it from your home if you also have an ircddb gateway running from home. You probably shouldn't run it from your home anyway. The computer your Smart Group Server is running on should have reliable, 24/7 internet access and reliable, 24/7 power. It should also be properly protected from hackers. There are plenty of companies that provide virtual severs that easily fulfill these requirements for verly little money. (You don't need much horse-power for a typical Smart Group Server. For example, a $5/month server on Amazon Lightsail works fine.)

Also the Smart Group Server needs to have a unique callsign in QuadNet, one that will not be used by another client on QuadNet. Ideally, you should use a Club callsign, see the Configuring section below.

## Building

These instructions are for a Debian-based OS. Begin by downloading this git repository:
```
git clone git://github.com/n7tae/smart-group-server.git
```
Install the only needed development library:
```
sudo apt-get install libconfig++-dev
```
Change to the smart-group-server directory and type `make`. This should make the executable, `sgs` without errors or warnings. By default, you will have a group server that can link groups to X-Reflectors or DCS-Reflectors. Of course you can declare an unlinked channel by simply not defining a *reflector* parameter for that channel.

## Configuring

Before you install the group server, you need to create a configuration file called `sgs.cfg`. There is an example configuration file: `example.cfg`. The smart-group-server supports an unlimited number of channels. However there will be a practical limit based on you hardware capability. Also remember that a unique port is created for each DExtra or DCS link on a running smart-group-server. At some point you system will simply run out of connections. Be sure you look and the "StarNet Groups" tab on the openquad.net web page to be sure your new channel callsigns and logoff callsigns are not already in use! Each channel you define requires a band letter. Bands can be shared between channels. Choose any uppercase letter from 'A' to 'Z'. Each channel will have a group logon callsign and a group logoff callsign. The logon and logoff will differ only in the last letter of the callsign. PLEASE DON'T CHOOSE a channel callsign beginning in "REF", "XRF", "XLX", "DCS" or "CCS". While it is possible, it's really confusing for new-comers on QuadNet. Also, avoid subscribe and unsubscribe callsigns that end in "U". Jonathan's ircddbgateway will interpret this as an unlink command and never send it to the smart-group-server.

Your callsign parameter in the ircddb section of your configuration file is the callsign that will be used for logging into QuadNet. THIS NEEDS TO BE A UNIQUE CALLSIGN on QuadNet. Don't use your callsign if you are already using it for a repeater or a hot-spot. Ideally, you should use a Club callsign. Check with your club to see if you can use your club's callsign. Of course, don't do this if your club hosts a D-Star repeater with this callsign. If your club callsign is not available, either apply to be a trustee for a new callsign from you club, or get together with three of your friends and start a club. All the information you need is at arrl.org or w5yi.org. It's not difficult to do, and once you file your application, you'll get your new Club Callsign very quickly.

## Installing and Uninstalling

To install and start the smart-group-server, first type `make newhostfiles`. This will download the latest DCS and DExtra host files and install them. (This command downloads the files to the build directory and then moves them to /usr/local/etc with `sudo`, so it may prompt you for your password.) Then type `sudo make install`. This will put all the executable and the sgs.cfg configuration file the in /usr/local and then start the server. See the Makefile for more information. A very useful way to start it is:
```
sudo make install && sudo journalctl -u sgs.service -f
```
This will allow you to view the smart-group-server log file while it's booting up. When you are satisfied it's running okay you can Control-C to end the journalctl session. To uninstall it, type `sudo make uninstall` and `sudo make removehostfiles`. This will stop the server and remove all files from /usr/local. You can then delete the build directory to remove every trace of the smart-group-server.

73

Tom
n7tae (at) arrl (dot) net
