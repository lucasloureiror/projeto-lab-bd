CREATE OR REPLACE TYPE Habitantes_Record AS OBJECT (
    Nome            VARCHAR2(100),
    Faccao          VARCHAR2(100),
    Planeta         VARCHAR2(100),
    Sistema         VARCHAR2(100),
    Especie         VARCHAR2(100),
    QTD_Habitantes  NUMBER
);

/

CREATE OR REPLACE TYPE Habitantes_Table_Geral AS TABLE OF Habitantes_Record;

/

