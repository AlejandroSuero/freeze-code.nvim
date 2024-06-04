local api = vim.api
local buf = nil
local win = nil
local delay = 5000

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

  if vim.fn.has("nvim-0.10") == 1 then
    api.nvim_set_option_value("winblend", 0, { scope = "local" })
    api.nvim_set_option_value("bufhidden", "wipe", { scope = "local" })
    api.nvim_set_option_value("filetype", "typescript", { scope = "local" })
  else
    api.nvim_win_set_option(win, "winblend", 0)
    api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    api.nvim_buf_set_option(buf, "filetype", "typescript")
  end
  api.nvim_buf_set_name(buf, "testing.ts")

  return buf
end
local function get_image_path()
  return vim.loop.fs_stat("./freeze.png")
end

describe("[freeze-code test]", function()
  local freeze_code_config = require("freeze-code.config")
  local freeze_code_api = require("freeze-code.utils.api")
  local freeze_code = require("freeze-code")
  local same = assert.are.same
  local not_same = assert.not_same
  before_each(function()
    freeze_code_config = require("freeze-code.config")
    freeze_code = require("freeze-code")
    freeze_code.setup()
  end)
  describe("setup", function()
    it("creates user commands", function()
      vim.cmd("runtime plugin/freeze-code.lua")
      freeze_code_config.setup()
      local user_commands = api.nvim_get_commands({})
      not_same(nil, user_commands.Freeze)
    end)

    it("with default config", function()
      local expected = require("freeze-code.config").config
      freeze_code.setup()
      same(freeze_code_config.config, expected)
    end)

    it("with custom config", function()
      local default_config = require("freeze-code.config").config
      local opts = {
        copy = true,
        freeze_config = {
          theme = "rose-pine-moon",
        },
      }
      local expected = vim.tbl_deep_extend("force", {}, default_config, opts or {})
      freeze_code.setup(expected)
      same(freeze_code_config.config, expected)
      same(freeze_code_config.config.copy, true)
      same(freeze_code_config.config.freeze_config.theme, "rose-pine-moon")
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
      api.nvim_buf_call(buffer, freeze_code_api.freeze)

      if vim.wait(delay, function()
        return get_image_path() ~= nil
      end) then
        local actual = get_image_path()
        not_same(nil, actual)
      end
    end)

    it("creates an image from a range in a file", function()
      local buffer = create_buffer()

      freeze_code.setup()
      api.nvim_buf_call(buffer, function()
        freeze_code_api.freeze(1, 3)
      end)

      if vim.wait(delay, function()
        return get_image_path() ~= nil
      end) then
        local actual = get_image_path()
        not_same(nil, actual)
      end
    end)
  end)
end)
