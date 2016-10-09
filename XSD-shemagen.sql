SELECT  --XMLElement("xs:schema",
--          XMLElement("xs:element", XMLAttributes(cols.TABLE_NAME AS "name", cols.TABLE_NAME||'Type' AS "type")),
          XMLElement("xs:complexType", XMLAttributes(cols.TABLE_NAME||'Type' AS "name"),  
              XMLElement("xs:sequence", 
                        XMLAGG(
                          XMLElement("xs:element", XMLAttributes(cols.COLUMN_NAME AS "name", cols.DATA_TYPE AS "xdb:sqltype",  
                                              CASE 
                                              WHEN cols.DATA_TYPE = 'VARCHAR2' THEN 'xs:string' 
                                              WHEN cols.DATA_TYPE = 'DATE' THEN  'xs:dateTime'
                                              WHEN cols.DATA_TYPE = 'NUMBER' THEN 'xs:integer'
                                              ELSE 'xs:anySimpleType' END AS "type", 
                                              CASE WHEN cols.NULLABLE= 'Y' THEN 0 ELSE 1 END AS "minOccurs"),
                              XMLElement("xs:annotation", 
                              XMLElement("xs:documentation", coment.COMMENTS )
                            )
                          ) ORDER BY cols.COLUMN_ID
                        )
                    )
                )
--        )
FROM dba_tab_cols cols,
     DBA_COL_COMMENTS coment
WHERE cols.table_name = 'trn'
--WHERE cols.OWNER = 'XXI'
AND cols.table_name = coment.table_name
AND coment.column_name = cols.column_name
AND HIDDEN_COLUMN <> 'YES'
GROUP BY  cols.table_name 

--minOccurs="0"
SELECT * 
FROM dba_tab_cols cols
WHERE cols.table_name = 'trn'
 ORDER BY cols.COLUMN_ID
