BEGIN
    DBMS_SCHEDULER.create_chain(
        comments => '',
        chain_name => 'UBRR_XXI5.TEST_CHAIN'
    );
      DBMS_SCHEDULER.enable(name=>'UBRR_XXI5.TEST_CHAIN');
END;


BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_STEP(
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        STEP_NAME  => '"TEST_CHAIN_STEP1"',
        PROGRAM_NAME => '"XXI"."ubrr_test_program"' );   
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP1"',
            ATTRIBUTE => 'PAUSE',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP1"',
            ATTRIBUTE => 'SKIP',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP1"',
            ATTRIBUTE => 'RESTART_ON_FAILURE',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP1"',
            ATTRIBUTE => 'RESTART_ON_RECOVERY',
            VALUE => false);

END;

BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_STEP(
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        STEP_NAME  => '"TEST_CHAIN_STEP2"',
        PROGRAM_NAME => '"XXI"."ubrr_test_program"' );   
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP2"',
            ATTRIBUTE => 'PAUSE',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP2"',
            ATTRIBUTE => 'SKIP',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP2"',
            ATTRIBUTE => 'RESTART_ON_FAILURE',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP2"',
            ATTRIBUTE => 'RESTART_ON_RECOVERY',
            VALUE => false);

END;

BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_STEP(
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        STEP_NAME  => '"TEST_CHAIN_STEP3"',
        PROGRAM_NAME => '"XXI"."ubrr_test_program"' );   
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP3"',
            ATTRIBUTE => 'PAUSE',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP3"',
            ATTRIBUTE => 'SKIP',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP3"',
            ATTRIBUTE => 'RESTART_ON_FAILURE',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP3"',
            ATTRIBUTE => 'RESTART_ON_RECOVERY',
            VALUE => false);

END;

BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_STEP(
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        STEP_NAME  => '"TEST_CHAIN_STEP4"',
        PROGRAM_NAME => '"XXI"."ubrr_test_program"' );   
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP4"',
            ATTRIBUTE => 'PAUSE',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP4"',
            ATTRIBUTE => 'SKIP',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP4"',
            ATTRIBUTE => 'RESTART_ON_FAILURE',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP4"',
            ATTRIBUTE => 'RESTART_ON_RECOVERY',
            VALUE => false);

END;

BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_STEP(
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        STEP_NAME  => '"TEST_CHAIN_STEP5"',
        PROGRAM_NAME => '"XXI"."ubrr_test_program"' );   
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP5"',
            ATTRIBUTE => 'PAUSE',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP5"',
            ATTRIBUTE => 'SKIP',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP5"',
            ATTRIBUTE => 'RESTART_ON_FAILURE',
            VALUE => false);
        DBMS_SCHEDULER.ALTER_CHAIN(
            CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
            STEP_NAME => '"TEST_CHAIN_STEP5"',
            ATTRIBUTE => 'RESTART_ON_RECOVERY',
            VALUE => false);

END;
/*
BEGIN
    DBMS_SCHEDULER.DROP_CHAIN_RULE  (
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        force => false,       
        rule_name => '"SCHED_RULE$2"'
        );   
END;
*/

BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        condition => 'TRUE',
        action => 'START "TEST_CHAIN_STEP1"'
        );   
END;

BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        condition => '"TEST_CHAIN_STEP4" SUCCEEDED',
        action => 'END'
        );   
END;

BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        condition => '"TEST_CHAIN_STEP5" SUCCEEDED',
        action => 'END'
        );   
END;


BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        condition => '"TEST_CHAIN_STEP1" SUCCEEDED',
        action => 'START "TEST_CHAIN_STEP3"'
        );   
END;

BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        condition => '"TEST_CHAIN_STEP1" SUCCEEDED',
        action => 'START "TEST_CHAIN_STEP2"'
        );   
END;

BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        condition => '"TEST_CHAIN_STEP3" SUCCEEDED',
        action => 'START "TEST_CHAIN_STEP4"'
        );   
END;

BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        condition => '"TEST_CHAIN_STEP2" SUCCEEDED',
        action => 'START "TEST_CHAIN_STEP4"'
        );   
END;

BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        condition => '"TEST_CHAIN_STEP3" FAILED',
        action => 'START "TEST_CHAIN_STEP5"'
        );   
END;

BEGIN
    DBMS_SCHEDULER.DEFINE_CHAIN_RULE  (
        CHAIN_NAME  => '"UBRR_XXI5"."TEST_CHAIN"',
        condition => '"TEST_CHAIN_STEP2" FAILED',
        action => 'START "TEST_CHAIN_STEP5"'
        );   
END;

BEGIN
    DBMS_SCHEDULER.DROP_JOB (job_name => '"UBRR_XXI5"."TEST_CHAIN_JOB"',
    force => true);
END;

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"UBRR_XXI5"."TEST_CHAIN_JOB"',
            job_type => 'CHAIN',
            job_action => '"UBRR_XXI5"."TEST_CHAIN"',
            number_of_arguments => 0,
            start_date => NULL,
            repeat_interval => NULL,
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => '');

    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"UBRR_XXI5"."TEST_CHAIN_JOB"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
    
    DBMS_SCHEDULER.enable(
             name => '"UBRR_XXI5"."TEST_CHAIN_JOB"');
END;

--  insert into xxi.ubrr_chain_test(n1) values(to_char(sysdate,'dd.mm.yyyy HH24:MI:SS'));
SELECT * FROM xxi.ubrr_chain_test
