local assert = require("luassert.assert")
describe("[freeze-code test]", function()
  describe("setup", function()
    local code_snapshot = require("freeze-code")
    local same = assert.are.same
    it("with default config", function()
      local expected = {
        freeze_path = vim.fn.exepath("freeze"),
        copy_cmd = vim.env.HOME .. "/dev/nvim_plugins/freeze-code.nvim/bin/pngcopy-macos",
        copy = false,
        open = false,
        dir = vim.env.PWD,
        freeze_config = {
          output = "freeze.png",
          config = "base",
          theme = "default",
        },
      }
      code_snapshot.setup()
      same(code_snapshot.config, expected)
    end)
    it("with custom config", function()
      local expected = {
        freeze_path = vim.fn.exepath("freeze"),
        copy_cmd = vim.env.HOME .. "/dev/nvim_plugins/freeze-code.nvim/bin/pngcopy-linux",
        copy = false,
        open = true,
        dir = vim.env.PWD,
        freeze_config = {
          output = "freeze.png",
          config = "user",
          theme = "rose-pine-moon",
        },
      }
      code_snapshot.setup(expected)
      same(code_snapshot.config, expected)
    end)
  end)
end)
