
select 
d1,
d2,
NUMTODSINTERVAL((d2-d1),'DAY') "До Нового Года осталось",
EXTRACT(DAY FROM NUMTODSINTERVAL((d2-d1),'DAY')) "Дней",
EXTRACT(HOUR FROM NUMTODSINTERVAL((d2-d1),'DAY')) "Часов",
EXTRACT(MINUTE FROM NUMTODSINTERVAL((d2-d1),'DAY')) "Минут",
EXTRACT(SECOND FROM NUMTODSINTERVAL((d2-d1),'DAY')) "Секунд"
from (
    select sysdate d1,
          to_date('31.12.2011 23:59:59','DD.MM.YYYY HH24:Mi:SS') d2
    from dual
)

