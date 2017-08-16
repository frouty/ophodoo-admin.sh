#!/bin/bash
#install the version 8.0 d'ODOO

REP='/home/lof/odoo80'
cd REP
pip install requirement
aptitude install libxslt1-dev
aptitude show libxml2-dev    
aptitude install postgresql-server-dev-X.Y
aptitude install libldap2-dev
aptitude install libsasl2-dev 

# pour le rt5100
aptitude install python-netifaces