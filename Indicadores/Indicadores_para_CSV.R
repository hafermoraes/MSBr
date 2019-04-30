library(gdata)


exporta <- function( ABA, SEPARADOR, COLUNAS ) {
 input <- read.xls(
                   "Brasil-Indicadores.xlsm"
                   , sheet            = ABA
                   , header           = TRUE
                   , stringsAsFactors = FALSE
                   , fileEncoding     = "UTF-8"
                   , encoding         = "UTF-8"
                   , colClasses       = c( rep("factor", COLUNAS) )
                   )
 fn <- paste( ABA,".csv", sep = "" )
 if ( file.exists(fn) ) file.remove(fn)
 write.table(
             input
             , file      = tolower(fn)
             , sep       = SEPARADOR
             , dec       = "."
             , row.names = FALSE
             , na        = ""
             , quote     = FALSE
            )
 message(paste(" Finalizado (",tolower(ABA),".csv) \n ",sep=""))
}


# Exporta os dados da aba 'Ramos' para o arquivo ramos.csv
 message(" Exportando os dados da aba 'Ramos' para ramos.csv... ")
 exporta(
           ABA = "Ramos"
         , SEPARADOR = "|"
         , COLUNAS = 9
         )

# Exporta os dados da aba 'Cedentes' para o arquivo cedentes.csv
 message(" Exportando os dados da aba 'Cedentes' para cedentes.csv... ")
 exporta(
           ABA = "Cedentes"
         , SEPARADOR = "|"
         , COLUNAS = 9
         )

# Exporta os dados da aba 'Indices' para o arquivo indices.csv
# message(" Exportando os dados da aba 'Indices' para indices.csv... ")
# exporta(
#         ABA = "Indices",
#         SEPARADOR = "|",
#         COLUNAS = 3
#         )

# Corrige arquivos gerados, trocando &amp; por &
 system("sed -i 's/\\&amp;/\\&/g' *.csv")
