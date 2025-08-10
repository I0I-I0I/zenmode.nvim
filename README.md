# zenmode.nvim

A distraction-free mode for Neovim, designed to keep you focused.

## Features

- Centers the editor with customizable width.
- Hides UI elements like the statusline, number column, and more for a clean look.
- Preserves your existing window layout.
- Highly configurable with Lua.
- Extensible with callbacks to run your own custom logic.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "i0i-i0i/zenmode.nvim",
  config = function()
    require("zenmode").setup({
      -- your configuration comes here
      -- or leave it empty to use the default settings
    })
  end,
}
```

## Configuration

Here is an example of a more complete configuration with the default values:

```lua
require("zenmode").setup({
  window = {
    options = {
      -- These are the Neovim options that will be changed when Zen Mode is toggled.
      -- You can add any option here and it will be restored when you exit Zen Mode.
      number = false,
      relativenumber = false,
      cursorline = false,
      cursorcolumn = false,
      foldcolumn = "0",
      list = false,
      signcolumn = "no",
      statusline = "",
    }
  },
  default_width = 30,
  untouchable_side_bufs = true,
  -- You can override the default callbacks here
  on_before_open = function() end,
  on_after_open = function()
    -- Example: disable git-related plugins when entering Zen Mode
    vim.cmd("GitGutterDisable")
  end,
  on_before_close = function() end,
  on_after_close = function()
    -- Example: re-enable git-related plugins when exiting Zen Mode
    vim.cmd("GitGutterEnable")
  end,
})
```

### Callbacks

The following callbacks are available to hook into the Zen Mode lifecycle:

- `on_before_open`: Called just before Zen Mode is opened.
- `on_after_open`: Called after Zen Mode is fully opened.
- `on_before_close`: Called just before Zen Mode is closed.
- `on_after_close`: Called after Zen Mode is fully closed.

## Usage

The plugin provides the following commands:

- `:ZenmodeToggle`: Toggle Zen Mode.
- `:ZenmodeOpen`: Open Zen Mode.
- `:ZenmodeClose`: Close Zen Mode.

You can also use the built-in functions to create your own keymappings:

```lua
local builtin = require("zenmode").builtin()

vim.keymap.set("n", "<leader>z", function()
  builtin.toggle()
end, { silent = true, desc = "Toggle Zen Mode" })
-- vim.keymap.set("n", "<leader>zo", function()
--   builtin.open()
-- end, { silent = true, desc = "Toggle Zen Mode" })
-- vim.keymap.set("n", "<leader>zc", function()
--   builtin.close()
-- end, { silent = true, desc = "Toggle Zen Mode" })
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
