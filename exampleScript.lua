local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("Example")

local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "Hive GUI";
    Text = "Loaded successfully | Press RightShift";
    Duration = 3;
})

-- Create sectors (tabs)
local Main = GUI:CreateSector("Main")
local Settings = GUI:CreateSector("Settings")
local Features = GUI:CreateSector("Features")

-- Create sections on Main tab
Main:CreateSection("Welcome"):CreateLabel("Welcome to Hive GUI!")
Main:CreateSection("Welcome"):CreateLabel("Press Right Shift to toggle")
Main:CreateSection("Welcome"):CreateLabel("Click tabs above to switch")

Main:CreateSection("Buttons"):CreateButton("Notify", function()
    StarterGui:SetCore("SendNotification", {
        Title = "Hive GUI";
        Text = "Button clicked!";
        Duration = 2;
    })
end)

-- Create sections on Features tab
Features:CreateSection("Feature Toggles"):CreateToggle("Example Toggle", false, function(state)
    print("Toggle state:", state)
end)

Features:CreateSection("Feature Toggles"):CreateToggle("Another Toggle", true, function(state)
    print("Another toggle:", state)
end)

-- Create sections on Settings tab
Settings:CreateSection("Settings"):CreateSlider("Volume", 0, 100, 50, function(value)
    print("Volume:", value)
end)

Settings:CreateSection("Settings"):CreateSlider("Sensitivity", 0, 10, 5, function(value)
    print("Sensitivity:", value)
end)

GUI:EnableKeySystem()
GUI:BindKey(Enum.KeyCode.V, function()
    GUI:Toggle()
end)

print("Example gui loaded - press right shift to open gui")
