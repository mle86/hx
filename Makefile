.PHONY : all install test

BIN=src/hx
DEST=/usr/local/bin/hx
MOD=src/*.pm
MODDEST=/usr/local/lib/hx-modules/
CHOWN=root:root


all: ;

README.md: doc/hx.1 doc/*.md
	git submodule update --init doc/man-to-md/
	perl doc/man-to-md.pl \
		--formatted-code --comment \
		--word hx --word HX_COLORS --word HX_SETTINGS \
		--paste-section-after DESCRIPTION:'Installation.md' --paste-after HEADLINE:'Badges.md' \
		<$< >$@

dep: cpanfile
	cpanm --installdeps .

install: $(BIN)
	cp    $(BIN)   $(DEST)
	chown $(CHOWN) $(DEST)
	
	mkdir -p $(MODDEST)
	cp $(MOD) $(MODDEST)
	chown $(CHOWN) $(MODDEST) $(MODDEST)/*.pm
	
	mkdir -p    /usr/local/share/man/man1/
	cp doc/hx.1 /usr/local/share/man/man1/
	chmod 0644  /usr/local/share/man/man1/hx.1
	gzip -f     /usr/local/share/man/man1/hx.1

test:
	git submodule update --init test/framework/
	test/run-all-tests.sh

