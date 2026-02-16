local HiveLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/HiveLib.lua"))()

local lib = HiveLib.new()

lib.Theme.Accent = Color3.fromRGB(0, 200, 120)

local gui = lib:CreateGui()

lib:SetToggleKey(Enum.KeyCode.Escape)

lib:AddSection("Information")

lib:AddLabel("HiveLib v1.0.0 loaded!")

lib:AddButton("Show Notification", function()
    lib:Notification("HiveLib", "Welcome to HiveLib!", 5)
end)

lib:AddSeparator()

lib:AddSection("Features")

local speedToggle = lib:AddToggle("Speed Boost", false, function(state)
    if state then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 32
    else
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

local jumpToggle = lib:AddToggle("High Jump", false, function(state)
    if state then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 100
    else
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)

local healthToggle = lib:AddSeparator()

lib:AddSlider("Jump Power", 50, 300, 50, function(value)
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.Humanoid then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
    end
end)

lib:AddTextBox("Custom Message", "Enter text...", function(text)
    lib:Notification("Message", text, 3)
end)

lib:AddSeparator()

lib:AddButton("Reset Character", function()
    game.Players.LocalPlayer.Character:BreakJoints()
end)

lib:AddButton("Destroy GUI", function()
    lib:Destroy()
end)

task.wait(1)
lib:Notification("HiveLib", "Press ESC to toggle GUI", 5)
