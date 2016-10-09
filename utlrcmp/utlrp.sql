Rem
Rem $Header: utlrp.sql 27-oct-2004.12:30:35 rburns Exp $ 
Rem
Rem utlrp.sql
Rem
Rem Copyright (c) 1998, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      utlrp.sql - UTiLity script Recompile invalid Pl/sql modules
Rem
Rem    DESCRIPTION
Rem     This is a fairly general script that can be used at any time to
Rem     recompile all existing invalid PL/SQL modules in a database.
Rem
Rem     If run as one of the last steps during migration/upgrade/downgrade
Rem     (see the README notes for your current release and the Oracle
Rem     Migration book), this script  will validate all PL/SQL modules
Rem     (procedures, functions, packages, triggers, types, views, libraries) 
Rem     during the migration step itself.
Rem
Rem     Although invalid PL/SQL modules get automatically recompiled on use,
Rem     it is useful to run this script ahead of time (e.g. as one of the last
Rem     steps in your migration), since this will either eliminate or
Rem     minimize subsequent latencies caused due to on-demand automatic
Rem     recompilation at runtime.
Rem
Rem     Oracle highly recommends running this script towards the end of
Rem     of any migration/upgrade/downgrade.
Rem
Rem   NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem      * This script expects the following packages to have been created with
Rem        VALID status:
Rem          STANDARD      (standard.sql)
Rem          DBMS_STANDARD (dbmsstdx.sql)
Rem      * There should be no other DDL on the database while running the
Rem        script.  Not following this recommendation may lead to deadlocks.
Rem
Rem   MODIFIED   (MM/DD/YY)
Rem    rburns      10/27/04 - recompile dbms_registry packages 
Rem    rburns      10/01/04 - use dbms_registry_sys 
Rem    gviswana    11/12/01 - Use utl_recomp.recomp_serial
Rem    rdecker     11/09/01 - ADD ALTER library support FOR bug 1952368
Rem    rburns      11/12/01 - validate all components after compiles
Rem    rburns      11/06/01 - fix invalid CATPROC call
Rem    rburns      09/29/01 - use 9.2.0
Rem    rburns      09/20/01 - add check for CATPROC valid
Rem    rburns      07/06/01 - get version from instance view
Rem    rburns      05/09/01 - fix for use with 8.1.x
Rem    arithikr    04/17/01 - 1703753: recompile object type# 29,32,33
Rem    skabraha    09/25/00 - validate is now a keyword
Rem    kosinski    06/14/00 - Persistent parameters
Rem    skabraha    06/05/00 - validate tables also
Rem    jdavison    04/11/00 - Modify usage notes for 8.2 changes.
Rem    rshaikh     09/22/99 - quote name for recompile
Rem    ncramesh    08/04/98 - change for sqlplus
Rem    usundara    06/03/98 - merge from 8.0.5
Rem    usundara    04/29/98 - creation (split from utlirp.sql).
Rem                           Mark Ramacher (mramache) was the original
Rem                           author of this script.
Rem

Rem ===========================================================================
Rem BEGIN utlrp.sql
Rem ===========================================================================

--
--
-- *********************************************************************
-- NOTE: Package STANDARD and DBMS_STANDARD must be valid before running
-- this part.  If these are not valid, run standard.sql and
-- dbms_standard.sql to recreate and validate STANDARD and DBMS_STANDARD;
-- then run this portion.
-- *********************************************************************

--@@utlrcmp.sql
--execute utl_recomp.recomp_serial();
execute utl_recomp.recomp_parallel(5);

Rem =====================================================================
Rem Run component validation procedure - new one if it exists
Rem =====================================================================

DECLARE
  p_null char(1);
BEGIN
  select null into p_null from dba_procedures
  where procedure_name='VALIDATE_COMPONENTS' and
        object_name = 'DBMS_REGISTRY_SYS' and
        owner = 'SYS';
  EXECUTE IMMEDIATE 'begin dbms_registry_sys.validate_components; end;';
EXCEPTION WHEN NO_DATA_FOUND THEN
  EXECUTE IMMEDIATE 'begin dbms_registry.validate_components; end;';
END;
/

Rem ===========================================================================
Rem END utlrp.sql
Rem ===========================================================================
