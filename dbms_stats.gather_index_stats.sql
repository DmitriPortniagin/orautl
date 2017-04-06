begin
    dbms_stats.gather_index_stats (ownname => 'UBRR_TMP', indname => 'UBRR_CRM_CABN_TAB_PK');
end;
