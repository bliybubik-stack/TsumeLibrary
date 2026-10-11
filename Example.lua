--[[
    Liquid Obsidian — Example script
    Uses Loader.lua for the core, ThemeManager, SaveManager, LiquidGlass.
    Drop this into any executor and run it.
]]

local repo = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/"

-- Load the bundle
local Bundle = loadstring(game:HttpGet(repo .. "Loader.lua"))()
local Library       = Bundle.Library
local ThemeManager  = Bundle.ThemeManager
local SaveManager   = Bundle.SaveManager
local LiquidGlass   = Bundle.LiquidGlass
local ExecutorUtils = Bundle.ExecutorUtils

local Options = Library.Options
local Toggles = Library.Toggles

-- Notify the user which executor we detected
Library:Notify({
    Title = "Liquid Obsidian",
    Description = "Executor: " .. ExecutorUtils.GetExecutorName(),
    Time = 4,
})

-- Window
local Window = Library:CreateWindow({
    Title = "Liquid Obsidian",
    Footer = "v1.0 — glass edition",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
    Center = true,
    AutoShow = true,
})

-- Tabs
local Tabs = {
    Main        = Window:AddTab("Main", "user"),
    Key         = Window:AddKeyTab("Key System"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- === Main tab: left column ===
local LeftGroupBox = Tabs.Main:AddGroupbox({
    Side = "Left",
    Name = "Features",
    Description = "liquid glass demo",
    IconName = "sparkles",
})

LeftGroupBox:AddToggle("MyToggle", {
    Text = "Enable feature",
    Tooltip = "Toggles a demo feature",
    Default = true,
    Callback = function(Value)
        print("[cb] MyToggle:", Value)
    end,
}):AddColorPicker("ColorPicker1", {
    Default = Color3.fromRGB(120, 180, 255),
    Title = "Accent color",
})

LeftGroupBox:AddCheckbox("MyCheckbox", {
    Text = "Checkbox demo",
    Default = true,
})

LeftGroupBox:AddSlider("MySlider", {
    Text = "Intensity",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = "%",
})

LeftGroupBox:AddInput("MyTextbox", {
    Default = "hello world",
    Text = "Text input",
    Placeholder = "type here…",
    ClearTextOnFocus = false,
})

LeftGroupBox:AddButton({
    Text = "Notify me",
    Func = function()
        Library:Notify({
            Title = "Notification",
            Description = "You clicked the button!",
            Time = 3,
        })
    end,
    Tooltip = "Sends a notification",
})

LeftGroupBox:AddDivider()

LeftGroupBox:AddLabel("Keybind"):AddKeyPicker("MyKeybind", {
    Default = "K",
    Mode = "Toggle",
    Text = "Toggle feature",
    Callback = function(Value)
        print("[cb] Keybind:", Value)
    end,
})

-- === Main tab: right column ===
local RightGroupBox = Tabs.Main:AddGroupbox({
    Side = "Right",
    Name = "Selection",
    IconName = "list",
})

RightGroupBox:AddDropdown("MyDropdown", {
    Values = { "Alpha", "Beta", "Gamma", "Delta" },
    Default = 1,
    Multi = false,
    Text = "Choose one",
    Searchable = false,
})

RightGroupBox:AddDropdown("MyMultiDropdown", {
    Values = { "ESP", "Aimbot", "Fly", "Speed" },
    Default = 1,
    Multi = true,
    Text = "Choose many",
})

RightGroupBox:AddDropdown("PlayerDropdown", {
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
    Text = "Player",
})

-- === Tabbox ===
local TabBox = Tabs.Main:AddRightTabbox()
local Tab1 = TabBox:AddTab("Tab 1")
Tab1:AddToggle("Tab1Toggle", { Text = "Tab1 toggle" })
local Tab2 = TabBox:AddTab("Tab 2")
Tab2:AddToggle("Tab2Toggle", { Text = "Tab2 toggle" })

-- === Key tab ===
Tabs.Key:AddLabel({
    Text = "Key: Banana",
    DoesWrap = true,
    Size = 16,
})
Tabs.Key:AddKeyBox(function(ReceivedKey)
    local Success = ReceivedKey == "Banana"
    Library:Notify({
        Title = "Key Check",
        Description = "Received: " .. ReceivedKey .. "\nSuccess: " .. tostring(Success),
        Time = 4,
    })
end)

-- === UI Settings tab ===
local MenuGroup = Tabs["UI Settings"]:AddGroupbox({
    Side = "Left",
    Name = "Menu",
    IconName = "wrench",
})

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open keybind menu",
    Callback = function(v) Library.KeybindFrame.Visible = v end,
})

MenuGroup:AddToggle("AlwaysOnTop", {
    Text = "Always on top",
    Default = Window.AlwaysOnTop,
    Callback = function(v) Window:SetAlwaysOnTop(v) end,
})

MenuGroup:AddSlider("GlassTransparency", {
    Text = "Glass transparency",
    Default = math.floor(LiquidGlass.Config.ElementTransparency * 100),
    Min = 0,
    Max = 90,
    Rounding = 0,
    Suffix = "%",
    Callback = function(v)
        LiquidGlass.Config.ElementTransparency = v / 100
        LiquidGlass:Apply(Library)
    end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind",
})

MenuGroup:AddButton({
    Text = "Unload",
    Func = function() Library:Unload() end,
})

Library.ToggleKeybind = Options.MenuKeybind

-- === SaveManager / ThemeManager ===
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()

-- Re-apply glass after managers build their UI
task.defer(function()
    task.wait(0.2)
    LiquidGlass:Apply(Library)
end)

Library:OnUnload(function()
    print("[LiquidObsidian] Unloaded.")
end)
