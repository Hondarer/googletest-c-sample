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
include $(WORKSPACE_FOLDER)/test/prepare.mk

# テスト対象のソースファイル
TEST_SRCS := \
	$(WORKSPACE_FOLDER)/prod/src/testcommand/testcommand.c

# リンクオプションの追加
# -Wl,--wrap=main により、エントリポイントを __wrap_main() に、元々のエントリポイントを __real_main() に変更
LDCOMFLAGS += -Wl,--wrap=main

# ライブラリの追加
# -lgtest_wrapmain にて、__wrap_main() 経由でのテスト実施
# テスト対象のソースファイルにある main() は実行されない
LIBS += -lgtest_wrapmain -lmocklibc -lmocksample -ltestcom

# src の Makefile テンプレートを include
include $(WORKSPACE_FOLDER)/test/src/makesrc.mk
