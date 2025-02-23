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
TEST_TARGET_SRCS_C := \
	$(WORKSPACE_FOLDER)/prod/src/testcommand/testcommand.c
TEST_TARGET_SRCS_CPP :=

# リンクオプションの設定
# -Wl,--wrap=main により、エントリポイントを __wrap_main() に、元々のエントリポイントを __real_main() に変更
LDCOMFLAGS := -Wl,--wrap=main

# ライブラリの指定
# -lgtest_wrapmain にて、__wrap_main() 経由でのテスト実施
# テスト対象のソースファイルにある main() は実行されない
LIBS := -lgtest_wrapmain -lmocklibc -lmocksample -ltestcom

# src の Makefile テンプレートをインクルード
include $(WORKSPACE_FOLDER)/test/src/makesrc.mk
