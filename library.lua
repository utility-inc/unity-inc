local Hive = {}
Hive.__index = Hive

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local OriginalAttributes = {}

local THEME = {
	Background = Color3.fromRGB(25, 25, 35),
	Secondary = Color3.fromRGB(35, 35, 50),
	Accent = Color3.fromRGB(65, 105, 225),
	AccentLight = Color3.fromRGB(100, 149, 237),
	Text = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(180, 180, 180),
	Border = Color3.fromRGB(60, 60, 80),
}

local CONFIG = {
	ToggleOffset = 50,
	ToggleWidth = 40,
	ToggleHeight = 20,
	KnobSize = 16,
	TabPosition = "Top",
	TabHeight = 45,
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
	
	for attr, value in pairs(OriginalAttributes) do
		if value == nil then
			LocalPlayer:SetAttribute(attr, nil)
		else
			LocalPlayer:SetAttribute(attr, value)
		end
	end
	OriginalAttributes = {}
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
		
		if not ScriptFolder:FindFirstChild("config") then
			local config = Instance.new("Folder")
			config.Name = "config"
			config.Parent = ScriptFolder
		end
		
		if not ScriptFolder:FindFirstChild("flags") then
			local flags = Instance.new("Folder")
			flags.Name = "flags"
			flags.Parent = ScriptFolder
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
	self.KeySystemEnabled = false
	self.Keybinds = {}
	self.Components = {}
	self.Sectors = {}
	self.ActiveSector = nil
	self.ToggleKey = Enum.KeyCode.RightShift
	self.ScriptName = scriptName or "Default"
	self.ScriptFolder = GetScriptFolder(self.ScriptName)
	
	self:LoadSavedData()
	self:CreateGUI()
	
	return self
end

function Hive:LoadSavedData()
	local config = self.ScriptFolder:FindFirstChild("config")
	local flags = self.ScriptFolder:FindFirstChild("flags")
	
	if config then
		for _, child in ipairs(config:GetChildren()) do
			if child:IsA("StringValue") then
				local key = child.Name
				local value = child.Value
				
				if value == "true" then
					self.SavedConfig = self.SavedConfig or {}
					self.SavedConfig[key] = true
				elseif value == "false" then
					self.SavedConfig = self.SavedConfig or {}
					self.SavedConfig[key] = false
				elseif tonumber(value) then
					self.SavedConfig = self.SavedConfig or {}
					self.SavedConfig[key] = tonumber(value)
				else
					self.SavedConfig = self.SavedConfig or {}
					self.SavedConfig[key] = value
				end
			end
		end
	end
	
	if flags then
		for _, child in ipairs(flags:GetChildren()) do
			if child:IsA("StringValue") then
				local key = child.Name
				local value = child.Value
				
				if value == "true" then
					self.SavedFlags = self.SavedFlags or {}
					self.SavedFlags[key] = true
				elseif value == "false" then
					self.SavedFlags = self.SavedFlags or {}
					self.SavedFlags[key] = false
				elseif tonumber(value) then
					self.SavedFlags = self.SavedFlags or {}
					self.SavedFlags[key] = tonumber(value)
				else
					self.SavedFlags = self.SavedFlags or {}
					self.SavedFlags[key] = value
				end
			end
		end
	end
	
	self.SavedConfig = self.SavedConfig or {}
	self.SavedFlags = self.SavedFlags or {}
end

function Hive:SaveConfig(key, value)
	self.SavedConfig[key] = value
	
	local config = self.ScriptFolder:FindFirstChild("config")
	if config then
		local existing = config:FindFirstChild(key)
		if existing then
			existing:Destroy()
		end
		
		local stringValue = Instance.new("StringValue")
		stringValue.Name = key
		stringValue.Value = tostring(value)
		stringValue.Parent = config
	end
end

function Hive:LoadConfig(key)
	return self.SavedConfig and self.SavedConfig[key]
end

function Hive:SaveFlag(key, value)
	self.SavedFlags[key] = value
	
	local flags = self.ScriptFolder:FindFirstChild("flags")
	if flags then
		local existing = flags:FindFirstChild(key)
		if existing then
			existing:Destroy()
		end
		
		local stringValue = Instance.new("StringValue")
		stringValue.Name = key
		stringValue.Value = tostring(value)
		stringValue.Parent = flags
	end
end

function Hive:LoadFlag(key)
	return self.SavedFlags and self.SavedFlags[key]
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
		Draggable = false,
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
		Text = "v1.1.0",
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
		Size = UDim2.new(1, 0, 0, CONFIG.TabHeight),
		Position = UDim2.new(0, 0, 0, 35),
		Visible = false,
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
		ScrollBarImageColor3 = THEME.Accent,
		BorderSizePixel = 0,
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
		Position = UDim2.new(0, 0, 0, 35 + CONFIG.TabHeight),
		Size = UDim2.new(1, 0, 1, -(35 + CONFIG.TabHeight)),
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
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == self.ToggleKey then
			self:Toggle()
		end
		
		if self.KeySystemEnabled then
			for key, callback in pairs(self.Keybinds) do
				if input.KeyCode == key then
					callback()
				end
			end
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

function Hive:CreateSector(name, icon)
	local sectorName = name or "Sector"
	local iconValue = icon or ""
	
	if #self.Sectors == 0 then
		self.TabContainer.Visible = true
		self.ContentFrame.Visible = true
	end
	
	local tabBtn = CreateInstance("TextButton", {
		Name = "Tab_" .. sectorName,
		BackgroundColor3 = #self.Sectors == 0 and THEME.Accent or THEME.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 100, 0, 35),
		AutoButtonColor = false,
		Text = iconValue .. (iconValue ~= "" and " " or "") .. sectorName,
		TextColor3 = THEME.Text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
	})
	
	tabBtn.Parent = self.TabScroll
	task.wait()
	tabBtn.Size = UDim2.new(0, tabBtn.TextBounds.X + 32, 0, 35)
	
	local tabStroke = CreateInstance("UIStroke", {
		Name = "TabStroke",
		Color = THEME.Border,
		Thickness = 1,
	})
	tabStroke.Parent = tabBtn
	
	local tabCorner = CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 6),
	})
	tabCorner.Parent = tabBtn
	
	local tabPadding = CreateInstance("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	})
	tabPadding.Parent = tabBtn
	
	local sectorScrollFrame = CreateInstance("ScrollingFrame", {
		Name = "Sector_" .. sectorName,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 5, 0, 5),
		Size = UDim2.new(1, -10, 1, -10),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = THEME.Accent,
		BorderSizePixel = 0,
		Visible = #self.Sectors == 0,
	})
	
	local sectorListLayout = CreateInstance("UIListLayout", {
		Name = "ListLayout",
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	
	local sectorPadding = CreateInstance("UIPadding", {
		Name = "Padding",
		PaddingTop = UDim.new(0, 5),
	})
	
	sectorListLayout.Parent = sectorScrollFrame
	sectorPadding.Parent = sectorScrollFrame
	sectorScrollFrame.Parent = self.ContentFrame
	
	local sector = {
		Name = sectorName,
		TabButton = tabBtn,
		ScrollFrame = sectorScrollFrame,
		ListLayout = sectorListLayout,
		Parent = self,
		Components = {},
	}
	
	tabBtn.MouseButton1Click:Connect(function()
		for _, s in ipairs(self.Sectors) do
			s.ScrollFrame.Visible = false
			s.TabButton.BackgroundColor3 = THEME.Secondary
		end
		sectorScrollFrame.Visible = true
		tabBtn.BackgroundColor3 = THEME.Accent
		self.ActiveSector = sector
		self:UpdateCanvasSize()
	end)
	
	tabBtn.MouseEnter:Connect(function()
		if self.ActiveSector ~= sector then
			tabBtn.BackgroundColor3 = THEME.Border
		end
	end)
	
	tabBtn.MouseLeave:Connect(function()
		if self.ActiveSector ~= sector then
			tabBtn.BackgroundColor3 = THEME.Secondary
		end
	end)
	
	table.insert(self.Sectors, sector)
	
	self.ActiveSector = sector
	self:UpdateTabSize()
	
	return sector
end

function Hive:UpdateTabSize()
	local tabWidth = 0
	for _, s in ipairs(self.Sectors) do
		tabWidth = tabWidth + s.TabButton.TextBounds.X + 20
	end
	self.TabScroll.CanvasSize = UDim2.new(0, tabWidth, 0, 0)
end

function Hive:UpdateCanvasSize()
	local layoutOrder = self.ListLayout.AbsoluteContentSize
	self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, layoutOrder.Y + 10)
end

function Hive:CreateSection(name)
	local targetScrollFrame = self.ActiveSector and self.ActiveSector.ScrollFrame or self.ScrollFrame
	local targetComponents = self.ActiveSector and self.ActiveSector.Components or self.Components
	
	local sectionFrame = CreateInstance("Frame", {
		Name = "Section_" .. name,
		BackgroundColor3 = THEME.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		LayoutOrder = #targetComponents + 1,
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
	
	local contentFrame = CreateInstance("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 1, -30),
	})
	
	local listLayout = CreateInstance("UIListLayout", {
		Name = "ListLayout",
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	
	local padding = CreateInstance("UIPadding", {
		Name = "Padding",
		PaddingTop = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	})
	
	listLayout.Parent = contentFrame
	padding.Parent = contentFrame
	sectionLabel.Parent = sectionFrame
	highlight.Parent = sectionFrame
	contentFrame.Parent = sectionFrame
	sectionFrame.Parent = targetScrollFrame
	
	table.insert(targetComponents, sectionFrame)
	
	local section = {
		Frame = sectionFrame,
		Content = contentFrame,
		Name = name,
		Parent = self,
	}
	
	function section:CreateLabel(text)
		local label = CreateInstance("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = THEME.TextSecondary,
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			Size = UDim2.new(1, 0, 0, 20),
			LayoutOrder = #section.Components + 1,
		})
		label.Parent = contentFrame
		table.insert(self.Components, label)
		self:UpdateLayout()
		return label
	end
	
	function section:CreateButton(text, callback)
		local button = CreateInstance("TextButton", {
			Name = "Button",
			BackgroundColor3 = THEME.Accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			Text = text,
			TextColor3 = THEME.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			LayoutOrder = #section.Components + 1,
		})
		
		local corner = CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 6),
		})
		corner.Parent = button
		
		button.MouseButton1Click:Connect(function()
			callback()
		end)
		
		button.Parent = contentFrame
		table.insert(self.Components, button)
		self:UpdateLayout()
		return button
	end
	
	function section:CreateToggle(name, defaultState, callback)
		local toggleName = name or "Toggle"
		local savedState = self.Parent:LoadFlag(toggleName)
		local state = savedState ~= nil and savedState or defaultState
		
		local toggleFrame = CreateInstance("Frame", {
			Name = "Toggle",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 35),
			LayoutOrder = #section.Components + 1,
		})
		
		local toggleBg = CreateInstance("Frame", {
			Name = "ToggleBg",
			BackgroundColor3 = state and THEME.Accent or THEME.Border,
			BorderSizePixel = 0,
			Size = UDim2.new(0, CONFIG.ToggleWidth, 0, CONFIG.ToggleHeight),
			Position = UDim2.new(1, -CONFIG.ToggleOffset, 0.5, 0),
		})
		
		local toggleKnob = CreateInstance("Frame", {
			Name = "Knob",
			BackgroundColor3 = THEME.Text,
			BorderSizePixel = 0,
			Size = UDim2.new(0, CONFIG.KnobSize, 0, CONFIG.KnobSize),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = state and UDim2.new(1, -CONFIG.KnobSize/2 - 2, 0.5, 0) or UDim2.new(0, CONFIG.KnobSize/2 + 2, 0.5, 0),
		})
		
		local label = CreateInstance("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -(CONFIG.ToggleOffset + CONFIG.ToggleWidth + 10), 1, 0),
			Text = toggleName,
			TextColor3 = THEME.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.Gotham,
			TextSize = 14,
		})
		
		CreateInstance("UICorner", { CornerRadius = UDim.new(0, CONFIG.ToggleHeight/2) }).Parent = toggleBg
		CreateInstance("UICorner", { CornerRadius = UDim.new(0, CONFIG.KnobSize/2) }).Parent = toggleKnob
		
		local function updateToggle(newState)
			state = newState
			toggleBg.BackgroundColor3 = state and THEME.Accent or THEME.Border
			toggleKnob.Position = state and UDim2.new(1, -CONFIG.KnobSize/2 - 2, 0.5, 0) or UDim2.new(0, CONFIG.KnobSize/2 + 2, 0.5, 0)
			self.Parent:SaveFlag(toggleName, state)
			callback(state)
		end
		
		toggleBg.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				updateToggle(not state)
			end
		end)
		
		toggleBg.Parent = toggleFrame
		toggleKnob.Parent = toggleBg
		label.Parent = toggleFrame
		
		toggleFrame.Parent = contentFrame
		table.insert(self.Components, toggleFrame)
		self:UpdateLayout()
		
		return {
			Frame = toggleFrame,
			Set = updateToggle,
			Get = function() return state end,
		}
	end
	
	function section:CreateSlider(name, min, max, default, callback)
		local sliderName = name or "Slider"
		local savedValue = self.Parent:LoadFlag(sliderName)
		local actualValue = savedValue or default
		
		local sliderFrame = CreateInstance("Frame", {
			Name = "Slider",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 50),
			LayoutOrder = #section.Components + 1,
		})
		
		local label = CreateInstance("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			Text = sliderName,
			TextColor3 = THEME.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.Gotham,
			TextSize = 14,
		})
		
		local valueLabel = CreateInstance("TextLabel", {
			Name = "ValueLabel",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 50, 0, 20),
			Text = tostring(actualValue),
			TextColor3 = THEME.AccentLight,
			TextXAlignment = Enum.TextXAlignment.Right,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
		})
		
		local sliderBg = CreateInstance("Frame", {
			Name = "SliderBg",
			BackgroundColor3 = THEME.Border,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 8),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 10),
		})
		
		local sliderFill = CreateInstance("Frame", {
			Name = "SliderFill",
			BackgroundColor3 = THEME.Accent,
			BorderSizePixel = 0,
			Size = UDim2.new(0.5, 0, 1, 0),
		})
		
		local sliderKnob = CreateInstance("Frame", {
			Name = "Knob",
			BackgroundColor3 = THEME.Text,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 16, 0, 16),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
		})
		
		local corner = CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 4),
		})
		corner.Parent = sliderBg
		
		local fillCorner = CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 4),
		})
		fillCorner.Parent = sliderFill
		
		local knobCorner = CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 8),
		})
		knobCorner.Parent = sliderKnob
		
		sliderFill.Parent = sliderBg
		sliderKnob.Parent = sliderBg
		label.Parent = sliderFrame
		valueLabel.Parent = sliderFrame
		sliderBg.Parent = sliderFrame
		
		local value = actualValue
		local dragging = false
		
		local function updateSlider(percent)
			percent = math.clamp(percent, 0, 1)
			local newValue = math.floor(min + (max - min) * percent)
			value = newValue
			
			sliderFill.Size = UDim2.new(percent, 0, 1, 0)
			sliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
			valueLabel.Text = tostring(newValue)
			
			self.Parent:SaveFlag(sliderName, newValue)
			callback(newValue)
		end
		
		local function getPercentFromX(x)
			local absPos = sliderBg.AbsolutePosition
			local absSize = sliderBg.AbsoluteSize
			local relativeX = x - absPos.X
			return math.clamp(relativeX / absSize.X, 0, 1)
		end
		
		sliderBg.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				updateSlider(getPercentFromX(input.Position.X))
			end
		end)
		
		sliderBg.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				updateSlider(getPercentFromX(input.Position.X))
			end
		end)
		
		updateSlider((actualValue - min) / (max - min))
		
		sliderFrame.Parent = contentFrame
		table.insert(self.Components, sliderFrame)
		self:UpdateLayout()
		
		return {
			Frame = sliderFrame,
			Set = function(val) updateSlider((val - min) / (max - min)) end,
			Get = function() return value end,
		}
	end
	
	function section:CreateInput(placeholder, callback)
		local inputFrame = CreateInstance("Frame", {
			Name = "Input",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 40),
			LayoutOrder = #section.Components + 1,
		})
		
		local textBox = CreateInstance("TextBox", {
			Name = "TextBox",
			BackgroundColor3 = THEME.Border,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			Text = "",
			PlaceholderText = placeholder or "Enter text...",
			PlaceholderColor3 = THEME.TextSecondary,
			TextColor3 = THEME.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.Gotham,
			TextSize = 14,
		})
		
		local corner = CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 6),
		})
		corner.Parent = textBox
		
		local padding = CreateInstance("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
		})
		padding.Parent = textBox
		
		textBox.Parent = inputFrame
		
		textBox.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				callback(textBox.Text)
			end
		end)
		
		inputFrame.Parent = contentFrame
		table.insert(self.Components, inputFrame)
		self:UpdateLayout()
		
		return {
			Frame = inputFrame,
			GetText = function() return textBox.Text end,
			SetText = function(t) textBox.Text = t end,
		}
	end
	
	function section:UpdateLayout()
		local contentSize = listLayout.AbsoluteContentSize
		contentFrame.Size = UDim2.new(1, 0, 0, contentSize.Y)
		sectionFrame.Size = UDim2.new(1, 0, 0, 30 + contentSize.Y)
		pcall(function()
			Hive.UpdateCanvasSize(self.Parent)
		end)
	end
	
	section.Components = {}
	
	table.insert(self.Components, sectionFrame)
	self:UpdateCanvasSize()
	
	return section
end

function Hive:EnableKeySystem()
	self.KeySystemEnabled = true
end

function Hive:DisableKeySystem()
	self.KeySystemEnabled = false
end

function Hive:BindKey(key, callback)
	self.Keybinds[key] = callback
end

function Hive:UnbindKey(key)
	self.Keybinds[key] = nil
end

function Hive:SetToggleKey(key)
	self.ToggleKey = key
end

function Hive:Destroy()
	if self.GUI then
		self.GUI:Destroy()
	end
end

return Hive
