SUBDIRS = \
	libsrc \
	src

TESTDIRS = \
	src

.PHONY: all
all : $(SUBDIRS)

.PHONY: clean
clean : $(SUBDIRS)

.PHONY: test
test : $(TESTDIRS)

.PHONY: $(SUBDIRS)
$(SUBDIRS) :
	make -C $@ $(MAKECMDGOALS)
