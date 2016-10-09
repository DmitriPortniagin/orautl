SELECT owner,
       object_type,
       object_name,
       object_id,
       status
  FROM sys.dba_objects
 WHERE object_id IN
           (SELECT object_id
              FROM public_dependency
            CONNECT BY PRIOR object_id = referenced_object_id
            START WITH referenced_object_id =
                           (SELECT object_id
                              FROM sys.dba_objects
                             WHERE     owner = 'TYULYUBAEV'
                                   AND object_name = 'UBRR_TAA_LIMITS_CALC'
                                   AND object_type = 'PACKAGE BODY'))
and object_type not in ( 'SYNONYM', 'VIEW')
order by 1,2,3;
