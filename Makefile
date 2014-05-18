SHELL = /bin/sh

srcdir = .

objects = gram.o keywords.o kwlookup.o

testobjects = test.c

.SUFFIXES:
.SUFFIXES: .c .o .l .y

CC = gcc -O -std=c11
PYTHON = python
YACC = yacc
DEFS = -D_POSIX_C_SOURCE=200809L -D_POSIX_SOURCE=1
CDEBUG = -g
WFLAGS = -Wall -pedantic-errors -Wextra -Werror
CFLAGS = $(CDEBUG) -I. -I$(srcdir) $(DEFS) $(WFLAGS)
LDFLAGS = $(CDEBUG)
LDLIBS =

.PHONY: all
all: libtemplate.a test cdjango

libtemplate.a: CFLAGS += -fPIC
libtemplate.a: $(objects)
	ar rcs $@ $(objects) $(LDLIBS)

gram.o: scan.c

gram.h: gram.c

gram.c: YFLAGS += --defines=gram.h

scan.c: LFLAGS += -CF -p -p
scan.c: scan.l

# Force these dependencies to be known even without dependency info built:
gram.o keywords.o: gram.h

%.d: %.c
	@set -e; rm -f $@; \
	$(CC) -MM $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

ifneq (,$(wildcard gram.h))
-include $(objects:.o=.d)
endif

test: LDLIBS += -ltemplate
test: $(testobjects) libtemplate.a
	$(CC) $(LDFLAGS) -L. -o $@ $(testobjects) $(LDLIBS)

.PHONY: cdjango
cdjango: libtemplate.a
	$(PYTHON) setup.py build

.PHONY: install
install:
	$(PYTHON) setup.py install --user

.PHONY: clean
clean:
	-rm -rf build; \
	rm -f gram.c gram.h libtemplate.a scan.c test *.o *.d
