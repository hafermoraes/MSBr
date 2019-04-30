
# bibliotecas necessárias para produzir o relatório
library(ggplot2)   # gráficos mais elaborados
library(reshape)   # manipulacao de data.frames
library(scales)    # tratamento de datas nos gráficos ggplot2

# importa arquivo para a variável 'dados'
arquivo <- "../pib"
dados    <- read.table(
                      file       = arquivo,
                      sep        = "|",
                      header     = FALSE,
                      dec        = ".",
                      colClasses = c("Date", "character", "numeric")
                     )

names(dados) <- c("Data", "Indice", "Valor")   # renomeia os títulos
dados$Valor  <- dados$Valor / 1e12               # PIB será exibido em BRL Trilhões
dados$Ano    <- as.numeric(substr( dados$Data, 0, 4 ) )

graf <- function(DADOS) {
    DADOS <- subset( DADOS, Ano >= max(Ano) - 3 )   # compara últimos 3 anos
    grafico <- ggplot(
                      DADOS, aes(
                                 x      = strftime(Data, "%m"),
                                 y      = Valor,
                                 colour = strftime(Data,"%Y")
                                )
                      ) +
               theme_bw() +
               labs(
                    x = "Mês",
                    y = "em BRL Trilhões"
                   ) +
               geom_line(
                         aes(
                             group = strftime(Data, "%Y")
                            )
                        ) +
               theme(
                     legend.title = element_blank()
                    )
    grafico
}


# Exporta gráfico para a pasta MSBr/Relatorio/figuras em formato PNG
pdf(file = "../../../Relatorio/img/PIB.pdf", width = 13/2.54, height = 9/2.54)
 graf(dados)
dev.off()
