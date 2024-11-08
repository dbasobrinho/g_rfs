set lines 190
 
SELECT
    bs.recid                                               bs_key
  , bp.piece#                                              piece#
  , bp.copy#                                               copy#
  , bp.recid                                               bp_key
  , sp.spfile_included                                     spfile_included
  , TO_CHAR(bs.completion_time, 'DD-MON-YYYY HH24:MI:SS')  completion_time
  , DECODE(   status
            , 'A', 'Available'
            , 'D', 'Deleted'
            , 'X', 'Expired')                              status
  , handle                                                 handle
FROM
    v$backup_set                                           bs
  , v$backup_piece                                         bp
  ,  (select distinct
          set_stamp
        , set_count
        , 'YES'     spfile_included
      from v$backup_spfile)                                sp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
  AND bs.set_stamp = sp.set_stamp
  AND bs.set_count = sp.set_count
ORDER BY
    bs.recid
  , piece#;
