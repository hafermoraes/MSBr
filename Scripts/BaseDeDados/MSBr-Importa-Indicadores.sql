/*
 Rafael Rodrigues de Moraes - Maio.2015
 Script de criacao e importacao das tabelas utilizadas no banco de dados
 MSBr.db

 IMPORTANTE:
 Antes de executar os comandos abaixo é necessário
  1) renomear os nomes dos arquivos para ficarem somente com letra minúscula
  2) trocar ',' por '.' em todos os arquivos dos diretórios BaseSES_SUSEP e Indicadores
    sed -i 's/,/./g' *.csv  - executado no diretório 'BaseSES_SUSEP'
    sed -i 's/,/./g' *.csv  - executado no diretório 'BaseANS'
    sed -i 's/,/./g' *.csv  - executado no diretório 'Indicadores'

.separator "|"  --arquivos originais da SUSEP sao separados por ';'
.mode column
.headers ON
.timer ON --ativa a contagem de tempo das consultas

 A tabela cedentes é baseada diretamente na listagem do Mercado Supervisionado do site da SUSEP. Uma macro no Excel coloca a lista em formato tabular, separado por aba (Seguradoras, Previdencia, Capitalizacao, etc...)

 À tabela é adicionada a listagem das seguradoras de saúde, de supervisao da ANS.
 */
DROP TABLE IF EXISTS cedentes;
CREATE TABLE cedentes(
  Tipo varchar(20),
  Grupo varchar(20),
  Banco varchar(20),
  Origem varchar(20),
  Nome varchar(250),
  CNPJ varchar(20),
  CodigoFIP varchar(5) PRIMARY KEY,
  Endereco varchar(250),
  Cidade varchar(20) );

.import 'Indicadores/cedentes.csv' cedentes
DELETE FROM cedentes WHERE Tipo = 'Tipo' COLLATE NOCASE;

/*
 Tabela criada atraves de macro no Excel 'Brasil-Indicadores.xlsm'

 Como as tabelas de IPCA e INPC (IBGE), SELIC (BCB), PME (IBGE) e PIB (IGBE) são difíceis de tratar automaticamente por Webscraping, a atualizacao dos valores é feita de forma manual e uma macro concentra todos os índices na tabela Indices.csv
 */
DROP TABLE IF EXISTS Indices;
CREATE TABLE Indices (
  Mes date,
  Indice varchar(20),
  Valor numeric );

--.import 'Indicadores/indices.csv'                   indices
.import 'Indicadores/Bovespa/ibovespa'              indices
.import 'Indicadores/Câmbio/cambio'                 indices
.import 'Indicadores/Desemprego/pme'                indices
.import 'Indicadores/DívidaPública/divida_publica'  indices
.import 'Indicadores/EMBI/embi'                     indices
.import 'Indicadores/Inflação/ipca'                 indices
.import 'Indicadores/Juros/selic'                   indices
.import 'Indicadores/PIB/pib'                       indices
.import 'Indicadores/ReservasUSD/ReservasUSD'       indices
DELETE FROM Indices WHERE Mes = 'Mes' COLLATE NOCASE;


/*
  Tabela ramos, proveniente do arquivo Ramos.xlsx, que guarda as classificacoes de ramos, do macro para o mini.
 */
DROP TABLE IF EXISTS ramos;
CREATE TABLE ramos (
  fonte varchar(20),
  coramo varchar(20),
  noramo varchar(60),
  ativo varchar(14),
  class1 varchar(50),
  class1a varchar(50),
  class2 varchar(50),
  class3 varchar(50),
  class4 varchar(50) );

.import 'Indicadores/ramos.csv' ramos
DELETE FROM ramos WHERE coramo = 'coramo' COLLATE NOCASE;
