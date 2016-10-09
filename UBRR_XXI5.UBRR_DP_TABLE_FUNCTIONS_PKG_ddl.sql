-- Start of DDL Script for Package Body UBRR_XXI5.UBRR_DP_TABLE_FUNCTIONS_PKG
-- Generated 14.01.2011 17:27:24 from UBRR_XXI5@rUODB

CREATE OR REPLACE 
PACKAGE           ubrr_xxi5.ubrr_dp_table_functions_pkg IS
    TYPE acc_balance_type is record
           (acc varchar2(20),
            cur varchar2(4),
            balance number(19,2));

    TYPE acc_balance IS TABLE OF acc_balance_type;
    
    FUNCTION balance_acc(input_values SYS_REFCURSOR)
      RETURN acc_balance 
      PIPELINED 
      PARALLEL_ENABLE(PARTITION input_values BY any) 
      ;
    
END ubrr_dp_table_functions_pkg;
/


CREATE OR REPLACE 
PACKAGE BODY           ubrr_xxi5.ubrr_dp_table_functions_pkg IS

    FUNCTION balance_acc(input_values SYS_REFCURSOR)
      RETURN acc_balance PIPELINED 
      PARALLEL_ENABLE(PARTITION input_values BY any) 
      IS
      p_acc acc%rowtype;
      p_balance NUMBER(19,2) := 0;
      ret acc_balance_type;
    BEGIN
      LOOP
         FETCH input_values INTO p_acc;
         EXIT WHEN input_values%NOTFOUND;
         p_balance := 0;
         begin
            select SUM(nvl(trnsum,0)) balance 
            into p_balance
            from(
                select -sum(trn.mtrnsum) trnsum from xxi.trn trn where ctrnaccc = p_acc.caccacc
                union 
                select sum(trn.mtrnsum) trnsum from xxi.trn trn where ctrnaccd = p_acc.caccacc
            );
         exception when others then 
            p_balance := 0;
         end;
         ret.acc := p_acc.caccacc;
         ret.cur := p_acc.cacccur;
         ret.balance := p_balance;
         PIPE ROW (ret);
      END LOOP;
      RETURN;
    END;   
    
end;
/


-- End of DDL Script for Package Body UBRR_XXI5.UBRR_DP_TABLE_FUNCTIONS_PKG

