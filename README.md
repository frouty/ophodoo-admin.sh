ophodoo-admin
=============

 This is a collection of bash scripts that enable:
 
 dump-oo.sh : -* pg_dump of the database on the server. Must be run on the server.
 
 rsync-filestore-backups.sh; -* backup the filestore directory in a remote backup server. 
 Must be run on the remote backup server.
 
 OpenERP_7_Admin.sh - one command line installation for OpenERP 7.0 server instances
 
 OpenERP_7_Copy.sh - one command line backup of production server instance and copy 
 of a testing server instance to a production server instance.
 
Au depart on ne peut pas se connecter à postgresql avec l'utilisateur postgres.

1* donner un password à postgres
```
$su
#su postgres
$psql
postgres=#\password postgres
```
2* editer le pg_hba.conf

------

Par defaut on peut se connecter à postgres si username est le meme que le postgres username.
Pour se connecter à la base de donnée la seule facon de faire c'est:
```
$su
#su postgres
#psql unnomdedatabaseexistant (comme template0)
```
Mais on aimerait bien pouvoir se connecter en tant qu'utilisateur linux habituel. Il y a plusieurs facon de faire. 
Pour permettre à des utilisateurs locaux d'accéder à la base de donnée il faut éditer /etc/postgresql/pg_hba.conf
Mais une fois qu'on a autorisé les users à entrer dans la database ils doivent aussi exiter dans la database pour pouvoir se connecter.
```
#su postgres
#createuser unnomdeuser
```
Postgres utilise les roles pour les authentifacation et autorisation. Postgres apres installation utilise "ident" pour
l'indentification c'est à dire que le mot de passe est le meme que celui de linux.

* pour connaitre la liste des roles: \\du
* pour connaiter la liste des tables: \dt
* pour connaitre la liste des database: \l
* pour se connecter à une autre database: \c 
* pour avoir des infos sur la connection : \conninfo


Comment faire un dump sur le server?
```
lof$ pg_dump -Fc goeen001 > test.dump ne marche pas.
```
par contre sur la machine de dev pas de souci

sur le dev 
```
psql -U lfs -h 127.0.0.1 -d devaout -W 
```
avec le password = "password linux" ca marche.
si je mets dans pg_hba.conf
```
host    all             openerp             127.0.0.1/32            trust
```
si je mets md5 ca ne marche pas.
