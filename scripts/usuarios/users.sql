/* Criacao de uma tabela para armazenar os usuarios do sistema */
CREATE TABLE USERS(
    USER_ID NUMBER NOT NULL,
    PASSWORD VARCHAR2(32) NOT NULL,
    ID_LIDER CHAR(14) NOT NULL,
    CONSTRAINT PK_USERS PRIMARY KEY(USER_ID),
    CONSTRAINT FK_LIDER_USERS FOREIGN KEY(ID_LIDER) REFERENCES LIDER(CPI) ON DELETE CASCADE,
    CONSTRAINT UK_LIDER_USERS UNIQUE(ID_LIDER)
);

/* Sequencia para criacao do ID sintetico */
CREATE SEQUENCE SEQ_USER_ID
START WITH 1 INCREMENT BY 1;

/* Utilizacao da funcao MD5 do SGBD para armazenar os dados do atributo PASSWORD */
CREATE OR REPLACE FUNCTION PASSWORD_MD5(senha VARCHAR2)
RETURN VARCHAR2 AS senha_hash VARCHAR2(32);
BEGIN
    senha_hash := RAWTOHEX(DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT => UTL_RAW.CAST_TO_RAW(senha)));
    RETURN senha_hash;
END;
/

/* Criacao de um procedimento PL/SQL para encontrar lideres sem respectivas tuplas na tabela USERS e inseri-los com uma senha padrao */
CREATE OR REPLACE PROCEDURE PROC_CRIA_USUARIOS_PADRAO(senha_padrao VARCHAR2) AS
    v_qtd_usuarios NUMBER;
BEGIN
    FOR v_lider IN (SELECT * FROM LIDER) LOOP
        SELECT COUNT(*) INTO v_qtd_usuarios FROM USERS
        WHERE ID_LIDER = v_lider.CPI;
        
        IF v_qtd_usuarios = 0 THEN
            INSERT INTO USERS(USER_ID, PASSWORD, ID_LIDER)
            VALUES(SEQ_USER_ID.NEXTVAL, PASSWORD_MD5(senha_padrao), v_lider.CPI);
        END IF;
    END LOOP;
END;
/

/* Execucao manual do procedimento para cadastrar na tabela USERS os lideres ja cadastrados */
BEGIN
    PROC_CRIA_USUARIOS_PADRAO('lider_padrao');
END;
/
