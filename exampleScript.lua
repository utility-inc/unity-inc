local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("Example")

game.StarterGui:SetCore("SendNotification", {
    Title = "Hive GUI";
    Text = "Loaded successfully | Press RightShift";
    Duration = 3;
})

local Main = GUI:CreateSector("Main")
local Settings = GUI:CreateSector("Settings", "S")
local Features = GUI:CreateSector("Features", "F")

local mainSection = GUI:CreateSection("Welcome")
mainSection:CreateLabel("Welcome to Hive GUI!")
mainSection:CreateLabel("Press Right Shift to toggle")
mainSection:CreateLabel("")

local buttonSection = GUI:CreateSection("Button Example")
buttonSection:CreateButton("Notify", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Hive GUI";
        Text = "Button clicked!";
        Duration = 2;
    })
end)

GUI:CreateSection("Toggles")
GUI:CreateToggle("Example Toggle", false, function(state)
    print("Toggle state:", state)
end)

GUI:CreateSection("Settings Section")
GUI:CreateSlider("Volume", 0, 100, 50, function(value)
    print("Volume:", value)
end)

GUI:EnableKeySystem()
GUI:BindKey(Enum.KeyCode.V, function()
    GUI:Toggle()
end)

print("Example gui loaded press right shift to open gui")
