/* Criacao de uma tabela para armazenar o log de acessos e operacoes dos usuarios do sistema */
CREATE TABLE LOG_TABLE(
    USER_ID NUMBER NOT NULL,
    TIMESTAMP TIMESTAMP NOT NULL,
    MESSAGE VARCHAR2(255) NOT NULL,
    CONSTRAINT FK_USER_LOG FOREIGN KEY(USER_ID) REFERENCES USERS(USER_ID)
);
