COLUMN Parameter                FORMAT a40             heading 'Parameter'               justify CENTER
COLUMN Description              FORMAT a90             heading 'Description'             justify CENTER
COLUMN Session_Value            FORMAT a15            heading 'Session_Value'           justify CENTER
COLUMN Instance_Value           FORMAT a15             heading 'Instance_Value'          justify CENTER

SELECT
   substr(a.ksppdesc,1,90) Description,
   a.ksppinm  Parameter,
   b.ksppstvl Session_Value,
   c.ksppstvl Instance_Value
FROM
   x$ksppi a,
   x$ksppcv b,
   x$ksppsv c
WHERE
   a.indx = b.indx
   AND 
   a.indx = c.indx
   AND   upper(a.ksppinm) LIKE upper(DECODE('/_&PARAN_OCULTO%','/_ALL',a.ksppinm,'/_&&PARAN_OCULTO%')) escape '/'
   ORDER BY Parameter
/ 
-- a.ksppinm like '/_ash_size%' escape '/'; 
UNDEF PARAN_OCULTO