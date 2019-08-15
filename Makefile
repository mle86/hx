.PHONY : all install

BIN=src/hx
DEST=/usr/local/bin/hx
CHOWN=root:root


all: ;

install: $(BIN)
	cp $(BIN) $(DEST)
	chown $(CHOWN) $(DEST)
	
	mkdir -p /usr/local/share/man/man1/
	cp doc/hx.1 /usr/local/share/man/man1/
	chmod 0644 /usr/local/share/man/man1/hx.1
	gzip -f /usr/local/share/man/man1/hx.1

