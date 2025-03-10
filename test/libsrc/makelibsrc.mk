SHELL := /bin/bash

# 【コンパイルオプションの観点】
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
#   - ADD_SRCS に指定されていて、カレントディレクトリに配置されているもの

# inject, filter 判定
CP_SRCS := $(foreach src,$(ADD_SRCS), \
	$(if $(or $(wildcard $(notdir $(basename $(src))).inject$(suffix $(src))), \
		$(wildcard $(notdir $(src)).filter.sh)), \
		$(src)))
DIRECT_SRCS := $(if $(filter-out $(CP_SRCS),$(ADD_SRCS)),$(shell for f in $(filter-out $(CP_SRCS),$(ADD_SRCS)); do \
	if [ -f "./$$(basename $$f)" ] && [ ! -L "./$$(basename $$f)" ]; then \
		echo $$f; \
	fi; \
	done))
LINK_SRCS := $(filter-out $(CP_SRCS),$(ADD_SRCS))

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

# コンパイル時の依存関係に $(notdir $(LINK_SRCS)) $(notdir $(CP_SRCS)) を定義しているのは
# ヘッダ類などを引き込んでおく必要がある場合に、先に処理を行っておきたいため

# C ソースファイルのコンパイル
$(OBJDIR)/%.o: %.c $(OBJDIR)/%.d $(notdir $(LINK_SRCS)) $(notdir $(CP_SRCS)) | $(OBJDIR) $(TARGETDIR)
	set -o pipefail; LANG=$(FILES_LANG) $(CC) $(DEPFLAGS) $(CFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf

# C++ ソースファイルのコンパイル (*.cc)
$(OBJDIR)/%.o: %.cc $(OBJDIR)/%.d $(notdir $(LINK_SRCS)) $(notdir $(CP_SRCS)) | $(OBJDIR) $(TARGETDIR)
	set -o pipefail; LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf

# C++ ソースファイルのコンパイル (*.cpp)
$(OBJDIR)/%.o: %.cpp $(OBJDIR)/%.d $(notdir $(LINK_SRCS)) $(notdir $(CP_SRCS)) | $(OBJDIR) $(TARGETDIR)
	set -o pipefail; LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf

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
		echo "echo \"#ifdef _IN_TEST_SRC_\" >> $(1)"; \
		echo "#ifdef _IN_TEST_SRC_" >> $(1); \
		echo "echo \"#include \"$(basename $(1)).inject$(suffix $(1))\"\" >> $(1)"; \
		echo "#include \"$(basename $(1)).inject$(suffix $(1))\"" >> $(1); \
		echo "echo \"#endif // _IN_TEST_SRC_\" >> $(1)"; \
		echo "#endif // _IN_TEST_SRC_" >> $(1); \
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

.PHONY: all
all: clean $(TARGETDIR)/$(TARGET)

.PHONY: clean
clean:
	-rm -f $(TARGETDIR)/$(TARGET)
#	@if [ -f $(TARGETDIR)/$(TARGET) ]; then \
#		for obj in $(OBJS); do \
#			echo ar d $(TARGETDIR)/$(TARGET) $$(basename $$obj); \
#			ar d $(TARGETDIR)/$(TARGET) $$(basename $$obj); \
#		done; \
#	fi
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
