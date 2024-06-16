CREATE OR REPLACE TYPE Comunidade_Record AS OBJECT (
    Nome            VARCHAR2(100),
    Nacao           VARCHAR2(100),
    Planeta         VARCHAR2(100),
    Sistema         VARCHAR2(100),
    Especie         VARCHAR2(100),
    QTD_Habitantes  NUMBER
);

/

CREATE OR REPLACE TYPE Comunidade_Table AS TABLE OF Comunidade_Record;

/

CREATE OR REPLACE PACKAGE Relatorios_Lider_de_Faccao AS
    
    -- Exceções personalizadas
    Sem_Dados EXCEPTION;
    Nao_Eh_Algo_Valido_Para_Ordenar EXCEPTION;

    -- Declaração da função que retorna uma tabela de registros
    FUNCTION Gerar_Relatorio(lider_logado IN lider.CPI%TYPE, ordenar_por VARCHAR2) 
    RETURN Comunidade_Table PIPELINED;

END Relatorios_Lider_de_Faccao;

/

CREATE OR REPLACE PACKAGE BODY Relatorios_Lider_de_Faccao AS

    -- Função para gerar o relatório
    FUNCTION Gerar_Relatorio(lider_logado IN lider.CPI%TYPE, ordenar_por VARCHAR2) RETURN Comunidade_Table PIPELINED IS
        CURSOR c_communities IS
            SELECT 
                C.NOME AS Nome,
                N.Nome AS Nacao,
                P.Id_Astro AS Planeta,
                S.Nome AS Sistema,
                PA.Especie AS Especie,
                C.QTD_Habitantes AS QTD_Habitantes
            FROM Lider L 
            JOIN Faccao F ON L.CPI = F.Lider AND L.CPI = lider_logado
            JOIN Nacao_Faccao NF ON NF.Faccao = F.Nome
            JOIN Nacao N ON N.Nome = NF.Nacao
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
            ORDER BY CASE UPPER(ordenar_por)
                        WHEN 'NACAO' THEN N.Nome
                        WHEN 'ESPECIE' THEN PA.Especie
                        WHEN 'PLANETA' THEN P.Id_Astro
                        WHEN 'SISTEMA' THEN S.Nome
                        ELSE NULL
                    END;
    BEGIN
        FOR rec IN c_communities LOOP
            PIPE ROW (Comunidade_Record(rec.Nome, rec.Nacao, rec.Planeta, rec.Sistema, rec.Especie, rec.QTD_Habitantes));
        END LOOP;
    END Gerar_Relatorio;

END Relatorios_Lider_de_Faccao;

/
