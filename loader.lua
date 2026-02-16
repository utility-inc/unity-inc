--[[
    HiveLib Loader
    Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/HiveLib.lua"))()
    
    Or use the example below:
]]

local HiveLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/HiveLib.lua"))()

-- Create the GUI
local gui = HiveLib:CreateGui()

-- Set toggle key (Press ESC to toggle GUI)
HiveLib:SetToggleKey(Enum.KeyCode.Escape)

-- Add custom keybind
HiveLib:AddKeybind("Print Hello", Enum.KeyCode.H, function()
    print("Hello! Keybind pressed.")
end)

-- Add components
HiveLib:AddSection("Example")

HiveLib:AddButton("Hello World", function()
    HiveLib:Notification("Hello", "You clicked the button!", 3)
end)

HiveLib:AddToggle("Example Toggle", false, function(state)
    print("Toggle is now:", state)
end)

HiveLib:AddSlider("Example Slider", 0, 100, 50, function(value)
    print("Slider value:", value)
end)

HiveLib:AddTextBox("Example Input", "Enter text...", function(text)
    print("Input:", text)
end)

HiveLib:AddLabel("This is a label")

HiveLib:AddSeparator()

HiveLib:AddButton("Show Notification", function()
    HiveLib:Notification("Success!", "Everything is working!", 5)
end)

-- Show initial notification
task.wait(1)
HiveLib:Notification("HiveLib Loaded", "Press ESC to toggle GUI. Press H for keybind test.", 5)
