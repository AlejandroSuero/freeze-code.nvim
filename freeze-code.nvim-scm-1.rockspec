---@diagnostic disable: lowercase-global
--#selene: allow(unscoped_variables, unused_variable)
local _MODREV, _SPECREV = "scm", "-1"

rockspec_format = "3.0"
package = "freeze-code.nvim"
version = _MODREV .. _SPECREV

description = {
  summary = "A code snapshot plugin using freeze.",
  detailed = [[
    This plugin allows you to take a "screenshot" of your code,
    thanks to freeze by charm.sh.
]],
  homepage = "https://github.com/AlejandroSuero/freeze-code.nvim",
  license = "MIT/X11",
  labels = { "neovim", "snapshot", "screenshot", "freeze" },
}

dependencies = {
  "lua >= 5.1, < 5.4",
  "luassert",
}

source = {
  url = "git://github.com/AlejandroSuero/freeze-code.nvim",
}

build = {
  type = "builtin",
  copy_directories = {
    "doc",
  },
}
