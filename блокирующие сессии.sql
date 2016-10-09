select * from xxi."acc"
where rowid = DBMS_ROWID.rowid_create (1, 36076, 41,  984799,  56)

SELECT count(1), BLOCKING_SESSION, BLOCKING_SESSION_SERIAL# --count(1) c, sum(TIME_WAITED) total_WAIT_TIME, min(a.SAMPLE_TIME) FROM_TIME, max(a.SAMPLE_TIME) TO_TIME,  CURRENT_OBJ#, CURRENT_FILE#, CURRENT_BLOCK#, CURRENT_ROW#
            FROM DBA_HIST_ACTIVE_SESS_HISTORY a
            WHERE EVENT LIKE '%TX%'
            AND a.SAMPLE_TIME >= to_date('17.03.2014')
            AND a.SAMPLE_TIME < to_date('18.03.2014')
            and CURRENT_OBJ# = 36076
            and CURRENT_FILE# = 41
            and CURRENT_BLOCK# = 984799
            and CURRENT_ROW# = 56
group by BLOCKING_SESSION, BLOCKING_SESSION_SERIAL#

select * from xxi."acc"
where rowid = DBMS_ROWID.rowid_create (1, 36076, 44,  1021600, 5)
36076 44  1021600 5
