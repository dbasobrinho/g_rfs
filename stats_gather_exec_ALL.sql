SET ECHO ON
SET TIMI on
set time on
spo stats_gather_exec_ALL.log
@stats_gather_table.sql
@stats_gather_system.sql
@stats_gather_dictionary.sql
spo off
SET ECHO off