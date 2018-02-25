#!/bin/bash
################################################################################
#DO NOT USE THIS SCRIPT  AS IT IS
exit 1 
#Script for Installation: ODOO 8.0 on Debian 9
# Author: Laurent FRANCOIS
# email: francois.oph@gmail.com
# 
# LibreOffice-Python 2.7 Compatibility Script Author: Holger Brunn (https://gist.github.com/hbrunn/6f4a007a6ff7f75c0f8b)
#-------------------------------------------------------------------------------
#  
# This script will install ODOO Server on
# clean Ubuntu 14.04 Server
#-------------------------------------------------------------------------------
# USAGE:
#
# odoo-install
#
# EXAMPLE:
# ./odoo-install 
#
################################################################################

## --------
## fixed var
## --------
TEMP="/home/lof/tempo"
##openerp
OE_USER="odoo"
OE_HOME="/opt/$OE_USER"
##Enter version for checkout 7.0 for version  7.0 
##8.0 for version 8.0
#OE_VERSION="8.0"
echo -e "\n---Enter the ODOO version you want---"
echo -e "---should be 7 or 8---"
read OE_VERSION
if [ "$OE_VERSION" != "8" ] && [ "$OE_VERSION" != "7" ];
	then 
		echo -e "\n--- you enter $OE_VERSION---"
		echo -e "--- please enter 8 or 7. nothing else"
		echo -e "--- bye for now. Start again---"
		exit 1
	else
		echo -e "\n---So let's install V$OE_VERSION.0"
fi

## ----------
## install dependencies
## ----------
## Install SSH
echo -e "\n---- Install SSH Server ----"
echo -e "\n---- This will install client and server openssh ----"
sudo apt-get install ssh -y

## Install postgresql
echo -e "\n---Install Postgresql Server"
sudo apt-get install postgresql -y
## install git
echo -e "\n---- install git ----"
sudo apt-get install git -y
echo -e "\n---- install pip ----"
sudo apt-get install git python-pip -y	
echo -e "\n--- Actuel pip version ---	
python -m pip --version
echo -e "\n--- upgradel pip version ---
sudo pip install --upgrade pip
python -m pip --version


## /opt/odoo7/odoo-server
##/opt/odoo7/custom/addons
## /opt/odoo8/odoo-server
##/opt/odoo8/custom/addons
## Install server odoo in /opt/odoo$OE_VERSION/$OE_USER-server
## install customs addons  in /opt/odoo$OE_VERSION/custom/addons
if [[ -d /opt/$OE_USR$OE_VERSION ]];
then
	sudo rm -r /opt/$OE_USR$OE_VERSION
fi 



## Installation de aeroo lib
echo -e "\n---- Install aeroo lib ----"
echo -e "\n---- first Install libreoffice and some python libraries ----"
sudo apt-get install -y --force-yes --no-install-recommends libreoffice-common libreoffice-core python3-uno libreoffice-script-provider-python 
sudo apt-get install python-setuptools python-genshi python-cairo python-lxml

sudo mkdir /opt/aeroo
cd /opt/aeroo
echo -e "--- clonage de aeroolib---"
sudo git clone https://github.com/aeroo/aeroolib.git
cd /opt/aeroo/aeroolib
echo -e "--- install aeroolib ---"
sudo python setup.py install

echo -e "\n--- make an init script for libreoffice headless server --"
cd $TEMP
## The quoted form of "EOF" is important
## else you get the "$1" and "$2" replaced by the name of the script !
## the second EOF do not have to be quoted.
cat > libreoffice.sh << "EOF"
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
EOF # do not quote this one 

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

## remove the service
## sudo update-rc.d -f libreoffice.sh remove
	
## end of aeroolib install

## install aeroodocs
echo -e "--- install some dependencies for aeroodocs---" 
sudo apt-get install python3-pip
sudo pip3 install jsonrpc2 daemonize
cd /opt/aeroo

echo -e "--- clone aeroo_docs---"
if [[ -d /opt/aeroo/aeroo_docs ]];
then
	sudo rm -r /opt/aeroo/aeroo_docs
fi 
sudo git clone https://github.com/aeroo/aeroo_docs.git
sudo python3 /opt/aeroo/aeroo_docs/aeroo-docs start -c /etc/aeroo-docs.conf
## If you encounter and error "Unable to lock on the pidfile while trying  just restart your server (sudo shutdown -r now)
## and try again after reboot.
sudo ln -s /opt/aeroo/aeroo_docs/aeroo-docs /etc/init.d/aeroo-docs
sudo update-rc.d aeroo-docs defaults

## end of aeroo_docs install

## install aeroo Reports
echo -e "--- clone aeroo_docs---"
sudo apt-get install python-cups
if [[ ! -d /opt/odoo/custom ]];
then
	sudo mkdir -p /opt/odoo/custom
fi 
cd /opt/odoo/custom
sudo git clone -b master https://github.com/aeroo/aeroo_reports.git
	
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


