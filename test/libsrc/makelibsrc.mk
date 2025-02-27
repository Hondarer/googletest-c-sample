SHELL := /bin/bash

# 副作用を防ぐため、はじめに include する
include $(WORKSPACE_FOLDER)/test/common_flags.mk

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

# コンパイル対象のソースファイル (カレントディレクトリから自動収集)
SRCS_C := $(wildcard *.c)
SRCS_CPP := $(wildcard *.cc) $(wildcard *.cpp)

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
OBJS := $(sort $(addprefix $(OBJDIR)/, $(notdir $(SRCS_C:.c=.o) $(LINK_SRCS_C:.c=.o) $(patsubst %.cc, %.o, $(patsubst %.cpp, %.o, $(SRCS_CPP) $(LINK_SRCS_CPP))))))
DEPS := $(sort $(addprefix $(OBJDIR)/, $(notdir $(SRCS_C:.c=.d) $(LINK_SRCS_C:.c=.d) $(patsubst %.cc, %.d, $(patsubst %.cpp, %.d, $(SRCS_CPP) $(LINK_SRCS_CPP))))))

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
$(notdir $(LINK_SRCS_C)):
	ln -s $(shell realpath --relative-to=. $(shell echo $(LINK_SRCS_C) | tr ' ' '\n' | awk '/$@/')) $(notdir $@)
#	.gitignore に対象ファイルを追加
	echo $(notdir $@) >> .gitignore
	@tempfile=$$(mktemp) && \
	sort .gitignore | uniq > $$tempfile && \
	mv $$tempfile .gitignore
$(notdir $(LINK_SRCS_CPP)):
	ln -s $(shell realpath --relative-to=. $(shell echo $(LINK_SRCS_CPP) | tr ' ' '\n' | awk '/$@/')) $(notdir $@)
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
#   シンボリックリンク対象から張ったシンボリックリンクを削除する
	-@if [ -n "$(wildcard $(notdir $(LINK_SRCS_C)))" ] || [ -n "$(wildcard $(notdir $(LINK_SRCS_CPP)))" ]; then \
		echo rm -f $(notdir $(LINK_SRCS_C)) $(notdir $(LINK_SRCS_CPP)); \
		rm -f $(notdir $(LINK_SRCS_C)) $(notdir $(LINK_SRCS_CPP)); \
	fi
# .gitignore の再生成 (コミット差分が出ないように)
	-rm -f .gitignore
	@for ignorefile in $(notdir $(LINK_SRCS_C)) $(notdir $(LINK_SRCS_CPP)); \
		do echo $$ignorefile >> .gitignore; \
		tempfile=$$(mktemp) && \
		sort .gitignore | uniq > $$tempfile && \
		mv $$tempfile .gitignore; \
	done
	-rm -rf $(OBJDIR)

.PHONY: test
test: $(TARGETDIR)/$(TARGET)
