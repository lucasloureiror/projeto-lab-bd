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

-- Trigger para impedir a remocao na tabela NACAO_FACCAO quando isso causa a dissociacao da faccao com a nacao de seu lider
CREATE OR REPLACE TRIGGER TRIG_REMOVER_NACAO_FACCAO
BEFORE DELETE ON NACAO_FACCAO
FOR EACH ROW
DECLARE
    v_lider_faccao LIDER.CPI%TYPE;
    v_nacao_lider LIDER.NACAO%TYPE;
    v_nacao_faccao_critica NUMBER;
BEGIN
    -- Obter o CPI do lider da faccao
    SELECT LIDER INTO v_lider_faccao
    FROM FACCAO
    WHERE NOME = :old.FACCAO;

    -- Obter o nome da nacao a qual o lider da faccao pertence
    SELECT NACAO INTO v_nacao_lider
    FROM LIDER
    WHERE CPI = v_lider_faccao;
    
    -- Se a nacao da NACAO_FACCAO que sera removida for a nacao do lider, lancar uma excecao
    IF :old.NACAO = v_nacao_lider THEN
        RAISE_APPLICATION_ERROR(-20005, 'O lider da faccao "' || :old.FACCAO || '" pertence a nacao "' || :old.NACAO
        || '" e, portanto, tal faccao nao pode ser removida dessa nacao.');
    END IF;

END TRIG_REMOVER_NACAO_FACCAO;
/

