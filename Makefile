SHELL = /bin/sh

srcdir = .

sources = template.c

.SUFFIXES:
.SUFFIXES: .c .o .l .y

CC = gcc -O -std=c11
YACC = yacc
DEFS =
CDEBUG = -g
WFLAGS = -Wall -pedantic-errors -Wextra
CFLAGS = $(CDEBUG) -I. -I$(srcdir) $(DEFS) $(WFLAGS)
LDFLAGS = $(CDEBUG)
LDLIBS =

.PHONY: all
all: template.a

objects = $(sources:.c=.o) gram.o

gram.o: scan.c

gram.h: gram.c

gram.c: YFLAGS += --defines=gram.h

gram.o: gram.h


# template: $(objects)
# 	$(CC) $(LDFLAGS) -o $@ $(objects) $(LDLIBS)

template.a: $(objects)
	ar rcs $@ $(objects) $(LDLIBS)

%.d: %.c
	@set -e; rm -f $@; \
	$(CC) -MM $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

-include $(sources:.c=.d)

.PHONY: clean
clean:
	-rm -f txtbrowse gram.c gram.h scan.c *.o *.d
