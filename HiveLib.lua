--[[
    HiveLib - A legitimate Roblox utility library
    Version 1.0.0
]]

local HiveLib = {}
HiveLib.__index = HiveLib

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

function HiveLib.new()
    local self = setmetatable({}, HiveLib)
    self.Gui = nil
    self.Theme = {
        Background = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(60, 60, 60),
        Success = Color3.fromRGB(0, 200, 100),
        Warning = Color3.fromRGB(255, 180, 0),
        Error = Color3.fromRGB(255, 50, 50)
    }
    self.Notifications = {}
    self.Components = {}
    self.Keybinds = {}
    self.KeybindConnections = {}
    self.Toggled = true
    return self
end

function HiveLib:CreateGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HiveLib"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 9999
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = self.Theme.Background
    mainFrame.BorderColor3 = self.Theme.Border
    mainFrame.BorderSizePixel = 1
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = self.Theme.Secondary
    titleBar.BorderColor3 = self.Theme.Border
    titleBar.BorderSizePixel = 1
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "HiveLib"
    titleLabel.TextColor3 = self.Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = self.Theme.Error
    closeButton.Text = "X"
    closeButton.TextColor3 = self.Theme.Text
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = titleBar
    
    local draggable = Instance.new("Frame")
    draggable.Name = "Draggable"
    draggable.Size = UDim2.new(1, -60, 1, 0)
    draggable.Position = UDim2.new(0, 0, 0, 0)
    draggable.BackgroundTransparency = 1
    draggable.Parent = titleBar
    
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -50)
    contentFrame.Position = UDim2.new(0, 10, 0, 40)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = self.Theme.Accent
    contentFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = contentFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingLeft = UDim.new(0, 5)
    padding.Parent = contentFrame
    
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    self.Gui = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        TitleBar = titleBar,
        Content = contentFrame,
        Draggable = draggable
    }
    
    self:SetupDragging(mainFrame, draggable)
    self:SetupCloseButton(closeButton)
    
    return self.Gui
end

function HiveLib:SetupDraggable(frame, dragArea)
    local isDragging = false
    local dragStart = nil
    local startPos = nil
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    dragArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    inputService = game:GetService("UserInputService")
    inputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function HiveLib:SetupCloseButton(button)
    button.MouseButton1Click:Connect(function()
        if self.Gui and self.Gui.ScreenGui then
            self.Gui.ScreenGui:Destroy()
            self.Gui = nil
        end
    end)
end

function HiveLib:AddButton(name, callback)
    if not self.Gui then return end
    
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = self.Theme.Secondary
    button.BorderColor3 = self.Theme.Border
    button.BorderSizePixel = 1
    button.Text = name
    button.TextColor3 = self.Theme.Text
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = self.Gui.Content
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    local hover = Instance.new("UICorner")
    hover.CornerRadius = UDim.new(0, 6)
    hover.Parent = button
    
    return button
end

function HiveLib:AddToggle(name, default, callback)
    if not self.Gui then return end
    
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = self.Gui.Content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = self.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = container
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 24)
    toggle.Position = UDim2.new(1, -50, 0.5, -12)
    toggle.BackgroundColor3 = default and self.Theme.Success or self.Theme.Secondary
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = self.Theme.Text
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 12
    toggle.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggle
    
    local enabled = default or false
    
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.BackgroundColor3 = enabled and self.Theme.Success or self.Theme.Secondary
        toggle.Text = enabled and "ON" or "OFF"
        if callback then callback(enabled) end
    end)
    
    return {
        Enabled = function() return enabled end,
        Set = function(self, state)
            enabled = state
            toggle.BackgroundColor3 = enabled and self.Theme.Success or self.Theme.Secondary
            toggle.Text = enabled and "ON" or "OFF"
            if callback then callback(enabled) end
        end
    }
end

function HiveLib:AddSlider(name, min, max, default, callback)
    if not self.Gui then return end
    
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = self.Gui.Content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(default)
    label.TextColor3 = self.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 20)
    sliderBg.Position = UDim2.new(0, 0, 0, 25)
    sliderBg.BackgroundColor3 = self.Theme.Secondary
    sliderBg.BorderColor3 = self.Theme.Border
    sliderBg.BorderSizePixel = 1
    sliderBg.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    local fillPercent = (default - min) / (max - min)
    sliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    sliderFill.BackgroundColor3 = self.Theme.Accent
    sliderFill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = sliderFill
    
    local isDragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            self:UpdateSlider(input.Position.X)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    inputService = game:GetService("UserInputService")
    inputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            self:UpdateSlider(input.Position.X)
        end
    end)
    
    function self:UpdateSlider(xPos)
        local sliderPos = sliderBg.AbsolutePosition.X
        local sliderWidth = sliderBg.AbsoluteSize.X
        local percent = math.clamp((xPos - sliderPos) / sliderWidth, 0, 1)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        
        local value = math.floor(min + (max - min) * percent)
        label.Text = name .. ": " .. tostring(value)
        
        if callback then callback(value) end
    end
    
    return {
        Value = function() return tonumber(label.Text:match("%d+$")) or default end
    }
end

function HiveLib:AddTextBox(name, placeholder, callback)
    if not self.Gui then return end
    
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = self.Gui.Content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = self.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = container
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.65, 0, 1, 0)
    textBox.Position = UDim2.new(0.35, 0, 0, 0)
    textBox.BackgroundColor3 = self.Theme.Secondary
    textBox.BorderColor3 = self.Theme.Border
    textBox.BorderSizePixel = 1
    textBox.Text = ""
    textBox.PlaceholderText = placeholder or ""
    textBox.PlaceholderColor3 = self.Theme.TextSecondary
    textBox.TextColor3 = self.Theme.Text
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.ClearTextOnFocus = false
    textBox.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = textBox
    
    textBox.FocusLost:Connect(function()
        if callback then callback(textBox.Text) end
    end)
    
    return textBox
end

function HiveLib:AddLabel(text)
    if not self.Gui then return end
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = self.Gui.Content
    
    return label
end

function HiveLib:AddSeparator()
    if not self.Gui then return end
    
    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, 0, 0, 1)
    separator.BackgroundColor3 = self.Theme.Border
    separator.BorderSizePixel = 0
    separator.Parent = self.Gui.Content
    
    return separator
end

function HiveLib:AddSection(title)
    if not self.Gui then return end
    
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 30)
    section.BackgroundColor3 = self.Theme.Secondary
    section.BorderColor3 = self.Theme.Border
    section.BorderSizePixel = 1
    section.Parent = self.Gui.Content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = section
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = title:upper()
    label.TextColor3 = self.Theme.Accent
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = section
    
    return section
end

function HiveLib:Notification(title, text, duration)
    duration = duration or 5
    
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 300, 0, 60)
    notifFrame.Position = UDim2.new(1, -310, 1, -70 - (#self.Notifications * 70))
    notifFrame.BackgroundColor3 = self.Theme.Secondary
    notifFrame.BorderColor3 = self.Theme.Border
    notifFrame.BorderSizePixel = 1
    notifFrame.Parent = self.Gui.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notifFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.Theme.Accent
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notifFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 0, 25)
    textLabel.Position = UDim2.new(0, 10, 0, 25)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = self.Theme.Text
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 12
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.Parent = notifFrame
    
    table.insert(self.Notifications, notifFrame)
    
    task.spawn(function()
        task.wait(duration)
        local tween = TweenService:Create(notifFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Wait()
        notifFrame:Destroy()
        table.remove(self.Notifications, table.find(self.Notifications, notifFrame))
    end)
end

function HiveLib:AddKeybind(name, key, callback, toggleGui)
    local inputService = game:GetService("UserInputService")
    
    local keybind = {
        Name = name,
        Key = key,
        Callback = callback,
        ToggleGui = toggleGui or false
    }
    
    table.insert(self.Keybinds, keybind)
    
    local connection = inputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local keyCode = type(key) == "string" and Enum.KeyCode[key] or key
        if input.KeyCode == keyCode then
            if toggleGui then
                self:Toggle()
            end
            if callback then callback() end
        end
    end)
    
    table.insert(self.KeybindConnections, connection)
    
    return keybind
end

function HiveLib:RemoveKeybind(name)
    for i, kb in ipairs(self.Keybinds) do
        if kb.Name == name then
            table.remove(self.Keybinds, i)
            if self.KeybindConnections[i] then
                self.KeybindConnections[i]:Disconnect()
                table.remove(self.KeybindConnections, i)
            end
            break
        end
    end
end

function HiveLib:SetToggleKey(key)
    self:ToggleKey = key
    self:AddKeybind("Toggle GUI", key, nil, true)
end

function HiveLib:Toggle()
    if not self.Gui or not self.Gui.ScreenGui then return end
    
    self.Toggled = not self.Toggled
    self.Gui.ScreenGui.Enabled = self.Toggled
end

function HiveLib:Show()
    if self.Gui and self.Gui.ScreenGui then
        self.Gui.ScreenGui.Enabled = true
    end
end

function HiveLib:Hide()
    if self.Gui and self.Gui.ScreenGui then
        self.Gui.ScreenGui.Enabled = false
    end
end

function HiveLib:Destroy()
    for _, connection in ipairs(self.KeybindConnections) do
        connection:Disconnect()
    end
    self.KeybindConnections = {}
    self.Keybinds = {}
    
    if self.Gui and self.Gui.ScreenGui then
        self.Gui.ScreenGui:Destroy()
        self.Gui = nil
    end
end

return HiveLib
