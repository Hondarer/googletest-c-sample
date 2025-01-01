SUBDIRS = $(wildcard */)

.PHONY: all
all : $(SUBDIRS)

.PHONY: clean
clean : $(SUBDIRS)

.PHONY: test
test :

.PHONY: $(SUBDIRS)
$(SUBDIRS) : 
	make -C $@ $(MAKECMDGOALS)
