/* Script de criacao dos triggers utilizados na base */

-- Trigger que sera executado ao inves do INSERT na VIEW_COMUNIDADE_CREDENCIADA, para que seja possivel credenciar uma comunidade nova na tabela PARTICIPA
CREATE OR REPLACE TRIGGER TRIG_CREDENCIAR_COMUNIDADE
INSTEAD OF INSERT ON VIEW_COMUNIDADE_CREDENCIADA
FOR EACH ROW
DECLARE
    v_comunidade_valida NUMBER;
    e_comunidade_invalida EXCEPTION;
BEGIN
    -- Verificar se a comunidade habita um planeta dominado por uma nacao associada a faccao
    SELECT COUNT(*) INTO v_comunidade_valida
    FROM VIEW_COMUNIDADE_CREDENCIADA
    WHERE FACCAO = :new.FACCAO
    AND ESPECIE_HABITA = :new.ESPECIE_HABITA
    AND COMUNIDADE_HABITA = :new.COMUNIDADE_HABITA;
    
    -- Se a comunidade nao for valida, lancar uma excecao
    IF v_comunidade_valida = 0 THEN
        RAISE e_comunidade_invalida;
    END IF;
    
    -- Se a comunidade for valida, credenciar sua participacao na faccao
    INSERT INTO PARTICIPA(FACCAO, ESPECIE, COMUNIDADE)
    VALUES(:new.FACCAO, :new.ESPECIE_HABITA, :new.COMUNIDADE_HABITA);
    
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20003, 'Comunidade ja credenciada na sua faccao, altere a comunidade e tente novamente.');
        WHEN e_comunidade_invalida THEN
            RAISE_APPLICATION_ERROR(-20005, 'Somente comunidades que habitam um planeta dominado por uma nacao associada a sua faccao podem ser credenciadas.');
END TRIG_CREDENCIAR_COMUNIDADE;
/

-- Trigger para impedir a alteracao do lider de uma faccao quando esse lider nao pertence a uma nacao em que faccao esta presente
CREATE OR REPLACE TRIGGER TRIG_VALIDA_NACAO_NOVO_LIDER
BEFORE UPDATE ON FACCAO
FOR EACH ROW
WHEN (old.LIDER <> new.LIDER) -- Trigger executa somente se o lider estiver sendo alterado
DECLARE
    v_nacao_novo_lider NACAO.NOME%TYPE;
    v_qtd_nacao_faccao NUMBER;
    e_novo_lider_invalido EXCEPTION;
BEGIN
    -- Obter o nome da nacao a qual o novo lider pertence
    SELECT NACAO INTO v_nacao_novo_lider
    FROM LIDER
    WHERE CPI = :new.LIDER;
    
    -- Verificar se a nacao do novo lider esta associada a faccao que sera alterada
    SELECT COUNT(*) INTO v_qtd_nacao_faccao
    FROM NACAO_FACCAO
    WHERE NACAO = v_nacao_novo_lider
    AND FACCAO = :new.NOME;
    
    -- Se a nacao do novo lider nao estiver associada a faccao, lancar uma excecao
    IF v_qtd_nacao_faccao = 0 THEN
        RAISE e_novo_lider_invalido;
    END IF;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Lider de faccao nao encontrado.');
        WHEN e_novo_lider_invalido THEN
            RAISE_APPLICATION_ERROR(-20005, 'A faccao "' || :new.NOME || '" nao esta presente na nacao do lider "'
            || :new.LIDER || '". Escolha outro lider e tente novamente.');
END TRIG_VALIDA_NACAO_NOVO_LIDER;
/

-- Compound trigger para permitir que o nome da faccao (PRIMARY KEY) seja modificado
/* OBS.: Isso deve ser feito porque o Oracle nao possui ON UPDATE CASCADE, entao ele impede uma PK de ser modificada quando existem registros filhos em outras tabelas (FKs que referenciam a PK de faccao). */
CREATE OR REPLACE TRIGGER TRIG_ALTERAR_NOME_FACCAO
FOR UPDATE ON FACCAO
WHEN (old.NOME <> new.NOME)
COMPOUND TRIGGER
    TYPE tab_nome_nacao IS TABLE OF NACAO_FACCAO.NACAO%TYPE;
    TYPE tab_comunidade IS TABLE OF COMUNIDADE%ROWTYPE;
    col_nacoes_assoc TAB_NOME_NACAO := tab_nome_nacao();
    col_comunidades_cred TAB_COMUNIDADE := tab_comunidade();
    
    BEFORE EACH ROW IS
        v_indice NUMBER := 0;
    BEGIN
        -- Armazenar o nome de todas as nacoes associadas a faccao
        FOR v_nacao_faccao IN (
            SELECT NACAO, FACCAO
            FROM NACAO_FACCAO
            WHERE FACCAO = :old.NOME
        ) LOOP
            col_nacoes_assoc.extend();
            v_indice := v_indice + 1;
            col_nacoes_assoc(v_indice) := v_nacao_faccao.NACAO;
        END LOOP;

        -- Remover todas as nacoes associadas para que seja possivel alterar o nome da faccao
        DELETE FROM NACAO_FACCAO
        WHERE FACCAO = :old.NOME;
        
        v_indice := 0; -- Resetar o indice
        
        -- Armazenar o nome e a especie de todas as comunidades credenciadas na faccao
        FOR v_participa IN (
            SELECT FACCAO, ESPECIE, COMUNIDADE
            FROM PARTICIPA
            WHERE FACCAO = :old.NOME
        ) LOOP
            col_comunidades_cred.extend();
            v_indice := v_indice + 1;
            col_comunidades_cred(v_indice).NOME := v_participa.COMUNIDADE;
            col_comunidades_cred(v_indice).ESPECIE := v_participa.ESPECIE;
        END LOOP;
        
        -- Remover todas as comunidades credenciadas para que seja possivel alterar o nome da faccao        
        DELETE FROM PARTICIPA
        WHERE FACCAO = :old.NOME;

    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        -- Associar todas as nacoes novamente, usando o novo nome da faccao
        FOR i IN col_nacoes_assoc.FIRST..col_nacoes_assoc.LAST LOOP
            INSERT INTO NACAO_FACCAO(NACAO, FACCAO)
            VALUES(col_nacoes_assoc(i), :new.NOME);
        END LOOP;

        -- Credenciar todas as comunidades novamente, usando o novo nome da faccao
        FOR i IN col_comunidades_cred.FIRST..col_comunidades_cred.LAST LOOP
            INSERT INTO PARTICIPA(FACCAO, ESPECIE, COMUNIDADE)
            VALUES(:new.NOME, col_comunidades_cred(i).ESPECIE, col_comunidades_cred(i).NOME);
        END LOOP;
        
    END AFTER EACH ROW;

END TRIG_ALTERAR_NOME_FACCAO;

