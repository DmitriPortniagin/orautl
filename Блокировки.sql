SELECT * FROM v$SESSION
WHERE AUDSID = 315748489

SELECT count(1) c, sum(WAIT_TIME) total_WAIT_TIME,  CURRENT_OBJ#, CURRENT_FILE#, CURRENT_BLOCK#, CURRENT_ROW#
FROM DBA_HIST_ACTIVE_SESS_HISTORY a
WHERE EVENT LIKE '%TX%'
AND a.SAMPLE_TIME >= to_date('17.03.2014')
AND a.SAMPLE_TIME < to_date('18.03.2014')
group by CURRENT_OBJ#, CURRENT_FILE#, CURRENT_BLOCK#, CURRENT_ROW#

select  acc.caccacc, b.*
from (
      SELECT
--      a.sid BLOCKED_SID,
--      a.serial# BLOCKED_SERIAL,
--      a.username BLOCKED_USER,
--      d.sid BLOCKED_BY_SID,
--      d.serial# BLOCKED_BY_SERIAL,
--      d.username BLOCKING_USERNAME,
      c ,
      b.owner WAIT_OBJECT_OWNER,
      b.object_name WAIT_OBJECT_NAME,
      a.total_WAIT_TIME,
      a.FROM_TIME,
      a.TO_TIME,
      DBMS_ROWID.rowid_create (1, CURRENT_OBJ#, CURRENT_FILE#, CURRENT_BLOCK#, CURRENT_ROW#)  WAIT_ROWID,
      CURRENT_OBJ#, CURRENT_FILE#, CURRENT_BLOCK#, CURRENT_ROW#
      from (SELECT count(1) c, sum(TIME_WAITED) total_WAIT_TIME, min(a.SAMPLE_TIME) FROM_TIME, max(a.SAMPLE_TIME) TO_TIME,  CURRENT_OBJ#, CURRENT_FILE#, CURRENT_BLOCK#, CURRENT_ROW#
            FROM DBA_HIST_ACTIVE_SESS_HISTORY a
            WHERE EVENT LIKE '%TX%'
--            AND a.SAMPLE_TIME >= to_date('17.03.2014')
--            AND a.SAMPLE_TIME < to_date('18.03.2014')
            group by trunc(a.SAMPLE_TIME, CURRENT_OBJ#, CURRENT_FILE#, CURRENT_BLOCK#, CURRENT_ROW#) a,
           dba_objects b,
           dba_data_files c
      where a.CURRENT_OBJ#=b.object_id
      and a.CURRENT_FILE#=c.file_id
      AND b.object_name = 'acc'
      order by c desc
    ) b,
    xxi."acc" acc
where acc.rowid = WAIT_ROWID
AND WAIT_OBJECT_NAME = 'acc'


select * from XXI.CASHNUM  where rowid = 'AAAIPKAAqAAEB2zADG'

select * from xxi."acc"
where rowid = DBMS_ROWID.rowid_create (1, 36076, 41,  984799,  56)

SELECT * FROM dictionary
WHERE table_name LIKE '%LOCK%'


SELECT * FROM V$SESSION_EVENT
WHERE sid = 7429

SELECT * FROM V$LOCK
WHERE SID = 11

AAAIzsAAnAAD5pMAA1

SELECT DISTINCT a.sid BLOCKED, a.serial# BLOCKEDSERIAL, a.username BLOCKEDUSER, d.sid BLOCKEDBYSID,
d.serial# BLOCKEDBYSERIAL, d.username BLOCKINGUSERNAME, 
DBMS_ROWID.rowid_create (1, row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#)
from v$session a, dba_objects b, dba_data_files c, v$lock e,
(SELECT b.sid, b.serial#, b.username, a.id1 from v$lock a, v$session b where block=1 and a.sid=b.sid) d
where a.row_wait_obj#=b.object_id
and a.row_wait_file#=c.file_id
and a.lockwait is not NULL
and e.id1=d.id1
and e.block=0 and e.type='TX';

SELECT * FROM xxi."acc"
WHERE ROWID = 'AAAIzsAAnAAD5pMAA1'

40702810400000000401

SELECT * FROM v$segment_statistics
WHERE object_name = 'acc'


SELECT *
FROM DBA_HIST_ACTIVE_SESS_HISTORY a
WHERE EVENT LIKE '%TX%'
AND a.SAMPLE_TIME >= to_date('17.03.2014')
AND a.SAMPLE_TIME < to_date('18.03.2014')

select min(SAMPLE_TIME) from DBA_HIST_ACTIVE_SESS_HISTORY
