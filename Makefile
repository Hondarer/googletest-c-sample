.PHONY: all
all :
	make -C test $(MAKECMDGOALS)

.PHONY: clean
clean :
	make -C test $(MAKECMDGOALS)

.PHONY: test
test :
	make -C test $(MAKECMDGOALS)
# gcovr (dnf install python3.11 python3.11-pip; pip3.11 install gcovr)
	@if command -v gcovr > /dev/null 2>&1; then \
		gcovr --exclude-unreachable-branches --cobertura-pretty --output coverage.xml > /dev/null 2>&1; \
		gcovr --exclude-unreachable-branches; \
	else \
		echo "gcovr is not installed. Skipping coverage report."; \
	fi
