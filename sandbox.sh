#!/bin/bash


OE_VERSION='7'
OE_USER='odoo'
OE_CONFIG="$OE_USER$OE_VERSION-server"

## install an init.d scritp
echo -e "* Create init file"
echo '#!/bin/sh' >> ~/$OE_CONFIG
echo '### BEGIN INIT INFO' >> ~/$OE_CONFIG
echo "# Provides:             odoo-server" >> ~/$OE_CONFIG
echo "# Required-Start:       $remote_fs $syslog" >> ~/$OE_CONFIG
echo "# Required-Stop:        $remote_fs $syslog" >> ~/$OE_CONFIG
echo "# Should-Start:         $network" >> ~/$OE_CONFIG
echo "# Should-Stop:          $network" >> ~/$OE_CONFIG
echo "# Default-Start:        2 3 4 5" >> ~/$OE_CONFIG
echo "# Default-Stop:         0 1 6" >> ~/$OE_CONFIG
echo "# Short-Description:    Complete Business Application software" >> ~/$OE_CONFIG
echo "# Description:          Odoo is a complete suite of business tools." >> ~/$OE_CONFIG
echo "# after creation: chmod 755 this file" >> ~/$OE_CONFIG
echo "#		  chown root: this file" >> ~/$OE_CONFIG
echo "# 		  update-rc.d this file defaults" >> ~/$OE_CONFIG
echo "### END INIT INFO" >> ~/$OE_CONFIG
echo "" >> ~/$OE_CONFIG
echo "PATH=/bin:/sbin:/usr/bin" >> ~/$OE_CONFIG
echo "DAEMON=$OE_HOME/$OE_USER$OE_VERSION/$OE_CONFIG/openerp-server" >> ~/$OE_CONFIG
echo "NAME=$OE_CONFIG" >> ~/$OE_CONFIG
echo "DESC=$OE_CONFIG" >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo # Specify the user name (Default: odoo).' >> ~/$OE_CONFIG
echo 'USER=$OE_USER' >> ~/$OE_CONFIG
echo '#USER=openerp' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# Specify an alternate config file (Default: /etc/odoo-server.conf).' >> ~/$OE_CONFIG
echo 'CONFIGFILE="/etc/$OE_USER/$OE_CONFIG.conf"' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# pidfile' >> ~/$OE_CONFIG
echo 'PIDFILE=/var/run/$NAME.pid' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# Additional options that are passed to the Daemon.' >> ~/$OE_CONFIG
echo 'DAEMON_OPTS="-c $CONFIGFILE"' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '[ -x $DAEMON ] || exit 0' >> ~/$OE_CONFIG
echo '[ -f $CONFIGFILE ] || exit 0' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'checkpid() {' >> ~/$OE_CONFIG
echo '    [ -f $PIDFILE ] || return 1' >> ~/$OE_CONFIG
echo '   pid=`cat $PIDFILE`' >> ~/$OE_CONFIG
echo '    [ -d /proc/$pid ] && return 0' >> ~/$OE_CONFIG
echo '   return 1' >> ~/$OE_CONFIG
echo '}' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'case "${1}" in' >> ~/$OE_CONFIG
echo '        start)' >> ~/$OE_CONFIG
echo '                echo -n "Starting ${DESC}: "' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                     start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '                          --chuid ${USER} --background --make-pidfile \' >> ~/$OE_CONFIG
echo '                          --exec ${DAEMON} -- ${DAEMON_OPTS}' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                  echo "${NAME}."' >> ~/$OE_CONFIG
echo '                 ;;' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '        stop)' >> ~/$OE_CONFIG
echo '                echo -n "Stopping ${DESC}: ' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                 start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '                       --oknodo' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                 echo "${NAME}."' >> ~/$OE_CONFIG
echo '                  ;;' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '        restart|force-reload)' >> ~/$OE_CONFIG
echo '                echo -n "Restarting ${DESC}: "' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '                        --oknodo' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                 sleep 1' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                 start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '                         --chuid ${USER} --background --make-pidfile \' >> ~/$OE_CONFIG
echo '                         --exec ${DAEMON} -- ${DAEMON_OPTS}'>> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '                echo "${NAME}."' >> ~/$OE_CONFIG
echo '                 ;;' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '       *)' >> ~/$OE_CONFIG
echo '               N=/etc/init.d/${NAME}' >> ~/$OE_CONFIG
echo '               echo "Usage: ${NAME} {start|stop|restart|force-reload}" >&2' >> ~/$OE_CONFIG
echo '               exit 1' >> ~/$OE_CONFIG
echo '              ;;' >> ~/$OE_CONFIG
echo 'esac' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'exit 0' >> ~/$OE_CONFIG

exit 1
