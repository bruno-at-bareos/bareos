#   BAREOS® - Backup Archiving REcovery Open Sourced
#
#   Copyright (C) 2019-2024 Bareos GmbH & Co. KG
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
message("Entering ${CMAKE_CURRENT_SOURCE_DIR}")

include(BareosConfigureFile)
bareos_configure_file(GLOB_RECURSE "resources/*.in")

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/resources/com.bareos.bareos-fd.plist
  DESTINATION "${scriptdir}"
  COMPONENT filedaemon
)

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/resources/uninstall-bareos
  DESTINATION "${scriptdir}"
  PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE
              WORLD_READ WORLD_EXECUTE
  COMPONENT common
)

# cpack settings
set(CPACK_PACKAGE_VENDOR "bareos")
set(CPACK_PACKAGE_NAME "bareos")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://www.bareos.com/")
set(CPACK_PACKAGE_VERSION_MAJOR "${BAREOS_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${BAREOS_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${BAREOS_VERSION_PATCH}")
set(CPACK_MONOLITHIC_INSTALL FALSE)
set(CPACK_COMPONENTS_ALL common filedaemon bconsole)

set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Bareos File Daemon")
set(CPACK_PACKAGE_DESCRIPTION_FILE
    "${CMAKE_CURRENT_SOURCE_DIR}/description.txt"
)

set(CPACK_PACKAGE_ICON "${CMAKE_CURRENT_SOURCE_DIR}/bareos-logo.png")

set(CPACK_PRODUCTBUILD_RESOURCES_DIR "${CMAKE_CURRENT_BINARY_DIR}/resources")

set(CPACK_RESOURCE_FILE_WELCOME
    "${CMAKE_CURRENT_BINARY_DIR}/resources/welcome.txt"
)
set(CPACK_RESOURCE_FILE_README
    "${CMAKE_CURRENT_BINARY_DIR}/resources/ReadMe.html"
)

set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE.txt")

set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${BAREOS_FULL_VERSION}")
set(CPACK_GENERATOR "productbuild")

# if unset, next points to goes to /Application
set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})

set(CPACK_PREFLIGHT_FILEDAEMON_SCRIPT
    "${CMAKE_CURRENT_BINARY_DIR}/resources/preinstall"
)
set(CPACK_POSTFLIGHT_FILEDAEMON_SCRIPT
    "${CMAKE_CURRENT_BINARY_DIR}/resources/postinstall"
)
set(CPACK_SET_DESTDIR TRUE)

include(CPack)
