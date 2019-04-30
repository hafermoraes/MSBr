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
---------------------------------------------------------------------------------------------
-- Tabela 3: Maiores Grupos Seguradores por Ramo de Negócios em dezembro do ano anterior
---------------------------------------------------------------------------------------------
-- VGBL classificado como 'Pessoas'
SELECT
  strftime('%Y',m.Mes) as Ano,
  r.class1a as LN,
  c.Grupo,
  sum( m.SUSEP_PremioBrutoSeguro+
   m.ANS_ReceitaContraprestacoes+
   m.SUSEP_PGBL_Contrib+
   m.SUSEP_PrevTrad_Contrib+
   m.SUSEP_Capitalizacao_Premio)/1e9 as Volume
FROM
  MSBr m
LEFT OUTER JOIN
  ramos r
  ON (m.Ramo = r.coramo)
LEFT OUTER JOIN
  cedentes c
  ON (m.codFIP = c.CodigoFIP)
WHERE
  CAST(strftime('%Y',m.Mes) AS INTEGER) >= CAST(strftime('%Y',(SELECT DATE(base, '-1 years') FROM mes)) AS INTEGER)
GROUP BY
  strftime('%Y',m.Mes), r.class1a, c.Grupo
ORDER BY Ano ASC, LN ASC, Volume DESC;
