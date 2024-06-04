<a name="readme-top"></a>

<div align="center">

[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]

# Freeze Neovim Plugin

Take a "screenshot" of your code by turning it into an image, thanks to
[freeze](https://github.com/charmbracelet/freeze) by [charm](https://charm.sh/).

[Report an issue](https://github.com/AlejandroSuero/freeze-code.nvim/issues/new?assignees=&labels=bug&projects=&template=bug_report.yml&title=%5BBug%5D%3A+)
· [Suggest a feature](https://github.com/AlejandroSuero/freeze-code.nvim/issues/new?assignees=&labels=enhancement&projects=&template=feature_request.md&title=%5BFeat%5D%3A+)

**Remember to always follow the [code of conduct](https://github.com/AlejandroSuero/freeze-code.nvim/blob/main/CODE_OF_CONDUCT.md#contributor-covenant-code-of-conduct)**

</div>

> [!warning]
>
> This plugin requires Neovim v0.9.0 or higher

## Installation

Using your plugin manager at your disposal, in the example
[lazy](https://github.com/folke/lazy.nvim) is going to be used.

> [!note]
>
> If you don't have [freeze](https://github.com/charmbracelet/freeze) installed,
> and you are have [golang](https://go.dev) installed, it will
> `go install github.com/charmbracelet/freeze@latest` for you 🫡.
>
> In the case that you don't have neither of those, don't you worry 😉, we got you
> cover. It will install `freeze` using `cURL` to the
> [freeze's releases page](https://github.com/charmbracelet/freeze/releases).

- Default installation:

```lua
return {
    "AlejandroSuero/freeze-code.nvim",
    config = function()
        require("freeze-code").setup()
    end,
}
```

> [!note]
>
> You can also install it using [Rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim)
>
> `:Rocks install freeze-code.nvim`
>
> Also as `luarocks install freeze-code.nvim`

- Customizable installation:

```lua
return {
    "AlejandroSuero/freeze-code.nvim",
    config = function()
        require("freeze-code.nvim").setup({
            -- your configuration goes here
        })
    end,
}
```

> [!note]
>
> See default configuration below.

```lua
local opts = {
  freeze_path = vim.fn.exepath("freeze"), -- where is freeze installed
  copy_cmd = "gclip", -- the default copy commands `gclip` or native to your OS (see below)
  copy = false, -- copy after screenshot option
  open = false, -- open after screenshot option
  dir = vim.env.PWD, -- where is the image going to be saved "." as default
  freeze_config = { -- configuration options for `freeze` command
    output = "freeze.png",
    config = "base",
    theme = "default",
  },
}
```

> [!note]
>
> The default command will be [gclip](https://github.com/golang-design/clipboard)
> if it is installed, otherwise ...
>
> The commands to copy, as defaults per OS will be, for example, for Windows:
> `Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Clipboard]::SetImage(...)`,
> for Linux: `xclip -selection clipboard -t image/png ...` if is an `X11` session,
> `wl-copy < ...` if is a `Wayland` session, and for MacOS:
> `osascript -e 'to set the clipboard to (read (POSIX file "...") as «class PNGf»)'`.

Once you have it installed, you can use `:checkhealt freeze-code` to see if there
are any problems with the installation or you need to install additional tools.

<div align="right">
  (<a href="#readme-top">Back to top</a>)
</div>

## Usage

To use this plugin, simply call `:Freeze` and it will take a screenshot of the
current buffer and save it in the `dir` path you have configured.

If you want to take a screenshot of a specific line, you can use the `:Freeze` in
visual mode, and it will take a screenshot of the selected lines.

### Keymaps

```lua
vim.keymap.set("n", "<leader>fz", require("freeze-code.api").freeze)
vim.keymap.set("v", "<leader>fz", function()
  require("freeze-code.api").freeze(vim.fn.line("'<"), vim.fn.line("'>"))
end)
-- or using `<cmd>Freeze<cr>`
vim.keymap.set("n", "<leader>fl", require("freeze-code.api").freeze_line)
-- or using `<cmd>FreezeLine<cr>`
```

## Contributing

Thank you to everyone that is contributing and to those who want to contribute.
Any contribution is welcomed!

**Quick guide**:

1. [Fork](https://github.com/AlejandroSuero/freeze-code.nvim/fork) this
   project.
2. Clone your fork (`git clone <fork-URL>`).
3. Add main repo as remote (`git remote add upstream <main-repo-URL>`).
4. Create a branch for your changes (`git switch -c feature/your-feature` or
   `git switch -c fix/your-fix`).
5. Commit your changes (`git commit -m "feat(...): ..."`).
6. Push to your fork (`git push origin <branch-name>`).
7. Open a [PR](https://github.com/AlejandroSuero/freeze-code.nvim/pulls).

For more information, check
[CONTRIBUTING.md](https://github.com/AlejandroSuero/freeze-code.nvim/blob/main/CONTRIBUTING.md).

<div align="right">
  (<a href="#readme-top">Back to top</a>)
</div>

[stars-shield]: https://img.shields.io/github/stars/AlejandroSuero/freeze-code.nvim.svg?style=for-the-badge
[stars-url]: https://github.com/AlejandroSuero/freeze-code.nvim/stargazers
[issues-shield]: https://img.shields.io/github/issues/AlejandroSuero/freeze-code.nvim.svg?style=for-the-badge
[issues-url]: https://github.com/AlejandroSuero/freeze-code.nvim/issues
