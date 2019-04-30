# script do R para criar grafico_PME
library(ggplot2)   # gráficos mais elaborados
library(scales)    # tratamento de datas nos gráficos ggplot2
library(sqldf)     # SQL

# importa arquivo para a variável 'dados'
arquivo <- "../selic"
selic   <- read.table(
                      file       = arquivo,
                      sep        = "|",
                      header     = FALSE,
                      dec        = ".",
                      colClasses = c("Date", "character", "numeric")
                     )

# renomeia os títulos
names(selic) <- c("Data", "Indice", "Valor")

# restringe selic para valores a partir de 2000 e toma o valor ao final do mês
selic <- subset(selic, Data >= '2003-03-01')
selic$Data <- as.character(selic$Data)
selic      <- sqldf(" SELECT
                        *
                      FROM
                        selic
                      WHERE
                        Data IN (SELECT
                                   FimMes
                                 FROM
                                   (
                                    SELECT
                                      substr(Data,0,5),
                                      substr(Data,6,2),
                                      Max(Data) as FimMes
                                    FROM
                                      selic
                                    GROUP BY
                                      substr(Data,0,5),
                                      substr(Data,6,2)
                                   )
                                )
                      ")
selic$Data <- as.Date(selic$Data)

# Função para fazer o gráfico do índice de Desemprego (Taxa de Desocupação - PME)
graf <- function(DADOS, delta) {
      # DADOS: data.frame que contém os dados para o gráfico
      # delta: controla quanto a legenda do último ponto sobe ou desce

      # y.max guarda a altura da legenda do ano
        y.max <-  max( DADOS$Valor ) + 0.01
        y.max <<- y.max

      # gráfico do índice
        graf <- ggplot(DADOS, aes( x = Data, y = Valor) ) +
                    ggtitle( "Taxa Básica de Juros (SELIC)" ) +
                    geom_line() +
                    theme_bw() +
                    geom_vline(
                                 xintercept = as.numeric(DADOS$Data[ strftime(DADOS$Data,"%m") == 12] )
                               , linetype   = 2
                               , colour     = "grey"
                              ) +
                    labs( x = "", y = "") +
                    #ylim( 0, y.max ) +
                    scale_y_continuous( labels=percent, limits = c(0, y.max) ) +
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
pdf(file = "../../../Relatorio/img/Juros.pdf", width = 20/2.54, height = 15/2.54)
 graf(selic, 0.06)
dev.off()

