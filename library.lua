local Hive = {}
Hive.__index = Hive

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Storage = {}
Storage.FolderName = "HiveConfigs/"
Storage.CanWriteFile = writefile ~= nil and readfile ~= nil and isfolder ~= nil and makefolder ~= nil and isfile ~= nil

function Storage:Save(name, data)
	if not self.CanWriteFile then return end
	if not isfolder(self.FolderName) then makefolder(self.FolderName) end
	writefile(self.FolderName .. name .. ".json", HttpService:JSONEncode(data))
end

function Storage:Load(name)
	if not self.CanWriteFile then return nil end
	local path = self.FolderName .. name .. ".json"
	if isfile(path) then
		local success, result = pcall(function()
			return HttpService:JSONDecode(readfile(path))
		end)
		return success and result or nil
	end
	return nil
end

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
	self.KeySystemEnabled = false
	self.Keybinds = {}
	self.Components = {}
	self.Sectors = {}
	self.ActiveSector = nil
	self.ToggleKey = Enum.KeyCode.RightShift
	self.ScriptName = scriptName or "Default"
	self.ScriptFolder = GetScriptFolder(self.ScriptName)
	self.SavedConfig = {}
	self.SavedFlags = {}
	
	self:LoadSavedData()
	self:CreateGUI()
	
	return self
end

function Hive:LoadSavedData()
	if Storage.CanWriteFile then
		local configData = Storage:Load(self.ScriptName .. "_config")
		if configData then
			self.SavedConfig = configData
		end
		local flagsData = Storage:Load(self.ScriptName .. "_flags")
		if flagsData then
			self.SavedFlags = flagsData
		end
	end
end

function Hive:SaveConfig(key, value)
	self.SavedConfig[key] = value
	if Storage.CanWriteFile then
		Storage:Save(self.ScriptName .. "_config", self.SavedConfig)
	end
end

function Hive:LoadConfig(key)
	return self.SavedConfig[key]
end

function Hive:SaveFlag(key, value)
	self.SavedFlags[key] = value
	if Storage.CanWriteFile then
		Storage:Save(self.ScriptName .. "_flags", self.SavedFlags)
	end
end

function Hive:LoadFlag(key)
	return self.SavedFlags[key]
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
		BorderSizePixel = 0,
		ClipsDescendants = false,
		CanvasSize = UDim2.new(0, 0, 0, 0),
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
			local callback = self.Keybinds[input.KeyCode]
			if callback then
				callback()
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

function Hive:SwitchSector(sectorName)
	for _, s in ipairs(self.Sectors) do
		local isActive = s.Name == sectorName
		s.ScrollFrame.Visible = isActive
		s.TabButton.BackgroundColor3 = isActive and THEME.Accent or THEME.Secondary
		if isActive then
			self.ActiveSector = s
		end
	end
	self:UpdateCanvasSize()
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
		Sections = {},
	}
	
	function sector:CreateSection(name)
		local contentFrame = sector.ScrollFrame
		
		local sectionFrame = CreateInstance("Frame", {
			Name = "Section_" .. name,
			BackgroundColor3 = THEME.Secondary,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = #sector.Components + 1,
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
		
		local sectionContentFrame = CreateInstance("Frame", {
			Name = "Content",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 30),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		
		local listLayout = CreateInstance("UIListLayout", {
			Name = "ListLayout",
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		
		local padding = CreateInstance("UIPadding", {
			Name = "Padding",
			PaddingTop = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		})
		
		listLayout.Parent = sectionContentFrame
		padding.Parent = sectionContentFrame
		sectionLabel.Parent = sectionFrame
		highlight.Parent = sectionFrame
		sectionContentFrame.Parent = sectionFrame
		sectionFrame.Parent = contentFrame
		
		table.insert(sector.Components, sectionFrame)
		
		local section = {
			Frame = sectionFrame,
			Content = sectionContentFrame,
			Name = name,
			Parent = sector,
			Components = {},
		}
		
		function section:CreateLabel(text)
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
			label.Parent = sectionContentFrame
			table.insert(self.Components, label)
			self:UpdateLayout()
			return label
		end
		
		function section:CreateButton(text, callback)
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
				callback()
			end)
			
			button.Parent = sectionContentFrame
			table.insert(self.Components, button)
			self:UpdateLayout()
			return button
		end
		
		function section:CreateToggle(toggleName, defaultState, callback)
			toggleName = toggleName or "Toggle"
			local savedState = self.Parent.Parent.Parent:LoadFlag(toggleName)
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
				self.Parent.Parent.Parent:SaveFlag(toggleName, state)
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
			toggleFrame.Parent = sectionContentFrame
			table.insert(self.Components, toggleFrame)
			self:UpdateLayout()
			
			return {
				Frame = toggleFrame,
				Set = updateToggle,
				Get = function() return state end,
			}
		end
		
		function section:CreateSlider(sliderName, min, max, default, callback)
			sliderName = sliderName or "Slider"
			local savedValue = self.Parent.Parent.Parent:LoadFlag(sliderName)
			local value = savedValue or default
			
			local sliderFrame = CreateInstance("Frame", {
				Name = "Slider",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 50),
				LayoutOrder = #section.Components + 1,
			})
			
			local sliderLabel = CreateInstance("TextLabel", {
				Name = "Label",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, -40, 0, 20),
				Text = sliderName .. ": " .. value,
				TextColor3 = THEME.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				TextSize = 14,
			})
			
			local sliderBg = CreateInstance("Frame", {
				Name = "SliderBg",
				BackgroundColor3 = THEME.Border,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -10, 0, 6),
				Position = UDim2.new(0, 5, 0, 30),
			})
			
			local sliderFill = CreateInstance("Frame", {
				Name = "SliderFill",
				BackgroundColor3 = THEME.Accent,
				BorderSizePixel = 0,
				Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
			})
			
			local sliderKnob = CreateInstance("Frame", {
				Name = "Knob",
				BackgroundColor3 = THEME.Text,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 14, 0, 14),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
			})
			
			CreateInstance("UICorner", { CornerRadius = UDim.new(0, 3) }).Parent = sliderBg
			CreateInstance("UICorner", { CornerRadius = UDim.new(0, 7) }).Parent = sliderFill
			CreateInstance("UICorner", { CornerRadius = UDim.new(0, 7) }).Parent = sliderKnob
			
			sliderFill.Parent = sliderBg
			sliderKnob.Parent = sliderBg
			sliderLabel.Parent = sliderFrame
			sliderBg.Parent = sliderFrame
			sliderFrame.Parent = sectionContentFrame
			
			local dragging = false
			
			local function updateSlider(percent)
				percent = math.clamp(percent, 0, 1)
				local newValue = math.floor(min + (max - min) * percent)
				value = newValue
				sliderLabel.Text = sliderName .. ": " .. newValue
				sliderFill.Size = UDim2.new(percent, 0, 1, 0)
				sliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
				self.Parent.Parent.Parent:SaveFlag(sliderName, newValue)
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
			
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					updateSlider(getPercentFromX(input.Position.X))
				end
			end)
			
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
			
			inputFrame.Parent = sectionContentFrame
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
			self.Parent.Parent.Parent:UpdateCanvasSize()
		end
		
		table.insert(self.Components, sectionFrame)
		self.Parent.Parent.Parent:UpdateCanvasSize()
		
		return section
	end
	
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

function Hive:CreateSection(name)
	if not self.ActiveSector then return end
	return self.ActiveSector:CreateSection(name)
end

function Hive:UpdateTabSize()
	local tabWidth = 0
	for _, s in ipairs(self.Sectors) do
		tabWidth = tabWidth + s.TabButton.AbsoluteSize.X + 6
	end
	self.TabScroll.CanvasSize = UDim2.new(0, tabWidth, 0, 0)
end

function Hive:UpdateCanvasSize()
	if self.ListLayout and self.ListLayout.AbsoluteContentSize then
		local layoutOrder = self.ListLayout.AbsoluteContentSize
		self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, layoutOrder.Y + 10)
	end
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