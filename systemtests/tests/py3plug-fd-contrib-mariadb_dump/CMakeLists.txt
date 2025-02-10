#   BAREOS® - Backup Archiving REcovery Open Sourced
#
#   Copyright (C) 2021-2025 Bareos GmbH & Co. KG
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

# This test requires the following variables to be set:
#
# -D MARIADB_DAEMON_BINARY=/usr/sbin/mariadbd -D
# MARIADB_CLIENT_BINARY=/usr/bin/mariadb"

get_filename_component(BASENAME ${CMAKE_CURRENT_BINARY_DIR} NAME)
if(TARGET python3-fd
   AND MARIADB_DAEMON_BINARY
   AND MARIADB_CLIENT_BINARY
)
  create_systemtest(${SYSTEMTEST_PREFIX} ${BASENAME})
else()
  create_systemtest(
    ${SYSTEMTEST_PREFIX}
    ${BASENAME}
    DISABLED
    COMMENT
    "
    no python3-fd or MARIADB_DAEMON_BINARY or MARIADB_CLIENT_BINARY not set.)
    example:
    cmake
    -D MARIADB_DAEMON_BINARY=/usr/sbin/mariadbd
    -D MARIADB_CLIENT_BINARY=/usr/bin/mariadb"
  )
endif()
