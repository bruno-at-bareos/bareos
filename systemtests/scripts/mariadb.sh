#!/bin/bash

#   BAREOS® - Backup Archiving REcovery Open Sourced
#
#   Copyright (C) 2022-2025 Bareos GmbH & Co. KG
#
#   This program is Free Software; you can redistribute it and/or
#   modify it under the terms of version three of the GNU Affero General Public
#   License as published by the Free Software Foundation and included
#   in the file LICENSE.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#   Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
#   02110-1301, USA.

#
# A set of useful functions to be sourced to run mysql/mariadb.
#
# Requirements:
#   Environment variables:
#     dbHost
#     MARIADB_DAEMON_BINARY
#     MARIADB_CLIENT_BINARY
#   defaults-file named "mariadbdefaults" in test directory.
#
# See tests/py3plug-fd-mariabackup/
# and especially tests/py3plug-fd-mariabackup/mariadbdefaults.in
# as a reference.
#

mariadbd_cleanup()
{
    mariadbd_server_stop

    rm -Rf mysql/data/*
    mkdir -p mysql/data/
    # directory for socket, depending on length (socket length is limited)
    rm -Rf ${dbHost}
    mkdir -p ${dbHost}
}

mariadbd_init()
{
    # creates "my.cnf" configuration file.
    # sets MARIADB_CLIENT variable.

    mariadbd_cleanup

    # initialize mariadb db
    if ${MARIADB_DAEMON_BINARY} --verbose --help | grep -q initialize-insecure; then
        echo "MariaDB init with --initialize-insecure"
        ${MARIADB_DAEMON_BINARY} --defaults-file=mariadbdefaults --initialize-insecure --user="${USER}" 2>&1 | tee mysql/mariadb_init.log
        {
            echo "[client]"
            echo "socket=${dbHost}/mysql.sock"
            echo "user=root"
        } > my.cnf
        MYSQL_CLIENT="${MARIADB_CLIENT_BINARY}} --defaults-file=my.cnf"
    else
        echo "MariaDBL init with ${MARIADB_INSTALL_DB_SCRIPT}"
        ${MARIADB_INSTALL_DB_SCRIPT} --auth-root-authentication-method=socket --user="${USER}" --auth-root-socket-user="${USER}" --defaults-file=mysqldefaults > mysql/mysql_init.log
        {
            echo "[client]"
            echo "socket=${dbHost}/mysql.sock"
            echo "user=${USER}"
        } > my.cnf
        MYSQL_CLIENT="${MARIADB_CLIENT_BINARY}} --defaults-file=my.cnf"
    fi
}

mysql_server_start()
{
    if ! [ "${MYSQL_CLIENT:-}" ]; then
        echo "MYSQL_CLIENT not defined. mysql_init not called?"
        return 1
    fi

    if ! [ -e my.cnf ]; then
        echo "Config file 'my.cnf' does not exist. mysql_init not called?"
        return 1
    fi

    "${MYSQL_DAEMON_BINARY}" --defaults-file=mysqldefaults >mysql/mysql.log 2>&1 &

    tries=60
    printf "waiting for MySQL server to start "
    while ! ${MARIADB_CLIENT} <<< "select version();" >/dev/null 2>&1; do
        [ $((tries-=1)) -eq 0 ] && {
            echo "Could not start MySQL server"
            cat mysql/mysql.log
            mysql_cleanup
            exit 1
        }
        printf "."
        sleep 1
    done
    printf " OK\n"
}

get_mysql_server_pid()
{
    if [ -f "mysql/mysqld.pid" ]; then
        cat "mysql/mysqld.pid"
    fi
}

mysql_server_stop()
{
    printf "shutdown MySQL server "
    local PID=$(get_mysql_server_pid)
    if [ "$PID" ]; then
        kill $PID
        waitpid $PID
    fi
}
