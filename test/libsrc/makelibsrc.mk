SHELL := /bin/bash

# 【コンパイルオプションの観点】
# ・フォルダ外の追加ソースファイル								: ADD_SRCS		外から指定
# ・その他のソースファイル
#   - 上記以外のカレントディレクトリに置かれているソースファイル
#
# 【ソース生成の観点】
# ・シンボリックリンクが必要というソースファイル				: LINK_SRCS
#   - inject ファイル および フィルタファイルがない
# ・コピーが必要というソースファイル							: CP_SRCS
#   - inject ファイル または フィルタファイルがある
# ・直接配置のソースファイル									: DIRECT_SRCS
#   - ADD_SRCS に指定されていて、カレントディレクトリに配置されているもの

# inject, filter 判定
CP_SRCS :=  $(foreach src,$(ADD_SRCS), \
	$(if $(or $(wildcard $(notdir $(basename $(src))).inject$(suffix $(src))), \
		$(wildcard $(notdir $(src)).filter.sh)), \
		$(src)))
DIRECT_SRCS := $(if $(filter-out $(CP_SRCS),$(ADD_SRCS)),$(shell for f in $(filter-out $(CP_SRCS),$(ADD_SRCS)); do \
    if [ -f "./$$(basename $$f)" ] && [ ! -L "./$$(basename $$f)" ]; then \
		echo $$f; \
	fi; \
	done))
LINK_SRCS := $(filter-out $(CP_SRCS),$(ADD_SRCS))

# コンパイル対象のソースファイル (カレントディレクトリから自動収集 + 指定ファイル)
SRCS_C := $(wildcard *.c) $(filter %.c,$(CP_SRCS) $(LINK_SRCS))
SRCS_CPP := $(wildcard *.cc) $(wildcard *.cpp) $(filter %.cc,$(CP_SRCS) $(LINK_SRCS)) $(filter %.cpp,$(CP_SRCS) $(LINK_SRCS))

# c_cpp_properties.json から include ディレクトリを得る
INCDIR := $(shell sh $(WORKSPACE_FOLDER)/test/cmnd/get_include_paths.sh)

OBJDIR := obj

# .c を gcc でコンパイルする場合、
# あらかじめ CC に g++ を設定しておく。
# そうでない場合は、gcc とする。
ifneq ($(CC),g++)
	CC := gcc
endif

CPP := g++

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
CFLAGS := $(CCOMFLAGS) $(addprefix -I, $(INCDIR))
CPPFLAGS := $(CPPCOMFLAGS) $(addprefix -I, $(INCDIR))

# OBJS
OBJS := $(filter-out $(OBJDIR)/%.inject.o, \
	$(sort $(addprefix $(OBJDIR)/, \
	$(notdir $(patsubst %.c, %.o, $(patsubst %.cc, %.o, $(patsubst %.cpp, %.o, $(SRCS_C) $(SRCS_CPP))))))))
# DEPS
DEPS := $(patsubst %.o, %.d, $(OBJS))

# アーカイブのディレクトリ名とアーカイブ名
# TARGETDIR := . の場合、カレントディレクトリに実行体を生成する
ifeq ($(TARGETDIR),)
	TARGETDIR := $(WORKSPACE_FOLDER)/test/lib
endif
# ディレクトリ名をアーカイブ名にする
ifeq ($(TARGET),)
	TARGET := lib$(shell basename `pwd`).a
endif

# アーカイブの生成
$(TARGETDIR)/$(TARGET): $(OBJS) | $(TARGETDIR)
	ar rvs $@ $(OBJS)

# C ソースファイルのコンパイル
$(OBJDIR)/%.o: %.c $(OBJDIR)/%.d | $(OBJDIR) $(TARGETDIR)
	set -o pipefail; LANG=$(FILES_LANG) $(CC) $(DEPFLAGS) $(CFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf

# C++ ソースファイルのコンパイル (*.cc)
$(OBJDIR)/%.o: %.cc $(OBJDIR)/%.d | $(OBJDIR) $(TARGETDIR)
	set -o pipefail; LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf

# C++ ソースファイルのコンパイル (*.cpp)
$(OBJDIR)/%.o: %.cpp $(OBJDIR)/%.d | $(OBJDIR) $(TARGETDIR)
	set -o pipefail; LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf

# シンボリックリンク対象のソースファイルからシンボリックリンクを張る
$(notdir $(LINK_SRCS)):
#	LINK_SRCS の notdir を引数に、LINK_SRCS に存在するフルパスを得る
	ln -s $(shell printf '%s\n' $(LINK_SRCS) | awk '{ notdir=$$0; sub(".*/", "", notdir); if (notdir == "$@") { print $$0 }}') $@
#	.gitignore に対象ファイルを追加
	echo $@ >> .gitignore
	@tempfile=$$(mktemp) && \
	sort .gitignore | uniq > $$tempfile && \
	mv $$tempfile .gitignore

# コピー対象のソースファイルをコピーして
# 1. フィルター処理をする
# 2. inject 処理をする
$(notdir $(CP_SRCS)): $(CP_SRCS)
#	CP_SRCS の notdir を引数に、CP_SRCS に存在するフルパスを得る
	@CP_SRC=$(shell printf '%s\n' $(CP_SRCS) | awk '{ notdir=$$0; sub(".*/", "", notdir); if (notdir == "$@") { print $$0 }}'); \
	if [ -f "$@.filter.sh" ]; then \
		echo "cat $$CP_SRC | sh $@.filter.sh > $@"; \
		cat $$CP_SRC | sh $@.filter.sh > $@; \
		diff $$CP_SRC $@; set $?=0; \
	else \
		echo "cp -p $$CP_SRC $@"; \
		cp -p $$CP_SRC $@; \
	fi
	@if [ -f "$(notdir $(basename $@)).inject$(suffix $@)" ]; then \
		if [ "$$(tail -c 1 $@ | od -An -tx1)" != " 0a" ]; then \
			echo "echo \"\" >> $@"; \
			echo "" >> $@; \
		fi; \
		echo "echo \"\" >> $@"; \
		echo "" >> $@; \
		echo "echo \"/* Inject from test framework */\" >> $@"; \
		echo "/* Inject from test framework */" >> $@; \
		echo "echo \"#ifdef _IN_TEST_FRAMEWORK_\" >> $@"; \
		echo "#ifdef _IN_TEST_FRAMEWORK_" >> $@; \
		echo "echo \"#include \"$(basename $@).inject$(suffix $@)\"\" >> $@"; \
		echo "#include \"$(basename $@).inject$(suffix $@)\"" >> $@; \
		echo "echo \"#endif // _IN_TEST_FRAMEWORK_\" >> $@"; \
		echo "#endif // _IN_TEST_FRAMEWORK_" >> $@; \
	fi
#	.gitignore に対象ファイルを追加
	echo $@ >> .gitignore
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

.PHONY: all
all: clean $(TARGETDIR)/$(TARGET)

.PHONY: clean
clean:
	@if [ -f $(TARGETDIR)/$(TARGET) ]; then \
		for obj in $(OBJS); do \
			echo ar d $(TARGETDIR)/$(TARGET) $$(basename $$obj); \
			ar d $(TARGETDIR)/$(TARGET) $$(basename $$obj); \
		done; \
	fi
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

.PHONY: test
test: $(TARGETDIR)/$(TARGET)
