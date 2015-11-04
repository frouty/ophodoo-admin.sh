#!/bin/bash
#-----------------------
#update the version of odoo
#Utiliser des chemins absolu pour les dossiers et des chemins relatif pour les nom de 
#$CHEMIN_DU_DOSSIER/$NOM_DU_FICHIER
#
#This script update the server from the local git repository.
#the local git repository must be on the right branch ie the production branch.
# ---UTILISATION---
# $cd /home/lof/ophodoo-admin.sh
# $git pull origin master
# $./pre_update_odoogoeen.sh
# $su 
# #./update_odoo.sh
#
#
#
#suffixe=$(date +%F_%T) ---> 2015-02-07_10:20:37
#cp -a /home/lfs/odoogoeen /usr/odoogoeen-$(date +F_%T)
#-----------------------

##--
SCRIPT_DIR='ophodoo-admin.sh'
SERVER_NAME='odoogoeen'
REPOSITORY_PATH='/home/lof'
SERVER_PATH='/home/lof/ODOO'
USER_NAME='openerp'

SERVER_BCK='backup'
##--
FILESTORE_PATH="$SERVER_PATH/$SERVER_NAME/openerp"
FILESTORE_DIR=filestore
##--
LOG_PATH="/var/log/openerp/"
LOG_FILE="odoo-server.log"
##--
SUFFIXE=$(date +'%F_%T')
echo "SUFFIXE: $SUFFIXE"
##--

##-- Check if root
if [ "$EUID" -ne 0 ]; then
	echo "This script should be run as root and you're not root"
	exit 1
fi

##-- dump of database
echo "BEFORE, MAKE A DUMP"
cd $REPOSITORY_PATH/$SCRIPT_DIR
./dump-oo.sh

##-- Shutdown service
echo 'Shutdown odoogoeen service'
service odoo-server stop

##--
# Move dir_server prod to dir_server prod last
# so if there is a problem it's easy to go back
mv $SERVER_PATH/$SERVER_NAME/ $SERVER_PATH/$SERVER_NAME.last


# then copy the repository
echo "then copy the repository to the server path"
sleep 4
rsync -avz --progress -h $REPOSITORY_PATH/$SERVER_NAME $SERVER_PATH/$SERVER_NAME


##--
# recuperer le filestore
#echo "copier filestore from $HOMEDIR/$SERVER_DIR/$SERVER_NAME.last/openerp/filestore to $HOMEDIR/$SERVER_DIR/$SERVER_NAME/openerp/"
sleep 2
echo "Copy filestore"
rsync -avz --progress -h $SERVER_PATH/$SERVER_NAME.last/openerp/filestore $SERVER_PATH/$SERVER_NAME/openerp/
##--
chown -R $USER_NAME:$USER_NAME $SERVER_PATH/$SERVER_NAME

#relancer le service
echo '-- Start odoo-server --'
service odoo-server start
##--
echo '-- log file -- '
tail -f $LOG_PATH/$LOG_FILE

exit 0