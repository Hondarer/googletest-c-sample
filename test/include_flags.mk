# 各ディレクトリから呼び出されることを想定
# 直近の makeflags.mk を探索
MAKEFLAGS_MK := $(shell \
    dir=`pwd`; \
    while [ "$$dir" != "/" ]; do \
        if [ -f "$$dir/makeflags.mk" ]; then \
            echo "$$dir/makeflags.mk"; \
            break; \
        fi; \
        if [ -f "$$dir/.workspaceRoot" ]; then \
            echo $$dir; \
            break; \
        fi; \
        dir=$$(dirname $$dir); \
    done \
)
# makeflags.mk が存在すればインクルード
ifneq ($(MAKEFLAGS_MK),)
include $(MAKEFLAGS_MK)
endif
