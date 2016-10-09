select  BLOCKED, BLOCKEDSERIAL,BLOCKEDUSER, BLOCKEDBYSID, BLOCKEDBYSERIAL, BLOCKINGUSERNAME,
acc.caccacc
from (
SELECT DISTINCT
a.sid BLOCKED_SID,
a.serial# BLOCKED_SERIAL,
a.username BLOCKED_USER,
d.sid BLOCKED_BY_SID,
d.serial# BLOCKED_BY_SERIAL,
d.username BLOCKING_USERNAME,
b.owner||'.'||b.object_name WAIT_OBJECT_NAME,
DBMS_ROWID.rowid_create (1, row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#)  WAIT_ROWID
from v$session a, dba_objects b, dba_data_files c, v$lock e,
(SELECT b.sid, b.serial#, b.username, a.id1 from v$lock a, v$session b where block=1 and a.sid=b.sid) d
where a.row_wait_obj#=b.object_id
and a.row_wait_file#=c.file_id
and a.lockwait is not NULL
and e.id1=d.id1
and e.block=0 and e.type='TX'
),
--xxi."acc" acc
where 1=1 --acc.rowid = r

select * from xxi."acc"
where rowid in ('AAAHRgABLAABc8QAAA')

select * from all_objects
where object_id = 29792
