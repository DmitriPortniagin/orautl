declare
--------------------------------------------------------------------------------
   cursor c_InvalidObjects
   is
      select   o.owner,o.object_name, o.object_type
          from dba_objects o
         where o.status = 'INVALID'
      order by object_type desc;
--------------------------------------------------------------------------------

   n_Counter      number          := 0;
   v_cSQLString   varchar2 (1000);
BEGIN
   for r in c_InvalidObjects
   loop
      begin
         if r.object_type = 'PACKAGE BODY' then
            v_cSQLString :=
                  'ALTER PACKAGE '
               || r.owner
               || '.'
               || r.object_name
               || ' COMPILE BODY';
         elsif r.object_type = 'SYNONYM' and r.owner = 'PUBLIC' then
            v_cSQLString :=
                  'ALTER PUBLIC SYNONYM '
               || r.object_name
               || ' COMPILE';      
         else
            v_cSQLString :=
                  'ALTER '||r.object_type||' '
               || r.owner
               || '.'
               || r.object_name
               || ' COMPILE';
         end if;
         EXECUTE IMMEDIATE v_cSQLString;
         n_Counter := n_Counter + 1;
      EXCEPTION
         WHEN others THEN
            dbms_output.put_line (v_cSQLString || ': ' || sqlerrm);
      end;
   end loop;
   dbms_output.put_line (   'Компиляция успешно завершена: ['
                         || to_char (n_Counter)
                         || ']'
                        );
END;


