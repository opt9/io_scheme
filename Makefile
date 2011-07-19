# vim: tabstop=8 noexpandtab

VERSION := `date +%Y%m%d`

DESTDIR =
PREFIX  = /usr/local
MANDIR  = $(PREFIX)/share/man

CC      = gcc

CFLAGS  =   -g -ggdb -pg
#CFLAGS += -ansi
CFLAGS += -Wno-long-long
CFLAGS += -I/opt/local/include
CFLAGS += -DUSE_INTERFACE=1 \
	  -DSTANDALONE=0 \
	  -DUSE_MATH=1 \
	  -DOSX=1 \
	  -DUSE_DL=1 \
	  -DUSE_ERROR_HOOK=1 \
	  -DUSE_ASCII=1

LFLAGS  =  -L/opt/local/lib -levent -levent_extra

INC     =
SRC     =  main.c scheme.c scheme_sqlite.c
#SRC    += dynload.c

OBJ     = $(SRC:.c=.o)
BIN     = ioscheme
LIB     =

default: all

all:	$(BIN)

$(BIN): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ $(LFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f $(OBJ) $(BIN) *.o

test: $(BIN)
	nc -u 127.0.0.1 8000
	#@[ $$? = 0 ] && echo "PASSED OK."

install: $(BIN)
	install -v $(BIN) $(DEST)/bin

install-man:
	install -d $(DESTDIR)$(MANDIR)/man1
	install -m 0644 ioscheme.1 $(DESTDIR)$(MANDIR)/man1

uninstall:
	rm -f $(DEST)/bin/$(BIN)

archive:
	git archive --prefix=$(BIN)-$(VERSION)/ HEAD | gzip > $(BIN)-$(VERSION).tar.gz

.PHONY: default clean test all install install-man uninstall archive

