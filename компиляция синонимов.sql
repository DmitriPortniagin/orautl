

DECLARE
BEGIN
    FOR r IN (SELECT object_id
                FROM dba_objects
               WHERE object_type = 'SYNONYM' AND status = 'INVALID')
    LOOP
        DBMS_UTILITY.VALIDATE (r.object_id);
        dbms_output.put_line('Откомпилил - ' || r.object_id);
    END LOOP;
END;
/
--alter materialized view UBRR_VDATA.UBRR_GRL_NOT_ZERO compile
