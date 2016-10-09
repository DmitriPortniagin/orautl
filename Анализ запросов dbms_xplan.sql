DECLARE
   CURSOR c_test IS
      SELECT * FROM dual;

   v_count PLS_INTEGER := 0;
BEGIN
   EXECUTE IMMEDIATE 'ALTER session SET statistics_level = ALL';

   FOR r IN c_test LOOP            --
      v_count := c_test%ROWCOUNT;  -- Тут можно поставить лбой другой запрос
   END LOOP;                       --

   DBMS_OUTPUT.NEW_LINE();
   DBMS_OUTPUT.PUT_LINE('Cursor returned ' || v_count || ' row' || CASE WHEN v_count != 1 THEN 's' END);
   DBMS_OUTPUT.NEW_LINE();

   FOR r IN (
      SELECT * FROM TABLE(dbms_xplan.display_cursor(NULL,NULL,'allstats last'))
   )
   LOOP
      DBMS_OUTPUT.PUT_LINE(r.plan_table_output);
   END LOOP;
END;
