
/*CREATE OR REPLACE PACKAGE Relatorios_Lider_de_Faccao AS
    
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

CREATE OR REPLACE PACKAGE BODY Relatorios_Lider_de_Faccao AS

    -- Verifica se o lider possui faccões
    FUNCTION Verificar_Faccoes_Lider(
     lider_logado IN lider%ROWTYPE)
     RETURN BOOLEAN
     
     BEGIN 
        
        SELECT * FROM Lider L JOIN 
        Faccao F ON L.CPI = F.Lider
        JOIN Nacao_Faccao NF ON NF.Faccao = F.Nome
        JOIN Nacao N ON N.Nome = NF.Nacao;
     
     END;
    
    

END Relatorios_Lider_de_Faccao;

/


SELECT * FROM Lider L JOIN 
        Faccao F ON L.CPI = F.Lider
        JOIN Nacao_Faccao NF ON NF.Faccao = F.Nome
        JOIN Nacao N ON N.Nome = NF.Nacao;*/