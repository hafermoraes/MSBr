# Informacoes do Índice Bovespa
# Fonte: pacote tseries do R
library(tseries)
library(scales)
library(ggplot2)


write("\tÍndice da Bolsa de Valores",                file = "../../../LOG_Indicadores", append = TRUE)
write("\t\tBaixado via R através do pacote tseries", file = "../../../LOG_Indicadores", append = TRUE)

# Funcao para baixar índices das principais bolsas do Mundo
Indice <- function( CODIGO, NOME ) {
    aux <- get.hist.quote(   # <-- cotação histórica do fechamento do índice
                          instrument = CODIGO,
                          start      = '1998-01-01',
                          end        = Sys.Date(),
                          quiet      = TRUE
                         )
    aux <- as.data.frame( aux )
    return (
            cbind.data.frame(
                             Mes    = as.Date( row.names( aux ) ),
                             Indice = rep( NOME, nrow( aux ) ),
                             Valor  = aux[, 4 ]
                            )
           )
}

# Baixa histórico de cotações do IBovespa através do pacote tseries do R
BVSP     <- Indice( CODIGO = "^BVSP"   , NOME = "IBovespa" )

# Baixa histórico de cotações das maiores bolsas do Mundo
AXJO     <- Indice( CODIGO = "^AXJO"   , NOME = "Sydney"   )                              # Bolsa da Austrália
DAX      <- Indice( CODIGO = "^GDAXI"  , NOME = "Frankfurt (DAX)"    )                    # Bolsa de Frankfurt
GSPTSE   <- Indice( CODIGO = "^GSPTSE" , NOME = "Toronto" )                               # Bolsa de Toronto
HSI      <- Indice( CODIGO = "^HSI"    , NOME = "Hong-Kong"    )                          # Bolsa de Hong-Kong
Euronext <- Indice( CODIGO = "^N100"   , NOME = "Paris, Amsterdam, Bruxelas e Lisboa"   ) # Bolsa Euronext (Europa)
FTSE     <- Indice( CODIGO = "^FTSE"   , NOME = "Londres"   )                             # Bolsa de Londres
Nikkei   <- Indice( CODIGO = "^N225"   , NOME = "Tokio (Nikkei 225)"   )                  # Bolsa de Tokio
NASDAQ   <- Indice( CODIGO = "^IXIC"   , NOME = "Nasdaq"   )                              # Nasdaq (Tecnologia)
NYSE     <- Indice( CODIGO = "^DJI"    , NOME = "Nova Iorque (Dow Jones)"    )            # Bolsa de NY

# data.frame contendo todas os índices
bolsas.df <- rbind.data.frame(
                               BVSP
                              ,AXJO
                              ,DAX
                              ,GSPTSE
                              ,HSI
                              ,Euronext
                              ,FTSE
                              ,Nikkei
                              ,NASDAQ
                              ,NYSE
                             )

# Exporta data.frame BVSP para arquivo ../ibovespa
write.table(
              BVSP
            , file = "../ibovespa"
            , quote = FALSE
            , sep = "|"
            , col.names = FALSE
            , row.names = FALSE
           )

# Gráficos do Índice Bovespa
graf <- function(DADOS, y.max, TITULO) {
      # DADOS: data.frame contendo o índice bovespa
      # b = máximo do eixo y no gráfico e local onde legenda do ano será posicionada
      y.max <<- y.max # transforma variável em global

      graf <- ggplot(DADOS, aes(x=Mes,y=Valor)) +
               geom_line() +
               ggtitle( TITULO )+
               theme_bw() +
               labs(x = "", y = "") +
               ylim(0, y.max) +
               #scale_x_date( labels = date_format("%m/\n%Y"), breaks = "12 month") +
               scale_y_continuous(
                                 name   = "Pontos",
                                 labels = comma
                                )
      graf
}

# Exporta gráfico para a pasta MSBr/Relatorio/figuras em formato PNG
pdf(file = "../../../Relatorio/img/Bovespa.pdf", width = 19/2.54, height = 11/2.54) #, units = "in", res = 300)
  graf(BVSP, y.max = 74000, TITULO = "IBovespa")
dev.off()


# Matriz de Gráficos 5x2 das principais bolsas do Mundo

pdf(file = "../../../Relatorio/img/BolsasMundo.pdf", width = 20/2.54, height = 20/2.54) #, units = "in", res = 300)
  ggplot( bolsas.df, aes( Mes, Valor ) ) +
       labs(x = "", y = "" ) +
       geom_line() +
       theme_bw() +
       facet_wrap(~Indice, scales = "free", ncol = 2 )
dev.off()
