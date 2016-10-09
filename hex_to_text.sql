declare
    hex_str varchar2(2048) := '436C6F6E655F4142535F557365723A322E30313020BEE8D8D1DAD020DDD0E7D0DBECDDDED920DFE0DEE6D5D4E3E0EB205858495F555345522E436C6F6E655F557365';
--    cur_hex number;
    ascii_text varchar2(1024):= '';
    i integer := 1;
begin
--    hex_str := char_convert.char_to_sap(hex_str);
    while length(hex_str) >= 2    
    loop
--        dbms_output.put_line('hex_str = '||hex_str);    
--        dbms_output.put_line(substr(hex_str,1,2));
        ascii_text := ascii_text || chr(to_number(substr(hex_str,1,2), 'xx'));
        hex_str := substr(hex_str, 3, length(hex_str));
--        dbms_output.put_line('');
        i:= i+2;
    end loop;
    dbms_output.put_line('ascii_text = '||ascii_text);
end;

