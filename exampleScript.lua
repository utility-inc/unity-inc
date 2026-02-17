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
        GUI:Label("Welcome to Hive GUI!")
        GUI:Label("Press " .. tostring(ToggleKey.Name) .. " to toggle")
        GUI:Button("Click Me", function()
            print("Button clicked!")
        end)
    end)
end)
GUI:Tab("Settings", function()
    GUI:Section("UI Configuration", function()
        GUI:Label("Current Key: " .. tostring(ToggleKey.Name))
        GUI:Button("Update Toggle Key (F8)", function()
            ToggleKey = Enum.KeyCode.F8
            GUI:SetToggleKey(ToggleKey)
            print("Toggle key changed to F8")
        end)

        GUI:Button("Unload Script", function()
            print("Unloading UI...") 
        end)
    end)
    GUI:Section("Credits", function()
        GUI:Label("Scripted by: You")
        GUI:Label("Library: Hive UI")
    end)
end)
GUI:Toggle()