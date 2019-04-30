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

--
-- Detalhamento da Previdencia nos últimos 10 anos
SELECT
  strftime('%Y',m.Mes) as Ano,
  r.class3,
  sum( m.SUSEP_PremioBrutoSeguro +
       m.SUSEP_PGBL_Contrib +
       m.SUSEP_PrevTrad_Contrib) as Valor
FROM
  MSBr m
LEFT OUTER JOIN
  ramos r
  ON
    (m.Ramo= r.coramo)
WHERE
  r.class1='Previdência'
AND
  CAST(strftime('%Y',m.Mes) AS INTEGER) >= CAST( strftime('%Y', (SELECT base FROM mes)) AS INTEGER)-9
GROUP BY
  Ano,r.class3;





