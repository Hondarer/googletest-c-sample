# ターゲットなしの make 対応
.PHONY: TARGET_FOR_NO_ARGS
TARGET_FOR_NO_ARGS :
	make -C test

.PHONY: all
all :
	make -C test all

.PHONY: clean
clean :
	make -C test clean

.PHONY: test
test :
	make -C test test
