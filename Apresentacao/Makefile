

all: *.pdf

%.pdf : %.tex
	pdflatex $^
	pdflatex $^
	make clean
	clear
	ls

.PHONY: clean
clean:
	rm *.aux *.log *.nav *.out *.snm *.toc
