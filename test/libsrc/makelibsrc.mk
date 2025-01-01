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
	$(WORKSPACE_ROOT)/test/include_override \
	$(WORKSPACE_ROOT)/prod/include

OBJDIR := obj

CC := gcc
CPP := g++

include $(WORKSPACE_ROOT)/test/common_flags.mk

DEPFLAGS = -MT $@ -MMD -MP -MF $(OBJDIR)/$*.d
CFLAGS := $(addprefix -I, $(INCDIR)) $(CCOMFLAGS)
CPPFLAGS := $(addprefix -I, $(INCDIR)) $(CPPCOMFLAGS)
OBJS := $(addprefix $(OBJDIR)/, $(notdir $(SRCS_C:.c=.o) $(SRCS_CPP:.cc=.o)))
DEPS := $(addprefix $(OBJDIR)/, $(notdir $(SRCS_C:.c=.d) $(SRCS_CPP:.cc=.d)))

# 実行体の生成
$(TARGETDIR)/$(TARGET): $(OBJS) | $(TARGETDIR)

# C ソースファイルのコンパイル
$(OBJDIR)/%.o: %.c $(OBJDIR)/%.d | $(OBJDIR) $(TARGETDIR)
	$(CC) $(DEPFLAGS) $(CFLAGS) -c -o $@ $<;
	@if [ ! -f $(TARGETDIR)/$(TARGET) ]; then \
		echo ar rcs $(TARGETDIR)/$(TARGET); \
		ar rcs $(TARGETDIR)/$(TARGET); \
	fi
	ar rv $(TARGETDIR)/$(TARGET) $@

# C++ ソースファイルのコンパイル
$(OBJDIR)/%.o: %.cc $(OBJDIR)/%.d | $(OBJDIR) $(TARGETDIR)
	$(CPP) $(DEPFLAGS) $(CPPFLAGS) -c -o $@ $<;
	@if [ ! -f $(TARGETDIR)/$(TARGET) ]; then \
		echo ar rcs $(TARGETDIR)/$(TARGET); \
		ar rcs $(TARGETDIR)/$(TARGET); \
	fi
	ar rv $(TARGETDIR)/$(TARGET) $@

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
			ar tv $(TARGETDIR)/$(TARGET); \
		done \
    fi
	-rm -rf $(OBJDIR)

# make all test をワークスペースのルートで実行した場合、
# test ターゲットが伝播してくるため、無処理であることを明示する
.PHONY: test
test:
