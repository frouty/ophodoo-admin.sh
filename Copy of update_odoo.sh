#!/bin/bash
#update the version of odoo
#Utiliser des chemins absolu pour les dossiers et des chemins relatif pour les nom de 
#$CHEMIN_DU_DOSSIER/$NOM_DU_FICHIER
#
#suffixe=$(date +%F_%T) ---> 2015-02-07_10:20:37
#cp -a /home/lfs/odoogoeen /usr/odoogoeen-$(date +F_%T)

#sudo
#user host=(as user) [NOPWD:] cmd
#1er arg : user
#2eme arg: machine sur lequel le droit de la ligne sont valables
#3eme arg: utilisateur dont root prend les droits
#4eme arg: les commandes aux quelles user aura droit
#-----------------------
HOMEDIR=${HOME}
##--
SCRIPT_DIR='ophodoo-admin.sh'
SERVER_NAME='odoogoeen'
SERVER_PATH='/home/lof/ODOO'
REPOSITORY_PATH='/home/lof'
USER_NAME='openerp'
echo "SERVER:$HOMEDIR/$SERVER_DIR/$SERVER_NAME"
#CURRENT_USER=lof

##--

REPOSITORY=$HOMEDIR/$DIR_NAME
PROD_BRANCH='devfromscratch70'
UPSTREAM='upstream'

SERVER_BCK='backup'
##--
FILESTORE_DIR=filestore
##--
SUFFIXE=$(date +'%F_%T')
echo "SUFFIXE: $SUFFIXE"
##--
echo "BEFORE, MAKE A DUMP"
cd $HOMEDIR/$SCRIPT_DIR
./dump-oo.sh

##--
echo 'shutdown odoogoeen service'
service odoo-server stop

##--
# Copy dir_server prod to dir_server prod last
# so if there is a problem it's easy to go back
rsync -avz --progress -h $HOMEDIR/$SERVER_DIR/$SERVER_NAME/ $HOMEDIR/$SERVER_DIR/$SERVER_NAME.last
rm -r $HOMEDIR/$SERVER_DIR/$SERVER_NAME


##--
# Update the server repository
# Change to the branch you want
# git checkout branch namebranch
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