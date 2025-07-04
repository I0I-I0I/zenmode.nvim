---@class Tab
---@field M integer
---@field H integer
---@field L integer
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
function M.update(editor_tabs)
    for idx, tab in pairs(M.tabs) do
        if not utils.include(editor_tabs, tab.id) then
            table.remove(M.tabs, idx)
        end
    end
end

return M
