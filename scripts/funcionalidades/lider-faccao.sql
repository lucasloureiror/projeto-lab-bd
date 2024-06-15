/* Funcionalidades de gerenciamento do Lider de Faccao:
 * a. Alterar o nome da propria faccao da qual eh lider
 * b. Indicar um novo lider para a propria faccao (deve perder acesso as funcionalidades)
 * c. Credenciar comunidades novas que habitem planetas dominados por nacoes onde a propria faccao esta presente
 * d. Remover faccao de nacao (NacaoFaccao)
 * */
 
CREATE OR REPLACE PACKAGE PAC_FUNC_LIDER_FACCAO AS

    PROCEDURE alterar_nome_faccao(p_novo_nome_faccao FACCAO.NOME%TYPE, p_id_lider LIDER.CPI%TYPE);
    PROCEDURE indicar_novo_lider(p_id_novo_lider LIDER.CPI%TYPE, p_id_lider_atual LIDER.CPI%TYPE);
    PROCEDURE credenciar_nova_comunidade(p_nome_especie ESPECIE.NOME%TYPE, p_nome_comunidade COMUNIDADE.NOME%TYPE, p_id_lider LIDER.CPI%TYPE);
    PROCEDURE remover_faccao_de_nacao(p_nome_faccao FACCAO.NOME%TYPE, p_nome_nacao NACAO.NOME%TYPE);

END PAC_FUNC_LIDER_FACCAO;
/

CREATE OR REPLACE PACKAGE BODY PAC_FUNC_LIDER_FACCAO AS
    /* Declaracao de funcoes/procedimentos privados */
    FUNCTION buscar_propria_faccao(p_id_lider LIDER.CPI%TYPE) RETURN FACCAO%ROWTYPE;
    FUNCTION lider_pertence_a_nacao(p_id_lider LIDER.CPI%TYPE, p_nome_nacao NACAO.NOME%TYPE) RETURN BOOLEAN;
    FUNCTION comunidade_existe(p_nome_especie ESPECIE.NOME%TYPE, p_nome_comunidade COMUNIDADE.NOME%TYPE) RETURN BOOLEAN;

    /* Procedimento publico: Alterar o nome da propria faccao da qual eh lider */
    PROCEDURE alterar_nome_faccao(p_novo_nome_faccao FACCAO.NOME%TYPE, p_id_lider LIDER.CPI%TYPE) AS
        v_faccao_lider FACCAO%ROWTYPE;
        e_novo_nome_igual_atual EXCEPTION;
    BEGIN
        v_faccao_lider := BUSCAR_PROPRIA_FACCAO(p_id_lider);
        
        IF v_faccao_lider.NOME = p_novo_nome_faccao THEN
            RAISE e_novo_nome_igual_atual;
        END IF;
        
        UPDATE FACCAO
        SET NOME = p_novo_nome_faccao
        WHERE NOME = v_faccao_lider.NOME;
        
        COMMIT;
        
        EXCEPTION
            WHEN e_novo_nome_igual_atual THEN RAISE_APPLICATION_ERROR(-20005, 'O novo nome da faccao deve ser diferente do nome atual.');
    END alterar_nome_faccao;
    
    /* Procedimento publico: Indicar um novo lider para a propria faccao (deve perder acesso as funcionalidades) */
    PROCEDURE indicar_novo_lider(p_id_novo_lider LIDER.CPI%TYPE, p_id_lider_atual LIDER.CPI%TYPE) AS
        v_faccao_lider FACCAO%ROWTYPE;
        e_atualizar_para_null EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_atualizar_para_null, -1407);
    BEGIN
        v_faccao_lider := BUSCAR_PROPRIA_FACCAO(p_id_lider_atual);
    
        UPDATE FACCAO
        SET LIDER = p_id_novo_lider
        WHERE NOME = v_faccao_lider.NOME;
        
        COMMIT;
        
        EXCEPTION
            WHEN e_atualizar_para_null THEN RAISE_APPLICATION_ERROR(-20004, 'O atributo "LIDER" nao pode ser nulo. Indique o CPI do novo lider e tente novamente.');
    END indicar_novo_lider;
    
    /* Procedimento publico: Credenciar comunidades novas que habitem planetas dominados por nacoes onde a propria faccao esta presente */
    PROCEDURE credenciar_nova_comunidade(p_nome_especie ESPECIE.NOME%TYPE, p_nome_comunidade COMUNIDADE.NOME%TYPE, p_id_lider LIDER.CPI%TYPE) AS
        v_faccao_lider FACCAO%ROWTYPE;
        e_comunidade_nao_informada EXCEPTION;
        e_comunidade_nao_existe EXCEPTION;
    BEGIN
        v_faccao_lider := BUSCAR_PROPRIA_FACCAO(p_id_lider);
        
        -- Verificar se a comunidade foi informada
        IF p_nome_especie IS NULL OR p_nome_comunidade IS NULL THEN 
            RAISE e_comunidade_nao_informada;
        END IF;
        
        -- Verificar se a comunidade existe
        IF COMUNIDADE_EXISTE(p_nome_especie, p_nome_comunidade) = FALSE THEN
            RAISE e_comunidade_nao_existe;
        END IF;
        
        INSERT INTO VIEW_COMUNIDADE_CREDENCIADA(FACCAO, ESPECIE_HABITA, COMUNIDADE_HABITA)
        VALUES(v_faccao_lider.NOME, p_nome_especie, p_nome_comunidade);
        COMMIT;
        
        EXCEPTION
            WHEN e_comunidade_nao_informada THEN
                RAISE_APPLICATION_ERROR(-20004, 'Os atributos "ESPECIE" e "COMUNIDADE" nao podem ser nulos.');
            WHEN e_comunidade_nao_existe THEN
                RAISE_APPLICATION_ERROR(-20001, 'Comunidade nao encontrada.');
    END credenciar_nova_comunidade;
    
    /* Procedimento publico: Remover faccao de nacao (NacaoFaccao) */
    PROCEDURE remover_faccao_de_nacao(p_nome_faccao FACCAO.NOME%TYPE, p_nome_nacao NACAO.NOME%TYPE) AS
        v_faccao FACCAO%ROWTYPE;
        e_nacao_faccao_critica EXCEPTION;
        e_nacao_faccao_nao_existe EXCEPTION;
    BEGIN
        -- Obter a faccao da NACAO_FACCAO que sera removida
        SELECT NOME, LIDER, IDEOLOGIA, QTD_NACOES INTO v_faccao
        FROM FACCAO
        WHERE NOME = p_nome_faccao;
        
        -- Verificar se o lider da faccao em questao pertence a nacao da NACAO_FACCAO que sera removida
        IF LIDER_PERTENCE_A_NACAO(v_faccao.LIDER, p_nome_nacao) THEN 
            RAISE e_nacao_faccao_critica;
        END IF;
    
        DELETE FROM NACAO_FACCAO
        WHERE NACAO = p_nome_nacao
        AND FACCAO = v_faccao.NOME;
        
        IF SQL%NOTFOUND THEN
            RAISE e_nacao_faccao_nao_existe;
        END IF;
        
        -- Atualizar a quantidade de nacoes associadas a faccao em questao
        UPDATE FACCAO
        SET QTD_NACOES = (v_faccao.QTD_NACOES - 1)
        WHERE NOME = v_faccao.NOME;
        
        COMMIT;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20001, 'Faccao nao encontrada.');
            WHEN e_nacao_faccao_nao_existe THEN
                RAISE_APPLICATION_ERROR(-20001, 'Associacao de nacao-faccao nao encontrada.');
            WHEN e_nacao_faccao_critica THEN
                RAISE_APPLICATION_ERROR(-20005, 'O lider da faccao "' || v_faccao.NOME || '" pertence a nacao "'
                || p_nome_nacao || '" e, portanto, tal faccao nao pode ser removida dessa nacao.');
    END remover_faccao_de_nacao;

    /* Funcao privada: buscar a faccao de um lider */
    FUNCTION buscar_propria_faccao(p_id_lider LIDER.CPI%TYPE)
    RETURN FACCAO%ROWTYPE AS
        v_faccao FACCAO%ROWTYPE;
    BEGIN
        SELECT NOME, LIDER, IDEOLOGIA, QTD_NACOES
        INTO v_faccao
        FROM FACCAO
        WHERE LIDER = p_id_lider;
        
        RETURN v_faccao;
    
        EXCEPTION
            WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20001, 'Lider de faccao nao encontrado.');
    END buscar_propria_faccao;
    
    /* Funcao privada: verifica se um lider pertence a uma nacao especifica */
    FUNCTION lider_pertence_a_nacao(p_id_lider LIDER.CPI%TYPE, p_nome_nacao NACAO.NOME%TYPE)
    RETURN BOOLEAN AS
        v_nacao_lider NACAO.NOME%TYPE;
    BEGIN
        SELECT NACAO INTO v_nacao_lider
        FROM LIDER
        WHERE CPI = p_id_lider;
        
        RETURN v_nacao_lider = p_nome_nacao;
    END lider_pertence_a_nacao;
    
    /* Funcao privada: verifica se uma comunidade existe */
    FUNCTION comunidade_existe(p_nome_especie ESPECIE.NOME%TYPE, p_nome_comunidade COMUNIDADE.NOME%TYPE)
    RETURN BOOLEAN AS
        v_qtd_comunidades_encontradas NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_qtd_comunidades_encontradas
        FROM COMUNIDADE
        WHERE NOME = p_nome_comunidade
        AND ESPECIE = p_nome_especie;
        
        RETURN v_qtd_comunidades_encontradas > 0;
    END comunidade_existe;

END PAC_FUNC_LIDER_FACCAO;
/
