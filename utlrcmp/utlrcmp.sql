Rem Copyright (c) 1998, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      utlrcmp.sql - Utility package for dependency-based recompilation
Rem                    of invalid objects sequentially or in parallel.
Rem
Rem    DESCRIPTION
Rem      This script provides a packaged interface to recompile invalid
Rem      PL/SQL modules, Java classes, indextypes and operators in a
Rem      database sequentially or in parallel.
Rem
Rem      This script is particularly useful after a major-version upgrade.
Rem      A major-version upgrade typically invalidates all PL/SQL and Java
Rem      objects. Although invalid objects are recompiled automatically on
Rem      use, it is useful to run this script ahead of time (e.g. as one of
Rem      the last steps in your migration), since this will either eliminate
Rem      or minimize subsequent latencies caused due to on-demand automatic
Rem      recompilation at runtime.
Rem
Rem   PARALLELISM AND PERFORMANCE
Rem      Parallel recompilation can exploit multiple CPUs to reduce the time
Rem      taken to recompile invalid objects. The degree of parallelism is
Rem      specified by the first argument to utl_recomp.recomp_parallel(). 
Rem      In general, a parallelism setting of one thread per available
Rem      CPU provides a good initial setting.
Rem
Rem      However, please note that the process of recompiling an invalid
Rem      object writes a significant amount of data to system tables and is
Rem      fairly I/O intensive. A slow disk system may be a significant
Rem      bottleneck and limit speedups available from a higher degree of
Rem      parallelism.
Rem     
Rem   EXAMPLES
Rem      1. Recompile all objects sequentially:
Rem             execute utl_recomp.recomp_serial();
Rem
Rem      2. Recompile objects in schema SCOTT sequentially:
Rem             execute utl_recomp.recomp_serial('SCOTT');
Rem
Rem      3. Recompile all objects using 4 parallel threads:
Rem             execute utl_recomp.recomp_parallel(4);
Rem
Rem      4. Recompile objects in schema JOE using the number of threads
Rem         specified in the paramter JOB_QUEUE_PROCESSES:
Rem             execute utl_recomp.recomp_parallel(NULL, 'JOE');
Rem
Rem      5. Recompile all objects using 2 parallel threads, but allow
Rem         other applications to use the job queue concurrently:
Rem             execute utl_recomp.recomp_parallel(2, NULL,
Rem                                                utl_recomp.share_job_queue);
Rem
Rem      6. Restore the job queue after a failure in recomp_parallel:
Rem             execute utl_recomp.restore_job_queue();
Rem
Rem   NOTES
Rem      * This script uses the job queue for parallel recompilation. It
Rem        temporarily disables existing jobs (by marking them broken)
Rem        so that recompile jobs can be run instead.
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem      * This script expects the following packages to have been created with
Rem        VALID status:
Rem          STANDARD      (standard.sql)
Rem          DBMS_STANDARD (dbmsstdx.sql)
Rem          DBMS_JOB      (dbmsjob.sql)
Rem      * There should be no other DDL on the database while running 
Rem        entries in this package. Not following this recommendation may
Rem        lead to deadlocks.

Rem
Rem   MODIFIED   (MM/DD/YY)
Rem    weiwang    12/13/04 - bug 4059209: validate queues as well 
Rem    gviswana   12/15/03 - 3320292: Avoid validating generated types 
Rem    gviswana   03/18/03 - 2849370: Fix premature termination
Rem    skabraha   12/09/03 - ignore invalid earlier version types
Rem    weiwang    05/13/03 - validate rule sets
Rem    gviswana   09/19/02 - Compile MVs sequentially
Rem    rburns     08/21/02 - add materialized views
Rem    wxli       01/18/02 - recomp_parallel including java parallel
Rem    spsundar   12/20/01 - validate indexes (domain) too
Rem    gviswana   12/06/01 - Wrap DROP TABLE statements
Rem    gviswana   10/12/01 - Fold in changes from utlrp.sql
Rem    gviswana   06/03/01 - Merged gviswana_utl_recomp_1
Rem    gviswana   05/29/01 - Creation from utlrp.sql
Rem

Rem ===========================================================================
Rem BEGIN utlrcmp.sql
Rem ===========================================================================

Rem
Rem Drop tables without raising errors if they do not exist   
Rem
declare
   PROCEDURE drop_force(tab varchar2) IS
   BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE ' || tab;
   EXCEPTION WHEN OTHERS THEN
      NULL;
   END;
begin
   drop_force('utl_recomp_invalid');
   drop_force('utl_recomp_sorted');
   drop_force('utl_recomp_compiled');
   drop_force('utl_recomp_backup_jobs');
   drop_force('utl_recomp_log');
end;
/
   
Rem
Rem List of all invalid objects on this compile pass
Rem
CREATE TABLE utl_recomp_invalid(obj# number);

Rem
Rem Invalid objects topologically sorted by depth
Rem
CREATE TABLE utl_recomp_sorted(obj# number, depth number);

Rem
Rem List of objects that we have compiled already. We make multiple
Rem compile passes because each pass may generate new invalid objects.
Rem However, we do not want to recompile the same invalid object more   
Rem than once. This table keeps track of the objects that we have
Rem attempted to compile at least once.   
Rem
CREATE TABLE utl_recomp_compiled(obj# number);
CREATE INDEX utl_recomp_comp_idx1 ON utl_recomp_compiled(obj#);

Rem
Rem Jobs in the job queue that have been temporarily disabled
Rem
CREATE TABLE utl_recomp_backup_jobs(job number);

Rem
Rem Log of all ALTER COMPILE commands executed by these scripts
Rem   
CREATE TABLE utl_recomp_log(command varchar2(100), status varchar2(1000));

Rem
Rem View selecting all invalid objects in the database
Rem
CREATE OR REPLACE VIEW utl_recomp_all_inv AS
   SELECT o.obj#, o.type#, o.owner# FROM obj$ o
      WHERE o.remoteowner IS NULL AND o.status in (4, 5, 6) AND
            (o.type# IN (1, 2, 4, 7, 8, 9, 11, 12, 14, 22, 24, 29, 32, 33, 
                         42, 46) 
             OR
             (o.type# = 13 AND o.subname IS NULL AND
              o.name NOT LIKE 'SYS_PLSQL_%'));

Rem
Rem View selecting invalid objects indexed by schema name
Rem
CREATE OR REPLACE view utl_recomp_schema_inv AS
   SELECT o.obj#, o.type#, u.name AS owner FROM utl_recomp_all_inv o, user$ u
      WHERE o.owner# = u.user#;


CREATE OR REPLACE PACKAGE utl_recomp IS
   /*
    * NAME:
    *   recomp_parallel
    *
    * PARAMETERS:
    *   threads    (IN) - Number of recompile threads to run in parallel
    *                     If NULL, use the value of `job_queue_processes'.
    *   schema     (IN) - Schema in which to recompile invalid objects
    *                     If NULL, all invalid objects in the database
    *                     are recompiled.
    *   flags      (IN) - The following option flags are supported:
    *      SHARE_JOB_QUEUE - Allow user jobs in the job queue to run
    *                     concurrently with recompile jobs. This option
    *                     is useful if the recompile is executed on a
    *                     production system (i.e., not part of an upgrade)
    *      COMPILE_LOG  - Keep a log of the compile statements executed
    *                     and the status of execution.
    *      NO_REUSE_SETTINGS  - Do not reuse compiler settings for PL/SQL
    *                     compiles. *Note*: This setting will delete old
    *                     compiler settings stored with PL/SQL objects,
    *                     and must be used with caution.
    *
    * DESCRIPTION:
    *   This procedure is the main driver that recompiles invalid objects
    *   in the database (or in a given schema) in parallel in dependency
    *   order. It uses information in dependency$ to order recompilation
    *   of dependents after parents.
    *
    * NOTES:
    *   The parallel recompile exploits multiple CPUs to reduce the time
    *   taken to recompile invalid objects. However, please note that
    *   recompilation writes significant amounts of data to system tables,
    *   so the disk system may be a bottleneck and prevent significant
    *   speedups.
    */
   PROCEDURE recomp_parallel(threads PLS_INTEGER := NULL,
                             schema VARCHAR2 := NULL,
                             flags PLS_INTEGER := 0);

   SHARE_JOB_QUEUE   CONSTANT PLS_INTEGER := 1;
   COMPILE_LOG       CONSTANT PLS_INTEGER := 2;
   NO_REUSE_SETTINGS CONSTANT PLS_INTEGER := 4;

   /*
    * NAME:
    *   recomp_serial
    *
    * PARAMETERS:
    *   schema     (IN) - Schema in which to recompile invalid objects
    *                     If NULL, all invalid objects in the database
    *                     are recompiled.
    *   flags      (IN) - The following option flags are supported:
    *      COMPILE_LOG  - Keep a log of the compile statements executed
    *                     and the status of execution.
    *      NO_REUSE_SETTINGS  - Do not reuse compiler settings for PL/SQL
    *                     compiles. *Note*: This setting will delete old
    *                     compiler settings stored with PL/SQL objects,
    *                     and must be used with caution.
    *
    * DESCRIPTION:
    *   This procedure recompiles invalid objects in a given schema or
    *   all invalid objects in the database.
    */
   PROCEDURE recomp_serial(schema VARCHAR2 := NULL, flags PLS_INTEGER := 0);

   /*
    * NAME:
    *   parallel_slave
    *
    * PARAMETERS:
    *   batch_size   (IN) - Number of jobs to pick in each iteration
    *   flags      (IN) - The following option flags are supported:
    *      COMPILE_LOG  - Keep a log of the compile statements executed
    *                     and the status of execution.
    *      NO_REUSE_SETTINGS  - Do not reuse compiler settings for PL/SQL
    *                     compiles. *Note*: This setting will delete old
    *                     compiler settings stored with PL/SQL objects,
    *                     and must be used with caution.
    *
    * DESCRIPTION:
    *   This is an internal function that runs in each parallel thread.
    *   It picks up any remaining invalid objects from utl_recomp_sorted
    *   and recompiles them.
    */
   PROCEDURE parallel_slave(batch_size PLS_INTEGER, flags PLS_INTEGER);

   /*
    * NAME:
    *   restore_job_queue
    *
    * DESCRIPTION:
    *   This procedure restores all jobs in the job queue back to their
    *   original state. Call this procedure to restore the job queue if 
    *   one of the recomp procedures ended abruptly.
    */
   PROCEDURE restore_job_queue;
END;
/
show errors;


CREATE OR REPLACE PACKAGE BODY utl_recomp is
  CRLF             CONSTANT VARCHAR2(4) := '
';
   /*
    * NAME:
    *   exec_force
    *
    * DESCRIPTION:
    *   Wrapper for EXECUTE IMMEDIATE that discards any exceptions.
    */
   PROCEDURE exec_force(command varchar2) IS
   BEGIN
      EXECUTE IMMEDIATE command;
   EXCEPTION WHEN OTHERS THEN
      NULL;
   END;
   
   /*
    * NAME:
    *   setup_jobs
    *
    * PARAMETERS:
    *   threads    (IN) - Number of recompile threads to run in parallel
    *                     If NULL, use the value of `job_queue_processes'.
    *   flags      (IN) - The following option flags are supported:
    *      SHARE_JOB_QUEUE - Allow user jobs in the job queue to run
    *                     concurrently with recompile jobs. This option
    *                     is useful if the recompile is executed on a
    *                     production system (i.e., not part of an upgrade)
    *   num_slaves(OUT) - Number of job slaves that can be used for
    *                     recompile jobs.
    *   old_job_procs(OUT) - Value of job_queue_processes on entry to this
    *                     function.
    * 
    * DESCRIPTION:
    *   If SHARE_JOB_QUEUE is not set in `flags', this procedure makes a
    *   copy of all enabled jobs registered in job$ and marks them broken,
    *   so that the job queue can be used for recompilation jobs.
    *   
    *   If `threads' is non-NULL, this procedure sets the system parameter
    *   job_queue_processes to "threads - 1". It returns the old value of
    *   job_queue_processes in old_job_procs, and the new value of  
    *   job_queue_processes in num_slaves.
    */
   PROCEDURE setup_jobs(threads PLS_INTEGER, flags PLS_INTEGER,
                        num_slaves OUT PLS_INTEGER,
                        old_job_procs OUT PLS_INTEGER) IS
   BEGIN
      /*
       * If we're using the job queue exclusively, disable and
       * back up currently-enabled jobs.
       */
      IF (bitand(flags, SHARE_JOB_QUEUE) = 0) THEN
         -- Disable the job queue
         exec_force('ALTER SYSTEM ENABLE RESTRICTED SESSION');

         -- Create backup table
         exec_force('TRUNCATE TABLE utl_recomp_backup_jobs');

         INSERT INTO utl_recomp_backup_jobs
            SELECT job FROM job$ WHERE bitand(flag, 1) = 0;

         -- Mark all current jobs as broken
         UPDATE job$ SET flag = flag + 1 WHERE bitand(flag, 1) = 0;

         COMMIT;
      
         -- Re-enable the job queue
         exec_force('ALTER SYSTEM DISABLE RESTRICTED SESSION');
      END IF;

      /*
       * Set up job slaves. If the requested number of threads is non-NULL,
       * set up "threads - 1" job queue processes. If NULL, just use
       * the existing value of job_queue_processes.
       */
      SELECT value INTO old_job_procs FROM v$parameter
         WHERE name = 'job_queue_processes';
      old_job_procs := NVL(old_job_procs, 0);
      
      IF (threads IS NOT NULL) THEN
         num_slaves := threads - 1;
         exec_force(
            'ALTER SYSTEM SET job_queue_processes = ' || to_char(num_slaves));
      ELSE
         num_slaves := old_job_procs;
      END IF;
   END;
   
   /*
    * NAME:
    *   restore_job_queue
    *
    * DESCRIPTION:
    *   This procedure restores all jobs in the job queue back to their
    *   original state.
    */
   PROCEDURE restore_job_queue IS
   BEGIN
      -- Disable the job queue
      exec_force('ALTER SYSTEM ENABLE RESTRICTED SESSION');

      -- Re-enable old jobs
      UPDATE job$ SET flag = flag - 1
         WHERE job IN (SELECT job FROM utl_recomp_backup_jobs) and
               bitand(flag, 1) != 0;

      exec_force('TRUNCATE TABLE utl_recomp_backup_jobs');

      COMMIT;
      
      -- Disable the job queue
      exec_force('ALTER SYSTEM DISABLE RESTRICTED SESSION');
   END;
      

   /*
    * NAME:
    *   cleanup_jobs
    *
    * PARAMETERS:
    *   threads    (IN) - Number of recompile threads to run in parallel
    *                     If NULL, use the value of `job_queue_processes'.
    *   flags      (IN) - The following option flags are supported:
    *      SHARE_JOB_QUEUE - Allow user jobs in the job queue to run
    *                     concurrently with recompile jobs. This option
    *                     is useful if the recompile is executed on a
    *                     production system (i.e., not part of an upgrade)
    *   old_job_procs(IN) - Old value of job_queue_processes to be restored
    * 
    * DESCRIPTION:
    *   If SHARE_JOB_QUEUE is not set in `flags', this procedure restores
    *   user jobs to the job queue.
    *   
    *   If `threads' is non-NULL, this procedure restores
    *   job_queue_processes to its old value old_job_procs.
    */
   PROCEDURE cleanup_jobs(threads PLS_INTEGER, flags PLS_INTEGER,
                          old_job_procs PLS_INTEGER) IS
   BEGIN
      -- Reset job_queue_processes if we set it initially
      IF (threads IS NOT NULL) THEN
         exec_force(
            'ALTER SYSTEM SET job_queue_processes = ' ||
            to_char(old_job_procs));
      END IF;

      -- Restore jobs and clean up
      IF (bitand(flags, SHARE_JOB_QUEUE) = 0) THEN
         restore_job_queue();
      END IF;
   END;

   /*
    * NAME:
    *   select_invalid_objs
    *
    * PARAMETERS:
    *   schema       (IN) - Schema in which to recompile invalid objects
    *                       If NULL, all invalid objects in the database
    *                       are recompiled.
    *   include_seq  (IN) - If FALSE, leave out objects that must be
    *                       recompiled sequentially.
    * 
    * RETURNS:
    *   Number of invalid objects inserted into utl_recomp_invalid
    *
    * DESCRIPTION:
    *   This procedure populates table utl_recomp_invalid with the 
    *   list of currently invalid objects that have not already been
    *   considered for recompilation.
    */
   FUNCTION select_invalid_objs(schema VARCHAR2, include_seq BOOLEAN)
                                RETURN NUMBER IS
      num_invalid number;
   BEGIN
      exec_force('TRUNCATE TABLE utl_recomp_invalid');
      exec_force('DROP INDEX utl_recomp_inv_idx1');

      IF include_seq THEN
         IF schema IS NULL THEN
            -- Select list of invalid objects in the database
            INSERT INTO utl_recomp_invalid
               SELECT o.obj# FROM utl_recomp_all_inv o
                  WHERE o.obj# NOT IN (SELECT obj# FROM utl_recomp_compiled);
         ELSE
            -- Select list of invalid objects in the given schema
            INSERT INTO utl_recomp_invalid
               SELECT o.obj# FROM utl_recomp_schema_inv o
                  WHERE o.obj# NOT IN (SELECT obj# FROM utl_recomp_compiled)
                    AND o.owner = schema;
         END IF;
      ELSE
            -- Select list of invalid objects in the database
         IF (schema IS NULL) THEN
            INSERT INTO utl_recomp_invalid
               SELECT o.obj# from utl_recomp_all_inv o
                  WHERE o.type# != 29 AND o.type# != 42 AND
                        o.obj# NOT IN (SELECT obj# FROM utl_recomp_compiled);
         ELSE
            -- Select list of invalid objects in the given schema
            INSERT INTO utl_recomp_invalid
               SELECT o.obj# FROM utl_recomp_schema_inv o
                  WHERE o.owner = schema AND
                        o.type# != 29 AND o.type# != 42 AND
                        o.obj# NOT IN (SELECT obj# FROM utl_recomp_compiled);
         END IF;
      END IF;

      -- Copy invalid objects to the compiled list
      INSERT INTO utl_recomp_compiled
         SELECT obj# from utl_recomp_invalid;

      num_invalid := SQL%ROWCOUNT;
         
      exec_force( 
         'CREATE INDEX utl_recomp_inv_idx1 on utl_recomp_invalid(obj#)');

      COMMIT;

      RETURN num_invalid;
   END;
   
   /*
    * NAME:
    *   init
    *
    * DESCRIPTION:
    *   This procedure cleans up by truncating tables utl_recomp_invalid,
    *   utl_recomp_sorted and utl_recomp_compiled. It also drops indices
    *   on utl_recomp_invalid and utl_recomp_sorted.
    */
   PROCEDURE init IS
   BEGIN
      exec_force('TRUNCATE TABLE utl_recomp_invalid');
      exec_force('TRUNCATE TABLE utl_recomp_sorted');
      exec_force('TRUNCATE TABLE utl_recomp_compiled');
      exec_force('TRUNCATE TABLE utl_recomp_log');
      exec_force('DROP INDEX utl_recomp_inv_idx1');
      exec_force('DROP INDEX utl_recomp_sort_idx1');
   END;

   /*
    * NAME:
    *   topological_sort_objects
    *
    * DESCRIPTION:
    *   This procedure topologically sorts the invalid objects in
    *   utl_recomp_invalid and stores the results in utl_recomp_sorted.
    *   
    *   The algorithm used here is straightforward - in each iteration
    *   we choose (and remove) all objects in the set that do not depend
    *   on any other objects in the set. The removed set forms the next
    *   level of the topological-sort tree.
    */
   PROCEDURE topological_sort_objects IS
      type num_tab is table of number;
      invalid_objs num_tab;
      my_depth pls_integer := 0;
   BEGIN
      exec_force('TRUNCATE TABLE utl_recomp_sorted');
      exec_force('DROP INDEX utl_recomp_sort_idx1');

      -- Toplogical-sort loop. 
      LOOP
         -- Select and remove the next level objects
         DELETE FROM utl_recomp_invalid o
         WHERE not exists (SELECT * FROM dependency$ d, utl_recomp_invalid i
                           WHERE d.d_obj# = o.obj# and
                                 d.p_obj# = i.obj# and
                                 d.property = 1)
               and o.obj# = o.obj#                -- Workaround for bug 1782584
         RETURNING o.obj# BULK COLLECT INTO invalid_objs;

         COMMIT;
         
         EXIT WHEN invalid_objs.count = 0;

         FORALL i IN invalid_objs.first .. invalid_objs.last
            INSERT INTO utl_recomp_sorted VALUES(invalid_objs(i), my_depth);

         COMMIT;
         
         my_depth := my_depth + 1;
      END LOOP;

      exec_force(
         'CREATE INDEX utl_recomp_sort_idx1 on utl_recomp_sorted(depth)');
   END;
   
   /*
    * NAME:
    *   start_job_slaves
    *
    * PARAMETERS:
    *   threads    (IN) - Number of recompile threads to run in parallel
    *                     If NULL, use the value of `job_queue_processes'.
    *   flags      (IN) - The following option flags are supported:
    *      COMPILE_LOG  - Keep a log of the compile statements executed
    *                     and the status of execution.
    *      NO_REUSE_SETTINGS  - Do not reuse compiler settings for PL/SQL
    *                     compiles. *Note*: This setting will delete old
    *                     compiler settings stored with PL/SQL objects,
    *                     and must be used with caution.
    * RETURNS:
    *   Value of parameter `job_queue_processes' on entry to this function.
    *
    * DESCRIPTION:
    *   This function starts the job slaves, one per background process.
    *
    */
   FUNCTION start_job_slaves(threads in PLS_INTEGER, flags PLS_INTEGER)
      RETURN PLS_INTEGER IS
      num_slaves pls_integer := threads - 1;
      job_procs pls_integer;
      jobno number;
   BEGIN
      SELECT value INTO job_procs FROM v$parameter
         WHERE name = 'job_queue_processes';

      job_procs := NVL(job_procs, 0);
      
      -- Set the number of slaves and update job_queue_processes
      IF threads IS NULL THEN
         num_slaves := job_procs;
      ELSE
         exec_force(
            'ALTER SYSTEM SET job_queue_processes = ' || to_char(num_slaves));
      END IF;

      
      return job_procs;
   END;
   
   /*
    * NAME:
    *   alter_compile
    *
    * PARAMETERS:
    *   obj_id        (IN)    - Object ID of object to be recompiled
    *   plsql_options (IN)    - PL/SQL compiler options for ALTER COMPILE
    *   flags         (IN)    - The following option flags are supported:
    *      COMPILE_LOG        - Keep a log of the compile statements executed
    *                           and the status of execution.
    *
    * DESCRIPTION:
    *   This function recompiles a single object identified by its
    *   object number. If the object is a PL/SQL object, compiler options
    *   specified by `plsql_options' are used for the ALTER compile.
    */

   PROCEDURE alter_compile(obj_id NUMBER, plsql_options VARCHAR2,
                           flags PLS_INTEGER) IS

      status PLS_INTEGER;
      command VARCHAR2(4000);
      compile_status VARCHAR2(1000);
 
      -- Cursor to build the ALTER COMPILE command
      CURSOR alter1 IS
         SELECT o.status, 
           CASE 
             WHEN o.type# = 46 THEN
               'declare  ' || CRLF || 'ectx_owner VARCHAR2(30); ' || CRLF ||
               'ectx_name VARCHAR2(30); ' || CRLF || 
               'thit sys.re$rule_hit_list; ' || CRLF ||
               'mhit sys.re$rule_hit_list; ' || CRLF || 'begin ' || CRLF ||
               'select rule_set_eval_context_owner,rule_set_eval_context_name'
               || ' into ectx_owner, ectx_name from dba_rule_sets where ' ||
               'rule_set_owner = ''' || u.name || ''' and rule_set_name = ''' 
               || o.name || ''';' || CRLF || 'IF (ectx_owner IS NULL) THEN ' 
               || CRLF || 'ectx_owner := ''SYS''; ' || CRLF ||
               'ectx_name := ''STREAMS$_EVALUATION_CONTEXT''; ' || CRLF ||
               'END IF; ' || CRLF || 'BEGIN ' || CRLF ||
               'dbms_rule.evaluate(rule_set_name => ''' || u.name || '.' ||
               o.name || ''', ' || CRLF || 
               'evaluation_context => ectx_owner || ''.'' || ectx_name, ' ||
               CRLF || 'true_rules => thit, maybe_rules => mhit); ' || CRLF ||
               'EXCEPTION when others then null; END;' || CRLF || 'end; '
             WHEN o.type# = 24 THEN
               'DECLARE ' || CRLF || 'qtname VARCHAR2(30); ' || CRLF ||
               'BEGIN ' || CRLF || 'SELECT qt.name INTO qtname ' ||
               'FROM system.aq$_queues q, system.aq$_queue_tables qt ' ||
               'WHERE q.eventid = ' || o.obj# || 
               ' and q.table_objno = qt.objno; ' || CRLF ||
               'sys.dbms_aqadm_syscalls.kwqa_3gl_validateQueue(''' ||
               u.name || ''', ''' || o.name || ''', qtname); ' || CRLF ||
               'COMMIT; ' || CRLF || 'EXCEPTION WHEN others THEN null; END; '
             ELSE
              'ALTER ' || decode (o.type#,
                                  1, 'INDEX',
                                  2, 'TABLE',
                                  4, 'VIEW',
                                  7, 'PROCEDURE',
                                  8, 'FUNCTION',
                                  9, 'PACKAGE',
                                  11, 'PACKAGE',
                                  12, 'TRIGGER',
                                  13, 'TYPE',
                                  14, 'TYPE',
                                  22, 'LIBRARY',
                                  29, 'JAVA CLASS',
                                  32, 'INDEXTYPE',
                                  33, 'OPERATOR',
                                  42, 'MATERIALIZED VIEW',
                                    ' ') ||
              ' "' || u.name || '"."' || o.name || '" ' ||
                             decode (o.type#,
	                             2, 'UPGRADE INCLUDING DATA ',
                                        'COMPILE ') ||
                             decode (o.type#,
                                     9, 'SPECIFICATION ',
                                     11, 'BODY ',
                                     13, 'SPECIFICATION ',
                                     14, 'BODY ',
                                         ' ')
              ||
                               decode (o.type#,
                                        1, ' ',
                                        2, ' ',
                                        4, ' ',
                                       22, ' ',
                                       29, ' ',
                                       32, ' ',
                                       33, ' ',
                                       42, ' ',
                                           plsql_options)
         END
         FROM obj$ o, user$ u
         WHERE o.obj# = obj_id AND u.user# = o.owner#;

   BEGIN
      OPEN alter1;
      FETCH alter1 INTO status, command;
      CLOSE alter1;
      IF status IN (4, 5, 6) THEN
         BEGIN
            -- Execute the ALTER COMPILE
            EXECUTE IMMEDIATE command;
            compile_status := 'OK';
         EXCEPTION WHEN OTHERS THEN
            compile_status := substrb(sqlerrm, 1, 1000);
         END;

         -- Log the status
         IF (bitand(flags, COMPILE_LOG) != 0) THEN
            INSERT INTO utl_recomp_log VALUES (command, compile_status);
         END IF;
      END IF;
   END;
   
   /*
    * NAME:
    *   plsql_options
    *
    * PARAMETERS:
    *   flags         (IN)    - The following option flags are supported:
    *      NO_REUSE_SETTINGS  - Do not reuse compiler settings for PL/SQL
    *                           compiles.
    *
    * RETURNS:
    *   Compile-time options for PL/SQL objects.
    */

   FUNCTION plsql_compile_options(flags PLS_INTEGER) RETURN varchar2 IS
      ver_num number := 0;
      options varchar2(20) := ' ';
   BEGIN
      IF (bitand(flags, NO_REUSE_SETTINGS) = 0) THEN
         options := ' REUSE SETTINGS';
      END IF;

      RETURN options;
   END;


   /*
    * NAME:
    *   recomp_serial_internal
    *
    * PARAMETERS:
    *   schema     (IN) - Schema in which to recompile invalid objects
    *                     If NULL, all invalid objects in the database
    *                     are recompiled.
    *   flags      (IN) - The following option flags are supported:
    *      COMPILE_LOG  - Keep a log of the compile statements executed
    *                     and the status of execution.
    *      NO_REUSE_SETTINGS  - Do not reuse compiler settings for PL/SQL
    *                     compiles.
    *
    * DESCRIPTION:
    *   This procedure recompiles invalid objects in a given schema or
    *   all invalid objects in the database. 
    */

   PROCEDURE recomp_serial_internal(schema varchar2, flags PLS_INTEGER) IS
      plsql_options varchar2(20) := plsql_compile_options(flags);
   BEGIN
      /*
       * Each compile pass may generate new invalid objects. This loop
       * repeats the compilation passes until all invalid objects have
       * been recompiled.
       */
      LOOP
         -- Select any remaining invalid objects
         EXIT WHEN select_invalid_objs(schema, TRUE) = 0;

         -- Recompile each invalid object
         FOR i IN (SELECT obj# FROM utl_recomp_invalid ORDER BY obj#) LOOP
            alter_compile(i.obj#, plsql_options, flags);
         END LOOP;
      END LOOP;
   END;

      
   /*
    * NAME:
    *   recomp_parallel
    *
    * PARAMETERS:
    *   threads    (IN) - Number of recompile threads to run in parallel
    *                     If NULL, use the value of `job_queue_processes'.
    *                     If NOT NULL, the parameter job_queue_processes
    *                     will be set to `threads' - 1.
    *
    * DESCRIPTION:
    *   This procedure is the main driver that recompiles invalid objects
    *   in the database in parallel in dependency order. It uses information
    *   in dependency$ to order recompilation of dependents after parents.
    */
   PROCEDURE recomp_parallel(threads PLS_INTEGER, schema VARCHAR2,
                             flags PLS_INTEGER) IS
      old_job_procs pls_integer;
      num_invalid number;
      num_slaves pls_integer;
      jobno number;

      type seq_job_tab is table of number index by binary_integer;
      invalid_seq_objs seq_job_tab;

      /*
       * Select jobs that must be sequentialized
       */
      PROCEDURE select_invalid_seq_jobs(schema VARCHAR2) IS
      BEGIN
        IF (schema IS NULL) THEN
          SELECT o.obj# BULK COLLECT INTO invalid_seq_objs 
             FROM utl_recomp_all_inv o
                 WHERE o.type# = 29 OR o.type# = 42;
        ELSE
           -- Select list of invalid objects in the given schema
          SELECT o.obj# BULK COLLECT INTO invalid_seq_objs 
             FROM utl_recomp_schema_inv o
                 WHERE o.owner = schema AND (o.type# = 29 OR o.type# = 42);
        END IF;
      END;

      /* running sequential slave parallel with PL/SQL slaves */
      PROCEDURE seq_slave(flags PLS_INTEGER) IS
        plsql_options varchar2(20) := plsql_compile_options(flags);
      BEGIN
         FOR i IN invalid_seq_objs.first .. invalid_seq_objs.last LOOP
            alter_compile(invalid_seq_objs(i), plsql_options, 0);
         END LOOP;
         invalid_seq_objs.DELETE;
      END;
   BEGIN
      init();

      setup_jobs(threads, flags, num_slaves, old_job_procs);

      select_invalid_seq_jobs(schema);

      /*
       * Run loop recompiling sets of invalid objects. This loop is
       * necessary because each pass can create a new set of invalid
       * objects.
       */
      LOOP
         -- Get invalid objects and sort them
         EXIT WHEN select_invalid_objs(schema, FALSE) = 0;
         topological_sort_objects();
      
         -- Kick off parallel slaves
         FOR j IN 1 .. num_slaves LOOP
            dbms_job.submit(jobno, 
               'sys.utl_recomp.parallel_slave(5, ' || to_char(flags) || ');');
         END LOOP;
         COMMIT;

         -- Recompile objects that need to go sequentially in this thread
         IF (invalid_seq_objs.count > 0) THEN
            seq_slave(flags);
         END IF;

         -- Run parallel slaves for PL/SQL if any
         parallel_slave(5, flags);
      END LOOP;
      
      cleanup_jobs(threads, flags, old_job_procs);

   EXCEPTION WHEN OTHERS THEN
      cleanup_jobs(threads, flags, old_job_procs);
      raise;
   END;
   
   /*
    * NAME:
    *   parallel_slave
    *
    * PARAMETERS:
    *   batch_size    (IN) - Number of jobs to pick in each iteration
    *   flags         (IN) - The following option flags are supported:
    *      COMPILE_LOG  - Keep a log of the compile statements executed
    *                     and the status of execution.
    *      NO_REUSE_SETTINGS  - Do not reuse compiler settings for PL/SQL
    *                     compiles.
    *
    * DESCRIPTION:
    *   This function runs in each parallel thread. It picks up any remaining
    *   invalid objects from utl_recomp_sorted and recompiles them.
    */
   PROCEDURE parallel_slave(batch_size PLS_INTEGER, flags PLS_INTEGER) IS
      type num_tab is table of number index by binary_integer;
      invalid_objs num_tab;

      plsql_options varchar2(20) := plsql_compile_options(flags);
   BEGIN
      LOOP
         -- Fetch a new batch of jobs
         LOCK TABLE utl_recomp_sorted IN EXCLUSIVE MODE;

         DELETE FROM utl_recomp_sorted
            WHERE rownum <= batch_size and
                  depth = (SELECT min(depth) FROM utl_recomp_sorted)
            RETURNING obj# BULK COLLECT INTO invalid_objs;
      
         COMMIT;

         EXIT WHEN invalid_objs.count = 0;
      
         FOR i IN invalid_objs.first .. invalid_objs.last LOOP
            alter_compile(invalid_objs(i), plsql_options, 0);
         END LOOP;
      END LOOP;
   END;

   /*
    * NAME:
    *   recomp_serial
    *
    * PARAMETERS:
    *   schema     (IN) - Schema in which to recompile invalid objects
    *                     If NULL, all invalid objects in the database
    *                     are recompiled.
    *   flags      (IN) - The following option flags are supported:
    *      COMPILE_LOG  - Keep a log of the compile statements executed
    *                     and the status of execution.
    *      NO_REUSE_SETTINGS  - Do not reuse compiler settings for PL/SQL
    *                     compiles.
    *
    * DESCRIPTION:
    *   This procedure recompiles invalid objects in a given schema or
    *   all invalid objects in the database. 
    */

   PROCEDURE recomp_serial(schema varchar2, flags PLS_INTEGER) IS
   BEGIN
      init();
      recomp_serial_internal(schema, flags);
   END;

END;
/
show errors;
   
Rem ===========================================================================
Rem END utlrcmp.sql
Rem ===========================================================================
