# ターゲットなしの make 対応
.PHONY: default
default : submodule
	make -C testfw
	make -C test

.PHONY: submodule
submodule :
	git submodule update --init --recursive

.PHONY: all
all : submodule
	make -C testfw all
	make -C test all

.PHONY: clean
clean : submodule
	make -C testfw clean
	make -C test clean

.PHONY: test
test : submodule
	make -C testfw test
	make -C test test
