/* Script de criação dos triggers utilizados na base */

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
