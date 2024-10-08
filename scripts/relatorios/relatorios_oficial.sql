CREATE OR REPLACE TYPE Habitantes_Record AS OBJECT (
    Nome            VARCHAR2(100),
    Faccao          VARCHAR2(100),
    Planeta         VARCHAR2(100),
    Sistema         VARCHAR2(100),
    Especie         VARCHAR2(100),
    QTD_Habitantes  NUMBER
);

/

CREATE OR REPLACE TYPE Habitantes_Table_Geral AS TABLE OF Habitantes_Record;

/

CREATE OR REPLACE PACKAGE Relatorios_Oficial AS
    
    -- Exceções personalizadas
    Sem_Dados EXCEPTION;
    Nao_Eh_Algo_Valido_Para_Ordenar EXCEPTION;

    -- Declaração da função que retorna uma tabela de registros
    FUNCTION Gerar_Relatorio_Habitantes_Geral(lider_logado IN lider.CPI%TYPE)
    RETURN  SYS_REFCURSOR;

    FUNCTION Gerar_Relatorio_Habitantes_Faccao(lider_logado IN lider.CPI%TYPE)
    RETURN SYS_REFCURSOR;

    FUNCTION Gerar_Relatorio_Habitantes_Sistemas(lider_logado IN lider.CPI%TYPE)
    RETURN SYS_REFCURSOR;
    
    FUNCTION Gerar_Relatorio_Habitantes_Planetas(lider_logado IN lider.CPI%TYPE)
    RETURN SYS_REFCURSOR;
    
    FUNCTION Gerar_Relatorio_Habitantes_Especies(lider_logado IN lider.CPI%TYPE)
    RETURN SYS_REFCURSOR;
    
END Relatorios_Oficial;

/

CREATE OR REPLACE PACKAGE BODY Relatorios_Oficial AS
    
    FUNCTION Gerar_Relatorio_Habitantes_Geral(lider_logado IN lider.CPI%TYPE)
    RETURN SYS_REFCURSOR IS
        v_nacao_lider Nacao.Nome%TYPE;
        cur SYS_REFCURSOR;
    BEGIN
        SELECT L.Nacao INTO v_nacao_lider FROM
        Lider L WHERE L.CPI = lider_logado;
    
        OPEN cur FOR
            SELECT 
                C.NOME AS Nome,
                F.Nome AS Faccao,
                P.Id_Astro AS Planeta,
                S.Nome AS Sistema,
                PA.Especie AS Especie,
                C.QTD_Habitantes AS QTD_Habitantes
            FROM Nacao N 
            JOIN Nacao_Faccao NF ON NF.nacao = N.Nome AND N.Nome = v_nacao_lider
            JOIN Faccao F ON F.Nome = NF.Faccao
            JOIN Dominancia D ON D.Nacao = N.Nome AND D.DATA_INI <= TRUNC(SYSDATE) AND
                            (D.DATA_FIM >= TRUNC(SYSDATE) OR D.DATA_FIM IS NULL)
            JOIN Planeta P ON P.Id_Astro = D.Planeta
            JOIN Orbita_Planeta OP ON OP.Planeta = P.Id_Astro
            JOIN Estrela E ON E.Id_Estrela = OP.Estrela
            JOIN Sistema S ON S.Estrela = E.Id_Estrela
            JOIN Participa PA ON PA.Faccao = F.Nome
            JOIN Comunidade C ON C.Especie = PA.Especie AND C.Nome = PA.Comunidade
            JOIN Habitacao H ON H.Comunidade = C.Nome AND H.Planeta = P.Id_Astro AND H.Especie = C.Especie AND H.DATA_INI <= TRUNC(SYSDATE) AND
                            (H.DATA_FIM >= TRUNC(SYSDATE) OR H.DATA_FIM IS NULL)
            ORDER BY F.Nome;
        RETURN cur;
    END Gerar_Relatorio_Habitantes_Geral;
    
    -- Faccao
    
    FUNCTION Gerar_Relatorio_Habitantes_Faccao(lider_logado IN lider.CPI%TYPE)
    RETURN SYS_REFCURSOR IS
        v_nacao_lider Nacao.Nome%TYPE;
        cur SYS_REFCURSOR;
    BEGIN
        SELECT L.Nacao INTO v_nacao_lider FROM
        Lider L WHERE L.CPI = lider_logado;
    
        OPEN cur FOR
            SELECT 
                F.Nome AS Faccao,
                SUM(C.QTD_Habitantes) AS QTD_Habitantes
            FROM Nacao N 
            JOIN Nacao_Faccao NF ON NF.nacao = N.Nome AND N.Nome = v_nacao_lider
            JOIN Faccao F ON F.Nome = NF.Faccao
            JOIN Dominancia D ON D.Nacao = N.Nome AND D.DATA_INI <= TRUNC(SYSDATE) AND
                            (D.DATA_FIM >= TRUNC(SYSDATE) OR D.DATA_FIM IS NULL)
            JOIN Planeta P ON P.Id_Astro = D.Planeta
            JOIN Orbita_Planeta OP ON OP.Planeta = P.Id_Astro
            JOIN Estrela E ON E.Id_Estrela = OP.Estrela
            JOIN Sistema S ON S.Estrela = E.Id_Estrela
            JOIN Participa PA ON PA.Faccao = F.Nome
            JOIN Comunidade C ON C.Especie = PA.Especie AND C.Nome = PA.Comunidade
            JOIN Habitacao H ON H.Comunidade = C.Nome AND H.Planeta = P.Id_Astro AND H.Especie = C.Especie AND H.DATA_INI <= TRUNC(SYSDATE) AND
                            (H.DATA_FIM >= TRUNC(SYSDATE) OR H.DATA_FIM IS NULL)
            GROUP BY F.Nome;
        RETURN cur;
    END Gerar_Relatorio_Habitantes_Faccao;
    
    -- Sistemas
    
    FUNCTION Gerar_Relatorio_Habitantes_Sistemas(lider_logado IN lider.CPI%TYPE)
    RETURN SYS_REFCURSOR IS
        v_nacao_lider Nacao.Nome%TYPE;
        cur SYS_REFCURSOR;
    BEGIN
        SELECT L.Nacao INTO v_nacao_lider FROM
        Lider L WHERE L.CPI = lider_logado;
    
        OPEN cur FOR
            SELECT 
                S.Nome AS Sistema,
                SUM(C.QTD_Habitantes) AS QTD_Habitantes
            FROM Nacao N 
            JOIN Nacao_Faccao NF ON NF.nacao = N.Nome AND N.Nome = v_nacao_lider
            JOIN Faccao F ON F.Nome = NF.Faccao
            JOIN Dominancia D ON D.Nacao = N.Nome AND D.DATA_INI <= TRUNC(SYSDATE) AND
                            (D.DATA_FIM >= TRUNC(SYSDATE) OR D.DATA_FIM IS NULL)
            JOIN Planeta P ON P.Id_Astro = D.Planeta
            JOIN Orbita_Planeta OP ON OP.Planeta = P.Id_Astro
            JOIN Estrela E ON E.Id_Estrela = OP.Estrela
            JOIN Sistema S ON S.Estrela = E.Id_Estrela
            JOIN Participa PA ON PA.Faccao = F.Nome
            JOIN Comunidade C ON C.Especie = PA.Especie AND C.Nome = PA.Comunidade
            JOIN Habitacao H ON H.Comunidade = C.Nome AND H.Planeta = P.Id_Astro AND H.Especie = C.Especie AND H.DATA_INI <= TRUNC(SYSDATE) AND
                            (H.DATA_FIM >= TRUNC(SYSDATE) OR H.DATA_FIM IS NULL)
            GROUP BY S.Nome
            ORDER BY QTD_Habitantes DESC;
        RETURN cur;
    END Gerar_Relatorio_Habitantes_Sistemas;
    
    -- Planeta
    
    FUNCTION Gerar_Relatorio_Habitantes_Planetas(lider_logado IN lider.CPI%TYPE)
    RETURN SYS_REFCURSOR IS
        v_nacao_lider Nacao.Nome%TYPE;
        cur SYS_REFCURSOR;
    BEGIN
        SELECT L.Nacao INTO v_nacao_lider FROM
        Lider L WHERE L.CPI = lider_logado;
    
        OPEN cur FOR
            SELECT 
                P.Id_Astro AS Planeta,
                SUM(C.QTD_Habitantes) AS QTD_Habitantes
            FROM Nacao N 
            JOIN Nacao_Faccao NF ON NF.nacao = N.Nome AND N.Nome = v_nacao_lider
            JOIN Faccao F ON F.Nome = NF.Faccao
            JOIN Dominancia D ON D.Nacao = N.Nome AND D.DATA_INI <= TRUNC(SYSDATE) AND
                            (D.DATA_FIM >= TRUNC(SYSDATE) OR D.DATA_FIM IS NULL)
            JOIN Planeta P ON P.Id_Astro = D.Planeta
            JOIN Orbita_Planeta OP ON OP.Planeta = P.Id_Astro
            JOIN Estrela E ON E.Id_Estrela = OP.Estrela
            JOIN Sistema S ON S.Estrela = E.Id_Estrela
            JOIN Participa PA ON PA.Faccao = F.Nome
            JOIN Comunidade C ON C.Especie = PA.Especie AND C.Nome = PA.Comunidade
            JOIN Habitacao H ON H.Comunidade = C.Nome AND H.Planeta = P.Id_Astro AND H.Especie = C.Especie
            AND H.DATA_INI <= TRUNC(SYSDATE) AND
                            (H.DATA_FIM >= TRUNC(SYSDATE) OR H.DATA_FIM IS NULL)
            GROUP BY P.Id_Astro
            ORDER BY QTD_Habitantes DESC;
        RETURN cur;
    END Gerar_Relatorio_Habitantes_Planetas;
    
    -- Especie
    
    FUNCTION Gerar_Relatorio_Habitantes_Especies(lider_logado IN lider.CPI%TYPE)
    RETURN SYS_REFCURSOR IS
        v_nacao_lider Nacao.Nome%TYPE;
        cur SYS_REFCURSOR;
    BEGIN
        SELECT L.Nacao INTO v_nacao_lider FROM
        Lider L WHERE L.CPI = lider_logado;
    
        OPEN cur FOR
            SELECT 
                PA.Especie AS Especie,
                SUM(C.QTD_Habitantes) AS QTD_Habitantes
            FROM Nacao N 
            JOIN Nacao_Faccao NF ON NF.nacao = N.Nome AND N.Nome = v_nacao_lider
            JOIN Faccao F ON F.Nome = NF.Faccao
            JOIN Dominancia D ON D.Nacao = N.Nome AND D.DATA_INI <= TRUNC(SYSDATE) AND
                            (D.DATA_FIM >= TRUNC(SYSDATE) OR D.DATA_FIM IS NULL)
            JOIN Planeta P ON P.Id_Astro = D.Planeta
            JOIN Orbita_Planeta OP ON OP.Planeta = P.Id_Astro
            JOIN Estrela E ON E.Id_Estrela = OP.Estrela
            JOIN Sistema S ON S.Estrela = E.Id_Estrela
            JOIN Participa PA ON PA.Faccao = F.Nome
            JOIN Comunidade C ON C.Especie = PA.Especie AND C.Nome = PA.Comunidade
            JOIN Habitacao H ON H.Comunidade = C.Nome AND H.Planeta = P.Id_Astro AND H.Especie = C.Especie
            AND H.DATA_INI <= TRUNC(SYSDATE) AND
                            (H.DATA_FIM >= TRUNC(SYSDATE) OR H.DATA_FIM IS NULL)
            GROUP BY PA.Especie
            ORDER BY QTD_Habitantes DESC;
        RETURN cur;
    END Gerar_Relatorio_Habitantes_Especies;
END Relatorios_Oficial;
/
