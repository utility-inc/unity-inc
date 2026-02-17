local Hive = loadstring(game:HttpGet("https://raw.githubusercontent.com/utility-inc/unity-inc/main/library.lua"))()

local GUI = Hive.new("Example")
local ToggleKey = Enum.KeyCode.RightShift

GUI:SetToggleKey(ToggleKey)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
end)

local Themes = {
    Default = {
        Background = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 50),
        Accent = Color3.fromRGB(65, 105, 225),
        AccentLight = Color3.fromRGB(100, 149, 237),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(60, 60, 80),
    },
    Green = {
        Background = Color3.fromRGB(25, 35, 30),
        Secondary = Color3.fromRGB(35, 50, 40),
        Accent = Color3.fromRGB(46, 204, 113),
        AccentLight = Color3.fromRGB(100, 230, 150),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 200, 180),
        Border = Color3.fromRGB(60, 90, 70),
    },
    Red = {
        Background = Color3.fromRGB(35, 25, 25),
        Secondary = Color3.fromRGB(50, 35, 35),
        Accent = Color3.fromRGB(231, 76, 60),
        AccentLight = Color3.fromRGB(240, 130, 110),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 180, 180),
        Border = Color3.fromRGB(90, 60, 60),
    },
    Orange = {
        Background = Color3.fromRGB(35, 30, 25),
        Secondary = Color3.fromRGB(50, 40, 35),
        Accent = Color3.fromRGB(230, 126, 34),
        AccentLight = Color3.fromRGB(240, 160, 100),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 190, 180),
        Border = Color3.fromRGB(90, 70, 60),
    },
}

local function applyTheme(themeName)
    local theme = Themes[themeName]
    if not theme then return end
    
    GUI.MainFrame.BackgroundColor3 = theme.Background
    GUI.TitleBar.BackgroundColor3 = theme.Secondary
    
    print("Theme applied:", themeName)
end

-- // MAIN TAB
GUI:Tab("Main", function()
    GUI:Section("Welcome", function()
        GUI:Label("Welcome to Hive GUI example!")
        GUI:Label("Press " .. tostring(ToggleKey.Name) .. " to toggle gui")
        GUI:Button("Example button", function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Screen Message";
                Text = "this is a example button and this is a message that is linked to it";
                Duration = 5;
            })
        end)
    end)
end)

GUI:Tab("Settings", function()
    GUI:Section("Themes", function()
        GUI:Dropdown("Theme", {
            options = {"Default", "Green", "Red", "Orange"},
            default = "Default",
            mode = "auto",
        }, function(selected)
            applyTheme(selected)
        end)
    end)
    
    GUI:Section("Dropdown Example", function()
        GUI:Dropdown("Mode", {
            options = {"Option1", "Option2", "Option3"},
            default = "Option1",
            mode = "manual",
        }, function(selected)
            print("Manual mode selected:", selected)
        end)
    end)
    
    GUI:Section("Credits", function()
        GUI:Label("Scripted by: hive")
        GUI:Label("Library: Hive UI")
    end)
    
    GUI:Section("UI Configuration", function()
        GUI:Button("Unload Script", function()
            GUI:Destroy()
            pcall(function()
                script:Destroy()
            end)
        end)
    end)
end)

GUI:Toggle()
