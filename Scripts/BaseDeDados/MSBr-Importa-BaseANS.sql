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
DROP TABLE IF EXISTS dados_ans;
CREATE TABLE dados_ans (
  tipooperadora varchar(250),
  operadora varchar(250),
  codigo varchar(6),
  grupoEconomico varchar(20),
  ano numeric,
  receita numeric,
  despadmin numeric,
  despassist numeric,
  ressegurocedido numeric );

.import 'BaseANS/dados_ans.csv' dados_ans
DELETE FROM dados_ans WHERE operadora = 'operadora' COLLATE NOCASE;
