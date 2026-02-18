local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("bedwars")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local UserInputService = game:GetService("UserInputService")

local GUIKeybind = Enum.KeyCode.RightShift

local function toggleGUI()
    GUI:Toggle()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local savedKeybind = GUI:Load("GUI Keybind_Keybind")
    if savedKeybind then
        GUIKeybind = Enum.KeyCode[savedKeybind]
    end
    
    if input.KeyCode == GUIKeybind then
        toggleGUI()
    end
end)



local bedwars = require(game:GetService("ReplicatedStorage").TS.remotes).default

local function getSpeed()
	local multi, increase, modifiers = 0, true, bedwars.SprintController:getMovementStatusModifier():getModifiers()

	for v in modifiers do
		local val = v.constantSpeedMultiplier and v.constantSpeedMultiplier or 0
		if val and val > math.max(multi, 1) then
			increase = false
			multi = val - (0.06 * math.round(val))
		end
	end

	for v in modifiers do
		multi = multi + math.max((v.moveSpeedMultiplier or 0) - 1, 0)
	end

	if multi > 0 and increase then
		multi = multi + 0.16 + (0.02 * math.round(multi))
	end

	return 20 * (multi + 1)
end



local Themes = {
    Default = {
        Background = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 50),
        Accent = Color3.fromRGB(0, 120, 255),
        AccentLight = Color3.fromRGB(60, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(60, 60, 80),
    },
    Green = {
        Background = Color3.fromRGB(20, 30, 25),
        Secondary = Color3.fromRGB(30, 50, 35),
        Accent = Color3.fromRGB(0, 255, 127),
        AccentLight = Color3.fromRGB(80, 255, 160),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 210, 180),
        Border = Color3.fromRGB(50, 80, 60),
    },
    Red = {
        Background = Color3.fromRGB(45, 25, 25),
        Secondary = Color3.fromRGB(65, 35, 35),
        Accent = Color3.fromRGB(255, 60, 60),
        AccentLight = Color3.fromRGB(255, 120, 120),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(220, 190, 190),
        Border = Color3.fromRGB(100, 60, 60),
    },
    Orange = {
        Background = Color3.fromRGB(45, 35, 25),
        Secondary = Color3.fromRGB(65, 50, 35),
        Accent = Color3.fromRGB(255, 150, 20),
        AccentLight = Color3.fromRGB(255, 190, 100),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(225, 210, 190),
        Border = Color3.fromRGB(100, 75, 50),
    },
}

local function applyTheme(themeName)
    local theme = Themes[themeName]
    if not theme then return end
    
    GUI.MainFrame.BackgroundColor3 = theme.Background
    GUI.TitleBar.BackgroundColor3 = theme.Secondary
    GUI.TabContainer.BackgroundColor3 = theme.Secondary
end
local savedTheme = GUI:Load("Theme")
if savedTheme then
    applyTheme(savedTheme)
end

-- // MAIN TAB
GUI:Tab("Main", function()
    GUI:Section("Welcome", function()
        GUI:Label("Welcome to the bedwars script")
        GUI:Label("notice - some features may not work")
    end)
end)

GUI:Tab("Combat", function()
    local SprintConnection = nil
    local SprintOld = nil
    
    GUI:Section("Movement", function()
        GUI:CreateToggle("Sprint", {
            default = false,
            save = true,
        }, function(callback)
            if callback then
                if not bedwars.SprintController then
                    return
                end
                
                if UserInputService.TouchEnabled then 
                    pcall(function() 
                        LocalPlayer.PlayerGui.MobileUI['4'].Visible = false 
                    end) 
                end
                
                local success, err = pcall(function()
                    SprintOld = bedwars.SprintController.stopSprinting
                    bedwars.SprintController.stopSprinting = function(...)
                        local call = SprintOld(...)
                        bedwars.SprintController:startSprinting()
                        return call
                    end
                    SprintConnection = LocalPlayer.CharacterAdded:Connect(function() 
                        task.delay(0.1, function() 
                            bedwars.SprintController:stopSprinting() 
                        end) 
                    end)
                    bedwars.SprintController:stopSprinting()
                end)
                
                if not success then
                    return
                end
            else
                if UserInputService.TouchEnabled then 
                    pcall(function() 
                        LocalPlayer.PlayerGui.MobileUI['4'].Visible = true 
                    end) 
                end
                
                pcall(function()
                    if SprintOld and bedwars.SprintController then
                        bedwars.SprintController.stopSprinting = SprintOld
                    end
                    if SprintConnection then
                        SprintConnection:Disconnect()
                        SprintConnection = nil
                    end
                    if bedwars.SprintController then
                        bedwars.SprintController:stopSprinting()
                    end
                end)
            end
        end)
    end)
    
    local VelocityOld = nil
    local VelocityHorizontal = 0
    local VelocityVertical = 0
    local VelocityChance = 100
    local VelocityRand = Random.new()
    
    GUI:Section("Velocity", function()
        GUI:CreateToggle("Velocity", {
            default = false,
            save = true,
        }, function(callback)
            if callback then
                if not bedwars.KnockbackUtil then
                    return
                end
                
                local success, err = pcall(function()
                    VelocityOld = bedwars.KnockbackUtil.applyKnockback
                    bedwars.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
                        if VelocityRand:NextNumber(0, 100) > VelocityChance then return end
                        
                        knockback = knockback or {}
                        if VelocityHorizontal == 0 and VelocityVertical == 0 then return end
                        knockback.horizontal = (knockback.horizontal or 1) * (VelocityHorizontal / 100)
                        knockback.vertical = (knockback.vertical or 1) * (VelocityVertical / 100)
                        
                        return VelocityOld(root, mass, dir, knockback, ...)
                    end
                end)
                
                if not success then
                    return
                end
            else
                pcall(function()
                    if VelocityOld and bedwars.KnockbackUtil then
                        bedwars.KnockbackUtil.applyKnockback = VelocityOld
                    end
                end)
            end
        end)
        
        GUI:Slider("Horizontal", {
            min = 0,
            max = 100,
            default = 0,
            save = true,
        }, function(value)
            VelocityHorizontal = value
        end)
        
        GUI:Slider("Vertical", {
            min = 0,
            max = 100,
            default = 0,
            save = true,
        }, function(value)
            VelocityVertical = value
        end)
        
        GUI:Slider("Chance", {
            min = 0,
            max = 100,
            default = 100,
            save = true,
        }, function(value)
            VelocityChance = value
        end)
    end)
end)

GUI:Tab("Blatant", function()
    local AntiFallPart = nil
    
    GUI:Section("Movement", function()
        GUI:CreateToggle("AntiFall", {
            default = false,
            save = true,
        }, function(callback)
            if callback then
                if not bedwars.BlockController then
                    return
                end
                
                local success = pcall(function()
                    local function getLowGround()
                        local mag = math.huge
                        local store = bedwars.BlockController:getStore()
                        if store and store.getAllBlockPositions then
                            for _, pos in store:getAllBlockPositions() do
                                pos = pos * 3
                                if pos.Y < mag then
                                    mag = pos.Y
                                end
                            end
                        end
                        return mag
                    end
                    
                    local pos = getLowGround()
                    if pos ~= math.huge then
                        AntiFallPart = Instance.new('Part')
                        AntiFallPart.Name = "AntiFallPart"
                        AntiFallPart.Size = Vector3.new(10000, 5, 10000)
                        AntiFallPart.Transparency = 1
                        AntiFallPart.Position = Vector3.new(0, pos - 3, 0)
                        AntiFallPart.CanCollide = true
                        AntiFallPart.Anchored = true
                        AntiFallPart.CanQuery = false
                        AntiFallPart.Parent = workspace
                    end
                end)
                
                if not success then
                    return
                end
            else
                pcall(function()
                    if AntiFallPart then
                        AntiFallPart:Destroy()
                        AntiFallPart = nil
                    end
                end)
            end
        end)
        
        local FlyConnection = nil
        local FlyOld = nil
        local FlyUp = 0
        local FlyDown = 0
        local FlySpeed = 23
        local FlyVerticalSpeed = 50
        local FlyWallCheck = false
        local FlyTPDown = false
        
        GUI:CreateToggle("Fly", {
            default = false,
            save = true,
        }, function(callback)
            if callback then
                if not bedwars.BalloonController then
                    return
                end
                
                local success = pcall(function()
                    FlyUp, FlyDown = 0, 0
                    FlyOld = bedwars.BalloonController.deflateBalloon
                    bedwars.BalloonController.deflateBalloon = function() end
                    
                    local function getItem(itemName)
                        if LocalPlayer.Character then
                            for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                                if tool:IsA("Tool") and tool.Name:lower():find(itemName:lower()) then
                                    return tool
                                end
                            end
                        end
                        return nil
                    end
                    
                    local tpTick, tpToggle, oldY = tick(), true, nil
                    
                    if LocalPlayer.Character and (LocalPlayer.Character:GetAttribute('InflatedBalloons') or 0) == 0 and getItem('balloon') then
                        bedwars.BalloonController:inflateBalloon()
                    end
                    
                    FlyConnection = game:GetService("RunService").PreSimulation:Connect(function(dt)
                        local char = LocalPlayer.Character
                        if not char then return end
                        local root = char:FindFirstChild("HumanoidRootPart")
                        local humanoid = char:FindFirstChild("Humanoid")
                        if not root or not humanoid then return end
                        
                        local flyAllowed = (char:GetAttribute('InflatedBalloons') and char:GetAttribute('InflatedBalloons') > 0)
                        local mass = (1.5 + (flyAllowed and 6 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)) + ((FlyUp + FlyDown) * FlyVerticalSpeed)
                        local moveDirection = humanoid.MoveDirection
                        local velo = getSpeed()
                        local destination = (moveDirection * math.max(FlySpeed - velo, 0) * dt)
                        
                        if FlyWallCheck then
                            local rayCheck = RaycastParams.new()
                            rayCheck.RespectCanCollide = true
                            rayCheck.FilterDescendantsInstances = {char, workspace.CurrentCamera, AntiFallPart}
                            rayCheck.CollisionGroup = root.CollisionGroup
                            
                            local ray = workspace:Raycast(root.Position, destination, rayCheck)
                            if ray then
                                destination = ((ray.Position + ray.Normal) - root.Position)
                            end
                        end
                        
                        if not flyAllowed then
                            if FlyTPDown then
                                if tpToggle then
                                    local airTime = tick()
                                    if airTime > 2 then
                                        if not oldY then
                                            local rayCheck = RaycastParams.new()
                                            rayCheck.RespectCanCollide = true
                                            local ray = workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), rayCheck)
                                            if ray then
                                                tpToggle = false
                                                oldY = root.Position.Y
                                                tpTick = tick() + 0.11
                                                root.CFrame = CFrame.new(Vector3.new(root.Position.X, ray.Position.Y + humanoid.HipHeight, root.Position.Z))
                                            end
                                        end
                                    end
                                else
                                    if oldY then
                                        if tpTick < tick() then
                                            local newpos = Vector3.new(root.Position.X, oldY, root.Position.Z)
                                            root.CFrame = CFrame.new(newpos)
                                            tpToggle = true
                                            oldY = nil
                                        else
                                            mass = 0
                                        end
                                    end
                                end
                            end
                        end
                        
                        root.CFrame = root.CFrame + destination
                        root.AssemblyLinearVelocity = (moveDirection * velo) + Vector3.new(0, mass, 0)
                    end)
                end)
                
                if not success then
                    return
                end
            else
                pcall(function()
                    if FlyOld then
                        bedwars.BalloonController.deflateBalloon = FlyOld
                    end
                    if FlyConnection then
                        FlyConnection:Disconnect()
                        FlyConnection = nil
                    end
                end)
            end
        end)
        
        GUI:Slider("Fly Speed", {
            min = 1,
            max = 23,
            default = 23,
            save = true,
        }, function(value)
            FlySpeed = value
        end)
        
        GUI:Slider("Vertical Speed", {
            min = 1,
            max = 150,
            default = 50,
            save = true,
        }, function(value)
            FlyVerticalSpeed = value
        end)
        
        GUI:CreateToggle("Wall Check", {
            default = false,
            save = true,
        }, function(callback)
            FlyWallCheck = callback
        end)
        
        GUI:CreateToggle("TP Down", {
            default = false,
            save = true,
        }, function(callback)
            FlyTPDown = callback
        end)
    end)
end)

GUI:Tab("Render", function()
end)

GUI:Tab("Utility", function()
end)

GUI:Tab("World", function()
end)

GUI:Tab("Inventory", function()
end)

GUI:Tab("Misc", function()
end)

GUI:Tab("Settings", function()
    GUI:Section("Themes", function()
        GUI:Dropdown("Theme", {
            options = {"Default", "Green", "Red", "Orange"},
            default = "Default",
            mode = "auto",
            save = true,
        }, function(selected)
            applyTheme(selected)
        end)
    end)
    
    GUI:Section("Credits", function()
        GUI:Label("Scripted by: hive")
        GUI:Label("Library: Hive UI")
    end)
    
    GUI:Section("UI Configuration", function()
        GUI:CreateToggle("GUI Keybind", {
            keybind = GUIKeybind,
            save = true,
        })
        
        local function loadKeybind()
            local savedKey = GUI:Load("GUIKeybind")
            if savedKey then
                GUIKeybind = Enum.KeyCode[savedKey]
            end
        end
        loadKeybind()
        
        GUI:Button("Unload Script", function()
            GUI:Destroy()
            pcall(function()
                script:Destroy()
            end)
        end)
    end)
end)

GUI:Toggle()