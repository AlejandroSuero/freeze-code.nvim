<a name="readme-top"></a>

<div align="center">

# Freeze NeoVim Plugin

Take a "screenshot" of your code by turning it into an image, thanks to
[freeze](https://github.com/charmbracelet/freeze) by [charm](https://charm.sh/).

[Report an issue](https://github.com/AlejandroSuero/freeze-code.nvim/issues/new?assignees=&labels=bug&projects=&template=bug_report.yml&title=%5BBug%5D%3A+)
· [Suggest a feature](https://github.com/AlejandroSuero/freeze-code.nvim/issues/new?assignees=&labels=enhancement&projects=&template=feature_request.md&title=%5BFeat%5D%3A+)

</div>

## Installation

Using your plugin manager at your disposal, in the example
[lazy](https://github.com/folke/lazy.nvim) is going to be used.

- Default installation:

```lua
return {
    "AlejandroSuero/freeze-code.nvim",
    config = function()
        require("freeze-code").setup()
    end,
}
```

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
> See default configuration below.

```lua
---@class FreezeConfig
---@field output string|"freeze.png": Freeze output filename `--output "freeze.png"`
---@field theme string|"default": Freeze theme `--theme "default"`
---@field config string|"base": Freeze configuration `--config "base"`

---@class CodeSnapshotConfig
---@field freeze_path string: Path to `freeze` executable
---@field copy_cmd string: Path to copy `image/png` to clipboard command
---@field copy boolean: Open image after creation option
---@field open boolean: Open image after creation option
---@field dir string: Directory to create image
---@field freeze_config FreezeConfig

---@type CodeSnapshotConfig
local opts = {
  freeze_path = vim.fn.exepath("freeze"), -- where is freeze installed
  copy_cmd = "pngcopy", -- the default copy commands are in the bin directory
  copy = false,
  open = false,
  dir = vim.env.PWD,
  freeze_config = {
    output = "freeze.png",
    config = "base",
    theme = "default",
  },
}
```

> [!note]
> The commands to copy, as defaults per OS will be in the
> [bin-directory](https://github.com/AlejandroSuero/freeze-code.nvim/blob/main/bin)

Once you have it installed, you can use `:checkhealt freeze-code` to see if there
are any problems with the installation or you need to install aditional tools.

<div align="right">
  (<a href="#readme-top">Back to top</a>)
</div>

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
[CONTRIBUTING.md](https://github.com/AlejandroSuero/freeze-code.nvim/blob/main/contrib/CONTRIBUTING.md).

<div align="right">
  (<a href="#readme-top">Back to top</a>)
</div>
