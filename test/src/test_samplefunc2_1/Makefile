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
# NOTE: シンボリックリンクで引き込むため、
#       テスト対象のソースファイルはカレントディレクトリ以外に存在する前提
TEST_TARGET_SRCS_C := 
TEST_TARGET_SRCS_CPP :=

# ライブラリの指定
LIBS := -lrealsample -lmocklibc -lmocksample -ltestcom

# src の Makefile テンプレートをインクルード
include $(WORKSPACE_FOLDER)/test/src/makesrc.mk
