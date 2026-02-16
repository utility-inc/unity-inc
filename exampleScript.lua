-- Script Name: Example
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
Sliders:CreateLabel("Example Slider")
local ExampleSlider = Sliders:CreateSlider(0, 100, 50, function(value)
end)

GUI:EnableKeySystem()
GUI:BindKey(Enum.KeyCode.X, function()
    ExampleToggle:Set(not ExampleToggle:Get())
end)

GUI:BindKey(Enum.KeyCode.V, function()
    GUI:Toggle()
end)

print("Hive GUI loaded! Press Right Shift to open.")
