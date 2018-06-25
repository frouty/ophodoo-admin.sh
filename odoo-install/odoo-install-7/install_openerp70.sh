#!/bin/bash
################################################################################
#DO NOT USE THIS SCRIPT  AS IT IS
#exit 1 
#Script for Installation: ODOO 7.0 on Debian 9
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
# ./install_openerp70.sh
#
# 
################################################################################
set -x # for debugging
##openerp
OE_USR="odoo"
OE_HOME="/opt/$OE_USR"
OE_VERSION=7
OE_CONFIG="$OE_USR$OE_VERSION-server" # ie : odoo7-server
## --
OE_PORT="8069"
OE_SUPERADMIN="admin"
##--
TEMP="tmp"


## create ODOO system user 
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
sudo chown $OE_USR:$OE_USR /var/log/$OE_USR

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

## --- Create the odoo Postgresql user ----
echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $OE_USR" 2> /dev/null || true
## peut etre les droits sont trop hauts avec cette commande

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
if   [[ ! -d $HOME/$TEMP ]];
then 
	mkdir $HOME/$TEMP
fi
cd $HOME/$TEMP
## The quoted form of "EOF" is important
## it's for not interpreting the $
## else you get the "$1" and "$2" replaced by the name of the script !
## the second EOF do not have to be quoted.
cat > libreoffice.sh << EOF
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

case "\$1" in 
start) 
if [ -f \$PIDFILE ]; then 
echo "LibreOffice headless server has already started." 
sleep 5 
exit 
fi 
echo "Starting LibreOffice headless server" 
\$SOFFICE_PATH --nologo --nofirststartwizard --headless --norestore --invisible "--accept=socket,host=localhost,port=8100,tcpNoDelay=1;urp;" & > /dev/null 2>&1 
touch \$PIDFILE 
;; 
stop) 
if [ -f \$PIDFILE ]; then 
echo "Stopping LibreOffice headless server." 
killall -9 oosplash && killall -9 soffice.bin 
rm -f \$PIDFILE 
exit 
fi 
echo "LibreOffice headless server is not running." 
exit 
;; 
restart) 
\$0 stop 
sleep 1 
\$0 start 
;; 
*) 
echo "Usage: \$0 {start|stop|restart}" 
exit 1 
esac 
exit 0
EOF
## End of init script.

## as I didn't find the way to create this file in /etc/init.d directly I move it now
echo -e "--- mv the script to /etc/init.d---"
if [[ ! -e /etc/init.d/libreoffice.sh ]]; 
then
	sudo mv $HOME/$TEMP/libreoffice.sh /etc/init.d/
	sudo chmod +x /etc/init.d/libreoffice.sh
	sudo chmod 0755 /etc/init.d/libreoffice.sh
	sudo update-rc.d libreoffice.sh defaults 
	sudo service libreoffice.sh start	
else
	echo -e "--- /etc/init.d/libreoffice.sh exist already. Do you want to overwrite it?---"
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
	
echo -e "--- End of AerooLib install---" 
## end of aeroolib install

## --- Install ODOO server ---- ##
echo -e "\n--- So let's install V$OE_VERSION.0"
echo -e "--- Cloning the github branch $OE_VERSION.0 of odoo ? ----"
while true; do
    read -p "--- Would you like a fresh install of Odoo  V $OE_VERSION.0. Could take some time (y/n)? --- " yn
    case $yn in
        [Yy]* ) cd $OE_HOME/
        if [[ -d $OE_HOME/$OE_USR$OE_VERSION-server ]]; #/odoo/odooV-server
then
	echo -e "---- Removing =$E_HOME/$OE_USR$OE_VERSION-server directory ----"
	sudo rm -rf $OE_HOME/$OE_USR$OE_VERSION-server 
fi 
		sudo mkdir -p $OE_HOME/$OE_CONFIG
        sudo git clone --branch $OE_VERSION.0 https://www.github.com/odoo/odoo.git $OE_CONFIG 
 # use the https url not the ssh github url else permission non accordée       	
        break;;
        [Nn]* ) break;;
        * ) echo "--- Please answer yes or no.";;
    esac
done

## Create a config file for odoo server
echo -e "\n--- Create server config file ---"
if [[ ! -d  /etc/$OE_USR ]];
	then sudo mkdir  /etc/$OE_USR/
		sudo chown -R $OE_USR: /etc/$OE_USR/
		sudo chmod 755 /etc/$OE_USR/
fi
sudo su root -c "cat <<EOF > /etc/$OE_USR/$OE_CONFIG.conf
[options]
addons_path = $OE_HOME/$OE_CONFIG/addons,$OE_HOME/$OE_CONFIG/custom/addons/aeroo, ,$OE_HOME/$OE_CONFIG/custom/addons/oph
# addons_path = /home/lof/ODOO/odoogoeen/addons,/home/lof/ODOO/odoogoeen/extra-addons/aeroo,/home/lof/ODOO/odoogoeen/extra-addons/oph
admin_passwd = sgcg40
csv_internal_sep = ,
db_host = False
db_maxconn = 64
db_name = False
db_password = False
db_port = False
db_template = template1
db_user = odoo
dbfilter = .*
debug_mode = False
demo = {}
email_from = False
# ftp_server_host HACK ME
#ftp_server_host = 10.66.0.249
import_partial = 
limit_memory_hard = 805306368
limit_memory_soft = 671088640
limit_request = 8192
limit_time_cpu = 60
limit_time_real = 120
list_db = True
log_handler = [':INFO']
## specify the level of the logging. Accepted values: info, debug_rpc, warn, test, critical, debug_sql, error, debug, debug_rpc_answer, notset' 
log_level = info
logfile = /var/log/$OE_USR/$OE_USR-server.log
login_message = False
logrotate = True
max_cron_threads = 2
netrpc = False
netrpc_interface = 
netrpc_port = 8070
osv_memory_age_limit = 1.0
osv_memory_count_limit = False
pg_path = None
pidfile = None
proxy_mode = False
reportgz = False
secure_cert_file = server.cert
secure_pkey_file = server.pkey
server_wide_modules = None
smtp_password = False
smtp_port = 25
smtp_server = localhost
smtp_ssl = False
smtp_user = False
static_http_document_root = None
static_http_enable = False
static_http_url_prefix = None
syslog = False
test_commit = False
test_enable = False
test_file = False
test_report_directory = False
timezone = False
translate_modules = ['all']
unaccent = False
without_demo = False
workers = 0
xmlrpc = True
xmlrpc_interface = 
xmlrpc_port = 8069
xmlrpcs = True
xmlrpcs_interface = 
xmlrpcs_port = 8071

EOF"
## --- Securing odoo-server.conf ----
echo -e "--- Securing /etc/$OE_USR/$OE_CONFIG.conf file ----"
sudo chown $OE_USR:$OE_USR  /etc/$OE_USR/$OE_CONFIG.conf
sudo chmod 640 /etc/$OE_USR/$OE_CONFIG.conf

## ---- Create an init file for odoo server -----
echo -e "\n--- Make an init script for odoo server ---"
cd $TEMP
## The quoted form of "EOF" is important
## it's for not interpreting the $
## else you get the "$1" and "$2" replaced by the name of the script !
## the second EOF do not have to be quoted.
## but here you need some substitution
## but sometimes not and you use the \ escape character for that
## sudo su root -c doesn't work ici
cat > ~/odoo-server << EOF
#!/bin/sh

### BEGIN INIT INFO
# Provides:             odoo-server
# Required-Start:       \$remote_fs \$syslog
# Required-Stop:        \$remote_fs \$syslog
# Should-Start:         \$network
# Should-Stop:          \$network
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    Complete Business Application software
# Description:          Odoo is a complete suite of business tools.
# after creation: chmod 755 this file
#		  chown root: this file
# 		  update-rc.d this file defaults
### END INIT INFO

PATH=/bin:/sbin:/usr/bin
OE_USR="odoo"
OE_VERSION=7
OE_CONFIG=$OE_USR$OE_VERSION-server
DAEMON=$OE_HOME/$OE_CONFIG/openerp-server # look in the odoo repository for the correct path
NAME=odoo-server
DESC=odoo-server

# Specify the user name (Default: odoo).
USER=odoo
#USER=openerp

# Specify an alternate config file (Default: /etc/odoo-server.conf).
#CONFIGFILE="/etc/odoo-server.conf"
CONFIGFILE="/etc/$OE_USR/$OE_CONFIG.conf"

# pidfile
PIDFILE=/var/run/\$NAME.pid

# Additional options that are passed to the Daemon.
DAEMON_OPTS="-c \$CONFIGFILE"

[ -x \$DAEMON ] || exit 0
[ -f \$CONFIGFILE ] || exit 0

checkpid() {
    [ -f \$PIDFILE ] || return 1
    pid=\`cat \$PIDFILE\`
    [ -d /proc/\$pid ] && return 0
    return 1
}

case "\${1}" in
        start)
                echo -n "Starting \${DESC}: "

                start-stop-daemon --start --quiet --pidfile \${PIDFILE} \
                --chuid \${USER} --background --make-pidfile \
                --exec \${DAEMON} -- \${DAEMON_OPTS}

                echo "\${NAME}."
                ;;

        stop)
                echo -n "Stopping \${DESC}: "

                start-stop-daemon --stop --quiet --pidfile \${PIDFILE} \
                --oknodo

                echo "\${NAME}."
                ;;

        restart|force-reload)
                echo -n "Restarting \${DESC}: "

                start-stop-daemon --stop --quiet --pidfile \${PIDFILE} \
                --oknodo
      
                sleep 1

                start-stop-daemon --start --quiet --pidfile \${PIDFILE} \
                --chuid \${USER} --background --make-pidfile \
                 --exec \${DAEMON} -- \${DAEMON_OPTS}

                echo "\${NAME}."
                ;;

        *)
                N=/etc/init.d/\${NAME}
                echo "Usage: \${NAME} {start|stop|restart|force-reload}" >&2
                exit 1
                ;;
esac
exit 0
EOF
## End of init script.

## as I didn't find the way to create this file in /etc/init.d directly I move it now
echo -e "--- mv the script to /etc/init.d---"
if [[ ! -e /etc/init.d/odoo-server ]]; 
then
	sudo mv ~/odoo-server /etc/init.d/
	sudo chmod +x /etc/init.d/odoo-server
	sudo chmod 0755 /etc/init.d/odoo-server
	echo -e "--- Start ODOO on Startup ---"
	sudo update-rc.d odoo-server defaults 
	sudo service odoo-server start	
else
	echo -e "---/etc/init.d/odoo-server exist already. Do you want to overwrite it?---"
fi

## ----- Install the OPH Module ----- 
echo -e "\n---- Do you want to install the oph module? ----"
while true; do
    read -p "Would you like to install the oph module for Odoo  V $OE_VERSION.0. (y/n)? " yn
    case $yn in
        [Yy]* ) cd $OE_HOME/$OE_USR$OE_VERSION/custom/addons
        sudo git clone --branch $OE_VERSION.0 https://www.github.com/frouty/oph_odoo.git 
		 # use the https url not the ssh github url else permission non accordée       	
        break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
## End Install the OPH Module 

## ----- Install aeroo module -------
## dans github de aeroo on ne trouve pas la version d'aeroo
## pour la version 7.0 d'odoo
## Mais j'ai la branche de julius-network-solutions
## que j'ai forké
echo -e "\n---- Do you want to install aeroo report ----"
while true; do
    read -p "Would you like to install the AEROO module for Odoo  V $OE_VERSION.0. (y/n)? " yn
    case $yn in
        [Yy]* ) cd $OE_HOME/$OE_USR$OE_VERSION/custom/addons
        sudo git clone --branch $OE_VERSION.0 https://www.github.com/frouty/aeroo.git 
		 # use the https url not the ssh github url else permission non accordée       	
        break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
## End install aeroo module

## ---- Setting permission for home folder /opt/odoo/
echo -e "\n---- Setting permissions on home folder $OE_HOME ----"
sudo chown -R $OE_USR:$OE_USR $OE_HOME/*
 

