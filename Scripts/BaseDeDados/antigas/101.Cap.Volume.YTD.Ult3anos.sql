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

-- Capitalização

-------------------------------------------------
-- Total até o mês atual para os últimos 3 anos
-------------------------------------------------

SELECT
  strftime('%Y',m.Mes) as Ano,
  sum(m.SUSEP_Capitalizacao_Premio*
    CASE
    WHEN CAST(strftime('%m',m.Mes) as INTEGER) <= CAST( strftime('%m', (SELECT base from mes)) as INTEGER)
      THEN 1
    ELSE 0
    END)/1e9 as Valor
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
  r.class1 = 'Capitalização'
AND
  CAST(strftime('%Y',m.Mes) AS INTEGER) >= CAST( strftime('%Y', (SELECT base FROM mes)) AS INTEGER)-2
GROUP BY
  Ano;
