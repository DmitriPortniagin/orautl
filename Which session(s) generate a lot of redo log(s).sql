--Which session(s) generate a lot of redo log(s)
--How to find which SQL statement generates lots of redo logs.

--Firstly use below query to find out which sessions generate more redo logs:

SELECT  s.sid, s.serial#, s.username, s.program, i.block_changes
FROM v$session s, v$sess_io i
WHERE s.sid = i.sid AND i.block_changes > 0
ORDER BY 5 DESC, 1;

--block_changes column provide us how much blocks have been changed the session

--P.S: You can omit block_changes > 0 condition if you want to see all result

--But, what about if you want to see amount of undo blocks and undo records accessed by the transaction?
--To do that use:

SELECT s.sid, s.serial#, s.username, s.program, s.machine, t.used_ublk, t.used_urec
FROM v$session s, v$transaction t
WHERE s.taddr = t.addr
ORDER BY 6, 7 desc;

--At the end, to get object lists which block changed historical information:

SELECT dhso.object_name, object_type, SUM (db_block_changes_delta)
FROM dba_hist_seg_stat dhss, dba_hist_seg_stat_obj dhso, dba_hist_snapshot dhs
WHERE     dhs.snap_id = dhss.snap_id 
AND dhs.instance_number = dhss.instance_number
AND dhss.obj# = dhso.obj#
AND dhss.dataobj# = dhso.dataobj#
AND begin_interval_time BETWEEN TO_DATE ('20-12-2012 00:00:00', 'DD-MM-YYYY HH24:mi:ss') AND TO_DATE ('20-12-201223:59:59', 'DD-MM-YYYY HH24:mi:ss')
GROUP BY dhso.object_name, object_type
HAVING SUM (db_block_changes_delta) > 0
ORDER BY 2, SUM (db_block_changes_delta) DESC

--And to get which SQL statement used :

SELECT distinct dbms_lob.substr(sql_text,4000,1), optimizer_mode, module
FROM dba_hist_sqlstat dhss,
dba_hist_snapshot dhs,
dba_hist_sqltext dhst
WHERE upper(dhst.sql_text) LIKE '%AZ_PAY%' AND 
dhss.snap_id=dhs.snap_id
AND dhss.instance_Number=dhs.instance_number
AND dhss.sql_id = dhst.sql_id --and rownum<2;

--Not: You can add additional column to get more detail info for investigation, such as :
--use : dba_hist_sqlstat dyanmic view`s columns : cpu_time_total, cpu_time_delta, elapsed_time_total, elapsed_time_delta, iowait_total, disk_reads_total etc 

--Top 10 sessions which generate more redo logs:

select b.inst_id, b.SID, b.serial# sid_serial, b.username, machine, b.osuser, b.status, a.redo_mb MB
from (select n.inst_id, sid, round(value/1024/1024) redo_mb from gv$statname n, gv$sesstat s
where n.inst_id=s.inst_id and n.statistic#=134 and s.statistic# = n.statistic# order by value desc) a, gv$session b
where b.inst_id=a.inst_id
  and a.sid = b.sid
and   rownum <= 10;

--Total count of redo generation:

select sum(round(gb)) total_redo_count from (select b.inst_id, b.SID, b.serial# sid_serial, b.username, machine, b.osuser, b.status, a.redo_gb GB 
from (select n.inst_id, sid, round(value/1024/1024/1024) redo_gb from gv$statname n, gv$sesstat s 
where n.inst_id=s.inst_id and n.statistic#=134 and s.statistic# = n.statistic# order by value desc ) a, gv$session b
where b.inst_id=a.inst_id
and a.sid = b.sid)
