set lines 400 pages 99
col name for a35
col value for a40
select NAME,VALUE,ISDEFAULT,ISSES_MODIFIABLE,ISSYS_MODIFIABLE,ISINSTANCE_MODIFIABLE 
from v$parameter where UPPER(name) like UPPER('&1');
