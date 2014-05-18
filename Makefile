SHELL = /bin/sh

srcdir = .

objects = gram.o keywords.o kwlookup.o

testobjects = test.c

.SUFFIXES:
.SUFFIXES: .c .o .l .y

CC = gcc -O -std=c11
YACC = yacc
DEFS = -D_POSIX_C_SOURCE=200809L -D_POSIX_SOURCE=1
CDEBUG = -g
WFLAGS = -Wall -pedantic-errors -Wextra
CFLAGS = $(CDEBUG) -I. -I$(srcdir) $(DEFS) $(WFLAGS)
LDFLAGS = $(CDEBUG)
LDLIBS =

.PHONY: all
all: libtemplate.a test

test: LDLIBS += -ltemplate
test: $(testobjects) libtemplate.a
	$(CC) $(LDFLAGS) -L. -o $@ $(testobjects) $(LDLIBS)

gram.o: scan.c

gram.h: gram.c

gram.c: YFLAGS += --defines=gram.h

scan.c: LFLAGS += -CF -p -p
scan.c: scan.l

# Force these dependencies to be known even without dependency info built:
gram.o keywords.o: gram.h

# template: $(objects)("test"
# 	$(CC) $(LDFLAGS) -o $@ $(objects) $(LDLIBS)

libtemplate.a: CFLAGS += -fPIC
libtemplate.a: $(objects)
	ar rcs $@ $(objects) $(LDLIBS)

%.d: %.c
	@set -e; rm -f $@; \
	$(CC) -MM $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

ifneq (,$(wildcard gram.h))
-include $(objects:.o=.d)
endif

.PHONY: clean
clean:
	-rm -f test libtemplate.a gram.c gram.h scan.c *.o *.d
