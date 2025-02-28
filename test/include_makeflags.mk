# 各 Makefile から呼び出され、
# 親階層から Makefile の存在する階層までに存在する makeflags.mk を
# 親階層から Makefile の存在する階層に向かって順次 include する

# makeflags.mk の検索
MAKEFILES := $(shell \
    dir=`pwd`; \
    while [ "$$dir" != "/" ]; do \
        if [ -f "$$dir/makeflags.mk" ]; then \
            echo "$$dir/makeflags.mk"; \
        fi; \
        if [ -f "$$dir/.workspaceRoot" ]; then \
            break; \
        fi; \
        dir=$$(dirname $$dir); \
    done \
)

# 逆順にする
MAKEFILES := $(foreach i, $(shell seq $(words $(MAKEFILES)) -1 1), $(word $(i), $(MAKEFILES)))

# makeflags.mk が存在すればインクルード
#$(foreach f, $(MAKEFILES), $(info include $(f)) $(eval include $(f)))
$(foreach f, $(MAKEFILES), $(eval include $(f)))
