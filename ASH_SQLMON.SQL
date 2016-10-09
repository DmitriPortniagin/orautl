--
-- SQL Plan Statistics for SQL_EXEC_ID from ASH
-- Usage: SQL> @ash_sqlmon &sql_id [&plan_hash_value] [&sql_exec_id]
-- http://iusoltsev.wordpress.com
--
 
set feedback off heading on timi off pages 500 lines 500 echo off  VERIFY OFF
 
col PLAN_OPERATION for a100
col WAIT_PROFILE for a200
 
with ash as
 (select sql_id,
         sql_plan_hash_value,
         nvl(sql_plan_line_id, 0) as SQL_PLAN_LINE_ID,
         decode(session_state,'WAITING',event,session_state) as EVENT,
         count(*) as WAIT_COUNT
    from v$active_session_history
   where sql_id = '&1'
     and sql_plan_hash_value = nvl('&2', sql_plan_hash_value)
     and NVL(sql_exec_id, 0) = nvl('&3', NVL(sql_exec_id, 0))
   group by sql_id, sql_plan_hash_value, sql_plan_line_id, decode(session_state,'WAITING',event,session_state)),
ash_stat as
(select  sql_id,
        sql_plan_hash_value,
        sql_plan_line_id,
        rtrim(xmlagg(xmlelement(s, EVENT || '(' ||WAIT_COUNT, '); ').extract('//text()') order by WAIT_COUNT desc),',') as WAIT_PROFILE
from ash
group by sql_id,
         sql_plan_hash_value,
         sql_plan_line_id),
pt as
 (select
        id,
        operation,
        options,
        object_owner,
        object_name,
        parent_id
    from dba_hist_sql_plan
   where (sql_id, plan_hash_value) =
         (select distinct sql_id, sql_plan_hash_value from ash_stat)
  union -- for plans not in dba_hist_sql_plan yet
  select
        id,
        operation,
        options,
        object_owner,
        object_name,
        parent_id
    from v$sql_plan
   where (sql_id, plan_hash_value) =
         (select distinct sql_id, sql_plan_hash_value from ash_stat))
SELECT pt.id,
       lpad(' ', 2 * level) || pt.operation || ' ' || pt.options as PLAN_OPERATION,
       pt.object_owner,
       pt.object_name,
       ash_stat.WAIT_PROFILE
  FROM pt
  left join ash_stat
    on pt.id = ash_stat.sql_plan_line_id
CONNECT BY PRIOR pt.id = pt.parent_id
 START WITH pt.id = 0
/
set feedback on VERIFY ON timi on