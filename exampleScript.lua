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
local welcomeSection = Main:CreateSection("Welcome")
welcomeSection:CreateLabel("Welcome to Hive GUI!")
welcomeSection:CreateLabel("Press Right Shift to toggle")
welcomeSection:CreateLabel("Click tabs above to switch")

welcomeSection:CreateButton("Notify", function()
    StarterGui:SetCore("SendNotification", {
        Title = "Hive GUI";
        Text = "Button clicked!";
        Duration = 2;
    })
end)

GUI:EnableKeySystem()
GUI:BindKey(Enum.KeyCode.V, function()
    GUI:Toggle()
end)

print("Example gui loaded - press right shift to open gui")
