local M = {}

function M.save_opts(opts)
    local saved_opts = {}
    for opt, _ in pairs(opts) do
        saved_opts[opt] = vim.opt[opt]
    end
    return saved_opts
end

function M.apply_opts(opts)
    for opt, value in pairs(opts) do
        vim.opt[opt] = value
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
local function create_window(width, direction)
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

---@param width integer
---@return Tab
function M.zenmode_open_one(width)
    local cur_win = vim.fn.win_getid()

    ---@type Tab
    local tab = {
        M = cur_win,
        H = create_window(width, "H"),
        L = create_window(width, "L"),
        id = vim.api.nvim_get_current_tabpage()
    }

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
    vim.api.nvim_win_close(tab.H, true)
    vim.api.nvim_win_close(tab.L, true)
end

return M
