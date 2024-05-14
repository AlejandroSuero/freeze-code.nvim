local delay = 3000
local old_gopath = vim.env.GOPATH

---@alias levels "ERROR"|"INFO"|"WARN"|"OFF"|"DEBUG"|"TRACE"

---Notification function
---@param level levels: notification level
---@param msg string: message to display
---@param ... any
local notify = function(level, msg, ...)
  local fmt_str = string.format("[freeze-code tests] %s: %s\n", level, msg)
  vim.notify(string.format(fmt_str, ...), vim.log.levels[level] or vim.log.levels.INFO, { title = "FreezeCodeTests" })
end

---Removes the directories for the mocks
---@param bin string: `path/to/plugin/tests/mocks/bin`
---@param go_bin string: `path/to/plugin/tests/mocks/go/bin`
local remove_binaries = function(bin, go_bin)
  local is_win = vim.api.nvim_call_function("has", { "win32" }) == 1
  local force_flag = is_win and " -Force" or "f"
  local cmd = { "rm", "-r" .. force_flag }
  -- removing binary from `agnostic_install_freeze`
  if vim.fn.isdirectory(bin) == 1 then
    notify("DEBUG", "removing `freeze` binary from `%s`", bin)
    table.insert(cmd, bin)
    local ok = os.execute(table.concat(cmd, " "))
    if not ok then
      notify("ERROR", "could not remove binary at `%s`", bin)
    end
    table.remove(cmd, #cmd)
  end

  -- removing binary from `go_install_freeze`
  if vim.fn.isdirectory(go_bin) == 1 then
    notify("DEBUG", "removing `freeze` binary from `%s`", go_bin)
    table.insert(cmd, go_bin)
    local ok = os.execute(table.concat(cmd, " "))
    if not ok then
      notify("ERROR", "could not remove binary at `%s`", bin)
    end
  end
end

describe("[freeze-code installation]", function()
  local opts
  local freeze_code
  local default_config
  local actual
  local expected
  local mocks_bin = vim.fn.expand("./tests/mocks/bin")
  local mocks_bin_freeze = mocks_bin .. "/freeze"
  local mocks_go_bin = vim.fn.expand("./tests/mocks/go/bin")
  local mocks_go_bin_freeze = mocks_go_bin .. "/freeze"

  before_each(function()
    ---@type FreezeCode
    freeze_code = require("freeze-code")
    default_config = require("freeze-code").config

    remove_binaries(mocks_bin, mocks_go_bin)

    -- setting $GOPATH to `path/to/plugin/tests/go/bin`
    if vim.env.GOPATH ~= nil or vim.env.GOPATH ~= vim.env.MOCK_DIR .. "/go/bin" then
      vim.fn.setenv("GOPATH", vim.env.MOCK_DIR .. "/go/bin")
    end
  end)

  after_each(function()
    remove_binaries(mocks_bin, mocks_go_bin)

    -- setting `$GOPATH` back to original
    vim.fn.setenv("GOPATH", old_gopath)
  end)

  it("installs `freeze` using `cURL`", function()
    opts = {
      _installed = false,
      install_path = mocks_bin,
      freeze_path = mocks_bin_freeze,
    }
    opts = vim.tbl_deep_extend("force", {}, default_config, opts or {})
    freeze_code.agnostic_install_freeze(opts)

    local mock_binary = mocks_bin_freeze
    if vim.wait(delay, function()
      return vim.fn.filereadable(mock_binary) == 1
    end) then
      expected = vim.fn.executable(mock_binary)
      actual = vim.fn.executable(vim.env.MOCK_DIR .. "/bin/freeze")
      assert.are.same(expected, actual)
    end
  end)

  it("installs `freeze` using `go install`", function()
    opts = {
      _installed = false,
      install_path = mocks_go_bin,
      freeze_path = mocks_go_bin_freeze,
    }
    opts = vim.tbl_deep_extend("force", {}, default_config, opts or {})
    freeze_code.go_install_freeze(opts)

    local mock_binary = mocks_go_bin_freeze
    if vim.wait(delay, function()
      return vim.fn.filereadable(mock_binary) == 1
    end) then
      expected = vim.fn.executable(mock_binary)
      actual = vim.fn.executable(vim.env.MOCK_DIR .. "/go/bin/freeze")
      assert.are.same(expected, actual)
    end
  end)
end)
