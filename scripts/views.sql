/* Script de criacao das views utilizadas na base */

-- View para auxiliar no credenciamento de comunidades novas que habitem planetas dominados por nacoes onde a faccao esta presente
CREATE OR REPLACE VIEW VIEW_COMUNIDADE_CREDENCIADA AS
SELECT f.NOME AS FACCAO,
    nf.NACAO AS NACAO_ASSOCIADA,
    d.PLANETA AS PLANETA_DOMINADO,
    h.ESPECIE AS ESPECIE_HABITA,
    h.COMUNIDADE AS COMUNIDADE_HABITA,
    CASE
        WHEN EXISTS(
            SELECT 1 FROM PARTICIPA
            WHERE FACCAO = f.NOME
            AND ESPECIE = h.ESPECIE
            AND COMUNIDADE = h.COMUNIDADE
        )
        THEN 'SIM' 
        ELSE 'NAO' 
    END AS COMUNIDADE_CREDENCIADA
FROM FACCAO f
JOIN NACAO_FACCAO nf
    ON nf.FACCAO = f.NOME
JOIN (
    SELECT PLANETA, NACAO
    FROM DOMINANCIA
    WHERE DATA_INI <= SYSDATE
    AND DATA_FIM IS NULL OR DATA_FIM >= SYSDATE
) d ON d.NACAO = nf.NACAO
JOIN (
    SELECT PLANETA, ESPECIE, COMUNIDADE
    FROM HABITACAO
    WHERE DATA_INI <= SYSDATE
    AND DATA_FIM IS NULL OR DATA_FIM >= SYSDATE
) h ON h.PLANETA = d.PLANETA
ORDER BY FACCAO;
