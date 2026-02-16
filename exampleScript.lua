local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/libery.lua"))()

local GUI = Hive.new()

local Main = GUI:CreateSection("Welcome")
Main:CreateLabel("Welcome to Hive GUI!")
Main:CreateLabel("Press Right Shift to toggle")
Main:CreateLabel("Drag the title bar to move")

local Buttons = GUI:CreateSection("Buttons")
Buttons:CreateButton("Print Hello", function()
    print("Hello from Hive GUI!")
end)

Buttons:CreateButton("Notify Player", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Hive GUI";
        Text = "Button clicked!";
        Duration = 2;
    })
end)

local Toggles = GUI:CreateSection("Toggles")
local ExampleToggle = Toggles:CreateToggle(false, function(state)
    print("Example toggle:", state)
    if state then
        print("Feature enabled!")
    else
        print("Feature disabled!")
    end
end)

local Sliders = GUI:CreateSection("Sliders")
Sliders:CreateLabel("Volume Slider")
local VolumeSlider = Sliders:CreateSlider(0, 100, 50, function(value)
    print("Volume set to:", value)
end)

Sliders:CreateLabel("Sensitivity Slider")
local SensSlider = Sliders:CreateSlider(1, 100, 50, function(value)
    print("Sensitivity set to:", value)
end)

local Inputs = GUI:CreateSection("Inputs")
Inputs:CreateInput("Enter your name...", function(text)
    print("Player name:", text)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Hive GUI";
        Text = "Name saved: " .. text;
        Duration = 2;
    })
end)

GUI:EnableKeySystem()
GUI:BindKey(Enum.KeyCode.X, function()
    print("[KeyBind] X pressed!")
    ExampleToggle:Set(not ExampleToggle:Get())
end)

GUI:BindKey(Enum.KeyCode.V, function()
    print("[KeyBind] V pressed - Toggling GUI")
    GUI:Toggle()
end)

GUI:BindKey(Enum.KeyCode.P, function()
    print("[KeyBind] P pressed - Random volume")
    local randomVol = math.random(0, 100)
    VolumeSlider:Set(randomVol)
end)

print("Hive GUI loaded! Press Right Shift to open.")
