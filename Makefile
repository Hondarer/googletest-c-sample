# ターゲットなしの make 対応
.PHONY: TARGET_FOR_NO_ARGS
TARGET_FOR_NO_ARGS :
	make -C testfw
	make -C test

.PHONY: all
all :
	make -C testfw all
	make -C test all

.PHONY: clean
clean :
	make -C testfw clean
	make -C test clean

.PHONY: test
test :
	make -C testfw test
	make -C test test
