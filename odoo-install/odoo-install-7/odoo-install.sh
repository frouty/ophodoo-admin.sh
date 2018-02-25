#!/bin/bash
################################################################################
# Script for Installation of new file system for odoo 7
# Author: Laurent FRANCOIS
# email: francois.oph@gmail.com
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
OE_CONFIG="$OE_USER$OE_VERSION-server"

echo -e "\n---- Create ODOO system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER

echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

##Enter version for checkout 7.0 for version  7.0 
##8.0 for version 8.0
#OE_VERSION="8.0"
echo -e "\n---Enter the ODOO version you want---"
echo -e "---should be 7--"
read OE_VERSION
#if [ "$OE_VERSION" != "8" ] && [ "$OE_VERSION" != "7" ];
if  [ "$OE_VERSION" != "7" ];
		then 
		echo -e "\n--- you enter $OE_VERSION---"
		echo -e "--- please enter 7. nothing else"
		echo -e "--- bye for now. Start again---"
		exit 1
	else
	echo -e "\n---So let's make file system for  V$OE_VERSION.0"
fi

## /opt/odoo/odoo7/odoo7-server
##/opt/odoo/odoo7/custom/addons
## /opt/odoo/odoo8/odoo8-server
##/opt/odoo8/custom/addons
## Install server odoo in /opt/$OE_USER/$OE_USER$OE_VERSION/$OE_USER$OE_VERSION-server
## install customs addons  in /opt/$OE_USER/$OE_USER$OE_VERSION/custom/addons
##
echo -e "\n--- making file system for odoo"
if [[ -d  /opt/$OE_USER/$OE_USER$OE_VERSION ]];
	then sudo rm -rf  /opt/$OE_USER/$OE_USER$OE_VERSION
fi
sudo mkdir -p /opt/$OE_USER/$OE_USER$OE_VERSION/{custom/addons/,$OE_USER$OE_VERSION-server}
echo -e "\n---So let's install V$OE_VERSION.0"
echo -e "\n---Cloning odoo 7----"
cd /opt/$OE_USER/$OE_USER$OE_VERSION 
sudo git clone --branch $OE_VERSION.0 https://www.github.com/frouty/odoo $OE_USER$OE_VERSION-server 
# use the https url not the ssh github url else permission non accordée

#Install a config file 
if [[ ! -d  /etc/$OE_USER ]];
	then sudo mkdir  /etc/$OE_USER/
fi

echo -e "/n--- Make a server conf file"
cat << END > ~/$OE_CONFIG.conf 
#!/bin/bash 
[options]
# specify additional addons paths (separated by commas)' 
addons_path = $OE_HOME/$OE_USER$OE_VERSION/$OE_USER$OE_VERSION-server/addons/,/$OE_HOME/$OE_USER$OE_VERSION/custom/addons/extra-addons/oph,/$OE_HOME/$OE_USER$OE_VERSION/custom/addons/extra-addons/aeroo
# Admin password for creating, restoring and backing up databases admin_passwd = admin'
admin_passwd = admin HACK ME
csv_internal_sep = ,
db_host = False
db_maxconn = 64
db_name = False
db_password = admin HACK ME
db_port = False
db_template = template1
db_user = openerp
dbfilter = .*
debug_mode = False
demo = {}
email_from = False
ftp_server_host = IP HACK ME
import_partial = 
limit_memory_hard = 805306368
limit_memory_soft = 671088640
limit_request = 8192
limit_time_cpu = 60
limit_time_real = 120
list_db = True
log_handler = [':INFO']
# specify the level of the logging. Accepted values: info, debug_rpc, warn, test, critical, debug_sql, error, debug, debug_rpc_answer, notset' 
log_level = info
# file where the server log will be stored (default = None)' 
logfile = /var/log/$OE_USER/$OE_USER$OE_VERSiON-server.log
login_message = False
logrotate = True
max_cron_threads = 2
netrpc = False
netrpc_interface = 127.0.0.1
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
# Send the log to the syslog server'
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
xmlrpc_interface = 127.0.0.1
xmlrpc_port = 8069
xmlrpcs = True
xmlrpcs_interface = 
xmlrpcs_port = 8071
END

echo -e '/n--- You must hack /etc/$OE_USER/$OE_CONFIG ----'

## Security on odoo server conf file
if [[ -f /etc/$OE_USER/$OE_CONFIG-server ]];
	then sudo rm /etc/$OE_USER/$OE_CONFIG-server
sudo mv ~/$OE_CONFIG.conf /etc/$OE_USER/
sudo chown $OE_USER:$OE_USER /etc/$OE_USER/$OE_CONFIG.conf
sudo chmod -R 640 /etc/$OE_USER

## end of install a config file for odoo server

## install an init.d scritp
echo -e "* Create init file"
echo '#!/bin/sh' >> ~/$OE_CONFIG
echo '### BEGIN INIT INFO' >> ~/$OE_CONFIG
echo "# Provides:             odoo-server" >> ~/$OE_CONFIG
echo "# Required-Start:       $remote_fs $syslog" >> ~/$OE_CONFIG
echo "# Required-Stop:        $remote_fs $syslog" >> ~/$OE_CONFIG
echo "# Should-Start:         $network" >> ~/$OE_CONFIG
echo "# Should-Stop:          $network" >> ~/$OE_CONFIG
echo "# Default-Start:        2 3 4 5" >> ~/$OE_CONFIG
echo "# Default-Stop:         0 1 6" >> ~/$OE_CONFIG
echo "# Short-Description:    Complete Business Application software" >> ~/$OE_CONFIG
echo "# Description:          Odoo is a complete suite of business tools." >> ~/$OE_CONFIG
echo "# after creation: chmod 755 this file" >> ~/$OE_CONFIG
echo "#		  chown root: this file" >> ~/$OE_CONFIG
echo "# 		  update-rc.d this file defaults" >> ~/$OE_CONFIG
echo "### END INIT INFO" >> ~/$OE_CONFIG
echo "" >> ~/$OE_CONFIG
echo "PATH=/bin:/sbin:/usr/bin" >> ~/$OE_CONFIG
echo "DAEMON=$OE_HOME/$OE_USER$OE_VERSION/$OE_CONFIG/openerp-server" >> ~/$OE_CONFIG
echo "NAME=$OE_CONFIG" >> ~/$OE_CONFIG
echo "DESC=$OE_CONFIG" >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo # Specify the user name (Default: odoo).' >> ~/$OE_CONFIG
echo 'USER=$OE_USER' >> ~/$OE_CONFIG
echo '#USER=openerp' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# Specify an alternate config file (Default: /etc/odoo-server.conf).' >> ~/$OE_CONFIG
echo 'CONFIGFILE="/etc/$OE_USER/$OE_CONFIG.conf"' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# pidfile' >> ~/$OE_CONFIG
echo 'PIDFILE=/var/run/$NAME.pid' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# Additional options that are passed to the Daemon.' >> ~/$OE_CONFIG
echo 'DAEMON_OPTS="-c $CONFIGFILE"' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '[ -x $DAEMON ] || exit 0' >> ~/$OE_CONFIG
echo '[ -f $CONFIGFILE ] || exit 0' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'checkpid() {' >> ~/$OE_CONFIG
echo '    [ -f $PIDFILE ] || return 1' >> ~/$OE_CONFIG
echo '   pid=`cat $PIDFILE`' >> ~/$OE_CONFIG
echo '    [ -d /proc/$pid ] && return 0' >> ~/$OE_CONFIG
echo '   return 1' >> ~/$OE_CONFIG
echo '}' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'case "${1}" in' >> ~/$OE_CONFIG
echo '        start)' >> ~/$OE_CONFIG
echo '                echo -n "Starting ${DESC}: "' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                     start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '                          --chuid ${USER} --background --make-pidfile \' >> ~/$OE_CONFIG
echo '                          --exec ${DAEMON} -- ${DAEMON_OPTS}' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                  echo "${NAME}."' >> ~/$OE_CONFIG
echo '                 ;;' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '        stop)' >> ~/$OE_CONFIG
echo '                echo -n "Stopping ${DESC}: ' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                 start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '                       --oknodo' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                 echo "${NAME}."' >> ~/$OE_CONFIG
echo '                  ;;' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '        restart|force-reload)' >> ~/$OE_CONFIG
echo '                echo -n "Restarting ${DESC}: "' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '                        --oknodo' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                 sleep 1' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                 start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '                         --chuid ${USER} --background --make-pidfile \' >> ~/$OE_CONFIG
echo '                         --exec ${DAEMON} -- ${DAEMON_OPTS}'>> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                echo "${NAME}."' >> ~/$OE_CONFIG
echo '                 ;;' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '       *)' >> ~/$OE_CONFIG
echo '               N=/etc/init.d/${NAME}' >> ~/$OE_CONFIG
echo '               echo "Usage: ${NAME} {start|stop|restart|force-reload}" >&2' >> ~/$OE_CONFIG
echo '               exit 1' >> ~/$OE_CONFIG
echo '              ;;' >> ~/$OE_CONFIG
echo 'esac' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'exit 0' >> ~/$OE_CONFIG

# Security init.script
echo -e "* Security Init File"
sudo mv ~/$OE_CONFIG /etc/init.d/$OE_CONFIG
sudo chmod 755 /etc/init.d/$OE_CONFIG
sudo chown root: /etc/init.d/$OE_CONFIG

echo -e "\n--- Start ODOO on Startup ---"
sudo update-rc.d $OE_CONFIG defaults
## end init script.

##Installation des extra-addons.
cd /opt/$OE_USER/$OE_USER$OE_VERSION/custom/
sudo git clone https://github.com/frouty/oph_odoo7.git addons
echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

exit 1

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

## End of init script libreoffice headless server.

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

	echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*	
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


