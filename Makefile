src := .
top_srcdir=../../
top_builddir=../../
srctree := .
obj ?= bin

CC :=gcc
HOSTCC :=gcc

$(shell mkdir -p ${obj}/lxdialog)

include Makefile.inc
#HOSTCFLAGS+=-Dinline="" -include foo.h
-include $(obj)/.depend
$(obj)/.depend: $(wildcard *.h *.c)
	$(HOSTCC) $(HOST_EXTRACFLAGS) $(HOSTCFLAGS) -MM *.c > $@ 2>/dev/null || :

__hostprogs := $(sort $(hostprogs-y) $(hostprogs-m))
host-csingle := $(foreach m,$(__hostprogs),$(if $($(m)-objs),,$(m)))
host-cmulti := $(foreach m,$(__hostprogs),\
           $(if $($(m)-cxxobjs),,$(if $($(m)-objs),$(m))))
host-cxxmulti := $(foreach m,$(__hostprogs),\
           $(if $($(m)-cxxobjs),$(m),$(if $($(m)-objs),)))
host-cobjs := $(addprefix $(obj)/,$(sort $(foreach m,$(__hostprogs),$($(m)-objs))))
host-cxxobjs := $(addprefix $(obj)/,$(sort $(foreach m,$(__hostprogs),$($(m)-cxxobjs))))

HOST_EXTRACFLAGS += -I$(obj)

$(host-csingle): %: %.c
	$(HOSTCC) $(HOST_EXTRACFLAGS) $(HOSTCFLAGS) $(HOSTCFLAGS_$@) $< -o $(obj)/$@

$(host-cmulti): %: $(host-cobjs) $(host-cshlib)
	$(HOSTCC) $(HOST_EXTRACFLAGS) $(HOSTCFLAGS) $(HOSTCFLAGS_$@) $(addprefix $(obj)/,$($(@F)-objs)) $(HOSTLOADLIBES_$(@F)) -o $(obj)/$@

$(host-cxxmulti): %: $(host-cxxobjs) $(host-cobjs) $(host-cshlib)
	$(HOSTCXX) $(HOST_EXTRACFLAGS) $(HOSTCFLAGS) $(HOSTCXXFLAGS_$@) $(addprefix $(obj)/,$($(@F)-objs) $($(@F)-cxxobjs)) $(HOSTLOADLIBES_$(@F)) -o $(obj)/$@

$(obj)/%.o: %.c
	$(HOSTCC) $(HOST_EXTRACFLAGS) $(HOSTCFLAGS) $(HOSTCFLAGS_$(@F)) -c $< -o $@

$(obj)/%.o: $(obj)/%.c
	$(HOSTCC) $(HOST_EXTRACFLAGS) $(HOSTCFLAGS) $(HOSTCFLAGS_$(@F)) -c $< -o $@

$(obj)/%.o: %.cc
	$(HOSTCC) $(HOST_EXTRACFLAGS) $(HOSTCFLAGS) $(HOSTCXXFLAGS_$(@F)) -c $< -o $@

$(obj)/%:: $(src)/%_shipped
	$(Q)cat $< > $@

clean:
	$(Q)rm -rf $(addprefix $(obj)/,$(clean-files)) $(obj)
distclean: clean
	$(Q)rm -rf $(obj) $(addprefix $(obj)/,$(lxdialog) $(conf-objs) $(mconf-objs) $(kxgettext-objs) \
		$(hostprogs-y) $(qconf-cxxobjs) $(qconf-objs) $(gconf-objs) \
		mconf .depend)

FORCE:
.PHONY: FORCE clean distclean
