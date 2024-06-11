/* Funcionalidades de gerenciamento do Comandante:
 * a. Incluir/excluir a propria nacao de uma federacao existente
 * b. Criar nova federacao, com a propria nacao
 * c. Inserir nova dominancia de um planeta que nao esta sendo dominado por ninguem
 * */

CREATE OR REPLACE PACKAGE PAC_FUNC_COMANDANTE AS
    e_inserir_null EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_inserir_null, -1400);

    PROCEDURE incluir_propria_nacao(p_nome_federacao FEDERACAO.NOME%TYPE, p_id_lider LIDER.CPI%TYPE);
    PROCEDURE excluir_propria_nacao(p_nome_federacao FEDERACAO.NOME%TYPE, p_id_lider LIDER.CPI%TYPE);
    PROCEDURE criar_federacao(p_federacao FEDERACAO%ROWTYPE, p_id_lider LIDER.CPI%TYPE);
    PROCEDURE inserir_dominancia(p_id_planeta PLANETA.ID_ASTRO%TYPE, p_data_ini DATE, p_id_lider LIDER.CPI%TYPE);

END PAC_FUNC_COMANDANTE;
/

CREATE OR REPLACE PACKAGE BODY PAC_FUNC_COMANDANTE AS

    /* Funcao privada: buscar a nacao de um lider */
    FUNCTION buscar_propria_nacao(p_id_lider LIDER.CPI%TYPE)
    RETURN NACAO%ROWTYPE AS
        v_nome_nacao LIDER.NACAO%TYPE;
        v_propria_nacao NACAO%ROWTYPE;
    BEGIN
        SELECT NACAO INTO v_nome_nacao
        FROM LIDER
        WHERE CPI = p_id_lider;
        
        SELECT * INTO v_propria_nacao
        FROM NACAO
        WHERE NOME = v_nome_nacao;
        
        RETURN v_propria_nacao;
    
        EXCEPTION
            WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20001, 'Lider nao encontrado.');
    END buscar_propria_nacao;
    
    /* Funcao privada: verificar se uma federacao tem pelo menos 1 nacao associada */
    FUNCTION federacao_tem_nacao_associada(p_nome_federacao FEDERACAO.NOME%TYPE)
    RETURN BOOLEAN AS
        v_qtd_nacoes_associadas NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_qtd_nacoes_associadas
        FROM NACAO
        WHERE FEDERACAO = p_nome_federacao;
        
        RETURN v_qtd_nacoes_associadas > 0;
    END federacao_tem_nacao_associada;
    
    /* Funcao privada: verificar se um planeta esta sendo dominado por alguem atualmente */
    FUNCTION planeta_tem_dominancia_atual(p_id_planeta PLANETA.ID_ASTRO%TYPE)
    RETURN BOOLEAN AS
        v_qtd_dominancias_atuais NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_qtd_dominancias_atuais
        FROM DOMINANCIA
        WHERE PLANETA = p_id_planeta
        AND (DATA_FIM IS NULL OR DATA_FIM >= SYSDATE);
        
        RETURN v_qtd_dominancias_atuais > 0;
    END planeta_tem_dominancia_atual;
    
    /* Procedimento publico: Incluir a propria nacao em uma federacao existente */
    PROCEDURE incluir_propria_nacao(p_nome_federacao FEDERACAO.NOME%TYPE, p_id_lider LIDER.CPI%TYPE) AS
        v_propria_nacao NACAO%ROWTYPE;
        e_nacao_ja_inclusa EXCEPTION;
        e_nacao_ja_tem_federacao EXCEPTION;
        e_federacao_nao_existe EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_federacao_nao_existe, -02291);
    BEGIN        
        -- Identificar a nacao do lider
        v_propria_nacao := BUSCAR_PROPRIA_NACAO(p_id_lider);
        
        -- Verificar se a propria nacao ja esta incluida na federacao em questao
        IF v_propria_nacao.FEDERACAO = p_nome_federacao THEN
            RAISE e_nacao_ja_inclusa;
        END IF;
        
        -- Verificar se a propria nacao ja esta associada a uma federacao
        IF v_propria_nacao.FEDERACAO IS NOT NULL THEN
            RAISE e_nacao_ja_tem_federacao;            
        END IF;
        
        -- Incluir a propria nacao na federacao especificada
        UPDATE NACAO
        SET FEDERACAO = p_nome_federacao
        WHERE NOME = v_propria_nacao.NOME;
        COMMIT;
        
        EXCEPTION
            WHEN e_nacao_ja_inclusa THEN
                RAISE_APPLICATION_ERROR(-20005, 'Sua nacao ja faz parte dessa federacao.');
            WHEN e_nacao_ja_tem_federacao THEN 
                RAISE_APPLICATION_ERROR(-20005, 'Sua nacao esta atualmente incluida na federacao "'
                || v_propria_nacao.FEDERACAO || '". Exclua essa associacao e tente novamente.');
            WHEN e_federacao_nao_existe THEN
                RAISE_APPLICATION_ERROR(-20001, 'Federacao nao encontrada.');
    END incluir_propria_nacao;
    
    /* Procedimento publico: Excluir a propria nacao de uma federacao existente */
    PROCEDURE excluir_propria_nacao(p_nome_federacao FEDERACAO.NOME%TYPE, p_id_lider LIDER.CPI%TYPE) AS
        v_propria_nacao NACAO%ROWTYPE;
        e_nacao_nao_tem_federacao EXCEPTION;
        e_nacao_nao_inclusa EXCEPTION;
    BEGIN        
        -- Identificar a nacao do lider
        v_propria_nacao := BUSCAR_PROPRIA_NACAO(p_id_lider);
        
        -- Verificar se a nacao esta associada a alguma federacao
        IF v_propria_nacao.FEDERACAO IS NULL THEN
            RAISE e_nacao_nao_tem_federacao;
        END IF;
        
        -- Verificar se a nacao esta realmente associada a federacao em questao
        IF v_propria_nacao.FEDERACAO <> p_nome_federacao THEN
            RAISE e_nacao_nao_inclusa;
        END IF;
        
        -- Excluir a propria nacao da federacao especificada
        UPDATE NACAO
        SET FEDERACAO = NULL
        WHERE NOME = v_propria_nacao.NOME;
        COMMIT;
        
        -- Excluir a federacao em questao caso ela nao esteja mais associada a nenhuma nacao
        IF FEDERACAO_TEM_NACAO_ASSOCIADA(p_nome_federacao) = FALSE THEN
            DELETE FROM FEDERACAO WHERE NOME = p_nome_federacao;
            COMMIT;
        END IF;
        
        EXCEPTION
            WHEN e_nacao_nao_tem_federacao THEN
                RAISE_APPLICATION_ERROR(-20005, 'Sua nacao nao faz parte de nenhuma federacao.');
            WHEN e_nacao_nao_inclusa THEN
                RAISE_APPLICATION_ERROR(-20005, 'Sua nacao nao esta incluida na federacao "' || p_nome_federacao || '".' );
    END excluir_propria_nacao;

    /* Procedimento publico: Criar nova federacao, com a propria nacao */
    PROCEDURE criar_federacao(p_federacao FEDERACAO%ROWTYPE, p_id_lider LIDER.CPI%TYPE) AS
        v_propria_nacao NACAO%ROWTYPE;
        e_nacao_ja_tem_federacao EXCEPTION;
    BEGIN
        -- Identificar a nacao do lider
        v_propria_nacao := BUSCAR_PROPRIA_NACAO(p_id_lider);

        -- Verificar se a propria nacao ja esta associada a uma federacao
        IF v_propria_nacao.FEDERACAO IS NOT NULL THEN
            RAISE e_nacao_ja_tem_federacao;            
        END IF;
    
        -- Criar a nova federacao
        INSERT INTO FEDERACAO(NOME, DATA_FUND)
        VALUES(p_federacao.NOME, p_federacao.DATA_FUND);
    
        -- Atualizar a nacao para associa-la a nova federacao
        UPDATE NACAO
        SET FEDERACAO = p_federacao.NOME
        WHERE NOME = v_propria_nacao.NOME;
        
        COMMIT;
    
        EXCEPTION
            WHEN e_nacao_ja_tem_federacao THEN 
                RAISE_APPLICATION_ERROR(-20005, 'Sua nacao esta atualmente incluida na federacao "'
                || v_propria_nacao.FEDERACAO || '". Exclua essa associacao e tente novamente.');
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20003, 'Federacao ja existe, altere o nome e tente novamente.');
            WHEN e_inserir_null THEN
                RAISE_APPLICATION_ERROR(-20004, 'Os atributos "NOME" e "DATA_FUND" nao podem ser nulos.');
    END criar_federacao;
    
    /* Procedimento publico: Inserir nova dominancia de um planeta que nao esta sendo dominado por ninguem */
    PROCEDURE inserir_dominancia(p_id_planeta PLANETA.ID_ASTRO%TYPE, p_data_ini DATE, p_id_lider LIDER.CPI%TYPE) AS
        v_propria_nacao NACAO%ROWTYPE;
        e_planeta_ja_tem_dominancia EXCEPTION;
        e_planeta_nao_existe EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_planeta_nao_existe, -02291);
    BEGIN
        -- Identificar a nacao do lider
        v_propria_nacao := BUSCAR_PROPRIA_NACAO(p_id_lider);
        
        -- Verificar se o planeta ja esta sendo dominado por alguem
        IF PLANETA_TEM_DOMINANCIA_ATUAL(p_id_planeta) THEN
            RAISE e_planeta_ja_tem_dominancia;
        END IF;
        
        -- Inserir nova dominancia
        INSERT INTO DOMINANCIA(PLANETA, NACAO, DATA_INI)
        VALUES(p_id_planeta, v_propria_nacao.NOME, p_data_ini);
        COMMIT;
        
        EXCEPTION
            WHEN e_planeta_ja_tem_dominancia THEN
                RAISE_APPLICATION_ERROR(-20005, 'Esse planeta ja esta sendo dominado.');
            WHEN e_planeta_nao_existe THEN
                RAISE_APPLICATION_ERROR(-20001, 'Planeta nao encontrado.');
            WHEN e_inserir_null THEN
                RAISE_APPLICATION_ERROR(-20004, 'Os atributos "PLANETA", "NACAO" e "DATA_INI" nao podem ser nulos.');
    END;

END PAC_FUNC_COMANDANTE;
/
