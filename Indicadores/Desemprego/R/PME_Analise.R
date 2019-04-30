# bibliotecas necessárias para produzir o relatório
library(ggplot2)   # gráficos mais elaborados
library(reshape)   # manipulacao de data.frames
library(scales)    # tratamento de datas nos gráficos ggplot2

# importa arquivo para a variável 'dados'
arquivo        <- "../pme"
pme            <- read.table(
                              file       = arquivo
                             ,sep        = "|"
                             ,header     = FALSE
                             ,dec        = "."
                             ,encoding   = "latin1"#"UTF-8"
                             ,colClasses = c("Date", "character", "numeric")
                            )

# renomeia os títulos
names(pme)    <- c("Mes", "Grupo", "Valor")

# restringe a série para os últimos 24 meses
pme.graf      <- subset( pme, Mes >= '2005-01-01' )

# ------------------------------------------------------------
# Controle do Desemprego versão "Atirei"
# restringindo os dados de mesmo jeito que o site informa
atirei.dados        <- subset(
                              pme,
                              Mes   >= '2010-01-01' &
                              Mes   <= '2014-12-01'
                             )
atirei.dados$Grupo  <- NULL
atirei.dados$mes    <- as.numeric( substr(atirei.dados$Mes, 6,7) )
names(atirei.dados) <- c("data", "pme", "mes")

# modelo quadrático: ipca ~ mes + mes^2
modelo  <- lm( pme ~ mes + I(mes^2), data = atirei.dados)

# predições
preds   <- predict.lm( modelo, interval = "prediction" )

# gráfico
# Exporta o painel gráfico dos indicadores para pdf
pdf(file = "../../../Relatorio/img/PMEatirei.pdf", width = 19/2.54, height = 15/2.54)

  plot(
         pme ~ mes
       , data  = atirei.dados
       , type  = "n"
       , ylab  = "Taxa de Desocupação (TD/PEA)"
       , xlab  = ""
       , main  = "Acompanhamento da Taxa de Desemprego"
      )
    lines( preds[,1],                 col = "darkgreen" )
    lines( preds[,2], lty = "dashed", col = "red"       )
    lines( preds[,3], lty = "dashed", col = "red"       )

    # linhas cinzas claras indicarão os últimos 4 anos no gráfico
    ano.atual <- as.numeric( max( substr( pme$Mes, 1, 4 ) ) )
    qtde <- 5
    for (ano in (ano.atual - qtde):ano.atual ){
      serie <- subset(pme, substr(Mes, 1, 4) == ano)$Valor

      # no ano corrente, usa pontos ligados por linhas na cor azul escura
      if ( ano == ano.atual   )   lines( serie, col = "darkblue", type = "o", pch = 20 )
      if ( ano != ano.atual   )   lines(
                                          serie
                                        , col = paste(
                                                      "gray"
                                                    , (ano.atual - ano)*5 + 75
                                                    , sep=""
                                                   )
                                        , type = "l"
                                       )
    }
dev.off()


# ------------------------------------------------------------
# pacote qcc
library(qcc)
ts.pme <- ts( pme$Valor, frequency = 12, start=c(2002,3) )

# gráfico
plot(ts.pme)

# decomposição da série temporal da pme
ts.pme.componentes <- decompose(ts.pme)

# série ajustada
ts.pme.ajustada    <- ts.pme - ts.pme.componentes$seasonal


# Exporta o painel gráfico dos indicadores para pdf
pdf(file = "../../../Relatorio/img/PMEqcc.pdf", width = 19/2.54, height = 15/2.54)
      grupo.serie  <- na.omit(ts.pme.componentes$random)
      grupo.qcc    <- qcc( grupo.serie, type = "xbar.one", restore.par = FALSE, plot = FALSE )
      grupo.plot   <- plot(
                            grupo.qcc
                           ,add.stats   = FALSE
                           ,chart.all   = FALSE
                           ,title       = "Taxa de Desemprego (PME)\n(TD/PEA)"
                           ,ylab        = "Série dessasonalizada e sem tendência"
                           ,xlab        = "Meses"
                          )
dev.off()

