#!/bin/bash
################################################################################
#DO NOT USE THIS SCRIPT  AS IT IS
#exit 1 
#Script for Installation: ODOO 8.0 on Debian 9
# Author: Laurent FRANCOIS
# email: francois.oph@gmail.com
# 
# LibreOffice-Python 2.7 Compatibility Script Author: Holger Brunn (https://gist.github.com/hbrunn/6f4a007a6ff7f75c0f8b)
#------------------------------------------------------------------------------- 
# This script will install ODOO Server on
# clean Ubuntu 14.04 Server
#-------------------------------------------------------------------------------
# File System
# /opt/odoo home of odoo user
#/opt/odoo/odoo7/odoo7-server
#opt/odoo/odoo7/custom/addons
#
#
# First UPDATE
# USAGE:
#
# odoo-install
#
# EXAMPLE:
# ./odoo-install 
#
# 
################################################################################

## --------
## fixed var
## --------
TEMP="/home/lof/tempo"
##openerp
OE_USR="odoo"
OE_HOME="/opt/$OE_USR"
OE_CONFIG="$OE_USR$OE_VERSION-server"

## create ODOO system usr 
## gecos is a comment field for user.
echo -e "\n---- Create ODOO system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USR >> ./install_log

## create log directory
echo -e "\n---- Create Log directory ----"
if [[ -d  /var/log/$OE_USR ]];
	echo -e "\n--- /var/log/$OE_USR exist ---"
	echo -e "--- I remove it ---"
	then sudo rm -rf  /var/log/$OE_USR
fi
echo -e "\n--- Creating /var/log/$OE_USR directory ---"
sudo mkdir /var/log/$OE_USR >> ./install_log
sudo chown $OE_USER:$OE_USR /var/log/$OE_USER



##Enter version for checkout 7.0 for version  7.0 
##8.0 for version 8.0
#OE_VERSION="8.0"
echo -e "\n---Enter the ODOO version you want---"
echo -e "---should be 7 or 8---"
read OE_VERSION
if [ "$OE_VERSION" != "8" ] && [ "$OE_VERSION" != "7" ];
	then 
		echo -e "\n---- you enter $OE_VERSION---"
		echo -e "---- please enter 8 or 7. nothing else----"
		echo -e "---- bye for now. Start again---"
		exit 1
	else
		echo -e "\n---- So let's install V$OE_VERSION.0"
fi

## check internet connection
echo -e "\n--- Check internet connection ---" 
WGET=$(which wget)
$WGET -q --tries=20 --timeout=10 http://www.google.com -O /tmp/google.idx &> /dev/null
if [ ! -s /tmp/google.idx ]
then
    echo "Not Connected..!"
    echo -e "\n--- Fix the internet connection and start again---"
    echo "Exit"
    exit 1
else
    echo "Connected..!"
fi 

## ----------
## install dependencies
## ----------

sudo aptitude update && sudo aptitude full-upgrade -y
sudo apt-get build-dep build-essential -y

## Install SSH
echo -e "\n---- Install SSH Server ----"
echo -e "\n---- This will install client and server openssh ----"
sudo apt-get install ssh -y >> ./install_log

## Install postgresql
echo -e "\n---- Install Postgresql Server"
sudo apt-get install postgresql -y >> ./install_log

## install git
echo -e "\n---- Install git ----"
sudo apt-get install git -y >> ./install_log
echo -e "\n---- Install pip ----"
sudo apt-get install git python-pip -y	>> ./install_log
echo -e "\n---- Actuel pip version ----"
python -m pip --version >> ./install_log
echo -e "\n---- Upgrade pip version ----"
sudo pip install --upgrade pip >> ./install_log
python -m pip --version >> ./install_log


## /opt/odoo/
#			- odoo7-server
#			- odoo7/
#				- custom/addons
# 			- odoo8-server
#			- odoo8
#				- custom/addons
## Install server odoo in /opt/odoo/odoo$OE_VERSION/$OE_USER-server
## install customs addons  in /opt/odoo/odoo$OE_VERSION/custom/addons
echo -e "\n---- Making file system for odoo ---"
if [[ -d $OE_HOME/$OE_USR$OE_VERSION ]]; #/odoo/odooV
then
	echo -e "\n---- Removing =$E_HOME/$OE_USR$OE_VERSION directory ---"
	sudo rm -rf $OE_HOME/$OE_USR$OE_VERSION  >>./install_log
fi 
sudo mkdir -p $OE_HOME/$OE_USR$OE_VERSION/custom/addons/  >> ./install_log


## Installation de aeroo lib
echo -e "\n---- Install aeroo lib ----"
echo -e "\n---- first Install libreoffice and some python libraries ----"
sudo apt-get install -y --force-yes --no-install-recommends libreoffice-common libreoffice-core python3-uno libreoffice-script-provider-python >> ./install_log
sudo apt-get install python-setuptools python-genshi python-cairo python-lxml >> ./install_log

if [[ -d /opt/aeroo ]];
then
	sudo rm -rf /opt/aeroo 
fi 
sudo mkdir /opt/aeroo >> ./install_log
cd /opt/aeroo 
echo -e "--- clonage de aeroolib---"
sudo git clone https://github.com/aeroo/aeroolib.git 
cd /opt/aeroo/aeroolib
echo -e "---- Install aeroolib ---"
sudo python setup.py install 

## --- MAKE AN INIT SCRIPT FOR LIBREOFFICE HEADLESS SERVER---
echo -e "\n--- Make an init script for LibreOffice headless server ---"
cd $TEMP
## The quoted form of "EOF" is important
## it's for not interpreting the $
## else you get the "$1" and "$2" replaced by the name of the script !
## the second EOF do not have to be quoted.
cat > libreoffice.sh << 'EOF'
#!/bin/bash 
# openoffice.org headless server script 
# 
# chkconfig: 2345 80 30 
# description: headless libreoffice server script 
# processname: libreoffice 
# 
# Author: Vic Vijayakumar 
# Modified by Federico Ch. Tomasczik 
# 
# save this file
# move the file to /etc/init.d
#sudo chmod +x /etc/init.d/libreoffice.sh
#sudo chmod 0755 /etc/init.d/openoffice.sh
#sudo update-rc.d libreoffice.sh defaults

OOo_HOME=/usr/bin 
SOFFICE_PATH=$OOo_HOME/libreoffice 
PIDFILE=/var/run/libreoffice-server.pid 

set -e 

case "$1" in 
start) 
if [ -f $PIDFILE ]; then 
echo "LibreOffice headless server has already started." 
sleep 5 
exit 
fi 
echo "Starting LibreOffice headless server" 
$SOFFICE_PATH --nologo --nofirststartwizard --headless --norestore --invisible "--accept=socket,host=localhost,port=8100,tcpNoDelay=1;urp;" & > /dev/null 2>&1 
touch $PIDFILE 
;; 
stop) 
if [ -f $PIDFILE ]; then 
echo "Stopping LibreOffice headless server." 
killall -9 oosplash && killall -9 soffice.bin 
rm -f $PIDFILE 
exit 
fi 
echo "LibreOffice headless server is not running." 
exit 
;; 
restart) 
$0 stop 
sleep 1 
$0 start 
;; 
*) 
echo "Usage: $0 {start|stop|restart}" 
exit 1 
esac 
exit 0
EOF
## End of init script.

## as I didn't find the way to create this file in /etc/init.d directly I move it now
echo -e "--- mv the script to /etc/init.d---"
if [[ ! -e /etc/init.d/libreoffice.sh ]]; 
then
	sudo mv $TEMP/libreoffice.sh /etc/init.d/
	sudo chmod +x /etc/init.d/libreoffice.sh
	sudo chmod 0755 /etc/init.d/libreoffice.sh
	sudo update-rc.d libreoffice.sh defaults 
	sudo service libreoffice.sh start	
else
	echo -e "---/etc/init.d/libreoffice.sh exist already. Do you want to overwrite it?---"
fi

## to test the service
## sudo service libreoffice.sh start
## telnet localhost 8100
##	Trying ::1...
##Trying 127.0.0.1...
##Connected to localhost.
##Escape character is '^]'.
##e��'com.sun.star.bridge.XProtocolPropertiesUrpProtocolProperties.UrpProtocolPropertiesTid���:
## How to stop telnet connection:
## Ctrl+] will take you to command mode if the telnet client is already connected; 
## from there you can type (q)uit to exit.
## If it's connecting, however (or failing to connect...), then there is no way to interrupt the process 
## until it times out

## remove the service
## sudo update-rc.d -f libreoffice.sh remove
	
echo -e "\n---- End of AerooLib install---" 
## end of aeroolib install

## install aeroodocs
echo -e "\n---- Start aeroodocs  install ---"
echo -e "---- Install some dependencies for aeroodocs---" 
sudo apt-get install python3-pip >> ./install_log
sudo pip3 install jsonrpc2 daemonize
cd /opt/aeroo
echo -e "---- Clone aeroo_docs ----"
if [[ -d /opt/aeroo/aeroo_docs ]];
then
	sudo rm -r /opt/aeroo/aeroo_docs
fi 
sudo git clone https://github.com/aeroo/aeroo_docs.git
sudo python3 /opt/aeroo/aeroo_docs/aeroo-docs start -c /etc/aeroo-docs.conf

## If you encounter and error "Unable to lock on the pidfile while trying  just restart your server (sudo shutdown -r now) doesn't work
## and try again after reboot.doesn't work for me.
## If you encounter and error "Unable to lock on the pidfile while trying #16 just restart the service (sudo service aeroo-docs restart).
	
sudo ln -s /opt/aeroo/aeroo_docs/aeroo-docs /etc/init.d/aeroo-docs
sudo update-rc.d aeroo-docs defaults
sudo service aeroo-docs restart
## end of aeroo_docs install

## --- Install odoo server ---- ##
echo -e "\n---So let's install V$OE_VERSION.0"
echo -e "\n---Cloning the github branch $OE_VERSION.0 of odoo ----"
while true; do
    read -p "Would you like a fresh install of Odoo  V $OE_VERSION.0. Could take some time (y/n)? " yn
    case $yn in
        [Yy]* ) cd $OE_HOME/
        if [[ -d $OE_HOME/$OE_USR$OE_VERSION-server ]]; #/odoo/odooV-server
then
	echo -e "\n---- Removing =$E_HOME/$OE_USR$OE_VERSION-server directory ----"
	sudo rm -rf $OE_HOME/$OE_USR$OE_VERSION-server  >>./install_log
fi 
		sudo mkdir -p $OE_HOME/$OE_USR$OE_VERSION-server
        sudo git clone --branch $OE_VERSION.0 https://www.github.com/odoo/odoo.git $OE_USR$OE_VERSION-server 
 # use the https url not the ssh github url else permission non accordée       	
        break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done



#Install a config file 
if [[ ! -d  /etc/$OE_USER ]];
	then sudo mkdir  /etc/$OE_USER/
fi

## install aeroo Reports
echo -e "--- clone Aeroo Reports Odoo Module:  ---"
if [ "$OE_VERSION" != "8" ] && [ "$OE_VERSION" != "11" ];
	then 
		echo -e "\n---- you enter $OE_VERSION---"
		echo -e "---- please enter 8. nothing else for Aeroo Report----"
		echo -e "---- there is only branch 8.0 and 11.0 in the git repository ----"
		echo -e "---- bye for now. Start again ----"
		exit 1
	else
		echo -e "\n---- So let's install V$OE_VERSION.0"
fi
sudo apt-get install python-cups
if [[ ! -d $OE_HOME/$OE_USR$OE_VERSION/custom/addons ]];
then
	sudo mkdir -p $OE_HOME/$OE_USR$OE_VERSION/custom/addons
fi 
cd $OE_HOME/$OE_USR$OE_VERSION/custom/addons
sudo git clone -b  $OE_VERSION.0 https://github.com/aeroo/aeroo_reports.git
	

#After following the (above) steps in this guide you should have Aeroo Reports installed correctly on your server for Ubuntu 14.04 and Odoo 8.0. You'll just need to create a database and install the required Aeroo reports modules you need for that database.
#
#[ ! ]    Do not have aeroo_report_sample in your addons directory or you will get an error message when updating module list:
#         Warning! Unmet python dependencies! No module named cups
#
#Install report_aeroo module in Odoo database:
#
##31    Go to Settings >> Users >> Administrator in the backend of Odoo
##32    Tick the box next to 'Technical Features' and Save, then refresh your browser window.
##33    Go to Settings >> Update Modules List > Update
##34    Go to Settings >> Local Modules > Search for: Aeroo
##35    Install report_aeroo
##36    You'll be confronted with an installation wizard, click: Continue >> Choose Simple Authentication from the Authentication dropdown list, and add username and password: anonymous
#[ ! ]     You can change the username and password in: /etc/aeroo-docs.conf if required.
##37    Click Apply and Test. You should see the following message if it was successful:
#
#Success! Connection to the DOCS service was successfully established and PDF convertion is working.



## ---- RESTART SERVER ---- ##
echo -e "\n >>>>>>>>>> PLEASE RESTART YOUR SERVER TO FINALISE THE INSTALLATION (See below for the command you should use) <<<<<<<<<<"
echo -e "\n---- restart the server  ie : sudo shutdown -r now ----"
while true; do
    read -p "Would you like to restart your server now (y/n)?" yn
    case $yn in
        [Yy]* ) sudo shutdown -r now
        break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

### for debug
echo -e "\n----BYE FOR NOW----"
tree /opt/$OE_USR -L 5 -gu 
exit 1
### end for debug

