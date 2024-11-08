
col source_owner head OWNER for a20
col source_name for a25
col source_line head LINE# for 999999
col source_text for a100
col source_type noprint

break on type skip 1

select 
	owner source_owner,
	type source_type,
	name source_name,
	line source_line, 
	text source_text
from 
	dba_source
where 
	lower(text) like lower('%&1%')
order by
	source_owner,
	source_name,
	source_type,
	line
;
