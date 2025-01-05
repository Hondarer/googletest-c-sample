SUBDIRS = \
	libsrc \
	src

.PHONY: all
all : $(SUBDIRS)

.PHONY: clean
clean : $(SUBDIRS)

.PHONY: test
test : $(SUBDIRS)

.PHONY: $(SUBDIRS)
$(SUBDIRS) :
	make -C $@ $(MAKECMDGOALS)
