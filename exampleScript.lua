local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("Example")

GUI:SetToggleKey(Enum.KeyCode.RightShift)

GUI:Toggle()

print("Hive GUI loaded - press RightShift to toggle")
