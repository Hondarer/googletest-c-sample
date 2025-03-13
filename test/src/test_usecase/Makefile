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
TEST_SRCS := 

# ライブラリの追加
LIBS += -lmocklibc -lmocksample -ltestcom

# src の Makefile テンプレートを include
include $(WORKSPACE_FOLDER)/testfw/makefiles/makesrc.mk
