# ターゲットなしの make 対応
.PHONY: TARGET_FOR_NO_ARGS
TARGET_FOR_NO_ARGS :
	make -C test

.PHONY: all
all :
	make -C test all

.PHONY: clean
clean :
	make -C test clean

.PHONY: test
test :
	make -C test test
# gcovr (dnf install python3.11 python3.11-pip; pip3.11 install gcovr)
	@if command -v gcovr > /dev/null 2>&1; then \
		gcovr --exclude-unreachable-branches --cobertura-pretty --output coverage.xml > /dev/null 2>&1; \
		gcovr --exclude-unreachable-branches; \
	else \
		echo "gcovr is not installed. Skipping coverage report."; \
	fi
