# bibliotecas necessárias para produzir o relatório
library(ggplot2)   # gráficos mais elaborados
library(reshape)   # manipulacao de data.frames
library(scales)    # tratamento de datas nos gráficos ggplot2

# importa arquivo para a variável 'dados'
arquivo        <- "../ipca_mensal"
ipca           <- read.table(
                              file       = arquivo
                             ,sep        = "|"
                             ,header     = FALSE
                             ,dec        = "."
                             ,encoding   = "latin1"#"UTF-8"
                             ,colClasses = c("Date", "character", "numeric")
                            )

# renomeia os títulos
names(ipca)    <- c("Mes", "Grupo", "Valor")

# restringe a série para os últimos 24 meses
ipca.graf      <- subset( ipca, Mes >= '2005-01-01' )

ipca_por_grupo <- ggplot( subset( ipca.graf, Grupo != "IPCA" ), aes( Mes, Valor ) ) +
                   labs(x = "", y = "" ) +
                   geom_line() +
                   theme_bw() +
                   facet_wrap(~Grupo, scales = "free", ncol = 2 )

# Exporta o painel gráfico dos indicadores para pdf
pdf(file = "../../../Relatorio/img/IPCAporGrupo.pdf", width = 22/2.54, height = 22/2.54)
  ipca_por_grupo
dev.off()

# ------------------------------------------------------------
# Controle da Inflação versão "Atirei"
# restringindo os dados de mesmo jeito que o site informa
atirei.dados        <- subset(
                              ipca,
                              Mes   >= '2005-01-01' &
                              Mes   <= '2014-12-01' &
                              Grupo == 'IPCA'
                             )
atirei.dados$Grupo  <- NULL
atirei.dados$mes    <- as.numeric( substr(atirei.dados$Mes, 6,7) )
names(atirei.dados) <- c("data", "ipca", "mes")

# modelo quadrático: ipca ~ mes + mes^2
modelo  <- lm( ipca ~ mes + I(mes^2), data = atirei.dados)

# predições
preds   <- predict.lm( modelo, interval = "prediction" )

# gráfico
# Exporta o painel gráfico dos indicadores para pdf
pdf(file = "../../../Relatorio/img/IPCAatirei.pdf", width = 19/2.54, height = 15/2.54)

  plot( ipca ~ mes, data = atirei.dados, ylim=c(-0.002, 0.015), type = "n")
    lines( preds[,1],                 col = "darkgreen" )
    lines( preds[,2], lty = "dashed", col = "red"       )
    lines( preds[,3], lty = "dashed", col = "red"       )

    # linhas cinzas claras indicarão os últimos 4 anos no gráfico
    ano.atual <- as.numeric( max( substr( ipca$Mes, 1, 4 ) ) )
    for (ano in (ano.atual - 4):ano.atual ){
      serie <- subset(ipca, substr(Mes, 1, 4) == ano & Grupo == 'IPCA')$Valor

      # no ano corrente, usa pontos ligados por linhas na cor azul escura
      if ( ano == ano.atual   )   lines( serie, col = "darkblue", type = "o", pch = 20 )

      # nos demais, linhas cinza de cor cada vez mais escuras
      if ( ano == ano.atual-1 )   lines( serie, col = "gray75")
      if ( ano == ano.atual-2 )   lines( serie, col = "gray87")
      if ( ano == ano.atual-3 )   lines( serie, col = "gray92")
      if ( ano == ano.atual-4 )   lines( serie, col = "gray97")
    }
dev.off()


# ------------------------------------------------------------
# pacote qcc
library(qcc)
mes.atual <- max( ipca$Mes )
serie.mes.atual <- subset(
                          ipca,
                          substr(Mes, 6, 10) == substr( mes.atual, 6, 10 ) &
                          Grupo              == 'IPCA'                     &
                          Mes                >= '2005-01-01'
                         )

Grupos <- unique( subset(ipca, Grupo != 'IPCA')$Grupo )

# Exporta o painel gráfico dos indicadores para pdf
pdf(file = "../../../Relatorio/img/IPCAqcc.pdf", width = 19/2.54, height = 15/2.54)
    for (grupo in Grupos){
      grupo.serie  <- subset(ipca, Grupo == grupo & Mes >= '2005-01-01')$Valor
      grupo.qcc    <- qcc( grupo.serie, type = "xbar.one", restore.par = FALSE, plot = FALSE )
      grupo.plot   <- plot(
                            grupo.qcc
                           ,add.stats   = FALSE
                           ,chart.all   = FALSE
                           ,title       = grupo
                           ,ylab        = "IPCA ao mês"
                           ,xlab        = "Meses"
                          )
    }
dev.off()




