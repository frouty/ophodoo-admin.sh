#!/bin/bash
#-----------------------
#update the version of odoo
#Utiliser des chemins absolu pour les dossiers et des chemins relatif pour les nom de 
#$CHEMIN_DU_DOSSIER/$NOM_DU_FICHIER
#
#
# ---UTILISATION---
# cd /home/lof/ophodoo-admin.sh/
# git pull origin master
# su 
# ./update_odoo.sh
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

##--
# Check if root
if [ "$EUID" -ne 0 ]; then
	echo "This script should be run as root and you're not root"
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
"echo "rsync-copy the $SERVER_PATH\/$SERVER_NAME\/ to $SERVER_PATH\/$SERVER_NAME.last"
sleep 2
rsync -avz --progress -h $SERVER_PATH/$SERVER_NAME/ $SERVER_PATH/$SERVER_NAME.last
echo "rm the $SERVER_PATH/$SERVER_NAME server"
sleep 2
rm -r $SERVER_PATH/$SERVER_NAME


##--
# Update the server repository
# Change to the branch you want
# git checkout branch namebranch
echo "cd $REPOSITORY_PATH/$SERVER_NAME"
sleep 2
cd $REPOSITORY_PATH/$SERVER_NAME

printf "\n Here are the branch of this repository:\n"
git branch -v
read -p "Choose the branch for checkout" BRANCH
git checkout $BRANCH
printf "Update from remote repository"
git pull origin $BRANCH

# then copy the repository
echo "then copy the repository to the server path"
sleep 2
rsync -avz --progress -h $REPOSITORY_PATH/$SERVER_NAME $SERVER_PATH/$SERVER_NAME


##--
# recuperer le filestore
echo "copier filestore from $HOMEDIR/$SERVER_DIR/$SERVER_NAME.last/openerp/filestore to $HOMEDIR/$SERVER_DIR/$SERVER_NAME/openerp/"
sleep 2
rsync -avz --progress -h $SERVER_PATH/$SERVER_NAME.last/openerp/filestore $SERVER_PATH/$SERVER_NAME/openerp/
##--
chown -R $USER_NAME:$USER_NAME $SERVER_PATH/$SERVER_NAME

#relancer le service 
service odoo-server start
##--
tail -f $LOG_PATH/$LOG_FILE

exit 0