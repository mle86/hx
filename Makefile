.PHONY : all install

BIN=src/hx
DEST=/usr/local/bin/hx
CHOWN=root:root


all: ;

README.md: doc/hx.1
	git submodule update --init doc/man-to-md/
	perl doc/man-to-md.pl --word hx --formatted-code --comment <$< >$@

install: $(BIN)
	cp $(BIN) $(DEST)
	chown $(CHOWN) $(DEST)
	
	mkdir -p /usr/local/share/man/man1/
	cp doc/hx.1 /usr/local/share/man/man1/
	chmod 0644 /usr/local/share/man/man1/hx.1
	gzip -f /usr/local/share/man/man1/hx.1

