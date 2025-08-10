---@class Opts
---@field window table
---@field default_width integer
---@field untouchable_side_bufs boolean
---@field excluded_filetypes table<string, boolean>
---@field on_before_open fun()
---@field on_after_open fun()
---@field on_before_close fun()
---@field on_after_close fun()

---@class Builtin
---@field toggle fun(input_width: integer | nil)
---@field open fun(input_width: integer | nil)
---@field close fun()

local M = {}

---@type Opts
local opts = {
    window = {
        options = {
            number = false,
            relativenumber = false,
            cursorline = false,
            cursorcolumn = false,
            foldcolumn = "0",
            list = false,
            showtabline = 0,
            signcolumn = "no",
            statusline = "",
        }
    },
    default_width = 30,
    untouchable_side_bufs = true,
    excluded_filetypes = {
        cmd = true,
        pager = true,
        qf = true,
        dialog = true,
        msg = true,
    },
    on_before_open = function() end,
    on_after_open = function() end,
    on_before_close = function() end,
    on_after_close = function() end,
}

local utils = require("zenmode.utils")
local Tabs = require("zenmode.tabs")

local saved_opts = {}

local function _create_autocmds()
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            saved_opts = utils.save_opts(M.opts.window.options)
        end
    })

    vim.api.nvim_create_autocmd("TabNew", {
        callback = function()
            if #Tabs.tabs ~= 0 then
                M.zenmode_open()
            end
        end
    })

    vim.api.nvim_create_autocmd("TabClosed", {
        callback = function()
            Tabs.update_all()
        end
    })

    vim.api.nvim_create_autocmd("TabEnter", {
        callback = function()
            for _, tabid in pairs(vim.api.nvim_list_tabpages()) do
                local current_tab = Tabs.get(tabid)

                if not current_tab then return end

                current_tab = current_tab.tab

                if not vim.api.nvim_win_is_valid(current_tab.H.winid)
                    or not vim.api.nvim_win_is_valid(current_tab.L.winid) then
                    M.zenmode_close()
                    M.zenmode_open(opts.default_width)
                    Tabs.update(tabid)
                end
            end
        end
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        callback = function()
            vim.schedule(function()
                local current_tab = vim.api.nvim_get_current_tabpage()
                Tabs.update(current_tab)

                for _, tab in pairs(Tabs.tabs) do
                    if #tab.M > 1 then
                        goto continue
                    end

                    if #tab.M == 0 then
                        utils.zenmode_close_one(tab)
                        Tabs.update_all()
                    end

                    ::continue::
                end
            end)
        end
    })

    M.window = 0

    vim.api.nvim_create_autocmd("WinLeave", {
        callback = function()
            if not M.opts.untouchable_side_bufs then return end

            local current_win = vim.api.nvim_get_current_win()
            local tabid = vim.api.nvim_get_current_tabpage()

            Tabs.update(tabid)

            local tab = Tabs.tabs[tabid]
            if not tab or not tab.H or not tab.L then
                return
            end

            if tab.H.winid == current_win or tab.L.winid == current_win then
                return
            end

            M.window = current_win
        end
    })

    vim.api.nvim_create_autocmd("WinEnter", {
        callback = function()
            if not M.opts.untouchable_side_bufs then return end

            local current_win = vim.api.nvim_get_current_win()
            local tabid = vim.api.nvim_get_current_tabpage()

            local tab = Tabs.tabs[tabid]
            if not tab or not tab.H or not tab.L then
                return
            end

            if tab.H.winid == current_win or tab.L.winid == current_win then
                if not vim.api.nvim_win_is_valid(M.window) then
                    return
                end
                vim.api.nvim_set_current_win(M.window)
            end
        end
    })
end

---@param user_opts Opts | {}
function M.setup(user_opts)
    if not user_opts then
        user_opts = {}
    end

    M.opts = vim.tbl_deep_extend("force", opts, user_opts)

    vim.api.nvim_create_user_command("ZenmodeToggle", function(input)
        M.zenmode_toggle(tonumber(input.fargs[1]))
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("ZenmodeClose", function()
        M.zenmode_close()
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("ZenmodeOpen", function(input)
        M.zenmode_open(tonumber(input.fargs[1]))
    end, { nargs = "?" })

    _create_autocmds()
end

---@param input_width integer | nil
function M.zenmode_open(input_width)
    if #Tabs.tabs >= #vim.api.nvim_list_tabpages() then
        return
    end

    M.opts.on_before_open()

    input_width = input_width or M.opts.default_width

    local start_tab = vim.api.nvim_get_current_tabpage()
    local editor_tabs = vim.api.nvim_list_tabpages()

    for _, current_tab in pairs(editor_tabs) do
        if Tabs.include(current_tab) then
            goto continue
        end

        vim.api.nvim_set_current_tabpage(current_tab)
        -- local filetype = vim.bo.filetype
        -- if utils.include(M.opts.ignore, filetype) then
        --     goto continue
        -- end

        local win = utils.zenmode_open_one(input_width)
        table.insert(Tabs.tabs, win)

        ::continue::
    end

    utils.apply_opts(M.opts.window.options)

    vim.api.nvim_set_current_tabpage(start_tab)

    M.opts.on_after_open()
end

function M.zenmode_close()
    if #Tabs.tabs == 0 then
        return
    end

    M.opts.on_before_close()

    local start_tab = vim.api.nvim_get_current_tabpage()
    local editor_tabs = vim.api.nvim_list_tabpages()

    for _, current_tab in pairs(editor_tabs) do
        local tab = Tabs.get(current_tab)
        if not tab then
            goto continue
        end

        vim.api.nvim_set_current_tabpage(current_tab)
        utils.zenmode_close_one(tab.tab)
        Tabs.tabs[tab.idx] = nil

        ::continue::
    end

    utils.apply_opts(saved_opts)

    Tabs.tabs = {}
    if vim.api.nvim_tabpage_is_valid(start_tab) then
        vim.api.nvim_set_current_tabpage(start_tab)
    end

    M.opts.on_after_close()
end

---@param input_width integer | nil
function M.zenmode_toggle(input_width)
    if #Tabs.tabs < #vim.api.nvim_list_tabpages() then
        M.zenmode_open(input_width)
    else
        M.zenmode_close()
    end
end

---@return Builtin
function M.builtin()
    return {
        toggle = M.zenmode_toggle,
        open = M.zenmode_open,
        close = M.zenmode_close,
    }
end

---@return Opts
function M.get_opts()
    return M.opts
end

return {
    setup = M.setup,
    builtin = M.builtin,
    get_opts = M.get_opts
}
