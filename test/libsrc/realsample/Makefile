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

# シンボリックリンク対象のソースファイル
# NOTE: シンボリックリンクで引き込むため、
#       シンボリックリンク対象のソースファイルはカレントディレクトリ以外に存在する前提
LINK_SRCS_C := \
	$(WORKSPACE_FOLDER)/prod/libsrc/sample/samplefunc2.c
LINK_SRCS_CPP :=

# libsrc の Makefile テンプレートをインクルード
include $(WORKSPACE_FOLDER)/test/libsrc/makelibsrc.mk
