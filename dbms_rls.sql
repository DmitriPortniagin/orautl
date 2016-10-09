SET echo ON
spool d:\tmp\DBMS_RLS.txt

CONNECT ubrr_xxi5/ubrr_xxi51@ruodb
SELECT idsmr, count(1) FROM XXI."acc" GROUP BY idsmr;

CONNECT XXI/XXI1@ruodb
create or replace function ubrr_policy_smr(p_schema varchar2, p_object varchar2) return varchar2 is
BEGIN
    return 'idsmr in (select idsmr from xxi."smr" WHERE IDSMR = SYS_CONTEXT(''B21'', ''IDSmr''))';
end;
/
BEGIN
  DBMS_RLS.ADD_POLICY (
     object_schema => 'XXI', 
     object_name  => '"acc"',
     policy_name  => 'acc_policy',
     function_schema => 'XXI',
     policy_function  => 'ubrr_policy_smr',
     statement_types => 'select, insert, update, delete',
     update_check => true
  );
END;
/
CONNECT ubrr_xxi5/ubrr_xxi51@ruodb

SELECT idsmr, count(1) FROM XXI."acc" GROUP BY idsmr;
BEGIN 
  XXI_CONTEXT.Set_idsmr('6');
END;   
/
SELECT idsmr, count(1) FROM XXI."acc" GROUP BY idsmr;

BEGIN   
  DBMS_RLS.DROP_POLICY (
   object_schema => 'XXI',
   object_name  => '"acc"',
   policy_name  => 'acc_policy'
  );
End;
/
SPOOL off;
