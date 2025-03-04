TESTS := $(sort $(wildcard test_*))

test: ../disorderfs
	set -eu; for X in $(TESTS); do \
		echo "executing $$X" >&2; \
		./$$X; \
	done

.PHONY: test
