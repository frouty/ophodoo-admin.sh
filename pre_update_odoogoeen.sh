#! /bin/bash

#////////////////////////////////////////////////////////////////////////////////////#
# Script for backup of the production version of odoogoeen
# to be run before an update                                                         #
#                                                                                    #
# derniere MAJ :                                                                     #
# Created : 06/08/2015 
# par laurent FRANCOIS                                                               #
# Le script effectue une sauvegarde complète du repertoire odoogoeen
# So if there is a problem during update you can reverse easily                         #
# without usint git.
# 
# In this backup you have the last filestore                                         #
# with all the docs, odt, pdf ... for patients                                       #
#                                                                                    #
# Script à mettre en CHMOD : 0755 je ne sais pas                                     #
# Et à exécuter sur le server en 'root' je ne sais pas                               #
#                                                                                    #
#   Utilisation :                                                                    #
#   -------------                                                                    #
#   Pour exécuter le fichier sous Debian 
#   ssh to the server
#   Placer le fichier dans le répertoire /root                                       #
#   Ouvrir une invite de commande et entrer                                          #
#       cd /root                                                                     #
#       bash ./       
#                                                                                    #
#                                                                                    #      
#////////////////////////////////////////////////////////////////////////////////////#

# ---------------------------------------------------------------------------------- #
NOW=$(date +"%F-%T")
HOMEDIR=${HOME} # home directory in the odoo server
SERVER_ROOT='ODOO'
SERVER_PATH=$HOMEDIR/$SERVER_ROOT
SERVER_NAME='odoogoeen'
REP_ODOO='odoogoeen' #we could rename it in INSTANCE
REP_ADMIN='ophodoo-admin.sh'
SUF='prod'
BCKDIR=$SERVER_NAME.$SUF
FILESTORE_PATH='openerp/filestore'
# ----------------------------------------------------------------------------------- #
echo "NOW is: $NOW"
## Verify your not root
##-- Check if root
if [ "$EUID" -eq 0 ]; then
	echo "This script should --NOT-- be run as root and you're not root"
	exit 1
fi

##-- update the odoo rep
cd $HOMEDIR/$REP_ODOO
printf "\n Here are the branch of this repository:\n"
git branch -v
## --chose the branch
read -p "Choose the branch you want to use for update: " BRANCH
git checkout $BRANCH
printf "Update from remote repository"
git pull origin $BRANCH

##-- update the ophodoo-admin.sh rep
cd $HOMEDIR/$REP_ADMIN
git pull origin master

echo "Backing up the last running odoogoeen directory of the server, please wait..."
sleep 3
rsync -avz --progress -h $SERVER_PATH/$SERVER_NAME/ $HOMEDIR/$BCKDIR.$NOW

echo -e "\nThe last odoogoeen server directories are:"
ls -alh $HOMEDIR/$BCKDIR*

echo -e "\nSize of the last backup odoogoeen directories are:"
du -h --summarize $HOMEDIR/$BCKDIR*/

echo "\nSize of the last bck filestore directory is:"
du -h --summarize $HOMEDIR/$BCKDIR.$NOW/$FILESTORE_PATH

echo "Now you can start the update script"
exit 0