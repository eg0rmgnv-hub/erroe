local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", true))()
local Window = Fluent:CreateWindow({ Title = "MoonHub UI ONLY", SubTitle = "No logic", TabWidth = 160, Size = UDim2.fromOffset(640, 540), Acrylic = false, Theme = "Dark", MinimizeKey = Enum.KeyCode.LeftControl })
local Tabs = {
    Movement = Window:AddTab({ Title = "Movement", Icon = "move" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Utility = Window:AddTab({ Title = "Utility", Icon = "compass" }),
    Troll = Window:AddTab({ Title = "Troll", Icon = "smile" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}
Tabs.Movement:AddToggle("SpeedEnabled",{Title="Enable Speed",Default=false,Callback=function() end})
Tabs.Movement:AddSlider("SpeedValue",{Title="WalkSpeed",Default=32,Min=16,Max=200,Rounding=0,Callback=function() end})
Tabs.Movement:AddToggle("FlyToggle",{Title="Fly",Default=false,Callback=function() end})
Tabs.Movement:AddSlider("FlySpeed",{Title="Fly Speed",Default=50,Min=10,Max=300,Rounding=0,Callback=function() end})
Tabs.Visuals:AddToggle("ESP",{Title="Enable ESP",Default=false,Callback=function() end})
Tabs.Visuals:AddToggle("Tracers",{Title="Tracers",Default=false,Callback=function() end})
Tabs.Combat:AddToggle("Aimbot",{Title="Aimbot",Default=false,Callback=function() end})
Tabs.Combat:AddDropdown("AimPart",{Title="Aim Part",Values={"Head","HumanoidRootPart","Torso"},Default=1,Callback=function() end})
Tabs.Player:AddToggle("AntiAFK",{Title="Anti AFK",Default=false,Callback=function() end})
Tabs.Utility:AddInput("TPPlayer",{Title="Teleport to Player",Placeholder="Username",Callback=function() end})
Tabs.Troll:AddInput("FlingPlayer",{Title="Fling Target",Placeholder="Username",Callback=function() end})
Tabs.Settings:AddDropdown("Language",{Title="Language",Values={"EN","UA","BY","KZ"},Default=1,Callback=function() end})
Window:SelectTab(1)
Fluent:Notify({ Title = "UI ONLY", Content = "If you see this, UI works", Duration = 4 })
