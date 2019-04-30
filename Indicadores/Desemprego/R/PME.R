# script do R para criar grafico_PME
library(ggplot2)   # gráficos mais elaborados
library(scales)    # tratamento de datas nos gráficos ggplot2

# importa arquivo para a variável 'dados'
arquivo <- "../pme"
pme     <- read.table(
                      file       = arquivo,
                      sep        = "|",
                      header     = FALSE,
                      dec        = ".",
                      colClasses = c("Date", "character", "numeric")
                     )

# renomeia os títulos
names(pme) <- c("Data", "Indice", "Valor")

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
                    ggtitle ( "Taxa de Desocupação (PME)" ) +
                    theme_bw() +
                    geom_vline(
                                 xintercept = as.numeric(DADOS$Data[ strftime(DADOS$Data,"%m") == 12] )
                               , linetype   = 2
                               , colour     = "grey"
                              ) +
                    labs( x = "", y = "(Contingente Desocupado)/(População Economicamente Ativa)") +
                    #ylim( 0, y.max ) +
                    scale_y_continuous( labels=percent, limits =c(0, y.max) ) +
                    scale_x_date(labels = date_format("%Y-%m"),breaks = "4 month") +
                    theme(axis.text.x = element_text(angle = 90))

        ano.label <- subset(DADOS, strftime(Data,"%m")=='06') # rótulos dos anos

        valor.atual <<- subset( DADOS, Data == max (Data) )

        graf <- graf +
                geom_text(
                          data = ano.label,
                          aes(
                              x     = Data,
                              y     = y.max,
                              label = strftime(Data,"%Y")
                             )
                         ) +
                geom_point(
                           data = valor.atual,
                           size = 3
                          ) +
                annotate(
                         "text",
                         label = paste(valor.atual$Valor*100,"% em \n",format(valor.atual$Data,"%Y/%m"), sep=""),
                         x     = valor.atual$Data,
                         y     = valor.atual$Valor + delta,
                         size  = 4
                        )
        graf

}

# Exporta gráfico para a pasta MSBr/Relatorio/figuras em formato PNG
pdf(file = "../../../Relatorio/img/Desemprego.pdf", width = 19/2.54, height = 15/2.54)
 graf(pme, 0.01)
dev.off()

