# ワークスペースのルートディレクトリ
WORKSPACE_ROOT := $(shell \
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
TEST_TARGET_SRCS_C := \
	$(WORKSPACE_ROOT)/prod/libsrc/sample/samplelogger.c
TEST_TARGET_SRCS_CPP :=

# src の Makefile テンプレートをインクルード
include $(WORKSPACE_ROOT)/test/src/makesrc.mk
