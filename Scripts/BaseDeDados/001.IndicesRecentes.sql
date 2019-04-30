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

------------------------------------------------
-- Tabela 1: Indicadores macro-econômicos atuais
------------------------------------------------
SELECT
    i.Mes
  , i.Indice
  , i.Valor
FROM
  Indices i
JOIN
  (SELECT
       a.Indice
     , max(a.Mes) as UltimoMes
   FROM
     Indices a
   GROUP BY a.Indice
  ) aux
ON i.Indice = aux.Indice AND i.Mes = aux.UltimoMes
WHERE
  i.Indice in ('PME','Divida_Publica_Perc_PIB','IPCA','SELIC')

UNION ALL
SELECT
    i.Mes
  , i.Indice
  , sum(i.Valor)
FROM
  Indices i
WHERE
  strftime('%Y', i.Mes) = strftime('%Y',(SELECT max(Mes) FROM Indices WHERE Indice = 'PIB'))
AND
  i.Indice = 'PIB'


UNION ALL
SELECT
    i.Mes
  , i.Indice
  , i.Valor
FROM
  Indices i
JOIN
  (SELECT
       a.Indice
     , max(a.Mes) as UltimoMes
   FROM
     Indices a
   GROUP BY a.Indice) aux
ON i.Indice = aux.Indice AND i.Mes = aux.UltimoMes
WHERE
  i.Indice in ('Reservas_Intl_USD')


UNION ALL
SELECT
    i.Mes
  , i.Indice
  , i.Valor
FROM
  Indices i
JOIN
  (SELECT
       a.Indice
     , max(a.Mes) as UltimoMes
   FROM
     Indices a
   GROUP BY a.Indice) aux
ON i.Indice = aux.Indice AND i.Mes = aux.UltimoMes
WHERE
  i.Indice in ('IBovespa')


UNION ALL
SELECT
    i.Mes
  , i.Indice
  , i.Valor
FROM
  Indices i
JOIN
  (SELECT
       a.Indice
     , max(a.Mes) as UltimoMes
   FROM
     Indices a
   GROUP BY a.Indice) aux
ON i.Indice = aux.Indice AND i.Mes = aux.UltimoMes
WHERE
  i.Indice in ('EUR/BRL','GBP/BRL','USD/BRL')


UNION ALL
SELECT
    i.Mes
  , i.Indice
  , i.Valor
FROM
  Indices i
JOIN
  (SELECT
       a.Indice
     , max(a.Mes) as UltimoMes
   FROM
     Indices a
   GROUP BY a.Indice) aux
ON i.Indice = aux.Indice AND i.Mes = aux.UltimoMes
WHERE
  i.Indice in ('EMBI');


