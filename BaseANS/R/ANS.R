# script do R para preparar arquivo ANS para importação ao SQLite
library(reshape2)   # manipulacao de data.frames

# importa arquivo para a variável 'dados'
arquivo <- "../ANS_Mercado_Supervisionado"
dados   <- read.csv(
                      file       = arquivo
                    , sep        = "|"
                    , header     = TRUE
                    , dec        = "."
                    , colClasses = rep( c( "character", "numeric" ), c( 3, 2014 - 2001 + 1 ) )
                   )

#<=========== Reformatação dos dados
# primeiro, como passo intermediário, coloca-se no formato longo por meio da função melt
dados.melt   <- melt( dados, id = c( "Tipo_Operadora", "Operadora", "Info_Financeira" ) )
  # os anos XAAAA são invariavelmente formatados como Factor, por isso a correção para character na linha abaixo
  dados.melt$variable <- as.character(dados.melt$variable)
  dados.melt$variable <- paste(
                                 substring( dados.melt$variable, 2 )
                               , "-12-31"
                               , sep = ""
                              )
# em seguida, coloca-se novamente no formato longitudinal, com o Info_Financeira na coluna
dados.reform <- dcast( dados.melt, Tipo_Operadora + Operadora + variable ~ Info_Financeira, value.var = "value" )

#<=========== Preparação do arquivo dados_ans.csv, que será importado ao SQLite
dados.import <- cbind(
                        TipoOperadora   = dados.reform$Tipo_Operadora
                      , Operadora       = dados.reform$Operadora
                      , Código          = substring( dados.reform$Operadora, first = 1, last = 6 )
                      , GrupoEconomico  = ""
                      , Ano             = substring( dados.reform$variable,  first = 1, last = 4 )
                      , Receita         = dados.reform$Receita
                      , DespAdmin       = dados.reform$Desp.Administrativa
                      , DespAssist      = dados.reform$Desp.Assistencial
                      , ResseguroCedido = 0
                     )

#<=========== Exporta data.frame dados.import para arquivo ../dados_ans.csv
write.table(
              dados.import
            , file         = "../dados_ans.csv"
            , quote        = FALSE
            , sep          = "|"
            , col.names    = TRUE
            , row.names    = FALSE
           )

