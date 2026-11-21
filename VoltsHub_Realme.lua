--[[
    Volts Hub • Realme UI 7.0 Style
    Fluid Animations | Soft Depth | Compact
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ====================== REALME THEME ======================
local R = {
    Bg          = Color3.fromRGB(245, 246, 250),      -- soft light
    Card        = Color3.fromRGB(255, 255, 255),
    CardDark    = Color3.fromRGB(22, 23, 28),         -- for dark mode feel on accents
    Surface     = Color3.fromRGB(238, 240, 245),
    Accent      = Color3.fromRGB(0, 145, 255),        -- Realme blue
    AccentSoft  = Color3.fromRGB(0, 145, 255),
    Text        = Color3.fromRGB(25, 28, 35),
    TextSec     = Color3.fromRGB(110, 115, 130),
    Green       = Color3.fromRGB(0, 190, 100),
    Red         = Color3.fromRGB(255, 70, 70),
    Orange      = Color3.fromRGB(255, 130, 40),
    TrackOff    = Color3.fromRGB(210, 214, 225),
    Shadow      = Color3.fromRGB(0, 0, 0),
}

-- Dark variant for the main window (more premium for cheats)
R.Bg = Color3.fromRGB(16, 17, 22)
R.Card = Color3.fromRGB(28, 29, 36)
R.Surface = Color3.fromRGB(36, 38, 48)
R.Text = Color3.fromRGB(245, 246, 250)
R.TextSec = Color3.fromRGB(140, 145, 160)
R.TrackOff = Color3.fromRGB(55, 58, 70)

-- ====================== FLAGS ======================
local F = {
    Aimbot=false, Silent=false, Rage=false, Sticky=false,
    Team=true, Wall=true, FOV=120, Smooth=5, Hit=100, Head=80, Pred=0.06, ShowFOV=false,
    ESP=false, Box=false, Name=false, HP=false, Dist=false, Tracer=false, Skel=false, Hat=false, Cross=false,
    Speed=false, SpeedV=1.6, Bhop=false, Fly=false, FlyV=45, NoClip=false, InfJump=false, CamFOV=70,
    NoRecoil=false, NoSpread=false, InfAmmo=false, Rapid=false, InstRel=false, NoScope=false, FastSw=false,
    Trigger=false, TrigDel=25,
    EChams=false, TChams=false, Rain=false, Glow=false, Outline=false, Trans=0.35,
}

-- ====================== TWEEN HELPERS ======================
local function Tw(obj, props, time, style, dir)
    return TweenService:Create(obj,
        TweenInfo.new(time or 0.28, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props)
end

local function Spring(obj, props, time)
    return TweenService:Create(obj,
        TweenInfo.new(time or 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        props)
end

local function Soft(obj, props, time)
    return TweenService:Create(obj,
        TweenInfo.new(time or 0.32, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        props)
end

local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 12)
    c.Parent = p
    return c
end

local function Pad(p, t, b, l, r)
    local u = Instance.new("UIPadding")
    u.PaddingTop = UDim.new(0, t or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    u.PaddingLeft = UDim.new(0, l or 0)
    u.PaddingRight = UDim.new(0, r or 0)
    u.Parent = p
end

-- ====================== SCREEN ======================
local Gui = Instance.new("ScreenGui")
Gui.Name = "VoltsRealme"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
pcall(function() Gui.Parent = CoreGui end)
if not Gui.Parent then Gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ====================== MAIN WINDOW ======================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 300, 0, 0)          -- start collapsed for open anim
Main.Position = UDim2.new(0.5, -150, 0.5, -175)
Main.BackgroundColor3 = R.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.BackgroundTransparency = 1
Main.Parent = Gui
Corner(Main, 18)

-- Soft shadow simulation
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.55
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.Parent = Main

-- Accent line (Realme style top glow)
local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 2)
TopLine.BackgroundColor3 = R.Accent
TopLine.BorderSizePixel = 0
TopLine.Parent = Main

local TopGrad = Instance.new("UIGradient")
TopGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, R.Orange),
    ColorSequenceKeypoint.new(0.5, R.Accent),
    ColorSequenceKeypoint.new(1, R.Orange),
})
TopGrad.Parent = TopLine

task.spawn(function()
    while TopLine.Parent do
        for i = 0, 360, 1.2 do
            TopGrad.Rotation = i
            task.wait(0.028)
        end
    end
end)

-- ====================== TITLE ======================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = Main

local Logo = Instance.new("Frame")
Logo.Size = UDim2.new(0, 28, 0, 28)
Logo.Position = UDim2.new(0, 12, 0.5, -14)
Logo.BackgroundColor3 = R.Accent
Logo.Parent = TitleBar
Corner(Logo, 9)

local LogoT = Instance.new("TextLabel")
LogoT.Size = UDim2.new(1, 0, 1, 0)
LogoT.BackgroundTransparency = 1
LogoT.Text = "V"
LogoT.TextSize = 15
LogoT.Font = Enum.Font.GothamBlack
LogoT.TextColor3 = Color3.fromRGB(255,255,255)
LogoT.Parent = Logo

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 130, 0, 20)
Title.Position = UDim2.new(0, 48, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "Volts Hub"
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = R.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(0, 130, 0, 14)
Sub.Position = UDim2.new(0, 48, 0, 22)
Sub.BackgroundTransparency = 1
Sub.Text = "Realme Style"
Sub.TextSize = 10
Sub.Font = Enum.Font.Gotham
Sub.TextColor3 = R.TextSec
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.Parent = TitleBar

local function IconBtn(icon, col, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = UDim2.new(1, x, 0.5, -14)
    b.BackgroundColor3 = R.Surface
    b.Text = icon
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = col
    b.AutoButtonColor = false
    b.Parent = TitleBar
    Corner(b, 8)

    b.MouseEnter:Connect(function()
        Soft(b, {BackgroundColor3 = Color3.fromRGB(50, 52, 65)}, 0.18):Play()
        Spring(b, {Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, x-1, 0.5, -15)}, 0.3):Play()
    end)
    b.MouseLeave:Connect(function()
        Soft(b, {BackgroundColor3 = R.Surface}, 0.18):Play()
        Soft(b, {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, x, 0.5, -14)}, 0.2):Play()
    end)
    return b
end

local MinBtn = IconBtn("−", R.Text, -68)
local CloseBtn = IconBtn("×", R.Red, -34)

-- ====================== MINI BAR ======================
local Mini = Instance.new("Frame")
Mini.Size = UDim2.new(0, 168, 0, 34)
Mini.Position = UDim2.new(0.5, -84, 0, 12)
Mini.BackgroundColor3 = R.Bg
Mini.BorderSizePixel = 0
Mini.Visible = false
Mini.BackgroundTransparency = 1
Mini.Parent = Gui
Corner(Mini, 12)

local MiniS = Instance.new("UIStroke")
MiniS.Color = R.Accent
MiniS.Thickness = 1.2
MiniS.Transparency = 0.4
MiniS.Parent = Mini

local MiniLogo = Instance.new("Frame")
MiniLogo.Size = UDim2.new(0, 22, 0, 22)
MiniLogo.Position = UDim2.new(0, 7, 0.5, -11)
MiniLogo.BackgroundColor3 = R.Accent
MiniLogo.Parent = Mini
Corner(MiniLogo, 7)

local MiniLT = Instance.new("TextLabel")
MiniLT.Size = UDim2.new(1,0,1,0)
MiniLT.BackgroundTransparency = 1
MiniLT.Text = "V"
MiniLT.TextSize = 12
MiniLT.Font = Enum.Font.GothamBlack
MiniLT.TextColor3 = Color3.fromRGB(255,255,255)
MiniLT.Parent = MiniLogo

local FPSL = Instance.new("TextLabel")
FPSL.Size = UDim2.new(0, 58, 1, 0)
FPSL.Position = UDim2.new(0, 36, 0, 0)
FPSL.BackgroundTransparency = 1
FPSL.Text = "FPS --"
FPSL.TextSize = 11
FPSL.Font = Enum.Font.GothamBold
FPSL.TextColor3 = R.Text
FPSL.TextXAlignment = Enum.TextXAlignment.Left
FPSL.Parent = Mini

local MSL = Instance.new("TextLabel")
MSL.Size = UDim2.new(0, 52, 1, 0)
MSL.Position = UDim2.new(0, 100, 0, 0)
MSL.BackgroundTransparency = 1
MSL.Text = "MS --"
MSL.TextSize = 11
MSL.Font = Enum.Font.GothamBold
MSL.TextColor3 = R.Text
MSL.TextXAlignment = Enum.TextXAlignment.Left
MSL.Parent = Mini

-- ====================== TABS (pill style + fluid) ======================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -16, 0, 36)
TabBar.Position = UDim2.new(0, 8, 0, 44)
TabBar.BackgroundColor3 = R.Surface
TabBar.BorderSizePixel = 0
TabBar.Parent = Main
Corner(TabBar, 12)

local TabLay = Instance.new("UIListLayout")
TabLay.FillDirection = Enum.FillDirection.Horizontal
TabLay.Padding = UDim.new(0, 3)
TabLay.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLay.VerticalAlignment = Enum.VerticalAlignment.Center
TabLay.Parent = TabBar
Pad(TabBar, 3, 3, 4, 4)

local Tabs = {
    {n="Aim", i="🎯"},
    {n="Visuals", i="👁"},
    {n="Move", i="💨"},
    {n="Gun", i="🔫"},
    {n="Chams", i="💠"},
    {n="Info", i="ℹ"},
}

local TabBtn, Pages, Cur = {}, {}, "Aim"
local Indicator = Instance.new("Frame") -- sliding pill
Indicator.Size = UDim2.new(0, 44, 0, 28)
Indicator.BackgroundColor3 = R.Accent
Indicator.BorderSizePixel = 0
Indicator.ZIndex = 1
Indicator.Parent = TabBar
Corner(Indicator, 9)

local function SetTab(name, instant)
    local old = Cur
    Cur = name

    for n, b in pairs(TabBtn) do
        local on = n == name
        Soft(b, {TextColor3 = on and Color3.fromRGB(255,255,255) or R.TextSec}, 0.25):Play()
        Pages[n].Visible = on
    end

    -- fluid slide indicator
    local target = TabBtn[name]
    if target then
        local goal = UDim2.new(0, target.Position.X.Offset, 0, 4)
        if instant then
            Indicator.Position = goal
            Indicator.Size = UDim2.new(0, target.AbsoluteSize.X > 0 and target.AbsoluteSize.X or 44, 0, 28)
        else
            Spring(Indicator, {
                Position = UDim2.new(0, target.Position.X.Offset, 0, 4),
                Size = UDim2.new(0, target.Size.X.Offset, 0, 28)
            }, 0.4):Play()
        end
    end

    -- page fade
    if Pages[name] then
        Pages[name].UIScale.Scale = 0.96
        Pages[name].GroupTransparency = 0.4
        Soft(Pages[name].UIScale, {Scale = 1}, 0.28):Play()
        Soft(Pages[name], {GroupTransparency = 0}, 0.28):Play()
    end
end

for i, t in ipairs(Tabs) do
    local b = Instance.new("TextButton")
    b.Name = t.n
    b.Size = UDim2.new(0, 44, 0, 28)
    b.BackgroundTransparency = 1
    b.Text = t.i
    b.TextSize = 15
    b.TextColor3 = R.TextSec
    b.ZIndex = 2
    b.AutoButtonColor = false
    b.Parent = TabBar
    TabBtn[t.n] = b

    b.MouseButton1Click:Connect(function()
        if Cur ~= t.n then SetTab(t.n) end
    end)

    -- micro press
    b.MouseButton1Down:Connect(function()
        Soft(b, {TextSize = 13}, 0.1):Play()
    end)
    b.MouseButton1Up:Connect(function()
        Soft(b, {TextSize = 15}, 0.15):Play()
    end)
end

-- ====================== PAGES ======================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -92)
Content.Position = UDim2.new(0, 8, 0, 86)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Main

local function MakePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = R.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.GroupTransparency = 0
    page.Parent = Content

    local scale = Instance.new("UIScale")
    scale.Scale = 1
    scale.Parent = page
    page.UIScale = scale

    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 6)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = page

    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 12)
    end)

    Pages[name] = page
    return page
end

for _, t in ipairs(Tabs) do MakePage(t.n) end

-- ====================== COMPONENTS (Realme style) ======================
local function Sec(page, text)
    local f = Instance.new("TextLabel")
    f.Size = UDim2.new(1, 0, 0, 20)
    f.BackgroundTransparency = 1
    f.Text = "  " .. text
    f.TextSize = 11
    f.Font = Enum.Font.GothamBold
    f.TextColor3 = R.Accent
    f.TextXAlignment = Enum.TextXAlignment.Left
    f.Parent = page
end

local function Card(page)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = R.Card
    f.BorderSizePixel = 0
    f.Parent = page
    Corner(f, 12)
    return f
end

local function Tog(page, text, key, cb)
    local f = Card(page)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -58, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = 12
    l.Font = Enum.Font.GothamMedium
    l.TextColor3 = R.Text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 42, 0, 24)
    track.Position = UDim2.new(1, -50, 0.5, -12)
    track.BackgroundColor3 = F[key] and R.Accent or R.TrackOff
    track.Text = ""
    track.AutoButtonColor = false
    track.Parent = f
    Corner(track, 12)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = F[key] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.Parent = track
    Corner(knob, 9)

    -- soft shadow on knob
    local ks = Instance.new("ImageLabel")
    ks.Size = UDim2.new(1, 10, 1, 10)
    ks.Position = UDim2.new(0, -5, 0, -5)
    ks.BackgroundTransparency = 1
    ks.Image = "rbxassetid://6014261993"
    ks.ImageColor3 = Color3.fromRGB(0,0,0)
    ks.ImageTransparency = 0.7
    ks.ScaleType = Enum.ScaleType.Slice
    ks.SliceCenter = Rect.new(49,49,450,450)
    ks.Parent = knob

    track.MouseButton1Click:Connect(function()
        F[key] = not F[key]
        local on = F[key]

        Soft(track, {BackgroundColor3 = on and R.Accent or R.TrackOff}, 0.25):Play()
        Spring(knob, {
            Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }, 0.35):Play()

        -- micro bounce
        Spring(knob, {Size = UDim2.new(0, 20, 0, 20)}, 0.15):Play()
        task.delay(0.12, function()
            Soft(knob, {Size = UDim2.new(0, 18, 0, 18)}, 0.2):Play()
        end)

        if cb then cb(on) end
    end)
end

local function Sld(page, text, key, min, max, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 48)
    f.BackgroundColor3 = R.Card
    f.Parent = page
    Corner(f, 12)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 0, 18)
    l.Position = UDim2.new(0, 12, 0, 6)
    l.BackgroundTransparency = 1
    l.Text = text .. "   " .. tostring(F[key])
    l.TextSize = 12
    l.Font = Enum.Font.GothamMedium
    l.TextColor3 = R.Text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 5)
    bar.Position = UDim2.new(0, 12, 0, 32)
    bar.BackgroundColor3 = R.TrackOff
    bar.Parent = f
    Corner(bar, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((F[key]-min)/(max-min), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = R.Accent
    fill.Parent = bar
    Corner(fill, 3)

    local drag = false
    local function upd(inp)
        local pct = math.clamp((inp.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local raw = min + (max - min) * pct
        local val = (type(F[key]) == "number" and F[key] % 1 ~= 0) and (math.floor(raw*100+0.5)/100) or math.floor(raw+0.5)
        F[key] = val
        Soft(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.08):Play()
        l.Text = text .. "   " .. tostring(val)
        if cb then cb(val) end
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; upd(i)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
end

local function Btn(page, text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = R.Card
    b.Text = text
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = R.Text
    b.AutoButtonColor = false
    b.Parent = page
    Corner(b, 12)

    b.MouseEnter:Connect(function()
        Soft(b, {BackgroundColor3 = R.Surface}, 0.18):Play()
        Spring(b, {Size = UDim2.new(1, 0, 0, 38)}, 0.25):Play()
    end)
    b.MouseLeave:Connect(function()
        Soft(b, {BackgroundColor3 = R.Card}, 0.18):Play()
        Soft(b, {Size = UDim2.new(1, 0, 0, 36)}, 0.2):Play()
    end)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
end

local function Lab(page, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 18)
    l.BackgroundTransparency = 1
    l.Text = "  " .. text
    l.TextSize = 11
    l.Font = Enum.Font.Gotham
    l.TextColor3 = R.TextSec
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = page
end

-- ====================== BUILD ======================
local p = Pages.Aim
Sec(p, "AIMBOT")
Tog(p, "Enable Aimbot", "Aimbot")
Tog(p, "Silent Aim", "Silent")
Tog(p, "Ragebot", "Rage")
Tog(p, "Sticky Aim", "Sticky")
Tog(p, "Team Check", "Team")
Tog(p, "Wall Check", "Wall")
Sld(p, "FOV", "FOV", 40, 350)
Sld(p, "Smoothness", "Smooth", 1, 20)
Sld(p, "Hit Chance", "Hit", 1, 100)
Sld(p, "Head Chance", "Head", 0, 100)
Sld(p, "Prediction", "Pred", 0, 0.2)
Tog(p, "Show FOV Circle", "ShowFOV")

p = Pages.Visuals
Sec(p, "ESP")
Tog(p, "Master ESP", "ESP")
Tog(p, "Box", "Box")
Tog(p, "Names", "Name")
Tog(p, "Health Bar", "HP")
Tog(p, "Distance", "Dist")
Tog(p, "Tracers", "Tracer")
Tog(p, "Skeleton", "Skel")
Tog(p, "China Hat", "Hat")
Sec(p, "EXTRA")
Tog(p, "Crosshair", "Cross")

p = Pages.Move
Sec(p, "MOVEMENT")
Tog(p, "Speed Hack", "Speed")
Sld(p, "Speed Multiplier", "SpeedV", 1, 5)
Tog(p, "Bunny Hop", "Bhop")
Tog(p, "Fly", "Fly")
Sld(p, "Fly Speed", "FlyV", 15, 100)
Tog(p, "NoClip", "NoClip")
Tog(p, "Infinite Jump", "InfJump")
Sec(p, "CAMERA")
Sld(p, "Field of View", "CamFOV", 70, 120)

p = Pages.Gun
Sec(p, "WEAPON")
Tog(p, "No Recoil", "NoRecoil")
Tog(p, "No Spread", "NoSpread")
Tog(p, "Infinite Ammo", "InfAmmo")
Tog(p, "Rapid Fire", "Rapid")
Tog(p, "Instant Reload", "InstRel")
Tog(p, "No Scope", "NoScope")
Tog(p, "Fast Switch", "FastSw")
Sec(p, "ASSIST")
Tog(p, "Triggerbot", "Trigger")
Sld(p, "Trigger Delay", "TrigDel", 0, 120)

p = Pages.Chams
Sec(p, "CHAMS")
Tog(p, "Enemy Chams", "EChams")
Tog(p, "Team Chams", "TChams")
Tog(p, "Rainbow", "Rain")
Tog(p, "Glow Walls", "Glow")
Tog(p, "Outline Only", "Outline")
Sld(p, "Transparency", "Trans", 0, 1)

p = Pages.Info
Sec(p, "VOLTS HUB")
Lab(p, "Version  3.0  •  Realme UI")
Lab(p, "Game     BloxStrike")
Lab(p, "Style    Fluid + Soft")
Sec(p, "ACTIONS")
Btn(p, "Copy Discord", function()
    pcall(function() setclipboard("discord.gg/voltshub") end)
end)
Btn(p, "Unload", function()
    Soft(Main, {Size = UDim2.new(0, 300, 0, 0), BackgroundTransparency = 1}, 0.3):Play()
    task.delay(0.3, function() Gui:Destroy() end)
end)

-- ====================== OPEN ANIMATION ======================
task.defer(function()
    Soft(Main, {BackgroundTransparency = 0}, 0.35):Play()
    Spring(Main, {Size = UDim2.new(0, 300, 0, 350)}, 0.55):Play()
    task.wait(0.15)
    SetTab("Aim", true)
end)

-- ====================== DRAG ======================
local drag, dStart, sPos, dInput
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; dStart = i.Position; sPos = Main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
    end
end)
TitleBar.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dInput = i end
end)
UserInputService.InputChanged:Connect(function(i)
    if i == dInput and drag then
        local d = i.Position - dStart
        Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
    end
end)

-- Mini drag
local md, ms, mp
Mini.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        md = true; ms = i.Position; mp = Mini.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then md = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if md and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - ms
        Mini.Position = UDim2.new(mp.X.Scale, mp.X.Offset + d.X, mp.Y.Scale, mp.Y.Offset + d.Y)
    end
end)

-- ====================== MINIMIZE / CLOSE ======================
local mini = false
MinBtn.MouseButton1Click:Connect(function()
    mini = not mini
    if mini then
        Soft(Main, {Size = UDim2.new(0, 300, 0, 0), BackgroundTransparency = 1}, 0.28):Play()
        task.delay(0.28, function()
            Main.Visible = false
            Mini.Visible = true
            Soft(Mini, {BackgroundTransparency = 0}, 0.22):Play()
            Spring(Mini, {Size = UDim2.new(0, 168, 0, 34)}, 0.35):Play()
        end)
    else
        Mini.Visible = false
        Main.Visible = true
        Main.Size = UDim2.new(0, 300, 0, 0)
        Main.BackgroundTransparency = 1
        Soft(Main, {BackgroundTransparency = 0}, 0.25):Play()
        Spring(Main, {Size = UDim2.new(0, 300, 0, 350)}, 0.45):Play()
    end
end)

local lastClick = 0
Mini.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        local now = tick()
        if now - lastClick < 0.35 then
            mini = false
            Mini.Visible = false
            Main.Visible = true
            Main.Size = UDim2.new(0, 300, 0, 0)
            Main.BackgroundTransparency = 1
            Soft(Main, {BackgroundTransparency = 0}, 0.25):Play()
            Spring(Main, {Size = UDim2.new(0, 300, 0, 350)}, 0.45):Play()
        end
        lastClick = now
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Soft(Main, {Size = UDim2.new(0, 300, 0, 0), BackgroundTransparency = 1}, 0.28):Play()
    task.delay(0.3, function() Gui:Destroy() end)
end)

-- ====================== FPS ======================
local frames, last = 0, tick()
RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - last >= 1 then
        local fps = frames; frames = 0; last = tick()
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        FPSL.Text = "FPS " .. fps
        MSL.Text = "MS " .. ping
        FPSL.TextColor3 = fps >= 55 and R.Green or (fps >= 30 and R.Orange or R.Red)
    end
end)

-- FOV Circle
local circle = Drawing and Drawing.new("Circle")
if circle then
    circle.Thickness = 1.4
    circle.NumSides = 64
    circle.Filled = false
    circle.Color = R.Accent
    circle.Visible = false
    RunService.RenderStepped:Connect(function()
        circle.Visible = F.ShowFOV
        if F.ShowFOV then
            circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            circle.Radius = F.FOV
        end
    end)
end

print("[Volts Hub] Realme UI 7.0 style loaded")
