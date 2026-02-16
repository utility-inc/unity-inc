local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("Example")

game.StarterGui:SetCore("SendNotification", {
    Title = "⚡ Hive GUI";
    Text = "Loaded successfully | Press RightShift";
    Duration = 3;
})

local Main = GUI:CreateSection("Welcome")
Main:CreateLabel("Welcome to Hive GUI!")
Main:CreateLabel("Press Right Shift to toggle")
Main:CreateLabel("")

local Button = GUI:CreateSection("Button Example")
Button:CreateButton("Notify", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Hive GUI";
        Text = "Button clicked!";
        Duration = 2;
    })
end)

local Toggles = GUI:CreateSection("Toggles")
Toggles:CreateToggle("Example Toggle", false, function(state)
    print("Toggle state:", state)
end)
Toggles:bel("")
Main:CreateLabel("")

local Sliders = GUI:CreateSection("Sliders")
Sliders:CreateLabel("Example Slider")
Sliders:CreateSlider("Volume", 0, 100, 50, function(value)
    print("Volume:", value)
end)

GUI:EnableKeySystem()
GUI:BindKey(Enum.KeyCode.V, function()
    GUI:Toggle()
end)

print("Example gui loaded press right shift to open gui")
