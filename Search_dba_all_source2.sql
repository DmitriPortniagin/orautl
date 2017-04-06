select * from dictionary where comments like '%obj%'

select distinct OWNER, NAME object_name, length(text )
from dba_source 
where text like '%455%'
and owner not in ('SYS', 'SYSTEM', 'XDB', 'DBSNMP', 'EXFSYS') ;

select OWNER, NAME object_name,
        TYPE,
        line,
        substr((  select listagg(sf.line || ': ' || substr(sf.text,1,187)) WITHIN GROUP (ORDER BY sf.line)
                  --sf.text
                  from dba_source sf
                  where 1=1
                  and owner = s.owner
                  and name  = s.name
                  and type  = s.type
                  and line between s.line - 10 and s.line + 10)
        , 1, 4000) text
from dba_source s
where 1=1
--and TEXT LIKE '%wrapp%'
and text like '%455%'
and owner not in ('SYS', 'SYSTEM', 'XDB', 'DBSNMP', 'EXFSYS', 'IMON','SGBACK', 'SGDEPO', 'WMSYS', 'CR', 'TR' ) 
and NAME is not null 
AND NAME NOT IN ('QTRN', 'XXI_LOGON')
order by OWNER, NAME, LINE ;  

select type, owner, name, text
from all_source
where line = 1
  and instr(text, 'wrapped') > 1;

select * from dba_source 
select * from dba_objects 
SGBACK   CG$SEC_COL_HIST

XXI.LEDGER_2


