
CREATE OR REPLACE PACKAGE Relatorios_Lider_de_Faccao AS
    
    E_acesso_negado EXCEPTION;
    
    PROCEDURE Comunidades_por_Nacao(
     lider_logado IN lider%ROWTYPE);
        
    PROCEDURE Comunidades_por_especie(
     lider_logado IN lider%ROWTYPE);
     
    PROCEDURE Comunidades_por_planeta(
     lider_logado IN lider%ROWTYPE);
     
    PROCEDURE Comunidades_por_sistema(
     lider_logado IN lider%ROWTYPE);
    
END Relatorios_Lider_de_Faccao;

/

CREATE OR REPLACE PACKAGE BODY Relatorios_Lider_de_Faccao AS

    -- Verifica se o lider possui faccões
    /*FUNCTION Verificar_Faccoes_Lider(
     lider_logado IN lider%ROWTYPE)
     RETURN BOOLEAN IS
     v_faccao NUMBER;
     BEGIN 
        
        SELECT COUNT(*) INTO v_faccao
        FROM Lider L JOIN Faccao F;
     
        IF v_faccao > 1 THEN
            RETURN FALSE;
        ELSE    
            RETURN TRUE;
        END IF;
     END Verificar_Faccoes_Lider;*/
     
    PROCEDURE Comunidades_por_Nacao(
     lider_logado IN lider%ROWTYPE) IS
     
     BEGIN
        SELECT C.NOME AS Nome,
        N.Nome AS Nacao,
        P.Id_Astro AS Planeta,
        S.Nome AS Sistema,
        PA.Especie AS Especie,
        C.QTD_Habitantes AS QTD_Habitantes
        FROM Lider L 
        JOIN Faccao F ON L.CPI = F.Lider
        JOIN Nacao_Faccao NF ON NF.Faccao = F.Nome
        JOIN Nacao N ON N.Nome = NF.Nacao
        JOIN Dominancia D ON D.Nacao = N.Nome AND DATA_INI <= TRUNC(SYSDATE) AND
                    (DATA_FIM >= TRUNC(SYSDATE) OR DATA_FIM IS NULL)
        JOIN Planeta P ON P.Id_Astro = D.Planeta
        JOIN Orbita_Planeta OP ON OP.Planeta = P.Id_Astro
        JOIN Estrela E ON E.Id_Estrela = OP.Estrela
        JOIN Sistema S ON S.Estrela = E.Id_Estrela
        JOIN Participa PA ON PA.Faccao = F.Nome
        JOIN Comunidade C ON C.Especie = PA.Especie AND C.Nome = PA.Comunidade
        ORDER BY N.Nome;
     END Comunidades_por_Nacao;
     
    PROCEDURE Comunidades_por_especie(
     lider_logado IN lider%ROWTYPE) IS
     
     BEGIN
        SELECT C.NOME AS Nome,
        N.Nome AS Nacao,
        P.Id_Astro AS Planeta,
        S.Nome AS Sistema,
        PA.Especie AS Especie,
        C.QTD_Habitantes AS QTD_Habitantes
        FROM Lider L 
        JOIN Faccao F ON L.CPI = F.Lider
        JOIN Nacao_Faccao NF ON NF.Faccao = F.Nome
        JOIN Nacao N ON N.Nome = NF.Nacao
        JOIN Dominancia D ON D.Nacao = N.Nome AND DATA_INI <= TRUNC(SYSDATE) AND
                    (DATA_FIM >= TRUNC(SYSDATE) OR DATA_FIM IS NULL)
        JOIN Planeta P ON P.Id_Astro = D.Planeta
        JOIN Orbita_Planeta OP ON OP.Planeta = P.Id_Astro
        JOIN Estrela E ON E.Id_Estrela = OP.Estrela
        JOIN Sistema S ON S.Estrela = E.Id_Estrela
        JOIN Participa PA ON PA.Faccao = F.Nome
        JOIN Comunidade C ON C.Especie = PA.Especie AND C.Nome = PA.Comunidade
        ORDER BY PA.Especie;
     END Comunidades_por_especie;

    PROCEDURE Comunidades_por_planeta(
     lider_logado IN lider%ROWTYPE) IS
     
     BEGIN
        SELECT C.NOME AS Nome,
        N.Nome AS Nacao,
        P.Id_Astro AS Planeta,
        S.Nome AS Sistema,
        PA.Especie AS Especie,
        C.QTD_Habitantes AS QTD_Habitantes
        FROM Lider L 
        JOIN Faccao F ON L.CPI = F.Lider
        JOIN Nacao_Faccao NF ON NF.Faccao = F.Nome
        JOIN Nacao N ON N.Nome = NF.Nacao
        JOIN Dominancia D ON D.Nacao = N.Nome AND DATA_INI <= TRUNC(SYSDATE) AND
                    (DATA_FIM >= TRUNC(SYSDATE) OR DATA_FIM IS NULL)
        JOIN Planeta P ON P.Id_Astro = D.Planeta
        JOIN Orbita_Planeta OP ON OP.Planeta = P.Id_Astro
        JOIN Estrela E ON E.Id_Estrela = OP.Estrela
        JOIN Sistema S ON S.Estrela = E.Id_Estrela
        JOIN Participa PA ON PA.Faccao = F.Nome
        JOIN Comunidade C ON C.Especie = PA.Especie AND C.Nome = PA.Comunidade
        ORDER BY P.Id_Astro;
     END Comunidades_por_planeta;

    PROCEDURE Comunidades_por_sistema(
     lider_logado IN lider%ROWTYPE) IS
     
     BEGIN
        SELECT C.NOME AS Nome,
        N.Nome AS Nacao,
        P.Id_Astro AS Planeta,
        S.Nome AS Sistema,
        PA.Especie AS Especie,
        C.QTD_Habitantes AS QTD_Habitantes
        FROM Lider L 
        JOIN Faccao F ON L.CPI = F.Lider
        JOIN Nacao_Faccao NF ON NF.Faccao = F.Nome
        JOIN Nacao N ON N.Nome = NF.Nacao
        JOIN Dominancia D ON D.Nacao = N.Nome AND DATA_INI <= TRUNC(SYSDATE) AND
                    (DATA_FIM >= TRUNC(SYSDATE) OR DATA_FIM IS NULL)
        JOIN Planeta P ON P.Id_Astro = D.Planeta
        JOIN Orbita_Planeta OP ON OP.Planeta = P.Id_Astro
        JOIN Estrela E ON E.Id_Estrela = OP.Estrela
        JOIN Sistema S ON S.Estrela = E.Id_Estrela
        JOIN Participa PA ON PA.Faccao = F.Nome
        JOIN Comunidade C ON C.Especie = PA.Especie AND C.Nome = PA.Comunidade
        ORDER BY S.Nome;
     END Comunidades_por_sistema;
END Relatorios_Lider_de_Faccao;

/