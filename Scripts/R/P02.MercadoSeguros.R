library(RSQLite)   # conexao com o banco de dados
library(reshape)   # manipulacao de data.frames
library(xtable)    # formatação de tabelas para o LaTeX

# diretório base
Projeto.path  <- '../../'

db <- dbConnect(
                  dbDriver("SQLite")
                , dbname = paste( Projeto.path, 'MSBr.db', sep = "" )
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


   Mercado.Seguros <- read.table(  # criado via 100.Mercado.Seguros.sql
                                   file   = paste( Projeto.path, 'Relatorio/tabelas/Seguros', sep = "" )
                                 , quote  = ""
                                 , header = TRUE
                                 , sep    = ";"
                                 , dec    = "."
                                 , stringsAsFactors = FALSE
                                )

   # Converte valores das colunas Volume e YTD para BRL Bilhões
    Mercado.Seguros$Volume <- Mercado.Seguros$Volume / 1e9
    Mercado.Seguros$YTD    <- Mercado.Seguros$YTD    / 1e9

Seguros <- function( Dados = Mercado.Seguros, VGBL, Valor = "Volume") {
  # Fornece dados de entrada para tabelas, gráficos e informações para análises do mercado de seguros
  # Tabelas para o início da parte II, "Mercado de Seguros, Capitalização e Previdência"
  #
  # Argumentos:
  #  Dados          - consulta 100.Mercado.Seguros.sql, base para análises na 'Parte 2 - Mercado Segurador...'
  #  VGBL           - indica como classificar o VGBL: 'Seguros' ou 'Previdência'
  #  Valor          - qual coluna utilizar: 'Volume' ou 'YTD'

  # Retorna lista:
  #  ev.Tabela              - evolução nos últimos 10 anos, pronta para publicação (xtable)
  #  ev.Dígitos             - controle do número de dígitos decimais na tabela acima (xtable)
  #  ev.Barras              - linhas horizontais nas tabelas xtable do relatório (xtable)
  #  gr.Grupos.Dez          - (até) 10 Maiores Grupos econômicos, em Dezembro do Ano Anterior
  #  gr.Grupos.Dez.Dígitos  - controle do número de casas decimais (xtable)
  #  gr.Grupos.Dez.Barras   - linhas horizontais nas tabelas xtable do relatório (xtable)
  #  gr.Grupos.YTD          - (até) 10 Maiores Grupos econômicos, no ano atual
  #  gr.Grupos.YTD.Dígitos  - controle do número de casas decimais (xtable)
  #  gr.Grupos.YTD.Barras   - linhas horizontais nas tabelas xtable do relatório (xtable)

  #VGBL  <- "Seguros"
  #Dados <- Mercado.Seguros
  #Valor <- "Volume"

  if (VGBL == 'Seguros'    ) {
                              Fórmula = "class1a  ~ Ano"
                              LN      = "class1a"
                             }
  if (VGBL == 'Previdência') {
                              Fórmula = "class1   ~ Ano"
                              LN      = "class1"
                             }

  #---- ev.Tabela -------------------------------------------------------------------
  # Transpõe tabela para o formato longitudinal
   ev.Tabela <- cast(
                       data          = Dados
                     , formula       = Fórmula
                     , value         = Valor
                     , fun.aggregate = sum
                    )
   nl        <- nrow(ev.Tabela) # <-- número de linhas  (nl) da tabela
   nc        <- ncol(ev.Tabela) # <-- número de colunas (nc) da tabela

  # Cálculo do Total de Prêmios do Mercado dividido pelo PIB
   ev.Tabela[ nl, 1    ] <- "% do PIB"   # na última linha, 'zzz PIB' se torna '% do PIB'
   ev.Tabela[ nl, 2:nc ] <- 100 * colSums( ev.Tabela[ 1:(nl-1), 2:nc ] ) / ev.Tabela[ nl, 2:nc ]

  # Inclusão da linha dos totais e percentual do PIB
   ev.Tabela <-
     rbind.data.frame(
                        ev.Tabela[ 1:(nl-1), ]                               # <-- tabela normal
                      , c(0, colSums( ev.Tabela[ 1:(nl-1), 2:nc ] ) )        # <-- soma linha 2 até penúltima
                      , ev.Tabela[ nl,  ]                                    # <-- linha do % do PIB
                     )
   ev.Tabela[ nl, 1] <- "Total"       # <-- renomeia 0 para "Total" na penúltima linha
   dimnames(ev.Tabela)[[2]][1] <- ""  # retira o título 'class1' ou 'class1a' da primeira coluna
   rm(nc, nl, Fórmula)

  #---- ev.Dígitos -------------------------------------------------------------------
  # ev.Digitos guarda a matriz que controla a quandidade de casas decimais da ev.Tabela (argumento do xtable)
    #  volume por ano : 1 casa  decimal
    #  % do PIB       : 2 casas decimais
   ev.Dígitos <- matrix(
                          2
                        , ncol = ncol(ev.Tabela) + 1
                        , nrow = nrow(ev.Tabela) - 1
                       )
   ev.Dígitos <- rbind(
                         ev.Dígitos
                       , rep( 2, ncol(ev.Tabela) + 1 )
                      )

  #---- ev.Barras -------------------------------------------------------------------
  # ev.Barras guarda o argumento para o xtable que desenha as linhas horizontais de separação de informações
   ev.Barras <- c(
                    -1                    # antes da linha do título
                  ,  0                    # entre linha do título e primeira linha
                  ,  nrow(ev.Tabela) - 2  # antes da linha do total do mercado
                  ,  nrow(ev.Tabela) - 1  # entre linha do Total do Mercado e do % do PIB
                  ,  nrow(ev.Tabela)      # após linha do % do PIB
                 )

  #---- rk.Grupos.Dez e rk.Grupos.YTD------------------------------------------------
   # agrupa a soma de Volume (ou YTD) para a combinação Ano+class1(a)+Grupo
   gr.Ranking    <- aggregate(
                                Dados[Valor] # <-- coluna a ser resumida, pode ser 'Volume' ou 'YTD'
                              , by  = Dados[ c("Ano", LN, "Grupo") ] # <- agrupamento por 'Ano', 'class1(a)' e 'Grupo'
                              , FUN = sum # <- a coluna Dados[Valor] será somada
                             )
   gr.Ranking    <- subset( gr.Ranking, Ano   >= max(Ano) - 1) # <-- somente últimos 2 anos interessam
   gr.Ranking    <- subset( gr.Ranking, Grupo != "zzz PIB"   ) # <-- retira 'zzz PIB' da tabela

   # Colunas da tabela "gr.Ranking": 1-Ano, 2-class1(a), 3-Grupo, 4-Volume e 5-rk

   # Orderna tabela: Ano ASC, class1(a) ASC, Volume DESC
   gr.Ranking    <- gr.Ranking[ order(                  # ordena colunas
                                        gr.Ranking[,1]  # Ano               --> crescente
                                      , gr.Ranking[,2]  # class1 ou class1a --> crescente
                                      ,-gr.Ranking[,4]  # Volume ou YTD     --> descrescente
                                     ),
                              ]

   # inclui coluna rk, contendo a posição do Grupo no mercado em relação ao volume de prêmios
   gr.Ranking    <- transform(
                                gr.Ranking
                              , rk = ave(
                                           gr.Ranking[,4]  # Volume ou YTD
                                         , gr.Ranking[,1]  # Ano
                                         , gr.Ranking[,2]  # class1 ou class1a
                                         , FUN = function(x) order(x,decreasing=T)
                                        )
                             )

  #---- rk.Grupos.função -------------------------------------------------------------------
  # função para os rankings rk.Grupos.Dez e rk.Grupos.YTD
   rk.Grupos.função <- function( ANO ){
     tb <- reshape(
                     subset(
                              gr.Ranking
                            , Ano == ANO & rk <= 10
                           )
                   , timevar   = LN
                   , idvar     = c( "Ano", "rk" )
                   , direction = "wide"
                   , drop      = Valor
                  )
     tb$Ano       <- NULL      # <-- remove coluna 'Ano'
     names(tb)    <- c(        # <-- remove 'Grupo.' da linha de títulos
                       "",
                       substr(
                                names( tb[, -1] )
                              , nchar("Grupo.") + 1
                              , 100
                             )
                      )
     # Inclui TOP5 e TOP10 abaixo do Ranking
     tb.Top <- reshape(
                         subset(gr.Ranking, Ano == ANO ) # <-- somente ano anterior
                       , timevar   = LN
                       , idvar     = c( "Ano", "rk" )
                       , direction = "wide"
                       , drop      = "Grupo"
                      )
     tb.Top <- tb.Top[,-c(1,2)]     # <-- remove colunas 'Ano' e 'rk'
     tb.Top <- rbind.data.frame(               # <-- calcula TOP5 e TOP10
                                  c(0,   # <-- coluna 1, será substituído depois por Top5
                                    colSums(tb.Top[1:5, ]) / colSums(tb.Top, na.rm=TRUE)
                                   )
                                , c(0,   # <-- coluna 1, será substituído depois por Top10
                                    colSums(tb.Top[1:10,]) / colSums(tb.Top, na.rm=TRUE)
                                   )
                               ) * 100
     tb.Top[,1]    <- c("Top5","Top10")  # <-- renomeia as linhas para Top5 e Top10
     tb.Top        <- cbind.data.frame(  # <-- 2 casas decimais, antes de juntar tabelas
                                         tb.Top[, 1]
                                       , apply( round(tb.Top[, 2:ncol(tb.Top)],2), 2, paste, "%" )
                                      )
     names(tb.Top) <- names(tb)   # <-- renomeia os títulos para poder juntar as 2 tabelas

     tb            <-  rbind.data.frame(
                                          tb
                                        , tb.Top
                                       )
     rm(tb.Top)

     return(tb)
   } #<-- fim da rk.Grupos.função



  #---- rk.Grupos.Dez -------------------------------------------------------------------
  # Ranking dos 10 maiores grupos, por Ramo, em Dezembro do ANO ANTERIOR
   rk.Grupos.Dez <- rk.Grupos.função( ANO = min( gr.Ranking$Ano ) )

  #---- rk.Grupos.Dez.Dígitos -------------------------------------------------------------------
  # rk.Grupos.Dez.Dígitos  guarda a matriz que controla a quandidade de casas decimais (argumento do xtable)
   #  nomes das cedentes : 0 casas  decimais
   #  TOP5 e TOP10       : 2 casas decimais
   rk.Grupos.Dez.Dígitos <- matrix(
                                     0
                                   , ncol = ncol(rk.Grupos.Dez) + 1
                                   , nrow = nrow(rk.Grupos.Dez) - 2
                                  )
   rk.Grupos.Dez.Dígitos <- rbind(
                                    rk.Grupos.Dez.Dígitos
                                  , rep( 2, ncol(rk.Grupos.Dez) + 1 )
                                  , rep( 2, ncol(rk.Grupos.Dez) + 1 )
                                 )
  #---- rk.Grupos.Dez.Barras ------------------------------------------------------------------
  #  guarda o argumento para o xtable que desenha as linhas horizontais de separação de informações
   rk.Grupos.Dez.Barras <- c(
                               -1                        # antes da linha do título
                             ,  0                        # entre linha do título e primeira linha
                             ,  nrow(rk.Grupos.Dez) - 2  # antes das linhas TOP5 e TOP10
                             ,  nrow(rk.Grupos.Dez)      # após última linha
                            )

  #---- rk.Grupos.YTD -------------------------------------------------------------------
   # Ranking dos 10 maiores grupos, por Ramo, até o mês corrente do ANO ATUAL
   rk.Grupos.YTD <- rk.Grupos.função( ANO = max( gr.Ranking$Ano ) )

  #---- rk.Grupos.YTD.Dígitos -------------------------------------------------------------------
  # gr.Grupos.YTD.Dígitos  guarda a matriz que controla a quandidade de casas decimais (argumento do xtable)
  #  nomes das cedentes : 0 casas  decimais
  #  TOP5 e TOP10       : 2 casas decimais
   rk.Grupos.YTD.Dígitos <- matrix(
                                     0
                                   , ncol = ncol(rk.Grupos.YTD) + 1
                                   , nrow = nrow(rk.Grupos.YTD) - 2
                                  )
   rk.Grupos.YTD.Dígitos <- rbind(
                                    rk.Grupos.YTD.Dígitos
                                  , rep( 2, ncol(rk.Grupos.YTD) + 1 )
                                  , rep( 2, ncol(rk.Grupos.YTD) + 1 )
                                  )

  #---- rk.Grupos.YTD.Barras ------------------------------------------------------------------
  #  guarda o argumento para o xtable que desenha as linhas horizontais de separação de informações
   rk.Grupos.YTD.Barras <- c(
                               -1                        # antes da linha do título
                             ,  0                        # entre linha do título e primeira linha
                             ,  nrow(rk.Grupos.YTD) - 2  # antes das linhas TOP5 e TOP10
                             ,  nrow(rk.Grupos.YTD)      # após última linha
                            )

   return(
          list(
                 "ev.Tabela"             = ev.Tabela
               , "ev.Dígitos"            = ev.Dígitos
               , "ev.Barras"             = ev.Barras
               , "rk.Grupos.Dez"         = rk.Grupos.Dez
               , "rk.Grupos.Dez.Dígitos" = rk.Grupos.Dez.Dígitos
               , "rk.Grupos.Dez.Barras"  = rk.Grupos.Dez.Barras
               , "rk.Grupos.YTD"         = rk.Grupos.YTD
               , "rk.Grupos.YTD.Dígitos" = rk.Grupos.YTD.Dígitos
               , "rk.Grupos.YTD.Barras"  = rk.Grupos.YTD.Barras
              )
         )

}


#----------------------------------------------------------------------------
# Função de detalhamento dos ramos: Capitalização, Previdência (EAPC), etc...
#----------------------------------------------------------------------------

Seguros.Detalha <- function( Dados = Mercado.Seguros, Segmento, Nível) {
  # Fornece dados de entrada para tabelas, gráficos e informações para análises detalhada dos ramos
  # Tabelas para seções Capitalização, Previdência (EAPC), etc...
  #
  # Argumentos:
  #  Dados          - consulta 100.Mercado.Seguros.sql, base para análises na 'Parte 2 - Mercado Segurador...'
  #  Segmento       - determina qual ramo será analisado em detalhe
  #                         'Capitalização',
  #                         'Previdência (EAPC)',
  #                         'Seguros de Danos',
  #                         'Seguros de Pessoas',
  #                         'Seguro Saúde'
  #  Nível          - indica qual coluna detalhar: 'class2', 'class3' ou 'class4'

  # Retorna lista:
  #  ev.Tabela              - evolução nos últimos 10 anos, pronta para publicação (xtable)
  #  ev.Dígitos             - controle do número de dígitos decimais na tabela acima (xtable)
  #  ev.Barras              - linhas horizontais nas tabelas xtable do relatório (xtable)
  #  ev.YTD                 - tabela que guarda a evolução até o mês atual, para todos os anos
  #  ev.Bancos              - concentração de prêmios nas seguradoras ligadas a bancos, últimos 10 anos
  #  rk.Grupos.Dez          - (até) 10 Maiores Grupos econômicos, em Dezembro do Ano Anterior
  #  rk.Grupos.Dez.Dígitos  - controle do número de casas decimais (xtable)
  #  rk.Grupos.Dez.Barras   - linhas horizontais nas tabelas xtable do relatório (xtable)
  #  rk.Grupos.YTD          - (até) 10 Maiores Grupos econômicos, no ano atual
  #  rk.Grupos.YTD.Dígitos  - controle do número de casas decimais (xtable)
  #  rk.Grupos.YTD.Barras   - linhas horizontais nas tabelas xtable do relatório (xtable)

  #Segmento <- "Seguro Saúde"
  #Dados   <-  Mercado.Seguros
  #Nível   <- "class2"

  Fórmula <- paste("class1 + ", Nível, " ~ Ano", sep = "")

  #---- ev.Tabela -------------------------------------------------------------------
  # Transpõe tabela para o formato longitudinal
   ev.Tabela <- cast(   # <-- esta tabela traz class1 e valor da variável 'Nível'
                       data          = Dados
                     , formula       = Fórmula
                     , value         = "Volume"
                     , fun.aggregate = sum
                    )

   nl        <- nrow(ev.Tabela)    # <-- número de linhas  (nl) da tabela
   nc        <- ncol(ev.Tabela)    # <-- número de colunas (nc) da tabela

   ev.Tabela <- rbind.data.frame(  # <-- inclui antes do PIB linha com a soma do mercado de seguros
                                   ev.Tabela[ 1:(nl-1), ]
                                 , rep(0, nc)
                                 , c(0, 0, colSums( ev.Tabela[ 1:(nl-1), 3:nc ] ) )
                                 , ev.Tabela[ nl, ]
                                )
   nl        <- nl + 2

   ev.Tabela[ nl-2, 1:2 ] <- "Total"         # na ante penúltima linha, 1a e 2a colunas se chamam 'Total'
   ev.Tabela[ nl-1, 1:2 ] <- "% do Mercado"  # na penúltima linha, 1a e 2a colunas se chamam '% do Mercado'
   ev.Tabela[ nl,   1:2 ] <- "% do PIB"      # na última linha, 'zzz PIB' se torna '% do PIB'

   ev.Tabela <- subset(     # <-- retira da tabela tudo o que não reflete a escolha do Ramo em class1
                         ev.Tabela
                       , class1 == Segmento       |
                         class1 == "Total"        |
                         class1 == "% do Mercado" |
                         class1 == "% do PIB"
                      )
   nl        <- nrow( ev.Tabela )

   ev.Tabela[ nl-2, 3:nc ] <- colSums(ev.Tabela[ 1:(nl-3), 3:nc ])  # <-- Total do Ramo

   if ( (nl-2) == 2 ) {  # se Ramo é "Capitalização" ou "Seguro Saúde", elimina a linha do Total
      ev.Tabela <- subset( ev.Tabela, class1 != "Total")
      nl        <- nl -1
   }

   # Cálculo do % do Mercado e do % do PIB para o Ramo escolhido
    ev.Tabela[ nl-1, 3:nc] <- 100 * ev.Tabela[ nl-2, 3:nc ]  / ev.Tabela[ nl-1, 3:nc ] # MERCADO
    ev.Tabela[ nl,   3:nc] <- 100 * ev.Tabela[ nl-2, 3:nc ]  / ev.Tabela[ nl,   3:nc ] # PIB

   # Ajustes finais na tabela
    ev.Tabela$class1            <- NULL # retira a primeira coluna da tabela
    dimnames(ev.Tabela)[[2]][1] <- ""   # retira o título  da primeira coluna
    rm(nc, nl, Fórmula)

  #---- ev.Dígitos -------------------------------------------------------------------
  # ev.Digitos guarda a matriz que controla a quandidade de casas decimais da ev.Tabela (argumento do xtable)
    #  volume por ano : 1 casa  decimal
    #  % do PIB       : 2 casas decimais
   ev.Dígitos <- matrix(
                          2
                        , ncol = ncol(ev.Tabela) + 1
                        , nrow = nrow(ev.Tabela) - 1
                       )
   ev.Dígitos <- rbind(
                         ev.Dígitos
                       , rep( 2, ncol(ev.Tabela) + 1 )
                      )

  #---- ev.Barras -------------------------------------------------------------------
  # ev.Barras guarda o argumento para o xtable que desenha as linhas horizontais de separação de informações
   ev.Barras <- c(
                    -1                    # antes da linha do título
                  ,  0                    # entre linha do título e primeira linha
                  ,  nrow(ev.Tabela) - 3  # antes da linha do Total do mercado
                  ,  nrow(ev.Tabela) - 2  # antes da linha do % do mercado
                  ,  nrow(ev.Tabela) - 1  # entre linha do % do Mercado e do % do PIB
                  ,  nrow(ev.Tabela)      # após linha do % do PIB
                 )

  #---- ev.YTD -------------------------------------------------------------------
   # ev.YTD guarda, para os últimos 10 anos, o volume de prêmio YTD no Segmento de Escolha
   ev.YTD    <- aggregate(
                            Dados["YTD"] # <-- coluna a ser resumida
                          , by  = Dados[ c("Ano", "class1") ] # <- agrupamento por 'Ano' e 'Grupo'
                          , FUN = sum                          # <- soma
                         )
   ev.YTD    <- subset( ev.YTD, class1 == Segmento)

  #---- ev.Bancos -------------------------------------------------------------------
   # ev.Bancos guarda, para os últimos 10 anos, a concentração de prêmios nos bancos para o Segmento de escolha
   ev.Bancos <- aggregate(
                            Dados[c("volumeBancos", "volumeIndep")] # <- colunas a serem resumidas
                          , by  = Dados[ c("Ano", "class1") ]       # <- agrupamento por 'Ano', 'class1'
                          , FUN = sum                               # <- soma
                         )
   ev.Bancos            <- subset( ev.Bancos, class1 == Segmento)
   ev.Bancos$percentual <- ev.Bancos[, 3 ] / ( ev.Bancos[, 3 ] + ev.Bancos[, 4 ] )
   ev.Bancos            <- ev.Bancos[, c(1, 2, 5 )]

   #---- rk.Grupos.Dez e rk.Grupos.YTD------------------------------------------------
   # preparação para os rankings
   # agrupa a soma de Volume (ou YTD) para a combinação Ano+class1+Grupo
   gr.Ranking    <- aggregate(
                                Dados[ c("Volume") ]                       # <-- coluna a ser resumida
                              , by  = Dados[ c("Ano", "class1", "Grupo") ] # <- agrupa por 'Ano', 'class1' e 'Grupo'
                              , FUN = sum                                  # <- soma
                             )
   gr.Ranking    <- subset(       # <-- somente Segmento de escolha e os últimos 2 anos interessam
                             gr.Ranking
                           , class1 == Segmento
                          )
   ANOS <- 1
   if(Segmento=="Seguro Saúde"){
     ANOS <- 0
   }
   gr.Ranking    <- subset(
                             gr.Ranking
                           , Ano   >= max(Ano) - ANOS
                          )

   # Colunas da tabela "gr.Ranking": 1-Ano, 2-class1(a), 3-Grupo, 4-Volume e 5-rk

   # Orderna tabela: Ano ASC, class1(a) ASC, Volume DESC
   gr.Ranking    <- gr.Ranking[ order(                   # ordena colunas
                                         gr.Ranking[,1]  # Ano            --> crescente
                                      ,  gr.Ranking[,2]  # class1         --> crescente
                                      , -gr.Ranking[,4]  # Volume ou YTD  --> descrescente
                                     ),
                              ]

   # inclui coluna rk, contendo a posição do Grupo no mercado em relação ao volume de prêmios
   gr.Ranking    <- transform(
                                gr.Ranking
                              , rk = ave(
                                           gr.Ranking[,4]  # Volume ou YTD
                                         , gr.Ranking[,1]  # Ano
                                         , gr.Ranking[,2]  # class1 ou class1a
                                         , FUN = function(x) order(x,decreasing=T)
                                      )
                             )

  #---- rk.função -------------------------------------------------------------------
  # função que fornecerá o Ranking por período de interesse
   rk.função <- function( Dados_ranking = gr.Ranking, ANO ){
           tb <- reshape(
                           subset(Dados_ranking, Ano == ANO & rk <= 10)
                         , timevar   = "class1"
                         , idvar     = c( "Ano", "rk" )
                         , direction = "wide"
                        )
           tb$Ano      <- NULL      # <-- remove coluna 'Ano'
           names( tb ) <- c("","Grupo", "P")

           # Inclui TOP5 e TOP10 abaixo do Ranking
           tb.Top <- reshape(
                               subset(Dados_ranking, Ano == ANO) # <-- somente ano de interesse
                             , timevar   = "class1"
                             , idvar     = c( "Ano", "rk" )
                             , direction = "wide"
                             , drop      = "Grupo"
                            )
           tb.Top <- tb.Top[,-c(1,2)]     # <-- remove colunas 'Ano' e 'rk'
           tb.Top <- rbind.data.frame(               # <-- calcula TOP5 e TOP10
                                        c(0, 0,   # <-- coluna 1, será substituído depois por Top5
                                          sum(tb.Top[ 1:min(5, nrow(tb.Top))  ])
                                         )
                                      , c(0, 0,   # <-- coluna 1, será substituído depois por Top10
                                         sum(tb.Top[ 1:min(10, nrow(tb.Top)) ])
                                         )
                                      , c(0, 0,   # <-- coluna 1, será substituído depois por Mercado
                                         sum(tb.Top)
                                         )
                                      )
           tb.Top[,2] <- c("Top5","Top10","Mercado")  # <-- renomeia as linhas para Top5, Top10 e Mercado
           tb.Top[,1] <- c("","","")  # <-- renomeia as linhas para ""

           names(tb.Top) <- names(tb)   # <-- renomeia os títulos para poder juntar as 2 tabelas
           tb    <-  rbind.data.frame(
                                        tb
                                      , tb.Top
                                     )
           tb$MS <- ( tb$P / tb[ nrow(tb), 3] )*100
           rm(tb.Top)

           return(tb)

   } # <-- fim do rk.função


  #---- rk.Grupos.Dez ---------------------------------------------------------------------------
   # Ranking dos 10 maiores grupos, por Ramo, em Dezembro do ANO ANTERIOR
   rk.Grupos.Dez <- rk.função( ANO = min( gr.Ranking$Ano ) )

  #---- rk.Grupos.Dez.Dígitos -------------------------------------------------------------------
  # rk.Grupos.Dez.Dígitos  guarda a matriz que controla a quandidade de casas decimais (argumento do xtable)
   rk.Grupos.Dez.Dígitos <- matrix(
                                     rep(
                                            c(
                                                0  # <-- coluna de texto
                                              , 0  # <-- coluna do ranking
                                              , 0  # <-- 'Grupo'
                                              , 2  # <-- 'P', prêmios por grupo
                                              , 1  # <-- 'MS', market share
                                             )
                                          , times = nrow(rk.Grupos.Dez)
                                         )
                                    , ncol= ncol(rk.Grupos.Dez) + 1
                                    , byrow = TRUE
                                  )
  #---- rk.Grupos.Dez.Barras ------------------------------------------------------------------
  #  guarda o argumento para o xtable que desenha as linhas horizontais de separação de informações
   rk.Grupos.Dez.Barras <- c(
                               -1                        # antes da linha do título
                             ,  0                        # entre linha do título e primeira linha
                             ,  nrow(rk.Grupos.Dez) - 3  # antes das linhas TOP5 e TOP10
                             ,  nrow(rk.Grupos.Dez)      # após última linha
                            )

  #---- gr.Grupos.YTD -------------------------------------------------------------------
   # Ranking dos 10 maiores grupos, por Ramo, até o mês corrente do ANO ATUAL
    rk.Grupos.YTD <- rk.função( ANO = max( gr.Ranking$Ano ) )

  #---- rk.Grupos.YTD.Dígitos -------------------------------------------------------------------
  # rk.Grupos.YTD.Dígitos  guarda a matriz que controla a quandidade de casas decimais (argumento do xtable)
   rk.Grupos.YTD.Dígitos <- matrix(
                                      rep(
                                            c(
                                                0  # <-- coluna de texto
                                              , 0  # <-- coluna do ranking
                                              , 0  # <-- 'Grupo'
                                              , 2  # <-- 'P', prêmios por grupo
                                              , 1   # <-- 'MS', market share
                                             )
                                          , times = nrow(rk.Grupos.YTD)
                                         )
                                    , ncol= ncol(rk.Grupos.YTD) + 1
                                    , byrow = TRUE
                                  )

  #---- rk.Grupos.YTD.Barras ------------------------------------------------------------------
  #  guarda o argumento para o xtable que desenha as linhas horizontais de separação de informações
   rk.Grupos.YTD.Barras <- c(
                               -1                        # antes da linha do título
                             ,  0                        # entre linha do título e primeira linha
                             ,  nrow(rk.Grupos.YTD) - 3  # antes das linhas TOP5 e TOP10
                             ,  nrow(rk.Grupos.YTD)      # após última linha
                            )

   return(
          list(
                 "ev.Tabela"             = ev.Tabela
               , "ev.Dígitos"            = ev.Dígitos
               , "ev.Barras"             = ev.Barras
               , "ev.YTD"                = ev.YTD
               , "ev.Bancos"             = ev.Bancos
               , "rk.Grupos.Dez"         = rk.Grupos.Dez
               , "rk.Grupos.Dez.Dígitos" = rk.Grupos.Dez.Dígitos
               , "rk.Grupos.Dez.Barras"  = rk.Grupos.Dez.Barras
               , "rk.Grupos.YTD"         = rk.Grupos.YTD
               , "rk.Grupos.YTD.Dígitos" = rk.Grupos.YTD.Dígitos
               , "rk.Grupos.YTD.Barras"  = rk.Grupos.YTD.Barras
              )
         )

}

#-----------------------------------------------------------------------------------
# Parte II - Mercado de Seguros, Capitalização e Previdência
#-----------------------------------------------------------------------------------
  Seguros.VGBL.como.Previdência <- Seguros(VGBL = "Previdência")
  Seguros.VGBL.como.Vida        <- Seguros(VGBL = "Seguros"    )

#-----------------------------------------------------------------------------------
# Parte II - 2) Capitalização
#-----------------------------------------------------------------------------------
  Cap              <- Seguros.Detalha( Segmento="Capitalização", Nível="class2" )

  Cap.YTD.A        <- round( Cap$ev.YTD[ nrow(Cap$ev.YTD)    , 3 ], digits = 1 )
  Cap.YTD.Am1      <- round( Cap$ev.YTD[ nrow(Cap$ev.YTD) - 1, 3 ], digits = 1 )

  Cap.Perc.Mercado <- round( Cap$ev.Tabela[ nrow(Cap$ev.Tabela) - 1, ncol(Cap$ev.Tabela) - 1 ], digits = 1 )
  Cap.Dez.Am1      <- round( Cap$ev.Tabela[ nrow(Cap$ev.Tabela) - 2, ncol(Cap$ev.Tabela) - 1 ], digits = 1 )

  Cap.Banco.A      <- round( 100 * Cap$ev.Bancos[ nrow(Cap$ev.Bancos)    , 3 ], digits = 1 )
  Cap.Banco.Am5    <- round( 100 * Cap$ev.Bancos[ nrow(Cap$ev.Bancos) - 4, 3 ], digits = 1 )
  Cap.Banco.Am10   <- round( 100 * Cap$ev.Bancos[ nrow(Cap$ev.Bancos) - 9, 3 ], digits = 1 )

#-----------------------------------------------------------------------------------
# Parte II - 3) Previdência
#-----------------------------------------------------------------------------------
  Prev              <-   Seguros.Detalha( Segmento = "Previdência (EAPC)", Nível = "class2" )

  Prev.YTD.A        <- round( Prev$ev.YTD[ nrow(Prev$ev.YTD)    , 3 ], digits = 1 )
  Prev.YTD.Am1      <- round( Prev$ev.YTD[ nrow(Prev$ev.YTD) - 1, 3 ], digits = 1 )

  Prev.Perc.Mercado <- round( Prev$ev.Tabela[ nrow(Prev$ev.Tabela) - 1, ncol(Prev$ev.Tabela) - 1 ], digits = 1 )
  Prev.Dez.Am1      <- round( Prev$ev.Tabela[ nrow(Prev$ev.Tabela) - 2, ncol(Prev$ev.Tabela) - 1 ], digits = 1 )

  Prev.Banco.A      <- round( 100 * Prev$ev.Bancos[ nrow(Prev$ev.Bancos)    , 3 ], digits = 1 )
  Prev.Banco.Am5    <- round( 100 * Prev$ev.Bancos[ nrow(Prev$ev.Bancos) - 4, 3 ], digits = 1 )
  Prev.Banco.Am10   <- round( 100 * Prev$ev.Bancos[ nrow(Prev$ev.Bancos) - 9, 3 ], digits = 1 )

#-----------------------------------------------------------------------------------
# Parte II - 4) Danos
#-----------------------------------------------------------------------------------
  Danos              <- Seguros.Detalha( Segmento = "Seguro de Danos"     , Nível = "class2" )

  Danos.YTD.A        <- round( Danos$ev.YTD[ nrow(Danos$ev.YTD)    , 3 ], digits = 1 )
  Danos.YTD.Am1      <- round( Danos$ev.YTD[ nrow(Danos$ev.YTD) - 1, 3 ], digits = 1 )

  Danos.Perc.Mercado <- round( Danos$ev.Tabela[ nrow(Danos$ev.Tabela) - 1, ncol(Danos$ev.Tabela) - 1 ], digits = 1 )
  Danos.Dez.Am1      <- round( Danos$ev.Tabela[ nrow(Danos$ev.Tabela) - 2, ncol(Danos$ev.Tabela) - 1 ], digits = 1 )

  Danos.Banco.A      <- round( 100 * Danos$ev.Bancos[ nrow(Danos$ev.Bancos)    , 3 ], digits = 1 )
  Danos.Banco.Am5    <- round( 100 * Danos$ev.Bancos[ nrow(Danos$ev.Bancos) - 4, 3 ], digits = 1 )
  Danos.Banco.Am10   <- round( 100 * Danos$ev.Bancos[ nrow(Danos$ev.Bancos) - 9, 3 ], digits = 1 )


#-----------------------------------------------------------------------------------
# Parte II - 5) Pessoas
#-----------------------------------------------------------------------------------
 Pessoas              <- Seguros.Detalha( Segmento = "Seguro de Pessoas"     , Nível = "class3" )

 Pessoas.YTD.A        <- round( Pessoas$ev.YTD[ nrow(Pessoas$ev.YTD)    , 3 ], digits = 1 )
 Pessoas.YTD.Am1      <- round( Pessoas$ev.YTD[ nrow(Pessoas$ev.YTD) - 1, 3 ], digits = 1 )

 Pessoas.Perc.Mercado <- round( Pessoas$ev.Tabela[ nrow(Pessoas$ev.Tabela) - 1, ncol(Pessoas$ev.Tabela) - 1 ], digits = 1 )
 Pessoas.Dez.Am1      <- round( Pessoas$ev.Tabela[ nrow(Pessoas$ev.Tabela) - 2, ncol(Pessoas$ev.Tabela) - 1 ], digits = 1 )

 Pessoas.Banco.A      <- round( 100 * Pessoas$ev.Bancos[ nrow(Pessoas$ev.Bancos)    , 3 ], digits = 1 )
 Pessoas.Banco.Am5    <- round( 100 * Pessoas$ev.Bancos[ nrow(Pessoas$ev.Bancos) - 4, 3 ], digits = 1 )
 Pessoas.Banco.Am10   <- round( 100 * Pessoas$ev.Bancos[ nrow(Pessoas$ev.Bancos) - 9, 3 ], digits = 1 )


#-----------------------------------------------------------------------------------
# Parte II - 6) Saúde
#-----------------------------------------------------------------------------------
 Saude              <- Seguros.Detalha( Segmento = "Seguro Saúde"     , Nível = "class2" )

 Saude.YTD.A        <- round( Saude$ev.YTD[ nrow(Saude$ev.YTD)    , 3 ], digits = 1 )
 Saude.YTD.Am1      <- round( Saude$ev.YTD[ nrow(Saude$ev.YTD) - 1, 3 ], digits = 1 )

 Saude.Perc.Mercado <- round( Saude$ev.Tabela[ nrow(Saude$ev.Tabela) - 1, ncol(Saude$ev.Tabela) - 1 ], digits = 1 )
 Saude.Dez.Am1      <- round( Saude$ev.Tabela[ nrow(Saude$ev.Tabela) - 2, ncol(Saude$ev.Tabela) - 1 ], digits = 1 )

 Saude.Banco.A      <- round( 100 * Saude$ev.Bancos[ nrow(Saude$ev.Bancos)    , 3 ], digits = 1 )
 Saude.Banco.Am5    <- round( 100 * Saude$ev.Bancos[ nrow(Saude$ev.Bancos) - 4, 3 ], digits = 1 )
 Saude.Banco.Am10   <- round( 100 * Saude$ev.Bancos[ nrow(Saude$ev.Bancos) - 9, 3 ], digits = 1 )

# Exporta somente as variáveis do relatório para o arquivo RData
save.image(file='P02.RData')
