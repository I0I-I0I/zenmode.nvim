---@class Opts
---@field default_width integer
---@field toggle_opts table | nil
---@field untouchable_side_bufs boolean
---@field on_open fun()
---@field on_close fun()

---@class Buitlin
---@field toggle fun(input_width: integer | nil)
---@field open fun(input_width: integer | nil)
---@field close fun()

local M = {}

---@type Opts
local opts = {
    default_width = 30,
    untouchable_side_bufs = true,
    on_open = function() end,
    on_close = function() end
}

local utils = require("zenmode.utils")
local Tabs = require("zenmode.tabs")

local saved_opts = {}

---@param user_opts Opts | {}
function M.setup(user_opts)
    if not user_opts then
        user_opts = {}
    end

    opts = vim.tbl_deep_extend("force", opts, user_opts)

    vim.api.nvim_create_user_command("ZenmodeToggle", function(input)
        M.zenmode_toggle(tonumber(input.fargs[1]))
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("ZenmodeClose", function()
        M.zenmode_close()
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("ZenmodeOpen", function(input)
        M.zenmode_open(tonumber(input.fargs[1]))
    end, { nargs = "?" })

    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            saved_opts = utils.save_opts(opts.toggle_opts)
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

    vim.api.nvim_create_autocmd("WinNew", {
        callback = function()
            vim.schedule(function()
                local current_tab = vim.api.nvim_get_current_tabpage()
                Tabs.update(current_tab)
            end)
        end
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        callback = function()
            vim.schedule(function()
                local current_tab = vim.api.nvim_get_current_tabpage()

                Tabs.update(current_tab)

                for _, tab in pairs(Tabs.tabs) do
                    if not vim.api.nvim_win_is_valid(tab.H.winid)
                            or not vim.api.nvim_win_is_valid(tab.L.winid) then
                        M.zenmode_close()
                    end

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
            if not opts.untouchable_side_bufs then return end

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
            if not opts.untouchable_side_bufs then return end

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

---@param input_width integer | nil
function M.zenmode_open(input_width)
    if #Tabs.tabs >= #vim.api.nvim_list_tabpages() then
        return
    end

    opts.on_open()

    input_width = input_width or opts.default_width

    local start_tab = vim.api.nvim_get_current_tabpage()
    local editor_tabs = vim.api.nvim_list_tabpages()

    for _, current_tab in pairs(editor_tabs) do
        if Tabs.include(current_tab) then
            goto continue
        end

        vim.api.nvim_set_current_tabpage(current_tab)
        -- local filetype = vim.bo.filetype
        -- if utils.include(opts.ignore, filetype) then
        --     goto continue
        -- end

        table.insert(Tabs.tabs, utils.zenmode_open_one(input_width))

        ::continue::
    end

    utils.apply_opts(opts.toggle_opts)

    vim.api.nvim_set_current_tabpage(start_tab)
end

function M.zenmode_close()
    if #Tabs.tabs == 0 then
        return
    end

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

    opts.on_close()
end

---@param input_width integer | nil
function M.zenmode_toggle(input_width)
    if #Tabs.tabs < #vim.api.nvim_list_tabpages() then
        M.zenmode_open(input_width)
    else
        M.zenmode_close()
    end
end

---@return Buitlin
function M.builtin()
    return {
        toggle = M.zenmode_toggle,
        open = M.zenmode_open,
        close = M.zenmode_close,
    }
end

return {
    setup = M.setup,
    builtin = M.builtin
}
