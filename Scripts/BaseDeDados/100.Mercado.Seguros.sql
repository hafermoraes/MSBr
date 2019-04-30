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

------------------------------------------------------------------------------
-- Tabela que serve de entrada para todos os gráficos e rankings do Cap. 2
------------------------------------------------------------------------------
SELECT
    strftime('%Y',m.Mes) as Ano
  , c.Grupo
  , r.class1
  , r.class1a
  , r.class2
  , r.class3
  , r.class4
  , sum(
        CASE
          WHEN CAST(strftime('%m',m.Mes) AS INTEGER) <= CAST(strftime('%m',(SELECT base FROM mes)) AS INTEGER)
            THEN 1
            ELSE 0
        END *
        (
          m.SUSEP_PremioBrutoSeguro      +
          m.ANS_ReceitaContraprestacoes  +
          m.SUSEP_PGBL_Contrib           +
          m.SUSEP_PrevTrad_Contrib       +
          m.SUSEP_Capitalizacao_Premio
        )
       ) as YTD
  , sum(
        m.SUSEP_PremioBrutoSeguro      +
        m.ANS_ReceitaContraprestacoes  +
        m.SUSEP_PGBL_Contrib           +
        m.SUSEP_PrevTrad_Contrib       +
        m.SUSEP_Capitalizacao_Premio
       ) as Volume
  , sum(
        CASE
          WHEN c.banco = ''
            THEN 0
            ELSE 1
        END *
        (
          m.SUSEP_PremioBrutoSeguro      +
          m.ANS_ReceitaContraprestacoes  +
          m.SUSEP_PGBL_Contrib           +
          m.SUSEP_PrevTrad_Contrib       +
          m.SUSEP_Capitalizacao_Premio
        )
       ) as volumeBancos
  , sum(
        CASE
          WHEN c.banco = ''
            THEN 1
            ELSE 0
        END *
        (
          m.SUSEP_PremioBrutoSeguro      +
          m.ANS_ReceitaContraprestacoes  +
          m.SUSEP_PGBL_Contrib           +
          m.SUSEP_PrevTrad_Contrib       +
          m.SUSEP_Capitalizacao_Premio
        )
       ) as volumeIndep
FROM
  MSBr m
LEFT OUTER JOIN
  ramos r
  ON (m.Ramo = r.coramo)
LEFT OUTER JOIN
  cedentes c
  ON (m.codFip = c.CodigoFIP)
WHERE
  CAST(strftime('%Y',m.Mes) AS INTEGER) >= CAST(strftime('%Y',(SELECT DATE(base, '-9 years') FROM mes)) AS INTEGER)
GROUP BY
  strftime('%Y',m.Mes)
  , c.Grupo
  , r.class1
  , r.class1a
  , r.class2
  , r.class3
  , r.class4

UNION ALL

SELECT
  CAST(strftime('%Y', i.Mes) AS INTEGER)
  , 'zzz PIB'  --Grupo
  , 'zzz PIB'  --class1
  , 'zzz PIB'  --class1a
  , 'zzz PIB'  --class2
  , 'zzz PIB'  --class3
  , 'zzz PIB'  --class4
  , Valor      --YTD
  , Valor      --Volume
  , 0          --volumeBancos
  , 0          --volumeIndep
FROM
  Indices i
WHERE
  i.Indice = 'PIB'
AND
  CAST(strftime('%Y',i.Mes) AS INTEGER) >= CAST(strftime('%Y',(SELECT DATE(base, '-9 years') FROM mes)) AS INTEGER)
  ;
