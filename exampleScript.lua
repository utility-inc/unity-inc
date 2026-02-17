local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("Example")
local ToggleKey = Enum.KeyCode.RightShift

GUI:SetToggleKey(ToggleKey)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

-- // MAIN TAB
GUI:Tab("Main", function()
    GUI:Section("Welcome", function()
        GUI:Label("Welcome to Hive GUI example!")
        GUI:Label("Press " .. tostring(ToggleKey.Name) .. " to toggle gui")
        GUI:Button("Example button", function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Screen Message";
                Text = "this is a example button and this is a message that is linked to it";
                Duration = 5;
            })
        end)
    end)
end)

GUI:Tab("Settings", function()
    GUI:Section("Credits", function()
        GUI:Label("Scripted by: hive")
        GUI:Label("Library: Hive UI")
    end)
    
    GUI:Section("UI Configuration", function()
        GUI:Button("Unload Script", function()
            GUI:Destroy()
            script:Destroy()
        end)
    end)
end)

GUI:Toggle()
