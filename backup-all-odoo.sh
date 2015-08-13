#! /bin/bash

#////////////////////////////////////////////////////////////////////////////////////#
# Script de sauvegarde complète d'OpenERP                                            #
# Par Thierry Godin : 2013-06-23                                                     #
# http://thierry-godin.developpez.com/                                               #
# derniere MAJ : 2013-11-25                                                          #
# modifié le : 22/07/2015 
# par laurent FRANCOIS                                                               #
# Le script effectue une sauvegarde complète des fichiers OpenERP                    #
# et du fichier de configuration du serveur openerp-server.conf                      #
# ainsi que de la base de données au format TAR                                      #
#                                                                                    #
# Sauvegarde en local dans le répertoire de l'utilisateur openerp                    #
#                                                                                    #
# Script à mettre en CHMOD : 0755                                                    #
# Et à exécuter en 'root'                                                            #
#                                                                                    #
#   Utilisation :                                                                    #
#   -------------                                                                    #
#   Pour exécuter le fichier sous Debian                                             #
#   Placer le fichier dans le répertoire /root                                       #
#   Ouvrir une invite de commande et entrer                                          #
#       cd /root                                                                     #
#       bash ./backup-all-odoo.sh                                                   #
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

# odoo dbname
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
# pg_dump -Fc $dbname > $bckfile OK for dev machine
pg_dump -U $odoouser -Fc $dbname -h 127.0.0.1 > $bckfile
# il faut specifier le -h car c'est en peer.
#pour l'instant odooser est en trust 
# il va falloir le changer.

tree -sh $bckfile

## OK fonctionne en local dev mais la restauration n'a pas été testé.
## n'a pas été testé sur le serveur.
 
###suppression des sauvegardes trop anciennes.
## FIND='$(which find)'
## RM='$(which rm)'
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


## pg_dump -Fc goeen001 > goeen001.bck.dump

## to drop the database and recreate it
## dropdb goeen001
## pg_restore -C -d postgres goeen.bck.dump
##
## to reload the dump in a new database
## creatdb -T template0 newdb
## pg_restore -d newdb goeen.bck.dump # msg d'erreur mais parait ok a voir dans la vraie vie.

## Qd je me connecte en lof sur le server
## je ne peux pas lancer un pg_dump. Se plaint que le role lof n'existe pas.