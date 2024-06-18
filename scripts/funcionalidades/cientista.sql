/* Funcionalidades de gerenciamento do Cientista:
 * a. Gerenciar (CRUD) estrelas
 * */

CREATE OR REPLACE PACKAGE PAC_FUNC_CIENTISTA AS

    PROCEDURE criar_estrela(
        p_id_estrela ESTRELA.ID_ESTRELA%TYPE,
        p_nome ESTRELA.NOME%TYPE,
        p_classificacao ESTRELA.CLASSIFICACAO%TYPE,
        p_massa ESTRELA.MASSA%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    );
    FUNCTION buscar_estrela(p_id_estrela ESTRELA.ID_ESTRELA%TYPE) RETURN ESTRELA%ROWTYPE;
    PROCEDURE atualizar_estrela(
        p_id_estrela ESTRELA.ID_ESTRELA%TYPE,
        p_nome ESTRELA.NOME%TYPE,
        p_classificacao ESTRELA.CLASSIFICACAO%TYPE,
        p_massa ESTRELA.MASSA%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    );
    PROCEDURE remover_estrela(p_id_estrela ESTRELA.ID_ESTRELA%TYPE);

END PAC_FUNC_CIENTISTA;
/

CREATE OR REPLACE PACKAGE BODY PAC_FUNC_CIENTISTA AS
    /* Declaracao de funcoes/procedimentos privados */
    FUNCTION coordenadas_ja_existem(p_x ESTRELA.X%TYPE, p_y ESTRELA.Y%TYPE, p_z ESTRELA.Z%TYPE) RETURN BOOLEAN;

    /* Procedimento publico: Criar uma nova estrela */
    PROCEDURE criar_estrela(
        p_id_estrela ESTRELA.ID_ESTRELA%TYPE,
        p_nome ESTRELA.NOME%TYPE,
        p_classificacao ESTRELA.CLASSIFICACAO%TYPE,
        p_massa ESTRELA.MASSA%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    ) AS
        e_coordenadas_ja_existem EXCEPTION;
        e_inserir_null EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_inserir_null, -1400);
    BEGIN
        IF COORDENADAS_JA_EXISTEM(p_x, p_y, p_z) THEN
            RAISE e_coordenadas_ja_existem;
        END IF;
    
        INSERT INTO ESTRELA(ID_ESTRELA, NOME, CLASSIFICACAO, MASSA, X, Y, Z)
        VALUES(p_id_estrela, p_nome, p_classificacao, p_massa, p_x, p_y, p_z);
        
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20003, 'Estrela ja existe, altere o ID e tente novamente.');
            WHEN e_coordenadas_ja_existem THEN RAISE_APPLICATION_ERROR(-20003, 'Estrela ja existe, altere as coordenadas e tente novamente.');
            WHEN e_inserir_null THEN RAISE_APPLICATION_ERROR(-20004, 'Os atributos "ID_ESTRELA", "X", "Y" e "Z" nao podem ser nulos.');
    END criar_estrela;
    
    /* Funcao publica: Buscar (ler) uma estrela existente */
    FUNCTION buscar_estrela(p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE)
    RETURN ESTRELA%ROWTYPE AS
        v_estrela ESTRELA%ROWTYPE;
    BEGIN
        SELECT * INTO v_estrela FROM ESTRELA
        WHERE ID_ESTRELA = p_id_estrela;
        
        RETURN v_estrela;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20001, 'Estrela nao encontrada.');
    END buscar_estrela;
    
    /* Procedimento publico: atualizar uma estrela existente */
    PROCEDURE atualizar_estrela(
        p_id_estrela ESTRELA.ID_ESTRELA%TYPE,
        p_nome ESTRELA.NOME%TYPE,
        p_classificacao ESTRELA.CLASSIFICACAO%TYPE,
        p_massa ESTRELA.MASSA%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    ) AS
        e_estrela_nao_existe EXCEPTION;
        e_atualizar_para_null EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_atualizar_para_null, -1407);
    BEGIN
        UPDATE ESTRELA
        SET NOME = p_nome,
            CLASSIFICACAO = p_classificacao,
            MASSA = p_massa,
            X = p_x, 
            Y = p_y,
            Z = p_z
        WHERE ID_ESTRELA = p_id_estrela;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE e_estrela_nao_existe;
        END IF;

        EXCEPTION
            WHEN e_estrela_nao_existe THEN RAISE_APPLICATION_ERROR(-20001, 'Estrela nao encontrada.');
            WHEN e_atualizar_para_null THEN RAISE_APPLICATION_ERROR(-20004, 'Os atributos "ID_ESTRELA", "X", "Y" e "Z" nao podem ser nulos.');
    END atualizar_estrela;
    
    /* Procedimento publico: remover uma estrela existente */
    PROCEDURE remover_estrela(p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE) AS
        e_estrela_nao_existe EXCEPTION;
    BEGIN
        DELETE FROM ESTRELA
        WHERE ID_ESTRELA = p_id_estrela;
        
        IF SQL%NOTFOUND THEN
            RAISE e_estrela_nao_existe;
        END IF;

        EXCEPTION
            WHEN e_estrela_nao_existe THEN RAISE_APPLICATION_ERROR(-20001, 'Estrela nao encontrada.');
    END remover_estrela;
    
    /* Funcao privada: Verifica se as coordenadas de uma estrela ja existem */
    FUNCTION coordenadas_ja_existem(p_x ESTRELA.X%TYPE, p_y ESTRELA.Y%TYPE, p_z ESTRELA.Z%TYPE)
    RETURN BOOLEAN IS 
        v_qtd_estrelas NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_qtd_estrelas
        FROM ESTRELA
        WHERE X = p_x AND Y = p_y AND Z = p_z;
        
        RETURN v_qtd_estrelas > 0;
    END coordenadas_ja_existem;

END PAC_FUNC_CIENTISTA;
/
