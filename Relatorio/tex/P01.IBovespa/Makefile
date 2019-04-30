

all: *.pdf

%.pdf : %.tex
	pdflatex $^
	pdflatex $^
	make clean
	clear
	ls

%.tex : %.Rnw
	Rscript -e "Sweave('$^', encoding='UTF-8')"
	sed -i 's/\\usepackage{Sweave}//' $@

.PHONY: clean
clean:
	rm *.aux *.log
