#!/bin/sh 

#------------------------------------------------------#
#  SCRIPT DE SAUVEGARDE DE L'ARBORESCENCE FILESTORE
#  Par Laurent FRANCOIS
#  Date: aout 2015
#  Le script effectue une suavegarde de l'arborescence filestore
#  donc de tous les documents (pdf,odt...) du serveur odoo
#  en local. 

# RPATH is the path of the filestore directory on the server.
# RHOST is the IP's server
# LPATH is the path where you want to save the filestore bck on local
#------------------------------------------------------#

RSYNC=/usr/bin/rsync 
SSH=/usr/bin/ssh 
KEY=/home/lfs/cron/linuxbox-rsync-key 
RUSER=lof
RHOST=192.168.2.110 
RPATH=/home/lof/ODOO/odoogoeen/openerp/filestore/
LPATH=/home/lfs/filestore.bck
#NOW = $(date+"%F-%T")
NOW=`date +%F-%T`
## -------------------------  ##
echo "LPATH:" $LPATH
# Create the directory for bck
if [ ! -d $LPATH ]; then
    echo 'Creation du directory de backup :'$LPATH
    mkdir $LPATH
fi

echo "Starting the backup of filestore from odoo server to localhost"
sleep 2
$RSYNC -azv -e "$SSH -i $KEY" $RUSER@$RHOST:$RPATH $LPATH/filestore.$NOW
echo "-------------------"
echo "The size of this last backup of filestore directory is:"
du --summarize -h $LPATH/filestore.$NOW
echo "-------------------"
## TODO 
## rotate filestore.bck:
## FIND='$(which find)'
## RM='$(which rm)'
## days_rotation=14
## $FIND $LPATH -mtime +$days_rotation -exec $RM () -f \;
## set hourly when it's ok by day.
