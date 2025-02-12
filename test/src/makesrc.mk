SHELL := /bin/bash

# 副作用を防ぐため、はじめに include する
include $(WORKSPACE_FOLDER)/test/common_flags.mk

# ソースファイルのエンコード指定から LANG を得る
FILES_LANG := $(shell sh $(WORKSPACE_FOLDER)/test/cmnd/get_files_lang.sh)

# テストプログラムのディレクトリ名と実行体名
# TARGETDIR := . の場合、カレントディレクトリに実行体を生成する
ifeq ($(TARGETDIR),)
	TARGETDIR := .
endif
# ディレクトリ名を実行体名にする
ifeq ($(TARGET),)
	TARGET := $(shell basename `pwd`)
endif

# コンパイル対象のソースファイル (カレントディレクトリから自動収集)
SRCS_C := $(wildcard *.c)
SRCS_CPP := $(wildcard *.cc) $(wildcard *.cpp)

# c_cpp_properties.json から include ディレクトリを得る
INCDIR := $(shell sh $(WORKSPACE_FOLDER)/test/cmnd/get_include_paths.sh)

LIBSDIR := \
	$(WORKSPACE_FOLDER)/test/lib

LIBSFILES := $(shell for dir in $(LIBSDIR); do find $$dir -maxdepth 1 -type f; done)

TEST_LIBS := -lgtest_main -lgtest -lpthread -lgmock -lgcov
ifneq ($(NO_GTEST_MAIN),)
	ifeq ($(NO_GTEST_MAIN), 1)
		TEST_LIBS := $(filter-out -lgtest_main, $(TEST_LIBS))
	endif
endif

TESTSH := $(WORKSPACE_FOLDER)/test/cmnd/exec_test.sh

OBJDIR := obj
GCOVDIR := gcov
LCOVDIR := lcov

# .c を gcc でコンパイルする場合、
# あらかじめ CC に g++ を設定しておく。
# そうでない場合は、gcc とする。
ifneq ($(CC),g++)
	CC := gcc
endif

CPP := g++
LD := g++

# -g が含まれていない場合に追加
ifeq ($(findstring -g,$(CCOMFLAGS)),)
  CCOMFLAGS += -g
endif
ifeq ($(findstring -g,$(CPPCOMFLAGS)),)
  CPPCOMFLAGS += -g
endif

DEPFLAGS = -MT $@ -MMD -MP -MF $(OBJDIR)/$*.d
CFLAGS := $(addprefix -I, $(INCDIR)) $(CCOMFLAGS)
CPPFLAGS := $(addprefix -I, $(INCDIR)) $(CPPCOMFLAGS)
LDFLAGS := $(addprefix -L, $(LIBSDIR))
OBJS := $(sort $(addprefix $(OBJDIR)/, $(notdir $(SRCS_C:.c=.o) $(patsubst %.cc, %.o, $(patsubst %.cpp, %.o, $(SRCS_CPP))) $(TEST_TARGET_SRCS_C:.c=.o) $(patsubst %.cc, %.o, $(patsubst %.cpp, %.o, $(TEST_TARGET_SRCS_CPP))))))
DEPS := $(sort $(addprefix $(OBJDIR)/, $(notdir $(SRCS_C:.c=.d) $(patsubst %.cc, %.d, $(patsubst %.cpp, %.d, $(SRCS_CPP))) $(TEST_TARGET_SRCS_C:.c=.d) $(patsubst %.cc, %.d, $(patsubst %.cpp, %.d, $(TEST_TARGET_SRCS_CPP))))))

# 実行体の生成
$(TARGETDIR)/$(TARGET): $(OBJS) $(LIBSFILES) | $(TARGETDIR)
	set -o pipefail; LANG=$(FILES_LANG) $(LD) $(LDFLAGS) -o $@ $(OBJS) $(LIBS) $(TEST_LIBS) -fdiagnostics-color=always 2>&1 | nkf

# C ソースファイルのコンパイル
$(OBJDIR)/%.o: %.c $(OBJDIR)/%.d | $(OBJDIR)
	@set -o pipefail; if echo $(TEST_TARGET_SRCS_C) | grep -q $(notdir $<); then \
		echo LANG=$(FILES_LANG) $(CC) $(DEPFLAGS) -I$(WORKSPACE_FOLDER)/test/include_override $(CFLAGS) -coverage -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
		LANG=$(FILES_LANG) $(CC) $(DEPFLAGS) -I$(WORKSPACE_FOLDER)/test/include_override $(CFLAGS) -coverage -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
	else \
		echo LANG=$(FILES_LANG) $(CC) $(DEPFLAGS) $(CFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
		LANG=$(FILES_LANG) $(CC) $(DEPFLAGS) $(CFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
	fi

# C++ ソースファイルのコンパイル (*.cc)
$(OBJDIR)/%.o: %.cc $(OBJDIR)/%.d | $(OBJDIR)
	@set -o pipefail; if echo $(TEST_TARGET_SRCS_CPP) | grep -q $(notdir $<); then \
		echo LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) -I$(WORKSPACE_FOLDER)/test/include_override $(CPPFLAGS) -coverage -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
		LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) -I$(WORKSPACE_FOLDER)/test/include_override $(CPPFLAGS) -coverage -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
	else \
		echo LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
		LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
	fi

# C++ ソースファイルのコンパイル (*.cpp)
$(OBJDIR)/%.o: %.cpp $(OBJDIR)/%.d | $(OBJDIR)
	@set -o pipefail; if echo $(TEST_TARGET_SRCS_CPP) | grep -q $(notdir $<); then \
		echo LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) -I$(WORKSPACE_FOLDER)/test/include_override $(CPPFLAGS) -coverage -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
		LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) -I$(WORKSPACE_FOLDER)/test/include_override $(CPPFLAGS) -coverage -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
	else \
		echo LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
		LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
	fi

# テスト対象のソースファイルからシンボリックリンクを張る
$(notdir $(TEST_TARGET_SRCS_C)):
	ln -s $(shell realpath --relative-to=. $(shell echo $(TEST_TARGET_SRCS_C) | tr ' ' '\n' | awk '/$@/')) $(notdir $@)
#	.gitignore に対象ファイルを追加
	echo $(notdir $@) >> .gitignore
	@tempfile=$$(mktemp) && \
	sort .gitignore | uniq > $$tempfile && \
	mv $$tempfile .gitignore
$(notdir $(TEST_TARGET_SRCS_CPP)):
	ln -s $(shell realpath --relative-to=. $(shell echo $(TEST_TARGET_SRCS_CPPs) | tr ' ' '\n' | awk '/$@/')) $(notdir $@)
#	.gitignore に対象ファイルを追加
	echo $(notdir $@) >> .gitignore
	@tempfile=$$(mktemp) && \
	sort .gitignore | uniq > $$tempfile && \
	mv $$tempfile .gitignore

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
# .gitignore の再生成 (コミット差分が出ないように)
	-rm -f .gitignore
	@for ignorefile in $(notdir $(TEST_TARGET_SRCS_C)) $(notdir $(TEST_TARGET_SRCS_CPP)); \
		do echo $$ignorefile >> .gitignore; \
		tempfile=$$(mktemp) && \
		sort .gitignore | uniq > $$tempfile && \
		mv $$tempfile .gitignore; \
	done
	-rm -rf $(OBJDIR)
	-rm -f $(TARGETDIR)/$(TARGET) core

.PHONY: clean-cov
clean-cov:
#	カバレッジ情報と、gcov, lcov で生成したファイルを削除する
	-rm -rf $(OBJDIR)/*.gcda
	-rm -rf $(OBJDIR)/*.info
	-rm -rf $(GCOVDIR)
	-rm -rf $(LCOVDIR)

.PHONY: take-cov
take-cov: take-gcov take-lcov

# Check if both variables are empty
ifneq ($(strip $(TEST_TARGET_SRCS_C)$(TEST_TARGET_SRCS_CPP)),)

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
	@if [ -s "$(shell command -v lcov 2> /dev/null)" ]; then \
		echo lcov -d $(OBJDIR) -c -o $(OBJDIR)/$(TARGET).info; \
		lcov -d $(OBJDIR) -c -o $(OBJDIR)/$(TARGET).info; \
	else \
		echo "lcov not found. Skipping."; \
	fi
#	genhtml は空のファイルを指定するとエラーを出力して終了するため
#	lcov の出力ファイルが空でないか確認してから genhtml を実行する
	@if [ -s $(OBJDIR)/$(TARGET).info ]; then \
		echo genhtml -o $(LCOVDIR) $(OBJDIR)/$(TARGET).info; \
		genhtml -o $(LCOVDIR) $(OBJDIR)/$(TARGET).info; \
	else \
		echo "No valid records found in tracefile $(OBJDIR)/$(TARGET).info."; \
	fi

else

.PHONY: take-gcov
take-gcov: $(GCOVDIR)
	@echo "No target source files for coverage measurement."

.PHONY: take-lcov
take-lcov: $(LCOVDIR)
	@echo "No target source files for coverage measurement."

endif

.PHONY: test
test: $(TESTSH) $(TARGETDIR)/$(TARGET)
	@status=0; \
	$(SHELL) $(TESTSH) > >(nkf) 2> >(nkf >&2) || status=$$?; \
	exit $$status
