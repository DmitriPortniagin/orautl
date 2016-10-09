SELECT * FROM v$DATABASE


  SELECT * FROM  table(DBMS_WORKLOAD_REPOSITORY.ash_report_html(
                           l_dbid          => 871185038,
                           l_inst_num      => 1,
                           l_btime         => to_date('25.11.2013','dd.mm.yyyy'),
                           l_etime         => to_date('26.11.2013','dd.mm.yyyy'),
/*
                           l_options       IN NUMBER    DEFAULT 0,
                           l_slot_width    IN NUMBER    DEFAULT 0,
*/                           
--                           l_sid           => 198
--                           l_sql_id        IN VARCHAR2  DEFAULT NULL,
--                           l_wait_class    IN VARCHAR2  DEFAULT NULL,
--                           l_service_hash  IN NUMBER    DEFAULT NULL,
                           l_module        => 'A4M_XXI'
--                           l_action        IN VARCHAR2  DEFAULT NULL,
--                           l_client_id     IN VARCHAR2  DEFAULT NULL,
--                           l_plsql_entry   IN VARCHAR2  DEFAULT NULL,
--                           l_data_src      IN NUMBER    DEFAULT 0                           
                          ))
                                         
                          
SELECT dbms_sqltune.report_sql_detail(
       sql_id                   => 'ckn284051w7u1',
/*       sql_plan_hash_value      in  number     default NULL,
       start_time               in  date       default NULL,
       duration                 in  number     default NULL,
       inst_id                  in  number     default NULL,
       dbid                     in  number     default NULL,
       event_detail             in  varchar2   default 'yes',
       bucket_max_count         in  number     default 128,
       bucket_interval          in  number     default NULL,
       top_n                    in  number     default 10,
*/       
       report_level             => 'all'   
--       type                     => 'html'
/*       
       data_source              in  varchar2   default 'auto',
       end_time                 in  date       default NULL,
       duration_stats           in  number     default NULL
*/       
       )
FROM dual
                          
                               
