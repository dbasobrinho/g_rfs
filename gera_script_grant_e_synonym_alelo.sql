
select '-- ** Gera Scripts para criar synonym do ususario OWMALELO para o ususario USMALELO ** --' command from dual
union all
select  'create or replace synonym  usmalelo.'||object_name||' for '||owner||'.'||object_name||';' command
from dba_objects where owner ='OWMALELO' and  object_type in('TABLE', 'PACKAGE','PROCEDURE','VIEW','SEQUENCE') 
union all
select '-- ** Gera Scripts para criar grant do ususario OWMALELO para o ususario USMALELO ** --' command from dual
union all
select  'grant '||decode(object_type,'TABLE','select,insert,update,delete', 'FUNCTION','execute', 'PACKAGE','execute','PROCEDURE','execute','VIEW','SELECT','SEQUENCE','SELECT')
         ||' on '|| owner||'.'||object_name||' to usmalelo;'  command
from dba_objects where owner ='OWMALELO' and  object_type in('TABLE', 'PACKAGE','PROCEDURE','VIEW','SEQUENCE') 
/
