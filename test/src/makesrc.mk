SHELL := /bin/bash

# 【コンパイルオプションの観点】
# ・テストの対象 (カバレッジ対象) のソースファイル				: TEST_SRCS		外から指定
# ・フォルダ外の追加ソースファイル								: ADD_SRCS		外から指定
# ・その他のソースファイル
#   - 上記以外のカレントディレクトリに置かれているソースファイル
#
# 【ソース生成の観点】
# ・C のソース													: SRCS_C
# ・C++ のソース												: SRCS_CPP
# ・シンボリックリンクが必要というソースファイル				: LINK_SRCS
#   - inject ファイル および フィルタファイルがない
# ・コピーが必要というソースファイル							: CP_SRCS
#   - inject ファイル または フィルタファイルがある
# ・直接配置のソースファイル									: DIRECT_SRCS
#   - TEST_SRCS, ADD_SRCS に指定されていて、カレントディレクトリに配置されているもの

# inject, filter 判定
CP_SRCS := $(foreach src,$(TEST_SRCS) $(ADD_SRCS), \
	$(if $(or $(wildcard $(notdir $(basename $(src))).inject$(suffix $(src))), \
		$(wildcard $(notdir $(src)).filter.sh)), \
		$(src)))
DIRECT_SRCS := $(if $(filter-out $(CP_SRCS),$(TEST_SRCS) $(ADD_SRCS)),$(shell for f in $(filter-out $(CP_SRCS),$(TEST_SRCS) $(ADD_SRCS)); do \
	if [ -f "./$$(basename $$f)" ] && [ ! -L "./$$(basename $$f)" ]; then \
		echo $$f; \
	fi; \
	done))
LINK_SRCS := $(filter-out $(CP_SRCS) $(DIRECT_SRCS),$(TEST_SRCS) $(ADD_SRCS))

# 以下の処理は、ADD_SRCS に inject ファイルや filter ファイルを指定するための追加処理
# make 開始時点でファイルが配置されていない場合は、CP_SRCS に正しく移動しきれないファイルがあるため

# LINK_SRCS の中から `*.inject.*` に対応する元ファイルを探して CP_SRCS に追加
CP_SRCS += $(foreach f, $(LINK_SRCS), \
	$(if $(findstring .inject.,$(notdir $(f))), \
		$(foreach src, $(filter %$(subst .inject.,.,$(notdir $(f))), $(LINK_SRCS)), $(src))))

# LINK_SRCS の中から `*.filter.sh` に対応する元ファイルを探して CP_SRCS に追加
CP_SRCS += $(foreach f, $(LINK_SRCS), \
	$(if $(findstring .filter.sh,$(notdir $(f))), \
		$(foreach src, $(filter %$(subst .filter.sh,,$(notdir $(f))), $(LINK_SRCS)), $(src))))

# CP_SRCS の重複排除
CP_SRCS := $(sort $(CP_SRCS))

# LINK_SRCS から CP_SRCS のファイルを削除
LINK_SRCS := $(filter-out $(CP_SRCS), $(LINK_SRCS))

#$(info CP_SRCS: $(CP_SRCS))
#$(info DIRECT_SRCS: $(DIRECT_SRCS))
#$(info LINK_SRCS: $(LINK_SRCS))

# gcovr のフィルタを作成
# gcovr では、シンボリックリンクの場合は、実パスを与える必要がある
GCOVR_SRCS := $(foreach src,$(TEST_SRCS), \
	$(if $(filter $(src),$(LINK_SRCS)), \
		 $(src), \
		 $(notdir $(src))))

# コンパイル対象のソースファイル (カレントディレクトリから自動収集 + 指定ファイル)
SRCS_C := $(wildcard *.c) $(filter %.c,$(CP_SRCS) $(LINK_SRCS))
SRCS_CPP := $(wildcard *.cc) $(wildcard *.cpp) $(filter %.cc,$(CP_SRCS) $(LINK_SRCS)) $(filter %.cpp,$(CP_SRCS) $(LINK_SRCS))

# c_cpp_properties.json から include ディレクトリを得る
INCDIR := $(shell sh $(WORKSPACE_FOLDER)/test/cmnd/get_include_paths.sh)

# 外部で LIBSDIR が指定されている場合は維持して結合
LIBSDIR := $(LIBSDIR) \
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

# c_cpp_properties.json の defines にある値を -D として追加する
# DEFINES は prepare.mk で設定されている
CCOMFLAGS += $(addprefix -D,$(DEFINES))
CPPCOMFLAGS += $(addprefix -D,$(DEFINES))

DEPFLAGS = -MT $@ -MMD -MP -MF $(OBJDIR)/$*.d

# NOTE: テスト対象の場合は、CCOMFLAGS の後、通常の include の前に include_override を追加する
#       CCOMFLAGS に追加した include パスは、include_override より前に評価されるので
#       個別のテストでの include 注入に対応できる

# テスト対象
CFLAGS_TEST := $(CCOMFLAGS) -I$(WORKSPACE_FOLDER)/test/include_override $(addprefix -I, $(INCDIR))
CPPFLAGS_TEST := $(CPPCOMFLAGS) -I$(WORKSPACE_FOLDER)/test/include_override $(addprefix -I, $(INCDIR))
# テスト対象以外
CFLAGS := $(CCOMFLAGS) $(addprefix -I, $(INCDIR))
CPPFLAGS := $(CPPCOMFLAGS) $(addprefix -I, $(INCDIR))

LDFLAGS := $(LDCOMFLAGS) $(addprefix -L, $(LIBSDIR))

# OBJS
OBJS := $(filter-out $(OBJDIR)/%.inject.o, \
	$(sort $(addprefix $(OBJDIR)/, \
	$(notdir $(patsubst %.c, %.o, $(patsubst %.cc, %.o, $(patsubst %.cpp, %.o, $(SRCS_C) $(SRCS_CPP))))))))
# DEPS
DEPS := $(patsubst %.o, %.d, $(OBJS))

# テストプログラムのディレクトリ名と実行体名
# TARGETDIR := . の場合、カレントディレクトリに実行体を生成する
ifeq ($(TARGETDIR),)
	TARGETDIR := .
endif
# ディレクトリ名を実行体名にする
ifeq ($(TARGET),)
	TARGET := $(shell basename `pwd`)
endif

ifndef NO_LINK
# 実行体の生成
$(TARGETDIR)/$(TARGET): $(OBJS) $(LIBSFILES) | $(TARGETDIR)
	set -o pipefail; LANG=$(FILES_LANG) $(LD) $(LDFLAGS) -o $@ $(OBJS) $(LIBS) $(TEST_LIBS) -fdiagnostics-color=always 2>&1 | nkf
else
# リンクのみ
$(OBJS): $(LIBSFILES)
endif

# コンパイル時の依存関係に $(notdir $(LINK_SRCS)) $(notdir $(CP_SRCS)) を定義しているのは
# ヘッダ類などを引き込んでおく必要がある場合に、先に処理を行っておきたいため

# C ソースファイルのコンパイル
$(OBJDIR)/%.o: %.c $(OBJDIR)/%.d $(notdir $(LINK_SRCS)) $(notdir $(CP_SRCS)) | $(OBJDIR)
	@set -o pipefail; if echo $(TEST_SRCS) | grep -q $(notdir $<); then \
		echo LANG=$(FILES_LANG) $(CC) $(DEPFLAGS) $(CFLAGS_TEST) -coverage -D_IN_TEST_FRAMEWORK_ -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
		LANG=$(FILES_LANG) $(CC) $(DEPFLAGS) $(CFLAGS_TEST) -coverage -D_IN_TEST_FRAMEWORK_ -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
	else \
		echo LANG=$(FILES_LANG) $(CC) $(DEPFLAGS) $(CFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
		LANG=$(FILES_LANG) $(CC) $(DEPFLAGS) $(CFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
	fi

# C++ ソースファイルのコンパイル (*.cc)
$(OBJDIR)/%.o: %.cc $(OBJDIR)/%.d $(notdir $(LINK_SRCS)) $(notdir $(CP_SRCS)) | $(OBJDIR)
	@set -o pipefail; if echo $(TEST_SRCS) | grep -q $(notdir $<); then \
		echo LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS_TEST) -coverage -D_IN_TEST_FRAMEWORK_ -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
		LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS_TEST) -coverage -D_IN_TEST_FRAMEWORK_ -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
	else \
		echo LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
		LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
	fi

# C++ ソースファイルのコンパイル (*.cpp)
$(OBJDIR)/%.o: %.cpp $(OBJDIR)/%.d $(notdir $(LINK_SRCS)) $(notdir $(CP_SRCS)) | $(OBJDIR)
	@set -o pipefail; if echo $(TEST_SRCS) | grep -q $(notdir $<); then \
		echo LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS_TEST) -coverage -D_IN_TEST_FRAMEWORK_ -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
		LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS_TEST) -coverage -D_IN_TEST_FRAMEWORK_ -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
	else \
		echo LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
		LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf; \
	fi

# シンボリックリンク対象のソースファイルをシンボリックリンク
define generate_link_src_rule
$(1):
	ln -s $(2) $(1)
#	.gitignore に対象ファイルを追加
	echo $(1) >> .gitignore
	@tempfile=$$(mktemp) && \
	sort .gitignore | uniq > $$tempfile && \
	mv $$tempfile .gitignore
endef

# ファイルごとの依存関係を動的に定義
$(foreach link_src,$(LINK_SRCS),$(eval $(call generate_link_src_rule,$(notdir $(link_src)),$(link_src))))

# コピー対象のソースファイルをコピーして
# 1. フィルター処理をする
# 2. inject 処理をする
define generate_cp_src_rule
$(1): $(2) $(wildcard $(1).filter.sh) $(wildcard $(basename $(1)).inject$(suffix $(1))) $(filter $(1).filter.sh,$(notdir $(LINK_SRCS))) $(filter $(basename $(1)).inject$(suffix $(1)),$(notdir $(LINK_SRCS)))
	@if [ -f "$(1).filter.sh" ]; then \
		echo "cat $(2) | sh $(1).filter.sh > $(1)"; \
		cat $(2) | sh $(1).filter.sh > $(1); \
		diff $(2) $(1); set $?=0; \
	else \
		echo "cp -p $(2) $(1)"; \
		cp -p $(2) $(1); \
	fi
	@if [ -f "$(basename $(1)).inject$(suffix $(1))" ]; then \
		if [ "$$(tail -c 1 $(1) | od -An -tx1)" != " 0a" ]; then \
			echo "echo \"\" >> $(1)"; \
			echo "" >> $(1); \
		fi; \
		echo "echo \"\" >> $(1)"; \
		echo "" >> $(1); \
		echo "echo \"/* Inject from test framework */\" >> $(1)"; \
		echo "/* Inject from test framework */" >> $(1); \
		echo "echo \"#ifdef _IN_TEST_FRAMEWORK_\" >> $(1)"; \
		echo "#ifdef _IN_TEST_FRAMEWORK_" >> $(1); \
		echo "echo \"#include \"$(basename $(1)).inject$(suffix $(1))\"\" >> $(1)"; \
		echo "#include \"$(basename $(1)).inject$(suffix $(1))\"" >> $(1); \
		echo "echo \"#endif // _IN_TEST_FRAMEWORK_\" >> $(1)"; \
		echo "#endif // _IN_TEST_FRAMEWORK_" >> $(1); \
	fi
#	.gitignore に対象ファイルを追加
	echo $(1) >> .gitignore
	@tempfile=$$(mktemp) && \
	sort .gitignore | uniq > $$tempfile && \
	mv $$tempfile .gitignore
endef

# ファイルごとの依存関係を動的に定義
$(foreach cp_src,$(CP_SRCS),$(eval $(call generate_cp_src_rule,$(notdir $(cp_src)),$(cp_src))))

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
ifndef NO_LINK
# clean & 実行体の生成
all: clean $(TARGETDIR)/$(TARGET)
else
# clean & リンクのみ
all: clean $(OBJS) $(LIBSFILES)
endif

.PHONY: clean
clean: clean-cov clean-test
#   シンボリックリンクされたソース、コピー対象のソースを削除する
	-@if [ -n "$(wildcard $(notdir $(CP_SRCS) $(LINK_SRCS)))" ]; then \
		echo rm -f $(notdir $(CP_SRCS) $(LINK_SRCS)); \
		rm -f $(notdir $(CP_SRCS) $(LINK_SRCS)); \
	fi
#	.gitignore の再生成 (コミット差分が出ないように)
	-rm -f .gitignore
	@for ignorefile in $(notdir $(CP_SRCS) $(LINK_SRCS)); \
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

.PHONY: clean-test
clean-test:
	-rm -rf results

# Check if both variables are empty
ifneq ($(strip $(TEST_SRCS)),)

.PHONY: take-cov
take-cov: take-gcov take-lcov take-gcovr

.PHONY: take-gcovr
take-gcovr:
# gcovr (dnf install python3.11 python3.11-pip; pip3.11 install gcovr)
	@if command -v gcovr > /dev/null 2>&1; then \
		#gcovr --exclude-unreachable-branches --cobertura-pretty --output coverage.xml --filter "$(shell echo $(GCOVR_SRCS) | tr ' ' '|')" > /dev/null 2>&1; \
		gcovr --exclude-unreachable-branches --filter "$(shell echo $(GCOVR_SRCS) | tr ' ' '|')"; \
	fi

.PHONY: take-gcov
take-gcov: $(GCOVDIR)
#	gcov で生成したファイルを削除する
	-rm -rf $(GCOVDIR)/*
#	gcov でカバレッジ情報を取得する
#	-bc オプションは可読性に問題があるので、使用しない (lcov の結果で確認可能)
#	gcov -bc $(TEST_SRCS) -o $(OBJDIR)
	gcov $(TEST_SRCS) -o $(OBJDIR)
#	カバレッジ未通過の *.gcov ファイルは削除する
	@if [ -n "$$(ls *.gcov 2>/dev/null)" ]; then \
		for file in *.gcov; do \
			if ! grep -qE '^\s*[0-9]+\*?:' "$$file"; then \
				echo "rm $$file # No coverage data"; \
				rm "$$file"; \
			fi; \
		done \
	fi
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
		echo genhtml --function-coverage -o $(LCOVDIR) $(OBJDIR)/$(TARGET).info; \
		genhtml --function-coverage -o $(LCOVDIR) $(OBJDIR)/$(TARGET).info; \
	else \
		echo "No valid records found in tracefile $(OBJDIR)/$(TARGET).info."; \
	fi

else

.PHONY: take-cov
take-cov:
	@echo "No target source files for coverage measurement."

.PHONY: take-gcovr
take-gcovr:
	@echo "No target source files for coverage measurement."

.PHONY: take-gcov
take-gcov:
	@echo "No target source files for coverage measurement."

.PHONY: take-lcov
take-lcov:
	@echo "No target source files for coverage measurement."

endif

.PHONY: test
ifndef NO_LINK
# テストの実行
test: $(TESTSH) $(TARGETDIR)/$(TARGET)
	@status=0; \
	$(SHELL) $(TESTSH) > >(nkf) 2> >(nkf >&2) || status=$$?; \
	exit $$status
else
# 何もしない
test: ;
endif
