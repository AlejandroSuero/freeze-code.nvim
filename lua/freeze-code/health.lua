local health = vim.health or require("health")

local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local warn = health.warn or health.report_warn
local error = health.error or health.report_error

local os_util = require("freeze-code.utils").os

local is_win = os_util.is_win
local is_macos = os_util.is_macos

---@class FreezeCodeHealthPackage
---@field name string: package name
---@field binaries string[]: binaries command call
---@field url string: package url
---@field optional boolean: whether or not is an optional package

---@class FreezeCodeHealthDependency
---@field cmd_name string: command name
---@table package FreezeCodeHealthPackage[]

---@type FreezeCodeHealthDependency[]
local optional_dependencies = {
  {
    cmd_name = "freeze",
    package = {
      {
        name = "freeze",
        binaries = { "freeze" },
        url = "[charmbracelet/freeze](https://github.com/charmbracelet/freeze)",
        optional = false,
      },
    },
  },
  {
    cmd_name = "osascript",
    package = {
      {
        name = "osascript",
        binaries = { "osascript" },
        url = "[docs](https://pypi.org/project/osascript/)",
        optional = is_macos and false,
      },
    },
  },
  {
    cmd_name = "xclip",
    package = {
      {
        name = "xclip",
        binaries = { "xclip" },
        url = "[astrand/xclip](https://github.com/astrand/xclip)",
        optional = (not is_win) and true,
      },
    },
  },
  {
    cmd_name = "Add-Type",
    package = {
      name = "powershell",
      binaries = { "pwsh" },
      url = "[PowerShell/PowerShell](https://github.com/PowerShell/PowerShell)",
      optional = is_win and false,
    },
  },
  {
    cmd_name = "open",
    package = {
      name = "open",
      binaries = { "open" },
      url = "[docs](https://www.man7.org/linux/man-pages/man2/open.2.html)",
      optional = is_macos and false,
    },
  },
  {
    cmd_name = "explorer",
    package = {
      name = "explorer",
      binaries = { "explorer" },
      url = "[docs](https://devblogs.microsoft.com/scripting/use-powershell-to-work-with-windows-explorer/)",
      optional = is_win and false,
    },
  },
}

---Check if the binaries for the package are installed and which version
---@param package FreezeCodeHealthPackage
---@return boolean installed
---@return string|any
local check_binary_installed = function(package)
  local binaries = package.binaries or { package.name }
  for _, binary in ipairs(binaries) do
    if is_win then
      binary = binary .. ".exe"
    end
    if vim.fn.executable(binary) == 1 then
      local handle, err = io.popen(binary .. " --version")
      if err then
        error(err)
      end
      if handle then
        local binary_version = handle:read("*a")
        handle:close()
        return true, binary_version
      end
    end
  end
  return false, ""
end

local M = {}

M.check = function()
  start("Checking for external dependencies")

  for _, opt_dep in pairs(optional_dependencies) do
    for _, package in ipairs(opt_dep.package) do
      local installed, version = check_binary_installed(package)
      if not installed then
        local err_msg = string.format("%s: not found.", package.name)
        if package.optional then
          local warn_msg =
            string.format("%s %s", err_msg, string.format("Install %s for extended capabilities", package.url))
          warn(warn_msg)
        else
          err_msg = string.format(
            "%s %s",
            err_msg,
            string.format("`%s` will not function without %s installed.", opt_dep.cmd_name, package.url)
          )
          error(err_msg)
        end
      else
        local eol = version:find("\n")
        if eol == nil then
          version = "(unkown version)"
        else
          version = version:sub(0, eol - 1) or "(unkown version)"
        end
        local ok_msg = string.format("%s: found %s", package.name, version)
        ok(ok_msg)
      end
    end
  end
end

return M
