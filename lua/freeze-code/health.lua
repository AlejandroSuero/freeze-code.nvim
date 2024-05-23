local health = vim.health or require("health")

local report_start = health.start or health.report_start
local report_ok = health.ok or health.report_ok
local report_warn = health.warn or health.report_warn
local report_error = health.error or health.report_error

local os_util = require("freeze-code.utils").os

local is_win = os_util.is_win
local is_macos = os_util.is_macos
local is_linux = os_util.is_unix

local is_freeze_installed = vim.fn.executable("freeze") == 1
local is_go_installed = vim.fn.executable("go") == 1

---@alias os_platform "windows"|"macos"|"linux"|"all"

---@class FreezeCodeHealthPackage
---@field name string: package name
---@field cmd string[]: cmd command call
---@field url string: package url
---@field optional boolean: whether or not is an optional package
---@field args string[]|nil: check version command
---@field platform os_platform: for which OS is needed

---@class FreezeCodeHealthDependency
---@field cmd_name string: command name
---@table package FreezeCodeHealthPackage[]

---@type FreezeCodeHealthDependency[]
local optional_dependencies = {
  {
    cmd_name = "freeze",
    package = {
      {
        name = "Freeze",
        cmd = { "freeze" },
        args = nil,
        url = "[charmbracelet/freeze](https://github.com/charmbracelet/freeze)",
        optional = false,
        platform = "all",
      },
    },
  },
  {
    cmd_name = "Install freeze",
    package = {
      {
        name = "GoLang",
        cmd = { "go" },
        args = { "version" },
        url = "[golang](https://go.dev/dl)",
        optional = is_freeze_installed,
        platform = "all",
      },
      {
        name = "cURL",
        cmd = { "curl" },
        args = { "--version" },
        url = "[curl](https://curl.se/docs/releases.html)",
        optional = is_freeze_installed or is_go_installed,
        platform = "all",
      },
      {
        name = "tar",
        cmd = { "tar" },
        args = { "--version" },
        url = "[tar](https://www.gnu.org/software/tar/)",
        optional = is_freeze_installed or is_go_installed,
        platform = not is_win and "linux",
      },
      {
        name = "Expand-Archive",
        cmd = { "Expand-Archive" },
        args = nil,
        url = "[Expand-Archive](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/expand-archive?view=powershell-7.4)",
        optional = is_freeze_installed or is_go_installed,
        platform = "windows",
      },
    },
  },
  {
    cmd_name = "osascript",
    package = {
      {
        name = "Osascript",
        cmd = { "osascript" },
        args = nil,
        url = "[docs](https://pypi.org/project/osascript/)",
        optional = true,
        platform = "macos",
      },
    },
  },
  {
    cmd_name = "xclip",
    package = {
      {
        name = "xclip",
        cmd = { "xclip" },
        args = nil,
        url = "[astrand/xclip](https://github.com/astrand/xclip)",
        optional = true,
        platform = "linux",
      },
    },
  },
  {
    cmd_name = "Add-Type",
    package = {
      {
        name = "powershell",
        cmd = { "pwsh" },
        args = { "--version" },
        url = "[PowerShell/PowerShell](https://github.com/PowerShell/PowerShell)",
        optional = true,
        platform = "windows",
      },
    },
  },
  {
    cmd_name = "Clipboard",
    package = {
      {
        name = "gclip",
        cmd = { "gclip" },
        args = nil,
        url = "[golang-design/clipboard](https://github.com/golang-design/clipboard)",
        optional = true,
        platform = "all",
      },
    },
  },
  {
    cmd_name = "open",
    package = {
      {
        name = "open",
        cmd = { "open" },
        args = nil,
        url = "[docs](https://www.man7.org/linux/man-pages/man2/open.2.html)",
        optional = true,
        platform = "linux",
      },
    },
  },
  {
    cmd_name = "explorer",
    package = {
      {
        name = "explorer",
        cmd = { "explorer" },
        args = nil,
        url = "[docs](https://devblogs.microsoft.com/scripting/use-powershell-to-work-with-windows-explorer/)",
        optional = true,
        platform = "windows",
      },
    },
  },
}

---Check if the package is needed by the platorm
---@param pkg FreezeCodeHealthPackage
---@return boolean
local check_platform_needed = function(pkg)
  if pkg.platform == "windows" then
    return is_win
  end
  if pkg.platform == "linux" or pkg.platform == "macos" then
    return is_linux or is_macos
  end
  if pkg.platform == "linux" then
    return is_linux
  end
  if pkg.platform == "macos" then
    return is_macos
  end

  return true
end

---Check if the cmd for the package are installed and which version
---@param pkg FreezeCodeHealthPackage
---@return boolean installed
---@return string|any
---@return boolean needed
local check_binary_installed = function(pkg)
  local needed = check_platform_needed(pkg)
  local cmd = pkg.cmd or { pkg.name }
  for _, binary in ipairs(cmd) do
    if is_win then
      binary = binary .. ".exe"
    end
    if vim.fn.executable(binary) == 1 then
      local binary_version = ""
      local version_cmd = ""
      if pkg.args == nil then
        return vim.fn.executable(binary) == 1, "", needed
      else
        local cmd_args = table.concat(pkg.args, " ")
        version_cmd = table.concat({ binary, cmd_args }, " ")
      end
      local handle, err = io.popen(version_cmd)

      if err then
        report_error(err)
        vim.notify(err, vim.log.levels.ERROR, { title = "FreezeCode" })
        return true, err, needed
      end
      if handle then
        binary_version = handle:read("*a")
        handle:close()
        if binary_version:lower():find("built from source") then
          return true, binary_version, needed
        elseif
          binary_version:lower():find("illegal")
          or binary_version:lower():find("unknown")
          or binary_version:lower():find("invalid")
        then
          return true, "", needed
        end
        return true, binary_version, needed
      end
    end
  end
  return false, "", needed
end

local M = {}

M.check = function()
  report_start("Checking for external dependencies")

  for _, opt_dep in pairs(optional_dependencies) do
    for _, pkg in ipairs(opt_dep.package) do
      local installed, version, needed = check_binary_installed(pkg)
      if not installed then
        local err_msg = string.format("%s: not found.", pkg.name)
        if pkg.optional and needed then
          local warn_msg =
            string.format("%s %s", err_msg, string.format("Install %s for extended capabilities", pkg.url))
          report_warn(warn_msg)
        else
          if needed then
            err_msg = string.format(
              "%s %s",
              err_msg,
              string.format("`%s` will not function without %s installed.", opt_dep.cmd_name, pkg.url)
            )
            report_error(err_msg)
          end
        end
      else
        version = version == "" and "(unknown)" or version
        local eol = version:find("\n")
        if eol == nil then
          version = "(unknown)"
        else
          version = version:sub(0, eol - 1)
        end
        local ok_msg = string.format("%s: found! version: `%s`", pkg.name, version)
        report_ok(ok_msg)
      end
    end
  end

  report_start("====================================================================================")
end

return M
