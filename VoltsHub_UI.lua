--[[
    Volts Hub UI
    BloxStrike | Mobile Friendly | Smooth Animations
    Tabs: Aim, Visuals, Movement, Gun, Chams, Info
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

-- ====================== CONFIG ======================
local Config = {
    Name = "Volts Hub",
    Accent = Color3.fromRGB(0, 200, 255),
    Accent2 = Color3.fromRGB(255, 90, 40),
    Background = Color3.fromRGB(16, 16, 20),
    Secondary = Color3.fromRGB(26, 26, 32),
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(150, 150, 165),
    Success = Color3.fromRGB(80, 220, 120),
    Danger = Color3.fromRGB(255, 80, 80),
}

-- ====================== MAIN GUI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoltsHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Window
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 340, 0, 430)
Main.Position = UDim2.new(0.5, -170, 0.5, -215)
Main.BackgroundColor3 = Config.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

-- Glow / Fire Border
local Glow = Instance.new("UIStroke")
Glow.Name = "Glow"
Glow.Color = Color3.fromRGB(255, 255, 255)
Glow.Thickness = 2.4
Glow.Transparency = 0.1
Glow.Parent = Main

local FireGradient = Instance.new("UIGradient")
FireGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Config.Accent2),
    ColorSequenceKeypoint.new(0.25, Config.Accent),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 200, 50)),
    ColorSequenceKeypoint.new(0.75, Config.Accent),
    ColorSequenceKeypoint.new(1.00, Config.Accent2)
})
FireGradient.Rotation = 0
FireGradient.Parent = Glow

-- Rotate fire effect
task.spawn(function()
    while Main and Main.Parent do
        for i = 0, 360, 2 do
            if not Main or not Main.Parent then break end
            FireGradient.Rotation = i
            task.wait(0.03)
        end
    end
end)

-- ====================== TITLE BAR ======================
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Config.Secondary
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 18)
TitleFix.Position = UDim2.new(0, 0, 1, -18)
TitleFix.BackgroundColor3 = Config.Secondary
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 30, 0, 30)
Logo.Position = UDim2.new(0, 10, 0.5, -15)
Logo.BackgroundTransparency = 1
Logo.Text = "⚡"
Logo.TextSize = 20
Logo.Font = Enum.Font.GothamBold
Logo.TextColor3 = Config.Accent
Logo.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 150, 1, 0)
Title.Position = UDim2.new(0, 42, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Volts Hub"
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Config.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Title Buttons
local function CreateTitleButton(text, position, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 30, 0, 30)
    btn.Position = position
    btn.BackgroundColor3 = Config.Secondary
    btn.Text = text
    btn.TextSize = 18
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = color
    btn.AutoButtonColor = false
    btn.Parent = TitleBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(42, 42, 52)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Config.Secondary}):Play()
    end)

    return btn
end

local MinimizeBtn = CreateTitleButton("−", UDim2.new(1, -70, 0.5, -15), Config.Text)
local CloseBtn = CreateTitleButton("×", UDim2.new(1, -35, 0.5, -15), Config.Danger)

-- ====================== MINIMIZED BAR ======================
local MiniBar = Instance.new("Frame")
MiniBar.Name = "MiniBar"
MiniBar.Size = UDim2.new(0, 180, 0, 36)
MiniBar.Position = UDim2.new(0.5, -90, 0, 12)
MiniBar.BackgroundColor3 = Config.Background
MiniBar.BorderSizePixel = 0
MiniBar.Visible = false
MiniBar.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 10)
MiniCorner.Parent = MiniBar

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Config.Accent
MiniStroke.Thickness = 1.5
MiniStroke.Transparency = 0.3
MiniStroke.Parent = MiniBar

local MiniLogo = Instance.new("TextLabel")
MiniLogo.Size = UDim2.new(0, 24, 1, 0)
MiniLogo.Position = UDim2.new(0, 8, 0, 0)
MiniLogo.BackgroundTransparency = 1
MiniLogo.Text = "⚡"
MiniLogo.TextSize = 16
MiniLogo.TextColor3 = Config.Accent
MiniLogo.Parent = MiniBar

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Name = "FPS"
FPSLabel.Size = UDim2.new(0, 70, 1, 0)
FPSLabel.Position = UDim2.new(0, 34, 0, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: --"
FPSLabel.TextSize = 12
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextColor3 = Config.Text
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.Parent = MiniBar

local MSLabel = Instance.new("TextLabel")
MSLabel.Name = "MS"
MSLabel.Size = UDim2.new(0, 60, 1, 0)
MSLabel.Position = UDim2.new(0, 105, 0, 0)
MSLabel.BackgroundTransparency = 1
MSLabel.Text = "MS: --"
MSLabel.TextSize = 12
MSLabel.Font = Enum.Font.GothamBold
MSLabel.TextColor3 = Config.Text
MSLabel.TextXAlignment = Enum.TextXAlignment.Left
MSLabel.Parent = MiniBar

-- ====================== TABS ======================
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -16, 0, 52)
TabBar.Position = UDim2.new(0, 8, 0, 52)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabBar

local TabsData = {
    {Name = "Aim", Icon = "🎯"},
    {Name = "Visuals", Icon = "👁"},
    {Name = "Movement", Icon = "🏃"},
    {Name = "Gun", Icon = "🔫"},
    {Name = "Chams", Icon = "💎"},
    {Name = "Info", Icon = "ℹ"},
}

local TabButtons = {}
local Pages = {}
local CurrentTab = "Aim"

local function SetActiveTab(name)
    CurrentTab = name
    for tabName, data in pairs(TabButtons) do
        local isActive = tabName == name
        TweenService:Create(data.Button, TweenInfo.new(0.2), {
            BackgroundColor3 = isActive and Config.Accent or Config.Secondary
        }):Play()
        data.NameLabel.TextColor3 = isActive and Config.Background or Config.TextDim
        data.IconLabel.TextColor3 = isActive and Config.Background or Config.Text
        Pages[tabName].Visible = isActive
    end
end

local function CreateTabButton(name, icon)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 50, 0, 46)
    btn.BackgroundColor3 = Config.Secondary
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = TabBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 0, 24)
    iconLabel.Position = UDim2.new(0, 0, 0, 3)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = 16
    iconLabel.TextColor3 = Config.Text
    iconLabel.Parent = btn

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 14)
    nameLabel.Position = UDim2.new(0, 0, 0, 28)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextSize = 10
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextColor3 = Config.TextDim
    nameLabel.Parent = btn

    TabButtons[name] = {
        Button = btn,
        IconLabel = iconLabel,
        NameLabel = nameLabel
    }

    btn.MouseButton1Click:Connect(function()
        SetActiveTab(name)
    end)

    return btn
end

for _, tab in ipairs(TabsData) do
    CreateTabButton(tab.Name, tab.Icon)
end

-- ====================== PAGES ======================
local PagesContainer = Instance.new("Frame")
PagesContainer.Name = "Pages"
PagesContainer.Size = UDim2.new(1, -16, 1, -118)
PagesContainer.Position = UDim2.new(0, 8, 0, 110)
PagesContainer.BackgroundTransparency = 1
PagesContainer.ClipsDescendants = true
PagesContainer.Parent = Main

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Config.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = PagesContainer

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)

    Pages[name] = page
    return page
end

for _, tab in ipairs(TabsData) do
    CreatePage(tab.Name)
end

-- ====================== UI COMPONENTS ======================
local function AddSection(page, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Config.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = page
    return label
end

local function AddToggle(page, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Config.Secondary
    frame.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -64, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Config.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 44, 0, 24)
    toggleBg.Position = UDim2.new(1, -54, 0.5, -12)
    toggleBg.BackgroundColor3 = default and Config.Accent or Color3.fromRGB(48, 48, 56)
    toggleBg.Text = ""
    toggleBg.AutoButtonColor = false
    toggleBg.Parent = frame

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggleBg

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = toggleBg

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(1, 0)
    cCorner.Parent = circle

    local enabled = default
    toggleBg.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Config.Accent or Color3.fromRGB(48, 48, 56)
        }):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        if callback then callback(enabled) end
    end)

    return frame
end

local function AddSlider(page, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 54)
    frame.BackgroundColor3 = Config.Secondary
    frame.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Config.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -24, 0, 6)
    barBg.Position = UDim2.new(0, 12, 0, 34)
    barBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    barBg.Parent = frame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Config.Accent
    fill.Parent = barBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos + 0.5)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        label.Text = text .. ": " .. tostring(value)
        if callback then callback(value) end
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    return frame
end

local function AddButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Config.Secondary
    btn.Text = text
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Config.Text
    btn.AutoButtonColor = false
    btn.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Config.Secondary}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return btn
end

local function AddLabel(page, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 28)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Config.TextDim
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = page
    return label
end

-- ====================== BUILD TABS CONTENT ======================

-- AIM TAB
local AimPage = Pages["Aim"]
AddSection(AimPage, "Aimbot")
AddToggle(AimPage, "Enable Aimbot", false, function(v) print("Aimbot:", v) end)
AddToggle(AimPage, "Silent Aim", false, function(v) print("SilentAim:", v) end)
AddToggle(AimPage, "Team Check", true, function(v) print("TeamCheck:", v) end)
AddToggle(AimPage, "Wall Check", true, function(v) print("WallCheck:", v) end)
AddSlider(AimPage, "FOV", 30, 400, 120, function(v) print("FOV:", v) end)
AddSlider(AimPage, "Smoothness", 1, 20, 5, function(v) print("Smooth:", v) end)
AddSlider(AimPage, "Hit Chance", 1, 100, 100, function(v) print("HitChance:", v) end)
AddSection(AimPage, "Target")
AddToggle(AimPage, "Aim at Head", true, function(v) print("Head:", v) end)
AddToggle(AimPage, "Prediction", false, function(v) print("Prediction:", v) end)

-- VISUALS TAB
local VisualsPage = Pages["Visuals"]
AddSection(VisualsPage, "ESP")
AddToggle(VisualsPage, "Enable ESP", false, function(v) print("ESP:", v) end)
AddToggle(VisualsPage, "Box ESP", false, function(v) print("Box:", v) end)
AddToggle(VisualsPage, "Name ESP", false, function(v) print("Name:", v) end)
AddToggle(VisualsPage, "Health Bar", false, function(v) print("Health:", v) end)
AddToggle(VisualsPage, "Distance", false, function(v) print("Distance:", v) end)
AddToggle(VisualsPage, "Tracers", false, function(v) print("Tracers:", v) end)
AddSection(VisualsPage, "Other")
AddToggle(VisualsPage, "Show FOV Circle", false, function(v) print("FOVCircle:", v) end)
AddToggle(VisualsPage, "Crosshair", false, function(v) print("Crosshair:", v) end)

-- MOVEMENT TAB
local MovePage = Pages["Movement"]
AddSection(MovePage, "Movement")
AddToggle(MovePage, "Speed Hack", false, function(v) print("Speed:", v) end)
AddSlider(MovePage, "Speed Multiplier", 1, 5, 1, function(v) print("SpeedMult:", v) end)
AddToggle(MovePage, "Bunny Hop", false, function(v) print("Bhop:", v) end)
AddToggle(MovePage, "Fly", false, function(v) print("Fly:", v) end)
AddToggle(MovePage, "No Clip", false, function(v) print("NoClip:", v) end)
AddToggle(MovePage, "Infinite Jump", false, function(v) print("InfJump:", v) end)
AddSection(MovePage, "Camera")
AddSlider(MovePage, "FOV", 70, 120, 70, function(v) print("CamFOV:", v) end)

-- GUN TAB
local GunPage = Pages["Gun"]
AddSection(GunPage, "Weapon Mods")
AddToggle(GunPage, "No Recoil", false, function(v) print("NoRecoil:", v) end)
AddToggle(GunPage, "No Spread", false, function(v) print("NoSpread:", v) end)
AddToggle(GunPage, "Infinite Ammo", false, function(v) print("InfAmmo:", v) end)
AddToggle(GunPage, "Rapid Fire", false, function(v) print("Rapid:", v) end)
AddToggle(GunPage, "Instant Reload", false, function(v) print("InstReload:", v) end)
AddToggle(GunPage, "No Scope Overlay", false, function(v) print("NoScope:", v) end)
AddSection(GunPage, "Extra")
AddToggle(GunPage, "Trigger Bot", false, function(v) print("Trigger:", v) end)
AddSlider(GunPage, "Fire Rate", 1, 20, 5, function(v) print("FireRate:", v) end)

-- CHAMS TAB
local ChamsPage = Pages["Chams"]
AddSection(ChamsPage, "Chams")
AddToggle(ChamsPage, "Enemy Chams", false, function(v) print("EnemyChams:", v) end)
AddToggle(ChamsPage, "Team Chams", false, function(v) print("TeamChams:", v) end)
AddToggle(ChamsPage, "Rainbow Chams", false, function(v) print("Rainbow:", v) end)
AddToggle(ChamsPage, "Glow Through Walls", false, function(v) print("XRay:", v) end)
AddSection(ChamsPage, "Colors")
AddToggle(ChamsPage, "Custom Color", false, function(v) print("CustomColor:", v) end)
AddSlider(ChamsPage, "Transparency", 0, 100, 30, function(v) print("Trans:", v) end)

-- INFO TAB
local InfoPage = Pages["Info"]
AddSection(InfoPage, "Volts Hub")
AddLabel(InfoPage, "Version: 1.0.0")
AddLabel(InfoPage, "Game: BloxStrike")
AddLabel(InfoPage, "Author: Volts")
AddSection(InfoPage, "Credits")
AddLabel(InfoPage, "UI Design • Smooth Animations")
AddLabel(InfoPage, "Mobile Optimized")
AddSection(InfoPage, "Actions")
AddButton(InfoPage, "Copy Discord", function()
    print("Discord link copied")
end)
AddButton(InfoPage, "Unload Hub", function()
    ScreenGui:Destroy()
end)

-- ====================== DRAGGING ======================
local dragging, dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- MiniBar dragging
local miniDragging, miniDragStart, miniStartPos
MiniBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = true
        miniDragStart = input.Position
        miniStartPos = MiniBar.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                miniDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - miniDragStart
        MiniBar.Position = UDim2.new(miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X, miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y)
    end
end)

-- ====================== MINIMIZE / CLOSE ======================
local isMinimized = false

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 340, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.2)
        Main.Visible = false
        MiniBar.Visible = true
        MiniBar.BackgroundTransparency = 1
        TweenService:Create(MiniBar, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    else
        MiniBar.Visible = false
        Main.Visible = true
        Main.BackgroundTransparency = 1
        Main.Size = UDim2.new(0, 340, 0, 0)
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 340, 0, 430),
            BackgroundTransparency = 0
        }):Play()
    end
end)

-- Click MiniBar to restore
MiniBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- double click style restore can be added, for now single click after short delay is fine
    end
end)

-- Simple restore on MiniBar click
local lastClick = 0
MiniBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local now = tick()
        if now - lastClick < 0.35 then
            isMinimized = false
            MiniBar.Visible = false
            Main.Visible = true
            Main.BackgroundTransparency = 1
            Main.Size = UDim2.new(0, 340, 0, 0)
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 340, 0, 430),
                BackgroundTransparency = 0
            }):Play()
        end
        lastClick = now
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.25), {
        Size = UDim2.new(0, 340, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.25)
    ScreenGui:Destroy()
end)

-- ====================== FPS + MS ======================
local frames = 0
local lastFPSUpdate = tick()

RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - lastFPSUpdate >= 1 then
        local fps = frames
        frames = 0
        lastFPSUpdate = tick()

        local ms = 0
        pcall(function()
            ms = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)

        FPSLabel.Text = "FPS: " .. tostring(fps)
        MSLabel.Text = "MS: " .. tostring(ms)

        if fps >= 55 then
            FPSLabel.TextColor3 = Config.Success
        elseif fps >= 30 then
            FPSLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        else
            FPSLabel.TextColor3 = Config.Danger
        end
    end
end)

-- ====================== INIT ======================
SetActiveTab("Aim")

print("Volts Hub loaded successfully")
