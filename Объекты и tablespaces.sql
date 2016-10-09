select owner, tablespace_name, segment_name, segment_type, sum(bytes)/1024/1024 as size$
  from dba_segments 
 group by owner, tablespace_name, segment_name, segment_type
 order by size$ desc;
 
 select tablespace_name, segment_type, sum(bytes)/1024/1024 as size$
  from dba_segments 
 where segment_type = 'INDEX'
 group by tablespace_name, segment_type
 order by size$ desc;
 



