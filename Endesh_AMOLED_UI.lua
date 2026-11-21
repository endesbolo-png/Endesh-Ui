--!strict
-- Endesh Pure Black AMOLED UI Framework (8 Tabs: Aim, ESP, Player, Movement, Chams, Spinbot, Gun, Info)
-- Mobile Touch + Draggable + Smooth Tween Animations + Toggle / Slider / Button
-- Built for Roblox Studio / Local Testing (~200 KB Extended Config & UI Bundle)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================================================
-- 1. THEME & LUCIDE ICON REGISTRY
-- ============================================================================
local Theme = {
	BgPureBlack = Color3.fromRGB(5, 5, 8),
	PanelDark = Color3.fromRGB(13, 14, 22),
	CardDark = Color3.fromRGB(20, 22, 34),
	CardHover = Color3.fromRGB(27, 30, 46),
	StrokeSubtle = Color3.fromRGB(45, 42, 72),
	NeonBlue = Color3.fromRGB(56, 189, 248),
	NeonPurple = Color3.fromRGB(168, 85, 247),
	NeonAccent = Color3.fromRGB(112, 137, 255),
	TextPrimary = Color3.fromRGB(244, 246, 255),
	TextMuted = Color3.fromRGB(148, 155, 182),
	ToggleOff = Color3.fromRGB(36, 39, 58),
}

local LucideIcons = {
	Aim = { id = "", glyph = "◎" },
	ESP = { id = "", glyph = "◈" },
	Player = { id = "", glyph = "◉" },
	Movement = { id = "", glyph = "➤" },
	Chams = { id = "", glyph = "❖" },
	Spinbot = { id = "", glyph = "↻" },
	Gun = { id = "", glyph = "⌖" },
	Info = { id = "", glyph = "ⓘ" },
	Close = { id = "", glyph = "✕" },
	Toggle = { id = "", glyph = "⚡" },
}

local State = {
	Open = true,
	ActiveTab = "Aim",
	Flags = {
		AimEnabled = false,
		AimSmoothness = 15,
		AimFOV = 120,
		ESPEnabled = false,
		ESPMaxDist = 500,
		CustomSpeedEnabled = false,
		WalkSpeed = 24,
		JumpPower = 60,
		BHopEnabled = false,
		ChamsEnabled = false,
		ChamsFillAlpha = 45,
		SpinbotEnabled = false,
		SpinSpeed = 25,
		NoRecoilEnabled = false,
		FireRateScale = 100,
	},
}

local RuntimeConnections = {}
local function trackConnection(conn: RBXScriptConnection)
	table.insert(RuntimeConnections, conn)
	return conn
end

-- ============================================================================
-- 2. TWEEN & UI HELPERS
-- ============================================================================
local function tween(instance: Instance, info: TweenInfo, props: { [string]: any })
	local anim = TweenService:Create(instance, info, props)
	anim:Play()
	return anim
end

local function addCorner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function addStroke(parent: Instance, color: Color3, thickness: number, transparency: number?)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.Transparency = transparency or 0.35
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function addNeonGradient(parent: Instance, rotation: number?)
	local g = Instance.new("UIGradient")
	g.Rotation = rotation or 35
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.NeonBlue),
		ColorSequenceKeypoint.new(1, Theme.NeonPurple),
	})
	g.Parent = parent
	return g
end

-- ============================================================================
-- 3. ROOT GUI & MOBILE RESPONSIVE SCALE
-- ============================================================================
local function getParentGui(): Instance
	local ok, result = pcall(function()
		return CoreGui
	end)
	if ok and result then
		return result
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EndeshAMOLED_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = getParentGui()

local UIScale = Instance.new("UIScale")
UIScale.Parent = ScreenGui

local function updateResponsiveScale()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local minDim = math.min(viewport.X, viewport.Y)
	if minDim < 500 then
		UIScale.Scale = math.clamp(viewport.X / 760, 0.72, 1.0)
	else
		UIScale.Scale = math.clamp(minDim / 720, 0.85, 1.15)
	end
end

updateResponsiveScale()
if workspace.CurrentCamera then
	trackConnection(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale))
end

-- ============================================================================
-- 4. MAIN WINDOW, DRAG (TOUCH + MOUSE) & OPEN/CLOSE ANIMATION
-- ============================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainWindow"
MainFrame.Size = UDim2.fromOffset(620, 410)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Theme.BgPureBlack
MainFrame.BackgroundTransparency = 0.04
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

addCorner(MainFrame, 16)
local mainStroke = addStroke(MainFrame, Theme.NeonAccent, 1.4, 0.25)
addNeonGradient(mainStroke, 45)

local FloatingToggle = Instance.new("TextButton")
FloatingToggle.Name = "FloatingOpenButton"
FloatingToggle.Size = UDim2.fromOffset(48, 48)
FloatingToggle.Position = UDim2.new(0.03, 0, 0.18, 0)
FloatingToggle.BackgroundColor3 = Theme.PanelDark
FloatingToggle.Text = "⚡"
FloatingToggle.TextColor3 = Theme.TextPrimary
FloatingToggle.TextSize = 20
FloatingToggle.Font = Enum.Font.GothamBold
FloatingToggle.Visible = false
FloatingToggle.Parent = ScreenGui
addCorner(FloatingToggle, 14)
addStroke(FloatingToggle, Theme.NeonPurple, 1.4, 0.2)

local function setWindowOpen(isOpen: boolean)
	State.Open = isOpen
	if isOpen then
		FloatingToggle.Visible = false
		MainFrame.Visible = true
		MainFrame.Size = UDim2.fromOffset(560, 340)
		MainFrame.BackgroundTransparency = 0.45
		tween(
			MainFrame,
			TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Size = UDim2.fromOffset(620, 410),
				BackgroundTransparency = 0.04,
			}
		)
	else
		local closeAnim = tween(
			MainFrame,
			TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				Size = UDim2.fromOffset(560, 320),
				BackgroundTransparency = 0.65,
			}
		)
		closeAnim.Completed:Connect(function()
			if not State.Open then
				MainFrame.Visible = false
				FloatingToggle.Visible = true
			end
		end)
	end
end

trackConnection(FloatingToggle.MouseButton1Click:Connect(function()
	setWindowOpen(true)
end))

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Theme.PanelDark
TopBar.BackgroundTransparency = 0.12
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -110, 1, 0)
TitleLabel.Position = UDim2.fromOffset(16, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ENDESH  //  PURE BLACK UI"
TitleLabel.TextColor3 = Theme.TextPrimary
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseButton"
CloseBtn.Size = UDim2.fromOffset(32, 32)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -16)
CloseBtn.BackgroundColor3 = Theme.CardDark
CloseBtn.Text = LucideIcons.Close.glyph
CloseBtn.TextColor3 = Theme.TextMuted
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
addCorner(CloseBtn, 8)
addStroke(CloseBtn, Theme.StrokeSubtle, 1, 0.3)

trackConnection(CloseBtn.MouseButton1Click:Connect(function()
	setWindowOpen(false)
end))

do
	local dragging = false
	local dragInput: InputObject? = nil
	local dragStart = Vector2.zero
	local startPos = MainFrame.Position

	trackConnection(TopBar.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
			dragInput = input

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end))

	trackConnection(TopBar.InputChanged:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end))

	trackConnection(UserInputService.InputChanged:Connect(function(input: InputObject)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			local scale = UIScale.Scale > 0 and UIScale.Scale or 1
			MainFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + (delta.X / scale),
				startPos.Y.Scale,
				startPos.Y.Offset + (delta.Y / scale)
			)
		end
	end))
end

-- ============================================================================
-- 5. SIDEBAR (8 TABS) & CONTENT CONTAINER
-- ============================================================================
local BodyContainer = Instance.new("Frame")
BodyContainer.Name = "Body"
BodyContainer.Size = UDim2.new(1, 0, 1, -48)
BodyContainer.Position = UDim2.fromOffset(0, 48)
BodyContainer.BackgroundTransparency = 1
BodyContainer.Parent = MainFrame

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 152, 1, -16)
Sidebar.Position = UDim2.fromOffset(10, 8)
Sidebar.BackgroundColor3 = Theme.PanelDark
Sidebar.BackgroundTransparency = 0.25
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 2
Sidebar.ScrollBarImageColor3 = Theme.NeonPurple
Sidebar.CanvasSize = UDim2.fromOffset(0, 0)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.Parent = BodyContainer
addCorner(Sidebar, 12)
addStroke(Sidebar, Theme.StrokeSubtle, 1, 0.45)

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 6)
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 8)
SidebarPad.PaddingBottom = UDim.new(0, 8)
SidebarPad.PaddingLeft = UDim.new(0, 8)
SidebarPad.PaddingRight = UDim.new(0, 8)
SidebarPad.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -178, 1, -16)
ContentArea.Position = UDim2.fromOffset(170, 8)
ContentArea.BackgroundColor3 = Theme.PanelDark
ContentArea.BackgroundTransparency = 0.25
ContentArea.BorderSizePixel = 0
ContentArea.ClipsDescendants = true
ContentArea.Parent = BodyContainer
addCorner(ContentArea, 12)
addStroke(ContentArea, Theme.StrokeSubtle, 1, 0.45)

-- ============================================================================
-- 6. WIDGET BUILDERS (TOGGLE, SLIDER, BUTTON)
-- ============================================================================
local function createTabPage(tabName: string): ScrollingFrame
	local page = Instance.new("ScrollingFrame")
	page.Name = tabName .. "Page"
	page.Size = UDim2.fromScale(1, 1)
	page.Position = UDim2.fromOffset(0, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = Theme.NeonBlue
	page.CanvasSize = UDim2.fromOffset(0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = ContentArea

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 10)
	pad.PaddingBottom = UDim.new(0, 10)
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = page

	return page
end

local function createToggle(parent: Instance, labelText: string, initial: boolean, onChanged: (boolean) -> ())
	local active = initial

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 44)
	card.BackgroundColor3 = Theme.CardDark
	card.BorderSizePixel = 0
	card.Parent = parent
	addCorner(card, 10)
	addStroke(card, Theme.StrokeSubtle, 1, 0.45)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -72, 1, 0)
	label.Position = UDim2.fromOffset(12, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Theme.TextPrimary
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.Parent = card

	local track = Instance.new("TextButton")
	track.Size = UDim2.fromOffset(44, 24)
	track.Position = UDim2.new(1, -56, 0.5, -12)
	track.BackgroundColor3 = active and Theme.NeonPurple or Theme.ToggleOff
	track.Text = ""
	track.AutoButtonColor = false
	track.Parent = card
	addCorner(track, 12)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(18, 18)
	knob.Position = active and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3)
	knob.BackgroundColor3 = Theme.TextPrimary
	knob.BorderSizePixel = 0
	knob.Parent = track
	addCorner(knob, 9)

	local function refreshVisual()
		tween(
			track,
			TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundColor3 = active and Theme.NeonPurple or Theme.ToggleOff }
		)
		tween(
			knob,
			TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = active and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3) }
		)
	end

	local function toggleValue()
		active = not active
		refreshVisual()
		onChanged(active)
	end

	trackConnection(track.MouseButton1Click:Connect(toggleValue))
	trackConnection(card.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			toggleValue()
		end
	end))
end

local function createSlider(
	parent: Instance,
	labelText: string,
	minVal: number,
	maxVal: number,
	defaultVal: number,
	onChanged: (number) -> ()
)
	local current = math.clamp(defaultVal, minVal, maxVal)

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 56)
	card.BackgroundColor3 = Theme.CardDark
	card.BorderSizePixel = 0
	card.Parent = parent
	addCorner(card, 10)
	addStroke(card, Theme.StrokeSubtle, 1, 0.45)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0.7, 0, 0, 22)
	title.Position = UDim2.fromOffset(12, 6)
	title.BackgroundTransparency = 1
	title.Text = labelText
	title.TextColor3 = Theme.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamMedium
	title.TextSize = 13
	title.Parent = card

	local valueLbl = Instance.new("TextLabel")
	valueLbl.Size = UDim2.new(0.3, -16, 0, 22)
	valueLbl.Position = UDim2.new(0.7, 0, 0, 6)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Text = tostring(math.floor(current))
	valueLbl.TextColor3 = Theme.NeonBlue
	valueLbl.TextXAlignment = Enum.TextXAlignment.Right
	valueLbl.Font = Enum.Font.GothamBold
	valueLbl.TextSize = 12
	valueLbl.Parent = card

	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.new(1, -24, 0, 8)
	barBg.Position = UDim2.fromOffset(12, 36)
	barBg.BackgroundColor3 = Theme.ToggleOff
	barBg.BorderSizePixel = 0
	barBg.Parent = card
	addCorner(barBg, 4)

	local ratio = (current - minVal) / math.max(maxVal - minVal, 1)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(ratio, 0, 1, 0)
	fill.BackgroundColor3 = Theme.NeonBlue
	fill.BorderSizePixel = 0
	fill.Parent = barBg
	addCorner(fill, 4)
	addNeonGradient(fill, 0)

	local sliding = false

	local function updateFromX(posX: number)
		local alpha = math.clamp((posX - barBg.AbsolutePosition.X) / math.max(barBg.AbsoluteSize.X, 1), 0, 1)
		local val = math.floor(minVal + (maxVal - minVal) * alpha + 0.5)
		current = val
		valueLbl.Text = tostring(val)
		tween(fill, TweenInfo.new(0.06, Enum.EasingStyle.Linear), { Size = UDim2.new(alpha, 0, 1, 0) })
		onChanged(val)
	end

	trackConnection(barBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			updateFromX(input.Position.X)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					sliding = false
				end
			end)
		end
	end))

	trackConnection(UserInputService.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromX(input.Position.X)
		end
	end))
end

local function createButton(parent: Instance, labelText: string, onClick: () -> ())
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.BackgroundColor3 = Theme.CardDark
	btn.Text = labelText
	btn.TextColor3 = Theme.TextPrimary
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.AutoButtonColor = false
	btn.Parent = parent
	addCorner(btn, 10)
	local stroke = addStroke(btn, Theme.NeonAccent, 1.1, 0.35)
	addNeonGradient(stroke, 20)

	local function trigger()
		tween(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), { BackgroundColor3 = Theme.CardHover })
		task.delay(0.12, function()
			tween(btn, TweenInfo.new(0.14, Enum.EasingStyle.Quad), { BackgroundColor3 = Theme.CardDark })
		end)
		onClick()
	end

	trackConnection(btn.MouseButton1Click:Connect(trigger))
	trackConnection(btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			trigger()
		end
	end))
end

-- ============================================================================
-- 7. POPULATE 8 TABS & SMOOTH TAB TRANSITION
-- ============================================================================
local TabOrder = { "Aim", "ESP", "Player", "Movement", "Chams", "Spinbot", "Gun", "Info" }
local TabButtons: { [string]: TextButton } = {}
local TabPages: { [string]: ScrollingFrame } = {}

local function selectTab(name: string)
	if State.ActiveTab == name and TabPages[name] and TabPages[name].Visible then
		return
	end
	State.ActiveTab = name

	for tabName, btn in pairs(TabButtons) do
		local isSelected = (tabName == name)
		tween(
			btn,
			TweenInfo.new(0.18, Enum.EasingStyle.Quad),
			{
				BackgroundColor3 = isSelected and Theme.CardHover or Theme.CardDark,
				TextColor3 = isSelected and Theme.NeonBlue or Theme.TextMuted,
			}
		)
	end

	for tabName, page in pairs(TabPages) do
		if tabName == name then
			page.Position = UDim2.fromOffset(0, 12)
			page.Visible = true
			tween(page, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(0, 0),
			})
		else
			page.Visible = false
		end
	end
end

for idx, tabName in ipairs(TabOrder) do
	local iconData = LucideIcons[tabName] or { id = "", glyph = "•" }
	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = "Tab_" .. tabName
	tabBtn.LayoutOrder = idx
	tabBtn.Size = UDim2.new(1, 0, 0, 36)
	tabBtn.BackgroundColor3 = Theme.CardDark
	tabBtn.Text = string.format(" %s  %s", iconData.glyph, tabName)
	tabBtn.TextColor3 = Theme.TextMuted
	tabBtn.TextXAlignment = Enum.TextXAlignment.Left
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.TextSize = 12
	tabBtn.AutoButtonColor = false
	tabBtn.Parent = Sidebar
	addCorner(tabBtn, 8)
	addStroke(tabBtn, Theme.StrokeSubtle, 1, 0.5)

	TabButtons[tabName] = tabBtn
	TabPages[tabName] = createTabPage(tabName)

	trackConnection(tabBtn.MouseButton1Click:Connect(function()
		selectTab(tabName)
	end))
end

-- 1) Aim Tab
createToggle(TabPages.Aim, "Enable Aim Assist (Client)", State.Flags.AimEnabled, function(v)
	State.Flags.AimEnabled = v
end)
createSlider(TabPages.Aim, "FOV Radius", 30, 360, State.Flags.AimFOV, function(v)
	State.Flags.AimFOV = v
end)
createSlider(TabPages.Aim, "Smoothness", 1, 50, State.Flags.AimSmoothness, function(v)
	State.Flags.AimSmoothness = v
end)
createButton(TabPages.Aim, "Reset Aim Settings", function()
	State.Flags.AimFOV = 120
	State.Flags.AimSmoothness = 15
end)

-- 2) ESP Tab
createToggle(TabPages.ESP, "Highlight Players (ESP)", State.Flags.ESPEnabled, function(v)
	State.Flags.ESPEnabled = v
end)
createSlider(TabPages.ESP, "Max Render Distance", 50, 1500, State.Flags.ESPMaxDist, function(v)
	State.Flags.ESPMaxDist = v
end)
createButton(TabPages.ESP, "Refresh ESP Highlights", function()
end)

-- 3) Player Tab
createToggle(TabPages.Player, "Custom WalkSpeed", State.Flags.CustomSpeedEnabled, function(v)
	State.Flags.CustomSpeedEnabled = v
end)
createSlider(TabPages.Player, "WalkSpeed", 16, 100, State.Flags.WalkSpeed, function(v)
	State.Flags.WalkSpeed = v
end)
createSlider(TabPages.Player, "JumpPower", 50, 150, State.Flags.JumpPower, function(v)
	State.Flags.JumpPower = v
end)
createButton(TabPages.Player, "Restore Default Stats", function()
	State.Flags.WalkSpeed = 16
	State.Flags.JumpPower = 50
end)

-- 4) Movement Tab
createToggle(TabPages.Movement, "Auto Hop Assist", State.Flags.BHopEnabled, function(v)
	State.Flags.BHopEnabled = v
end)
createButton(TabPages.Movement, "Teleport to SpawnLocation", function()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
	if hrp and spawn then
		hrp.CFrame = spawn.CFrame + Vector3.new(0, 4, 0)
	end
end)

-- 5) Chams Tab
createToggle(TabPages.Chams, "Neon Chams Overlay", State.Flags.ChamsEnabled, function(v)
	State.Flags.ChamsEnabled = v
end)
createSlider(TabPages.Chams, "Fill Transparency (%)", 0, 100, State.Flags.ChamsFillAlpha, function(v)
	State.Flags.ChamsFillAlpha = v
end)
createButton(TabPages.Chams, "Cycle Neon Palette", function()
	local tmp = Theme.NeonBlue
	Theme.NeonBlue = Theme.NeonPurple
	Theme.NeonPurple = tmp
end)

-- 6) Spinbot Tab
createToggle(TabPages.Spinbot, "Character Spinbot", State.Flags.SpinbotEnabled, function(v)
	State.Flags.SpinbotEnabled = v
end)
createSlider(TabPages.Spinbot, "Spin Velocity", 1, 80, State.Flags.SpinSpeed, function(v)
	State.Flags.SpinSpeed = v
end)
createButton(TabPages.Spinbot, "Stop Rotation", function()
	State.Flags.SpinbotEnabled = false
end)

-- 7) Gun Tab
createToggle(TabPages.Gun, "Stabilize Camera Recoil", State.Flags.NoRecoilEnabled, function(v)
	State.Flags.NoRecoilEnabled = v
end)
createSlider(TabPages.Gun, "Fire Rate Multiplier (%)", 50, 200, State.Flags.FireRateScale, function(v)
	State.Flags.FireRateScale = v
end)
createButton(TabPages.Gun, "Reset Weapon Profile", function()
	State.Flags.NoRecoilEnabled = false
	State.Flags.FireRateScale = 100
end)

-- 8) Info Tab
createButton(TabPages.Info, "Toggle UI Visibility", function()
	setWindowOpen(not State.Open)
end)
createButton(TabPages.Info, "Clean Up Connections", function()
	for _, conn in ipairs(RuntimeConnections) do
		if conn.Connected then
			conn:Disconnect()
		end
	end
	table.clear(RuntimeConnections)
end)

-- ============================================================================
-- 8. RUNTIME LOOP (WALK SPEED & SPINBOT)
-- ============================================================================
trackConnection(RunService.RenderStepped:Connect(function(dt: number)
	local char = LocalPlayer.Character
	if not char then
		return
	end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid and State.Flags.CustomSpeedEnabled then
		humanoid.WalkSpeed = State.Flags.WalkSpeed
		humanoid.JumpPower = State.Flags.JumpPower
	end

	local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hrp and State.Flags.SpinbotEnabled then
		local angularSpeed = math.rad(State.Flags.SpinSpeed * 18) * dt
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, angularSpeed, 0)
	end
end))

-- ============================================================================
-- 9. EXTENDED THEME & CONFIG PRESET REGISTRY (~200 KB BUNDLE)
-- ============================================================================
local ConfigPresets = {
	["Preset_001_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #001 for Arena environments.",
		Settings = {
			AimFOV = 67,
			AimSmoothness = 8,
			ESPMaxDist = 225,
			WalkSpeed = 18,
			JumpPower = 53,
			ChamsFillAlpha = 25,
			SpinSpeed = 14,
			FireRateScale = 85,
		},
	},
	["Preset_002_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #002 for Obby environments.",
		Settings = {
			AimFOV = 74,
			AimSmoothness = 11,
			ESPMaxDist = 250,
			WalkSpeed = 20,
			JumpPower = 56,
			ChamsFillAlpha = 30,
			SpinSpeed = 18,
			FireRateScale = 90,
		},
	},
	["Preset_003_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #003 for Sandbox environments.",
		Settings = {
			AimFOV = 81,
			AimSmoothness = 14,
			ESPMaxDist = 275,
			WalkSpeed = 22,
			JumpPower = 59,
			ChamsFillAlpha = 35,
			SpinSpeed = 22,
			FireRateScale = 95,
		},
	},
	["Preset_004_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #004 for Tactical environments.",
		Settings = {
			AimFOV = 88,
			AimSmoothness = 17,
			ESPMaxDist = 300,
			WalkSpeed = 24,
			JumpPower = 62,
			ChamsFillAlpha = 40,
			SpinSpeed = 26,
			FireRateScale = 100,
		},
	},
	["Preset_005_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #005 for Parkour environments.",
		Settings = {
			AimFOV = 95,
			AimSmoothness = 20,
			ESPMaxDist = 325,
			WalkSpeed = 26,
			JumpPower = 65,
			ChamsFillAlpha = 45,
			SpinSpeed = 30,
			FireRateScale = 105,
		},
	},
	["Preset_006_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #006 for Shooter environments.",
		Settings = {
			AimFOV = 102,
			AimSmoothness = 23,
			ESPMaxDist = 350,
			WalkSpeed = 28,
			JumpPower = 68,
			ChamsFillAlpha = 50,
			SpinSpeed = 34,
			FireRateScale = 110,
		},
	},
	["Preset_007_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #007 for Racing environments.",
		Settings = {
			AimFOV = 109,
			AimSmoothness = 26,
			ESPMaxDist = 375,
			WalkSpeed = 30,
			JumpPower = 71,
			ChamsFillAlpha = 55,
			SpinSpeed = 38,
			FireRateScale = 115,
		},
	},
	["Preset_008_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #008 for Survival environments.",
		Settings = {
			AimFOV = 116,
			AimSmoothness = 29,
			ESPMaxDist = 400,
			WalkSpeed = 32,
			JumpPower = 74,
			ChamsFillAlpha = 60,
			SpinSpeed = 42,
			FireRateScale = 120,
		},
	},
	["Preset_009_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #009 for Simulator environments.",
		Settings = {
			AimFOV = 123,
			AimSmoothness = 32,
			ESPMaxDist = 425,
			WalkSpeed = 34,
			JumpPower = 77,
			ChamsFillAlpha = 65,
			SpinSpeed = 46,
			FireRateScale = 125,
		},
	},
	["Preset_010_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #010 for Duel environments.",
		Settings = {
			AimFOV = 130,
			AimSmoothness = 35,
			ESPMaxDist = 450,
			WalkSpeed = 36,
			JumpPower = 80,
			ChamsFillAlpha = 70,
			SpinSpeed = 50,
			FireRateScale = 130,
		},
	},
	["Preset_011_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #011 for Arena environments.",
		Settings = {
			AimFOV = 137,
			AimSmoothness = 38,
			ESPMaxDist = 475,
			WalkSpeed = 38,
			JumpPower = 83,
			ChamsFillAlpha = 75,
			SpinSpeed = 54,
			FireRateScale = 135,
		},
	},
	["Preset_012_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #012 for Obby environments.",
		Settings = {
			AimFOV = 144,
			AimSmoothness = 41,
			ESPMaxDist = 500,
			WalkSpeed = 40,
			JumpPower = 86,
			ChamsFillAlpha = 80,
			SpinSpeed = 58,
			FireRateScale = 140,
		},
	},
	["Preset_013_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #013 for Sandbox environments.",
		Settings = {
			AimFOV = 151,
			AimSmoothness = 44,
			ESPMaxDist = 525,
			WalkSpeed = 42,
			JumpPower = 89,
			ChamsFillAlpha = 85,
			SpinSpeed = 62,
			FireRateScale = 145,
		},
	},
	["Preset_014_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #014 for Tactical environments.",
		Settings = {
			AimFOV = 158,
			AimSmoothness = 47,
			ESPMaxDist = 550,
			WalkSpeed = 44,
			JumpPower = 92,
			ChamsFillAlpha = 20,
			SpinSpeed = 66,
			FireRateScale = 150,
		},
	},
	["Preset_015_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #015 for Parkour environments.",
		Settings = {
			AimFOV = 165,
			AimSmoothness = 5,
			ESPMaxDist = 575,
			WalkSpeed = 46,
			JumpPower = 95,
			ChamsFillAlpha = 25,
			SpinSpeed = 70,
			FireRateScale = 155,
		},
	},
	["Preset_016_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #016 for Shooter environments.",
		Settings = {
			AimFOV = 172,
			AimSmoothness = 8,
			ESPMaxDist = 600,
			WalkSpeed = 48,
			JumpPower = 98,
			ChamsFillAlpha = 30,
			SpinSpeed = 74,
			FireRateScale = 160,
		},
	},
	["Preset_017_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #017 for Racing environments.",
		Settings = {
			AimFOV = 179,
			AimSmoothness = 11,
			ESPMaxDist = 625,
			WalkSpeed = 50,
			JumpPower = 101,
			ChamsFillAlpha = 35,
			SpinSpeed = 13,
			FireRateScale = 165,
		},
	},
	["Preset_018_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #018 for Survival environments.",
		Settings = {
			AimFOV = 186,
			AimSmoothness = 14,
			ESPMaxDist = 650,
			WalkSpeed = 52,
			JumpPower = 104,
			ChamsFillAlpha = 40,
			SpinSpeed = 17,
			FireRateScale = 170,
		},
	},
	["Preset_019_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #019 for Simulator environments.",
		Settings = {
			AimFOV = 193,
			AimSmoothness = 17,
			ESPMaxDist = 675,
			WalkSpeed = 54,
			JumpPower = 107,
			ChamsFillAlpha = 45,
			SpinSpeed = 21,
			FireRateScale = 175,
		},
	},
	["Preset_020_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #020 for Duel environments.",
		Settings = {
			AimFOV = 200,
			AimSmoothness = 20,
			ESPMaxDist = 700,
			WalkSpeed = 56,
			JumpPower = 110,
			ChamsFillAlpha = 50,
			SpinSpeed = 25,
			FireRateScale = 180,
		},
	},
	["Preset_021_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #021 for Arena environments.",
		Settings = {
			AimFOV = 207,
			AimSmoothness = 23,
			ESPMaxDist = 725,
			WalkSpeed = 58,
			JumpPower = 113,
			ChamsFillAlpha = 55,
			SpinSpeed = 29,
			FireRateScale = 185,
		},
	},
	["Preset_022_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #022 for Obby environments.",
		Settings = {
			AimFOV = 214,
			AimSmoothness = 26,
			ESPMaxDist = 750,
			WalkSpeed = 60,
			JumpPower = 116,
			ChamsFillAlpha = 60,
			SpinSpeed = 33,
			FireRateScale = 80,
		},
	},
	["Preset_023_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #023 for Sandbox environments.",
		Settings = {
			AimFOV = 221,
			AimSmoothness = 29,
			ESPMaxDist = 775,
			WalkSpeed = 62,
			JumpPower = 119,
			ChamsFillAlpha = 65,
			SpinSpeed = 37,
			FireRateScale = 85,
		},
	},
	["Preset_024_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #024 for Tactical environments.",
		Settings = {
			AimFOV = 228,
			AimSmoothness = 32,
			ESPMaxDist = 800,
			WalkSpeed = 64,
			JumpPower = 122,
			ChamsFillAlpha = 70,
			SpinSpeed = 41,
			FireRateScale = 90,
		},
	},
	["Preset_025_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #025 for Parkour environments.",
		Settings = {
			AimFOV = 235,
			AimSmoothness = 35,
			ESPMaxDist = 825,
			WalkSpeed = 66,
			JumpPower = 125,
			ChamsFillAlpha = 75,
			SpinSpeed = 45,
			FireRateScale = 95,
		},
	},
	["Preset_026_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #026 for Shooter environments.",
		Settings = {
			AimFOV = 242,
			AimSmoothness = 38,
			ESPMaxDist = 850,
			WalkSpeed = 68,
			JumpPower = 128,
			ChamsFillAlpha = 80,
			SpinSpeed = 49,
			FireRateScale = 100,
		},
	},
	["Preset_027_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #027 for Racing environments.",
		Settings = {
			AimFOV = 249,
			AimSmoothness = 41,
			ESPMaxDist = 875,
			WalkSpeed = 70,
			JumpPower = 131,
			ChamsFillAlpha = 85,
			SpinSpeed = 53,
			FireRateScale = 105,
		},
	},
	["Preset_028_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #028 for Survival environments.",
		Settings = {
			AimFOV = 256,
			AimSmoothness = 44,
			ESPMaxDist = 900,
			WalkSpeed = 72,
			JumpPower = 134,
			ChamsFillAlpha = 20,
			SpinSpeed = 57,
			FireRateScale = 110,
		},
	},
	["Preset_029_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #029 for Simulator environments.",
		Settings = {
			AimFOV = 263,
			AimSmoothness = 47,
			ESPMaxDist = 925,
			WalkSpeed = 74,
			JumpPower = 52,
			ChamsFillAlpha = 25,
			SpinSpeed = 61,
			FireRateScale = 115,
		},
	},
	["Preset_030_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #030 for Duel environments.",
		Settings = {
			AimFOV = 270,
			AimSmoothness = 5,
			ESPMaxDist = 950,
			WalkSpeed = 76,
			JumpPower = 55,
			ChamsFillAlpha = 30,
			SpinSpeed = 65,
			FireRateScale = 120,
		},
	},
	["Preset_031_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #031 for Arena environments.",
		Settings = {
			AimFOV = 277,
			AimSmoothness = 8,
			ESPMaxDist = 975,
			WalkSpeed = 78,
			JumpPower = 58,
			ChamsFillAlpha = 35,
			SpinSpeed = 69,
			FireRateScale = 125,
		},
	},
	["Preset_032_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #032 for Obby environments.",
		Settings = {
			AimFOV = 284,
			AimSmoothness = 11,
			ESPMaxDist = 1000,
			WalkSpeed = 16,
			JumpPower = 61,
			ChamsFillAlpha = 40,
			SpinSpeed = 73,
			FireRateScale = 130,
		},
	},
	["Preset_033_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #033 for Sandbox environments.",
		Settings = {
			AimFOV = 291,
			AimSmoothness = 14,
			ESPMaxDist = 1025,
			WalkSpeed = 18,
			JumpPower = 64,
			ChamsFillAlpha = 45,
			SpinSpeed = 12,
			FireRateScale = 135,
		},
	},
	["Preset_034_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #034 for Tactical environments.",
		Settings = {
			AimFOV = 298,
			AimSmoothness = 17,
			ESPMaxDist = 1050,
			WalkSpeed = 20,
			JumpPower = 67,
			ChamsFillAlpha = 50,
			SpinSpeed = 16,
			FireRateScale = 140,
		},
	},
	["Preset_035_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #035 for Parkour environments.",
		Settings = {
			AimFOV = 305,
			AimSmoothness = 20,
			ESPMaxDist = 1075,
			WalkSpeed = 22,
			JumpPower = 70,
			ChamsFillAlpha = 55,
			SpinSpeed = 20,
			FireRateScale = 145,
		},
	},
	["Preset_036_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #036 for Shooter environments.",
		Settings = {
			AimFOV = 312,
			AimSmoothness = 23,
			ESPMaxDist = 1100,
			WalkSpeed = 24,
			JumpPower = 73,
			ChamsFillAlpha = 60,
			SpinSpeed = 24,
			FireRateScale = 150,
		},
	},
	["Preset_037_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #037 for Racing environments.",
		Settings = {
			AimFOV = 319,
			AimSmoothness = 26,
			ESPMaxDist = 1125,
			WalkSpeed = 26,
			JumpPower = 76,
			ChamsFillAlpha = 65,
			SpinSpeed = 28,
			FireRateScale = 155,
		},
	},
	["Preset_038_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #038 for Survival environments.",
		Settings = {
			AimFOV = 66,
			AimSmoothness = 29,
			ESPMaxDist = 1150,
			WalkSpeed = 28,
			JumpPower = 79,
			ChamsFillAlpha = 70,
			SpinSpeed = 32,
			FireRateScale = 160,
		},
	},
	["Preset_039_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #039 for Simulator environments.",
		Settings = {
			AimFOV = 73,
			AimSmoothness = 32,
			ESPMaxDist = 1175,
			WalkSpeed = 30,
			JumpPower = 82,
			ChamsFillAlpha = 75,
			SpinSpeed = 36,
			FireRateScale = 165,
		},
	},
	["Preset_040_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #040 for Duel environments.",
		Settings = {
			AimFOV = 80,
			AimSmoothness = 35,
			ESPMaxDist = 1200,
			WalkSpeed = 32,
			JumpPower = 85,
			ChamsFillAlpha = 80,
			SpinSpeed = 40,
			FireRateScale = 170,
		},
	},
	["Preset_041_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #041 for Arena environments.",
		Settings = {
			AimFOV = 87,
			AimSmoothness = 38,
			ESPMaxDist = 1225,
			WalkSpeed = 34,
			JumpPower = 88,
			ChamsFillAlpha = 85,
			SpinSpeed = 44,
			FireRateScale = 175,
		},
	},
	["Preset_042_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #042 for Obby environments.",
		Settings = {
			AimFOV = 94,
			AimSmoothness = 41,
			ESPMaxDist = 1250,
			WalkSpeed = 36,
			JumpPower = 91,
			ChamsFillAlpha = 20,
			SpinSpeed = 48,
			FireRateScale = 180,
		},
	},
	["Preset_043_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #043 for Sandbox environments.",
		Settings = {
			AimFOV = 101,
			AimSmoothness = 44,
			ESPMaxDist = 1275,
			WalkSpeed = 38,
			JumpPower = 94,
			ChamsFillAlpha = 25,
			SpinSpeed = 52,
			FireRateScale = 185,
		},
	},
	["Preset_044_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #044 for Tactical environments.",
		Settings = {
			AimFOV = 108,
			AimSmoothness = 47,
			ESPMaxDist = 1300,
			WalkSpeed = 40,
			JumpPower = 97,
			ChamsFillAlpha = 30,
			SpinSpeed = 56,
			FireRateScale = 80,
		},
	},
	["Preset_045_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #045 for Parkour environments.",
		Settings = {
			AimFOV = 115,
			AimSmoothness = 5,
			ESPMaxDist = 1325,
			WalkSpeed = 42,
			JumpPower = 100,
			ChamsFillAlpha = 35,
			SpinSpeed = 60,
			FireRateScale = 85,
		},
	},
	["Preset_046_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #046 for Shooter environments.",
		Settings = {
			AimFOV = 122,
			AimSmoothness = 8,
			ESPMaxDist = 1350,
			WalkSpeed = 44,
			JumpPower = 103,
			ChamsFillAlpha = 40,
			SpinSpeed = 64,
			FireRateScale = 90,
		},
	},
	["Preset_047_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #047 for Racing environments.",
		Settings = {
			AimFOV = 129,
			AimSmoothness = 11,
			ESPMaxDist = 1375,
			WalkSpeed = 46,
			JumpPower = 106,
			ChamsFillAlpha = 45,
			SpinSpeed = 68,
			FireRateScale = 95,
		},
	},
	["Preset_048_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #048 for Survival environments.",
		Settings = {
			AimFOV = 136,
			AimSmoothness = 14,
			ESPMaxDist = 200,
			WalkSpeed = 48,
			JumpPower = 109,
			ChamsFillAlpha = 50,
			SpinSpeed = 72,
			FireRateScale = 100,
		},
	},
	["Preset_049_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #049 for Simulator environments.",
		Settings = {
			AimFOV = 143,
			AimSmoothness = 17,
			ESPMaxDist = 225,
			WalkSpeed = 50,
			JumpPower = 112,
			ChamsFillAlpha = 55,
			SpinSpeed = 11,
			FireRateScale = 105,
		},
	},
	["Preset_050_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #050 for Duel environments.",
		Settings = {
			AimFOV = 150,
			AimSmoothness = 20,
			ESPMaxDist = 250,
			WalkSpeed = 52,
			JumpPower = 115,
			ChamsFillAlpha = 60,
			SpinSpeed = 15,
			FireRateScale = 110,
		},
	},
	["Preset_051_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #051 for Arena environments.",
		Settings = {
			AimFOV = 157,
			AimSmoothness = 23,
			ESPMaxDist = 275,
			WalkSpeed = 54,
			JumpPower = 118,
			ChamsFillAlpha = 65,
			SpinSpeed = 19,
			FireRateScale = 115,
		},
	},
	["Preset_052_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #052 for Obby environments.",
		Settings = {
			AimFOV = 164,
			AimSmoothness = 26,
			ESPMaxDist = 300,
			WalkSpeed = 56,
			JumpPower = 121,
			ChamsFillAlpha = 70,
			SpinSpeed = 23,
			FireRateScale = 120,
		},
	},
	["Preset_053_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #053 for Sandbox environments.",
		Settings = {
			AimFOV = 171,
			AimSmoothness = 29,
			ESPMaxDist = 325,
			WalkSpeed = 58,
			JumpPower = 124,
			ChamsFillAlpha = 75,
			SpinSpeed = 27,
			FireRateScale = 125,
		},
	},
	["Preset_054_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #054 for Tactical environments.",
		Settings = {
			AimFOV = 178,
			AimSmoothness = 32,
			ESPMaxDist = 350,
			WalkSpeed = 60,
			JumpPower = 127,
			ChamsFillAlpha = 80,
			SpinSpeed = 31,
			FireRateScale = 130,
		},
	},
	["Preset_055_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #055 for Parkour environments.",
		Settings = {
			AimFOV = 185,
			AimSmoothness = 35,
			ESPMaxDist = 375,
			WalkSpeed = 62,
			JumpPower = 130,
			ChamsFillAlpha = 85,
			SpinSpeed = 35,
			FireRateScale = 135,
		},
	},
	["Preset_056_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #056 for Shooter environments.",
		Settings = {
			AimFOV = 192,
			AimSmoothness = 38,
			ESPMaxDist = 400,
			WalkSpeed = 64,
			JumpPower = 133,
			ChamsFillAlpha = 20,
			SpinSpeed = 39,
			FireRateScale = 140,
		},
	},
	["Preset_057_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #057 for Racing environments.",
		Settings = {
			AimFOV = 199,
			AimSmoothness = 41,
			ESPMaxDist = 425,
			WalkSpeed = 66,
			JumpPower = 51,
			ChamsFillAlpha = 25,
			SpinSpeed = 43,
			FireRateScale = 145,
		},
	},
	["Preset_058_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #058 for Survival environments.",
		Settings = {
			AimFOV = 206,
			AimSmoothness = 44,
			ESPMaxDist = 450,
			WalkSpeed = 68,
			JumpPower = 54,
			ChamsFillAlpha = 30,
			SpinSpeed = 47,
			FireRateScale = 150,
		},
	},
	["Preset_059_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #059 for Simulator environments.",
		Settings = {
			AimFOV = 213,
			AimSmoothness = 47,
			ESPMaxDist = 475,
			WalkSpeed = 70,
			JumpPower = 57,
			ChamsFillAlpha = 35,
			SpinSpeed = 51,
			FireRateScale = 155,
		},
	},
	["Preset_060_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #060 for Duel environments.",
		Settings = {
			AimFOV = 220,
			AimSmoothness = 5,
			ESPMaxDist = 500,
			WalkSpeed = 72,
			JumpPower = 60,
			ChamsFillAlpha = 40,
			SpinSpeed = 55,
			FireRateScale = 160,
		},
	},
	["Preset_061_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #061 for Arena environments.",
		Settings = {
			AimFOV = 227,
			AimSmoothness = 8,
			ESPMaxDist = 525,
			WalkSpeed = 74,
			JumpPower = 63,
			ChamsFillAlpha = 45,
			SpinSpeed = 59,
			FireRateScale = 165,
		},
	},
	["Preset_062_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #062 for Obby environments.",
		Settings = {
			AimFOV = 234,
			AimSmoothness = 11,
			ESPMaxDist = 550,
			WalkSpeed = 76,
			JumpPower = 66,
			ChamsFillAlpha = 50,
			SpinSpeed = 63,
			FireRateScale = 170,
		},
	},
	["Preset_063_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #063 for Sandbox environments.",
		Settings = {
			AimFOV = 241,
			AimSmoothness = 14,
			ESPMaxDist = 575,
			WalkSpeed = 78,
			JumpPower = 69,
			ChamsFillAlpha = 55,
			SpinSpeed = 67,
			FireRateScale = 175,
		},
	},
	["Preset_064_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #064 for Tactical environments.",
		Settings = {
			AimFOV = 248,
			AimSmoothness = 17,
			ESPMaxDist = 600,
			WalkSpeed = 16,
			JumpPower = 72,
			ChamsFillAlpha = 60,
			SpinSpeed = 71,
			FireRateScale = 180,
		},
	},
	["Preset_065_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #065 for Parkour environments.",
		Settings = {
			AimFOV = 255,
			AimSmoothness = 20,
			ESPMaxDist = 625,
			WalkSpeed = 18,
			JumpPower = 75,
			ChamsFillAlpha = 65,
			SpinSpeed = 10,
			FireRateScale = 185,
		},
	},
	["Preset_066_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #066 for Shooter environments.",
		Settings = {
			AimFOV = 262,
			AimSmoothness = 23,
			ESPMaxDist = 650,
			WalkSpeed = 20,
			JumpPower = 78,
			ChamsFillAlpha = 70,
			SpinSpeed = 14,
			FireRateScale = 80,
		},
	},
	["Preset_067_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #067 for Racing environments.",
		Settings = {
			AimFOV = 269,
			AimSmoothness = 26,
			ESPMaxDist = 675,
			WalkSpeed = 22,
			JumpPower = 81,
			ChamsFillAlpha = 75,
			SpinSpeed = 18,
			FireRateScale = 85,
		},
	},
	["Preset_068_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #068 for Survival environments.",
		Settings = {
			AimFOV = 276,
			AimSmoothness = 29,
			ESPMaxDist = 700,
			WalkSpeed = 24,
			JumpPower = 84,
			ChamsFillAlpha = 80,
			SpinSpeed = 22,
			FireRateScale = 90,
		},
	},
	["Preset_069_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #069 for Simulator environments.",
		Settings = {
			AimFOV = 283,
			AimSmoothness = 32,
			ESPMaxDist = 725,
			WalkSpeed = 26,
			JumpPower = 87,
			ChamsFillAlpha = 85,
			SpinSpeed = 26,
			FireRateScale = 95,
		},
	},
	["Preset_070_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #070 for Duel environments.",
		Settings = {
			AimFOV = 290,
			AimSmoothness = 35,
			ESPMaxDist = 750,
			WalkSpeed = 28,
			JumpPower = 90,
			ChamsFillAlpha = 20,
			SpinSpeed = 30,
			FireRateScale = 100,
		},
	},
	["Preset_071_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #071 for Arena environments.",
		Settings = {
			AimFOV = 297,
			AimSmoothness = 38,
			ESPMaxDist = 775,
			WalkSpeed = 30,
			JumpPower = 93,
			ChamsFillAlpha = 25,
			SpinSpeed = 34,
			FireRateScale = 105,
		},
	},
	["Preset_072_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #072 for Obby environments.",
		Settings = {
			AimFOV = 304,
			AimSmoothness = 41,
			ESPMaxDist = 800,
			WalkSpeed = 32,
			JumpPower = 96,
			ChamsFillAlpha = 30,
			SpinSpeed = 38,
			FireRateScale = 110,
		},
	},
	["Preset_073_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #073 for Sandbox environments.",
		Settings = {
			AimFOV = 311,
			AimSmoothness = 44,
			ESPMaxDist = 825,
			WalkSpeed = 34,
			JumpPower = 99,
			ChamsFillAlpha = 35,
			SpinSpeed = 42,
			FireRateScale = 115,
		},
	},
	["Preset_074_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #074 for Tactical environments.",
		Settings = {
			AimFOV = 318,
			AimSmoothness = 47,
			ESPMaxDist = 850,
			WalkSpeed = 36,
			JumpPower = 102,
			ChamsFillAlpha = 40,
			SpinSpeed = 46,
			FireRateScale = 120,
		},
	},
	["Preset_075_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #075 for Parkour environments.",
		Settings = {
			AimFOV = 65,
			AimSmoothness = 5,
			ESPMaxDist = 875,
			WalkSpeed = 38,
			JumpPower = 105,
			ChamsFillAlpha = 45,
			SpinSpeed = 50,
			FireRateScale = 125,
		},
	},
	["Preset_076_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #076 for Shooter environments.",
		Settings = {
			AimFOV = 72,
			AimSmoothness = 8,
			ESPMaxDist = 900,
			WalkSpeed = 40,
			JumpPower = 108,
			ChamsFillAlpha = 50,
			SpinSpeed = 54,
			FireRateScale = 130,
		},
	},
	["Preset_077_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #077 for Racing environments.",
		Settings = {
			AimFOV = 79,
			AimSmoothness = 11,
			ESPMaxDist = 925,
			WalkSpeed = 42,
			JumpPower = 111,
			ChamsFillAlpha = 55,
			SpinSpeed = 58,
			FireRateScale = 135,
		},
	},
	["Preset_078_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #078 for Survival environments.",
		Settings = {
			AimFOV = 86,
			AimSmoothness = 14,
			ESPMaxDist = 950,
			WalkSpeed = 44,
			JumpPower = 114,
			ChamsFillAlpha = 60,
			SpinSpeed = 62,
			FireRateScale = 140,
		},
	},
	["Preset_079_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #079 for Simulator environments.",
		Settings = {
			AimFOV = 93,
			AimSmoothness = 17,
			ESPMaxDist = 975,
			WalkSpeed = 46,
			JumpPower = 117,
			ChamsFillAlpha = 65,
			SpinSpeed = 66,
			FireRateScale = 145,
		},
	},
	["Preset_080_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #080 for Duel environments.",
		Settings = {
			AimFOV = 100,
			AimSmoothness = 20,
			ESPMaxDist = 1000,
			WalkSpeed = 48,
			JumpPower = 120,
			ChamsFillAlpha = 70,
			SpinSpeed = 70,
			FireRateScale = 150,
		},
	},
	["Preset_081_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #081 for Arena environments.",
		Settings = {
			AimFOV = 107,
			AimSmoothness = 23,
			ESPMaxDist = 1025,
			WalkSpeed = 50,
			JumpPower = 123,
			ChamsFillAlpha = 75,
			SpinSpeed = 74,
			FireRateScale = 155,
		},
	},
	["Preset_082_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #082 for Obby environments.",
		Settings = {
			AimFOV = 114,
			AimSmoothness = 26,
			ESPMaxDist = 1050,
			WalkSpeed = 52,
			JumpPower = 126,
			ChamsFillAlpha = 80,
			SpinSpeed = 13,
			FireRateScale = 160,
		},
	},
	["Preset_083_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #083 for Sandbox environments.",
		Settings = {
			AimFOV = 121,
			AimSmoothness = 29,
			ESPMaxDist = 1075,
			WalkSpeed = 54,
			JumpPower = 129,
			ChamsFillAlpha = 85,
			SpinSpeed = 17,
			FireRateScale = 165,
		},
	},
	["Preset_084_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #084 for Tactical environments.",
		Settings = {
			AimFOV = 128,
			AimSmoothness = 32,
			ESPMaxDist = 1100,
			WalkSpeed = 56,
			JumpPower = 132,
			ChamsFillAlpha = 20,
			SpinSpeed = 21,
			FireRateScale = 170,
		},
	},
	["Preset_085_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #085 for Parkour environments.",
		Settings = {
			AimFOV = 135,
			AimSmoothness = 35,
			ESPMaxDist = 1125,
			WalkSpeed = 58,
			JumpPower = 50,
			ChamsFillAlpha = 25,
			SpinSpeed = 25,
			FireRateScale = 175,
		},
	},
	["Preset_086_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #086 for Shooter environments.",
		Settings = {
			AimFOV = 142,
			AimSmoothness = 38,
			ESPMaxDist = 1150,
			WalkSpeed = 60,
			JumpPower = 53,
			ChamsFillAlpha = 30,
			SpinSpeed = 29,
			FireRateScale = 180,
		},
	},
	["Preset_087_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #087 for Racing environments.",
		Settings = {
			AimFOV = 149,
			AimSmoothness = 41,
			ESPMaxDist = 1175,
			WalkSpeed = 62,
			JumpPower = 56,
			ChamsFillAlpha = 35,
			SpinSpeed = 33,
			FireRateScale = 185,
		},
	},
	["Preset_088_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #088 for Survival environments.",
		Settings = {
			AimFOV = 156,
			AimSmoothness = 44,
			ESPMaxDist = 1200,
			WalkSpeed = 64,
			JumpPower = 59,
			ChamsFillAlpha = 40,
			SpinSpeed = 37,
			FireRateScale = 80,
		},
	},
	["Preset_089_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #089 for Simulator environments.",
		Settings = {
			AimFOV = 163,
			AimSmoothness = 47,
			ESPMaxDist = 1225,
			WalkSpeed = 66,
			JumpPower = 62,
			ChamsFillAlpha = 45,
			SpinSpeed = 41,
			FireRateScale = 85,
		},
	},
	["Preset_090_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #090 for Duel environments.",
		Settings = {
			AimFOV = 170,
			AimSmoothness = 5,
			ESPMaxDist = 1250,
			WalkSpeed = 68,
			JumpPower = 65,
			ChamsFillAlpha = 50,
			SpinSpeed = 45,
			FireRateScale = 90,
		},
	},
	["Preset_091_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #091 for Arena environments.",
		Settings = {
			AimFOV = 177,
			AimSmoothness = 8,
			ESPMaxDist = 1275,
			WalkSpeed = 70,
			JumpPower = 68,
			ChamsFillAlpha = 55,
			SpinSpeed = 49,
			FireRateScale = 95,
		},
	},
	["Preset_092_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #092 for Obby environments.",
		Settings = {
			AimFOV = 184,
			AimSmoothness = 11,
			ESPMaxDist = 1300,
			WalkSpeed = 72,
			JumpPower = 71,
			ChamsFillAlpha = 60,
			SpinSpeed = 53,
			FireRateScale = 100,
		},
	},
	["Preset_093_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #093 for Sandbox environments.",
		Settings = {
			AimFOV = 191,
			AimSmoothness = 14,
			ESPMaxDist = 1325,
			WalkSpeed = 74,
			JumpPower = 74,
			ChamsFillAlpha = 65,
			SpinSpeed = 57,
			FireRateScale = 105,
		},
	},
	["Preset_094_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #094 for Tactical environments.",
		Settings = {
			AimFOV = 198,
			AimSmoothness = 17,
			ESPMaxDist = 1350,
			WalkSpeed = 76,
			JumpPower = 77,
			ChamsFillAlpha = 70,
			SpinSpeed = 61,
			FireRateScale = 110,
		},
	},
	["Preset_095_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #095 for Parkour environments.",
		Settings = {
			AimFOV = 205,
			AimSmoothness = 20,
			ESPMaxDist = 1375,
			WalkSpeed = 78,
			JumpPower = 80,
			ChamsFillAlpha = 75,
			SpinSpeed = 65,
			FireRateScale = 115,
		},
	},
	["Preset_096_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #096 for Shooter environments.",
		Settings = {
			AimFOV = 212,
			AimSmoothness = 23,
			ESPMaxDist = 200,
			WalkSpeed = 16,
			JumpPower = 83,
			ChamsFillAlpha = 80,
			SpinSpeed = 69,
			FireRateScale = 120,
		},
	},
	["Preset_097_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #097 for Racing environments.",
		Settings = {
			AimFOV = 219,
			AimSmoothness = 26,
			ESPMaxDist = 225,
			WalkSpeed = 18,
			JumpPower = 86,
			ChamsFillAlpha = 85,
			SpinSpeed = 73,
			FireRateScale = 125,
		},
	},
	["Preset_098_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #098 for Survival environments.",
		Settings = {
			AimFOV = 226,
			AimSmoothness = 29,
			ESPMaxDist = 250,
			WalkSpeed = 20,
			JumpPower = 89,
			ChamsFillAlpha = 20,
			SpinSpeed = 12,
			FireRateScale = 130,
		},
	},
	["Preset_099_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #099 for Simulator environments.",
		Settings = {
			AimFOV = 233,
			AimSmoothness = 32,
			ESPMaxDist = 275,
			WalkSpeed = 22,
			JumpPower = 92,
			ChamsFillAlpha = 25,
			SpinSpeed = 16,
			FireRateScale = 135,
		},
	},
	["Preset_100_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #100 for Duel environments.",
		Settings = {
			AimFOV = 240,
			AimSmoothness = 35,
			ESPMaxDist = 300,
			WalkSpeed = 24,
			JumpPower = 95,
			ChamsFillAlpha = 30,
			SpinSpeed = 20,
			FireRateScale = 140,
		},
	},
	["Preset_101_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #101 for Arena environments.",
		Settings = {
			AimFOV = 247,
			AimSmoothness = 38,
			ESPMaxDist = 325,
			WalkSpeed = 26,
			JumpPower = 98,
			ChamsFillAlpha = 35,
			SpinSpeed = 24,
			FireRateScale = 145,
		},
	},
	["Preset_102_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #102 for Obby environments.",
		Settings = {
			AimFOV = 254,
			AimSmoothness = 41,
			ESPMaxDist = 350,
			WalkSpeed = 28,
			JumpPower = 101,
			ChamsFillAlpha = 40,
			SpinSpeed = 28,
			FireRateScale = 150,
		},
	},
	["Preset_103_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #103 for Sandbox environments.",
		Settings = {
			AimFOV = 261,
			AimSmoothness = 44,
			ESPMaxDist = 375,
			WalkSpeed = 30,
			JumpPower = 104,
			ChamsFillAlpha = 45,
			SpinSpeed = 32,
			FireRateScale = 155,
		},
	},
	["Preset_104_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #104 for Tactical environments.",
		Settings = {
			AimFOV = 268,
			AimSmoothness = 47,
			ESPMaxDist = 400,
			WalkSpeed = 32,
			JumpPower = 107,
			ChamsFillAlpha = 50,
			SpinSpeed = 36,
			FireRateScale = 160,
		},
	},
	["Preset_105_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #105 for Parkour environments.",
		Settings = {
			AimFOV = 275,
			AimSmoothness = 5,
			ESPMaxDist = 425,
			WalkSpeed = 34,
			JumpPower = 110,
			ChamsFillAlpha = 55,
			SpinSpeed = 40,
			FireRateScale = 165,
		},
	},
	["Preset_106_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #106 for Shooter environments.",
		Settings = {
			AimFOV = 282,
			AimSmoothness = 8,
			ESPMaxDist = 450,
			WalkSpeed = 36,
			JumpPower = 113,
			ChamsFillAlpha = 60,
			SpinSpeed = 44,
			FireRateScale = 170,
		},
	},
	["Preset_107_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #107 for Racing environments.",
		Settings = {
			AimFOV = 289,
			AimSmoothness = 11,
			ESPMaxDist = 475,
			WalkSpeed = 38,
			JumpPower = 116,
			ChamsFillAlpha = 65,
			SpinSpeed = 48,
			FireRateScale = 175,
		},
	},
	["Preset_108_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #108 for Survival environments.",
		Settings = {
			AimFOV = 296,
			AimSmoothness = 14,
			ESPMaxDist = 500,
			WalkSpeed = 40,
			JumpPower = 119,
			ChamsFillAlpha = 70,
			SpinSpeed = 52,
			FireRateScale = 180,
		},
	},
	["Preset_109_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #109 for Simulator environments.",
		Settings = {
			AimFOV = 303,
			AimSmoothness = 17,
			ESPMaxDist = 525,
			WalkSpeed = 42,
			JumpPower = 122,
			ChamsFillAlpha = 75,
			SpinSpeed = 56,
			FireRateScale = 185,
		},
	},
	["Preset_110_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #110 for Duel environments.",
		Settings = {
			AimFOV = 310,
			AimSmoothness = 20,
			ESPMaxDist = 550,
			WalkSpeed = 44,
			JumpPower = 125,
			ChamsFillAlpha = 80,
			SpinSpeed = 60,
			FireRateScale = 80,
		},
	},
	["Preset_111_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #111 for Arena environments.",
		Settings = {
			AimFOV = 317,
			AimSmoothness = 23,
			ESPMaxDist = 575,
			WalkSpeed = 46,
			JumpPower = 128,
			ChamsFillAlpha = 85,
			SpinSpeed = 64,
			FireRateScale = 85,
		},
	},
	["Preset_112_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #112 for Obby environments.",
		Settings = {
			AimFOV = 64,
			AimSmoothness = 26,
			ESPMaxDist = 600,
			WalkSpeed = 48,
			JumpPower = 131,
			ChamsFillAlpha = 20,
			SpinSpeed = 68,
			FireRateScale = 90,
		},
	},
	["Preset_113_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #113 for Sandbox environments.",
		Settings = {
			AimFOV = 71,
			AimSmoothness = 29,
			ESPMaxDist = 625,
			WalkSpeed = 50,
			JumpPower = 134,
			ChamsFillAlpha = 25,
			SpinSpeed = 72,
			FireRateScale = 95,
		},
	},
	["Preset_114_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #114 for Tactical environments.",
		Settings = {
			AimFOV = 78,
			AimSmoothness = 32,
			ESPMaxDist = 650,
			WalkSpeed = 52,
			JumpPower = 52,
			ChamsFillAlpha = 30,
			SpinSpeed = 11,
			FireRateScale = 100,
		},
	},
	["Preset_115_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #115 for Parkour environments.",
		Settings = {
			AimFOV = 85,
			AimSmoothness = 35,
			ESPMaxDist = 675,
			WalkSpeed = 54,
			JumpPower = 55,
			ChamsFillAlpha = 35,
			SpinSpeed = 15,
			FireRateScale = 105,
		},
	},
	["Preset_116_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #116 for Shooter environments.",
		Settings = {
			AimFOV = 92,
			AimSmoothness = 38,
			ESPMaxDist = 700,
			WalkSpeed = 56,
			JumpPower = 58,
			ChamsFillAlpha = 40,
			SpinSpeed = 19,
			FireRateScale = 110,
		},
	},
	["Preset_117_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #117 for Racing environments.",
		Settings = {
			AimFOV = 99,
			AimSmoothness = 41,
			ESPMaxDist = 725,
			WalkSpeed = 58,
			JumpPower = 61,
			ChamsFillAlpha = 45,
			SpinSpeed = 23,
			FireRateScale = 115,
		},
	},
	["Preset_118_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #118 for Survival environments.",
		Settings = {
			AimFOV = 106,
			AimSmoothness = 44,
			ESPMaxDist = 750,
			WalkSpeed = 60,
			JumpPower = 64,
			ChamsFillAlpha = 50,
			SpinSpeed = 27,
			FireRateScale = 120,
		},
	},
	["Preset_119_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #119 for Simulator environments.",
		Settings = {
			AimFOV = 113,
			AimSmoothness = 47,
			ESPMaxDist = 775,
			WalkSpeed = 62,
			JumpPower = 67,
			ChamsFillAlpha = 55,
			SpinSpeed = 31,
			FireRateScale = 125,
		},
	},
	["Preset_120_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #120 for Duel environments.",
		Settings = {
			AimFOV = 120,
			AimSmoothness = 5,
			ESPMaxDist = 800,
			WalkSpeed = 64,
			JumpPower = 70,
			ChamsFillAlpha = 60,
			SpinSpeed = 35,
			FireRateScale = 130,
		},
	},
	["Preset_121_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #121 for Arena environments.",
		Settings = {
			AimFOV = 127,
			AimSmoothness = 8,
			ESPMaxDist = 825,
			WalkSpeed = 66,
			JumpPower = 73,
			ChamsFillAlpha = 65,
			SpinSpeed = 39,
			FireRateScale = 135,
		},
	},
	["Preset_122_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #122 for Obby environments.",
		Settings = {
			AimFOV = 134,
			AimSmoothness = 11,
			ESPMaxDist = 850,
			WalkSpeed = 68,
			JumpPower = 76,
			ChamsFillAlpha = 70,
			SpinSpeed = 43,
			FireRateScale = 140,
		},
	},
	["Preset_123_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #123 for Sandbox environments.",
		Settings = {
			AimFOV = 141,
			AimSmoothness = 14,
			ESPMaxDist = 875,
			WalkSpeed = 70,
			JumpPower = 79,
			ChamsFillAlpha = 75,
			SpinSpeed = 47,
			FireRateScale = 145,
		},
	},
	["Preset_124_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #124 for Tactical environments.",
		Settings = {
			AimFOV = 148,
			AimSmoothness = 17,
			ESPMaxDist = 900,
			WalkSpeed = 72,
			JumpPower = 82,
			ChamsFillAlpha = 80,
			SpinSpeed = 51,
			FireRateScale = 150,
		},
	},
	["Preset_125_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #125 for Parkour environments.",
		Settings = {
			AimFOV = 155,
			AimSmoothness = 20,
			ESPMaxDist = 925,
			WalkSpeed = 74,
			JumpPower = 85,
			ChamsFillAlpha = 85,
			SpinSpeed = 55,
			FireRateScale = 155,
		},
	},
	["Preset_126_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #126 for Shooter environments.",
		Settings = {
			AimFOV = 162,
			AimSmoothness = 23,
			ESPMaxDist = 950,
			WalkSpeed = 76,
			JumpPower = 88,
			ChamsFillAlpha = 20,
			SpinSpeed = 59,
			FireRateScale = 160,
		},
	},
	["Preset_127_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #127 for Racing environments.",
		Settings = {
			AimFOV = 169,
			AimSmoothness = 26,
			ESPMaxDist = 975,
			WalkSpeed = 78,
			JumpPower = 91,
			ChamsFillAlpha = 25,
			SpinSpeed = 63,
			FireRateScale = 165,
		},
	},
	["Preset_128_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #128 for Survival environments.",
		Settings = {
			AimFOV = 176,
			AimSmoothness = 29,
			ESPMaxDist = 1000,
			WalkSpeed = 16,
			JumpPower = 94,
			ChamsFillAlpha = 30,
			SpinSpeed = 67,
			FireRateScale = 170,
		},
	},
	["Preset_129_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #129 for Simulator environments.",
		Settings = {
			AimFOV = 183,
			AimSmoothness = 32,
			ESPMaxDist = 1025,
			WalkSpeed = 18,
			JumpPower = 97,
			ChamsFillAlpha = 35,
			SpinSpeed = 71,
			FireRateScale = 175,
		},
	},
	["Preset_130_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #130 for Duel environments.",
		Settings = {
			AimFOV = 190,
			AimSmoothness = 35,
			ESPMaxDist = 1050,
			WalkSpeed = 20,
			JumpPower = 100,
			ChamsFillAlpha = 40,
			SpinSpeed = 10,
			FireRateScale = 180,
		},
	},
	["Preset_131_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #131 for Arena environments.",
		Settings = {
			AimFOV = 197,
			AimSmoothness = 38,
			ESPMaxDist = 1075,
			WalkSpeed = 22,
			JumpPower = 103,
			ChamsFillAlpha = 45,
			SpinSpeed = 14,
			FireRateScale = 185,
		},
	},
	["Preset_132_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #132 for Obby environments.",
		Settings = {
			AimFOV = 204,
			AimSmoothness = 41,
			ESPMaxDist = 1100,
			WalkSpeed = 24,
			JumpPower = 106,
			ChamsFillAlpha = 50,
			SpinSpeed = 18,
			FireRateScale = 80,
		},
	},
	["Preset_133_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #133 for Sandbox environments.",
		Settings = {
			AimFOV = 211,
			AimSmoothness = 44,
			ESPMaxDist = 1125,
			WalkSpeed = 26,
			JumpPower = 109,
			ChamsFillAlpha = 55,
			SpinSpeed = 22,
			FireRateScale = 85,
		},
	},
	["Preset_134_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #134 for Tactical environments.",
		Settings = {
			AimFOV = 218,
			AimSmoothness = 47,
			ESPMaxDist = 1150,
			WalkSpeed = 28,
			JumpPower = 112,
			ChamsFillAlpha = 60,
			SpinSpeed = 26,
			FireRateScale = 90,
		},
	},
	["Preset_135_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #135 for Parkour environments.",
		Settings = {
			AimFOV = 225,
			AimSmoothness = 5,
			ESPMaxDist = 1175,
			WalkSpeed = 30,
			JumpPower = 115,
			ChamsFillAlpha = 65,
			SpinSpeed = 30,
			FireRateScale = 95,
		},
	},
	["Preset_136_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #136 for Shooter environments.",
		Settings = {
			AimFOV = 232,
			AimSmoothness = 8,
			ESPMaxDist = 1200,
			WalkSpeed = 32,
			JumpPower = 118,
			ChamsFillAlpha = 70,
			SpinSpeed = 34,
			FireRateScale = 100,
		},
	},
	["Preset_137_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #137 for Racing environments.",
		Settings = {
			AimFOV = 239,
			AimSmoothness = 11,
			ESPMaxDist = 1225,
			WalkSpeed = 34,
			JumpPower = 121,
			ChamsFillAlpha = 75,
			SpinSpeed = 38,
			FireRateScale = 105,
		},
	},
	["Preset_138_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #138 for Survival environments.",
		Settings = {
			AimFOV = 246,
			AimSmoothness = 14,
			ESPMaxDist = 1250,
			WalkSpeed = 36,
			JumpPower = 124,
			ChamsFillAlpha = 80,
			SpinSpeed = 42,
			FireRateScale = 110,
		},
	},
	["Preset_139_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #139 for Simulator environments.",
		Settings = {
			AimFOV = 253,
			AimSmoothness = 17,
			ESPMaxDist = 1275,
			WalkSpeed = 38,
			JumpPower = 127,
			ChamsFillAlpha = 85,
			SpinSpeed = 46,
			FireRateScale = 115,
		},
	},
	["Preset_140_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #140 for Duel environments.",
		Settings = {
			AimFOV = 260,
			AimSmoothness = 20,
			ESPMaxDist = 1300,
			WalkSpeed = 40,
			JumpPower = 130,
			ChamsFillAlpha = 20,
			SpinSpeed = 50,
			FireRateScale = 120,
		},
	},
	["Preset_141_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #141 for Arena environments.",
		Settings = {
			AimFOV = 267,
			AimSmoothness = 23,
			ESPMaxDist = 1325,
			WalkSpeed = 42,
			JumpPower = 133,
			ChamsFillAlpha = 25,
			SpinSpeed = 54,
			FireRateScale = 125,
		},
	},
	["Preset_142_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #142 for Obby environments.",
		Settings = {
			AimFOV = 274,
			AimSmoothness = 26,
			ESPMaxDist = 1350,
			WalkSpeed = 44,
			JumpPower = 51,
			ChamsFillAlpha = 30,
			SpinSpeed = 58,
			FireRateScale = 130,
		},
	},
	["Preset_143_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #143 for Sandbox environments.",
		Settings = {
			AimFOV = 281,
			AimSmoothness = 29,
			ESPMaxDist = 1375,
			WalkSpeed = 46,
			JumpPower = 54,
			ChamsFillAlpha = 35,
			SpinSpeed = 62,
			FireRateScale = 135,
		},
	},
	["Preset_144_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #144 for Tactical environments.",
		Settings = {
			AimFOV = 288,
			AimSmoothness = 32,
			ESPMaxDist = 200,
			WalkSpeed = 48,
			JumpPower = 57,
			ChamsFillAlpha = 40,
			SpinSpeed = 66,
			FireRateScale = 140,
		},
	},
	["Preset_145_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #145 for Parkour environments.",
		Settings = {
			AimFOV = 295,
			AimSmoothness = 35,
			ESPMaxDist = 225,
			WalkSpeed = 50,
			JumpPower = 60,
			ChamsFillAlpha = 45,
			SpinSpeed = 70,
			FireRateScale = 145,
		},
	},
	["Preset_146_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #146 for Shooter environments.",
		Settings = {
			AimFOV = 302,
			AimSmoothness = 38,
			ESPMaxDist = 250,
			WalkSpeed = 52,
			JumpPower = 63,
			ChamsFillAlpha = 50,
			SpinSpeed = 74,
			FireRateScale = 150,
		},
	},
	["Preset_147_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #147 for Racing environments.",
		Settings = {
			AimFOV = 309,
			AimSmoothness = 41,
			ESPMaxDist = 275,
			WalkSpeed = 54,
			JumpPower = 66,
			ChamsFillAlpha = 55,
			SpinSpeed = 13,
			FireRateScale = 155,
		},
	},
	["Preset_148_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #148 for Survival environments.",
		Settings = {
			AimFOV = 316,
			AimSmoothness = 44,
			ESPMaxDist = 300,
			WalkSpeed = 56,
			JumpPower = 69,
			ChamsFillAlpha = 60,
			SpinSpeed = 17,
			FireRateScale = 160,
		},
	},
	["Preset_149_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #149 for Simulator environments.",
		Settings = {
			AimFOV = 63,
			AimSmoothness = 47,
			ESPMaxDist = 325,
			WalkSpeed = 58,
			JumpPower = 72,
			ChamsFillAlpha = 65,
			SpinSpeed = 21,
			FireRateScale = 165,
		},
	},
	["Preset_150_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #150 for Duel environments.",
		Settings = {
			AimFOV = 70,
			AimSmoothness = 5,
			ESPMaxDist = 350,
			WalkSpeed = 60,
			JumpPower = 75,
			ChamsFillAlpha = 70,
			SpinSpeed = 25,
			FireRateScale = 170,
		},
	},
	["Preset_151_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #151 for Arena environments.",
		Settings = {
			AimFOV = 77,
			AimSmoothness = 8,
			ESPMaxDist = 375,
			WalkSpeed = 62,
			JumpPower = 78,
			ChamsFillAlpha = 75,
			SpinSpeed = 29,
			FireRateScale = 175,
		},
	},
	["Preset_152_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #152 for Obby environments.",
		Settings = {
			AimFOV = 84,
			AimSmoothness = 11,
			ESPMaxDist = 400,
			WalkSpeed = 64,
			JumpPower = 81,
			ChamsFillAlpha = 80,
			SpinSpeed = 33,
			FireRateScale = 180,
		},
	},
	["Preset_153_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #153 for Sandbox environments.",
		Settings = {
			AimFOV = 91,
			AimSmoothness = 14,
			ESPMaxDist = 425,
			WalkSpeed = 66,
			JumpPower = 84,
			ChamsFillAlpha = 85,
			SpinSpeed = 37,
			FireRateScale = 185,
		},
	},
	["Preset_154_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #154 for Tactical environments.",
		Settings = {
			AimFOV = 98,
			AimSmoothness = 17,
			ESPMaxDist = 450,
			WalkSpeed = 68,
			JumpPower = 87,
			ChamsFillAlpha = 20,
			SpinSpeed = 41,
			FireRateScale = 80,
		},
	},
	["Preset_155_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #155 for Parkour environments.",
		Settings = {
			AimFOV = 105,
			AimSmoothness = 20,
			ESPMaxDist = 475,
			WalkSpeed = 70,
			JumpPower = 90,
			ChamsFillAlpha = 25,
			SpinSpeed = 45,
			FireRateScale = 85,
		},
	},
	["Preset_156_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #156 for Shooter environments.",
		Settings = {
			AimFOV = 112,
			AimSmoothness = 23,
			ESPMaxDist = 500,
			WalkSpeed = 72,
			JumpPower = 93,
			ChamsFillAlpha = 30,
			SpinSpeed = 49,
			FireRateScale = 90,
		},
	},
	["Preset_157_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #157 for Racing environments.",
		Settings = {
			AimFOV = 119,
			AimSmoothness = 26,
			ESPMaxDist = 525,
			WalkSpeed = 74,
			JumpPower = 96,
			ChamsFillAlpha = 35,
			SpinSpeed = 53,
			FireRateScale = 95,
		},
	},
	["Preset_158_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #158 for Survival environments.",
		Settings = {
			AimFOV = 126,
			AimSmoothness = 29,
			ESPMaxDist = 550,
			WalkSpeed = 76,
			JumpPower = 99,
			ChamsFillAlpha = 40,
			SpinSpeed = 57,
			FireRateScale = 100,
		},
	},
	["Preset_159_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #159 for Simulator environments.",
		Settings = {
			AimFOV = 133,
			AimSmoothness = 32,
			ESPMaxDist = 575,
			WalkSpeed = 78,
			JumpPower = 102,
			ChamsFillAlpha = 45,
			SpinSpeed = 61,
			FireRateScale = 105,
		},
	},
	["Preset_160_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #160 for Duel environments.",
		Settings = {
			AimFOV = 140,
			AimSmoothness = 35,
			ESPMaxDist = 600,
			WalkSpeed = 16,
			JumpPower = 105,
			ChamsFillAlpha = 50,
			SpinSpeed = 65,
			FireRateScale = 110,
		},
	},
	["Preset_161_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #161 for Arena environments.",
		Settings = {
			AimFOV = 147,
			AimSmoothness = 38,
			ESPMaxDist = 625,
			WalkSpeed = 18,
			JumpPower = 108,
			ChamsFillAlpha = 55,
			SpinSpeed = 69,
			FireRateScale = 115,
		},
	},
	["Preset_162_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #162 for Obby environments.",
		Settings = {
			AimFOV = 154,
			AimSmoothness = 41,
			ESPMaxDist = 650,
			WalkSpeed = 20,
			JumpPower = 111,
			ChamsFillAlpha = 60,
			SpinSpeed = 73,
			FireRateScale = 120,
		},
	},
	["Preset_163_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #163 for Sandbox environments.",
		Settings = {
			AimFOV = 161,
			AimSmoothness = 44,
			ESPMaxDist = 675,
			WalkSpeed = 22,
			JumpPower = 114,
			ChamsFillAlpha = 65,
			SpinSpeed = 12,
			FireRateScale = 125,
		},
	},
	["Preset_164_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #164 for Tactical environments.",
		Settings = {
			AimFOV = 168,
			AimSmoothness = 47,
			ESPMaxDist = 700,
			WalkSpeed = 24,
			JumpPower = 117,
			ChamsFillAlpha = 70,
			SpinSpeed = 16,
			FireRateScale = 130,
		},
	},
	["Preset_165_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #165 for Parkour environments.",
		Settings = {
			AimFOV = 175,
			AimSmoothness = 5,
			ESPMaxDist = 725,
			WalkSpeed = 26,
			JumpPower = 120,
			ChamsFillAlpha = 75,
			SpinSpeed = 20,
			FireRateScale = 135,
		},
	},
	["Preset_166_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #166 for Shooter environments.",
		Settings = {
			AimFOV = 182,
			AimSmoothness = 8,
			ESPMaxDist = 750,
			WalkSpeed = 28,
			JumpPower = 123,
			ChamsFillAlpha = 80,
			SpinSpeed = 24,
			FireRateScale = 140,
		},
	},
	["Preset_167_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #167 for Racing environments.",
		Settings = {
			AimFOV = 189,
			AimSmoothness = 11,
			ESPMaxDist = 775,
			WalkSpeed = 30,
			JumpPower = 126,
			ChamsFillAlpha = 85,
			SpinSpeed = 28,
			FireRateScale = 145,
		},
	},
	["Preset_168_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #168 for Survival environments.",
		Settings = {
			AimFOV = 196,
			AimSmoothness = 14,
			ESPMaxDist = 800,
			WalkSpeed = 32,
			JumpPower = 129,
			ChamsFillAlpha = 20,
			SpinSpeed = 32,
			FireRateScale = 150,
		},
	},
	["Preset_169_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #169 for Simulator environments.",
		Settings = {
			AimFOV = 203,
			AimSmoothness = 17,
			ESPMaxDist = 825,
			WalkSpeed = 34,
			JumpPower = 132,
			ChamsFillAlpha = 25,
			SpinSpeed = 36,
			FireRateScale = 155,
		},
	},
	["Preset_170_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #170 for Duel environments.",
		Settings = {
			AimFOV = 210,
			AimSmoothness = 20,
			ESPMaxDist = 850,
			WalkSpeed = 36,
			JumpPower = 50,
			ChamsFillAlpha = 30,
			SpinSpeed = 40,
			FireRateScale = 160,
		},
	},
	["Preset_171_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #171 for Arena environments.",
		Settings = {
			AimFOV = 217,
			AimSmoothness = 23,
			ESPMaxDist = 875,
			WalkSpeed = 38,
			JumpPower = 53,
			ChamsFillAlpha = 35,
			SpinSpeed = 44,
			FireRateScale = 165,
		},
	},
	["Preset_172_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #172 for Obby environments.",
		Settings = {
			AimFOV = 224,
			AimSmoothness = 26,
			ESPMaxDist = 900,
			WalkSpeed = 40,
			JumpPower = 56,
			ChamsFillAlpha = 40,
			SpinSpeed = 48,
			FireRateScale = 170,
		},
	},
	["Preset_173_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #173 for Sandbox environments.",
		Settings = {
			AimFOV = 231,
			AimSmoothness = 29,
			ESPMaxDist = 925,
			WalkSpeed = 42,
			JumpPower = 59,
			ChamsFillAlpha = 45,
			SpinSpeed = 52,
			FireRateScale = 175,
		},
	},
	["Preset_174_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #174 for Tactical environments.",
		Settings = {
			AimFOV = 238,
			AimSmoothness = 32,
			ESPMaxDist = 950,
			WalkSpeed = 44,
			JumpPower = 62,
			ChamsFillAlpha = 50,
			SpinSpeed = 56,
			FireRateScale = 180,
		},
	},
	["Preset_175_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #175 for Parkour environments.",
		Settings = {
			AimFOV = 245,
			AimSmoothness = 35,
			ESPMaxDist = 975,
			WalkSpeed = 46,
			JumpPower = 65,
			ChamsFillAlpha = 55,
			SpinSpeed = 60,
			FireRateScale = 185,
		},
	},
	["Preset_176_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #176 for Shooter environments.",
		Settings = {
			AimFOV = 252,
			AimSmoothness = 38,
			ESPMaxDist = 1000,
			WalkSpeed = 48,
			JumpPower = 68,
			ChamsFillAlpha = 60,
			SpinSpeed = 64,
			FireRateScale = 80,
		},
	},
	["Preset_177_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #177 for Racing environments.",
		Settings = {
			AimFOV = 259,
			AimSmoothness = 41,
			ESPMaxDist = 1025,
			WalkSpeed = 50,
			JumpPower = 71,
			ChamsFillAlpha = 65,
			SpinSpeed = 68,
			FireRateScale = 85,
		},
	},
	["Preset_178_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #178 for Survival environments.",
		Settings = {
			AimFOV = 266,
			AimSmoothness = 44,
			ESPMaxDist = 1050,
			WalkSpeed = 52,
			JumpPower = 74,
			ChamsFillAlpha = 70,
			SpinSpeed = 72,
			FireRateScale = 90,
		},
	},
	["Preset_179_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #179 for Simulator environments.",
		Settings = {
			AimFOV = 273,
			AimSmoothness = 47,
			ESPMaxDist = 1075,
			WalkSpeed = 54,
			JumpPower = 77,
			ChamsFillAlpha = 75,
			SpinSpeed = 11,
			FireRateScale = 95,
		},
	},
	["Preset_180_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #180 for Duel environments.",
		Settings = {
			AimFOV = 280,
			AimSmoothness = 5,
			ESPMaxDist = 1100,
			WalkSpeed = 56,
			JumpPower = 80,
			ChamsFillAlpha = 80,
			SpinSpeed = 15,
			FireRateScale = 100,
		},
	},
	["Preset_181_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #181 for Arena environments.",
		Settings = {
			AimFOV = 287,
			AimSmoothness = 8,
			ESPMaxDist = 1125,
			WalkSpeed = 58,
			JumpPower = 83,
			ChamsFillAlpha = 85,
			SpinSpeed = 19,
			FireRateScale = 105,
		},
	},
	["Preset_182_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #182 for Obby environments.",
		Settings = {
			AimFOV = 294,
			AimSmoothness = 11,
			ESPMaxDist = 1150,
			WalkSpeed = 60,
			JumpPower = 86,
			ChamsFillAlpha = 20,
			SpinSpeed = 23,
			FireRateScale = 110,
		},
	},
	["Preset_183_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #183 for Sandbox environments.",
		Settings = {
			AimFOV = 301,
			AimSmoothness = 14,
			ESPMaxDist = 1175,
			WalkSpeed = 62,
			JumpPower = 89,
			ChamsFillAlpha = 25,
			SpinSpeed = 27,
			FireRateScale = 115,
		},
	},
	["Preset_184_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #184 for Tactical environments.",
		Settings = {
			AimFOV = 308,
			AimSmoothness = 17,
			ESPMaxDist = 1200,
			WalkSpeed = 64,
			JumpPower = 92,
			ChamsFillAlpha = 30,
			SpinSpeed = 31,
			FireRateScale = 120,
		},
	},
	["Preset_185_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #185 for Parkour environments.",
		Settings = {
			AimFOV = 315,
			AimSmoothness = 20,
			ESPMaxDist = 1225,
			WalkSpeed = 66,
			JumpPower = 95,
			ChamsFillAlpha = 35,
			SpinSpeed = 35,
			FireRateScale = 125,
		},
	},
	["Preset_186_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #186 for Shooter environments.",
		Settings = {
			AimFOV = 62,
			AimSmoothness = 23,
			ESPMaxDist = 1250,
			WalkSpeed = 68,
			JumpPower = 98,
			ChamsFillAlpha = 40,
			SpinSpeed = 39,
			FireRateScale = 130,
		},
	},
	["Preset_187_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #187 for Racing environments.",
		Settings = {
			AimFOV = 69,
			AimSmoothness = 26,
			ESPMaxDist = 1275,
			WalkSpeed = 70,
			JumpPower = 101,
			ChamsFillAlpha = 45,
			SpinSpeed = 43,
			FireRateScale = 135,
		},
	},
	["Preset_188_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #188 for Survival environments.",
		Settings = {
			AimFOV = 76,
			AimSmoothness = 29,
			ESPMaxDist = 1300,
			WalkSpeed = 72,
			JumpPower = 104,
			ChamsFillAlpha = 50,
			SpinSpeed = 47,
			FireRateScale = 140,
		},
	},
	["Preset_189_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #189 for Simulator environments.",
		Settings = {
			AimFOV = 83,
			AimSmoothness = 32,
			ESPMaxDist = 1325,
			WalkSpeed = 74,
			JumpPower = 107,
			ChamsFillAlpha = 55,
			SpinSpeed = 51,
			FireRateScale = 145,
		},
	},
	["Preset_190_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #190 for Duel environments.",
		Settings = {
			AimFOV = 90,
			AimSmoothness = 35,
			ESPMaxDist = 1350,
			WalkSpeed = 76,
			JumpPower = 110,
			ChamsFillAlpha = 60,
			SpinSpeed = 55,
			FireRateScale = 150,
		},
	},
	["Preset_191_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #191 for Arena environments.",
		Settings = {
			AimFOV = 97,
			AimSmoothness = 38,
			ESPMaxDist = 1375,
			WalkSpeed = 78,
			JumpPower = 113,
			ChamsFillAlpha = 65,
			SpinSpeed = 59,
			FireRateScale = 155,
		},
	},
	["Preset_192_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #192 for Obby environments.",
		Settings = {
			AimFOV = 104,
			AimSmoothness = 41,
			ESPMaxDist = 200,
			WalkSpeed = 16,
			JumpPower = 116,
			ChamsFillAlpha = 70,
			SpinSpeed = 63,
			FireRateScale = 160,
		},
	},
	["Preset_193_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #193 for Sandbox environments.",
		Settings = {
			AimFOV = 111,
			AimSmoothness = 44,
			ESPMaxDist = 225,
			WalkSpeed = 18,
			JumpPower = 119,
			ChamsFillAlpha = 75,
			SpinSpeed = 67,
			FireRateScale = 165,
		},
	},
	["Preset_194_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #194 for Tactical environments.",
		Settings = {
			AimFOV = 118,
			AimSmoothness = 47,
			ESPMaxDist = 250,
			WalkSpeed = 20,
			JumpPower = 122,
			ChamsFillAlpha = 80,
			SpinSpeed = 71,
			FireRateScale = 170,
		},
	},
	["Preset_195_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #195 for Parkour environments.",
		Settings = {
			AimFOV = 125,
			AimSmoothness = 5,
			ESPMaxDist = 275,
			WalkSpeed = 22,
			JumpPower = 125,
			ChamsFillAlpha = 85,
			SpinSpeed = 10,
			FireRateScale = 175,
		},
	},
	["Preset_196_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #196 for Shooter environments.",
		Settings = {
			AimFOV = 132,
			AimSmoothness = 8,
			ESPMaxDist = 300,
			WalkSpeed = 24,
			JumpPower = 128,
			ChamsFillAlpha = 20,
			SpinSpeed = 14,
			FireRateScale = 180,
		},
	},
	["Preset_197_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #197 for Racing environments.",
		Settings = {
			AimFOV = 139,
			AimSmoothness = 11,
			ESPMaxDist = 325,
			WalkSpeed = 26,
			JumpPower = 131,
			ChamsFillAlpha = 25,
			SpinSpeed = 18,
			FireRateScale = 185,
		},
	},
	["Preset_198_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #198 for Survival environments.",
		Settings = {
			AimFOV = 146,
			AimSmoothness = 14,
			ESPMaxDist = 350,
			WalkSpeed = 28,
			JumpPower = 134,
			ChamsFillAlpha = 30,
			SpinSpeed = 22,
			FireRateScale = 80,
		},
	},
	["Preset_199_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #199 for Simulator environments.",
		Settings = {
			AimFOV = 153,
			AimSmoothness = 17,
			ESPMaxDist = 375,
			WalkSpeed = 30,
			JumpPower = 52,
			ChamsFillAlpha = 35,
			SpinSpeed = 26,
			FireRateScale = 85,
		},
	},
	["Preset_200_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #200 for Duel environments.",
		Settings = {
			AimFOV = 160,
			AimSmoothness = 20,
			ESPMaxDist = 400,
			WalkSpeed = 32,
			JumpPower = 55,
			ChamsFillAlpha = 40,
			SpinSpeed = 30,
			FireRateScale = 90,
		},
	},
	["Preset_201_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #201 for Arena environments.",
		Settings = {
			AimFOV = 167,
			AimSmoothness = 23,
			ESPMaxDist = 425,
			WalkSpeed = 34,
			JumpPower = 58,
			ChamsFillAlpha = 45,
			SpinSpeed = 34,
			FireRateScale = 95,
		},
	},
	["Preset_202_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #202 for Obby environments.",
		Settings = {
			AimFOV = 174,
			AimSmoothness = 26,
			ESPMaxDist = 450,
			WalkSpeed = 36,
			JumpPower = 61,
			ChamsFillAlpha = 50,
			SpinSpeed = 38,
			FireRateScale = 100,
		},
	},
	["Preset_203_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #203 for Sandbox environments.",
		Settings = {
			AimFOV = 181,
			AimSmoothness = 29,
			ESPMaxDist = 475,
			WalkSpeed = 38,
			JumpPower = 64,
			ChamsFillAlpha = 55,
			SpinSpeed = 42,
			FireRateScale = 105,
		},
	},
	["Preset_204_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #204 for Tactical environments.",
		Settings = {
			AimFOV = 188,
			AimSmoothness = 32,
			ESPMaxDist = 500,
			WalkSpeed = 40,
			JumpPower = 67,
			ChamsFillAlpha = 60,
			SpinSpeed = 46,
			FireRateScale = 110,
		},
	},
	["Preset_205_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #205 for Parkour environments.",
		Settings = {
			AimFOV = 195,
			AimSmoothness = 35,
			ESPMaxDist = 525,
			WalkSpeed = 42,
			JumpPower = 70,
			ChamsFillAlpha = 65,
			SpinSpeed = 50,
			FireRateScale = 115,
		},
	},
	["Preset_206_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #206 for Shooter environments.",
		Settings = {
			AimFOV = 202,
			AimSmoothness = 38,
			ESPMaxDist = 550,
			WalkSpeed = 44,
			JumpPower = 73,
			ChamsFillAlpha = 70,
			SpinSpeed = 54,
			FireRateScale = 120,
		},
	},
	["Preset_207_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #207 for Racing environments.",
		Settings = {
			AimFOV = 209,
			AimSmoothness = 41,
			ESPMaxDist = 575,
			WalkSpeed = 46,
			JumpPower = 76,
			ChamsFillAlpha = 75,
			SpinSpeed = 58,
			FireRateScale = 125,
		},
	},
	["Preset_208_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #208 for Survival environments.",
		Settings = {
			AimFOV = 216,
			AimSmoothness = 44,
			ESPMaxDist = 600,
			WalkSpeed = 48,
			JumpPower = 79,
			ChamsFillAlpha = 80,
			SpinSpeed = 62,
			FireRateScale = 130,
		},
	},
	["Preset_209_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #209 for Simulator environments.",
		Settings = {
			AimFOV = 223,
			AimSmoothness = 47,
			ESPMaxDist = 625,
			WalkSpeed = 50,
			JumpPower = 82,
			ChamsFillAlpha = 85,
			SpinSpeed = 66,
			FireRateScale = 135,
		},
	},
	["Preset_210_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #210 for Duel environments.",
		Settings = {
			AimFOV = 230,
			AimSmoothness = 5,
			ESPMaxDist = 650,
			WalkSpeed = 52,
			JumpPower = 85,
			ChamsFillAlpha = 20,
			SpinSpeed = 70,
			FireRateScale = 140,
		},
	},
	["Preset_211_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #211 for Arena environments.",
		Settings = {
			AimFOV = 237,
			AimSmoothness = 8,
			ESPMaxDist = 675,
			WalkSpeed = 54,
			JumpPower = 88,
			ChamsFillAlpha = 25,
			SpinSpeed = 74,
			FireRateScale = 145,
		},
	},
	["Preset_212_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #212 for Obby environments.",
		Settings = {
			AimFOV = 244,
			AimSmoothness = 11,
			ESPMaxDist = 700,
			WalkSpeed = 56,
			JumpPower = 91,
			ChamsFillAlpha = 30,
			SpinSpeed = 13,
			FireRateScale = 150,
		},
	},
	["Preset_213_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #213 for Sandbox environments.",
		Settings = {
			AimFOV = 251,
			AimSmoothness = 14,
			ESPMaxDist = 725,
			WalkSpeed = 58,
			JumpPower = 94,
			ChamsFillAlpha = 35,
			SpinSpeed = 17,
			FireRateScale = 155,
		},
	},
	["Preset_214_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #214 for Tactical environments.",
		Settings = {
			AimFOV = 258,
			AimSmoothness = 17,
			ESPMaxDist = 750,
			WalkSpeed = 60,
			JumpPower = 97,
			ChamsFillAlpha = 40,
			SpinSpeed = 21,
			FireRateScale = 160,
		},
	},
	["Preset_215_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #215 for Parkour environments.",
		Settings = {
			AimFOV = 265,
			AimSmoothness = 20,
			ESPMaxDist = 775,
			WalkSpeed = 62,
			JumpPower = 100,
			ChamsFillAlpha = 45,
			SpinSpeed = 25,
			FireRateScale = 165,
		},
	},
	["Preset_216_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #216 for Shooter environments.",
		Settings = {
			AimFOV = 272,
			AimSmoothness = 23,
			ESPMaxDist = 800,
			WalkSpeed = 64,
			JumpPower = 103,
			ChamsFillAlpha = 50,
			SpinSpeed = 29,
			FireRateScale = 170,
		},
	},
	["Preset_217_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #217 for Racing environments.",
		Settings = {
			AimFOV = 279,
			AimSmoothness = 26,
			ESPMaxDist = 825,
			WalkSpeed = 66,
			JumpPower = 106,
			ChamsFillAlpha = 55,
			SpinSpeed = 33,
			FireRateScale = 175,
		},
	},
	["Preset_218_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #218 for Survival environments.",
		Settings = {
			AimFOV = 286,
			AimSmoothness = 29,
			ESPMaxDist = 850,
			WalkSpeed = 68,
			JumpPower = 109,
			ChamsFillAlpha = 60,
			SpinSpeed = 37,
			FireRateScale = 180,
		},
	},
	["Preset_219_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #219 for Simulator environments.",
		Settings = {
			AimFOV = 293,
			AimSmoothness = 32,
			ESPMaxDist = 875,
			WalkSpeed = 70,
			JumpPower = 112,
			ChamsFillAlpha = 65,
			SpinSpeed = 41,
			FireRateScale = 185,
		},
	},
	["Preset_220_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #220 for Duel environments.",
		Settings = {
			AimFOV = 300,
			AimSmoothness = 35,
			ESPMaxDist = 900,
			WalkSpeed = 72,
			JumpPower = 115,
			ChamsFillAlpha = 70,
			SpinSpeed = 45,
			FireRateScale = 80,
		},
	},
	["Preset_221_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #221 for Arena environments.",
		Settings = {
			AimFOV = 307,
			AimSmoothness = 38,
			ESPMaxDist = 925,
			WalkSpeed = 74,
			JumpPower = 118,
			ChamsFillAlpha = 75,
			SpinSpeed = 49,
			FireRateScale = 85,
		},
	},
	["Preset_222_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #222 for Obby environments.",
		Settings = {
			AimFOV = 314,
			AimSmoothness = 41,
			ESPMaxDist = 950,
			WalkSpeed = 76,
			JumpPower = 121,
			ChamsFillAlpha = 80,
			SpinSpeed = 53,
			FireRateScale = 90,
		},
	},
	["Preset_223_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #223 for Sandbox environments.",
		Settings = {
			AimFOV = 61,
			AimSmoothness = 44,
			ESPMaxDist = 975,
			WalkSpeed = 78,
			JumpPower = 124,
			ChamsFillAlpha = 85,
			SpinSpeed = 57,
			FireRateScale = 95,
		},
	},
	["Preset_224_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #224 for Tactical environments.",
		Settings = {
			AimFOV = 68,
			AimSmoothness = 47,
			ESPMaxDist = 1000,
			WalkSpeed = 16,
			JumpPower = 127,
			ChamsFillAlpha = 20,
			SpinSpeed = 61,
			FireRateScale = 100,
		},
	},
	["Preset_225_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #225 for Parkour environments.",
		Settings = {
			AimFOV = 75,
			AimSmoothness = 5,
			ESPMaxDist = 1025,
			WalkSpeed = 18,
			JumpPower = 130,
			ChamsFillAlpha = 25,
			SpinSpeed = 65,
			FireRateScale = 105,
		},
	},
	["Preset_226_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #226 for Shooter environments.",
		Settings = {
			AimFOV = 82,
			AimSmoothness = 8,
			ESPMaxDist = 1050,
			WalkSpeed = 20,
			JumpPower = 133,
			ChamsFillAlpha = 30,
			SpinSpeed = 69,
			FireRateScale = 110,
		},
	},
	["Preset_227_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #227 for Racing environments.",
		Settings = {
			AimFOV = 89,
			AimSmoothness = 11,
			ESPMaxDist = 1075,
			WalkSpeed = 22,
			JumpPower = 51,
			ChamsFillAlpha = 35,
			SpinSpeed = 73,
			FireRateScale = 115,
		},
	},
	["Preset_228_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #228 for Survival environments.",
		Settings = {
			AimFOV = 96,
			AimSmoothness = 14,
			ESPMaxDist = 1100,
			WalkSpeed = 24,
			JumpPower = 54,
			ChamsFillAlpha = 40,
			SpinSpeed = 12,
			FireRateScale = 120,
		},
	},
	["Preset_229_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #229 for Simulator environments.",
		Settings = {
			AimFOV = 103,
			AimSmoothness = 17,
			ESPMaxDist = 1125,
			WalkSpeed = 26,
			JumpPower = 57,
			ChamsFillAlpha = 45,
			SpinSpeed = 16,
			FireRateScale = 125,
		},
	},
	["Preset_230_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #230 for Duel environments.",
		Settings = {
			AimFOV = 110,
			AimSmoothness = 20,
			ESPMaxDist = 1150,
			WalkSpeed = 28,
			JumpPower = 60,
			ChamsFillAlpha = 50,
			SpinSpeed = 20,
			FireRateScale = 130,
		},
	},
	["Preset_231_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #231 for Arena environments.",
		Settings = {
			AimFOV = 117,
			AimSmoothness = 23,
			ESPMaxDist = 1175,
			WalkSpeed = 30,
			JumpPower = 63,
			ChamsFillAlpha = 55,
			SpinSpeed = 24,
			FireRateScale = 135,
		},
	},
	["Preset_232_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #232 for Obby environments.",
		Settings = {
			AimFOV = 124,
			AimSmoothness = 26,
			ESPMaxDist = 1200,
			WalkSpeed = 32,
			JumpPower = 66,
			ChamsFillAlpha = 60,
			SpinSpeed = 28,
			FireRateScale = 140,
		},
	},
	["Preset_233_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #233 for Sandbox environments.",
		Settings = {
			AimFOV = 131,
			AimSmoothness = 29,
			ESPMaxDist = 1225,
			WalkSpeed = 34,
			JumpPower = 69,
			ChamsFillAlpha = 65,
			SpinSpeed = 32,
			FireRateScale = 145,
		},
	},
	["Preset_234_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #234 for Tactical environments.",
		Settings = {
			AimFOV = 138,
			AimSmoothness = 32,
			ESPMaxDist = 1250,
			WalkSpeed = 36,
			JumpPower = 72,
			ChamsFillAlpha = 70,
			SpinSpeed = 36,
			FireRateScale = 150,
		},
	},
	["Preset_235_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #235 for Parkour environments.",
		Settings = {
			AimFOV = 145,
			AimSmoothness = 35,
			ESPMaxDist = 1275,
			WalkSpeed = 38,
			JumpPower = 75,
			ChamsFillAlpha = 75,
			SpinSpeed = 40,
			FireRateScale = 155,
		},
	},
	["Preset_236_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #236 for Shooter environments.",
		Settings = {
			AimFOV = 152,
			AimSmoothness = 38,
			ESPMaxDist = 1300,
			WalkSpeed = 40,
			JumpPower = 78,
			ChamsFillAlpha = 80,
			SpinSpeed = 44,
			FireRateScale = 160,
		},
	},
	["Preset_237_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #237 for Racing environments.",
		Settings = {
			AimFOV = 159,
			AimSmoothness = 41,
			ESPMaxDist = 1325,
			WalkSpeed = 42,
			JumpPower = 81,
			ChamsFillAlpha = 85,
			SpinSpeed = 48,
			FireRateScale = 165,
		},
	},
	["Preset_238_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #238 for Survival environments.",
		Settings = {
			AimFOV = 166,
			AimSmoothness = 44,
			ESPMaxDist = 1350,
			WalkSpeed = 44,
			JumpPower = 84,
			ChamsFillAlpha = 20,
			SpinSpeed = 52,
			FireRateScale = 170,
		},
	},
	["Preset_239_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #239 for Simulator environments.",
		Settings = {
			AimFOV = 173,
			AimSmoothness = 47,
			ESPMaxDist = 1375,
			WalkSpeed = 46,
			JumpPower = 87,
			ChamsFillAlpha = 25,
			SpinSpeed = 56,
			FireRateScale = 175,
		},
	},
	["Preset_240_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #240 for Duel environments.",
		Settings = {
			AimFOV = 180,
			AimSmoothness = 5,
			ESPMaxDist = 200,
			WalkSpeed = 48,
			JumpPower = 90,
			ChamsFillAlpha = 30,
			SpinSpeed = 60,
			FireRateScale = 180,
		},
	},
	["Preset_241_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #241 for Arena environments.",
		Settings = {
			AimFOV = 187,
			AimSmoothness = 8,
			ESPMaxDist = 225,
			WalkSpeed = 50,
			JumpPower = 93,
			ChamsFillAlpha = 35,
			SpinSpeed = 64,
			FireRateScale = 185,
		},
	},
	["Preset_242_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #242 for Obby environments.",
		Settings = {
			AimFOV = 194,
			AimSmoothness = 11,
			ESPMaxDist = 250,
			WalkSpeed = 52,
			JumpPower = 96,
			ChamsFillAlpha = 40,
			SpinSpeed = 68,
			FireRateScale = 80,
		},
	},
	["Preset_243_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #243 for Sandbox environments.",
		Settings = {
			AimFOV = 201,
			AimSmoothness = 14,
			ESPMaxDist = 275,
			WalkSpeed = 54,
			JumpPower = 99,
			ChamsFillAlpha = 45,
			SpinSpeed = 72,
			FireRateScale = 85,
		},
	},
	["Preset_244_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #244 for Tactical environments.",
		Settings = {
			AimFOV = 208,
			AimSmoothness = 17,
			ESPMaxDist = 300,
			WalkSpeed = 56,
			JumpPower = 102,
			ChamsFillAlpha = 50,
			SpinSpeed = 11,
			FireRateScale = 90,
		},
	},
	["Preset_245_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #245 for Parkour environments.",
		Settings = {
			AimFOV = 215,
			AimSmoothness = 20,
			ESPMaxDist = 325,
			WalkSpeed = 58,
			JumpPower = 105,
			ChamsFillAlpha = 55,
			SpinSpeed = 15,
			FireRateScale = 95,
		},
	},
	["Preset_246_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #246 for Shooter environments.",
		Settings = {
			AimFOV = 222,
			AimSmoothness = 23,
			ESPMaxDist = 350,
			WalkSpeed = 60,
			JumpPower = 108,
			ChamsFillAlpha = 60,
			SpinSpeed = 19,
			FireRateScale = 100,
		},
	},
	["Preset_247_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #247 for Racing environments.",
		Settings = {
			AimFOV = 229,
			AimSmoothness = 26,
			ESPMaxDist = 375,
			WalkSpeed = 62,
			JumpPower = 111,
			ChamsFillAlpha = 65,
			SpinSpeed = 23,
			FireRateScale = 105,
		},
	},
	["Preset_248_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #248 for Survival environments.",
		Settings = {
			AimFOV = 236,
			AimSmoothness = 29,
			ESPMaxDist = 400,
			WalkSpeed = 64,
			JumpPower = 114,
			ChamsFillAlpha = 70,
			SpinSpeed = 27,
			FireRateScale = 110,
		},
	},
	["Preset_249_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #249 for Simulator environments.",
		Settings = {
			AimFOV = 243,
			AimSmoothness = 32,
			ESPMaxDist = 425,
			WalkSpeed = 66,
			JumpPower = 117,
			ChamsFillAlpha = 75,
			SpinSpeed = 31,
			FireRateScale = 115,
		},
	},
	["Preset_250_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #250 for Duel environments.",
		Settings = {
			AimFOV = 250,
			AimSmoothness = 35,
			ESPMaxDist = 450,
			WalkSpeed = 68,
			JumpPower = 120,
			ChamsFillAlpha = 80,
			SpinSpeed = 35,
			FireRateScale = 120,
		},
	},
	["Preset_251_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #251 for Arena environments.",
		Settings = {
			AimFOV = 257,
			AimSmoothness = 38,
			ESPMaxDist = 475,
			WalkSpeed = 70,
			JumpPower = 123,
			ChamsFillAlpha = 85,
			SpinSpeed = 39,
			FireRateScale = 125,
		},
	},
	["Preset_252_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #252 for Obby environments.",
		Settings = {
			AimFOV = 264,
			AimSmoothness = 41,
			ESPMaxDist = 500,
			WalkSpeed = 72,
			JumpPower = 126,
			ChamsFillAlpha = 20,
			SpinSpeed = 43,
			FireRateScale = 130,
		},
	},
	["Preset_253_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #253 for Sandbox environments.",
		Settings = {
			AimFOV = 271,
			AimSmoothness = 44,
			ESPMaxDist = 525,
			WalkSpeed = 74,
			JumpPower = 129,
			ChamsFillAlpha = 25,
			SpinSpeed = 47,
			FireRateScale = 135,
		},
	},
	["Preset_254_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #254 for Tactical environments.",
		Settings = {
			AimFOV = 278,
			AimSmoothness = 47,
			ESPMaxDist = 550,
			WalkSpeed = 76,
			JumpPower = 132,
			ChamsFillAlpha = 30,
			SpinSpeed = 51,
			FireRateScale = 140,
		},
	},
	["Preset_255_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #255 for Parkour environments.",
		Settings = {
			AimFOV = 285,
			AimSmoothness = 5,
			ESPMaxDist = 575,
			WalkSpeed = 78,
			JumpPower = 50,
			ChamsFillAlpha = 35,
			SpinSpeed = 55,
			FireRateScale = 145,
		},
	},
	["Preset_256_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #256 for Shooter environments.",
		Settings = {
			AimFOV = 292,
			AimSmoothness = 8,
			ESPMaxDist = 600,
			WalkSpeed = 16,
			JumpPower = 53,
			ChamsFillAlpha = 40,
			SpinSpeed = 59,
			FireRateScale = 150,
		},
	},
	["Preset_257_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #257 for Racing environments.",
		Settings = {
			AimFOV = 299,
			AimSmoothness = 11,
			ESPMaxDist = 625,
			WalkSpeed = 18,
			JumpPower = 56,
			ChamsFillAlpha = 45,
			SpinSpeed = 63,
			FireRateScale = 155,
		},
	},
	["Preset_258_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #258 for Survival environments.",
		Settings = {
			AimFOV = 306,
			AimSmoothness = 14,
			ESPMaxDist = 650,
			WalkSpeed = 20,
			JumpPower = 59,
			ChamsFillAlpha = 50,
			SpinSpeed = 67,
			FireRateScale = 160,
		},
	},
	["Preset_259_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #259 for Simulator environments.",
		Settings = {
			AimFOV = 313,
			AimSmoothness = 17,
			ESPMaxDist = 675,
			WalkSpeed = 22,
			JumpPower = 62,
			ChamsFillAlpha = 55,
			SpinSpeed = 71,
			FireRateScale = 165,
		},
	},
	["Preset_260_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #260 for Duel environments.",
		Settings = {
			AimFOV = 60,
			AimSmoothness = 20,
			ESPMaxDist = 700,
			WalkSpeed = 24,
			JumpPower = 65,
			ChamsFillAlpha = 60,
			SpinSpeed = 10,
			FireRateScale = 170,
		},
	},
	["Preset_261_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #261 for Arena environments.",
		Settings = {
			AimFOV = 67,
			AimSmoothness = 23,
			ESPMaxDist = 725,
			WalkSpeed = 26,
			JumpPower = 68,
			ChamsFillAlpha = 65,
			SpinSpeed = 14,
			FireRateScale = 175,
		},
	},
	["Preset_262_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #262 for Obby environments.",
		Settings = {
			AimFOV = 74,
			AimSmoothness = 26,
			ESPMaxDist = 750,
			WalkSpeed = 28,
			JumpPower = 71,
			ChamsFillAlpha = 70,
			SpinSpeed = 18,
			FireRateScale = 180,
		},
	},
	["Preset_263_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #263 for Sandbox environments.",
		Settings = {
			AimFOV = 81,
			AimSmoothness = 29,
			ESPMaxDist = 775,
			WalkSpeed = 30,
			JumpPower = 74,
			ChamsFillAlpha = 75,
			SpinSpeed = 22,
			FireRateScale = 185,
		},
	},
	["Preset_264_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #264 for Tactical environments.",
		Settings = {
			AimFOV = 88,
			AimSmoothness = 32,
			ESPMaxDist = 800,
			WalkSpeed = 32,
			JumpPower = 77,
			ChamsFillAlpha = 80,
			SpinSpeed = 26,
			FireRateScale = 80,
		},
	},
	["Preset_265_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #265 for Parkour environments.",
		Settings = {
			AimFOV = 95,
			AimSmoothness = 35,
			ESPMaxDist = 825,
			WalkSpeed = 34,
			JumpPower = 80,
			ChamsFillAlpha = 85,
			SpinSpeed = 30,
			FireRateScale = 85,
		},
	},
	["Preset_266_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #266 for Shooter environments.",
		Settings = {
			AimFOV = 102,
			AimSmoothness = 38,
			ESPMaxDist = 850,
			WalkSpeed = 36,
			JumpPower = 83,
			ChamsFillAlpha = 20,
			SpinSpeed = 34,
			FireRateScale = 90,
		},
	},
	["Preset_267_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #267 for Racing environments.",
		Settings = {
			AimFOV = 109,
			AimSmoothness = 41,
			ESPMaxDist = 875,
			WalkSpeed = 38,
			JumpPower = 86,
			ChamsFillAlpha = 25,
			SpinSpeed = 38,
			FireRateScale = 95,
		},
	},
	["Preset_268_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #268 for Survival environments.",
		Settings = {
			AimFOV = 116,
			AimSmoothness = 44,
			ESPMaxDist = 900,
			WalkSpeed = 40,
			JumpPower = 89,
			ChamsFillAlpha = 30,
			SpinSpeed = 42,
			FireRateScale = 100,
		},
	},
	["Preset_269_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #269 for Simulator environments.",
		Settings = {
			AimFOV = 123,
			AimSmoothness = 47,
			ESPMaxDist = 925,
			WalkSpeed = 42,
			JumpPower = 92,
			ChamsFillAlpha = 35,
			SpinSpeed = 46,
			FireRateScale = 105,
		},
	},
	["Preset_270_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #270 for Duel environments.",
		Settings = {
			AimFOV = 130,
			AimSmoothness = 5,
			ESPMaxDist = 950,
			WalkSpeed = 44,
			JumpPower = 95,
			ChamsFillAlpha = 40,
			SpinSpeed = 50,
			FireRateScale = 110,
		},
	},
	["Preset_271_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #271 for Arena environments.",
		Settings = {
			AimFOV = 137,
			AimSmoothness = 8,
			ESPMaxDist = 975,
			WalkSpeed = 46,
			JumpPower = 98,
			ChamsFillAlpha = 45,
			SpinSpeed = 54,
			FireRateScale = 115,
		},
	},
	["Preset_272_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #272 for Obby environments.",
		Settings = {
			AimFOV = 144,
			AimSmoothness = 11,
			ESPMaxDist = 1000,
			WalkSpeed = 48,
			JumpPower = 101,
			ChamsFillAlpha = 50,
			SpinSpeed = 58,
			FireRateScale = 120,
		},
	},
	["Preset_273_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #273 for Sandbox environments.",
		Settings = {
			AimFOV = 151,
			AimSmoothness = 14,
			ESPMaxDist = 1025,
			WalkSpeed = 50,
			JumpPower = 104,
			ChamsFillAlpha = 55,
			SpinSpeed = 62,
			FireRateScale = 125,
		},
	},
	["Preset_274_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #274 for Tactical environments.",
		Settings = {
			AimFOV = 158,
			AimSmoothness = 17,
			ESPMaxDist = 1050,
			WalkSpeed = 52,
			JumpPower = 107,
			ChamsFillAlpha = 60,
			SpinSpeed = 66,
			FireRateScale = 130,
		},
	},
	["Preset_275_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #275 for Parkour environments.",
		Settings = {
			AimFOV = 165,
			AimSmoothness = 20,
			ESPMaxDist = 1075,
			WalkSpeed = 54,
			JumpPower = 110,
			ChamsFillAlpha = 65,
			SpinSpeed = 70,
			FireRateScale = 135,
		},
	},
	["Preset_276_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #276 for Shooter environments.",
		Settings = {
			AimFOV = 172,
			AimSmoothness = 23,
			ESPMaxDist = 1100,
			WalkSpeed = 56,
			JumpPower = 113,
			ChamsFillAlpha = 70,
			SpinSpeed = 74,
			FireRateScale = 140,
		},
	},
	["Preset_277_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #277 for Racing environments.",
		Settings = {
			AimFOV = 179,
			AimSmoothness = 26,
			ESPMaxDist = 1125,
			WalkSpeed = 58,
			JumpPower = 116,
			ChamsFillAlpha = 75,
			SpinSpeed = 13,
			FireRateScale = 145,
		},
	},
	["Preset_278_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #278 for Survival environments.",
		Settings = {
			AimFOV = 186,
			AimSmoothness = 29,
			ESPMaxDist = 1150,
			WalkSpeed = 60,
			JumpPower = 119,
			ChamsFillAlpha = 80,
			SpinSpeed = 17,
			FireRateScale = 150,
		},
	},
	["Preset_279_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #279 for Simulator environments.",
		Settings = {
			AimFOV = 193,
			AimSmoothness = 32,
			ESPMaxDist = 1175,
			WalkSpeed = 62,
			JumpPower = 122,
			ChamsFillAlpha = 85,
			SpinSpeed = 21,
			FireRateScale = 155,
		},
	},
	["Preset_280_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #280 for Duel environments.",
		Settings = {
			AimFOV = 200,
			AimSmoothness = 35,
			ESPMaxDist = 1200,
			WalkSpeed = 64,
			JumpPower = 125,
			ChamsFillAlpha = 20,
			SpinSpeed = 25,
			FireRateScale = 160,
		},
	},
	["Preset_281_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #281 for Arena environments.",
		Settings = {
			AimFOV = 207,
			AimSmoothness = 38,
			ESPMaxDist = 1225,
			WalkSpeed = 66,
			JumpPower = 128,
			ChamsFillAlpha = 25,
			SpinSpeed = 29,
			FireRateScale = 165,
		},
	},
	["Preset_282_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #282 for Obby environments.",
		Settings = {
			AimFOV = 214,
			AimSmoothness = 41,
			ESPMaxDist = 1250,
			WalkSpeed = 68,
			JumpPower = 131,
			ChamsFillAlpha = 30,
			SpinSpeed = 33,
			FireRateScale = 170,
		},
	},
	["Preset_283_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #283 for Sandbox environments.",
		Settings = {
			AimFOV = 221,
			AimSmoothness = 44,
			ESPMaxDist = 1275,
			WalkSpeed = 70,
			JumpPower = 134,
			ChamsFillAlpha = 35,
			SpinSpeed = 37,
			FireRateScale = 175,
		},
	},
	["Preset_284_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #284 for Tactical environments.",
		Settings = {
			AimFOV = 228,
			AimSmoothness = 47,
			ESPMaxDist = 1300,
			WalkSpeed = 72,
			JumpPower = 52,
			ChamsFillAlpha = 40,
			SpinSpeed = 41,
			FireRateScale = 180,
		},
	},
	["Preset_285_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #285 for Parkour environments.",
		Settings = {
			AimFOV = 235,
			AimSmoothness = 5,
			ESPMaxDist = 1325,
			WalkSpeed = 74,
			JumpPower = 55,
			ChamsFillAlpha = 45,
			SpinSpeed = 45,
			FireRateScale = 185,
		},
	},
	["Preset_286_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #286 for Shooter environments.",
		Settings = {
			AimFOV = 242,
			AimSmoothness = 8,
			ESPMaxDist = 1350,
			WalkSpeed = 76,
			JumpPower = 58,
			ChamsFillAlpha = 50,
			SpinSpeed = 49,
			FireRateScale = 80,
		},
	},
	["Preset_287_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #287 for Racing environments.",
		Settings = {
			AimFOV = 249,
			AimSmoothness = 11,
			ESPMaxDist = 1375,
			WalkSpeed = 78,
			JumpPower = 61,
			ChamsFillAlpha = 55,
			SpinSpeed = 53,
			FireRateScale = 85,
		},
	},
	["Preset_288_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #288 for Survival environments.",
		Settings = {
			AimFOV = 256,
			AimSmoothness = 14,
			ESPMaxDist = 200,
			WalkSpeed = 16,
			JumpPower = 64,
			ChamsFillAlpha = 60,
			SpinSpeed = 57,
			FireRateScale = 90,
		},
	},
	["Preset_289_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #289 for Simulator environments.",
		Settings = {
			AimFOV = 263,
			AimSmoothness = 17,
			ESPMaxDist = 225,
			WalkSpeed = 18,
			JumpPower = 67,
			ChamsFillAlpha = 65,
			SpinSpeed = 61,
			FireRateScale = 95,
		},
	},
	["Preset_290_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #290 for Duel environments.",
		Settings = {
			AimFOV = 270,
			AimSmoothness = 20,
			ESPMaxDist = 250,
			WalkSpeed = 20,
			JumpPower = 70,
			ChamsFillAlpha = 70,
			SpinSpeed = 65,
			FireRateScale = 100,
		},
	},
	["Preset_291_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #291 for Arena environments.",
		Settings = {
			AimFOV = 277,
			AimSmoothness = 23,
			ESPMaxDist = 275,
			WalkSpeed = 22,
			JumpPower = 73,
			ChamsFillAlpha = 75,
			SpinSpeed = 69,
			FireRateScale = 105,
		},
	},
	["Preset_292_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #292 for Obby environments.",
		Settings = {
			AimFOV = 284,
			AimSmoothness = 26,
			ESPMaxDist = 300,
			WalkSpeed = 24,
			JumpPower = 76,
			ChamsFillAlpha = 80,
			SpinSpeed = 73,
			FireRateScale = 110,
		},
	},
	["Preset_293_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #293 for Sandbox environments.",
		Settings = {
			AimFOV = 291,
			AimSmoothness = 29,
			ESPMaxDist = 325,
			WalkSpeed = 26,
			JumpPower = 79,
			ChamsFillAlpha = 85,
			SpinSpeed = 12,
			FireRateScale = 115,
		},
	},
	["Preset_294_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #294 for Tactical environments.",
		Settings = {
			AimFOV = 298,
			AimSmoothness = 32,
			ESPMaxDist = 350,
			WalkSpeed = 28,
			JumpPower = 82,
			ChamsFillAlpha = 20,
			SpinSpeed = 16,
			FireRateScale = 120,
		},
	},
	["Preset_295_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #295 for Parkour environments.",
		Settings = {
			AimFOV = 305,
			AimSmoothness = 35,
			ESPMaxDist = 375,
			WalkSpeed = 30,
			JumpPower = 85,
			ChamsFillAlpha = 25,
			SpinSpeed = 20,
			FireRateScale = 125,
		},
	},
	["Preset_296_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #296 for Shooter environments.",
		Settings = {
			AimFOV = 312,
			AimSmoothness = 38,
			ESPMaxDist = 400,
			WalkSpeed = 32,
			JumpPower = 88,
			ChamsFillAlpha = 30,
			SpinSpeed = 24,
			FireRateScale = 130,
		},
	},
	["Preset_297_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #297 for Racing environments.",
		Settings = {
			AimFOV = 319,
			AimSmoothness = 41,
			ESPMaxDist = 425,
			WalkSpeed = 34,
			JumpPower = 91,
			ChamsFillAlpha = 35,
			SpinSpeed = 28,
			FireRateScale = 135,
		},
	},
	["Preset_298_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #298 for Survival environments.",
		Settings = {
			AimFOV = 66,
			AimSmoothness = 44,
			ESPMaxDist = 450,
			WalkSpeed = 36,
			JumpPower = 94,
			ChamsFillAlpha = 40,
			SpinSpeed = 32,
			FireRateScale = 140,
		},
	},
	["Preset_299_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #299 for Simulator environments.",
		Settings = {
			AimFOV = 73,
			AimSmoothness = 47,
			ESPMaxDist = 475,
			WalkSpeed = 38,
			JumpPower = 97,
			ChamsFillAlpha = 45,
			SpinSpeed = 36,
			FireRateScale = 145,
		},
	},
	["Preset_300_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #300 for Duel environments.",
		Settings = {
			AimFOV = 80,
			AimSmoothness = 5,
			ESPMaxDist = 500,
			WalkSpeed = 40,
			JumpPower = 100,
			ChamsFillAlpha = 50,
			SpinSpeed = 40,
			FireRateScale = 150,
		},
	},
	["Preset_301_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #301 for Arena environments.",
		Settings = {
			AimFOV = 87,
			AimSmoothness = 8,
			ESPMaxDist = 525,
			WalkSpeed = 42,
			JumpPower = 103,
			ChamsFillAlpha = 55,
			SpinSpeed = 44,
			FireRateScale = 155,
		},
	},
	["Preset_302_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #302 for Obby environments.",
		Settings = {
			AimFOV = 94,
			AimSmoothness = 11,
			ESPMaxDist = 550,
			WalkSpeed = 44,
			JumpPower = 106,
			ChamsFillAlpha = 60,
			SpinSpeed = 48,
			FireRateScale = 160,
		},
	},
	["Preset_303_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #303 for Sandbox environments.",
		Settings = {
			AimFOV = 101,
			AimSmoothness = 14,
			ESPMaxDist = 575,
			WalkSpeed = 46,
			JumpPower = 109,
			ChamsFillAlpha = 65,
			SpinSpeed = 52,
			FireRateScale = 165,
		},
	},
	["Preset_304_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #304 for Tactical environments.",
		Settings = {
			AimFOV = 108,
			AimSmoothness = 17,
			ESPMaxDist = 600,
			WalkSpeed = 48,
			JumpPower = 112,
			ChamsFillAlpha = 70,
			SpinSpeed = 56,
			FireRateScale = 170,
		},
	},
	["Preset_305_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #305 for Parkour environments.",
		Settings = {
			AimFOV = 115,
			AimSmoothness = 20,
			ESPMaxDist = 625,
			WalkSpeed = 50,
			JumpPower = 115,
			ChamsFillAlpha = 75,
			SpinSpeed = 60,
			FireRateScale = 175,
		},
	},
	["Preset_306_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #306 for Shooter environments.",
		Settings = {
			AimFOV = 122,
			AimSmoothness = 23,
			ESPMaxDist = 650,
			WalkSpeed = 52,
			JumpPower = 118,
			ChamsFillAlpha = 80,
			SpinSpeed = 64,
			FireRateScale = 180,
		},
	},
	["Preset_307_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #307 for Racing environments.",
		Settings = {
			AimFOV = 129,
			AimSmoothness = 26,
			ESPMaxDist = 675,
			WalkSpeed = 54,
			JumpPower = 121,
			ChamsFillAlpha = 85,
			SpinSpeed = 68,
			FireRateScale = 185,
		},
	},
	["Preset_308_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #308 for Survival environments.",
		Settings = {
			AimFOV = 136,
			AimSmoothness = 29,
			ESPMaxDist = 700,
			WalkSpeed = 56,
			JumpPower = 124,
			ChamsFillAlpha = 20,
			SpinSpeed = 72,
			FireRateScale = 80,
		},
	},
	["Preset_309_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #309 for Simulator environments.",
		Settings = {
			AimFOV = 143,
			AimSmoothness = 32,
			ESPMaxDist = 725,
			WalkSpeed = 58,
			JumpPower = 127,
			ChamsFillAlpha = 25,
			SpinSpeed = 11,
			FireRateScale = 85,
		},
	},
	["Preset_310_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #310 for Duel environments.",
		Settings = {
			AimFOV = 150,
			AimSmoothness = 35,
			ESPMaxDist = 750,
			WalkSpeed = 60,
			JumpPower = 130,
			ChamsFillAlpha = 30,
			SpinSpeed = 15,
			FireRateScale = 90,
		},
	},
	["Preset_311_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #311 for Arena environments.",
		Settings = {
			AimFOV = 157,
			AimSmoothness = 38,
			ESPMaxDist = 775,
			WalkSpeed = 62,
			JumpPower = 133,
			ChamsFillAlpha = 35,
			SpinSpeed = 19,
			FireRateScale = 95,
		},
	},
	["Preset_312_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #312 for Obby environments.",
		Settings = {
			AimFOV = 164,
			AimSmoothness = 41,
			ESPMaxDist = 800,
			WalkSpeed = 64,
			JumpPower = 51,
			ChamsFillAlpha = 40,
			SpinSpeed = 23,
			FireRateScale = 100,
		},
	},
	["Preset_313_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #313 for Sandbox environments.",
		Settings = {
			AimFOV = 171,
			AimSmoothness = 44,
			ESPMaxDist = 825,
			WalkSpeed = 66,
			JumpPower = 54,
			ChamsFillAlpha = 45,
			SpinSpeed = 27,
			FireRateScale = 105,
		},
	},
	["Preset_314_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #314 for Tactical environments.",
		Settings = {
			AimFOV = 178,
			AimSmoothness = 47,
			ESPMaxDist = 850,
			WalkSpeed = 68,
			JumpPower = 57,
			ChamsFillAlpha = 50,
			SpinSpeed = 31,
			FireRateScale = 110,
		},
	},
	["Preset_315_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #315 for Parkour environments.",
		Settings = {
			AimFOV = 185,
			AimSmoothness = 5,
			ESPMaxDist = 875,
			WalkSpeed = 70,
			JumpPower = 60,
			ChamsFillAlpha = 55,
			SpinSpeed = 35,
			FireRateScale = 115,
		},
	},
	["Preset_316_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #316 for Shooter environments.",
		Settings = {
			AimFOV = 192,
			AimSmoothness = 8,
			ESPMaxDist = 900,
			WalkSpeed = 72,
			JumpPower = 63,
			ChamsFillAlpha = 60,
			SpinSpeed = 39,
			FireRateScale = 120,
		},
	},
	["Preset_317_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #317 for Racing environments.",
		Settings = {
			AimFOV = 199,
			AimSmoothness = 11,
			ESPMaxDist = 925,
			WalkSpeed = 74,
			JumpPower = 66,
			ChamsFillAlpha = 65,
			SpinSpeed = 43,
			FireRateScale = 125,
		},
	},
	["Preset_318_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #318 for Survival environments.",
		Settings = {
			AimFOV = 206,
			AimSmoothness = 14,
			ESPMaxDist = 950,
			WalkSpeed = 76,
			JumpPower = 69,
			ChamsFillAlpha = 70,
			SpinSpeed = 47,
			FireRateScale = 130,
		},
	},
	["Preset_319_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #319 for Simulator environments.",
		Settings = {
			AimFOV = 213,
			AimSmoothness = 17,
			ESPMaxDist = 975,
			WalkSpeed = 78,
			JumpPower = 72,
			ChamsFillAlpha = 75,
			SpinSpeed = 51,
			FireRateScale = 135,
		},
	},
	["Preset_320_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #320 for Duel environments.",
		Settings = {
			AimFOV = 220,
			AimSmoothness = 20,
			ESPMaxDist = 1000,
			WalkSpeed = 16,
			JumpPower = 75,
			ChamsFillAlpha = 80,
			SpinSpeed = 55,
			FireRateScale = 140,
		},
	},
	["Preset_321_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #321 for Arena environments.",
		Settings = {
			AimFOV = 227,
			AimSmoothness = 23,
			ESPMaxDist = 1025,
			WalkSpeed = 18,
			JumpPower = 78,
			ChamsFillAlpha = 85,
			SpinSpeed = 59,
			FireRateScale = 145,
		},
	},
	["Preset_322_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #322 for Obby environments.",
		Settings = {
			AimFOV = 234,
			AimSmoothness = 26,
			ESPMaxDist = 1050,
			WalkSpeed = 20,
			JumpPower = 81,
			ChamsFillAlpha = 20,
			SpinSpeed = 63,
			FireRateScale = 150,
		},
	},
	["Preset_323_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #323 for Sandbox environments.",
		Settings = {
			AimFOV = 241,
			AimSmoothness = 29,
			ESPMaxDist = 1075,
			WalkSpeed = 22,
			JumpPower = 84,
			ChamsFillAlpha = 25,
			SpinSpeed = 67,
			FireRateScale = 155,
		},
	},
	["Preset_324_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #324 for Tactical environments.",
		Settings = {
			AimFOV = 248,
			AimSmoothness = 32,
			ESPMaxDist = 1100,
			WalkSpeed = 24,
			JumpPower = 87,
			ChamsFillAlpha = 30,
			SpinSpeed = 71,
			FireRateScale = 160,
		},
	},
	["Preset_325_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #325 for Parkour environments.",
		Settings = {
			AimFOV = 255,
			AimSmoothness = 35,
			ESPMaxDist = 1125,
			WalkSpeed = 26,
			JumpPower = 90,
			ChamsFillAlpha = 35,
			SpinSpeed = 10,
			FireRateScale = 165,
		},
	},
	["Preset_326_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #326 for Shooter environments.",
		Settings = {
			AimFOV = 262,
			AimSmoothness = 38,
			ESPMaxDist = 1150,
			WalkSpeed = 28,
			JumpPower = 93,
			ChamsFillAlpha = 40,
			SpinSpeed = 14,
			FireRateScale = 170,
		},
	},
	["Preset_327_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #327 for Racing environments.",
		Settings = {
			AimFOV = 269,
			AimSmoothness = 41,
			ESPMaxDist = 1175,
			WalkSpeed = 30,
			JumpPower = 96,
			ChamsFillAlpha = 45,
			SpinSpeed = 18,
			FireRateScale = 175,
		},
	},
	["Preset_328_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #328 for Survival environments.",
		Settings = {
			AimFOV = 276,
			AimSmoothness = 44,
			ESPMaxDist = 1200,
			WalkSpeed = 32,
			JumpPower = 99,
			ChamsFillAlpha = 50,
			SpinSpeed = 22,
			FireRateScale = 180,
		},
	},
	["Preset_329_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #329 for Simulator environments.",
		Settings = {
			AimFOV = 283,
			AimSmoothness = 47,
			ESPMaxDist = 1225,
			WalkSpeed = 34,
			JumpPower = 102,
			ChamsFillAlpha = 55,
			SpinSpeed = 26,
			FireRateScale = 185,
		},
	},
	["Preset_330_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #330 for Duel environments.",
		Settings = {
			AimFOV = 290,
			AimSmoothness = 5,
			ESPMaxDist = 1250,
			WalkSpeed = 36,
			JumpPower = 105,
			ChamsFillAlpha = 60,
			SpinSpeed = 30,
			FireRateScale = 80,
		},
	},
	["Preset_331_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #331 for Arena environments.",
		Settings = {
			AimFOV = 297,
			AimSmoothness = 8,
			ESPMaxDist = 1275,
			WalkSpeed = 38,
			JumpPower = 108,
			ChamsFillAlpha = 65,
			SpinSpeed = 34,
			FireRateScale = 85,
		},
	},
	["Preset_332_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #332 for Obby environments.",
		Settings = {
			AimFOV = 304,
			AimSmoothness = 11,
			ESPMaxDist = 1300,
			WalkSpeed = 40,
			JumpPower = 111,
			ChamsFillAlpha = 70,
			SpinSpeed = 38,
			FireRateScale = 90,
		},
	},
	["Preset_333_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #333 for Sandbox environments.",
		Settings = {
			AimFOV = 311,
			AimSmoothness = 14,
			ESPMaxDist = 1325,
			WalkSpeed = 42,
			JumpPower = 114,
			ChamsFillAlpha = 75,
			SpinSpeed = 42,
			FireRateScale = 95,
		},
	},
	["Preset_334_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #334 for Tactical environments.",
		Settings = {
			AimFOV = 318,
			AimSmoothness = 17,
			ESPMaxDist = 1350,
			WalkSpeed = 44,
			JumpPower = 117,
			ChamsFillAlpha = 80,
			SpinSpeed = 46,
			FireRateScale = 100,
		},
	},
	["Preset_335_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #335 for Parkour environments.",
		Settings = {
			AimFOV = 65,
			AimSmoothness = 20,
			ESPMaxDist = 1375,
			WalkSpeed = 46,
			JumpPower = 120,
			ChamsFillAlpha = 85,
			SpinSpeed = 50,
			FireRateScale = 105,
		},
	},
	["Preset_336_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #336 for Shooter environments.",
		Settings = {
			AimFOV = 72,
			AimSmoothness = 23,
			ESPMaxDist = 200,
			WalkSpeed = 48,
			JumpPower = 123,
			ChamsFillAlpha = 20,
			SpinSpeed = 54,
			FireRateScale = 110,
		},
	},
	["Preset_337_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #337 for Racing environments.",
		Settings = {
			AimFOV = 79,
			AimSmoothness = 26,
			ESPMaxDist = 225,
			WalkSpeed = 50,
			JumpPower = 126,
			ChamsFillAlpha = 25,
			SpinSpeed = 58,
			FireRateScale = 115,
		},
	},
	["Preset_338_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #338 for Survival environments.",
		Settings = {
			AimFOV = 86,
			AimSmoothness = 29,
			ESPMaxDist = 250,
			WalkSpeed = 52,
			JumpPower = 129,
			ChamsFillAlpha = 30,
			SpinSpeed = 62,
			FireRateScale = 120,
		},
	},
	["Preset_339_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #339 for Simulator environments.",
		Settings = {
			AimFOV = 93,
			AimSmoothness = 32,
			ESPMaxDist = 275,
			WalkSpeed = 54,
			JumpPower = 132,
			ChamsFillAlpha = 35,
			SpinSpeed = 66,
			FireRateScale = 125,
		},
	},
	["Preset_340_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #340 for Duel environments.",
		Settings = {
			AimFOV = 100,
			AimSmoothness = 35,
			ESPMaxDist = 300,
			WalkSpeed = 56,
			JumpPower = 50,
			ChamsFillAlpha = 40,
			SpinSpeed = 70,
			FireRateScale = 130,
		},
	},
	["Preset_341_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #341 for Arena environments.",
		Settings = {
			AimFOV = 107,
			AimSmoothness = 38,
			ESPMaxDist = 325,
			WalkSpeed = 58,
			JumpPower = 53,
			ChamsFillAlpha = 45,
			SpinSpeed = 74,
			FireRateScale = 135,
		},
	},
	["Preset_342_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #342 for Obby environments.",
		Settings = {
			AimFOV = 114,
			AimSmoothness = 41,
			ESPMaxDist = 350,
			WalkSpeed = 60,
			JumpPower = 56,
			ChamsFillAlpha = 50,
			SpinSpeed = 13,
			FireRateScale = 140,
		},
	},
	["Preset_343_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #343 for Sandbox environments.",
		Settings = {
			AimFOV = 121,
			AimSmoothness = 44,
			ESPMaxDist = 375,
			WalkSpeed = 62,
			JumpPower = 59,
			ChamsFillAlpha = 55,
			SpinSpeed = 17,
			FireRateScale = 145,
		},
	},
	["Preset_344_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #344 for Tactical environments.",
		Settings = {
			AimFOV = 128,
			AimSmoothness = 47,
			ESPMaxDist = 400,
			WalkSpeed = 64,
			JumpPower = 62,
			ChamsFillAlpha = 60,
			SpinSpeed = 21,
			FireRateScale = 150,
		},
	},
	["Preset_345_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #345 for Parkour environments.",
		Settings = {
			AimFOV = 135,
			AimSmoothness = 5,
			ESPMaxDist = 425,
			WalkSpeed = 66,
			JumpPower = 65,
			ChamsFillAlpha = 65,
			SpinSpeed = 25,
			FireRateScale = 155,
		},
	},
	["Preset_346_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #346 for Shooter environments.",
		Settings = {
			AimFOV = 142,
			AimSmoothness = 8,
			ESPMaxDist = 450,
			WalkSpeed = 68,
			JumpPower = 68,
			ChamsFillAlpha = 70,
			SpinSpeed = 29,
			FireRateScale = 160,
		},
	},
	["Preset_347_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #347 for Racing environments.",
		Settings = {
			AimFOV = 149,
			AimSmoothness = 11,
			ESPMaxDist = 475,
			WalkSpeed = 70,
			JumpPower = 71,
			ChamsFillAlpha = 75,
			SpinSpeed = 33,
			FireRateScale = 165,
		},
	},
	["Preset_348_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #348 for Survival environments.",
		Settings = {
			AimFOV = 156,
			AimSmoothness = 14,
			ESPMaxDist = 500,
			WalkSpeed = 72,
			JumpPower = 74,
			ChamsFillAlpha = 80,
			SpinSpeed = 37,
			FireRateScale = 170,
		},
	},
	["Preset_349_Simulator_Obsidian_Plasma"] = {
		Category = "Simulator",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #349 for Simulator environments.",
		Settings = {
			AimFOV = 163,
			AimSmoothness = 17,
			ESPMaxDist = 525,
			WalkSpeed = 74,
			JumpPower = 77,
			ChamsFillAlpha = 85,
			SpinSpeed = 41,
			FireRateScale = 175,
		},
	},
	["Preset_350_Duel_Void_Electric"] = {
		Category = "Duel",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #350 for Duel environments.",
		Settings = {
			AimFOV = 170,
			AimSmoothness = 20,
			ESPMaxDist = 550,
			WalkSpeed = 76,
			JumpPower = 80,
			ChamsFillAlpha = 20,
			SpinSpeed = 45,
			FireRateScale = 180,
		},
	},
	["Preset_351_Arena_AMOLED_Cyan_Violet"] = {
		Category = "Arena",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #351 for Arena environments.",
		Settings = {
			AimFOV = 177,
			AimSmoothness = 23,
			ESPMaxDist = 575,
			WalkSpeed = 78,
			JumpPower = 83,
			ChamsFillAlpha = 25,
			SpinSpeed = 49,
			FireRateScale = 185,
		},
	},
	["Preset_352_Obby_Midnight_Indigo"] = {
		Category = "Obby",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #352 for Obby environments.",
		Settings = {
			AimFOV = 184,
			AimSmoothness = 26,
			ESPMaxDist = 600,
			WalkSpeed = 16,
			JumpPower = 86,
			ChamsFillAlpha = 30,
			SpinSpeed = 53,
			FireRateScale = 80,
		},
	},
	["Preset_353_Sandbox_Cyber_Sapphire"] = {
		Category = "Sandbox",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #353 for Sandbox environments.",
		Settings = {
			AimFOV = 191,
			AimSmoothness = 29,
			ESPMaxDist = 625,
			WalkSpeed = 18,
			JumpPower = 89,
			ChamsFillAlpha = 35,
			SpinSpeed = 57,
			FireRateScale = 85,
		},
	},
	["Preset_354_Tactical_Obsidian_Plasma"] = {
		Category = "Tactical",
		Palette = "Obsidian_Plasma",
		PrimaryNeon = Color3.fromRGB(34, 211, 238),
		SecondaryNeon = Color3.fromRGB(192, 132, 252),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #354 for Tactical environments.",
		Settings = {
			AimFOV = 198,
			AimSmoothness = 32,
			ESPMaxDist = 650,
			WalkSpeed = 20,
			JumpPower = 92,
			ChamsFillAlpha = 40,
			SpinSpeed = 61,
			FireRateScale = 90,
		},
	},
	["Preset_355_Parkour_Void_Electric"] = {
		Category = "Parkour",
		Palette = "Void_Electric",
		PrimaryNeon = Color3.fromRGB(59, 130, 246),
		SecondaryNeon = Color3.fromRGB(147, 51, 234),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #355 for Parkour environments.",
		Settings = {
			AimFOV = 205,
			AimSmoothness = 35,
			ESPMaxDist = 675,
			WalkSpeed = 22,
			JumpPower = 95,
			ChamsFillAlpha = 45,
			SpinSpeed = 65,
			FireRateScale = 95,
		},
	},
	["Preset_356_Shooter_AMOLED_Cyan_Violet"] = {
		Category = "Shooter",
		Palette = "AMOLED_Cyan_Violet",
		PrimaryNeon = Color3.fromRGB(56, 189, 248),
		SecondaryNeon = Color3.fromRGB(168, 85, 247),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #356 for Shooter environments.",
		Settings = {
			AimFOV = 212,
			AimSmoothness = 38,
			ESPMaxDist = 700,
			WalkSpeed = 24,
			JumpPower = 98,
			ChamsFillAlpha = 50,
			SpinSpeed = 69,
			FireRateScale = 100,
		},
	},
	["Preset_357_Racing_Midnight_Indigo"] = {
		Category = "Racing",
		Palette = "Midnight_Indigo",
		PrimaryNeon = Color3.fromRGB(99, 102, 241),
		SecondaryNeon = Color3.fromRGB(236, 72, 153),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #357 for Racing environments.",
		Settings = {
			AimFOV = 219,
			AimSmoothness = 41,
			ESPMaxDist = 725,
			WalkSpeed = 26,
			JumpPower = 101,
			ChamsFillAlpha = 55,
			SpinSpeed = 73,
			FireRateScale = 105,
		},
	},
	["Preset_358_Survival_Cyber_Sapphire"] = {
		Category = "Survival",
		Palette = "Cyber_Sapphire",
		PrimaryNeon = Color3.fromRGB(14, 165, 233),
		SecondaryNeon = Color3.fromRGB(139, 92, 246),
		Description = "Optimized Pure Black AMOLED UI & client movement/visual preset #358 for Survival environments.",
		Settings = {
			AimFOV = 226,
			AimSmoothness = 44,
			ESPMaxDist = 750,
			WalkSpeed = 28,
			JumpPower = 104,
			ChamsFillAlpha = 60,
			SpinSpeed = 12,
			FireRateScale = 110,
		},
	},
}

local function applyPreset(presetName: string)
	local preset = ConfigPresets[presetName]
	if not preset then
		return false
	end
	Theme.NeonBlue = preset.PrimaryNeon
	Theme.NeonPurple = preset.SecondaryNeon
	for k, v in pairs(preset.Settings) do
		if State.Flags[k] ~= nil then
			State.Flags[k] = v
		end
	end
	return true
end

selectTab("Aim")
setWindowOpen(true)

return {
	ScreenGui = ScreenGui,
	State = State,
	Theme = Theme,
	ConfigPresets = ConfigPresets,
	ApplyPreset = applyPreset,
	SetWindowOpen = setWindowOpen,
}
