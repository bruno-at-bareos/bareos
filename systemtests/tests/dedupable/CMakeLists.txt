#   BAREOS® - Backup Archiving REcovery Open Sourced
#
#   Copyright (C) 2024-2024 Bareos GmbH & Co. KG
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

get_filename_component(BASENAME ${CMAKE_CURRENT_BINARY_DIR} NAME)

create_systemtest(${SYSTEMTEST_PREFIX} ${BASENAME})

get_test_property(${SYSTEMTEST_PREFIX}${BASENAME} DISABLED ISDISABLED)
if(NOT ISDISABLED)
  # it would be better if we could just check if create_systemtest succeeded
  set_tests_properties(
    system:dedupable:create-backup
    PROPERTIES FIXTURES_SETUP "system:dedupable:backup-job-fixture"
  )
  set_tests_properties(
    system:dedupable:restore-file
    PROPERTIES FIXTURES_REQUIRED
               "system:dedupable:backup-job-fixture;system:dedupable-fixture"
  )
  set_tests_properties(
    system:dedupable:restore-dir
    PROPERTIES FIXTURES_REQUIRED
               "system:dedupable:backup-job-fixture;system:dedupable-fixture"
  )
  set_tests_properties(
    system:dedupable:full-restore
    PROPERTIES FIXTURES_REQUIRED
               "system:dedupable:backup-job-fixture;system:dedupable-fixture"
  )
  set_tests_properties(
    system:dedupable:purge-truncate PROPERTIES FIXTURES_REQUIRED
                                               "system:dedupable-fixture"
  )
endif()
