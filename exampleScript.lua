-- Script Name: Example
local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("Example")

local Main = GUI:CreateSection("Welcome")
Main:CreateLabel("Welcome to Hive GUI!")
Main:CreateLabel("Press Right Shift to toggle")

local Button = GUI:CreateSection("Button Example")
Button:CreateButton("Notify", function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Hive GUI";
        Text = "Button clicked!";
        Duration = 2;
    })
end)

local Toggles = GUI:CreateSection("Toggles")
local ExampleToggle = Toggles:CreateToggle(false, function(state)
end)

local Sliders = GUI:CreateSection("Sliders")
Sliders:CreateLabel("Example Slider")
local ExampleSlider = Sliders:CreateSlider(0, 100, 50, function(value)
end)

GUI:EnableKeySystem()
GUI:BindKey(Enum.KeyCode.V, function()
    GUI:Toggle()
end)

print("Example gui loaded press right shift to open gui")
