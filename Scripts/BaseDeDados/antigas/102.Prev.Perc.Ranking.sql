-- Consultas a serem usadas no Relatorio

/*  Campos da tabela principal MSBr
CREATE TABLE MSBr (
  Fonte varchar(30),
  Mes date,
  codFIP varchar(6),
  Ramo varchar(20),
  SUSEP_PremioBrutoSeguro numeric,
  SUSEP_PremioGanho numeric,
  SUSEP_CessaoResseguro numeric,
  SUSEP_SinistroRetido numeric,
  SUSEP_DespesasComerciais numeric,
  ANS_ReceitaContraprestacoes numeric,
  ANS_DespAdmin numeric,
  ANS_DespAssist numeric,
  ANS_CessaoResseguro numeric,
  SUSEP_PGBL_Contrib numeric,
  SUSEP_PrevTrad_Contrib numeric,
  SUSEP_Capitalizacao_Premio numeric,
  SUSEP_Resseguro_Premio numeric,
  SUSEP_Resseguro_Sinistro numeric );

*/

--Previdência Complementar Aberta
-------------------------------------------------------------------------
-- Ranking: Cedentes em AAAA/MM e AAAA-1/12, ordem decrescente, $ e %
-------------------------------------------------------------------------
SELECT
  CASE
    WHEN strftime('%Y',m.Mes) = strftime('%Y', (SELECT base FROM mes))
      THEN strftime('%Y/%m', (SELECT base FROM mes))
    ELSE strftime('%Y/12',m.Mes)
  END as Ano,
  c.Grupo,
  sum(m.SUSEP_PremioBrutoSeguro + m.SUSEP_PGBL_Contrib + m.SUSEP_PrevTrad_Contrib)/1e9 as Total
FROM
  MSBr m
LEFT OUTER JOIN
  cedentes c
ON
  (m.codFIP = c.CodigoFIP)
LEFT OUTER JOIN
  ramos r
ON
  (m.Ramo = r.coramo)
WHERE
  r.class1='Previdência (EAPC)'
  AND
    CAST(strftime('%Y',m.Mes) AS INTEGER) >= CAST(strftime('%Y', (SELECT base FROM mes)) AS INTEGER)-1
GROUP BY
  Ano, c.Grupo
ORDER BY Ano ASC, Total DESC;


