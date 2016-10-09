connect xxi/xxi1@ZODB
echo off
set serveroutput on
spool log.txt APPEND

declare
  CURSOR c is ( select SID, SERIAL#,  USERNAME, MACHINE, PROGRAM, MODULE, ACTION
                from v$session where TERMINAL NOT IN ('MFDEVEXT', 'PORTNYAGIN2', 'PORTNYAGIN'));
  TYPE t_sess IS TABLE OF c%ROWTYPE index by pls_integer;
  v_sess t_sess;
  v_kill_str varchar2(256);
  v_info_str varchar2(256);
  PROCEDURE exec_sql(v_sql IN varchar2)
  IS
  BEGIN
    dbms_output.put_line(v_sql);
    --EXECUTE IMMEDIATE v_sql;
  EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line('Error while execute '||v_sql);
    dbms_output.put_line(dbms_utility.format_error_stack);
    dbms_output.put_line(dbms_utility.format_error_backtrace());
  END;
begin
  DBMS_APPLICATION_INFO.SET_MODULE('SESSION KILLER','killing session');
  open c;
  fetch c BULK collect into v_sess;
  close c;

  for i in v_sess.first..v_sess.last loop
    v_info_str := to_char(sysdate,'dd.mm.yyyy HH24:MI:SS') ||' '|| v_sess(i).USERNAME ||' '
                                                                || v_sess(i).MACHINE  ||' '
                                                                || v_sess(i).PROGRAM  ||' '
                                                                || v_sess(i).MODULE   ||' '
                                                                || v_sess(i).ACTION;
    dbms_output.put_line(v_info_str );
    v_kill_str := 'ALTER SYSTEM KILL SESSION '|| CHR (39)|| v_sess(i).SID ||',' ||v_sess(i).SERIAL#|| CHR (39);
	exec_sql(v_kill_str);
  end loop;
end;
