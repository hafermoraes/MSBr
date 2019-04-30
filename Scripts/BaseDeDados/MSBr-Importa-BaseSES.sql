/*
 Rafael Rodrigues de Moraes - Maio.2015
 Script de criacao e importacao das tabelas utilizadas no banco de dados
 MSBr.db

 IMPORTANTE:
 Antes de executar os comandos abaixo é necessário
  1) renomear os nomes dos arquivos para ficarem somente com letra minúscula
  2) trocar ',' por '.' em todos os arquivos dos diretórios BaseSES_SUSEP e Indicadores
    sed -i 's/,/./g' *.csv  - executado no diretório 'BaseSES_SUSEP'

.mode column
.headers ON
.timer ON --ativa a contagem de tempo das consultas
 */

--A tabela abaixo contém o mês de referência das informacoes
--tabela: ses_diversos.csv
DROP TABLE IF EXISTS ses_diversos;
CREATE TABLE ses_diversos (
  descricao varchar(30),
  valor varchar(6) );

.import 'BaseSES_SUSEP/fonte/CSVs/ses_diversos.csv' ses_diversos

DROP TABLE IF EXISTS mes;
CREATE TABLE mes ( base date);

INSERT INTO mes
  SELECT
    SUBSTR(valor,1,4) || '-' || SUBSTR(valor,5,2) || '-01'
  FROM
    ses_diversos
  WHERE
    valor != 'valor' COLLATE NOCASE;


--A tabela abaixo contém a lista atualizada pela SUSEP das cias do mercado
--tabela: ses_cias.csv
DROP TABLE IF EXISTS ses_cias;
CREATE TABLE ses_cias (
  coenti varchar(20) PRIMARY KEY,
  noenti varchar(250),
  cogrupo varchar(20),
  nogrupo varchar(250) );

.import 'BaseSES_SUSEP/fonte/CSVs/Ses_cias.csv' ses_cias


--A tabela abaixo contém as informações de seguros
--tabela: ses_seguros.csv
DROP TABLE IF EXISTS ses_seguros;
CREATE TABLE ses_seguros (
  damesano varchar(6),
  coenti varchar(5),
  cogrupo varchar(5),
  coramo varchar(4),
  premio_direto numeric,
  premio_de_seguros numeric,
  premio_retido numeric,
  premio_ganho numeric,
  sinistro_direto numeric,
  sinistro_retido numeric,
  desp_com numeric ,
  premio_emitido2 numeric,
  premio_emitido_cap numeric,
  despesa_resseguros numeric,
  sinistro_ocorrido numeric,
  receita_resseguro numeric,
  sinistros_ocorridos_cap numeric,
  recuperacao_sinistros_ocorridos_cap numeric,
  rvne numeric,
  conveniodpvat numeric,
  consorciosefundos numeric );
.import 'BaseSES_SUSEP/fonte/CSVs/ses_seguros.csv' ses_seguros


--A tabela abaixo contém a lista dos ramos de atuação supervisionados pela SUSEP
--tabela: ses_ramos.csv
DROP TABLE IF EXISTS ses_ramos;
CREATE TABLE ses_ramos (
  coramo varchar(4) PRIMARY KEY,
  noramo varchar(250) );

.import 'BaseSES_SUSEP/fonte/CSVs/ses_ramos.csv' ses_ramos


--A tabela abaixo contém a lista dos grupos de ramos
--tabela: ses_gruposramos.csv
DROP TABLE IF EXISTS ses_gruposramos;
CREATE TABLE ses_gruposramos (
  graid numeric,
  granome varchar(50),
  gracodigo varchar(2) );

.import 'BaseSES_SUSEP/fonte/CSVs/ses_gruposramos.csv' ses_gruposramos


--A tabela abaixo contém as informações de resseguro
--tabela: ses_valoresresmovgrupos.csv
DROP TABLE IF EXISTS ses_valoresresmovgrupos;
CREATE TABLE ses_valoresresmovgrupos (
  coenti varchar(5),
  damesano varchar(6),
  cmpid numeric,
  gracodigo varchar(2),
  valor numeric,
  id varchar(6) );

.import 'BaseSES_SUSEP/fonte/CSVs/ses_valoresresmovgrupos.csv' ses_valoresresmovgrupos


--A tabela abaixo contém as informações da previdência tradicional
--tabela: ses_prev_uf.csv
DROP TABLE IF EXISTS ses_prev_uf;
CREATE TABLE ses_prev_uf (
  coenti varchar(5),
  damesano varchar(6),
  uf varchar(2),
  contrib numeric,
  benefpago numeric,
  resgpago numeric,
  numpartic numeric,
  numbenef numeric,
  numresg numeric );

.import 'BaseSES_SUSEP/fonte/CSVs/ses_prev_uf.csv' ses_prev_uf


--A tabela abaixo contém as informações de pgbl
--tabela: ses_pgbl_uf.csv
DROP TABLE IF EXISTS ses_pgbl_uf;
CREATE TABLE ses_pgbl_uf (
  coenti varchar(5),
  damesano varchar(6),
  uf varchar(2),
  contrib numeric,
  benefpago numeric,
  respago numeric,
  numpartic numeric,
  numbenef numeric,
  numresg numeric );

.import 'BaseSES_SUSEP/fonte/CSVs/ses_pgbl_uf.csv' ses_pgbl_uf


--A tabela abaixo contém as informações de capitalização
--tabela: ses_cap_uf.csv
DROP TABLE IF EXISTS ses_cap_uf;
CREATE TABLE ses_cap_uf (
  coenti varchar(5),
  damesano varchar(6),
  uf varchar(2),
  premio numeric,
  resgpago numeric,
  sortpago numeric,
  numpartic numeric,
  resgatantes numeric,
  sorteios numeric );

.import 'BaseSES_SUSEP/fonte/CSVs/ses_cap_uf.csv' ses_cap_uf

-- Preenchimento das tabelas de UF
--prêmios/contribuições por ano, ramo e UF
DROP TABLE IF EXISTS distr_UF;
CREATE TABLE distr_UF (
  coenti varchar(6),
  ano numeric,
  ramo varchar(6),
  uf varchar(2),
  valor numeric );

--seguros: tabela ses_uf2
DROP TABLE IF EXISTS ses_uf2;
CREATE TABLE ses_uf2 (
  coenti varchar(6),
  damesano varchar(6),
  ramos varchar(6),
  uf varchar(2),
  premio_dir numeric,
  premio_ret numeric,
  sin_dir numeric,
  prem_ret_liq numeric,
  gracodigo varchar(2),
  salvados numeric,
  recuperacao numeric );

.import 'BaseSES_SUSEP/fonte/CSVs/SES_UF2.csv' ses_uf2

INSERT INTO distr_UF
  SELECT
    coenti,
    SUBSTR(damesano,1,4), --ano
    ramos,
    uf,
    sum(premio_dir)
  FROM ses_uf2
    WHERE coenti != 'coenti' COLLATE NOCASE AND SUBSTR(damesano,1,4) >= '2010'
    GROUP BY coenti, SUBSTR(damesano,1,4), ramos, uf ;

DROP TABLE ses_uf2;

--previdência tradicional: tabela ses_prev_uf
INSERT INTO distr_UF
  SELECT
    coenti,
    SUBSTR(damesano,1,4), --ano
    'PrevTrad', --ramo
    uf,
    sum(contrib)
  FROM ses_prev_uf
    WHERE coenti != 'coenti' COLLATE NOCASE AND SUBSTR(damesano,1,4) >= '2010'
    GROUP BY coenti, SUBSTR(damesano,1,4), 'PrevTrad', uf ;


--pgbl: tabela ses_pgbl_uf
INSERT INTO distr_UF
  SELECT
    coenti,
    SUBSTR(damesano,1,4), --ano
    'PGBL', --ramo
    uf,
    sum(contrib)
  FROM ses_pgbl_uf
    WHERE coenti != 'coenti' COLLATE NOCASE AND SUBSTR(damesano,1,4) >= '2010'
    GROUP BY coenti, SUBSTR(damesano,1,4), 'PGBL', uf ;


--capitalização: tabela ses_cap_uf
INSERT INTO distr_UF
  SELECT
    coenti,
    SUBSTR(damesano,1,4), --ano
    'CAP', --ramo
    uf,
    sum(premio)
  FROM ses_cap_uf
    WHERE coenti != 'coenti' COLLATE NOCASE AND SUBSTR(damesano,1,4) >= '2010'
    GROUP BY coenti, SUBSTR(damesano,1,4), 'CAP', uf ;


--DROP TABLE IF EXISTS ses_diversos;
--DROP TABLE IF EXISTS ses_seguros;
--DROP TABLE IF EXISTS ses_valoresresmovgrupos;
--DROP TABLE IF EXISTS ses_prev_uf;
--DROP TABLE IF EXISTS ses_pgbl_uf;
--DROP TABLE IF EXISTS ses_cap_uf;
--DROP TABLE IF EXISTS dados_ans;
