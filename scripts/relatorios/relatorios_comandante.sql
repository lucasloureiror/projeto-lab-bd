CREATE OR REPLACE TYPE Planeta_Dominado_Info AS OBJECT (
    ID_Planeta          VARCHAR2(15),
    Nacao_Dominante     VARCHAR2(100),
    Data_Ini            DATE,
    Data_Fim            DATE,
    Qtd_Comunidades     NUMBER,
    Qtd_Especies        NUMBER,
    Total_Habitantes    NUMBER,
    Qtd_Faccoes         NUMBER,
    Faccao_Majoritaria  VARCHAR2(100)
);

/

CREATE OR REPLACE TYPE Planeta_Dominado_Table AS TABLE OF Planeta_Dominado_Info;

/

CREATE OR REPLACE TYPE Planeta_Potencial_Record AS OBJECT (
    planeta VARCHAR2(15),
    estrela VARCHAR2(31),
    coord_x NUMBER,
    coord_y NUMBER,
    coord_z NUMBER
);

/

CREATE OR REPLACE TYPE Planeta_Potencial_Table IS TABLE OF Planeta_Potencial_Record;

/

CREATE OR REPLACE PACKAGE Relatorios_Comandante AS
    -- Exceções personalizadas
    Sem_Dados EXCEPTION;
    Nao_Eh_Algo_Valido_Para_Ordenar EXCEPTION;

    -- Declaração dos tipos de dados de cursor
    TYPE Dominacao_Cursor IS REF CURSOR;
    TYPE Potencial_Expansao_Cursor IS REF CURSOR;

    -- Declaração das funções que retornam um cursor
    FUNCTION Gerar_Relatorio_Dominacao(lider_logado IN lider.CPI%TYPE) 
    RETURN Dominacao_Cursor;

    FUNCTION Gerar_Relatorio_Potencial_Expansao(lider_logado IN lider.CPI%TYPE, distancia_maxima NUMBER) 
    RETURN Potencial_Expansao_Cursor;
END Relatorios_Comandante;


/
CREATE OR REPLACE FUNCTION CALC_DISTANCIA_EUCLIDIANA(x1 NUMBER, y1 NUMBER, z1 NUMBER, x2 NUMBER, y2 NUMBER, z2 NUMBER)
RETURN NUMBER
IS
BEGIN
    RETURN SQRT(POWER(x2 - x1, 2) + POWER(y2 - y1, 2) + POWER(z2 - z1, 2));
END;

/

-- Corpo do pacote implementando as fun��es
CREATE OR REPLACE PACKAGE BODY Relatorios_Comandante AS

    FUNCTION Gerar_Relatorio_Dominacao(lider_logado IN lider.CPI%TYPE) 
    RETURN Dominacao_Cursor IS
        v_cursor Dominacao_Cursor;
    BEGIN
        OPEN v_cursor FOR
            SELECT 
                p.id_astro AS ID_Planeta,
                d.nacao AS Nacao_Dominante,
                d.data_ini AS Data_Ini,
                d.data_fim AS Data_Fim,
                (SELECT COUNT(*) FROM Comunidade c JOIN Habitacao h ON c.especie = h.especie AND c.nome = h.comunidade WHERE h.planeta = p.id_astro) AS Qtd_Comunidades,
                (SELECT COUNT(DISTINCT e.nome) FROM Especie e JOIN Habitacao h ON e.nome = h.especie WHERE h.planeta = p.id_astro) AS Qtd_Especies,
                (SELECT SUM(c.qtd_habitantes) FROM Comunidade c JOIN Habitacao h ON c.especie = h.especie AND c.nome = h.comunidade WHERE h.planeta = p.id_astro) AS Total_Habitantes,
                (SELECT COUNT(DISTINCT pa.faccao) FROM Participa pa JOIN Comunidade c ON pa.especie = c.especie AND pa.comunidade = c.nome JOIN Habitacao h ON c.especie = h.especie AND c.nome = h.comunidade WHERE h.planeta = p.id_astro) AS Qtd_Faccoes,
                (SELECT pa.faccao FROM Participa pa JOIN Comunidade c ON pa.especie = c.especie AND pa.comunidade = c.nome JOIN Habitacao h ON c.especie = h.especie AND c.nome = h.comunidade WHERE h.planeta = p.id_astro GROUP BY pa.faccao ORDER BY COUNT(*) DESC FETCH FIRST 1 ROWS ONLY) AS Faccao_Majoritaria
            FROM 
                Planeta p
                LEFT JOIN Dominancia d ON p.id_astro = d.planeta AND (d.data_fim IS NULL OR d.data_fim > SYSDATE);
        RETURN v_cursor;
    END Gerar_Relatorio_Dominacao;

   FUNCTION Gerar_Relatorio_Potencial_Expansao(lider_logado IN lider.CPI%TYPE, distancia_maxima NUMBER) 
    RETURN Potencial_Expansao_Cursor IS
        v_cursor Potencial_Expansao_Cursor;
        p_nacao Nacao.Nome%TYPE;
    BEGIN
        SELECT L.Nacao INTO p_nacao FROM
        Lider L WHERE L.CPI = lider_logado;

        OPEN v_cursor FOR
            SELECT 
                pl.id_astro AS planeta,
                est.nome AS estrela,
                est.x AS coord_x,
                est.y AS coord_y,
                est.z AS coord_z
            FROM planeta pl
            JOIN orbita_planeta op ON pl.id_astro = op.planeta
            JOIN estrela est ON op.estrela = est.id_estrela
            WHERE NOT EXISTS (
                SELECT 1 FROM dominancia d WHERE d.planeta = pl.id_astro AND (d.data_fim IS NULL OR d.data_fim > SYSDATE)
            )
            AND EXISTS (
                SELECT 1
                FROM orbita_planeta op2
                JOIN estrela est2 ON op2.estrela = est2.id_estrela
                JOIN dominancia dom ON dom.planeta = op2.planeta
                WHERE dom.nacao = p_nacao
                AND CALC_DISTANCIA_EUCLIDIANA(est2.x, est2.y, est2.z, est.x, est.y, est.z) <= distancia_maxima
            );
        RETURN v_cursor;
    END Gerar_Relatorio_Potencial_Expansao;

END Relatorios_Comandante;