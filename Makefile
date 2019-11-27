.PHONY : all install test

BIN=src/hx
DEST=/usr/local/bin/hx
CHOWN=root:root


all: ;

README.md: doc/hx.1 doc/*.md
	git submodule update --init doc/man-to-md/
	perl doc/man-to-md.pl --word hx --formatted-code --comment --paste-section-after DESCRIPTION:'Installation.md' <$< >$@

install: $(BIN)
	cp    $(BIN)   $(DEST)
	chown $(CHOWN) $(DEST)
	
	mkdir -p    /usr/local/share/man/man1/
	cp doc/hx.1 /usr/local/share/man/man1/
	chmod 0644  /usr/local/share/man/man1/hx.1
	gzip -f     /usr/local/share/man/man1/hx.1

test:
	git submodule update --init test/framework/
	test/run-all-tests.sh

