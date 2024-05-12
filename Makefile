.PHONY: test test-nvim lint style-lint format

test:
	@printf "%s\nRunning tests using vusted\n"
	@vusted ./tests

test-nvim:
	@printf "\nRunning tests using nvim\n"
	@nvim --headless --noplugin -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/freeze-code {minimal_init = 'tests/minimal_init.lua', sequential = true}"

lint: style-lint
	@printf "\nRunning selene\n"
	@selene --display-style quiet --config ./selene.toml lua/freeze-code

style-lint:
	@printf "\nRunning stylua check\n"
	@stylua --color always -f ./stylua.toml --check lua/freeze-code

format:
	@printf "\nRunning stylua format\n"
	@stylua --color always -f ./stylua.toml lua/freeze-code

all: test test-nvim lint
