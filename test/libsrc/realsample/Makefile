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

# フォルダ外の追加ソースファイル
ADD_SRCS := \
	$(WORKSPACE_FOLDER)/prod/libsrc/sample/samplefunc2.c

# libsrc の Makefile テンプレートをインクルード
include $(WORKSPACE_FOLDER)/test/libsrc/makelibsrc.mk
