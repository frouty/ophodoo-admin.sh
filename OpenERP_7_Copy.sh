################################################################################
#  Copyright 2013 Nicholas Riegel <nicholas.riegel@gmail.com>
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
################################################################################
################################################################################
# A one-line command for copying OpenERP 7.0 server testing folders to 
# production folders. This will just copy the files into the production folder
# and should retain most setting by not overwriting any configuration files.
#-------------------------------------------------------------------------------
# USAGE:
#
# * Copy an instance from one folder to another
# 	OpenERP_7_Copy /folder/[old server root] /folder/[new server root] 
#	[name of old server backup] [name of PostgreSQL Database]
#	
# EXAMPLE:
# OpenERP_7_Copy /opt/openerp/server /opt/openerp/staging/server ITPS ITPS7
#
################################################################################
#fixed parameters:
OEADMIN_USER="openerp"
OEADMIN_HOME="/opt/openerp"
now=$(date +"%Y_%m_%d_%H_%M_%S")
backup=/backup/$3$now.tar.7z

#Checks for any arguments and if there is none then the user is asked for arguments
if [ $# = 0 ]; then
	echo "What is the location of the old server root? (ie /opt/openerp/server)?"
	read old_server
	echo "What is the location of the new server root that will be copied?"
	read new_server
	echo "What would you like to call backup of the old PostgreSQL database?"
	read db_backup
	echo "What is the name of the PostgreSQL database to be backed up?"
	read db_post
	$1 = old_server
	$2 = new_server
	$3 = db_backup
	$4 = db_post 
	#echo $1
	#echo $2
	#echo $3
	#echo $4
else
	echo "Command arguments present.."
fi

#Make this script available anywhere:
#sudo ln -sf /usr/local/bin $0

# Script Testing
#echo $0
#echo $1
#echo $2
#echo $3
#echo $4
#echo $OEADMIN_HOME$backup
#echo $now
#echo $1/postgresql_$4_database_dump.7z


sudo mkdir $OEADMIN_HOME/backup
sudo rm $1/*.7z
sudo pg_dump -U postgres $4 | 7za a -si -t7z -m0=lzma -mx=9 -mfb=64 -md=32m $1/postgresql_$4_database_dump.7z
sudo tar -cv "$1" | 7za a -si -t7z -m0=lzma -mx=9 -mfb=64 -md=32m $OEADMIN_HOME$backup
sudo cp -av $2/server/ $OEADMIN_HOME
sudo chown -R openerp:openerp /opt/openerp
sudo chmod 755 -R /opt/openerp
sudo service openerp-server restart
echo "Files have been copied from $2 to $1."
echo "The old server files have been backed up to "$OEADMIN_HOME""$backup", including a dump of the OpenERP PostgreSQL database."  
