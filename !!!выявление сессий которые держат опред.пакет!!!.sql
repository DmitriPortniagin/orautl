select *
from v$session s, x$kgllk k, v$process p
where s.saddr = k.kgllkuse and k.kglnaobj = upper ('ubrr_abs_set_context') and s.paddr = p.addr;

select 'alter system disconnect session ''' || sid || ',' || serial# || ''' immediate;'
from v$session, x$kgllk
where saddr = kgllkuse and kglnaobj = upper ('ubrr_abs_set_context');

