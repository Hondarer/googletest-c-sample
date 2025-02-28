# ワークスペースのディレクトリ
WORKSPACE_FOLDER := $(shell \
    dir=`pwd`; \
    while [ "$$dir" != "/" ]; do \
        if [ -f "$$dir/.workspaceRoot" ]; then \
            echo $$dir; \
            break; \
        fi; \
        dir=$$(dirname $$dir); \
    done \
)

# 準備処理 (Makefile テンプレートより前に include)
include $(WORKSPACE_FOLDER)/test/prepare.mk

# フォルダ外の追加ソースファイル
ADD_SRCS := \
	$(WORKSPACE_FOLDER)/prod/libsrc/sample/samplefunc2.c

# ライブラリの追加
LIBS += -lmocklibc -lmocksample -ltestcom

# src の Makefile テンプレートを include
include $(WORKSPACE_FOLDER)/test/src/makesrc.mk
