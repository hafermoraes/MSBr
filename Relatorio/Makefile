
# ----------------------------------------------------------------------------------------
#    Variáveis que controlam os capítulos
# ----------------------------------------------------------------------------------------
# Parte I  - Indicadores Macro Econômicos
RnwP01    :=  tex/P01/P01.Rnw                                             \
              tex/P01.Cambio/P01.Cambio.Rnw                               \
              tex/P01.Desemprego/P01.Desemprego.Rnw                       \
              tex/P01.DividaPublica/P01.DividaPublica.Rnw                 \
              tex/P01.EMBI/P01.EMBI.Rnw                                   \
              tex/P01.IBovespa/P01.IBovespa.Rnw                           \
              tex/P01.Inflacao/P01.Inflacao.Rnw                           \
              tex/P01.Juros/P01.Juros.Rnw                                 \
              tex/P01.PIB/P01.PIB.Rnw                                     \
              tex/P01.ReservasUSD/P01.ReservasUSD.Rnw
texP01    :=  $(RnwP01:.Rnw=.tex)

# Parte II - Mercado Segurador
RnwP02    :=  tex/P02/P02.Rnw                                             \
              tex/P02.Capitalizacao/P02.Capitalizacao.Rnw                 \
              tex/P02.Danos/P02.Danos.Rnw                                 \
              tex/P02.Pessoas/P02.Pessoas.Rnw                             \
              tex/P02.Previdencia/P02.Previdencia.Rnw                     \
              tex/P02.Saude/P02.Saude.Rnw
texP02    :=  $(RnwP02:.Rnw=.tex)

Rnw       :=  $(RnwP01) $(RnwP02)
tex       :=  $(texP01) $(texP02)

# ----------------------------------------------------------------------------------------
#    make
# ----------------------------------------------------------------------------------------
# Alvo Principal é relatorio.pdf
all: relatorio.pdf

# relatorio.pdf depende de relatorio.tex (arquivo mae) e dos demais arquivos tex
#  Observacoes:
#    $< refere-se a relatorio.tex (primeira dependencia)
#    $@ refere-se a relatorio.pdf (alvo)
relatorio.pdf: relatorio.tex $(tex)
	pdflatex $<
	pdflatex $<
	make clean
	evince $@ &
	clear

# Regra geral de conversao do Rnw para o Tex
#  Observacoes:
#    $(*D) refere-se ao diretório onde está a dependência
#    $(*F) refere-se ao nome do arquivo da dependencia
#    $(@F) refere-se ao nome do arquivo do alvo
%.tex: %.Rnw
	cd $(*D);                                                         \
	Rscript -e "Sweave('$(*F)', encoding='UTF-8', output='$(@F)')";   \
	sed -i 's/\\usepackage{Sweave}//g' $(@F);                         \
	sed -i 's/0,00//g' $(@F)

# Dependencias por Parte do Relatório: tex depende de Rnw que depende do RData
$(texP01): $(RnwP01) ../Scripts/R/P01.RData
$(texP02): $(RnwP02) ../Scripts/R/P02.RData

# P01.RData guarda expressoes, tabelas e gráficos da Parte I
#   depende do arquivo de scripts P01.ContextoMacro.R
#   do banco de dados principal do projeto MSBr.db
#   e da consula 001.IndicesRecentes.sql
# Observacoes:
#   $(<D) refere-se ao diretório da primeira dependência
#   $(<F) refere-se ao nome do arquivo da primeira dependência
../Scripts/R/P01.RData: ../Scripts/R/P01.ContextoMacro.R ../MSBr.db  ../Scripts/BaseDeDados/001.IndicesRecentes.sql
	cd $(<D);                  \
	Rscript --vanilla $(<F)

# P02.RData guarda expressoes, tabelas e gráficos da Parte II
#   depende do arquivo de scripts P02.MercadoSeguros.R
#   do banco de dados principal do projeto MSBr.db
#   e da tabela 'Seguros'
# Observacoes:
#   $(<D) refere-se ao diretório da primeira dependência
#   $(<F) refere-se ao nome do arquivo da primeira dependência
../Scripts/R/P02.RData: ../Scripts/R/P02.MercadoSeguros.R ../MSBr.db ../Scripts/BaseDeDados/ tabelas/Seguros
	cd $(<D);                  \
	Rscript --vanilla $(<F)

.PHONY:  clean
clean:
	-rm *.aux *.log *.nav *.out *.snm *.toc
