SRCS=$(wildcard src/*.c)
SOBJ=$(SRCS:.c=.$(LIB_EXTENSION))
INSTALL?=install

ifdef IO_FOPEN_COVERAGE
COVFLAGS=--coverage
endif

.PHONY: all install

all: $(SOBJ)

%.o: %.c
	$(CC) $(CFLAGS) $(WARNINGS) $(COVFLAGS) $(CPPFLAGS) -o $@ -c $<

%.$(LIB_EXTENSION): %.o
	$(CC) -o $@ $^ $(LDFLAGS) $(LIBS) $(PLATFORM_LDFLAGS) $(COVFLAGS)

install: $(SOBJ)
	$(INSTALL) -d $(INST_LIBDIR)
	$(INSTALL) $(SOBJ) $(INST_LIBDIR)
	rm -f ./src/*.o
	rm -f ./src/*.so

