# script do R para criar grafico_EMBI
library(ggplot2)   # gráficos mais elaborados
library(scales)    # tratamento de datas nos gráficos ggplot2
library(sqldf)     # SQL

# importa arquivo para a variável 'dados'
arquivo <- "../ReservasUSD"
dados   <- read.table(
                      file       = arquivo,
                      sep        = "|",
                      header     = FALSE,
                      dec        = ".",
                      colClasses = c("Date", "character", "numeric")
                     )

# renomeia os títulos
names(dados) <- c("Data", "Indice", "Valor")

# restringe valores para o final do mês e e bilhões de USD
dados$Valor <- dados$Valor/1e9
dados$Data <- as.character(dados$Data)
dados      <- sqldf(" SELECT
                        *
                      FROM
                        dados
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
                                      dados
                                    GROUP BY
                                      substr(Data,0,5),
                                      substr(Data,6,2)
                                   )
                                )
                      ")
dados$Data <- as.Date(dados$Data)


# Função para fazer o gráfico do índice de Desemprego (Taxa de Desocupação - PME)
graf <- function(DADOS, delta) {
      # DADOS: data.frame que contém os dados para o gráfico
      # delta: controla quanto a legenda do último ponto sobe ou desce

      # y.max guarda a altura da legenda do ano
        y.max <-  max( DADOS$Valor ) + 0.01 + abs(delta)
        y.max <<- y.max

      # gráfico do índice
        graf <- ggplot(DADOS, aes( x = Data, y = Valor) ) +
                    ggtitle( "Reservas Internacionais em USD" ) +
                    geom_line() +
                    theme_bw() +
                    geom_vline(
                                 xintercept = as.numeric(DADOS$Data[ strftime(DADOS$Data,"%m") == 12] )
                               , linetype   = 2
                               , colour     = "grey"
                              ) +
                    labs( x = "", y = "USD Bilhões") +
                    #ylim( 0, y.max ) +
                    scale_y_continuous( limits = c(0, y.max) ) +
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
                              size  = 2,
                              label = strftime(Data,"%Y")
                             )
                         ) +
                geom_point(
                           data = valor.atual,
                           size = 3
                          ) +
                annotate(
                         "text",
                         label = paste(
                                       "USD ",
                                       round(valor.atual$Valor,1),
                                       "\n  Bilhões em \n",
                                       format(valor.atual$Data,"%Y/%m"),
                                       sep=""
                                      ),
                         x     = valor.atual$Data,
                         y     = valor.atual$Valor + delta,
                         size  = 2
                        )
        graf

}

# Exporta gráfico para a pasta MSBr/Relatorio/figuras em formato PNG
pdf(file = "../../../Relatorio/img/ReservasUSD.pdf", width = 19/2.54, height = 11/2.54)
 graf(dados, -50)
dev.off()

