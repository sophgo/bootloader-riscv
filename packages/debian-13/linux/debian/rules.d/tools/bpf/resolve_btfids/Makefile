PROGS = resolve_btfids

include $(top_rulesdir)/Makefile.inc

resolve_btfids:
# resolve_btfids always uses HOSTCC, HOSTLD, and HOSTAR; we need to
# override these on the command line to make cross-builds work.  But
# it also builds fixdep which still needs to be native in a
# cross-build.  Set REALHOSTCC and REALHOSTLD variables which will be
# used for fixdep.
	$(MAKE) -C $(top_srcdir)/tools/bpf/resolve_btfids O=$(CURDIR) \
		HOSTCC=$(CC) HOSTCFLAGS='$(CFLAGS) $(CPPFLAGS)' \
		HOSTLD=$(CROSS_COMPILE)ld KBUILD_HOSTLDFLAGS='$(LDFLAGS)' \
		HOSTAR=$(CROSS_COMPILE)ar \
		REALHOSTCC=gcc REALHOSTLD=ld \
		V=1
