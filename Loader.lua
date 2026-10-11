--[[
    TsumeLibrary Loader
    Repo layout:
        Loader.lua
        Library.lua
        addons/ThemeManager.lua
        addons/SaveManager.lua
        addons/LiquidGlass.lua
        addons/ExecutorUtils.lua
    Example.lua
]]

local repo = "https://raw.githubusercontent.com/bliybubik-stack/TsumeLibrary/refs/heads/main/"

-- Environment helpers first (used by everything else)
local ExecutorUtils = loadstring(game:HttpGet(repo .. "addons/ExecutorUtils.lua"))()

-- Core Obsidian library
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

-- Addons
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local LiquidGlass  = loadstring(game:HttpGet(repo .. "addons/LiquidGlass.lua"))()

-- Hand off to managers immediately
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("TsumeLibrary")
SaveManager:SetFolder("TsumeLibrary/configs")

-- Apply the liquid-glass aesthetic to the library
LiquidGlass:Apply(Library)

-- Return everything so Example.lua can use it
return {
    Library       = Library,
    ThemeManager  = ThemeManager,
    SaveManager   = SaveManager,
    LiquidGlass   = LiquidGlass,
    ExecutorUtils = ExecutorUtils,
}
