create global temporary table UBRR_DIR_LIST ( 
filename varchar2(255),
lastmodified date ) 
on commit delete rows;

create or replace and compile java source named "DirList"
  as
  import java.io.*;
  import java.sql.*;

      public class DirList
      {

     static private String dateStr( java.util.Date x )
      {
          if ( x != null )
              return (x.getYear()+1900) + "/" + (x.getMonth()+1) + "/" + x.getDate() + " " +
                      x.getHours() + ":" + x.getMinutes() + ":" + x.getSeconds();
         else return null;
      }

      public static void getList(String directory)
                        throws SQLException
      {
         String element;


         File path = new File(directory);
         File[] FileList = path.listFiles();
         String TheFile;
         String ModiDate;
         #sql { DELETE FROM UBRR_DIR_LIST};

         for(int i = 0; i < FileList.length; i++)
         {
             TheFile = FileList[i].getAbsolutePath();
             ModiDate = dateStr( new java.util.Date( FileList[i].lastModified() ) );

             #sql { INSERT INTO UBRR_DIR_LIST (FILENAME,LASTMODIFIED)
                    VALUES (:TheFile, to_date( :ModiDate, 'yyyy/mm/dd hh24:mi:ss') ) 
};
         }
     }
    }
  /
 create or replace procedure UBRR_get_dir_list( p_directory in varchar2 )
 as language java
 name 'DirList.getList( java.lang.String )';
 /
exec dbms_java.grant_permission( 'XXI', 'SYS:java.io.FilePermission', '/usr/u11/app/oracle/diag/rdbms/iuodb/iuodb/trace', 'read' )
/
exec UBRR_get_dir_list( '/usr/u11/app/oracle/diag/rdbms/iuodb/iuodb/trace' );
/

