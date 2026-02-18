local Hive = {}
Hive.__index = Hive

local Services = {}
Services.Players = game:GetService("Players")
Services.TweenService = game:GetService("TweenService")
Services.UserInputService = game:GetService("UserInputService")
Services.HttpService = game:GetService("HttpService")

local LocalPlayer = Services.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local THEME = {
	Background = Color3.fromRGB(25, 25, 35),
	Secondary = Color3.fromRGB(35, 35, 50),
	Accent = Color3.fromRGB(65, 105, 225),
	AccentLight = Color3.fromRGB(100, 149, 237),
	Text = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
	Border = Color3.fromRGB(60, 60, 80),
}

local Config = {}
Config.FolderName = "unity-inc/"
Config.CanWriteFile = writefile ~= nil and readfile ~= nil

function Config:Save(name, data)
	if not self.CanWriteFile then return end
	if not isfolder(self.FolderName) then makefolder(self.FolderName) end
	if not isfolder(self.FolderName .. name) then makefolder(self.FolderName .. name) end
	writefile(self.FolderName .. name .. "/config.json", Services.HttpService:JSONEncode(data))
end

function Config:Load(name)
	if not self.CanWriteFile then return nil end
	local path = self.FolderName .. name .. "/config.json"
	if isfile(path) then
		return Services.HttpService:JSONDecode(readfile(path))
	else
		return nil
	end
end

local function CreateInstance(className, properties)
	local instance = Instance.new(className)
	for prop, value in pairs(properties) do
		instance[prop] = value
	end
	return instance
end

local function Cleanup()
	local oldGui = PlayerGui:FindFirstChild("HiveGUI")
	if oldGui then
		oldGui:Destroy()
	end
end

local Version = "v1.0.2"

local RootFolder = nil
local ScriptFolder = nil

local function GetRootFolder()
	if not RootFolder or not RootFolder.Parent then
		RootFolder = game.Workspace:FindFirstChild("Hive_gui")
		if not RootFolder then
			RootFolder = Instance.new("Folder")
			RootFolder.Name = "Hive_gui"
			RootFolder.Parent = game.Workspace
		end
	end
	return RootFolder
end

local function GetScriptFolder(scriptName)
	if not ScriptFolder or not ScriptFolder.Parent or ScriptFolder.Name ~= scriptName then
		local root = GetRootFolder()
		ScriptFolder = root:FindFirstChild(scriptName)
		if not ScriptFolder then
			ScriptFolder = Instance.new("Folder")
			ScriptFolder.Name = scriptName
			ScriptFolder.Parent = root
		end
	end
	return ScriptFolder
end

Cleanup()

function Hive.new(scriptName)
	Cleanup()
	
	local self = setmetatable({}, Hive)
	
	self.GUI = nil
	self.MainFrame = nil
	self.Visible = false
	self.ScriptName = scriptName or "Default"
	self.ScriptFolder = GetScriptFolder(self.ScriptName)
	self.Tabs = {}
	self.ActiveTab = nil
	self.Config = Config:Load(self.ScriptName) or {}
	
	self:CreateGUI()
	
	return self
end

function Hive:CreateGUI()
	local screenGui = CreateInstance("ScreenGui", {
		Name = "HiveGUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 9999,
		Enabled = false,
	})
	screenGui.Parent = PlayerGui
	
	local mainFrame = CreateInstance("Frame", {
		Name = "MainFrame",
		BackgroundColor3 = THEME.Background,
		BorderColor3 = THEME.Border,
		BorderSizePixel = 1,
		Position = UDim2.new(0.5, -225, 0.5, -225),
		Size = UDim2.new(0, 450, 0, 450),
		ClipsDescendants = true,
	})
	
	local titleBar = CreateInstance("Frame", {
		Name = "TitleBar",
		BackgroundColor3 = THEME.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 35),
		ZIndex = 2,
	})
	
	local titleLabel = CreateInstance("TextLabel", {
		Name = "TitleLabel",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(0, 200, 1, 0),
		Text = "Hive",
		TextColor3 = THEME.AccentLight,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		ZIndex = 3,
	})
	
	local versionLabel = CreateInstance("TextLabel", {
		Name = "VersionLabel",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -10, 0, 0),
		Size = UDim2.new(0, 200, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Text = Version,
		TextColor3 = THEME.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		ZIndex = 3,
	})
	
	local tabContainer = CreateInstance("Frame", {
		Name = "TabContainer",
		BackgroundColor3 = THEME.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 45),
		Position = UDim2.new(0, 0, 0, 35),
		Visible = false,
		ZIndex = 2,
	})
	
	local tabPadding = CreateInstance("UIPadding", {
		Name = "TabPadding",
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
	})
	
	local tabScroll = CreateInstance("ScrollingFrame", {
		Name = "TabScroll",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 1, 0),
		ScrollBarThickness = 0,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
	})
	
	local tabList = CreateInstance("UIListLayout", {
		Name = "TabList",
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	
	local contentFrame = CreateInstance("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 80),
		Size = UDim2.new(1, 0, 1, -80),
		Visible = false,
	})
	
	local scrollFrame = CreateInstance("ScrollingFrame", {
		Name = "ScrollFrame",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 5, 0, 5),
		Size = UDim2.new(1, -10, 1, -10),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = THEME.Accent,
		BorderSizePixel = 0,
	})
	
	local listLayout = CreateInstance("UIListLayout", {
		Name = "ListLayout",
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	
	local padding = CreateInstance("UIPadding", {
		Name = "Padding",
		PaddingTop = UDim.new(0, 5),
	})
	
	titleBar.Parent = mainFrame
	titleLabel.Parent = titleBar
	versionLabel.Parent = titleBar
	tabContainer.Parent = mainFrame
	tabPadding.Parent = tabContainer
	tabScroll.Parent = tabContainer
	tabList.Parent = tabScroll
	contentFrame.Parent = mainFrame
	scrollFrame.Parent = contentFrame
	listLayout.Parent = scrollFrame
	padding.Parent = scrollFrame
	
	mainFrame.Parent = screenGui
	
	self.GUI = screenGui
	self.MainFrame = mainFrame
	self.TitleBar = titleBar
	self.TabContainer = tabContainer
	self.TabScroll = tabScroll
	self.ContentFrame = contentFrame
	self.ScrollFrame = scrollFrame
	self.ListLayout = listLayout
	
	self:MakeDraggable()
end

function Hive:MakeDraggable()
	local dragging = false
	local dragStart = nil
	local startPos = nil
	
	local inputBegan = function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if input.Position.Y - self.MainFrame.AbsolutePosition.Y < 35 then
				dragging = true
				dragStart = input.Position
				startPos = self.MainFrame.Position
			end
		end
	end
	
	local inputEnded = function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end
	
	local inputChanged = function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			self.MainFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end
	
	self.TitleBar.InputBegan:Connect(inputBegan)
	self.TitleBar.InputEnded:Connect(inputEnded)
	self.TitleBar.InputChanged:Connect(inputChanged)
end

function Hive:Toggle()
	self.Visible = not self.Visible
	self.GUI.Enabled = self.Visible
	
	if self.Visible then
		self:UpdateCanvasSize()
	end
end

function Hive:Show()
	self.Visible = true
	self.GUI.Enabled = true
	self:UpdateCanvasSize()
end

function Hive:Hide()
	self.Visible = false
	self.GUI.Enabled = false
end

function Hive:Destroy()
	if self.GUI then
		self.GUI:Destroy()
	end
end

function Hive:Save(key, value)
	self.Config[key] = value
	Config:Save(self.ScriptName, self.Config)
end

function Hive:Load(key)
	return self.Config[key]
end

function Hive:CreateTab(name)
	local tabCount = #self.Tabs
	
	if tabCount == 0 then
		self.TabContainer.Visible = true
		self.ContentFrame.Visible = true
	end
	
	local tabButton = CreateInstance("TextButton", {
		Name = "Tab_" .. name,
		BackgroundColor3 = tabCount == 0 and THEME.Accent or THEME.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 80, 0, 35),
		AutoButtonColor = false,
		Text = name,
		TextColor3 = THEME.Text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		ZIndex = 3,
	})
	
	local tabStroke = CreateInstance("UIStroke", {
		Color = THEME.Border,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	tabStroke.Parent = tabButton
	
	local tabCorner = CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 6),
	})
	tabCorner.Parent = tabButton
	
	local tabPadding = CreateInstance("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	})
	tabPadding.Parent = tabButton
	
	local buttonText = tabButton
	
	task.wait(0.1)
	local textWidth = tabButton.TextBounds.X
	if textWidth < 50 then textWidth = 50 end
	tabButton.Size = UDim2.new(0, textWidth + 40, 0, 35)
	
	local tabContent = CreateInstance("ScrollingFrame", {
		Name = "TabContent_" .. name,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 5, 0, 5),
		Size = UDim2.new(1, -10, 1, -10),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = THEME.Accent,
		BorderSizePixel = 0,
		Visible = tabCount == 0,
	})
	
	local tabListLayout = CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	
	local tabContentPadding = CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, 5),
	})
	
	tabListLayout.Parent = tabContent
	tabContentPadding.Parent = tabContent
	tabContent.Parent = self.ContentFrame
	
	local tab = {
		Name = name,
		Button = tabButton,
		Content = tabContent,
		ListLayout = tabListLayout,
		ScrollFrame = tabContent,
	}
	
	tabButton.Parent = self.TabScroll
	
	tabButton.MouseButton1Click:Connect(function()
		for _, t in ipairs(self.Tabs) do
			t.Content.Visible = false
			t.Button.BackgroundColor3 = THEME.Secondary
		end
		tabContent.Visible = true
		tabButton.BackgroundColor3 = THEME.Accent
		self.ActiveTab = tab
		self:UpdateCanvasSize()
	end)
	
	tabButton.MouseEnter:Connect(function()
		if self.ActiveTab ~= tab then
			tabButton.BackgroundColor3 = THEME.Border
		end
	end)
	
	tabButton.MouseLeave:Connect(function()
		if self.ActiveTab ~= tab then
			tabButton.BackgroundColor3 = THEME.Secondary
		end
	end)
	
	table.insert(self.Tabs, tab)
	
	if tabCount == 0 then
		self.ActiveTab = tab
	end
	
	self:UpdateTabSize()
	self:UpdateCanvasSize()
	
	return tab
end

function Hive:UpdateTabSize()
	local tabWidth = 0
	for _, tab in ipairs(self.Tabs) do
		tabWidth = tabWidth + tab.Button.AbsoluteSize.X + 6
	end
	self.TabScroll.CanvasSize = UDim2.new(0, tabWidth, 0, 0)
end

function Hive:UpdateCanvasSize()
	if self.ActiveTab and self.ActiveTab.ListLayout then
		local contentSize = self.ActiveTab.ListLayout.AbsoluteContentSize
		self.ActiveTab.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 10)
	end
end

function Hive:Tab(name, callback)
	local existingTab = self:FindTab(name)
	
	if existingTab then
		for _, t in ipairs(self.Tabs) do
			t.Content.Visible = false
			t.Button.BackgroundColor3 = THEME.Secondary
		end
		existingTab.Content.Visible = true
		existingTab.Button.BackgroundColor3 = THEME.Accent
		self.ActiveTab = existingTab
	else
		self.ActiveTab = self:CreateTab(name)
	end
	
	if callback then
		callback(self)
	end
end

function Hive:FindTab(name)
	for _, tab in ipairs(self.Tabs) do
		if tab.Name == name then
			return tab
		end
	end
	return nil
end

function Hive:Section(name, callback)
	if not self.ActiveTab then return end
	
	local tabContent = self.ActiveTab.ScrollFrame
	
	local sectionFrame = CreateInstance("Frame", {
		Name = "Section_" .. name,
		BackgroundColor3 = THEME.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	
	local sectionLabel = CreateInstance("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -20, 0, 30),
		Text = name,
		TextColor3 = THEME.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
	})
	
	local highlight = CreateInstance("Frame", {
		Name = "Highlight",
		BackgroundColor3 = THEME.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
	})
	
	local sectionContent = CreateInstance("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	
	local sectionList = CreateInstance("UIListLayout", {
		Name = "ListLayout",
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	
	local sectionPadding = CreateInstance("UIPadding", {
		Name = "Padding",
		PaddingTop = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 5),
	})
	
	sectionList.Parent = sectionContent
	sectionPadding.Parent = sectionContent
	sectionLabel.Parent = sectionFrame
	highlight.Parent = sectionFrame
	sectionContent.Parent = sectionFrame
	sectionFrame.Parent = tabContent
	
	self.CurrentSection = sectionContent
	
	if callback then
		callback(self)
	end
	
	return sectionContent
end

function Hive:Label(text)
	if not self.CurrentSection then return end
	
	local label = CreateInstance("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = THEME.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		Size = UDim2.new(1, 0, 0, 20),
	})
	label.Parent = self.CurrentSection
	self:UpdateCanvasSize()
	return label
end

function Hive:Button(text, callback)
	if not self.CurrentSection then return end
	
	local button = CreateInstance("TextButton", {
		Name = "Button",
		BackgroundColor3 = THEME.Border,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 35),
		Text = text,
		TextColor3 = THEME.Text,
		Font = Enum.Font.Gotham,
		TextSize = 14,
	})
	
	local corner = CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 6),
	})
	corner.Parent = button
	
	button.MouseButton1Click:Connect(function()
		if callback then callback(button) end
	end)
	
	button.Parent = self.CurrentSection
	self:UpdateCanvasSize()
	return button
end

function Hive:CreateToggle(name, config, callback)
	if not self.CurrentSection then return end
	if not name or name == "" then return end
	
	config = config or {}
	
	local default = config.default or false
	local keybind = config.keybind
	local shouldSave = config.save or false
	local isOn = default
	
	-- Load saved state
	if shouldSave then
		local savedState = self:Load(name)
		if savedState ~= nil then
			isOn = savedState
		end
		local savedKey = self:Load(name .. "_Keybind")
		if savedKey ~= nil then
			keybind = Enum.KeyCode[savedKey]
		end
	end
	
	local toggleContainer = CreateInstance("Frame", {
		Name = "Toggle_" .. name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 35),
	})
	
	local toggleSwitch = CreateInstance("TextButton", {
		Name = "Switch",
		BackgroundColor3 = isOn and THEME.Accent or THEME.Border,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 44, 0, 22),
		Position = UDim2.new(0, 0, 0.5, -11),
		AutoButtonColor = false,
		Text = "",
	})
	
	local switchCorner = CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 11),
	})
	switchCorner.Parent = toggleSwitch
	
	local switchKnob = CreateInstance("Frame", {
		Name = "Knob",
		BackgroundColor3 = THEME.Text,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 18, 0, 18),
		Position = isOn and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
	})
	
	local knobCorner = CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 9),
	})
	knobCorner.Parent = switchKnob
	
	local toggleLabel = CreateInstance("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 50, 0.5, -10),
		Size = UDim2.new(1, -100, 0, 20),
		AnchorPoint = Vector2.new(0, 0.5),
		Text = name,
		TextColor3 = THEME.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.Gotham,
		TextSize = 14,
	})
	
	local keybindBox = CreateInstance("TextButton", {
		Name = "Keybind",
		BackgroundColor3 = THEME.Border,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 40, 0, 25),
		Position = UDim2.new(1, -45, 0.5, -12.5),
		Text = keybind and keybind.Name or "None",
		TextColor3 = THEME.Text,
		TextXAlignment = Enum.TextXAlignment.Center,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		AutoButtonColor = false,
	})
	
	local keybindCorner = CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 6),
	})
	keybindCorner.Parent = keybindBox
	
	switchKnob.Parent = toggleSwitch
	toggleLabel.Parent = toggleContainer
	keybindBox.Parent = toggleContainer
	toggleSwitch.Parent = toggleContainer
	
	local isRebinding = false
	
	local function updateToggle(state, save)
		isOn = state
		toggleSwitch.BackgroundColor3 = isOn and THEME.Accent or THEME.Border
		switchKnob.Position = isOn and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
		
		if save and shouldSave then
			self:Save(name, isOn)
		end
		
		if callback then callback(isOn) end
	end
	
	toggleSwitch.MouseButton1Click:Connect(function()
		updateToggle(not isOn, true)
	end)
	
	keybindBox.MouseButton1Click:Connect(function()
		isRebinding = true
		keybindBox.Text = "..."
	end)

	
	Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if isRebinding and input.UserInputType == Enum.UserInputType.Keyboard then
			keybind = input.KeyCode
			keybindBox.Text = keybind.Name
			isRebinding = false
			
			if shouldSave then
				self:Save(name .. "_Keybind", keybind.Name)
			end
			return
		end
		
		if keybind and input.KeyCode == keybind then
			updateToggle(not isOn, true)
		end
	end)
	
	toggleContainer.Parent = self.CurrentSection
	self:UpdateCanvasSize()
	
	local toggleObj = {
		Value = isOn,
		SetValue = function(state)
			updateToggle(state, true)
		end,
		GetValue = function()
			return isOn
		end,
	}
	
	return toggleObj
end

function Hive:Slider(name, options, callback)
	if not self.CurrentSection then return end
	
	local min = options.min or 0
	local max = options.max or 100
	local shouldSave = options.save or false
	local default = options.default or min
	
	-- Load saved value if save is enabled
	if shouldSave then
		local savedValue = self:Load(name)
		if savedValue ~= nil then
			default = savedValue
		end
	end
	
	local value = default
	
	local initialPercent = (default - min) / (max - min)
	
	local sliderContainer = CreateInstance("Frame", {
		Name = "Slider_" .. name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
	})
	
	local sliderLabel = CreateInstance("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -50, 0, 20),
		Text = name,
		TextColor3 = THEME.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.Gotham,
		TextSize = 14,
	})
	
	local valueLabel = CreateInstance("TextLabel", {
		Name = "Value",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -50, 0, 0),
		Size = UDim2.new(0, 50, 0, 20),
		AnchorPoint = Vector2.new(1, 0),
		Text = tostring(default),
		TextColor3 = THEME.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.Gotham,
		TextSize = 14,
	})
	
	local track = CreateInstance("Frame", {
		Name = "Track",
		BackgroundColor3 = THEME.Border,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 25),
		Size = UDim2.new(1, 0, 0, 6),
	})
	
	local trackCorner = CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 3),
	})
	trackCorner.Parent = track
	
	local fill = CreateInstance("Frame", {
		Name = "Fill",
		BackgroundColor3 = THEME.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(initialPercent, 0, 1, 0),
	})
	
	local fillCorner = CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 3),
	})
	fillCorner.Parent = fill
	
	local knob = CreateInstance("Frame", {
		Name = "Knob",
		BackgroundColor3 = THEME.Text,
		BorderSizePixel = 0,
		Position = UDim2.new(initialPercent, -8, 0.5, -8),
		Size = UDim2.new(0, 16, 0, 16),
	})
	
	local knobCorner = CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 8),
	})
	knobCorner.Parent = knob
	
	fill.Parent = track
	knob.Parent = track
	sliderLabel.Parent = sliderContainer
	valueLabel.Parent = sliderContainer
	track.Parent = sliderContainer
	
	local function updateSlider(percent)
		percent = math.clamp(percent, 0, 1)
		value = math.floor(min + (max - min) * percent)
		
		fill.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, -8, 0.5, -8)
		valueLabel.Text = tostring(value)
		
		if shouldSave then
			self:Save(name, value)
		end
		
		if callback then callback(value) end
	end
	
	local sliding = false
	
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true
		end
	end)
	
	knob.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = false
		end
	end)
	
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true
			local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
			updateSlider(relativeX)
		end
	end)
	
	track.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = false
		end
	end)
	
	Services.UserInputService.InputChanged:Connect(function(input)
		if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
			local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
			updateSlider(relativeX)
		end
	end)
	
	sliderContainer.Parent = self.CurrentSection
	self:UpdateCanvasSize()
	
	local sliderObj = {
		Value = value,
		SetValue = function(newValue)
			local percent = (newValue - min) / (max - min)
			updateSlider(percent)
		end,
		GetValue = function()
			return value
		end,
	}
	
	return sliderObj
end

function Hive:Dropdown(name, config, callback)
	if not self.CurrentSection then return end
	
	local options = config.options or {}
	local default = config.default or options[1] or "None"
	local mode = config.mode or "auto"
	local shouldSave = config.save or false
	
	-- Load saved value if save is enabled
	if shouldSave then
		local savedValue = self:Load(name)
		if savedValue ~= nil then
			for _, v in ipairs(options) do
				if v == savedValue then
					default = savedValue
					break
				end
			end
		end
	end
	
	local currentValue = default
	local isExpanded = false
	
	local dropdownContainer = CreateInstance("Frame", {
		Name = "Dropdown_" .. name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 35),
		ClipsDescendants = false,
	})
	
	local dropdownButton = CreateInstance("TextButton", {
		Name = "DropdownButton",
		BackgroundColor3 = THEME.Border,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 35),
		Text = name .. ": " .. default .. " ▼",
		TextColor3 = THEME.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.Gotham,
		TextSize = 14,
	})
	
	local dropdownPadding = CreateInstance("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
	})
	dropdownPadding.Parent = dropdownButton
	
	local corner = CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 6),
	})
	corner.Parent = dropdownButton
	
	local optionsFrame = CreateInstance("Frame", {
		Name = "Options",
		BackgroundColor3 = THEME.Secondary,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 35),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = false,
		ClipsDescendants = true,
	})
	
	local optionsList = CreateInstance("UIListLayout", {
		Padding = UDim.new(0, 2),
	})
	optionsList.Parent = optionsFrame
	
	local optionsPadding = CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
	})
	optionsPadding.Parent = optionsFrame
	
	local executeButton = CreateInstance("TextButton", {
		Name = "ExecuteButton",
		BackgroundColor3 = THEME.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		Text = "▶ Execute",
		TextColor3 = THEME.Text,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		Visible = mode == "manual",
	})
	
	local executeCorner = CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 6),
	})
	executeCorner.Parent = executeButton
	
	local function updateOptionsHeight()
		local optionsHeight = #options * 30 + 10
		optionsFrame.Size = UDim2.new(1, 0, 0, optionsHeight)
		
		local totalHeight = 35 + optionsHeight
		if mode == "manual" then
			totalHeight = totalHeight + 35
		end
		
		if isExpanded then
			dropdownContainer.Size = UDim2.new(1, 0, 0, totalHeight)
		else
			dropdownContainer.Size = UDim2.new(1, 0, 0, 35)
		end
	end
	
	local function selectOption(option)
		currentValue = option
		dropdownButton.Text = name .. ": " .. option .. " ▼"
		isExpanded = false
		optionsFrame.Visible = false
		dropdownButton.Text = name .. ": " .. option .. " ▼"
		
		if shouldSave then
			self:Save(name, option)
		end
		
		if mode == "auto" and callback then
			callback(option)
		end
		
		updateOptionsHeight()
		task.delay(0.05, function()
			self:UpdateCanvasSize()
		end)
	end
	
	local function toggleDropdown()
		isExpanded = not isExpanded
		optionsFrame.Visible = isExpanded
		updateOptionsHeight()
		if isExpanded then
			dropdownButton.Text = name .. ": " .. currentValue .. " ▲"
		else
			dropdownButton.Text = name .. ": " .. currentValue .. " ▼"
		end
		task.delay(0.05, function()
			self:UpdateCanvasSize()
		end)
	end
	
	for _, option in ipairs(options) do
		local optionButton = CreateInstance("TextButton", {
			Name = "Option_" .. option,
			BackgroundColor3 = THEME.Border,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			Text = option,
			TextColor3 = THEME.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.Gotham,
			TextSize = 14,
		})
		
		local optionPadding = CreateInstance("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
		})
		optionPadding.Parent = optionButton
		
		local optionCorner = CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 4),
		})
		optionCorner.Parent = optionButton
		
		optionButton.MouseButton1Click:Connect(function()
			selectOption(option)
		end)
		
		optionButton.Parent = optionsFrame
	end
	
	dropdownButton.MouseButton1Click:Connect(function()
		toggleDropdown()
	end)
	
	executeButton.MouseButton1Click:Connect(function()
		if callback then
			callback(currentValue)
		end
	end)
	
	executeButton.Parent = dropdownContainer
	optionsFrame.Parent = dropdownContainer
	dropdownButton.Parent = dropdownContainer
	
	dropdownContainer.Parent = self.CurrentSection
	
	updateOptionsHeight()
	self:UpdateCanvasSize()
	
	local dropdownObj = {
		Value = currentValue,
		SetValue = function(newValue)
			selectOption(newValue)
		end,
		GetValue = function()
			return currentValue
		end,
	}
	
	return dropdownObj
end

function Hive:Notify(title, message)
	local Players = Services.Players
	local player = Players.LocalPlayer
	
	local notification = CreateInstance("Frame", {
		Name = "Notification",
		BackgroundColor3 = THEME.Secondary,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 10),
		Size = UDim2.new(0, 250, 0, 60),
		ZIndex = 10000,
	})
	
	local corner = CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 8),
	})
	corner.Parent = notification
	
	local titleLabel = CreateInstance("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 5),
		Size = UDim2.new(1, -20, 0, 20),
		Text = title or "Notification",
		TextColor3 = THEME.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		ZIndex = 10001,
	})
	
	local messageLabel = CreateInstance("TextLabel", {
		Name = "Message",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 25),
		Size = UDim2.new(1, -20, 0, 30),
		Text = message or "",
		TextColor3 = THEME.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		ZIndex = 10001,
	})
	
	titleLabel.Parent = notification
	messageLabel.Parent = notification
	notification.Parent = self.GUI
	
	notification.Position = UDim2.new(0, 10, 0, 10)
	
	task.delay(3, function()
		notification:Destroy()
	end)
	
	return notification
end

return Hive