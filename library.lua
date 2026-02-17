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
	self.ToggleKey = Enum.KeyCode.RightShift
	self.ScriptName = scriptName or "Default"
	self.ScriptFolder = GetScriptFolder(self.ScriptName)
	self.Tabs = {}
	self.ActiveTab = nil
	
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
		Text = "v1.0.0",
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
	self:SetupToggleKey()
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

function Hive:SetupToggleKey()
	Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == self.ToggleKey then
			self:Toggle()
		end
	end)
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

function Hive:SetToggleKey(key)
	self.ToggleKey = key
end

function Hive:Destroy()
	if self.GUI then
		self.GUI:Destroy()
	end
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
	
	task.wait()
	tabButton.Size = UDim2.new(0, tabButton.TextBounds.X + 24, 0, 35)
	
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

return Hive