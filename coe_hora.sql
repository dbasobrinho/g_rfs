
SET TERMOUT OFF;
COLUMN version NEW_VALUE version NOPRINT;
select substr(version,1,2) version from v$instance;
SET TERMOUT ON;
@coe_hora_&&version 