local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", true))()
local Window = Fluent:CreateWindow({ Title = "STRESS", SubTitle = "30 components", TabWidth = 160, Size = UDim2.fromOffset(640, 540), Acrylic = false, Theme = "Dark", MinimizeKey = Enum.KeyCode.LeftControl })
local Tabs = {
    A = Window:AddTab({ Title = "A", Icon = "move" }),
    B = Window:AddTab({ Title = "B", Icon = "eye" }),
    C = Window:AddTab({ Title = "C", Icon = "crosshair" }),
}
for i=1,10 do
    Tabs.A:AddToggle("TogA"..i, { Title = "Toggle A"..i, Default = false, Callback = function() end })
    Tabs.B:AddSlider("SliB"..i, { Title = "Slider B"..i, Default = 50, Min = 0, Max = 100, Rounding = 0, Callback = function() end })
    Tabs.C:AddButton({ Title = "Button C"..i, Callback = function() end })
end
Fluent:Notify({ Title = "STRESS", Content = "30 comps OK", Duration = 3 })
Window:SelectTab(1)
