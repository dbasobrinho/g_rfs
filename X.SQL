select /*+GUINA123*/ PJT.PROJECT_NAME PJT_NAME,
       CONNECT_BY_ROOT FLD.FOLDER_NAME PROJECT_FOLDER,
       FLD.FOLDER_NAME FOLDER_NAME,
       PP.POP_NAME AS INTERFACE_NAME,
       CASE
         WHEN PP.WSTAGE = 'E' THEN
          'TABLE_TO_TABLE_INF'
         ELSE
          'TEMP_INTERFACE'
       END AS INTERFACE_TYPE,
       PP.LSCHEMA_NAME AS TARGET_SCHEMA,
       PP.TABLE_NAME AS TARGET_TABLE,
       POP.COL_NAME AS TARGET_COLUMN,
       POP.POS AS TARGET_COL_INDEX,
       CASE
         WHEN PP.WSTAGE = 'E' THEN
          COL.SOURCE_DT || '(' || COL.LONGC || ')'
         ELSE
          POP.SOURCE_DT || '(' || POP.LONGC || ')'
       END AS TRG_DATATYPE,
       DBMS_LOB.SUBSTR(HDR.FULL_TEXT, 4000) AS MAPPING,
       COALESCE(TC.COL_NAME, COL.COL_NAME) AS SOURCE_COLUMN,
       CASE
         WHEN TC.COL_NAME IS NOT NULL THEN
          POP.SOURCE_DT || '(' || POP.LONGC || ')'
         ELSE
          COL.SOURCE_DT || '(' || COL.LONGC || ')'
       END SOURCE_DATATYPE,
       ST.LSCHEMA_NAME AS SOURCE_SCHEMA,
       ST.SRC_TAB_ALIAS AS SOURCE_ALIAS,
       ST.TABLE_NAME AS SOURCE_TABLE
  from WORK_11G_EPMDEV.SNP_PROJECT PJT
  LEFT OUTER JOIN WORK_11G_EPMDEV.SNP_FOLDER FLD
    ON PJT.I_PROJECT = FLD.I_PROJECT
  LEFT OUTER JOIN WORK_11G_EPMDEV.SNP_POP PP
    ON FLD.I_FOLDER = PP.I_FOLDER
  LEFT JOIN WORK_11G_EPMDEV.SNP_POP_COL POP
    ON PP.I_POP = POP.I_POP
  LEFT OUTER JOIN WORK_11G_EPMDEV.SNP_COL COL
    ON COL.I_COL = POP.I_COL
  LEFT OUTER JOIN WORK_11G_EPMDEV.SNP_POP_MAPPING MAP
    ON MAP.I_POP_COL = POP.I_POP_COL
  LEFT OUTER JOIN WORK_11G_EPMDEV.SNP_TXT_CROSSR TXT
    ON TXT.I_TXT = MAP.I_TXT_MAP
  LEFT OUTER JOIN WORK_11G_EPMDEV.SNP_TXT_HEADER HDR
    ON HDR.I_TXT = MAP.I_TXT_MAP
  LEFT OUTER JOIN WORK_11G_EPMDEV.SNP_SOURCE_TAB ST
    ON ST.I_SOURCE_TAB = MAP.I_SOURCE_TAB
  LEFT OUTER JOIN WORK_11G_EPMDEV.SNP_POP_COL TC
    ON TC.I_COL = TXT.I_COL
 where (1 = 1)
 start with FLD.PAR_I_FOLDER IS NULL
connect by prior FLD.I_FOLDER = FLD.PAR_I_FOLDER
 ORDER BY 1, 2, 3, 4
/ 
