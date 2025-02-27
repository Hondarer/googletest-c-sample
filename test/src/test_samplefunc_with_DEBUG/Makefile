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

# 直近の makeflags.mk を探索
include $(WORKSPACE_FOLDER)/test/include_flags.mk

# テスト対象のソースファイル
TEST_SRCS := \
	$(WORKSPACE_FOLDER)/prod/libsrc/sample/samplefunc.c

# フォルダ外の追加ソースファイル
# NOTE: オリジナルのテストシナリオをリンク
ADD_SRCS := \
    ../test_samplefunc/test_samplefunc.cc

# フラグの設定
CCOMFLAGS += -DDEBUG
CPPCOMFLAGS += -DDEBUG

# ライブラリの指定
LIBS := -lmocklibc -lmocksample -ltestcom

# src の Makefile テンプレートをインクルード
include $(WORKSPACE_FOLDER)/test/src/makesrc.mk
