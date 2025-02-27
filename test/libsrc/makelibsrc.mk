SHELL := /bin/bash

# ソースファイルのエンコード指定から LANG を得る
FILES_LANG := $(shell sh $(WORKSPACE_FOLDER)/test/cmnd/get_files_lang.sh $(WORKSPACE_FOLDER))

# アーカイブのディレクトリ名とアーカイブ名
# TARGETDIR := . の場合、カレントディレクトリに実行体を生成する
ifeq ($(TARGETDIR),)
	TARGETDIR := $(WORKSPACE_FOLDER)/test/lib
endif
# ディレクトリ名をアーカイブ名にする
ifeq ($(TARGET),)
	TARGET := lib$(shell basename `pwd`).a
endif

# 【コンパイルオプションの観点】
# ・フォルダ外の追加ソースファイル								: ADD_SRCS	外から指定							OK
# ・その他のソースファイル
#   - 上記以外のカレントディレクトリに置かれているソースファイル
#
# 【ソース生成の観点】
# ・シンボリックリンクが必要というソースファイル				: LINK_SRCS										OK
#   - inject ファイル および フィルタファイルがない
# ・コピーが必要というソースファイル							: CP_SRCS										OK
#   - inject ファイル または フィルタファイルがある

# inject, filter 判定
CP_SRCS :=  $(foreach src,$(ADD_SRCS), \
	$(if $(or $(wildcard $(notdir $(basename $(src))).inject$(suffix $(src))), \
		$(wildcard $(notdir $(src)).filter.sh)), \
		$(src)))
LINK_SRCS := $(filter-out $(CP_SRCS),$(ADD_SRCS))

# コンパイル対象のソースファイル (カレントディレクトリから自動収集)
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

# ワークスペース名を -D に追加する
CCOMFLAGS += -D$(subst -,_,$(shell echo $(notdir $(WORKSPACE_FOLDER)) | tr '[:lower:]' '[:upper:]'))
CPPCOMFLAGS += -D$(subst -,_,$(shell echo $(notdir $(WORKSPACE_FOLDER)) | tr '[:lower:]' '[:upper:]'))

DEPFLAGS = -MT $@ -MMD -MP -MF $(OBJDIR)/$*.d
CFLAGS := $(CCOMFLAGS) $(addprefix -I, $(INCDIR))
CPPFLAGS := $(CPPCOMFLAGS) $(addprefix -I, $(INCDIR))

# OBJS
OBJS := $(filter-out $(OBJDIR)/%.inject.o, \
    $(sort $(addprefix $(OBJDIR)/, \
    $(notdir $(patsubst %.c, %.o, $(patsubst %.cc, %.o, $(patsubst %.cpp, %.o, $(SRCS_C) $(SRCS_CPP))))))))
# DEPS
DEPS := $(patsubst %.o, %.d, $(OBJS))

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
$(notdir $(LINK_SRCS)): $(LINK_SRCS)
	ln -s $(shell realpath --relative-to=. $(shell echo $(LINK_SRCS) | tr ' ' '\n' | awk '/$@/')) $(notdir $@)
#	.gitignore に対象ファイルを追加
	echo $(notdir $@) >> .gitignore
	@tempfile=$$(mktemp) && \
	sort .gitignore | uniq > $$tempfile && \
	mv $$tempfile .gitignore

# コピー対象のソースファイルをコピーして
# (1) フィルター処理をする
# (2) inject ファイルを結合する
$(notdir $(CP_SRCS)): $(CP_SRCS)
	@if [ -f "$(notdir $@).filter.sh" ]; then \
		echo "cat $(shell realpath --relative-to=. $(shell echo $(CP_SRCS) | tr ' ' '\n' | awk '/$@/')) | sh $(notdir $@).filter.sh > $(notdir $@)"; \
		cat $(shell realpath --relative-to=. $(shell echo $(CP_SRCS) | tr ' ' '\n' | awk '/$@/')) | sh $(notdir $@).filter.sh > $(notdir $@); \
		diff $(shell realpath --relative-to=. $(shell echo $(CP_SRCS) | tr ' ' '\n' | awk '/$@/')) $(notdir $@); set $?=0; \
	else \
		echo "cp -p $(shell realpath --relative-to=. $(shell echo $(CP_SRCS) | tr ' ' '\n' | awk '/$@/')) $(notdir $@)"; \
		cp -p $(shell realpath --relative-to=. $(shell echo $(CP_SRCS) | tr ' ' '\n' | awk '/$@/')) $(notdir $@); \
	fi
	@if [ -f "$(notdir $(basename $@)).inject$(suffix $@)" ]; then \
		if [ "$$(tail -c 1 $(notdir $@) | od -An -tx1)" != " 0a" ]; then \
			echo "echo \"\" >> $(notdir $@)"; \
			echo "" >> $(notdir $@); \
		fi; \
		echo "echo \"\" >> $(notdir $@)"; \
		echo "" >> $(notdir $@); \
		echo "echo \"/* Inject from test framework */\" >> $(notdir $@)"; \
		echo "/* Inject from test framework */" >> $(notdir $@); \
		echo "echo \"#ifdef _IN_TEST_FRAMEWORK_\" >> $(notdir $@)"; \
		echo "#ifdef _IN_TEST_FRAMEWORK_" >> $(notdir $@); \
		echo "echo \"#include \"$(basename $(notdir $@)).inject$(suffix $(notdir $@))\"\" >> $(notdir $@)"; \
		echo "#include \"$(basename $(notdir $@)).inject$(suffix $(notdir $@))\"" >> $(notdir $@); \
		echo "echo \"#endif // _IN_TEST_FRAMEWORK_\" >> $(notdir $@)"; \
		echo "#endif // _IN_TEST_FRAMEWORK_" >> $(notdir $@); \
	fi
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

.PHONY: all
all: clean $(TARGETDIR)/$(TARGET)

.PHONY: clean
clean:
	@if [ -f $(TARGETDIR)/$(TARGET) ]; then \
		for obj in $(OBJS); do \
			echo ar d $(TARGETDIR)/$(TARGET) $$(basename $$obj); \
			ar d $(TARGETDIR)/$(TARGET) $$(basename $$obj); \
		done; \
		ar tv $(TARGETDIR)/$(TARGET); \
    fi
#   シンボリックリンクされたソース、コピー対象のソースを削除する
	-@if [ -n "$(wildcard $(notdir $(CP_SRCS) $(LINK_SRCS)))" ]; then \
		echo rm -f $(notdir $(CP_SRCS) $(LINK_SRCS)); \
		rm -f $(notdir $(CP_SRCS) $(LINK_SRCS)); \
	fi
# .gitignore の再生成 (コミット差分が出ないように)
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
