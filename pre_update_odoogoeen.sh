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
NOW = $(date +"%F-%T")
HOMEDIR=${HOME} # home directory in the odoo server
SERVERROOT='ODOO'
SERVERDIR=$HOMEDIR/$SERVERROOT
SERVERDIRNAME='odoogoeen' #we could rename it in INSTANCE
SUF='prod'
BCKDIR=$SERVERDIRNAME.$SUF
FILESTORE_PATH='openerp/filestore'
# ----------------------------------------------------------------------------------- #
echo "DONT FORGET TO DUMP THE DATABASE"
echo "--- WARNING --- WARNING ---"
## On peut appeler le script de dump  pour faire cela à voir
## cd ./home/lof/ophodoo-admin.sh
## ./dump-oo.sh &
echo "we are closing the odoogoeen server"
service odoo-server stop

echo "Backing up the last running odoogoeen directory of the server, please wait..."
rsync-copy $SERVERDIR/$SERVERDIRNAME/ $HOMEDIR/$BCKDIR.$NOW

echo "The last odoogoeen server directories are:"
ls -alh $HOMEDIR/$BCKDIR*

echo "Size of the last backup odoogoeen directories are:"
du -h --summarize $HOMEDIR/$BCKDIR*/

echo "The size of the last bck filestore directory is:"
du -h --summarize $HOMEDIR/$BCKDIR.$NOW/$FILESTORE_PATH

echo "Now we are updating the production server directory"
echo "Renaming the production server directory to $SERVERDIRNAME.last"
mv $SERVERDIR/$SERVERDIRNAME $SERVERDIR/$SERVERDIRNAME.last
ls -alh $SERVERDIR/$SERVERDIRNAME

echo "Update the odoo server directory from $HOMEDIR/$SERVERDIRNAME to $SERVERDIR"
rsync-move $HOMEDIR/$SERVERDIRNAME $SERVERDIR/
ls -alh $SERVERDIR/$SERVERDIRNAME

echo "change ownership and group to $ODOOUSER"
chown -R $ODOOUSER:$ODOOUSER $SERVERDIR/$SERVERDIRNAME/

echo "Copy the last filestore tree files to the new file tree server"
rsync-copy $SERVERDIR/$SERVERDIRNAME.last/$FILESTORE_PATH/ $SERVERDIR/$SERVERDIRNAME/$FILESTORE_PATH

echo "the size of the filestore is:"
du -h --summarize $SERVERDIR/$SERVERDIRNAME/$FILESTORE_PATH

echo "Restart the server odoogoeen"
service odoo-server start
# show up the log so you can see if everything fine.
tail -f /var/log/openerp/odoo-server.log