#!/bin/bash
#update the version of odoo
#Utiliser des chemins absolu pour les dossiers et des chemins relatif pour les nom de 
#$CHEMIN_DU_DOSSIER/$NOM_DU_FICHIER
#
#suffixe=$(date +%F_%T) ---> 2015-02-07_10:20:37
#cp -a /home/lfs/odoogoeen /usr/odoogoeen-$(date +F_%T)

#sudoexit
#user host=(as user) [NOPWD:] cmd
#1er arg : user
#2eme arg: machine sur lequel le droit de la ligne sont valables
#3eme arg: utilisateur dont root prend les droits
#4eme arg: les commandes aux quelles user aura droit
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
SUFFIXE=$(date +'%F_%T')
echo "SUFFIXE: $SUFFIXE"
##--

##--
# Check if root
if [ "$EUID" -ne 0 ]; then
	echo "This script should be run as root"
	exit 1
fi
##--
echo "BEFORE, MAKE A DUMP"
cd $REPOSITORY_PATH/$SCRIPT_DIR
./dump-oo.sh

##--
echo 'Shutdown odoogoeen service'
service odoo-server stop

##--
# Copy dir_server prod to dir_server prod last
# so if there is a problem it's easy to go bac
# rm the the prod server dir
rsync -avz --progress -h $SERVER_PATH/$SERVER_NAME/ $SERVER_PATH/$SERVER_NAME.last
rm -r $SERVER_PATH/$SERVER_NAME


##--
# Update the server repository
# Change to the branch you want
# git checkout branch namebranch
cd $REPOSITORY_PATH/$SERVER_NAME
printf 

# then copy the repository
rsync -avz --progress -h $REPOSITORY/ $HOMEDIR/$SERVER_DIR/$SERVER_NAME
##--
# recuperer le filestore
rsync -avz --progress -h $HOMEDIR/$SERVER_DIR/$SERVER_NAME.last/openerp/filestore $HOMEDIR/$SERVER_DIR/$SERVER_NAME/openerp/
##--
chown -R $USER_NAME:$USER_NAME /home/lof/ODOO/odoogoeen

#relancer le service 
service odoo-server start
##--
tail -f /var/log/openerp/


## Start the server
sudo service odoo-server start
exit 0