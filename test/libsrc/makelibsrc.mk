# 副作用を防ぐため、はじめに include する
include $(WORKSPACE_ROOT)/test/common_flags.mk

# ソースファイルのエンコード指定から LANG を得る
FILES_LANG := $(shell sh $(WORKSPACE_ROOT)/test/cmnd/get_files_lang.sh $(WORKSPACE_ROOT))

# アーカイブのディレクトリ名とアーカイブ名
# TARGETDIR := . の場合、カレントディレクトリに実行体を生成する
ifeq ($(TARGETDIR),)
	TARGETDIR := $(WORKSPACE_ROOT)/test/lib
endif
# ディレクトリ名をアーカイブ名にする
ifeq ($(TARGET),)
	TARGET := lib$(shell basename `pwd`).a
endif

# コンパイル対象のソースファイル (カレントディレクトリから自動収集)
SRCS_C := $(wildcard *.c)
SRCS_CPP := $(wildcard *.cc)

INCDIR := \
	/usr/local/include \
	$(WORKSPACE_ROOT)/test/include \
	$(WORKSPACE_ROOT)/prod/include

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

DEPFLAGS = -MT $@ -MMD -MP -MF $(OBJDIR)/$*.d
CFLAGS := $(addprefix -I, $(INCDIR)) $(CCOMFLAGS)
CPPFLAGS := $(addprefix -I, $(INCDIR)) $(CPPCOMFLAGS)
OBJS := $(addprefix $(OBJDIR)/, $(notdir $(SRCS_C:.c=.o) $(SRCS_CPP:.cc=.o)))
DEPS := $(addprefix $(OBJDIR)/, $(notdir $(SRCS_C:.c=.d) $(SRCS_CPP:.cc=.d)))

# アーカイブの生成
$(TARGETDIR)/$(TARGET): $(OBJS) | $(TARGETDIR)
	ar rv $@ $(OBJS)

# C ソースファイルのコンパイル
$(OBJDIR)/%.o: %.c $(OBJDIR)/%.d | $(OBJDIR) $(TARGETDIR)
	set -o pipefail; LANG=$(FILES_LANG) $(CC) $(DEPFLAGS) $(CFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf

# C++ ソースファイルのコンパイル
$(OBJDIR)/%.o: %.cc $(OBJDIR)/%.d | $(OBJDIR) $(TARGETDIR)
	set -o pipefail; LANG=$(FILES_LANG) $(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $< -fdiagnostics-color=always 2>&1 | nkf

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
	-rm -rf $(OBJDIR)

.PHONY: test
test: $(TARGETDIR)/$(TARGET)
