all: mwrap.pdf

RELEASE_DATE = $(shell grep "^Version " ../NEWS | head -n1 | sed "s/^Version .*(\(.*\)):/\1/")

mwrap.tex: mwrap.tex.in
	sed "s/@RELEASE_DATE@/$(RELEASE_DATE)/" < mwrap.tex.in > mwrap.tex

mwrap.pdf: mwrap.tex
	pdflatex mwrap.tex

clean:
	rm -f mwrap.aux mwrap.log mwrap.tex mwrap.pdf
