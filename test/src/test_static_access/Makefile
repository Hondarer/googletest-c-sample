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

# テスト対象のソースファイル
# NOTE: inject パターンでは、元フォルダから cp で複写して走査を行うため、
#       テスト対象のソースファイルはカレントディレクトリ以外に存在する前提
TEST_TARGET_SRCS_C := \
	$(WORKSPACE_FOLDER)/prod/libsrc/sample/samplestatic.c
TEST_TARGET_SRCS_CPP :=

# ライブラリの指定
LIBS := -lmocklibc -lmocksample -ltestcom

# src の Makefile テンプレートをインクルード
include $(WORKSPACE_FOLDER)/test/src/makesrc.mk
