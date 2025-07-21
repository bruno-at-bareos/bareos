-- update db schema from 2230 to 2240
-- start transaction
begin;

DROP VIEW IF EXISTS backup_unit_overview;
DROP VIEW IF EXISTS latest_full_size_categorized;

CREATE VIEW latest_full_size_categorized AS
SELECT
  c.name AS client,
  f.fileset AS fileset,
  j.jobbytes::bigint / 1000000 AS total_mb,
  CASE
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%mssqlvdi:%' THEN j.jobbytes::bigint / 1000000
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-mariabackup%' THEN j.jobbytes::bigint / 1000000
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-percona%' THEN j.jobbytes::bigint / 1000000
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-postgres%' THEN j.jobbytes::bigint / 1000000
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-ldap%' THEN j.jobbytes::bigint / 1000000
    WHEN f.filesettext ILIKE '%{%{%File%=%' THEN NULL::bigint
  END AS db_mb,
  CASE
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-vmware%' THEN j.jobbytes::bigint / 1000000
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-ovirt%' THEN j.jobbytes::bigint / 1000000
    WHEN f.filesettext ILIKE '%{%{%File%=%' THEN NULL::bigint
  END AS vm_mb,
  CASE
    WHEN f.filesettext ILIKE '%{%{%meta%=' THEN j.jobbytes::bigint / 1000000
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-libcloud%' THEN j.jobbytes::bigint / 1000000
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-qumulo%' THEN j.jobbytes::bigint / 1000000
    WHEN f.filesettext ILIKE '%{%{%File%=%' THEN NULL::bigint
  END AS filer_mb,
  CASE
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%' THEN NULL::bigint
    WHEN f.filesettext ILIKE '%{%{%File%=%' THEN j.jobbytes::bigint / 1000000
  END AS normal_mb,
  CASE
    WHEN f.filesettext ILIKE '%{%{%meta%=' THEN NULL::bigint
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%mssqlvdi:%' THEN NULL::bigint
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-mariabackup%' THEN NULL::bigint
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-percona%' THEN NULL::bigint
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-postgres%' THEN NULL::bigint
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-ldap%' THEN NULL::bigint
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-vmware%' THEN NULL::bigint
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-ovirt%' THEN NULL::bigint
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-libcloud%' THEN NULL::bigint
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-qumulo%' THEN NULL::bigint
    WHEN f.filesettext ILIKE '%{%{%File%=%' THEN NULL::bigint
    ELSE j.jobbytes::bigint / 1000000
  END AS unknown_mb,
  CASE
    WHEN f.filesettext ILIKE '%{%{%meta%=' THEN NULL
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%mssqlvdi:%' THEN NULL
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-mariabackup%' THEN NULL
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-percona%' THEN NULL
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-postgres%' THEN NULL
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-ldap%' THEN NULL
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-vmware%' THEN NULL
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-ovirt%' THEN NULL
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-libcloud%' THEN NULL
    WHEN f.filesettext ILIKE '%{%{%Plugin%=%python%:module_name=bareos-fd-qumulo%' THEN NULL
    WHEN f.filesettext ILIKE '%{%{%File%=%' THEN NULL
    WHEN f.filesettext ILIKE '%{%{%File%=%Plugin%=%' OR f.filesettext ILIKE '%{%{%Plugin%=%File%=%' THEN
      CASE WHEN LENGTH(f.filesettext) < 10 THEN '<empty>' ELSE f.filesettext END
    ELSE
      CASE WHEN LENGTH(f.filesettext) < 10 THEN '<empty>' ELSE f.filesettext END
  END AS filesettext
FROM job j
INNER JOIN client c
  ON c.clientid = j.clientid
INNER JOIN fileset f
  ON j.filesetid = f.filesetid
WHERE jobid IN (
  SELECT
    MAX(j.jobid) AS jobid
  FROM job j
  INNER JOIN fileset f
    ON j.filesetid = f.filesetid
  WHERE level = 'F'
    AND j.jobstatus IN ('T','W')
    AND j.type = 'B'
    AND j.jobbytes > 0
  GROUP BY j.clientid, f.fileset
)
;

CREATE VIEW backup_unit_overview AS
SELECT
  client,
  '<all file-based>' AS fileset,
  NULL::bigint AS db_units,
  NULL::bigint AS vm_units,
  CEIL(SUM(filer_mb) / 1000000)::bigint AS filer_units,
  CASE
    WHEN SUM(normal_mb) <= 10000000 THEN 1::bigint
    ELSE CEIL(SUM(normal_mb)/1000000)::bigint - 9::bigint
  END AS normal_units
FROM latest_full_size_categorized
WHERE normal_mb IS NOT NULL
   OR filer_mb IS NOT NULL
GROUP BY client
UNION
SELECT
  client,
  fileset,
  CASE
    WHEN db_mb > 0 THEN 1::bigint
  END AS db_units,
  CASE
    WHEN vm_mb > 10000000 THEN CEIL(vm_mb / 1000000)::bigint - 9::bigint
    WHEN vm_mb > 0 THEN 1::bigint
  END AS vm_units,
  NULL::bigint AS filer_units,
  NULL::bigint AS normal_units
FROM latest_full_size_categorized
WHERE (db_mb IS NOT NULL AND db_mb > 0)
   OR (vm_mb IS NOT NULL AND vm_mb > 0)
;

update Version set VersionId = 2250;

commit;
set client_min_messages = warning;
analyze;
