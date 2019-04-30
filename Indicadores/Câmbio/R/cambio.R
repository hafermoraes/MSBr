# Informacoes de cambio
# Fonte: oanda.com através do pacote quantmod do R
library(quantmod)
library(scales)
library(ggplot2)

write("\tCotações das Moedas EUR, USD e GBP",         file = "../../../LOG_Indicadores", append = TRUE)
write("\t\tBaixado via R através do pacote quantmod", file = "../../../LOG_Indicadores", append = TRUE)

#conecta com o site do Oanda.com e baixa as cotacoes das moedas desejadas
  Cota <- function( tipo ) {
      # Função para baixar as cotações das diferentes moedas em EUR, USD e GBP
      # Argumento:
      #   tipo    : string que contém Moeda/BRL, onde Moeda é representada pelo código ISO (3 caracteres)
      # Retorna:
      #   Matriz com colunas Data, Cambio e Tipo

      aux <- getSymbols(  # <-- função do pacote tseries que baixa o vetor de cotações da moeda (instrument)
                          Symbols       = tipo
                        , src           = "oanda"
                        , auto.assign   = FALSE
                        , return.class  = "zoo"
                        , from          = Sys.Date() - 500
                       )
      aux <- as.data.frame( aux )  # <-- o vetor tem o formato 'zoo' mas deve ser transformado para data.frame
      aux <- cbind.data.frame(     # <-- reestrutura a tabela para conter
                     Data    = as.Date( row.names( aux ) )   # <-- Data em formato AAAA-MM-DD
                   , Tipo    = tipo                          # <-- Moeda/BRL
                   , Cambio  = aux[, 1 ]                     # <-- Valor do Câmbio
                  )
      return(aux)
  }

  Matriz <- rbind.data.frame(
                               Cota( tipo = "EUR/BRL" )
                             , Cota( tipo = "USD/BRL" )
                             , Cota( tipo = "GBP/BRL" )
                             )
  Matriz$Tipo <- sapply( Matriz$Tipo, as.character )

# Exporta o data.frame Matriz para o arquivo ../cambio
write.table(
              Matriz
            , file      = "../cambio"
            , quote     = FALSE
            , row.names = FALSE
            , col.names = FALSE
            , sep       = "|"
           )

# Exporta o gráfico comparativo do câmbio para MSBr/Relatorio/img/cambio.eps
grafico <- ggplot( Matriz, aes( x = Data, y = Cambio ) ) +
            labs( x = "", y = "" ) +
            geom_line() +
            theme_bw() +
            scale_x_date( labels = date_format("%Y.%m"), breaks = "2 month" ) +
            geom_vline(
                       xintercept = as.numeric( Matriz$Data[ strftime( Matriz$Data, "%m-%d" ) == '12-31'] ),
                       linetype   = 2,
                       colour     = "black"
                      ) +
            facet_grid( Tipo ~ . , scales = "free")

# Exporta gráfico para a pasta MSBr/Relatorio/figuras em formato PNG
#png(file = "../../../Relatorio/img/cambio.png", width = 6, height = 12, units = "in", res = 300)
pdf(file = "../../../Relatorio/img/cambio.pdf")
  grafico
dev.off()

