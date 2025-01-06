# 副作用を防ぐため、はじめに include する
include $(WORKSPACE_ROOT)/test/common_flags.mk

# アーカイブのディレクトリ名とアーカイブ名
# TARGETDIR := . の場合、カレントディレクトリに実行体を生成する
TARGETDIR := $(WORKSPACE_ROOT)/test/lib
# ディレクトリ名をアーカイブ名にする
TARGET := lib$(shell basename `pwd`).a

# コンパイル対象のソースファイル (カレントディレクトリから自動収集)
SRCS_C := $(wildcard *.c)
SRCS_CPP := $(wildcard *.cc)

INCDIR := \
	/usr/local/include \
	$(WORKSPACE_ROOT)/test/include \
	$(WORKSPACE_ROOT)/prod/include

OBJDIR := obj

CC := gcc
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
	$(CC) $(DEPFLAGS) $(CFLAGS) -c -o $@ $<

# C++ ソースファイルのコンパイル
$(OBJDIR)/%.o: %.cc $(OBJDIR)/%.d | $(OBJDIR) $(TARGETDIR)
	$(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $<

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
test: all
