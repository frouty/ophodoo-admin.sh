#!/bin/bash
################################################################################
# A one-line installation for OpenERP 7.0 server instances
#-------------------------------------------------------------------------------
# USAGE:
#
# * Setup openerp server and create a first OpenERP7 7 instance
#   oe-admin install [name1] --full
#
# * Create an additional OpenERP7 7 instance
# 	oe-admin install [name2]
#
# * Start one OpenERP instance (to the terminal)
# 	oe-admin start [name2] [server options]
#
# EXAMPLE:
# oe-admin install development --full
# oe-admin install staging
# oe-admin start staging --xmlrpc-port=8080 &
# oe-admin start development --xmlrpc-port=8080 --debug
#
################################################################################
#  Copyright 2013 Nicholas <nicholas.riegel@gmail.com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.

#fixed parameters:
OEADMIN_USER="openerp"
OEADMIN_HOME="/opt/openerp"

case "$1" in
install)
	#--------------------------------------------------
	# Install required dependencies
	#--------------------------------------------------
	if [ "$3" = "--full" ] ; then
		#Make this script available anywhere:
		#sudo ln -sf /usr/local/bin $0
		echo -e "\n---- Install PostgreSQL ----"
		sudo apt-get install postgresql
		
		echo -e "\n---- Install tool debian packages ----"
		yes | sudo apt-get install bzr bzrtools python-pip

		echo -e "\n---- Install python debian packages ----"
		yes | sudo apt-get install python-dateutil python-docutils python-feedparser \
		python-gdata python-jinja2 python-ldap python-libxslt1 python-lxml python-mako \
		python-mock python-openid python-psycopg2 python-psutil python-pybabel \
		python-pychart python-pydot python-pyparsing python-reportlab python-simplejson \
		python-tz python-unittest2 python-vatnumber python-vobject python-webdav \
		python-werkzeug python-xlwt python-yaml python-zsi
		
		echo -e "\n---- Install python libraries ----"
		sudo pip install gdata
		
		echo -e "\n---- Create system user ----"
		sudo adduser --system --quiet --shell=/bin/bash --home=$OEADMIN_HOME --gecos 'OpenERP' --group $OEADMIN_USER
		sudo mkdir /var/log/$OEADMIN_USER
		sudo chown $OEADMIN_USER:$OEADMIN_USER /var/log/$OEADMIN_USER
		sudo mkdir -p $OEADMIN_HOME/$OEADMIN_USER
		sudo chown $OEADMIN_USER:$OEADMIN_USER $OEADMIN_HOME/$OEADMIN_USER
	fi
	
	#--------------------------------------------------
	# Create a new instance
	#--------------------------------------------------
	INSTANCE=$2
	echo -e "\n==== Create instance $INSTANCE ===="

	echo "* Create instance directory"
	mkdir -p $OEADMIN_HOME/$INSTANCE

	echo "* Create postgres user"
	echo "A new PostgreSQL user, openerp-"$INSTANCE" will be created."
	#read -s instance_pass
	sudo su -c "createuser -e --createdb --no-createrole --no-superuser openerp-$INSTANCE" postgres	
	#sudo su -c "createuser --createdb --no-createrole --no-superuser --pwprompt openerp-$INSTANCE" postgres
	if [ -d $OEADMIN_HOME/$INSTANCE/server ] ; then
		echo "* Server directory exists: skipping"
	else
		echo -e "* Download files"
		#Download nightly builds
		mkdir -p $OEADMIN_HOME/downloads
		wget --no-clobber http://nightly.openerp.com/7.0/nightly/src/openerp-7.0-latest.tar.gz -P $OEADMIN_HOME/downloads
		echo -e "* Uncompress files"
		rm -rf $OEADMIN_HOME/downloads/tmp
		mkdir -p $OEADMIN_HOME/downloads/tmp
		tar xvf $OEADMIN_HOME/downloads/openerp-7.0-latest.tar.gz --directory=$OEADMIN_HOME/downloads/tmp
		echo -e "* Install files"
		mkdir -p $OEADMIN_HOME/$INSTANCE/server
		mv $OEADMIN_HOME/downloads/tmp/`ls $OEADMIN_HOME/downloads/tmp/`/* $OEADMIN_HOME/$INSTANCE/server
		#bzr co lp:openerp-web/7.0 $OEADMIN_HOME/$INSTANCE/web
		#bzr co lp:openobject-server/7.0 $OEADMIN_HOME/$INSTANCE/server
		#bzr co lp:openobject-addons/7.0 $OEADMIN_HOME/$INSTANCE/addons
	fi
	
	echo -e "* Create server config file"
	cp $OEADMIN_HOME/$INSTANCE/server/install/openerp-server.conf $OEADMIN_HOME/$INSTANCE --backup=numbered
	sed -i s/"db_user = .*"/"db_user = openerp-$INSTANCE"/g $OEADMIN_HOME/$INSTANCE/openerp-server.conf
	#sed -i s/"db_password = .*"/"db_password = $instance_pass"/g $OEADMIN_HOME/$INSTANCE/openerp-server.conf
	echo "xmlrpc_port = 8070" >> $OEADMIN_HOME/$INSTANCE/openerp-server.conf
	echo "logfile = /var/log/openerp/openerp-$INSTANCE.log" >> $OEADMIN_HOME/$INSTANCE/openerp-server.conf
	#echo "addons_path=/opt/openerp/$INSTANCE/addons,/opt/openerp/$INSTANCE/web/addons" >> $OEADMIN_HOME/$INSTANCE/openerp-server.conf
	echo "#!/bin/sh
sudo -u $OEADMIN_USER $OEADMIN_HOME/$INSTANCE/server/openerp-server --config=$OEADMIN_HOME/$INSTANCE/openerp-server.conf \$*
" > $OEADMIN_HOME/$INSTANCE/start.sh
	chmod 755 $OEADMIN_HOME/$INSTANCE/start.sh
	;;

start)
	INSTANCE=$2
	shift 2
	$OEADMIN_HOME/$INSTANCE/start.sh $*
	;;
	
esac
echo "Done!"

# TODO IDEAS:  add options to
# * set listening xmlrpc port
# * start in background, see instances running, and stop instances
# * set instance to autostart on boot
# * provide better conf file template
# * install from source
# * install and add an additional addons directory to an existing instance
# * update instance files
# * remove instance
# * rebuild and run tests on throw-away instances
