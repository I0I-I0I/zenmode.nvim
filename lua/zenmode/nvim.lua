---@class Opts
---@field default_width number
---@field toggle_vals table | nil

---@class Windows
---@field H integer
---@field L integer

local M = {}

---@type Windows[]
local tabs = {}

---@type Opts
local opts = {
    default_width = 30
}

local utils = require("zenmode.utils")

---@param user_opts Opts | {}
function M.setup(user_opts)
    if not user_opts then
        user_opts = {}
    end

    opts.default_width = user_opts.default_width or opts.default_width
    opts.toggle_vals = user_opts.toggle_vals or opts.toggle_vals

    vim.api.nvim_create_user_command("ZenmodeToggle", function(input)
        M.zenmode_toggle(tonumber(input.fargs[1]))
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("ZenmodeClose", function()
        M.zenmode_close()
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("ZenmodeOpen", function(input)
        M.zenmode_close()
        M.zenmode_open(tonumber(input.fargs[1]))
    end, { nargs = "?" })
end

---@param input_width integer | nil
function M.zenmode_open(input_width)
    if #tabs ~= 0 then
        return
    end

    input_width = input_width or opts.default_width

    local start_tab = vim.api.nvim_get_current_tabpage()
    local editor_tabs = vim.api.nvim_list_tabpages()

    for _, current_tab in pairs(editor_tabs) do
        vim.api.nvim_set_current_tabpage(current_tab)
        tabs[current_tab] = utils.zenmode_open_one(input_width)
    end

    vim.api.nvim_set_current_tabpage(start_tab)
end

function M.zenmode_close()
    if #tabs == 0 then
        return
    end

    for tab, _ in pairs(tabs) do
        utils.zenmode_close_one(tabs[tab])
        tabs[tab] = nil
    end
end

---@param input_width number | nil
function M.zenmode_toggle(input_width)
    if #tabs == 0 then
        M.zenmode_open(input_width)
    else
        M.zenmode_close()
    end
end

function M.builtins()
    return {
        toggle = M.zenmode_toggle,
        open = M.zenmode_open,
        close = M.zenmode_close,
    }
end

return {
    setup = M.setup,
    builtins = M.builtins
}
