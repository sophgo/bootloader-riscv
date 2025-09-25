PROGS = \
	extract-cert

include $(top_rulesdir)/Makefile.inc

CPPFLAGS += -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -I$(top_srcdir)/scripts
extract-cert: LDLIBS += -lcrypto
