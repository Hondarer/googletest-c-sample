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
include $(WORKSPACE_FOLDER)/testfw/makefiles/prepare.mk

# テスト対象のソースファイル
# ※ prod 配下ではなく、ここに直接テスト対象を配置する例
TEST_SRCS := \
	testterget.c

# ライブラリの追加
LIBS += -lmocklibc -lmocksample -ltestcom

# src の Makefile テンプレートを include
include $(WORKSPACE_FOLDER)/testfw/makefiles/makesrc.mk
