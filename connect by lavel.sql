select to_date('01.12.2010','dd.mm.yyyy')+level-1 l from dual
connect by level <= to_date('10.12.2010','dd.mm.yyyy')-to_date('01.12.2010','dd.mm.yyyy')+1
