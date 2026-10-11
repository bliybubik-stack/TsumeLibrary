--[[
    LiquidGlass.lua
    Applies a translucent "liquid glass" aesthetic to an Obsidian library.

    This does NOT try to do real refraction/EditableImage blur —
    that is unreliable in executor CoreGui overlays. Instead it
    gives a convincing frosted-glass look using:
        - lower frame background transparency
        - a gradient overlay on the main window
        - rounded corners
        - a thin highlight stroke
        - a subtle drop shadow

    Usage:
        local LiquidGlass = loadstring(...)()
        LiquidGlass:Apply(Library)
]]

local LiquidGlass = {}

-- Configurable palette
LiquidGlass.Config = {
    WindowTransparency  = 0.12,          -- main window background alpha
    ElementTransparency = 0.18,          -- groupbox / element alpha
    CornerRadius        = 10,
    BorderColor         = Color3.fromRGB(180, 200, 255),
    BorderTransparency  = 0.75,
    ShadowTransparency  = 0.55,
    TintTop             = Color3.fromRGB(40, 45, 65),
    TintBottom          = Color3.fromRGB(15, 18, 28),
    UseGradient         = true,
}

local function findFirstParent(instance, className, maxDepth)
    maxDepth = maxDepth or 6
    local current = instance
    local depth = 0
    while current and depth < maxDepth do
        if current.ClassName == className then return current end
        current = current.Parent
        depth = depth + 1
    end
    return nil
end

local function addCorner(frame, radius)
    local corner = frame:FindFirstChildOfClass("UICorner")
    if not corner then
        corner = Instance.new("UICorner")
        corner.Parent = frame
    end
    corner.CornerRadius = UDim.new(0, radius)
    return corner
end

local function addStroke(frame, color, transparency, thickness)
    local stroke = frame:FindFirstChild("LiquidGlassStroke")
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Name = "LiquidGlassStroke"
        stroke.Parent = frame
    end
    stroke.Color = color
    stroke.Transparency = transparency
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return stroke
end

local function addGradient(frame, top, bottom)
    local gradient = frame:FindFirstChild("LiquidGlassGradient")
    if not gradient then
        gradient = Instance.new("UIGradient")
        gradient.Name = "LiquidGlassGradient"
        gradient.Rotation = 90
        gradient.Parent = frame
    end
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, top),
        ColorSequenceKeypoint.new(1, bottom),
    })
    return gradient
end

local function addShadow(frame)
    -- Simple fake shadow using a slightly offset, dark, blurred ImageLabel.
    -- Skipped if the frame already has one.
    if frame:FindFirstChild("LiquidGlassShadow") then return end
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "LiquidGlassShadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993" -- generic soft shadow
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = LiquidGlass.Config.ShadowTransparency
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.ZIndex = frame.ZIndex - 1
    shadow.Parent = frame
end

function LiquidGlass:Apply(Library)
    if not Library then
        warn("[LiquidGlass] No Library passed to :Apply()")
        return
    end

    local cfg = self.Config

    -- The main window is Library.Window (or Library.MainWindow depending on version)
    local window = Library.Window or Library.MainWindow
    if not window then
        warn("[LiquidGlass] Could not find main window on Library.")
        return
    end

    -- Find the root frame of the window. In Obsidian it's usually a Frame
    -- named "Main" or "Window" inside the ScreenGui.
    local root = window
    if typeof(root) ~= "Instance" then
        -- If it's an object with a .Toplevel or .Main property, dig in
        root = root.Toplevel or root.Main or root.Frame
    end

    if not root or typeof(root) ~= "Instance" then
        warn("[LiquidGlass] Could not resolve window root instance.")
        return
    end

    -- Apply to root
    addCorner(root, cfg.CornerRadius)
    addStroke(root, cfg.BorderColor, cfg.BorderTransparency, 1)
    addShadow(root)

    if cfg.UseGradient then
        -- Only add gradient if the root is a Frame (ImageLabels don't take UIGradient the same way)
        if root:IsA("Frame") or root:IsA("ImageLabel") then
            addGradient(root, cfg.TintTop, cfg.TintBottom)
        end
    end

    -- Lower transparency on the root and its direct children that look like panels.
    -- We walk a couple of levels deep and tint every Frame that has a solid background.
    local function styleFrame(frame)
        if not frame:IsA("Frame") and not frame:IsA("ImageLabel") then return end
        if frame == root then return end

        -- Skip tiny frames (separators, dots, etc.)
        if frame.AbsoluteSize.X < 20 or frame.AbsoluteSize.Y < 20 then return end

        -- Lower transparency slightly, but never above the config value
        if frame.BackgroundTransparency < 1 then
            frame.BackgroundTransparency = math.max(
                frame.BackgroundTransparency,
                cfg.ElementTransparency
            )
        end

        addCorner(frame, math.max(4, cfg.CornerRadius - 4))
    end

    -- Two passes to reach groupboxes / tabs / elements
    for _, child in ipairs(root:GetDescendants()) do
        styleFrame(child)
    end

    -- Expose a method to re-apply on newly created elements
    function LiquidGlass:StyleNew(element)
        styleFrame(element)
    end

    -- Hook window visibility so we can re-apply after animations settle
    if root:IsA("GuiObject") then
        root:GetPropertyChangedSignal("Visible"):Connect(function()
            if root.Visible then
                task.wait(0.05)
                for _, child in ipairs(root:GetDescendants()) do
                    styleFrame(child)
                end
            end
        end)
    end

    return self
end

return LiquidGlass
