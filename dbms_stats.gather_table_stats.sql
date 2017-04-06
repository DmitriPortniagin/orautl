begin
    sys.dbms_stats.gather_table_stats (OwnName            => 'A4M',
                                       TabName            => 'TUBRR_ACC_TURN',
                                       Estimate_Percent   => 10,
                                       Method_Opt         => 'FOR ALL COLUMNS SIZE 1',
                                       Degree             => 4,
                                       Cascade            => false,
                                       No_Invalidate      => false);
end;
