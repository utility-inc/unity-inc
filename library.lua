local Hive = {}
Hive.__index = Hive

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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

local DataFolder = nil
local ScriptFolder = nil

local function GetDataFolder()
	if not DataFolder then
		DataFolder = PlayerGui:FindFirstChild("HiveData")
		if not DataFolder then
			DataFolder = Instance.new("Folder")
			DataFolder.Name = "HiveData"
			DataFolder.Parent = PlayerGui
		end
	end
	return DataFolder
end

local function GetScriptFolder(scriptName)
	if not ScriptFolder then
		local df = GetDataFolder()
		ScriptFolder = df:FindFirstChild(scriptName)
		if not ScriptFolder then
			ScriptFolder = Instance.new("Folder")
			ScriptFolder.Name = scriptName
			ScriptFolder.Parent = df
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
	self.ToggleKey = Enum.KeyCode.RightShift
	self.ScriptName = scriptName or "Default"
	self.DataFolder = GetScriptFolder(self.ScriptName)
	
	self:LoadData()
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
		Text = "v1.0.0",
		TextColor3 = THEME.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		ZIndex = 3,
	})
	
	local contentFrame = CreateInstance("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 35),
		Size = UDim2.new(1, 0, 1, -35),
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
	contentFrame.Parent = mainFrame
	scrollFrame.Parent = contentFrame
	listLayout.Parent = scrollFrame
	padding.Parent = scrollFrame
	
	mainFrame.Parent = screenGui
	
	ExistingGUI = screenGui
	self.GUI = screenGui
	self.MainFrame = mainFrame
	self.TitleBar = titleBar
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
			local mousePos = UserInputService:GetMouseLocation()
			local guiPos = self.MainFrame.AbsolutePosition
			local offset = mousePos - guiPos
			
			if input.Position.Y - guiPos.Y < 35 then
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

function Hive:UpdateCanvasSize()
	local layoutOrder = self.ListLayout.AbsoluteContentSize
	self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, layoutOrder.Y + 10)
end

function Hive:CreateSection(name)
	local sectionFrame = CreateInstance("Frame", {
		Name = "Section_" .. name,
		BackgroundColor3 = THEME.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		LayoutOrder = #self.Components + 1,
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
	sectionFrame.Parent = self.ScrollFrame
	
	local section = {
		Frame = sectionFrame,
		Content = contentFrame,
		Name = name,
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
	
	function section:CreateToggle(defaultState, callback)
		local toggleFrame = CreateInstance("Frame", {
			Name = "Toggle",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 35),
			LayoutOrder = #section.Components + 1,
		})
		
		local toggleBg = CreateInstance("Frame", {
			Name = "ToggleBg",
			BackgroundColor3 = defaultState and THEME.Accent or THEME.Border,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 40, 0, 20),
			Position = UDim2.new(1, -50, 0.5, 0),
		})
		
		local toggleKnob = CreateInstance("Frame", {
			Name = "Knob",
			BackgroundColor3 = THEME.Text,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 16, 0, 16),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = defaultState and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		})
		
		local label = CreateInstance("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -60, 1, 0),
			Text = "Toggle",
			TextColor3 = THEME.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.Gotham,
			TextSize = 14,
		})
		
		local corner = CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 10),
		})
		corner.Parent = toggleBg
		
		local knobCorner = CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 8),
		})
		knobCorner.Parent = toggleKnob
		
		toggleBg.Parent = toggleFrame
		toggleKnob.Parent = toggleBg
		label.Parent = toggleFrame
		
		local state = defaultState
		local enabled = false
		
		local function updateToggle(newState)
			state = newState
			toggleBg.BackgroundColor3 = state and THEME.Accent or THEME.Border
			
			local targetPos = state and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
			toggleKnob.Position = targetPos
			
			callback(state)
		end
		
		toggleFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				enabled = true
			end
		end)
		
		toggleFrame.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and enabled then
				enabled = false
				updateToggle(not state)
			end
		end)
		
		toggleFrame.Parent = contentFrame
		table.insert(self.Components, toggleFrame)
		self:UpdateLayout()
		
		return {
			Frame = toggleFrame,
			Set = updateToggle,
			Get = function() return state end,
		}
	end
	
	function section:CreateSlider(min, max, default, callback)
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
			Text = "Slider",
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
			Text = tostring(default),
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
			Size = UDim2.new(0, 0, 1, 0),
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
		
		local value = default or min
		local dragging = false
		
		local function updateSlider(percent)
			percent = math.clamp(percent, 0, 1)
			local newValue = math.floor(min + (max - min) * percent)
			value = newValue
			
			sliderFill.Size = UDim2.new(percent, 0, 1, 0)
			sliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
			valueLabel.Text = tostring(newValue)
			
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
		
		updateSlider((default - min) / (max - min))
		
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
			Size = UDim2.new(1, 0, 0, 34),
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
			Hive.UpdateCanvasSize(self)
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

function Hive:SetAttribute(name, value)
	if OriginalAttributes[name] == nil then
		OriginalAttributes[name] = LocalPlayer:GetAttribute(name)
	end
	LocalPlayer:SetAttribute(name, value)
end

function Hive:GetAttribute(name)
	return LocalPlayer:GetAttribute(name)
end

function Hive:Destroy()
	if self.GUI then
		self.GUI:Destroy()
	end
end

function Hive:LoadData()
	if self.DataFolder then
		for _, child in ipairs(self.DataFolder:GetChildren()) do
			if child:IsA("StringValue") then
				local value = child.Value
				if value == "true" then
					self.DataStore = self.DataStore or {}
					self.DataStore[child.Name] = true
				elseif value == "false" then
					self.DataStore = self.DataStore or {}
					self.DataStore[child.Name] = false
				elseif tonumber(value) then
					self.DataStore = self.DataStore or {}
					self.DataStore[child.Name] = tonumber(value)
				else
					self.DataStore = self.DataStore or {}
					self.DataStore[child.Name] = value
				end
			end
		end
	end
	self.DataStore = self.DataStore or {}
end

function Hive:Save(key, value)
	self.DataStore = self.DataStore or {}
	self.DataStore[key] = value
	
	if self.DataFolder then
		local existing = self.DataFolder:FindFirstChild(key)
		if existing then
			existing:Destroy()
		end
		
		local stringValue = Instance.new("StringValue")
		stringValue.Name = key
		stringValue.Value = tostring(value)
		stringValue.Parent = self.DataFolder
	end
end

function Hive:Load(key)
	return self.DataStore and self.DataStore[key]
end

function Hive:CreateToggleWithKeybind(defaultState, keybind, callback)
	local key = tostring(keybind):gsub("Enum.KeyCode.", "")
	local savedKey = self:Load("ToggleKey_" .. key)
	
	local toggleObj = self:CreateToggle(defaultState, function(state)
		self:Save("ToggleState_" .. key, state)
		callback(state)
	end)
	
	if keybind then
		self:BindKey(keybind, function()
			local newState = not toggleObj:Get()
			toggleObj:Set(newState)
		end)
		
		local savedKeybind = self:Load("ToggleKeybind_" .. key)
		if savedKeybind then
			pcall(function()
				local keyEnum = Enum.KeyCode[savedKeybind]
				if keyEnum then
					self:BindKey(keyEnum, function()
						local newState = not toggleObj:Get()
						toggleObj:Set(newState)
					end)
				end
			end)
		end
		
		self:Save("ToggleKeybind_" .. key, key)
	end
	
	return toggleObj
end

return Hive
