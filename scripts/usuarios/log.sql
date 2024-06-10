/* Criacao de uma tabela para armazenar o log de acessos e operacoes dos usuarios do sistema */
CREATE TABLE LOG_TABLE(
    USER_ID NUMBER NOT NULL,
    TIMESTAMP TIMESTAMP NOT NULL,
    MESSAGE VARCHAR2(255) NOT NULL,
    CONSTRAINT FK_USER_LOG FOREIGN KEY(USER_ID) REFERENCES USERS(USER_ID)
);

/* A tabela de logs devera ser mantida por chamadas da aplicacao */
CREATE OR REPLACE PROCEDURE PROC_INSERIR_LOG(
    p_user_id LOG_TABLE.USER_ID%TYPE,
    p_mensagem LOG_TABLE.MESSAGE%TYPE
) AS
    e_usuario_nao_existe EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_usuario_nao_existe, -02291);
BEGIN
    INSERT INTO LOG_TABLE(USER_ID, TIMESTAMP, MESSAGE)
    VALUES(p_user_id, SYSTIMESTAMP, p_mensagem);
    
    EXCEPTION
        WHEN e_usuario_nao_existe THEN RAISE_APPLICATION_ERROR(-20001, 'Usuario nao encontrado.');
END;
/
