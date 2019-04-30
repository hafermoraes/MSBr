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

--A tabela abaixo servirá de base ao relatório todo
--tabela: MSBr
DROP TABLE IF EXISTS MSBr;
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

--Inicia preenchimento da tabela principal MSBr
-- tabela ses_seguros
INSERT INTO MSBr
  SELECT
    'Seguros', --Fonte
    SUBSTR(damesano,1,4) || '-' || SUBSTR(damesano,5,2) || '-01', --Mes
    coenti, --codFIP
    coramo, --Ramo
    premio_direto, --SUSEP_PremioBrutoSeguro
    premio_ganho, --SUSEP_PremioGanho
    premio_retido - premio_de_seguros, --SUSEP_CessaoResseguro
    sinistro_retido, --SUSEP_SinistroRetido
    desp_com, -- SUSEP_DespesasComerciais
    0, --ANS_ReceitaContraprestacoes
    0, --ANS_DespAdmin
    0, --ANS_DespAssist
    0, --ANS_CessaoResseguro
    0, --SUSEP_PGBL_Contrib
    0, --SUSEP_PrevTrad_Contrib
    0, --SUSEP_Capitalizacao_Premio
    0, --SUSEP_Resseguro_Premio
    0  --SUSEP_Resseguro_Sinistro
  FROM ses_seguros
  WHERE damesano != 'damesano' COLLATE NOCASE;


-- tabela ses_pgbl_uf
INSERT INTO MSBr
  SELECT
    'PGBL', --Fonte
    SUBSTR(damesano,1,4) || '-' || SUBSTR(damesano,5,2) || '-01', --Mes
    coenti, --codFIP
    'PGBL', --Ramo
    0, --SUSEP_PremioBrutoSeguro
    0, --SUSEP_PremioGanho
    0, --SUSEP_CessaoResseguro
    0, --SUSEP_SinistroRetido
    0, -- SUSEP_DespesasComerciais
    0, --ANS_ReceitaContraprestacoes
    0, --ANS_DespAdmin
    0, --ANS_DespAssist
    0, --ANS_CessaoResseguro
    contrib, --SUSEP_PGBL_Contrib
    0, --SUSEP_PrevTrad_Contrib
    0, --SUSEP_Capitalizacao_Premio
    0, --SUSEP_Resseguro_Premio
    0  --SUSEP_Resseguro_Sinistro
  FROM ses_pgbl_uf
  WHERE damesano != 'damesano' COLLATE NOCASE;


-- tabela ses_prev_uf
INSERT INTO MSBr
  SELECT
    'Previdência Tradicional', --Fonte
    SUBSTR(damesano,1,4) || '-' || SUBSTR(damesano,5,2) || '-01', --Mes
    coenti, --codFIP
    'PrevTrad', --Ramo
    0, --SUSEP_PremioBrutoSeguro
    0, --SUSEP_PremioGanho
    0, --SUSEP_CessaoResseguro
    0, --SUSEP_SinistroRetido
    0, -- SUSEP_DespesasComerciais
    0, --ANS_ReceitaContraprestacoes
    0, --ANS_DespAdmin
    0, --ANS_DespAssist
    0, --ANS_CessaoResseguro
    0, --SUSEP_PGBL_Contrib
    contrib, --SUSEP_PrevTrad_Contrib
    0, --SUSEP_Capitalizacao_Premio
    0, --SUSEP_Resseguro_Premio
    0  --SUSEP_Resseguro_Sinistro
  FROM ses_prev_uf
  WHERE damesano != 'damesano' COLLATE NOCASE;


-- tabela ses_cap_uf
INSERT INTO MSBr
  SELECT
    'Capitalização', --Fonte
    SUBSTR(damesano,1,4) || '-' || SUBSTR(damesano,5,2) || '-01', --Mes
    coenti, --codFIP
    'Cap', --Ramo
    0, --SUSEP_PremioBrutoSeguro
    0, --SUSEP_PremioGanho
    0, --SUSEP_CessaoResseguro
    0, --SUSEP_SinistroRetido
    0, -- SUSEP_DespesasComerciais
    0, --ANS_ReceitaContraprestacoes
    0, --ANS_DespAdmin
    0, --ANS_DespAssist
    0, --ANS_CessaoResseguro
    0, --SUSEP_PGBL_Contrib
    0, --SUSEP_PrevTrad_Contrib
    premio, --SUSEP_Capitalizacao_Premio
    0, --SUSEP_Resseguro_Premio
    0  --SUSEP_Resseguro_Sinistro
  FROM ses_cap_uf
  WHERE damesano != 'damesano' COLLATE NOCASE;


-- tabela dados_ans
INSERT INTO MSBr
  SELECT
    'Saúde', --Fonte
    ano || '-12-01', --Mes
    codigo, --codFIP
    'Saúde', --Ramo
    0, --SUSEP_PremioBrutoSeguro
    0, --SUSEP_PremioGanho
    0, --SUSEP_CessaoResseguro
    0, --SUSEP_SinistroRetido
    0, -- SUSEP_DespesasComerciais
    receita, --ANS_ReceitaContraprestacoes
    despadmin, --ANS_DespAdmin
    despassist, --ANS_DespAssist
    ressegurocedido, --ANS_CessaoResseguro
    0, --SUSEP_PGBL_Contrib
    0, --SUSEP_PrevTrad_Contrib
    0, --SUSEP_Capitalizacao_Premio
    0, --SUSEP_Resseguro_Premio
    0  --SUSEP_Resseguro_Sinistro
  FROM dados_ans
  WHERE ano != 'Ano' COLLATE NOCASE
  AND   tipooperadora = 'Seguradora Especializada em Saúde';


-- tabela ses_valoresresmovgrupos
INSERT INTO MSBr
  SELECT
    'Resseguros', --Fonte
    SUBSTR(damesano,1,4) || '-' || SUBSTR(damesano,5,2) || '-01', --Mes
    coenti, --codFIP
    gracodigo, --Ramo
    0, --SUSEP_PremioBrutoSeguro
    0, --SUSEP_PremioGanho
    0, --SUSEP_CessaoResseguro
    0, --SUSEP_SinistroRetido
    0, -- SUSEP_DespesasComerciais
    0, --ANS_ReceitaContraprestacoes
    0, --ANS_DespAdmin
    0, --ANS_DespAssist
    0, --ANS_CessaoResseguro
    0, --SUSEP_PGBL_Contrib
    0, --SUSEP_PrevTrad_Contrib
    0, --SUSEP_Capitalizacao_Premio
    CASE
      WHEN cmpid = 6807 THEN valor --SUSEP_Resseguro_Premio
    END,
    CASE
      WHEN cmpid = 6811 THEN valor  --SUSEP_Resseguro_Sinistro
    END
  FROM ses_valoresresmovgrupos
  WHERE damesano != 'damesano' COLLATE NOCASE;

-- cria índices para a tabela MSBr ter desempenho mais rápido
CREATE INDEX id_Mes on MSBr (Mes);
CREATE INDEX id_codFIP on MSBr (codFIP);
CREATE INDEX id_Ramo on MSBr (Ramo);
