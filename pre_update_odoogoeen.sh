#! /bin/bash

#////////////////////////////////////////////////////////////////////////////////////#
# Script for backup of the production version of odoogoeen                           #
# to be run before an update                                                         #
#                                                                                    #
# derniere MAJ :                                                                     #
# Created : 06/08/2015                                                               #
# par laurent FRANCOIS                                                               #
# Le script effectue une sauvegarde complète du repertoire odoogoeen de production   #
# So if there is a problem during update you can reverse easily                      #
# without usint git.                                                                 #
#                                                                                    #
# In this backup you have the last filestore                                         #
# with all the docs, odt, pdf ... for patients                                       #
#                                                                                    #
# Script à mettre en CHMOD : 0755 je ne sais pas                                     #
#                                                                                    #
#                                                                                    #
#   Utilisation :                                                                    #
#   -------------                                                                    #
#   Pour executer le fichier sous Debian                                             #
#   ssh to the server                                                                #
#   su lof                                                                           #
#   cd /home/lof/ophodoo-admin.sh/                                                   #
#   ./pre_update_odoogoeen.sh                                                        #
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

## Verify your not root
##-- Check if root
if [ "$EUID" -eq 0 ]; then
	echo "This script should --NOT-- be run as root and you're root"
	exit 1
fi

##-- update the ophodoo-admin.sh git rep
## -- check if it's update
cd $HOMEDIR/$REP_ADMIN

LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})

if [ $LOCAL = $REMOTE ]; then
    echo "Up-to-date"
    echo "Keep on"
elif [ $LOCAL = $BASE ]; then
    echo "Need to pull"
    echo "I'll do it for you"
    echo "But you must restart this script"
    git pull origin master
    exit 1
elif [ $REMOTE = $BASE ]; then
    echo "Need to push"
    echo "exiting"
    exit 1
else
    echo "Diverged"
    echo "exiting"
    exit 1
fi


	##-- update the odoo git rep
cd $HOMEDIR/$REP_ODOO
printf "Update the odoogoeen server\n"
git fetch origin
printf "Here are the branch:\n"
git branch -a
## --chose the branch
read -p "Choose the branch you want to use for update: " BRANCH
git checkout ${BRANCH}
## --check on what branch we are
printf "We are now on branch:"
git branch
## -- 
echo "Backing up the last running odoogoeen directory of the server, please wait..."
echo "Could take some times"
sleep 3
rsync -avz --progress -h $SERVER_PATH/$SERVER_NAME/ $HOMEDIR/$BCKDIR.$NOW

echo -e "\nThe last odoogoeen server backup directories are:"
ls -alh $HOMEDIR/$BCKDIR*

echo -e "\nSize of the last backup odoogoeen directories are:"
du -h --summarize $HOMEDIR/$BCKDIR*/

echo -e "\nSize of the last bck filestore directory is:"
du -h --summarize $HOMEDIR/$BCKDIR.$NOW/$FILESTORE_PATH

echo -e "\nNow you can start the update script\n"
echo -e "For that, you may type:\n"
echo -e "su"
echo -e "./update_odoo.sh"
echo -e "You will update to the :"
cd $HOMEDIR/$REP_ODOO
git branch


exit 0