#! /bin/bash

#////////////////////////////////////////////////////////////////////////////////////#
# Script de dump de la database                                                      #
# Par Thierry Godin : 2013-06-23                                                     #
# http://thierry-godin.developpez.com/                                               #
# derniere MAJ : 2013-11-25                                                          #
# modifié le : 22/07/2015 
# par laurent FRANCOIS                                                               #
# Script: dump on the server of the database: dbname                                 #
#                                                                                    #
# Sauvegarde sur le serveur                                                          #
#                                                                                    #
# Script à mettre en CHMOD : 0755  ????                                              #
# Et à exécuter en 'lof'                                                             #
#                                                                                    #
#   Utilisation :                                                                    #
#   ------------- 
#       ssh leserveur openerp                                                                    #
#       cd /home/lof/ophodoo-admin.sh                                                   #
#       ./dump-oo.sh                                                                 #
#                                                                                    #
#////////////////////////////////////////////////////////////////////////////////////#

# ---------------------------------------------------------------------------------- #
# !!!                                IMPORTANT                                     !!!
# ---------------------------------------------------------------------------------- #
#                                                                                    #
# Modifier le fichier pg_hba.conf de PostgreSQL pour autoriser la connexion          #
# sans mot de passe en local                                                         #
#                                                                                    #
# Emplacement du fichier = /etc/postgresql/9.1/main/pg_hba.conf :                    #
# Rajouter ou modifier la ligne ci-dessous :                                         #
#                                                                                    #
# TYPE  DATABASE        USER            ADDRESS                 METHOD               #
# local   all          openerp                                  trust                #
#                                                                                    #
# ---------------------------------------------------------------------------------- #


odoouser='openerp'
dbname='goeen001'
# Fichier de LOG
LOG_FILE='/var/log/openerp/odoo_backup.log'
# bck root directory
homedir=${HOME}
bckdirname='dump.bck'
bckroot=$homedir/$bckdirname

#create bck rootdirectory
# Create the directory for bck
if [ ! -d $bckroot ]; then
    echo 'Creation du directory de backup :'$bckroot
    mkdir $bckroot
fi

# Create a dump of database.
NOW=`date +%F-%T`
bckfile=$bckroot/$dbname-$NOW.dump
echo 'Dump will be saved on:' $bckfile
# pg_dump -Fc $dbname > $bckfile OK for dev machine not on prod server
pg_dump -U $odoouser -Fc $dbname -h 127.0.0.1 > $bckfile
# il faut specifier le -h car c'est en peer.
#pour l'instant odoouser est en trust 
# il va falloir le changer.

# show the dump and there size
tree -sh $bckroot

# le probleme avec ce script c'est qu'il faut faire un rsync depuis le server 
# sur un autre poste pour faire une sauvegarde.
# donc faire un echange de clef pour ne pas avoir à rentrer un password.

## OK fonctionne en local dev mais la restauration n'a pas été testé.

 
###suppression des sauvegardes trop anciennes.
## FIND=`which find`
## RM=`which rm`
## days_rotation=14
## $FIND $LPATH -mtime +$days_rotation -exec $RM () -f \;
## synchronisation avec le FTP:
## $LFTP -u $ltp_user,$lftp_pass $lftp_host -p -$lftp_port -e "mirror -R --delete $bckroot $lftp_target && quit"
## LFTP='$(which lftp)'
## configuration du FTP 
## installer lftp
## lftp_prot='IP du ftp'
## lftp_port='port du ftp'
## lftp_user='user du ftp'
## lft_pass='password'
## lftp_target='repertoire de dstination sur le ftp'


## RESTAURATION ##
## to drop the database and recreate it
## dropdb goeen001
## pg_restore -C -d postgres goeen.bck.dump
##
## to reload the dump in a new database
## creatdb -T template0 newdb
## pg_restore -d newdb goeen.bck.dump # msg d'erreur mais parait ok a voir dans la vraie vie.
