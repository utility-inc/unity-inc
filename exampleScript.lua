local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("Example")

GUI:SetToggleKey(Enum.KeyCode.RightShift)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

GUI:Tab("Main", function()
    GUI:Section("Welcome", function()
        GUI:Label("Welcome to Hive GUI!")
        GUI:Label("Press RightShift to toggle")
        GUI:Button("Click Me", function()
            print("Button clicked!")
        end)
    end)
end)

GUI:Tab("Settings", function()
    GUI:Section("Player", function()
        GUI:Slider("Speed", {
            min = 0,
            max = 100,
            default = 16,
        }, function(value)
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.WalkSpeed = value
            end
        end)
    end)
end)

GUI:Toggle()
