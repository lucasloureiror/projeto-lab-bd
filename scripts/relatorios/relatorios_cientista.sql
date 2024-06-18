CREATE OR REPLACE PACKAGE relatorios_cientista AS

    -- Função que retorna um SYS_REFCURSOR para o relatório 1
    FUNCTION Gerar_Relatorio1 RETURN SYS_REFCURSOR;

    -- Função que retorna um SYS_REFCURSOR para o relatório 2
    FUNCTION Gerar_Relatorio2 RETURN SYS_REFCURSOR;

    -- Função que retorna um SYS_REFCURSOR para o relatório 3
    FUNCTION Gerar_Relatorio3 RETURN SYS_REFCURSOR;

END relatorios_cientista;

/

CREATE OR REPLACE PACKAGE BODY relatorios_cientista AS

    -- Implementação da função Gerar_Relatorio1
    FUNCTION Gerar_Relatorio1 RETURN SYS_REFCURSOR IS
        cur SYS_REFCURSOR;
    BEGIN
        OPEN cur FOR
            SELECT 
                e.ID_ESTRELA,
                e.NOME AS Estrela_Nome,
                e.MASSA AS Estrela_Massa,
                e.CLASSIFICACAO AS Estrela_Classificacao,
                s.NOME AS Sistema_Nome,
                (SELECT COUNT(*) FROM ORBITA_PLANETA op WHERE op.ESTRELA = e.ID_ESTRELA) AS Qtd_Planetas_Orbitam,
                (SELECT COUNT(*) FROM ORBITA_ESTRELA oe WHERE oe.ORBITADA = e.ID_ESTRELA) AS Qtd_Estrelas_Orbitam,
                (SELECT COUNT(*) FROM ORBITA_ESTRELA oe WHERE oe.ORBITANTE = e.ID_ESTRELA) AS Qtd_Estrelas_Orbita,
                e.X AS Pos_X,
                e.Y AS Pos_Y,
                e.Z AS Pos_Z
            FROM ESTRELA e
            JOIN SISTEMA s ON e.ID_ESTRELA = s.ESTRELA;
        RETURN cur;
    END Gerar_Relatorio1;

    -- Implementação da função Gerar_Relatorio2
    FUNCTION Gerar_Relatorio2 RETURN SYS_REFCURSOR IS
        cur SYS_REFCURSOR;
    BEGIN
        OPEN cur FOR
            SELECT 
                p.ID_ASTRO,
                p.MASSA AS Planeta_Massa,
                p.CLASSIFICACAO AS Planeta_Classificacao,
                s.NOME AS Sistema_Nome,
                (SELECT COUNT(*) FROM ORBITA_PLANETA op WHERE op.PLANETA = p.ID_ASTRO) AS Qtd_Estrelas_Orbita
            FROM PLANETA p
            JOIN ORBITA_PLANETA op ON p.ID_ASTRO = op.PLANETA
            JOIN SISTEMA s ON op.ESTRELA = s.ESTRELA;
        RETURN cur;
    END Gerar_Relatorio2;

    -- Implementação da função Gerar_Relatorio3
    FUNCTION Gerar_Relatorio3 RETURN SYS_REFCURSOR IS
        cur SYS_REFCURSOR;
    BEGIN
        OPEN cur FOR
            SELECT 
                s.NOME AS Sistema_Nome,
                (SELECT COUNT(*) FROM ESTRELA e WHERE e.ID_ESTRELA = s.ESTRELA) AS Qtd_Estrelas,
                (SELECT COUNT(*) FROM ORBITA_PLANETA op WHERE op.ESTRELA = s.ESTRELA) AS Qtd_Planetas
            FROM SISTEMA s
            WHERE s.NOME IS NOT NULL;
        RETURN cur;
    END Gerar_Relatorio3;

END relatorios_cientista;

/