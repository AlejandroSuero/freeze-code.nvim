---@meta

---@class FreezeCodeOS
---@field is_win boolean
---@field is_macos boolean
---@field is_unix boolean

---@class FreezeCodeUtils
---@field logger FreezeCodeLogger
---@type FreezeCodeUtils|{}
local M = {}

M.logger = require("freeze-code.utils.logger")

local freeze_version = "0.1.6"

---@class FreezeCodeUtils
---@field get_archive_extension function: Get the release archive file extension depending on OS
M.get_archive_extension = function()
  local os_name, _ = M.get_os_info()

  return (os_name == "Windows" and ".zip" or ".tar.gz")
end

---@class FreezeCodeUtils
---@field release_file_url function: Get the release file for the right OS and Architecture from official release
---page, https://github.com/charmbracelet/freeze/releases, for the specified version
---@return string
M.release_file_url = function()
  -- check pre-existence of required programs
  if vim.fn.executable("curl") == 0 or vim.fn.executable("tar") == 0 then
    vim.notify("curl and/or tar are required", vim.log.levels.ERROR, { title = "Freeze" })
    return ""
  end

  local filename = M.get_freeze_filename() .. M.get_archive_extension()

  -- create the url, filename based on os and arch
  return "https://github.com/charmbracelet/freeze/releases/download/v" .. freeze_version .. "/" .. filename
end

---@class FreezeCodeUtils
---@field get_os_info function: Get the os and architecture info
---@return string os_name: OS name
---@return string arch: OS architecture
M.get_os_info = function()
  local os_name, arch

  local raw_os = vim.loop.os_uname().sysname
  local raw_arch = jit.arch
  local os_patterns = {
    ["Windows"] = "Windows",
    ["Windows_NT"] = "Windows",
    ["Linux"] = "Linux",
    ["Darwin"] = "Darwin",
    ["BSD"] = "Freebsd",
  }

  local arch_patterns = {
    ["x86"] = "i386",
    ["x64"] = "x86_64",
    ["arm"] = "arm7",
    ["arm64"] = "arm64",
  }

  os_name = os_patterns[raw_os]
  arch = arch_patterns[raw_arch]

  return os_name, arch
end

---@class FreezeCodeUtils
---@field get_freeze_filename function: Get the filename for the release (e.g. freeze_<version>_<os>_<arch>)
M.get_freeze_filename = function()
  local os_name, arch = M.get_os_info()

  if os_name == nil or arch == nil then
    vim.notify("os not supported or could not be parsed", vim.log.levels.ERROR, { title = "Freeze" })
    return ""
  end
  local filename = "freeze_" .. freeze_version .. "_" .. os_name .. "_" .. arch
  return filename
end

---@class FreezeCodeUtils
---@field check_executable function: Check if the executable is available
---@param cmd string: Command to check
---@param path_to_check string: Path to check
---@return boolean success: true if executes, false otherwise
M.check_executable = function(cmd, path_to_check)
  if vim.fn.executable(cmd) == 0 then
    M.logger.err_fmt(
      "[freeze-code] could not execute `" .. cmd .. "` binary in path=`%s` . make sure you have the right config",
      path_to_check
    )
    return false
  end
  return true
end

---@class FreezeCodeUtils
---@field os FreezeCodeOS
M.os = {
  is_win = vim.loop.os_uname().version:match("Windows"),
  is_macos = vim.loop.os_uname().version:match("Darwin"),
  is_unix = vim.loop.os_uname().version:match("Linux"),
}

return M
