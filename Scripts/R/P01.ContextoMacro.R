# limpa a sessão atual
rm(list=ls())

#diretório onde está localizado o arquivo MSBr.db
Projeto.path  <- '../../'

# bibliotecas necessárias para produzir o relatório
library(ggplot2)   # gráficos mais elaborados
library(RSQLite)   # conexao com o banco de dados
library(scales)    # tratamento de datas nos gráficos ggplot2

# conexao com o banco de dados de informacões trabalhadas
db <- dbConnect(
                  dbDriver( "SQLite" )
                , dbname              = paste( Projeto.path, 'MSBr.db', sep = "" )
                , loadable.extensions = TRUE
               )

# susep_ref guarda o mês até quando as informacões estão disponíveis nos arquivos da SUSEP
susep_ref <- dbGetQuery(db, "SELECT * FROM mes")
susep_ref <- as.Date( susep_ref[ 1, ] )

mes.por.extenso <- function ( Data = susep_ref ) {
# esta função reescreve a data, originalmente em formato AAAA-MM-01, para a data por extenso
  Data <- as.character( susep_ref )
  if ( substr(Data, 6, 7) == '01' ) return (paste("Janeiro de "  , substr(Data,1,4), sep=""))
  if ( substr(Data, 6, 7) == '02' ) return (paste("Fevereiro de ", substr(Data,1,4), sep=""))
  if ( substr(Data, 6, 7) == '03' ) return (paste("Março de "    , substr(Data,1,4), sep=""))
  if ( substr(Data, 6, 7) == '04' ) return (paste("Abril de "    , substr(Data,1,4), sep=""))
  if ( substr(Data, 6, 7) == '05' ) return (paste("Maio de "     , substr(Data,1,4), sep=""))
  if ( substr(Data, 6, 7) == '06' ) return (paste("Junho de "    , substr(Data,1,4), sep=""))
  if ( substr(Data, 6, 7) == '07' ) return (paste("Julho de "    , substr(Data,1,4), sep=""))
  if ( substr(Data, 6, 7) == '08' ) return (paste("Agosto de "   , substr(Data,1,4), sep=""))
  if ( substr(Data, 6, 7) == '09' ) return (paste("Setembro de " , substr(Data,1,4), sep=""))
  if ( substr(Data, 6, 7) == '10' ) return (paste("Outubro de "  , substr(Data,1,4), sep=""))
  if ( substr(Data, 6, 7) == '11' ) return (paste("Novembro de " , substr(Data,1,4), sep=""))
  if ( substr(Data, 6, 7) == '12' ) return (paste("Dezembro de " , substr(Data,1,4), sep=""))
}

# data.frame contendo todos os indicadores
indices <- dbGetQuery(db,"
             SELECT
                 Mes
               , Indice
               , CASE
                   WHEN Indice = 'Reservas_Intl_USD'
                     THEN CAST (Valor as DOUBLE) / 1e9
                     ELSE CAST (Valor as DOUBLE)
                 END  as Valor
             FROM
               Indices
             WHERE
               Mes >= (SELECT DATE(base,'-12 years') FROM mes)
            ")
indices$Mes <- as.Date(indices$Mes, format="%Y-%m-%d")

indices$Indice[indices$Indice=="PME"]                     <- "Taxa de Desocupação (PME)"
indices$Indice[indices$Indice=="EUR/BRL"]                 <- "Câmbio EUR/BRL"
indices$Indice[indices$Indice=="USD/BRL"]                 <- "Câmbio USD/BRL"
indices$Indice[indices$Indice=="GBP/BRL"]                 <- "Câmbio GBP/BRL"
indices$Indice[indices$Indice=="Divida_Publica_Perc_PIB"] <- "Dívida Pública (% do PIB)"
indices$Indice[indices$Indice=="Reservas_Intl_USD"]       <- "Reservas Internac. em USD bi"
indices$Indice[indices$Indice=="EMBI"]                    <- "EMBI+ Brasil (Risco País)"
indices$Indice[indices$Indice=="SELIC"]                   <- "SELIC (ao ano)"
indices$Indice[indices$Indice=="IPCA"]                    <- "IPCA (acum. últimos 12 meses)"
indices$Indice[indices$Indice=="IBovespa"]                <- "IBovespa (pontos)"


#-------------------------------------------------------------------
# Tabela 1: Indicadores macro-econômicos atuais
#-------------------------------------------------------------------
sql            <- readChar(   # consulta que traz somente índices mais recentes de cada indicador
                      paste( Projeto.path, 'Scripts/BaseDeDados/001.IndicesRecentes.sql', sep = "" )
                    , nchars = 1e6
                  )
indices.atuais              <- dbGetQuery( db, sql )
indices.atuais$Rel.Indice   <- ''  # coluna número 4
indices.atuais$Rel.Conteudo <- ''  # coluna número 5

# Taxa de Desemprego
ind <- 'PME'
aux <- subset(indices.atuais, Indice == ind)
indices.atuais[ indices.atuais$Indice == ind, 4 ]  <- 'Taxa de Desemprego' # (PME/IBGE)'
indices.atuais[ indices.atuais$Indice == ind, 5 ]  <- paste(
                                                             aux[,3] * 100
                                                            ,'% em '
                                                            ,format(
                                                                     as.Date(aux[,1])
                                                                    ,format = "%Y/%m"
                                                                   )
                                                            ,sep = ""
                                                           )
# Dívida Pública
ind <- 'Divida_Publica_Perc_PIB'
aux <- subset(indices.atuais, Indice == ind)
indices.atuais[ indices.atuais$Indice == ind, 4 ]  <- 'Dívida Pública'
indices.atuais[ indices.atuais$Indice == ind, 5 ]  <- paste(
                                                             aux[,3] * 100
                                                            ,'% do PIB em '
                                                            ,format(
                                                                     as.Date(aux[,1])
                                                                    ,format = "%Y/%m"
                                                                   )
                                                            ,sep = ""
                                                           )

# Inflação
ind <- 'IPCA'
aux <- subset(indices.atuais, Indice == ind)
indices.atuais[ indices.atuais$Indice == ind, 4 ]  <- 'Inflação oficial acum. em 12 meses' # (IPCA/IBGE)'
indices.atuais[ indices.atuais$Indice == ind, 5 ]  <- paste(
                                                             aux[,3] * 100
                                                            ,'% em '
                                                            ,format(
                                                                     as.Date(aux[,1])
                                                                    ,format = "%Y/%m"
                                                                   )
                                                            ,sep = ""
                                                           )

# Taxa de Juros (SELIC)
ind <- 'SELIC'
aux <- subset(indices.atuais, Indice == ind)
indices.atuais[ indices.atuais$Indice == ind, 4 ]  <- 'Taxa básica de Juros (SELIC/Bacen)'
indices.atuais[ indices.atuais$Indice == ind, 5 ]  <- paste(
                                                             aux[,3] * 100
                                                            ,'% (a.a.) em '
                                                            ,format(
                                                                     as.Date(aux[,1])
                                                                    ,format = "%Y/%m"
                                                                   )
                                                            ,sep = ""
                                                           )


# PIB
ind <- 'PIB'
aux <- subset(indices.atuais, Indice == ind)
indices.atuais[ indices.atuais$Indice == ind, 4 ]  <- 'Produto Interno Bruto'# (IBGE)'
indices.atuais[ indices.atuais$Indice == ind, 5 ]  <- paste(
                                                             round(aux[,3] / 1e12, 3) # 1.000.000.000.000
                                                            ,' BRL Trilhões em '
                                                            ,format(
                                                                     as.Date(aux[,1])
                                                                    ,format = "%Y/%m"
                                                                   )
                                                            ,sep = ""
                                                           )

# Reservas Internacionais em USD
ind <- 'Reservas_Intl_USD'
aux <- subset(indices.atuais, Indice == ind)
indices.atuais[ indices.atuais$Indice == ind, 4 ]  <- 'Reservas Internacionais (Bacen)'
indices.atuais[ indices.atuais$Indice == ind, 5 ]  <- paste(
                                                             round( aux[,3] / 1e9, 1) # 1.000.000.000
                                                            ,' USD Bilhões em '
                                                            ,format(
                                                                     as.Date(aux[,1])
                                                                    ,format = "%d/%m/%Y"
                                                                   )
                                                            ,sep = ""
                                                           )

# Bolsa de Valores
ind <- 'IBovespa'
aux <- subset(indices.atuais, Indice == ind)
indices.atuais[ indices.atuais$Indice == ind, 4 ]  <- 'IBovespa'# (Bolsa de Valores de SP)'
indices.atuais[ indices.atuais$Indice == ind, 5 ]  <- paste(
                                                             aux[,3]
                                                            ,' pontos '
                                                            ,format(
                                                                     as.Date(aux[,1])
                                                                    ,format = "%d/%m/%y"
                                                                   )
                                                            ,sep = ""
                                                           )

# Câmbio EUR/BRL
ind <- 'EUR/BRL'
aux <- subset(indices.atuais, Indice == ind)
indices.atuais[ indices.atuais$Indice == ind, 4 ]  <- 'EUR 1.00'
indices.atuais[ indices.atuais$Indice == ind, 5 ]  <- paste(
                                                             aux[,3]
                                                            ,' BRL em '
                                                            ,format(
                                                                     as.Date(aux[,1])
                                                                    ,format = "%d/%m/%Y"
                                                                   )
                                                            ,sep = ""
                                                           )

# Câmbio USD/BRL
ind <- 'USD/BRL'
aux <- subset(indices.atuais, Indice == ind)
indices.atuais[ indices.atuais$Indice == ind, 4 ]  <- 'USD 1.00'
indices.atuais[ indices.atuais$Indice == ind, 5 ]  <- paste(
                                                             aux[,3]
                                                            ,' BRL em '
                                                            ,format(
                                                                     as.Date(aux[,1])
                                                                    ,format = "%d/%m/%Y"
                                                                   )
                                                            ,sep = ""
                                                           )

# Câmbio GBP/BRL
ind <- 'GBP/BRL'
aux <- subset(indices.atuais, Indice == ind)
indices.atuais[ indices.atuais$Indice == ind, 4 ]  <- 'GBP 1.00'
indices.atuais[ indices.atuais$Indice == ind, 5 ]  <- paste(
                                                             aux[,3]
                                                            ,' BRL em '
                                                            ,format(
                                                                     as.Date(aux[,1])
                                                                    ,format = "%d/%m/%Y"
                                                                   )
                                                            ,sep = ""
                                                           )

# Risco Brasil EMBI+
ind <- 'EMBI'
aux <- subset(indices.atuais, Indice == ind)
indices.atuais[ indices.atuais$Indice == ind, 4 ]  <- 'Risco País (EMBI+ Brasil)'
indices.atuais[ indices.atuais$Indice == ind, 5 ]  <- paste(
                                                             aux[,3]
                                                            ,' bp (100 bp = 1%) em '
                                                            ,format(
                                                                     as.Date(aux[,1])
                                                                    ,format = "%d/%m/%Y"
                                                                   )
                                                            ,sep = ""
                                                           )



#-------------------------------------------------------------------
# Gráfico 1: Painel Gráfico dos Indicadores macro-econômicos atuais
#-------------------------------------------------------------------
grafico.indices <- ggplot( subset( indices, Indice != "PIB" ), aes( Mes, Valor ) ) +
                   labs(x = "", y = "" ) +
                   geom_line() +
                   theme_bw() +
                   facet_wrap(~Indice, scales = "free", ncol = 3 )


# Exporta o painel gráfico dos indicadores para pdf
pdf(file = "../../Relatorio/img/PainelMacro.pdf", width = 22/2.54, height = 22/2.54)
  grafico.indices
dev.off()

# Exporta somente as variáveis do relatório para o arquivo RData
save.image(file='P01.RData')
