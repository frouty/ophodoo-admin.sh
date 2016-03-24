#!/bin/bash

#fixed parameters


#check if root 
f [ "$EUID" -ne 0 ]; then
	echo "This script should be run as root and you're not root"
	exit 1
fi
case "$1" in
	install)
		# Install required depedencies
		echo -e "\n---- update aptitude ----"
		aptitude update && aptitude dist-upgrade
		echo -e "\n---- install the ssh server ----"
		aptitude install openssh-server
		echo -e "\n---- install postgresql ----"
		aptitude install postgresql
		
		echo -e "\n---- install git ----"
		aptitude install git gitk
		
#		echo -e "\n---- install the python package index: python-pip ----"
#		aptitude install python-pip
				
		echo -e "\n---- install the necessary python libraries for the server"
		aptitude install sudo apt-get install python-cups python-dateutil python-decorator python-docutils python-feedparser python-gdata python-geoip python-gevent python-imaging python-jinja2 python-ldap python-libxslt1
python-lxml python-mako python-mock python-openid python-passlib python-psutil python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-pypdf python-reportlab python-requests \
python-simplejson python-tz python-unicodecsv python-unittest2 python-vatnumber python-vobject python-werkzeug python-xlwt python-yaml wkhtmltopdf

#		echo -e "\n---- install the google data python library: gdata ----"
#		pip install gdata
		
	start)
		echo -e "work in progress"
esac