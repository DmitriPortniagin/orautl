
select 
d1,
d2,
NUMTODSINTERVAL((d2-d1),'DAY') "�� ������ ���� ��������",
EXTRACT(DAY FROM NUMTODSINTERVAL((d2-d1),'DAY')) "����",
EXTRACT(HOUR FROM NUMTODSINTERVAL((d2-d1),'DAY')) "�����",
EXTRACT(MINUTE FROM NUMTODSINTERVAL((d2-d1),'DAY')) "�����",
EXTRACT(SECOND FROM NUMTODSINTERVAL((d2-d1),'DAY')) "������"
from (
    select sysdate d1,
          to_date('31.12.2011 23:59:59','DD.MM.YYYY HH24:Mi:SS') d2
    from dual
)

