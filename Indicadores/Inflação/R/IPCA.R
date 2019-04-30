
# bibliotecas necessárias para produzir o relatório
library(ggplot2)   # gráficos mais elaborados
library(reshape)   # manipulacao de data.frames
library(scales)    # tratamento de datas nos gráficos ggplot2

# importa arquivo para a variável 'dados'
arquivo <- "../ipca"
ipca    <- read.table(
                      file       = arquivo,
                      sep        = "|",
                      header     = FALSE,
                      dec        = ".",
                      colClasses = c("Date", "character", "numeric")
                     )

# renomeia os títulos
names(ipca) <- c("Data", "Indice", "Valor")
# meta do IPCA
copom <- rbind.data.frame(
                          c(2003, 4   - 2.5 , 4   , 4   + 2.5 ),
                          c(2004, 5.5 - 2.5 , 5.5 , 5.5 + 2.5 ),
                          c(2005, 4.5 - 2   , 4.5 , 4.5 + 2   ),
                          c(2006, 4.5 - 2   , 4.5 , 4.5 + 2   ),
                          c(2007, 4.5 - 2   , 4.5 , 4.5 + 2   ),
                          c(2008, 4.5 - 2   , 4.5 , 4.5 + 2   ),
                          c(2009, 4.5 - 2   , 4.5 , 4.5 + 2   ),
                          c(2010, 4.5 - 2   , 4.5 , 4.5 + 2   ),
                          c(2011, 4.5 - 2   , 4.5 , 4.5 + 2   ),
                          c(2012, 4.5 - 2   , 4.5 , 4.5 + 2   ),
                          c(2013, 4.5 - 2   , 4.5 , 4.5 + 2   ),
                          c(2014, 4.5 - 2   , 4.5 , 4.5 + 2   ),
                          c(2015, 4.5 - 2   , 4.5 , 4.5 + 2   )
                         )
names(copom)  <- c('Ano','LI','Meta','LS')
copom[, 2:4 ] <- copom[, 2:4 ] / 100


#Gráficos do Índice de Inflacao (IPCA)
graf <- function(DADOS, delta) {
      # DADOS: data.frame que contém os dados para o gráfico
      # delta: controla quanto a legenda do último ponto sobe ou desce

        DADOS$Ano <- as.numeric( substr( DADOS$Data, 1, 4 ) )
        DADOS     <- merge( DADOS, copom, by = "Ano" )
        DADOS$Ano <- NULL

      # y.max guarda a altura da legenda do ano
        y.max <-  max( DADOS$Valor ) + 0.01
        y.max <<- y.max

        graf <- ggplot( DADOS, aes( x = Data, y = Valor ) ) +
                ggtitle( "Inflação Oficial ( IPCA / IBGE )" ) +
                geom_ribbon( aes( ymin = LI, ymax = LS ), fill = "snow2", linetype = 1 ) +
                geom_line( aes( y = Meta), colour = "brown1" ) +
                geom_line() +
                theme_bw() +
                geom_vline(
                           xintercept = as.numeric( DADOS$Data[ strftime( DADOS$Data, "%m" ) == 12 ] ),
                           linetype   = 2,
                           colour     = "grey"
                          )+
                labs( x = "", y = "") +
                scale_y_continuous( labels = percent, limits = c(0, y.max) ) +
                scale_x_date( labels = date_format("%b"), breaks = "4 month") +
                theme( axis.text.x = element_text(angle = 90))

        ano.label <- subset(DADOS, strftime(Data,"%m")=='06') # rótulos dos anos

        valor.atual <<- subset( DADOS, Data == max (Data) ) # índice do mês atual

        graf +
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
                      ) +
              annotate(
                       "text",
                       label = paste("Meta: ",valor.atual$Meta*100,"%", sep=""),
                       x     = valor.atual$Data,
                       y     = valor.atual$Meta - delta/10,
                       colour= "red",
                       size  = 3
                      ) +
              annotate(
                       "text",
                       label = paste("L.I.: ",valor.atual$LI*100,"%", sep=""),
                       x     = valor.atual$Data,
                       y     = valor.atual$LI - delta/10,
                       size  = 3
                      )+
              annotate(
                       "text",
                       label = paste("L.S.: ",valor.atual$LS*100,"%", sep=""),
                       x     = valor.atual$Data,
                       y     = valor.atual$LS -delta/10,
                       size  = 3
                      )
}

# Exporta gráfico para a pasta MSBr/Relatorio/figuras em formato PNG
pdf(file = "../../../Relatorio/img/Inflacao.pdf", width = 19/2.54, height = 15/2.54)
 graf(ipca, 0.02)
dev.off()
