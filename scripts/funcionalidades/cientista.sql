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
    FUNCTION atualizar_estrela(
        p_id_estrela ESTRELA.ID_ESTRELA%TYPE,
        p_nome ESTRELA.NOME%TYPE,
        p_classificacao ESTRELA.CLASSIFICACAO%TYPE,
        p_massa ESTRELA.MASSA%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    ) RETURN ESTRELA%ROWTYPE;
    PROCEDURE remover_estrela(p_id_estrela ESTRELA.ID_ESTRELA%TYPE);

END PAC_FUNC_CIENTISTA;
/

CREATE OR REPLACE PACKAGE BODY PAC_FUNC_CIENTISTA AS
    /* Declaracao de funcoes/procedimentos privados */
    FUNCTION coordenadas_ja_existem(p_x ESTRELA.X%TYPE, p_y ESTRELA.Y%TYPE, p_z ESTRELA.Z%TYPE) RETURN BOOLEAN;
    FUNCTION verifica_campos_atualizar(p_estrela_atual ESTRELA%ROWTYPE, p_dados_fornecidos ESTRELA%ROWTYPE) RETURN ESTRELA%ROWTYPE;

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
    FUNCTION atualizar_estrela(
        p_id_estrela ESTRELA.ID_ESTRELA%TYPE,
        p_nome ESTRELA.NOME%TYPE,
        p_classificacao ESTRELA.CLASSIFICACAO%TYPE,
        p_massa ESTRELA.MASSA%TYPE,
        p_x ESTRELA.X%TYPE,
        p_y ESTRELA.Y%TYPE,
        p_z ESTRELA.Z%TYPE
    ) RETURN ESTRELA%ROWTYPE AS
        v_estrela_atual ESTRELA%ROWTYPE;
        v_estrela_atualizar ESTRELA%ROWTYPE;
        v_dados_fornecidos ESTRELA%ROWTYPE;
        e_atualizar_para_null EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_atualizar_para_null, -1407);
    BEGIN
        v_estrela_atual := BUSCAR_ESTRELA(p_id_estrela);
        
        v_dados_fornecidos.NOME := p_nome;
        v_dados_fornecidos.CLASSIFICACAO := p_classificacao;
        v_dados_fornecidos.MASSA := p_massa;
        v_dados_fornecidos.X := p_x;
        v_dados_fornecidos.Y := p_y;
        v_dados_fornecidos.Z := p_z;
        
        v_estrela_atualizar := VERIFICA_CAMPOS_ATUALIZAR(v_estrela_atual, v_dados_fornecidos);
    
        UPDATE ESTRELA
        SET NOME = v_estrela_atualizar.NOME,
            CLASSIFICACAO = v_estrela_atualizar.CLASSIFICACAO,
            MASSA = v_estrela_atualizar.MASSA,
            X = v_estrela_atualizar.X, 
            Y = v_estrela_atualizar.Y,
            Z = v_estrela_atualizar.Z
        WHERE ID_ESTRELA = p_id_estrela;
        
        RETURN v_estrela_atualizar;

        EXCEPTION
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
    
    /* Função privada: Verifica quais campos da estrela devem ser atualizados */
    FUNCTION verifica_campos_atualizar(p_estrela_atual ESTRELA%ROWTYPE, p_dados_fornecidos ESTRELA%ROWTYPE)
    RETURN ESTRELA%ROWTYPE IS
        v_estrela_atualizar ESTRELA%ROWTYPE;
    BEGIN
        IF p_dados_fornecidos.NOME IS NULL THEN
            v_estrela_atualizar.NOME := p_estrela_atual.NOME;
        ELSE
            v_estrela_atualizar.NOME := p_dados_fornecidos.NOME; 
        END IF;
        
        IF p_dados_fornecidos.CLASSIFICACAO IS NULL THEN
            v_estrela_atualizar.CLASSIFICACAO := p_estrela_atual.CLASSIFICACAO;
        ELSE
            v_estrela_atualizar.CLASSIFICACAO := p_dados_fornecidos.CLASSIFICACAO; 
        END IF;
        
        IF p_dados_fornecidos.MASSA IS NULL THEN
            v_estrela_atualizar.MASSA := p_estrela_atual.MASSA;
        ELSE
            v_estrela_atualizar.MASSA := p_dados_fornecidos.MASSA; 
        END IF;
        
        IF p_dados_fornecidos.X IS NULL THEN
            v_estrela_atualizar.X := p_estrela_atual.X;
        ELSE
            v_estrela_atualizar.X := p_dados_fornecidos.X; 
        END IF;
        
        IF p_dados_fornecidos.Y IS NULL THEN
            v_estrela_atualizar.Y := p_estrela_atual.Y;
        ELSE
            v_estrela_atualizar.Y := p_dados_fornecidos.Y; 
        END IF;
        
        IF p_dados_fornecidos.Z IS NULL THEN
            v_estrela_atualizar.Z := p_estrela_atual.Z;
        ELSE
            v_estrela_atualizar.Z := p_dados_fornecidos.Z; 
        END IF;
        
        RETURN v_estrela_atualizar;
    END verifica_campos_atualizar;

END PAC_FUNC_CIENTISTA;
/
