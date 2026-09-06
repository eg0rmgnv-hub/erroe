local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", true))()
local Window = Fluent:CreateWindow({ Title = "MoonHub DEBUG FULL", SubTitle = "6 tabs", TabWidth = 160, Size = UDim2.fromOffset(640, 540), Acrylic = false, Theme = "Dark", MinimizeKey = Enum.KeyCode.LeftControl })
local Tabs = {
    Movement = Window:AddTab({ Title = "Movement", Icon = "move" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Utility = Window:AddTab({ Title = "Utility", Icon = "compass" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}
for name, tab in pairs(Tabs) do
    pcall(function()
        tab:AddToggle("TestToggle_"..name, { Title = "Toggle "..name, Default = false, Callback = function(v) print(name, v) end })
        tab:AddSlider("TestSlider_"..name, { Title = "Slider "..name, Default = 50, Min = 0, Max = 100, Rounding = 0, Callback = function(v) print(v) end })
        tab:AddButton({ Title = "Button "..name, Callback = function() print("btn "..name) end })
    end)
end
Fluent:Notify({ Title = "DEBUG FULL", Content = "6 tabs created", Duration = 4 })
Window:SelectTab(1)
