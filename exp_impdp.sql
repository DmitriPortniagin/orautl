expdp a4m/A4M1@RTWR DUMPFILE=textract_copy.dmp tables=textract query='textract:"where packno in (select p.packno from a4m.tExtractpacket p where p.CREATEDATE >= TO_DATE(''01.05.2015'',''DD.MM.YYYY'') AND p.BRANCH = 1) AND BRANCH = 1"'

SELECT count(*), packno
FROM TEXTRACT KU$
where exists(select p.packno from a4m.tExtractpacket p where KU$.packno=p.packno and p.CREATEDATE>=add_months(sysdate, -1) AND p.BRANCH = 1) AND KU$.BRANCH = 1
GROUP BY packno


expdp a4m/A4M1@RTWR DUMPFILE=textract_copy.dmp NOLOGFILE=YES DIRECTORY=expdp_test tables=textract CONTENT=DATA_ONLY QUERY='textract:"where KU$.packno in (select p.packno from a4m.tExtractpacket p where p.CREATEDATE >= TO_DATE(''01.05.2015'',''DD.MM.YYYY'') AND p.BRANCH = 1) AND KU$.BRANCH = 1"'

EXEC UTL_FILE.FREMOVE('/oradata/rtwr/arch','textract_copy.dmp');

select * from dba_directories

DROP TABLE textract_copy ;
CREATE TABLE textract_copy AS SELECT * FROM textract WHERE 1=2;
SELECT * FROM textract_copy

EXEC UTL_FILE.FREMOVE('EXPDP_TEST','textract_copy.dmp');
expdp a4m/A4M1@RTWR DUMPFILE=textract_copy.dmp NOLOGFILE=YES DIRECTORY=expdp_test tables=textract CONTENT=DATA_ONLY QUERY=textract:\"where exists(select p.packno from a4m.tExtractpacket p where KU$.packno=p.packno and p.CREATEDATE\>=TO_DATE(\'01.07.2015\',\'DD.MM.YYYY\') AND p.BRANCH=1)\"
expdp a4m/A4M1@RTWR DUMPFILE=textract_copy.dmp NOLOGFILE=YES DIRECTORY=expdp_test tables=textract CONTENT=DATA_ONLY QUERY='textract:"where exists(select p.packno from a4m.tExtractpacket p where KU$.packno=p.packno and p.CREATEDATE>=add_months(sysdate, -1))"'
expdp a4m/A4M1@RTWR DUMPFILE=textract_copy.dmp NOLOGFILE=YES DIRECTORY=expdp_test tables=textract CONTENT=DATA_ONLY QUERY='textract:"where packno = 39005"'
impdp a4m/A4M1@RTWR NOLOGFILE=YES DUMPFILE=textract_copy.dmp DIRECTORY=expdp_test REMAP_TABLE=textract:textract_copy

SELECT * FROM textract_copy

CONTENT=
DROP DIRECTORY expdp_test 
CREATE DIRECTORY expdp_test AS '/oradata/rtwr/expdp_test'
GRANT 



SELECT * FROM dba_datapump_sessions
select * from dba_datapump_jobs;
 select substr(sql_text, instr(sql_text,'"')+1,
               instr(sql_text,'"', 1, 2)-instr(sql_text,'"')-1)
          table_name,
       rows_processed,
       round((sysdate
              - to_date(first_load_time,'yyyy-mm-dd hh24:mi:ss'))
             *24*60, 1) minutes,
       trunc(rows_processed /
                ((sysdate-to_date(first_load_time,'yyyy-mm-dd hh24:mi:ss'))
             *24*60)) rows_per_min
from
   v$sqlarea
where
  upper(sql_text) like 'INSERT % INTO "%'
  and
  command_type = 2
  and
  open_versions > 0;

select
   sid,
   serial#
from
   v$session s,
   dba_datapump_sessions d
where
   s.saddr = d.saddr;

select
   sid,
   serial#,
   sofar,
   totalwork
from
   v$session_longops;
