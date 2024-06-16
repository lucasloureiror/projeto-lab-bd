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
START WITH 1 INCREMENT BY 1
NOCACHE NOCYCLE ;

/* Utilizacao da funcao MD5 do SGBD para armazenar os dados do atributo PASSWORD */
CREATE OR REPLACE FUNCTION PASSWORD_MD5(p_senha VARCHAR2)
RETURN VARCHAR2 AS senha_hash VARCHAR2(32);
BEGIN
    senha_hash := RAWTOHEX(DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT => UTL_RAW.CAST_TO_RAW(p_senha)));
    RETURN senha_hash;
END;
/

/* Criacao de um procedimento PL/SQL para encontrar lideres sem respectivas tuplas na tabela USERS e inseri-los com uma senha padrao */
CREATE OR REPLACE PROCEDURE PROC_CRIA_USUARIOS_PADRAO(p_senha_padrao VARCHAR2) AS
    v_qtd_usuarios NUMBER;
BEGIN
    FOR v_lider IN (SELECT * FROM LIDER) LOOP
        SELECT COUNT(*) INTO v_qtd_usuarios FROM USERS
        WHERE ID_LIDER = v_lider.CPI;
        
        IF v_qtd_usuarios = 0 THEN
            INSERT INTO USERS(USER_ID, PASSWORD, ID_LIDER)
            VALUES(SEQ_USER_ID.NEXTVAL, PASSWORD_MD5(p_senha_padrao), v_lider.CPI);
        END IF;
    END LOOP;
END;
/

/* Execucao manual do procedimento para cadastrar na tabela USERS os lideres ja cadastrados */
BEGIN
    PROC_CRIA_USUARIOS_PADRAO('lider_padrao');
    COMMIT;
END;
/

/* Funcao para validar um usuario: retorna o USER_ID caso o usuario seja valido */
CREATE OR REPLACE FUNCTION FUNC_VALIDA_USUARIO(
    p_id_lider LIDER.CPI%TYPE,
    p_senha USERS.PASSWORD%TYPE
) RETURN USERS.USER_ID%TYPE AS
    v_user_id USERS.USER_ID%TYPE;
    v_senha USERS.PASSWORD%TYPE;
    e_senha_invalida EXCEPTION;
BEGIN
    SELECT USER_ID, PASSWORD
    INTO v_user_id, v_senha 
    FROM USERS
    WHERE ID_LIDER = p_id_lider;
    
    IF v_senha <> PASSWORD_MD5(p_senha) THEN
        RAISE e_senha_invalida;
    END IF;
    
    RETURN v_user_id;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20001, 'Usuario nao encontrado.');
        WHEN e_senha_invalida THEN RAISE_APPLICATION_ERROR(-20002, 'Senha invalida.');
END;
/

/* Funcao para obter o cargo de um usuario/lider */
CREATE OR REPLACE FUNCTION FUNC_BUSCA_CARGO_USUARIO(
    p_id_lider USERS.ID_LIDER%TYPE
) RETURN LIDER.CARGO%TYPE AS
    v_cargo_usuario LIDER.CARGO%TYPE;
BEGIN
    SELECT CARGO INTO v_cargo_usuario
    FROM LIDER
    WHERE CPI = p_id_lider;
    
    RETURN v_cargo_usuario;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20001, 'Usuario nao encontrado.');
END;
/

/* Funcao para verificar se um usuario eh um lider de faccao (esta associado a uma faccao cadastrada) */
CREATE OR REPLACE FUNCTION FUNC_VALIDA_LIDER_FACCAO(
    p_id_lider USERS.ID_LIDER%TYPE
) RETURN BOOLEAN AS
    v_eh_lider_faccao NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_eh_lider_faccao
    FROM FACCAO
    WHERE LIDER = p_id_lider;

    RETURN v_eh_lider_faccao > 0;
END;
/

/* Funcao para obter o nome de um usuario/lider */
CREATE OR REPLACE FUNCTION FUNC_BUSCA_NOME_USUARIO(p_id_lider USERS.ID_LIDER%TYPE)
RETURN LIDER.NOME%TYPE AS
    v_nome_usuario LIDER.NOME%TYPE;
BEGIN
    SELECT NOME INTO v_nome_usuario
    FROM LIDER
    WHERE CPI = p_id_lider;
    
    RETURN v_nome_usuario;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20001, 'Usuario nao encontrado.');
END;
/
