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
TEST_SRCS := \
	$(WORKSPACE_FOLDER)/prod/libsrc/sample/samplestatic.c

# フォルダ外の追加ソースファイル
ADD_SRCS := \
    ../test_static_access/test_static_access.cc \
    ../test_static_access/samplestatic.inject.h \
    ../test_static_access/samplestatic.inject.c

# ライブラリの追加
LIBS += -lmock_libc -lmock_sample -ltest_com

# src の Makefile テンプレートを include
include $(WORKSPACE_FOLDER)/testfw/makefiles/makesrc.mk
