select * from dba_source 

select OWNER, NAME object_name,
      TYPE,
      line,
      substr(
        (select listagg(sf.line || ': ' || sf.text) WITHIN GROUP (ORDER BY sf.line)
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
and (text like '%42301%' or text like '%42601%')
    and owner not in ('SYS', 'SYSTEM', 'XDB', 'DBSNMP', 'EXFSYS') 
  order by 1, line;  
   
where 

UBRR_CRM.UBRR_F127_REP3
