# Module.mk for mathcore module
# Copyright (c) 2000 Rene Brun and Fons Rademakers
#
# Author: David Gonzalez Maline, 21/4/2008

MODNAME      := genetic
MODDIR       := $(ROOT_SRCDIR)/math/$(MODNAME)
MODDIRS      := $(MODDIR)/src
MODDIRI      := $(MODDIR)/inc

GENETICDIR  := $(MODDIR)
GENETICDIRS := $(GENETICDIR)/src
GENETICDIRI := $(GENETICDIR)/inc/Math
GENETICDIRT := $(call stripsrc,$(GENETICDIR)/test)

##### libGenetic #####
GENETICL    := $(MODDIRI)/LinkDef.h
GENETICDS   := $(call stripsrc,$(MODDIRS)/G__Genetic.cxx)
GENETICDO   := $(GENETICDS:.cxx=.o)
GENETICDH   := $(GENETICDS:.cxx=.h)

GENETICDH1  :=  $(MODDIRI)/Math/GeneticMinimizer.h

GENETICH    := $(filter-out $(MODDIRI)/Math/LinkDef%,$(wildcard $(MODDIRI)/Math/*.h))
GENETICS    := $(filter-out $(MODDIRS)/G__%,$(wildcard $(MODDIRS)/*.cxx))
GENETICO    := $(call stripsrc,$(GENETICS:.cxx=.o))

GENETICDEP  := $(GENETICO:.o=.d) $(GENETICDO:.o=.d)

GENETICLIB  := $(LPATH)/libGenetic.$(SOEXT)
GENETICMAP  := $(GENETICLIB:.$(SOEXT)=.rootmap)

# used in the main Makefile
GENETICH_REL := $(patsubst $(MODDIRI)/Math/%.h,include/Math/%.h,$(GENETICH))
ALLHDRS      += $(GENETICH_REL)
ALLLIBS      += $(GENETICLIB)
ALLMAPS      += $(GENETICMAP)
ifeq ($(CXXMODULES),yes)
  CXXMODULES_HEADERS := $(patsubst include/%,header \"%\"\\n,$(GENETICH_REL))
  CXXMODULES_MODULEMAP_CONTENTS += module Math_Genetic { \\n
  CXXMODULES_MODULEMAP_CONTENTS += $(CXXMODULES_HEADERS)
  CXXMODULES_MODULEMAP_CONTENTS += "export * \\n"
  CXXMODULES_MODULEMAP_CONTENTS += link \"$(GENETICLIB)\" \\n
  CXXMODULES_MODULEMAP_CONTENTS += } \\n
endif

# include all dependency files
INCLUDEFILES += $(GENETICDEP)

##### local rules #####
.PHONY:         all-$(MODNAME) clean-$(MODNAME) distclean-$(MODNAME) \
                test-$(MODNAME)

include/Math/%.h: $(GENETICDIRI)/%.h
		@(if [ ! -d "include/Math" ]; then     \
		   mkdir -p include/Math;              \
		fi)
		cp $< $@

$(GENETICLIB): $(GENETICO) $(GENETICDO) $(ORDER_) $(MAINLIBS) $(GENETICLIBDEP)
		@$(MAKELIB) $(PLATFORM) $(LD) "$(LDFLAGS)"  \
		   "$(SOFLAGS)" libGenetic.$(SOEXT) $@     \
		   "$(GENETICO) $(GENETICDO)" \
		   "$(GENETICLIBEXTRA)"

$(call pcmrule,GENETIC)
	$(noop)

$(GENETICDS):  $(GENETICDH1) $(GENETICL) $(GENETICLINC) $(ROOTCLINGEXE) $(call pcmdep,GENETIC)
		$(MAKEDIR)
		@echo "Generating dictionary $@..."
		$(ROOTCLINGSTAGE2) -f $@ $(call dictModule,GENETIC) -c -writeEmptyRootPCM $(GENETICDH1) $(GENETICL)

$(GENETICMAP):  $(GENETICDH1) $(GENETICL) $(GENETICLINC) $(ROOTCLINGEXE) $(call pcmdep,GENETIC)
		$(MAKEDIR)
		@echo "Generating rootmap $@..."
		$(ROOTCLINGSTAGE2) -r $(GENETICDS) $(call dictModule,GENETIC) -c $(GENETICDH1) $(GENETICL)

all-$(MODNAME): $(GENETICLIB)
clean-$(MODNAME):
		@rm -f $(GENETICO) $(GENETICDO)

clean::         clean-$(MODNAME)

distclean-$(MODNAME): clean-$(MODNAME)
		@rm -f $(GENETICDEP) $(GENETICDS) $(GENETICDH) \
		   $(GENETICLIB) $(GENETICMAP)
		@rm -rf include/Math
ifneq ($(ROOT_OBJDIR),$(ROOT_SRCDIR))
		@rm -rf $(GENETICDIRT)
else
		@cd $(GENETICDIRT) && $(MAKE) distclean
endif

distclean::     distclean-$(MODNAME)

test-$(MODNAME): all-$(MODNAME)
ifneq ($(ROOT_OBJDIR),$(ROOT_SRCDIR))
		@$(INSTALL) $(GENETICDIR)/test $(GENETICDIRT)
endif
		@cd $(GENETICDIRT) && $(MAKE)

##### extra rules ######
ifneq ($(ICC_MAJOR),)
# silence warning messages about subscripts being out of range
$(GENETICDO):   CXXFLAGS += -wd175 -I$(GENETICDIRI)
else
$(GENETICDO):   CXXFLAGS += -I$(GENETICDIRI)
endif
