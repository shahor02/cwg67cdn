NAME := cdnCWG67
PDFLATEX := pdflatex
BIBTEX := bibtex
SHELL := /bin/bash
CREATEMD5 := ( md5sum *.aux *.bbl || echo -n '' ) 2>/dev/null >aux-md5sums
CHECKMD5  := md5sum --quiet -c aux-md5sums
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
 CREATEMD5 := ( md5 -r *.aux *.bbl || echo -n '' ) 2>/dev/null >aux-md5sums
 CHECKMD5  := ( md5 -r `awk '{ print $2 }' aux-md5sums` ) 2>/dev/null | diff aux-md5sums -
endif

all: $(NAME).pdf

devel:
	@while true; do $(MAKE) -q $(NAME).pdf || $(MAKE) $(NAME).pdf && sleep 1s; done

EXTRA_DEPS := $(wildcard *.bib *.sty */*.eps */*.pdf */*.C) O2-logo.pdf Four_Colors_Logo.eps XS_Black_Logo.eps Makefile

clean:
	rm -f $(NAME).pdf */*~ *~ *.aux *.bbl *.blg *.brf *.lof *.log *.lol *.lot *.out *.toc */*.aux aux-md5sums *-eps-converted-to.pdf

TEX_INPUTS   := $(shell egrep '^[^%]*\\in(put|clude){.*?}' main.tex|sed 's@^.*{\(.*\)}.*$$@\1.tex@')
#TEX_INPUTS   := $(shell egrep '^[^%]*\\in(put|clude){.*?}' $(TEX_INPUTS)|sed 's@^.*{\(.*\)}.*$$@\1.tex@') $(TEX_INPUTS)
TEX_INPUTS   += main.tex

$(NAME).pdf: $(TEX_INPUTS) $(EXTRA_DEPS)
	@$(CREATEMD5)
	$(PDFLATEX) main
	#$(BIBTEX) main
	@while ! $(CHECKMD5); do \
		$(CREATEMD5); \
		$(PDFLATEX) main; \
	done
	@test -s main.pdf && mv main.pdf $@

cdn.tar.gz: $(TEX_INPUTS) $(EXTRA_DEPS)
	tar -c $(TEX_INPUTS) $(EXTRA_DEPS) | gzip > $@

.PHONY: clean
