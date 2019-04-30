# script do R para criar grafico_EMBI
library(ggplot2)   # gráficos mais elaborados
library(scales)    # tratamento de datas nos gráficos ggplot2

# importa arquivo para a variável 'dados'
arquivo <- "../embi"
dados   <- read.table(
                      file       = arquivo,
                      sep        = "|",
                      header     = FALSE,
                      dec        = ".",
                      colClasses = c("Date", "character", "numeric")
                     )

# renomeia os títulos
names(dados) <- c("Data", "Indice", "Valor")

# Função para fazer o gráfico do índice de Desemprego (Taxa de Desocupação - PME)
graf <- function(DADOS, delta) {
      # DADOS: data.frame que contém os dados para o gráfico
      # delta: controla quanto a legenda do último ponto sobe ou desce

      # y.max guarda a altura da legenda do ano
        y.max <-  max( DADOS$Valor ) + 0.01
        y.max <<- y.max

      # gráfico do índice
        graf <- ggplot(DADOS, aes( x = Data, y = Valor) ) +
                    geom_line() +
                    theme_bw() +
                    #geom_vline(
                    #             xintercept = as.numeric(DADOS$Data[ strftime(DADOS$Data,"%m") == 12] )
                    #           , linetype   = 2
                    #           , colour     = "grey"
                    #          ) +
                    labs( x = "", y = "pontos-base ( 1% = 100 bp )") +
                    ggtitle( "EMBI+ Brasil (Risco Brasil)" ) +
                    #ylim( 0, y.max ) +
                    scale_y_continuous( ) +
                    scale_x_date(labels = date_format("%Y-%m"),breaks = "12 month") +
                    theme(axis.text.x = element_text(angle = 90))

        #ano.label <- subset(DADOS, strftime(Data,"%m")=='06') # rótulos dos anos

        valor.atual <<- subset( DADOS, Data == max (Data) )

        graf <- graf +
                #geom_text(
                #          data = ano.label,
                #          aes(
                #              x     = Data,
                #              y     = y.max,
                #              label = strftime(Data,"%Y")
                #             )
                #         ) +
                geom_point(
                           data = valor.atual,
                           size = 3
                          ) +
                annotate(
                         "text",
                         label = paste(valor.atual$Valor," bp em \n",format( valor.atual$Data, "%Y/%m" ), sep = "" ),
                         x     = valor.atual$Data,
                         y     = valor.atual$Valor + delta,
                         size  = 4
                        )
        graf

}

# Exporta gráfico para a pasta MSBr/Relatorio/figuras em formato PNG
pdf(file = "../../../Relatorio/img/EMBI.pdf", width = 19/2.54, height = 11/2.54) 
 graf(dados, 200)
dev.off()

