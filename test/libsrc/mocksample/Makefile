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

CCOMFLAGS := -g
CPPCOMFLAGS := -g

# libsrc の Makefile テンプレートをインクルード
include $(WORKSPACE_ROOT)/test/libsrc/makelibsrc.mk
