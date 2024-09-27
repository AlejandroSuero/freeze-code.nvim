GREEN="\033[00;32m"
RESTORE="\033[0m"

# mock directory accessible by `vim.env.MOCK_DIR`
MOCK_DIR="./tests/mocks"

# make the output of the message appear green
define style_calls
	$(eval $@_msg = $(1))
	echo ${GREEN}${$@_msg}
	echo ${RESTORE}
endef

.PHONY: test-vusted test-nvim lint style-lint format tests spell spell-write all help

default_target: help

test-vusted:
	@$(call style_calls,"Running vusted tests")
	@MOCK_DIR=${MOCK_DIR} vusted ./tests

test-nvim:
	@$(call style_calls,"Running tests using nvim")
	@MOCK_DIR=${MOCK_DIR} nvim --headless --noplugin -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/freeze-code {minimal_init = 'tests/minimal_init.lua'}"

tests: test-vusted test-nvim

lint: style-lint
	@$(call style_calls,"Running selene")
	@selene --display-style quiet --config ./selene.toml lua/freeze-code

style-lint:
	@$(call style_calls,"Running stylua check")
	@stylua --color always -f ./stylua.toml --check lua/freeze-code

format:
	@$(call style_calls,"Running stylua format")
	@stylua --color always -f ./stylua.toml lua/freeze-code

spell:
	@$(call style_calls,"Running codespell check")
	@codespell --quiet-level=2 --check-hidden --skip=./.git .

spell-write:
	@$(call style_calls,"Running codespell write")
	@codespell --quiet-level=2 --check-hidden --skip=./.git --write-changes .

all: tests lint spell

help:
	@echo "make test-vusted - Run tests using vusted"
	@echo "make test-nvim   - Run tests using nvim"
	@echo "make tests       - Run all tests"
	@echo "make lint        - Run linting"
	@echo "make style-lint  - Run style linting"
	@echo "make format      - Run formatting"
	@echo "make spell       - Run spell check"
	@echo "make spell-write - Run spell check and write changes"
	@echo "make all         - Run all checks"
