select PATCH_NAME, a.* from apps.AD_APPLIED_PATCHES a where a.PATCH_NAME like '%12GEQ_COMI0%' ORDER BY a.CREATION_DATE DESC;

SELECT
    owner
  , object_name
  , object_type
  , status
FROM dba_objects
WHERE status <> 'VALID'
ORDER BY owner, object_name
/