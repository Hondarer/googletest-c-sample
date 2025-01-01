# 副作用を防ぐため、はじめに include する
include $(WORKSPACE_ROOT)/test/common_flags.mk

# テストプログラムのディレクトリ名と実行体名
# TARGETDIR := . の場合、カレントディレクトリに実行体を生成する
TARGETDIR := .
# ディレクトリ名を実行体名にする
TARGET := $(shell basename `pwd`)

# コンパイル対象のソースファイル (カレントディレクトリから自動収集)
SRCS_C := $(wildcard *.c)
SRCS_CPP := $(wildcard *.cc)

OVERRIDE_INCDIR := \
	$(WORKSPACE_ROOT)/test/include_override

INCDIR := \
	/usr/local/include \
	$(WORKSPACE_ROOT)/test/include \
	$(WORKSPACE_ROOT)/prod/include

LIBSDIR := \
	/usr/local/lib64 \
	$(WORKSPACE_ROOT)/test/lib

LIBS := -lmockstdio -lmocksample -ltestcom -lgtest -lgtest_main -lpthread -lgmock -lgcov

TESTSH := $(WORKSPACE_ROOT)/test/cmnd/exec_test.sh

OBJDIR := obj
GCOVDIR := gcov
LCOVDIR := lcov

CC := gcc
CPP := g++
LD := g++

DEPFLAGS = -MT $@ -MMD -MP -MF $(OBJDIR)/$*.d
CFLAGS := $(addprefix -I, $(INCDIR)) $(CCOMFLAGS)
CPPFLAGS := $(addprefix -I, $(INCDIR)) $(CPPCOMFLAGS)
LDFLAGS := $(addprefix -L, $(LIBSDIR))
OBJS := $(addprefix $(OBJDIR)/, $(notdir $(SRCS_C:.c=.o) $(SRCS_CPP:.cc=.o) $(TEST_TARGET_SRCS_C:.c=.o) $(TEST_TARGET_SRCS_CPP:.cc=.o)))
DEPS := $(addprefix $(OBJDIR)/, $(notdir $(SRCS_C:.c=.d) $(SRCS_CPP:.cc=.d) $(TEST_TARGET_SRCS_C:.c=.d) $(TEST_TARGET_SRCS_CPP:.cc=.d)))

# 実行体の生成
$(TARGETDIR)/$(TARGET): $(OBJS) | $(TARGETDIR)
	$(LD) $(LDFLAGS) -o $@ $^ $(LIBS)

# C ソースファイルのコンパイル
$(OBJDIR)/%.o: %.c $(OBJDIR)/%.d | $(OBJDIR)
	@if echo $(TEST_TARGET_SRCS_C) | grep -q $(notdir $<); then \
		echo $(CC) $(DEPFLAGS) $(addprefix -I, $(OVERRIDE_INCDIR)) $(CFLAGS) -coverage -c -o $@ $<; \
		$(CC) $(DEPFLAGS) $(addprefix -I, $(OVERRIDE_INCDIR)) $(CFLAGS) -coverage -c -o $@ $<; \
	else \
		echo $(CC) $(DEPFLAGS) $(CFLAGS) -c -o $@ $<; \
		$(CC) $(DEPFLAGS) $(CFLAGS) -c -o $@ $<; \
	fi

# C++ ソースファイルのコンパイル
$(OBJDIR)/%.o: %.cc $(OBJDIR)/%.d | $(OBJDIR)
	@if echo $(TEST_TARGET_SRCS_CPP) | grep -q $(notdir $<); then \
		echo $(CPP) $(DEPFLAGS) $(addprefix -I, $(OVERRIDE_INCDIR)) $(CPPFLAGS) -coverage -c -o $@ $<; \
		$(CPP) $(DEPFLAGS) $(addprefix -I, $(OVERRIDE_INCDIR)) $(CPPFLAGS) -coverage -c -o $@ $<; \
	else \
		echo $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $<; \
		$(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $<; \
	fi

# テスト対象のソースファイルからシンボリックリンクを張る
$(notdir $(TEST_TARGET_SRCS_C)):
	ln -s $(shell echo $(TEST_TARGET_SRCS_C) | tr ' ' '\n' | awk '/$@/') $(notdir $@)
$(notdir $(TEST_TARGET_SRCS_CPP)):
	ln -s $(shell echo $(TEST_TARGET_SRCS_C) | tr ' ' '\n' | awk '/$@/') $(notdir $@)

# The empty rule is required to handle the case where the dependency file is deleted.
$(DEPS):

include $(wildcard $(DEPS))

$(TARGETDIR):
	mkdir -p $@

$(OBJDIR):
	mkdir -p $@

$(GCOVDIR):
	mkdir -p $@

$(LCOVDIR):
	mkdir -p $@

.PHONY: all
all: clean $(TARGETDIR)/$(TARGET)

.PHONY: clean
clean: clean-cov
#   テスト対象から張ったシンボリックリンクを削除する
	-@if [ -n "$(wildcard $(notdir $(TEST_TARGET_SRCS_C)))" ] || [ -n "$(wildcard $(notdir $(TEST_TARGET_SRCS_CPP)))" ]; then \
		echo rm -f $(notdir $(TEST_TARGET_SRCS_C)) $(notdir $(TEST_TARGET_SRCS_CPP)); \
		rm -f $(notdir $(TEST_TARGET_SRCS_C)) $(notdir $(TEST_TARGET_SRCS_CPP)); \
	fi
	-rm -rf $(OBJDIR)
	-rm -f $(TARGETDIR)/$(TARGET)

.PHONY: clean-cov
clean-cov:
#	カバレッジ情報と、gcov, lcov で生成したファイルを削除する
	-rm -rf $(OBJDIR)/*.gcda
	-rm -rf $(OBJDIR)/*.info
	-rm -rf $(GCOVDIR)
	-rm -rf $(LCOVDIR)

.PHONY: take-cov
take-cov: take-gcov take-lcov

.PHONY: take-gcov
take-gcov: $(GCOVDIR)
#	gcov で生成したファイルを削除する
	-rm -rf $(GCOVDIR)/*
#	gcov でカバレッジ情報を取得する
#	-bc オプションは可読性に問題があるので、使用しない (lcov の結果で確認可能)
#	gcov -bc $(TEST_TARGET_SRCS_C) $(TEST_TARGET_SRCS_CPP) -o $(OBJDIR)
	gcov $(TEST_TARGET_SRCS_C) $(TEST_TARGET_SRCS_CPP) -o $(OBJDIR)
	mv *.gcov $(GCOVDIR)/.

.PHONY: take-lcov
take-lcov: $(LCOVDIR)
#	lcov で生成したファイルを削除する
	-rm -rf $(OBJDIR)/*.info
	-rm -rf $(LCOVDIR)/*
#	lcov でカバレッジ情報を取得する
	lcov -d $(OBJDIR) -c -o $(OBJDIR)/$(TARGET).info
#	genhtml は空のファイルを指定するとエラーを出力して終了するため
#	lcov の出力ファイルが空でないか確認してから genhtml を実行する
	@if [ -s $(OBJDIR)/$(TARGET).info ]; then \
		echo genhtml -o $(LCOVDIR) $(OBJDIR)/$(TARGET).info; \
		genhtml -o $(LCOVDIR) $(OBJDIR)/$(TARGET).info; \
	else \
		echo "No valid records found in tracefile $(OBJDIR)/$(TARGET).info"; \
	fi

.PHONY: test
test: $(TESTSH) $(TARGETDIR)/$(TARGET)
	@sh $(TESTSH)
