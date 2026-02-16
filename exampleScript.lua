local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("Example")

game.StarterGui:SetCore("SendNotification", {
    Title = "Hive GUI";
    Text = "Loaded successfully | Press RightShift";
    Duration = 3;
})

-- Create sectors (tabs)
local Main = GUI:CreateSector("Main")
local Settings = GUI:CreateSector("Settings")
local Features = GUI:CreateSector("Features")

-- Sections for Main tab
local welcomeSection = GUI:CreateSection("Welcome")
welcomeSection:CreateLabel("Welcome to Hive GUI!")
welcomeSection:CreateLabel("Press Right Shift to toggle")
welcomeSection:CreateLabel("Click tabs above to switch")

local buttonSection = GUI:CreateSection("Button Example")
buttonSection:CreateButton("Notify", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Hive GUI";
        Text = "Button clicked!";
        Duration = 2;
    })
end)

-- Switch to Features tab
Features:CreateSection("Feature Toggles")
GUI:CreateToggle("Example Toggle", false, function(state)
    print("Toggle state:", state)
end)

GUI:CreateToggle("Another Toggle", true, function(state)
    print("Another toggle:", state)
end)

-- Switch to Settings tab
Settings:CreateSection("Settings")
GUI:CreateSlider("Volume", 0, 100, 50, function(value)
    print("Volume:", value)
end)

GUI:CreateSlider("Sensitivity", 0, 10, 5, function(value)
    print("Sensitivity:", value)
end)

GUI:EnableKeySystem()
GUI:BindKey(Enum.KeyCode.V, function()
    GUI:Toggle()
end)

print("Example gui loaded - press right shift to open gui")
