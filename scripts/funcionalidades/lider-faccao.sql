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
    /* Declaracao de atributos privados */
    TYPE tab_nome_nacao IS TABLE OF NACAO_FACCAO.NACAO%TYPE;
    TYPE tab_comunidade IS TABLE OF COMUNIDADE%ROWTYPE;

    /* Declaracao de funcoes/procedimentos privados */
    FUNCTION buscar_propria_faccao(p_id_lider LIDER.CPI%TYPE) RETURN FACCAO.NOME%TYPE;
    FUNCTION comunidade_existe(p_nome_especie ESPECIE.NOME%TYPE, p_nome_comunidade COMUNIDADE.NOME%TYPE) RETURN BOOLEAN;
    FUNCTION obter_nacoes_associadas(p_nome_faccao FACCAO.NOME%TYPE) RETURN TAB_NOME_NACAO;
    FUNCTION obter_comunidades_credenciadas(p_nome_faccao FACCAO.NOME%TYPE) RETURN TAB_COMUNIDADE;
    PROCEDURE associar_nacoes(p_nome_faccao FACCAO.NOME%TYPE, col_nacoes TAB_NOME_NACAO);
    PROCEDURE credenciar_comunidades(p_nome_faccao FACCAO.NOME%TYPE, col_comunidades TAB_COMUNIDADE);

    /* Procedimento publico: Alterar o nome da propria faccao da qual eh lider */
    PROCEDURE alterar_nome_faccao(p_novo_nome_faccao FACCAO.NOME%TYPE, p_id_lider LIDER.CPI%TYPE) AS
        v_nome_faccao_lider FACCAO.NOME%TYPE;
        col_nacoes_associadas TAB_NOME_NACAO;
        col_comunidades_credenciadas TAB_COMUNIDADE;
        e_novo_nome_igual_atual EXCEPTION;
    BEGIN
        v_nome_faccao_lider := BUSCAR_PROPRIA_FACCAO(p_id_lider);
        
        IF v_nome_faccao_lider = p_novo_nome_faccao THEN
            RAISE e_novo_nome_igual_atual;
        END IF;
        
        -- Obter o nome das nacoes associadas e as comunidades credenciadas na faccao do lider
        col_nacoes_associadas := OBTER_NACOES_ASSOCIADAS(v_nome_faccao_lider);
        col_comunidades_credenciadas := OBTER_COMUNIDADES_CREDENCIADAS(v_nome_faccao_lider);
        
        -- Remover as nacoes associadas e as comunidades credenciadas para que seja possivel alterar o nome da faccao
        DELETE FROM NACAO_FACCAO WHERE FACCAO = v_nome_faccao_lider;
        DELETE FROM PARTICIPA WHERE FACCAO = v_nome_faccao_lider;
        
        -- Atualizar o nome da faccao do lider
        UPDATE FACCAO
        SET NOME = p_novo_nome_faccao
        WHERE NOME = v_nome_faccao_lider;
        
        -- Associar as nacoes e credenciar as comunidades novamente, usando o novo nome da faccao
        associar_nacoes(p_novo_nome_faccao, col_nacoes_associadas);
        credenciar_comunidades(p_novo_nome_faccao, col_comunidades_credenciadas);
        
        COMMIT;
        
        EXCEPTION
            WHEN e_novo_nome_igual_atual THEN RAISE_APPLICATION_ERROR(-20005, 'O novo nome da faccao deve ser diferente do nome atual.');
    END alterar_nome_faccao;
    
    /* Procedimento publico: Indicar um novo lider para a propria faccao (deve perder acesso as funcionalidades) */
    PROCEDURE indicar_novo_lider(p_id_novo_lider LIDER.CPI%TYPE, p_id_lider_atual LIDER.CPI%TYPE) AS
        v_nome_faccao_lider FACCAO.NOME%TYPE;
        e_atualizar_para_null EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_atualizar_para_null, -1407);
    BEGIN
        v_nome_faccao_lider := BUSCAR_PROPRIA_FACCAO(p_id_lider_atual);
    
        UPDATE FACCAO
        SET LIDER = p_id_novo_lider
        WHERE NOME = v_nome_faccao_lider;
        
        COMMIT;
        
        EXCEPTION
            WHEN e_atualizar_para_null THEN RAISE_APPLICATION_ERROR(-20004, 'O atributo "LIDER" nao pode ser nulo. Indique o CPI do novo lider e tente novamente.');
    END indicar_novo_lider;
    
    /* Procedimento publico: Credenciar comunidades novas que habitem planetas dominados por nacoes onde a propria faccao esta presente */
    PROCEDURE credenciar_nova_comunidade(p_nome_especie ESPECIE.NOME%TYPE, p_nome_comunidade COMUNIDADE.NOME%TYPE, p_id_lider LIDER.CPI%TYPE) AS
        v_nome_faccao_lider FACCAO.NOME%TYPE;
        e_comunidade_nao_informada EXCEPTION;
        e_comunidade_nao_existe EXCEPTION;
    BEGIN
        v_nome_faccao_lider := BUSCAR_PROPRIA_FACCAO(p_id_lider);
        
        -- Verificar se a comunidade foi informada
        IF p_nome_especie IS NULL OR p_nome_comunidade IS NULL THEN 
            RAISE e_comunidade_nao_informada;
        END IF;
        
        -- Verificar se a comunidade existe
        IF COMUNIDADE_EXISTE(p_nome_especie, p_nome_comunidade) = FALSE THEN
            RAISE e_comunidade_nao_existe;
        END IF;
        
        INSERT INTO VIEW_COMUNIDADE_CREDENCIADA(FACCAO, ESPECIE_HABITA, COMUNIDADE_HABITA)
        VALUES(v_nome_faccao_lider, p_nome_especie, p_nome_comunidade);
        COMMIT;
        
        EXCEPTION
            WHEN e_comunidade_nao_informada THEN
                RAISE_APPLICATION_ERROR(-20004, 'Os atributos "ESPECIE" e "COMUNIDADE" nao podem ser nulos.');
            WHEN e_comunidade_nao_existe THEN
                RAISE_APPLICATION_ERROR(-20001, 'Comunidade nao encontrada.');
    END credenciar_nova_comunidade;
    
    /* Procedimento publico: Remover faccao de nacao (NacaoFaccao) */
    PROCEDURE remover_faccao_de_nacao(p_nome_faccao FACCAO.NOME%TYPE, p_nome_nacao NACAO.NOME%TYPE) AS
        e_nacao_faccao_nao_existe EXCEPTION;
    BEGIN
        DELETE FROM NACAO_FACCAO
        WHERE NACAO = p_nome_nacao
        AND FACCAO = p_nome_faccao;
        
        IF SQL%NOTFOUND THEN
            RAISE e_nacao_faccao_nao_existe;
        END IF;
        
        COMMIT;

        EXCEPTION
            WHEN e_nacao_faccao_nao_existe THEN RAISE_APPLICATION_ERROR(-20001, 'Associacao de nacao-faccao nao encontrada.');
    END remover_faccao_de_nacao;

    /* Funcao privada: buscar a faccao de um lider */
    FUNCTION buscar_propria_faccao(p_id_lider LIDER.CPI%TYPE)
    RETURN FACCAO.NOME%TYPE AS
        v_nome_faccao FACCAO.NOME%TYPE;
    BEGIN
        SELECT NOME INTO v_nome_faccao
        FROM FACCAO
        WHERE LIDER = p_id_lider;
        
        RETURN v_nome_faccao;
    
        EXCEPTION
            WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20001, 'Lider de faccao nao encontrado.');
    END buscar_propria_faccao;
    
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
    
    /* Funcao privada: Obter uma colecao contendo o nome de todas as nacoes associadas a uma faccao */
    FUNCTION obter_nacoes_associadas(p_nome_faccao FACCAO.NOME%TYPE)
    RETURN TAB_NOME_NACAO AS
        col_nacoes TAB_NOME_NACAO := tab_nome_nacao();
        v_indice NUMBER := 0;
    BEGIN
        FOR v_nacao_faccao IN (
            SELECT NACAO, FACCAO
            FROM NACAO_FACCAO
            WHERE FACCAO = p_nome_faccao
        )
        LOOP
            col_nacoes.extend();
            v_indice := v_indice + 1;
            col_nacoes(v_indice) := v_nacao_faccao.NACAO;
        END LOOP;
        
        RETURN col_nacoes;
    END obter_nacoes_associadas;
    
    /* Funcao privada: Obter uma colecao contendo todas as comunidades credenciadas em uma faccao */
    FUNCTION obter_comunidades_credenciadas(p_nome_faccao FACCAO.NOME%TYPE)
    RETURN TAB_COMUNIDADE AS
        col_comunidades TAB_COMUNIDADE := tab_comunidade();
        v_indice NUMBER := 0;
    BEGIN
        FOR v_participa IN (
            SELECT FACCAO, ESPECIE, COMUNIDADE
            FROM PARTICIPA
            WHERE FACCAO = p_nome_faccao
        ) LOOP
            col_comunidades.extend();
            v_indice := v_indice + 1;
            col_comunidades(v_indice).NOME := v_participa.COMUNIDADE;
            col_comunidades(v_indice).ESPECIE := v_participa.ESPECIE;
        END LOOP;
    
        RETURN col_comunidades;
    END obter_comunidades_credenciadas;
    
    /* Procedimento privado: Associar uma colecao de nacoes com uma faccao */
    PROCEDURE associar_nacoes(p_nome_faccao FACCAO.NOME%TYPE, col_nacoes TAB_NOME_NACAO) AS
    BEGIN
        FOR i IN col_nacoes.FIRST..col_nacoes.LAST LOOP
            INSERT INTO NACAO_FACCAO(NACAO, FACCAO)
            VALUES(col_nacoes(i), p_nome_faccao);
        END LOOP;
    END associar_nacoes;

    /* Procedimento privado: Associar uma colecao de nacoes com uma faccao */
    PROCEDURE credenciar_comunidades(p_nome_faccao FACCAO.NOME%TYPE, col_comunidades TAB_COMUNIDADE) AS
    BEGIN
        FOR i IN col_comunidades.FIRST..col_comunidades.LAST LOOP
            INSERT INTO PARTICIPA(FACCAO, ESPECIE, COMUNIDADE)
            VALUES(p_nome_faccao, col_comunidades(i).ESPECIE, col_comunidades(i).NOME);
        END LOOP;
    END credenciar_comunidades;

END PAC_FUNC_LIDER_FACCAO;
/
