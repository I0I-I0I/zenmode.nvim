# zenmode.nvim

A simple zenmode plugin for Neovim.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
local M = { "i0i-i0i/zenmode.nvim" }

M.cmd = {
    "ZenmodeToggle",
    "ZenmodeClose",
    "ZenmodeOpen"
}

---@class Opts
---@field default_width integer
---@field toggle_opts table | nil
---@filed untouchable_side_bufs boolean
---@field on_open fun()
---@field on_close fun()
M.opts = {
    default_width = 30,
    untouchable_side_bufs = true,
    toggle_opts = {
        nu = false,
        rnu = false,
        laststatus = 0,
        signcolumn = "no"
    },
    on_open = function()
        vim.cmd("GitGutterDisable")
    end,
    on_close = function()
        vim.cmd("GitGutterEnable")
    end
}

M.keys = function()
    ---@class Buitlin
    ---@field toggle fun(input_width: integer | nil)
    ---@field open fun(input_width: integer | nil)
    ---@field close fun()
    local builtin = require("zenmode.nvim").builtin()

    return {
        { "<leader>z", function() builtin.toggle() end, { silent = true } },
    }
end

return M
```

## TODOS

- [ ] ignore
- [ ] backdrop
