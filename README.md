#ophodoo-admin

This is a collection of bash scripts that enable:

**dump-oo.sh** : -* pg_dump of the database on the server. Must be run on the server.

 **rsync-filestore-backups.sh**; -* backup the filestore directory in a remote backup server. 
 Must be run on the remote backup server.
 
**OpenERP_7_Admin.sh** - one command line installation for OpenERP 7.0 server instances
 
 **OpenERP_7_Copy.sh** - one command line backup of production server instance and copy 
 of a testing serv


# /ODOO/odoo7
c'est la branch 7.0 de ma fork odoo
# /ODOO/odoo8
c'est la branch 8.0 de ma fork odoo

je pense qu'elles ne servent à rien et que je peux les détruire. Car je ne veux pas développer odoo.
C'est la partie server. maintenant je vais l'installer sous /opt/odoo/odoo7/odoo7-server et odoo8/odoo8-server

# /ODOO/oph_odoo7
 uniquement la partie OPH 

Je pense que sur les postes de travail je peux avoir plusieurs system de fichier par version mais par contre au niveau de github une seule suffit je pense.

# Administration de postgresql
## Les utilisateurs
il faut être root pour se loguer à postgres sans avoir à rentrer un password. Le compte Postgres Unix est vérouillé (aucun password ne marchera). Ce qui veut dire que seul root peut `su` vers ce compte.
```
$su
#su - postgres
```
ou
```
$sudo su - postgres
```
##les passwords dans postgresq
###superuser password
Au départ il y a un seul superuser password. Il vérouille la base de donnée elle même. Il est mis en place pendant l'installation initiale. Et on peut le changer avec pgadmin ou avec une requete SQL:
```
ALTER USER postgres WITH PASSWORD 'VeryVerySecret';
```
##service password.
Postgresql tourne sur un compte système spécial. Ce compte est créé lors de l'installation. Il s'appelle postgres. Dans linux ce compte est mis en place sans password. et il ne faut pas s'en occuper.

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

Par defaut on peut se connecter à postgres si username  de l'utilisateur linux est le même que le postgres username.
Pour se connecter à la base de donnée la seule facon de faire c'est:
```
$su
#su postgres
#psql unnomdedatabaseexistant (comme template0)
```
psql template0  
psql: FATAL:  database "template0" is not currently accepting connections  
psql template1 OK  


Mais on aimerait bien pouvoir se connecter en tant qu'utilisateur linux habituel. Il y a plusieurs facon de faire. 
Pour permettre à des utilisateurs locaux d'accéder à la base de donnée il faut éditer /etc/postgresql/pg_hba.conf.
Mais une fois qu'on a autorisé les users à entrer dans la database ils doivent aussi exister dans la database pour pouvoir se connecter.

```
#su - postgres
#createuser unnomdeuser
```
Comment supprimer un role:
```
DROP ROLE IF EXISTS nom_de_role
```
Les roles se trouvent dans la table : **pg_roles**
```
#su - postgres 
$psql <nom d'une database>
```
Postgres utilise les roles pour les authentifications et autorisations. Postgres après installation utilise "ident" pour
l'identification c'est à dire que le mot de passe est le même que celui de linux.

* pour connaitre la liste des roles: \\du
* pour connaitre la liste des tables: \dt
* pour connaitre la liste des database: \l
* pour se connecter à une autre database: \c 
* pour avoir des infos sur la connection : \conninfo


##Comment faire un dump sur le server?
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

## Comment connaitre sa version de postgresql?
```
#select version();
```

## pg_lscluster
## pg_conftool show all
## pg_isready -h localhost -p 5432(5433)
Quand on utilise psql sans donner de nom de machine ou ip avec -h, il passe par le socket c'est donc la ligne # "local" is for Unix domain socket connections only 
du fichier pg_hba.conf qui est utilisée

# Comment savoir si le serveur postgresql est actif
`service postgresql status` 
mais ne donne pas le port  
## pour connaitre le port sur lequel écoute le seveur postgresl
```
netstat -natup | grep post
```
## plus simple
```
pg_isready
```

# Comment faire des rotations de fichiers et de directory

https://pypi.python.org/pypi/rotate-backups#features
à installer avec:
pip install rotate-backups

et je n'ai pas testé mais cela à l'air pas mal.

# https://github.com/frouty/odoo.git
c'est le fork de odoo 
ne jamais le modifier.
ne jamais faire un git push dedans.

# https://github.com/frouty/oph_odoo.git
c'est le repository avec uniquement l'ophtalmologie.
pour l'instant il n'y a que la branche 7.0 qui est la branch de prod du 11/06/2018

Il semble que je ne peux pas utiliser ce script pour installer la 7.0 car aeroo report 7.0 n'existe pas. Il n'y a que la 8.0 et la 11.O oir aerireport et la version 8.0 de oph_odoo n'est pas fonctionnel.

## 
J'ai réussi à installer une 7.0 avec le script install_openerp70.sh.
Je lance le server avec la commande ` ./openerp-server --addons-path addons`   
Il faut utiliser la database odoogoeenjuin17 avec login admin passwd easyfamily
J'ai pas l'impression que le init script fonctionne. Je n'arrive pas a voir le log. 

## sur saphir
je n'arrive pas utiliser le /etc/init.d script pour lancer odoo. 
Ca marche en /opt/odoo7-server/openerp-server
J'ai essaye en installant le scrip de la machine de prod et pareil rien ne se passe.
C'était un probleme de droit sur /etc/odoo directory.s
su chmod 755 /etc/odoo

## j'ai des choses sur les options pour la commande CLI openerp-server

## on peut générer un fichier de conf 
avec opener-server --addons-path addons -s 
ensuite faire un locate openerp-serverrc
 pour voir le fichier généré.

## quels sont les droits à mettre pour le fichier de conf.
TODO

## Je pense que le script installopenerp70.sh est ok
Mais reste le probleme du repository qui est maintenant oph_odoo avec toutes les branches. la 8 la 7 et les branches de dev de fix....
Ma branche de prod est la branch prod du repository https://github.com/frouty/odoogoeen.git (push)
j'aimerai que cette branch devienne la branch 7.0 de https://github.com/frouty/oph_odoo.git
Normalement j'ai fait ce qu'il faut pour ne garder d'odoogoeen que les fichiers pour les modules oph.
Je l'ai poussé dans oph_odoo. mais je n'ai que la branch prod pour l'instant. Je checkout 7.0 depuis prod. 
Maintenant il faudrait que je teste mon script d'installation sur la linuxbox.
je n'ai pas osé le faire dans linuxbox de peur de le casser.
Je l'ai donc fait dans le nouveau chassis odoo.

# A faire pour le filestorage. TODO. 
Pour il n'y a pas de filestorage dans le nouveau chassis
mkdir /var/odooattachment.
chown odoouser:odoouser /var/odooattachment
ln -s /openerp/filestore /var/odooattchment
on récupere tous les attachments 
rsync-copy openerp/filestorage/* /var/odooattachment 
on verifie avec un tree -gup /var/odooattachment que tout va bien

Ensuite il faudra créer un scipt de back de /var/odooattachment.

# depuis jessie qui est la version qui fait tourner openerp 7.0 en prod 
systemd est utilisé pour gérer les daemon. 
systemctl start|stop|restart|reload|status
## enable/disable daemon au boot
systemctl enable|disabble| is-enable ledaemon
disable m'enleve les symlink dans les rcx.dsi on veut le desactiver de suite et au reboot --now disable. marche pas
#avant jessie on utiliser les  scipts  system V style. 
cela permet de faire fonctionner les scripts conditionnelement suivant le runlevel.
## on controle avec :
service nomdudaemon start|stop|restart|relaod|status
## on enable/disable avec :
udpadte-rc.d <daemon> disbable|enable

