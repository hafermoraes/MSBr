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
-- Total de prêmios com banco/independente nos últimos 10 anos
SELECT
  strftime('%Y',m.Mes) as Ano,
  sum(  m.SUSEP_PremioBrutoSeguro + m.SUSEP_PGBL_Contrib + m.SUSEP_PrevTrad_Contrib )/1e9 as Total,
  sum(
    CASE
      WHEN c.banco = '' THEN 1
        ELSE 0
      END *  ( m.SUSEP_PremioBrutoSeguro + m.SUSEP_PGBL_Contrib + m.SUSEP_PrevTrad_Contrib)
     )/1e9 as Independente,
  sum(
    CASE
      WHEN c.banco = '' THEN 0
        ELSE 1
      END *  ( m.SUSEP_PremioBrutoSeguro + m.SUSEP_PGBL_Contrib + m.SUSEP_PrevTrad_Contrib)
    )/1e9 as Banco
FROM
  MSBr m
LEFT OUTER JOIN
  cedentes c , ramos r
ON
  (m.codFIP = c.CodigoFIP AND m.Ramo = r.coramo)
WHERE
  r.class1='Previdência (EAPC)'
  AND
    CAST(strftime('%Y',m.Mes) AS INTEGER) >= CAST(strftime('%Y', (SELECT base FROM mes)) AS INTEGER) -10
GROUP BY
  Ano;



