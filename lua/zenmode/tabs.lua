---@class Win
---@field bufid integer
---@field winid integer

---@class Tab
---@field M Win[]
---@field H Win
---@field L Win
---@field id integer

local M = {}

local utils = require("zenmode.utils")

---@type Tab[]
M.tabs = {}

---@param tab_id integer
---@return boolean
function M.include(tab_id)
    for _, tab in pairs(M.tabs) do
        if tab.id == tab_id then
            return true
        end
    end
    return false
end

---@param tab_id integer
---@return { idx: integer, tab: Tab } | nil
function M.get(tab_id)
    for idx, tab in pairs(M.tabs) do
        if tab.id == tab_id then
            return {
                idx = idx,
                tab = tab
            }
        end
    end
end

---@param editor_tabs integer[]
function M.update_all(editor_tabs)
    for idx, tab in pairs(M.tabs) do
        if not utils.include(editor_tabs, tab.id) then
            table.remove(M.tabs, idx)
        end
    end
end

---@param tabid integer
---@return Tab | nil
function M.update(tabid)
    ---@type Tab | nil
    local current_tab = nil

    for _, tab in pairs(M.tabs) do
        if tab.id == tabid then
            current_tab = tab
        end
    end

    if not current_tab then
        return
    end

    local new_tab_info = utils.update_tab_info(current_tab)

    for idx, tab in pairs(M.tabs) do
        if tab.id == new_tab_info.id then
            M.tabs[idx] = new_tab_info
        end
    end
end

return M
