
library(RSQLite)   # conexao com o banco de dados
#library(reshape)   # manipulacao de data.frames
db <- dbConnect(
  dbDriver("SQLite")
  , dbname = '/media/RAFAEL16GB/Pessoais/Conquistas/MSBr/MSBr.db'
  , loadable.extensions = TRUE)



#Scripts no R para a secao de Seguros no Relatório
# db : variável que guarda a conexao com o bando de dados MSBr.sqlite

sql <- readChar('/media/RAFAEL16GB/Pessoais/Conquistas/MSBr/Scripts/BaseDeDados/esboco.sql',nchars=1e6)
#sql <- readChar('../BaseDeDados/esboco.sql',nchars=1e6)


esboco <- dbGetQuery(db,sql)

