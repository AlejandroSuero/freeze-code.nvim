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

.PHONY: test test-nvim lint style-lint format

test:
	@$(call style_calls,"Running vusted tests")
	@MOCK_DIR=${MOCK_DIR} vusted ./tests

test-nvim:
	@$(call style_calls,"Running tests using nvim")
	@MOCK_DIR=${MOCK_DIR} nvim --headless --noplugin -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/freeze-code {minimal_init = 'tests/minimal_init.lua'}"

lint: style-lint
	@$(call style_calls,"Running selene")
	@selene --display-style quiet --config ./selene.toml lua/freeze-code

style-lint:
	@$(call style_calls,"Running stylua check")
	@stylua --color always -f ./stylua.toml --check lua/freeze-code

format:
	@$(call style_calls,"Running stylua format")
	@stylua --color always -f ./stylua.toml lua/freeze-code

all: test test-nvim lint
