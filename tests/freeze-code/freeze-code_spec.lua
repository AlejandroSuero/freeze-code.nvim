local api = vim.api
local buf = nil
local win = nil
local delay = 2500

local function create_buffer()
  local width = vim.o.columns
  local height = vim.o.lines
  local height_ratio = 0.7
  local width_ratio = 0.7
  local win_height = math.ceil(height * height_ratio)
  local win_width = math.ceil(width * width_ratio)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)
  local win_opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    border = "none",
  }
  vim.loop.chdir(vim.loop.cwd() .. "/tests/mocks")
  buf = api.nvim_create_buf(false, true)
  win = api.nvim_open_win(buf, true, win_opts)

  api.nvim_win_set_option(win, "winblend", 0)
  api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(buf, "filetype", "typescript")
  api.nvim_buf_set_name(buf, "testing.ts")

  return buf
end
local function get_image_path()
  return vim.loop.fs_stat(vim.env.PWD .. "/freeze.png")
end

describe("[freeze-code test]", function()
  local freeze_code = require("freeze-code")
  local same = assert.are.same
  local not_same = assert.not_same
  describe("setup", function()
    it("creates user commands", function()
      vim.cmd("runtime plugin/freeze-code.lua")
      freeze_code.setup()
      local user_commands = api.nvim_get_commands({})
      not_same(nil, user_commands.Freeze)
    end)

    it("with default config", function()
      local expected = require("freeze-code").config
      freeze_code.setup()
      same(freeze_code.config, expected)
    end)

    it("with custom config", function()
      local default_config = require("freeze-code").config
      local opts = {
        copy = true,
        freeze_config = {
          theme = "rose-pine-moon",
        },
      }
      local expected = vim.tbl_deep_extend("force", {}, default_config, opts or {})
      freeze_code.setup(expected)
      same(freeze_code.config, expected)
      same(freeze_code.config.copy, true)
      same(freeze_code.config.freeze_config.theme, "rose-pine-moon")
    end)
  end)

  describe("freeze", function()
    before_each(function()
      vim.loop.chdir(vim.env.PWD)
      if win ~= nil and buf ~= nil then
        api.nvim_win_close(win, true)
        win = nil
      end
    end)
    after_each(function()
      vim.loop.chdir(vim.env.PWD)
      os.remove(vim.env.PWD .. "/freeze.png")
    end)
    it("creates an image from a file", function()
      local buffer = create_buffer()

      freeze_code.setup()
      api.nvim_buf_call(buffer, freeze_code.freeze)

      vim.wait(delay) -- wait for file to create

      assert(get_image_path)
    end)

    it("creates an image from a range in a file", function()
      local buffer = create_buffer()

      freeze_code.setup()
      api.nvim_buf_call(buffer, function()
        freeze_code.freeze(1, 3)
      end)

      vim.wait(delay) -- wait for file to create

      assert(get_image_path)
    end)
  end)
end)
