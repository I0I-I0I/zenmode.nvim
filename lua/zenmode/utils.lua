local M = {}

function M.save_opts(opts)
    local saved_opts = {}
    for opt, _ in pairs(opts) do
        saved_opts[opt] = vim.opt[opt]
    end
    return saved_opts
end

---@param opts table<string, any>
function M.apply_opts(opts)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if filetype == "" then
            goto continue
        end

        for opt, value in pairs(opts) do
            vim.api.nvim_set_current_win(win)
            vim.opt[opt] = value
        end

        ::continue::
    end
end

---@param arr any[]
---@param val any
---@return boolean
function M.include(arr, val)
    for _, value in pairs(arr) do
        if val == value then
            return true
        end
    end
    return false
end

---@param width integer
---@param direction string
---@return integer
local function create_scratch_window(width, direction)
    vim.cmd("vsp")
    vim.cmd("wincmd " .. direction)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.cmd("buffer " .. buf)

    local win = vim.api.nvim_get_current_win()

    local opts = {
        scope = "local",
        win = win,
    }

    vim.api.nvim_win_set_width(win, width)
    vim.api.nvim_set_option_value("winfixwidth", true, opts)
    vim.api.nvim_set_option_value("cursorline", false, opts)
    vim.api.nvim_set_option_value("winfixbuf", true, opts)
    vim.api.nvim_set_option_value("numberwidth", 1, opts)
    vim.api.nvim_set_option_value("number", false, opts)
    vim.api.nvim_set_option_value("relativenumber", false, opts)
    vim.api.nvim_set_option_value("fillchars", "eob: ,vert: ", opts)

    return win
end

---@param current_tab integer
---@param H_win integer
---@param L_win integer
---@return Tab
local function get_tab_info(current_tab, H_win, L_win)
    ---@type Win[]
    local centred_wins = {}
    for _, win in pairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
        if win == H_win or win == L_win then goto continue end
        table.insert(centred_wins, {
            winid = win,
            bufid = vim.api.nvim_win_get_buf(win),
        })

        ::continue::
    end

    ---@type Tab
    local tab = {
        M = centred_wins,
        H = {
            winid = H_win,
            bufid = vim.api.nvim_win_get_buf(H_win)
        },
        L = {
            winid = L_win,
            bufid = vim.api.nvim_win_get_buf(L_win)
        },
        id = current_tab
    }

    return tab
end

---@param old_tab_info Tab
---@return Tab
function M.update_tab_info(old_tab_info)
    ---@type Win[]
    local centred_wins = {}
    for _, win in pairs(vim.api.nvim_tabpage_list_wins(old_tab_info.id)) do
        if win == old_tab_info.L.winid or win == old_tab_info.H.winid then
            goto continue
        end
        table.insert(centred_wins, {
            winid = win,
            bufid = vim.api.nvim_win_get_buf(win),
        })

        ::continue::
    end

    ---@type Tab
    local tab = {
        M = centred_wins,
        H = old_tab_info.H,
        L = old_tab_info.L,
        id = old_tab_info.id
    }

    return tab
end

---@param width integer
---@return Tab
function M.zenmode_open_one(width)
    local cur_win = vim.fn.win_getid()

    local H_win = create_scratch_window(width, "H")
    local L_win = create_scratch_window(width, "L")
    local current_tab = vim.api.nvim_get_current_tabpage()

    local tab = get_tab_info(current_tab, H_win, L_win)

    vim.api.nvim_set_option_value(
        "fillchars",
        "vert: ",
        {
            scope = "global",
            win = cur_win
        }
    )

    vim.api.nvim_set_current_win(cur_win)

    return tab
end

---@param tab Tab
function M.zenmode_close_one(tab)
    if vim.api.nvim_win_is_valid(tab.H.winid) then
        vim.api.nvim_win_close(tab.H.winid, true)
    end
    if vim.api.nvim_win_is_valid(tab.L.winid) then
        local ok, _ = pcall(vim.api.nvim_win_close, tab.L.winid, true)
        if not ok then
            vim.cmd("split")
            vim.api.nvim_set_current_buf(vim.fn.bufnr("#"))
            vim.api.nvim_win_close(tab.L.winid, true)
        end
    end
end

return M

