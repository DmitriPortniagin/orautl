  begin
      dbms_parallel_execute.drop_chunks('P5_TARNS2');
      dbms_parallel_execute.drop_task('P5_TARNS2');
  exception when dbms_parallel_execute.task_not_found then
      null;
  end;

SELECT * FROM v$parameter
WHERE NAME LIKE '%job%'

ALTER SYSTEM SET job_queue_processes=10

select *
from dba_parallel_execute_tasks where task_name = 'P5_TARNS2'
/

select *
from dba_parallel_execute_chunks where task_name = 'P5_TARNS2'
/

select *
from dba_scheduler_jobs where job_name like (select job_prefix || '%' from dba_parallel_execute_tasks where task_name = 'P5_TARNS2')
/

select *
from dba_scheduler_job_log where job_name like (select job_prefix || '%' from dba_parallel_execute_tasks where task_name = 'P5_TARNS2')
