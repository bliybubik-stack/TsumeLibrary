--[[
    ExecutorUtils.lua
    Small shim so the library works across the popular executors.
    Returns a table with useful helpers.
]]

local Utils = {}

-- Environment table
Utils.env = (function()
    if getgenv then return getgenv() end
    if getrenv then return getrenv() end
    return _G
end)()

-- HTTP request fallback chain
Utils.HttpRequest = (function()
    if syn and syn.request then return syn.request end
    if http and http.request then return http.request end
    if http_request then return http_request end
    if request then return request end
    return function(tbl)
        warn("[ExecutorUtils] No HTTP request function available.")
        return nil
    end
end)()

-- Clipboard
Utils.SetClipboard = (function()
    if setclipboard then return setclipboard end
    if toclipboard then return toclipboard end
    if syn and syn.set_clipboard then return syn.set_clipboard end
    return function(text) warn("[ExecutorUtils] No clipboard function. Text was: " .. tostring(text)) end
end)()

-- Identity / executor name (best-effort)
Utils.GetExecutorName = (function()
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok then return name end
    end
    return "Unknown"
end)()

-- Whether a real executor environment exists (vs. Studio)
Utils.IsExecutor = (function()
    return Utils.GetExecutorName() ~= "Unknown"
end)()

-- Safe require for Roblox services
function Utils.GetService(name)
    return game:GetService(name)
end

return Utils
