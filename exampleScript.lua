local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("Example")

GUI:SetToggleKey(Enum.KeyCode.RightShift)

GUI:Tab("Main", function()
    GUI:Section("Welcome", function()
        GUI:Label("Welcome to Hive GUI!")
        GUI:Label("Press RightShift to toggle")
        GUI:Button("Click Me", function()
            print("Button clicked!")
        end)
    end)
end)

GUI:Toggle()

print("Hive GUI loaded - press RightShift to toggle")
