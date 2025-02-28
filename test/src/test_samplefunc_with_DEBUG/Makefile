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

# テスト対象のソースファイル
TEST_SRCS := \
	$(WORKSPACE_FOLDER)/prod/libsrc/sample/samplefunc.c

# フォルダ外の追加ソースファイル
# NOTE: オリジナルのテストシナリオをリンク
ADD_SRCS := \
    ../test_samplefunc/test_samplefunc.cc

# フラグの追加
CCOMFLAGS += -DDEBUG
CPPCOMFLAGS += -DDEBUG

# ライブラリの追加
LIBS += -lmocklibc -lmocksample -ltestcom

# src の Makefile テンプレートを include
include $(WORKSPACE_FOLDER)/test/src/makesrc.mk
