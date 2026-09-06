local function safeGet(url)
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if ok and res and #res > 100 then return res end
    local ok2, res2 = pcall(function() return game:HttpGet(url) end)
    return ok2 and res2 or nil
end
local fluentSrc = safeGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
if not fluentSrc or #fluentSrc < 100 then fluentSrc = safeGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/library.lua") end
local Fluent = loadstring(fluentSrc)()
local SaveManager, InterfaceManager
pcall(function() SaveManager = loadstring(safeGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))() end)
pcall(function() InterfaceManager = loadstring(safeGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))() end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local T = {
    en = {Movement="Movement",Visuals="Visuals",Combat="Combat",Player="Player",Utility="Utility",Troll="Troll",Settings="Settings",Loaded="Loaded successfully",Fling="Fling Player",Orbit="Orbit Player",Attach="Attach to Player",View="View Player"},
    uk = {Movement="Рух",Visuals="Візуали",Combat="Бій",Player="Гравець",Utility="Утиліти",Troll="Троль",Settings="Налаштування",Loaded="Успішно завантажено",Fling="Кидок гравця",Orbit="Орбіта",Attach="Прикріпитись",View="Стежити"},
    be = {Movement="Рух",Visuals="Візуал",Combat="Бой",Player="Гулец",Utility="Утыліты",Troll="Троль",Settings="Налады",Loaded="Паспяхова загружана",Fling="Кінуць гульца",Orbit="Арбіта",Attach="Прымацавацца",View="Сачыць"},
    kk = {Movement="Қозғалыс",Visuals="Визуал",Combat="Ұрыс",Player="Ойыншы",Utility="Құралдар",Troll="Тролль",Settings="Баптаулар",Loaded="Сәтті жүктелді",Fling="Ойыншыны лақтыру",Orbit="Айналдыру",Attach="Жабысу",View="Бақылау"}
}
local curLang = "en"
local function tr(k) local d=T[curLang] return d and d[k] or k end
local function applyLang(lang)
    curLang=lang
    pcall(function()
        for _,v in ipairs(game.CoreGui:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                v.Font = Enum.Font.GothamBold
                for k,enVal in pairs(T.en) do
                    if v.Text==enVal then v.Text=T[lang][k] end
                    for _,other in pairs(T) do if v.Text==other[k] then v.Text=T[lang][k] end end
                end
            end
        end
    end)
    Fluent:Notify({Title="MoonHub",Content=(T[lang] and T[lang].Loaded or "Loaded").." ["..lang.."]",Duration=3})
end

local Window = Fluent:CreateWindow({
    Title = "MoonHub",
    SubTitle = "Universal  v1.2  //  Amethyst",
    TabWidth = 160,
    Size = UDim2.fromOffset(640, 540),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})
task.spawn(function()
    pcall(function()
        task.wait(0.4)
        Fluent:Notify({Title="MoonHub",Content="Amethyst palette active",Duration=2})
    end)
end)

task.defer(function()
    task.wait(0.7)
    pcall(function()
        for _,v in ipairs(game.CoreGui:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                v.Font = Enum.Font.GothamBold
            end
            if v:IsA("Frame") and v.Name=="Main" then
                local s=Instance.new("UIStroke")
                s.Color=Color3.fromRGB(168,85,247)
                s.Thickness=1.2
                s.Transparency=0.55
                s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
                s.Parent=v
            end
        end
    end)
end)

local Tabs = {
    Movement = Window:AddTab({ Title = tr("Movement"), Icon = "move" }),
    Visuals = Window:AddTab({ Title = tr("Visuals"), Icon = "eye" }),
    Combat = Window:AddTab({ Title = tr("Combat"), Icon = "crosshair" }),
    Player = Window:AddTab({ Title = tr("Player"), Icon = "user" }),
    Utility = Window:AddTab({ Title = tr("Utility"), Icon = "compass" }),
    Troll = Window:AddTab({ Title = tr("Troll"), Icon = "smile" }),
    Settings = Window:AddTab({ Title = tr("Settings"), Icon = "settings" })
}
local Options = Fluent.Options
Fluent:Notify({ Title = "MoonHub", Content = tr("Loaded"), Duration = 4 })

local function getCharacter() return LocalPlayer.Character end
local function getHumanoid() local c=getCharacter() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c=getCharacter() return c and c:FindFirstChild("HumanoidRootPart") end
local function findPlayer(name)
    if not name or name=="" then return nil end
    for _,p in ipairs(Players:GetPlayers()) do if p.Name:lower():sub(1,#name)==name:lower() then return p end end
    return Players:FindFirstChild(name)
end

------------------------------------------------
-- MOVEMENT
------------------------------------------------
local speedEnabled=false
local speedValue=32
local jumpValue=50
local flyEnabled=false
local flySpeed=50
local noclipEnabled=false
local noclipConn=nil
local infJumpEnabled=false
Tabs.Movement:AddToggle("SpeedEnabled",{Title="Enable Speed",Default=false,Callback=function(v) speedEnabled=v end})
Tabs.Movement:AddSlider("SpeedValue",{Title="WalkSpeed",Default=32,Min=16,Max=200,Rounding=0,Callback=function(v) speedValue=v end})
Tabs.Movement:AddToggle("JumpEnabled",{Title="Enable JumpPower",Default=false,Callback=function(v) local h=getHumanoid() if h then h.UseJumpPower=v end end})
Tabs.Movement:AddSlider("JumpValue",{Title="JumpPower",Default=50,Min=50,Max=350,Rounding=0,Callback=function(v) jumpValue=v local h=getHumanoid() if h then if h.UseJumpPower then h.JumpPower=v else h.JumpHeight=v/4 end end end})
local flyConn,flyGyro,flyVel
local function startFly()
    local root=getRoot() if not root then return end
    flyGyro=Instance.new("BodyGyro") flyGyro.P=9e4 flyGyro.MaxTorque=Vector3.new(9e9,9e9,9e9) flyGyro.CFrame=root.CFrame flyGyro.Parent=root
    flyVel=Instance.new("BodyVelocity") flyVel.Velocity=Vector3.new(0,0,0) flyVel.MaxForce=Vector3.new(9e9,9e9,9e9) flyVel.Parent=root
    flyConn=RunService.Heartbeat:Connect(function()
        if not flyEnabled then return end
        local h=getHumanoid() local r=getRoot() if not h or not r then return end
        h.PlatformStand=true
        local dir=Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir+=Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir-=Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir-=Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir+=Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0) end
        if dir.Magnitude>0 then dir=dir.Unit*flySpeed else dir=Vector3.new(0,0,0) end
        flyVel.Velocity=dir flyGyro.CFrame=Camera.CFrame
    end)
end
local function stopFly() if flyConn then flyConn:Disconnect() flyConn=nil end if flyGyro then flyGyro:Destroy() flyGyro=nil end if flyVel then flyVel:Destroy() flyVel=nil end local h=getHumanoid() if h then h.PlatformStand=false end end
Tabs.Movement:AddToggle("FlyToggle",{Title="Fly",Default=false,Callback=function(v) flyEnabled=v if v then startFly() else stopFly() end end})
Tabs.Movement:AddSlider("FlySpeed",{Title="Fly Speed",Default=50,Min=10,Max=300,Rounding=0,Callback=function(v) flySpeed=v end})
Tabs.Movement:AddToggle("Noclip",{Title="Noclip",Default=false,Callback=function(v)
    noclipEnabled=v
    if v then noclipConn=RunService.Stepped:Connect(function() local c=getCharacter() if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end end end end) Fluent:Notify({Title="Noclip",Content="Enabled",Duration=2})
    else if noclipConn then noclipConn:Disconnect() noclipConn=nil end end
end})
Tabs.Movement:AddToggle("InfJump",{Title="Infinite Jump",Default=false,Callback=function(v) infJumpEnabled=v end})
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.7) local h=getHumanoid() if h then h.UseJumpPower=Options.JumpEnabled and Options.JumpEnabled.Value or false if h.UseJumpPower then h.JumpPower=jumpValue else h.JumpHeight=jumpValue/4 end end if flyEnabled then stopFly() task.wait(0.2) startFly() end end)
UserInputService.JumpRequest:Connect(function() if infJumpEnabled and getHumanoid() then pcall(function() getHumanoid():ChangeState(Enum.HumanoidStateType.Jumping) end) end end)

------------------------------------------------
-- VISUALS
------------------------------------------------
local espEnabled=false
local espBoxes=true
local espNames=true
local espHealth=true
local espDistance=false
local tracerEnabled=false
local espFolder=Instance.new("Folder") espFolder.Name="MoonHub_ESP" espFolder.Parent=game.CoreGui
local highlights={},billboards={},tracerLines={}
local function clearESP(plr) if highlights[plr] then highlights[plr]:Destroy() highlights[plr]=nil end if billboards[plr] then billboards[plr]:Destroy() billboards[plr]=nil end if tracerLines[plr] then pcall(function() tracerLines[plr]:Remove() end) tracerLines[plr]=nil end end
local function createESP(plr)
    if plr==LocalPlayer then return end pcall(clearESP,plr) local char=plr.Character if not char then return end
    local hl=Instance.new("Highlight") hl.Adornee=char hl.FillTransparency=0.6 hl.FillColor=Color3.fromRGB(168,85,247) hl.OutlineColor=Color3.fromRGB(192,132,252) hl.OutlineTransparency=0 hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hl.Enabled=espEnabled and espBoxes hl.Parent=espFolder highlights[plr]=hl
    local bb=Instance.new("BillboardGui") bb.Adornee=char:WaitForChild("Head",3) or char:FindFirstChildWhichIsA("BasePart") bb.Size=UDim2.fromOffset(200,50) bb.StudsOffset=Vector3.new(0,2.5,0) bb.AlwaysOnTop=true bb.Parent=espFolder local label=Instance.new("TextLabel") label.BackgroundTransparency=1 label.Size=UDim2.fromScale(1,1) label.Font=Enum.Font.GothamBold label.TextSize=13 label.TextStrokeTransparency=0.2 label.TextColor3=Color3.fromRGB(245,235,255) label.Text=plr.Name label.Parent=bb billboards[plr]=bb
    if tracerEnabled and Drawing then local line=Drawing.new("Line") line.Visible=true line.Thickness=1.2 line.Transparency=0.85 line.Color=Color3.fromRGB(168,85,247) tracerLines[plr]=line end
    char.AncestryChanged:Connect(function() if not char.Parent then clearESP(plr) end end)
end
local function updateESP()
    for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer then local bb=billboards[plr] local hl=highlights[plr] if bb and hl then local char=plr.Character local hum=char and char:FindFirstChildOfClass("Humanoid") local root=char and char:FindFirstChild("HumanoidRootPart") local head=char and char:FindFirstChild("Head") if char and hum and root and head and hum.Health>0 then hl.Enabled=espEnabled and espBoxes bb.Enabled=espEnabled local dist=LocalPlayer:DistanceFromCharacter(root.Position) local txt="" if espNames then txt..=plr.Name end if espHealth and hum then txt..=string.format("  [%d/%d]",math.floor(hum.Health),hum.MaxHealth) end if espDistance then txt..=string.format("  %dm",math.floor(dist)) end bb:FindFirstChildOfClass("TextLabel").Text=txt bb.Adornee=head local col=Color3.fromRGB(168,85,247) if hum.Health/hum.MaxHealth<0.5 then col=Color3.fromRGB(239,68,68) end hl.FillColor=col hl.OutlineColor=col if tracerLines[plr] then local line=tracerLines[plr] local pos,onScreen=Camera:WorldToViewportPoint(root.Position) line.Visible=onScreen and espEnabled and tracerEnabled if onScreen then line.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y) line.To=Vector2.new(pos.X,pos.Y) end end else hl.Enabled=false bb.Enabled=false if tracerLines[plr] then tracerLines[plr].Visible=false end end elseif espEnabled and plr.Character then createESP(plr) end end end
end
for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then createESP(p) end end
Players.PlayerAdded:Connect(function(p) task.wait(1) if espEnabled then createESP(p) end p.CharacterAdded:Connect(function() task.wait(1) if espEnabled then createESP(p) end end) end)
Players.PlayerRemoving:Connect(clearESP)
Tabs.Visuals:AddToggle("ESP",{Title="Enable ESP",Default=false,Callback=function(v) espEnabled=v if not v then for _,plr in ipairs(Players:GetPlayers()) do if highlights[plr] then highlights[plr].Enabled=false end if billboards[plr] then billboards[plr].Enabled=false end if tracerLines[plr] then tracerLines[plr].Visible=false end end else for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer then createESP(plr) end end end end})
Tabs.Visuals:AddToggle("ESPBox",{Title="Highlight Box",Default=true,Callback=function(v) espBoxes=v end})
Tabs.Visuals:AddToggle("ESPName",{Title="Show Name",Default=true,Callback=function(v) espNames=v end})
Tabs.Visuals:AddToggle("ESPHealth",{Title="Show Health",Default=true,Callback=function(v) espHealth=v end})
Tabs.Visuals:AddToggle("ESPDistance",{Title="Show Distance",Default=false,Callback=function(v) espDistance=v end})
Tabs.Visuals:AddToggle("Tracers",{Title="Tracers",Default=false,Callback=function(v) tracerEnabled=v if not v then for _,l in pairs(tracerLines) do pcall(function() l.Visible=false end) end end if v and Drawing then for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer and not tracerLines[plr] then createESP(plr) end end end end})
Tabs.Visuals:AddToggle("Fullbright",{Title="Fullbright",Default=false,Callback=function(v) if v then Lighting.Brightness=2 Lighting.Ambient=Color3.fromRGB(255,255,255) Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255) Lighting.FogEnd=100000 Lighting.GlobalShadows=false else Lighting.Brightness=1 Lighting.Ambient=Color3.fromRGB(128,128,128) Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128) Lighting.FogEnd=10000 Lighting.GlobalShadows=true end end})
Tabs.Visuals:AddSlider("FOVSlider",{Title="Field of View",Default=70,Min=70,Max=120,Rounding=0,Callback=function(v) Camera.FieldOfView=v end})
Tabs.Visuals:AddToggle("XRay",{Title="X-Ray Walls",Default=false,Callback=function(v) for _,obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("BasePart") and not obj:IsDescendantOf(getCharacter() or Workspace) then obj.LocalTransparencyModifier=v and 0.7 or 0 end end end})

Tabs.Visuals:AddSection("Character Visuals")
Tabs.Visuals:AddButton({Title="Korblox Leg (Visual)",Callback=function()
    local c=getCharacter() if not c then return end
    local rLeg=c:FindFirstChild("Right Leg") or c:FindFirstChild("RightLowerLeg")
    if rLeg then
        if rLeg:IsA("Part") then rLeg.MeshId="http://www.roblox.com/asset/?id=101091329" rLeg.Mesh.Scale=Vector3.new(1,1,1)
        else
            for _,v in ipairs(rLeg:GetDescendants()) do if v:IsA("SpecialMesh") then v.MeshId="http://www.roblox.com/asset/?id=101091329" end end
        end
        Fluent:Notify({Title="Visuals",Content="Korblox applied (client only)",Duration=3})
    end
end})
Tabs.Visuals:AddButton({Title="Headless (Visual)",Callback=function()
    local c=getCharacter() if not c then return end
    local head=c:FindFirstChild("Head") if head then head.Transparency=1 for _,d in ipairs(head:GetChildren()) do if d:IsA("Decal") then d.Transparency=1 end end end
    Fluent:Notify({Title="Visuals",Content="Headless applied (client only)",Duration=3})
end})
Tabs.Visuals:AddButton({Title="Reset Visuals",Callback=function()
    local c=getCharacter() if not c then return end
    local head=c:FindFirstChild("Head") if head then head.Transparency=0 for _,d in ipairs(head:GetChildren()) do if d:IsA("Decal") then d.Transparency=0 end end end
    Fluent:Notify({Title="Visuals",Content="Reset done",Duration=2})
end})
local auraEnabled=false
local auraEmitter=nil
Tabs.Visuals:AddToggle("Aura",{Title="Amethyst Aura",Default=false,Callback=function(v)
    auraEnabled=v
    local root=getRoot()
    if v and root then
        auraEmitter=Instance.new("ParticleEmitter") auraEmitter.Texture="rbxassetid://6889792345" auraEmitter.Color=ColorSequence.new(Color3.fromRGB(168,85,247)) auraEmitter.Rate=22 auraEmitter.Lifetime=NumberRange.new(1,1.5) auraEmitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.4),NumberSequenceKeypoint.new(1,0)}) auraEmitter.Speed=NumberRange.new(3,5) auraEmitter.Parent=root
        local light=Instance.new("PointLight") light.Color=Color3.fromRGB(168,85,247) light.Range=12 light.Brightness=2 light.Name="MoonAuraLight" light.Parent=root
    else
        if root then for _,x in ipairs(root:GetChildren()) do if x:IsA("ParticleEmitter") or x.Name=="MoonAuraLight" then x:Destroy() end end end auraEmitter=nil
    end
end})

------------------------------------------------
-- COMBAT
------------------------------------------------
local aimEnabled=false
local teamCheck=true
local wallCheck=true
local aimPart="Head"
local fovRadius=160
local showFOV=true
local fovCircle
if Drawing then fovCircle=Drawing.new("Circle") fovCircle.Color=Color3.fromRGB(168,85,247) fovCircle.Thickness=1.2 fovCircle.NumSides=64 fovCircle.Filled=false fovCircle.Transparency=0.9 fovCircle.Visible=false end
local function isVisible(part) if not wallCheck then return true end local rayParams=RaycastParams.new() rayParams.FilterDescendantsInstances={LocalPlayer.Character,Camera} rayParams.FilterType=Enum.RaycastFilterType.Exclude local origin=Camera.CFrame.Position local dir=part.Position-origin local result=Workspace:Raycast(origin,dir,rayParams) return result==nil or result.Instance:IsDescendantOf(part.Parent) end
local function getClosest()
    local closest,dist=nil,fovRadius
    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer then if teamCheck and plr.Team==LocalPlayer.Team then continue end local char=plr.Character local hum=char and char:FindFirstChildOfClass("Humanoid") local target=char and char:FindFirstChild(aimPart) if char and hum and target and hum.Health>0 then local pos,onScreen=Camera:WorldToViewportPoint(target.Position) if onScreen and isVisible(target) then local mag=(Vector2.new(pos.X,pos.Y)-center).Magnitude if mag<dist then dist=mag closest=target end end end end end
    return closest
end
Tabs.Combat:AddToggle("Aimbot",{Title="Aimbot (Hold RMB)",Default=false,Callback=function(v) aimEnabled=v end})
Tabs.Combat:AddToggle("TeamCheck",{Title="Team Check",Default=true,Callback=function(v) teamCheck=v end})
Tabs.Combat:AddToggle("WallCheck",{Title="Wall Check",Default=true,Callback=function(v) wallCheck=v end})
Tabs.Combat:AddToggle("ShowFOV",{Title="Show FOV Circle",Default=true,Callback=function(v) showFOV=v end})
Tabs.Combat:AddSlider("FOVRadius",{Title="FOV Radius",Default=160,Min=40,Max=600,Rounding=0,Callback=function(v) fovRadius=v if fovCircle then fovCircle.Radius=v end end})
Tabs.Combat:AddDropdown("AimPart",{Title="Aim Part",Values={"Head","HumanoidRootPart","Torso"},Default=1,Callback=function(v) aimPart=v end})
Tabs.Combat:AddSlider("HitboxSize",{Title="Hitbox Expander",Default=2,Min=2,Max=20,Rounding=1,Callback=function(v) for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then local p=plr.Character.HumanoidRootPart p.Size=Vector3.new(v,v,v) p.Transparency=0.6 p.CanCollide=false p.Massless=true end end end})
Tabs.Combat:AddButton({Title="Reset Hitboxes",Callback=function() for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then local p=plr.Character.HumanoidRootPart p.Size=Vector3.new(2,2,1) p.Transparency=1 end end end})

------------------------------------------------
-- PLAYER
------------------------------------------------
Tabs.Player:AddSection("Character")
local antiAFK=false
Tabs.Player:AddToggle("AntiAFK",{Title="Anti AFK",Default=false,Callback=function(v) antiAFK=v end})
Tabs.Player:AddButton({Title="Anti Ragdoll",Callback=function() local c=getCharacter() if c then for _,v in ipairs(c:GetDescendants()) do if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then v:Destroy() end end end end})
Tabs.Player:AddButton({Title="Invisible",Callback=function() local c=getCharacter() if not c then return end for _,part in ipairs(c:GetDescendants()) do if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then part.Transparency=part.Transparency==1 and 0 or 1 end end end})
local spinEnabled=false local spinConn=nil local spinSpeed=22
Tabs.Player:AddToggle("SpinBot",{Title="SpinBot",Default=false,Callback=function(v) spinEnabled=v if v then spinConn=RunService.Heartbeat:Connect(function() local r=getRoot() if r then r.CFrame=r.CFrame*CFrame.Angles(0,math.rad(spinSpeed),0) end end) else if spinConn then spinConn:Disconnect() spinConn=nil end end end})
Tabs.Player:AddSlider("SpinSpeed",{Title="Spin Speed",Default=22,Min=5,Max=80,Rounding=0,Callback=function(v) spinSpeed=v end})
local spectateEnabled=false
Tabs.Player:AddToggle("Spectate",{Title="Spectate Closest",Default=false,Callback=function(v) spectateEnabled=v if not v then Camera.CameraSubject=getHumanoid() end end})

------------------------------------------------
-- TROLL
------------------------------------------------
local flingPower=500
local flingConn=nil
local flingTarget=nil
local orbitEnabled=false
local orbitConn=nil
local orbitSpeed=3
local attachEnabled=false
local attachConn=nil

local function flingPlayer(plr)
    local c=getCharacter() local root=getRoot() if not c or not root then return end
    local targetChar=plr and plr.Character local targetRoot=targetChar and targetChar:FindFirstChild("HumanoidRootPart") if not targetRoot then Fluent:Notify({Title="Fling",Content="Target not found",Duration=2}) return end
    flingTarget=plr
    Fluent:Notify({Title="Fling",Content="Flinging "..plr.Name,Duration=3})
    if flingConn then flingConn:Disconnect() end
    local bv=Instance.new("BodyAngularVelocity") bv.Name="MoonFling" bv.MaxTorque=Vector3.new(9e9,9e9,9e9) bv.AngularVelocity=Vector3.new(0,flingPower,0) bv.P=9e4 bv.Parent=root
    local start=Workspace.DistributedGameTime
    flingConn=RunService.Heartbeat:Connect(function()
        if not flingTarget or not flingTarget.Character or not flingTarget.Character:FindFirstChild("HumanoidRootPart") then if bv then bv:Destroy() end if flingConn then flingConn:Disconnect() flingConn=nil end return end
        if Workspace.DistributedGameTime-start>3 then bv:Destroy() if flingConn then flingConn:Disconnect() flingConn=nil end return end
        local tr=flingTarget.Character.HumanoidRootPart
        root.CFrame=tr.CFrame * CFrame.new(0,0,1)
        root.Velocity=Vector3.new(0,0,0)
    end)
    task.delay(3.5,function() if bv and bv.Parent then bv:Destroy() end root.Velocity=Vector3.new(0,0,0) end)
end

Tabs.Troll:AddInput("FlingPlayer",{Title="Fling Target",Placeholder="Username",Callback=function() end})
Tabs.Troll:AddSlider("FlingPower",{Title="Fling Power",Default=500,Min=100,Max=2000,Rounding=0,Callback=function(v) flingPower=v end})
Tabs.Troll:AddButton({Title="Fling Player",Callback=function() local p=findPlayer(Options.FlingPlayer.Value) if p then flingPlayer(p) end end})
Tabs.Troll:AddButton({Title="Fling All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then flingPlayer(p) task.wait(3.6) end end end})

Tabs.Troll:AddToggle("Orbit",{Title="Orbit Player",Default=false,Callback=function(v)
    orbitEnabled=v
    if v then
        local tgt=findPlayer(Options.FlingPlayer.Value) or getClosest() and getClosest().Parent and Players:GetPlayerFromCharacter(getClosest().Parent) or nil
        if not tgt then Fluent:Notify({Title="Orbit",Content="No target",Duration=2}) return end
        local angle=0
        orbitConn=RunService.Heartbeat:Connect(function(dt)
            local c=getCharacter() local r=getRoot() local tc=tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") if not r or not tc then return end
            angle+=dt*orbitSpeed
            local offset=Vector3.new(math.cos(angle)*6,1,math.sin(angle)*6)
            r.CFrame=CFrame.new(tc.Position+offset, tc.Position)
        end)
    else if orbitConn then orbitConn:Disconnect() orbitConn=nil end end
end})
Tabs.Troll:AddSlider("OrbitSpeed",{Title="Orbit Speed",Default=3,Min=1,Max=10,Rounding=1,Callback=function(v) orbitSpeed=v end})

Tabs.Troll:AddToggle("Attach",{Title="Attach to Player",Default=false,Callback=function(v)
    attachEnabled=v
    if v then
        local tgt=findPlayer(Options.FlingPlayer.Value)
        if not tgt or not tgt.Character then Fluent:Notify({Title="Attach",Content="Target not found",Duration=2}) return end
        attachConn=RunService.Heartbeat:Connect(function()
            local r=getRoot() local tr=tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") if r and tr then r.CFrame=tr.CFrame * CFrame.new(0,2,0) end
        end)
    else if attachConn then attachConn:Disconnect() attachConn=nil end end
end})
Tabs.Troll:AddButton({Title="Detach",Callback=function() attachEnabled=false if attachConn then attachConn:Disconnect() attachConn=nil end orbitEnabled=false if orbitConn then orbitConn:Disconnect() orbitConn=nil end if flingConn then flingConn:Disconnect() flingConn=nil end local bv=getRoot() and getRoot():FindFirstChild("MoonFling") if bv then bv:Destroy() end end})

------------------------------------------------
-- UTILITY
------------------------------------------------
Tabs.Utility:AddSection("Teleport")
Tabs.Utility:AddToggle("ClickTP",{Title="Click TP Tool",Default=false,Callback=function(v)
    if v then local t=Instance.new("Tool") t.Name="Moon TP" t.RequiresHandle=false t.CanBeDropped=false t.Parent=LocalPlayer.Backpack t.Activated:Connect(function() local m=LocalPlayer:GetMouse() local r=getRoot() if m.Hit and r then r.CFrame=CFrame.new(m.Hit.Position+Vector3.new(0,3,0)) end end) getgenv().MoonTP=t
    else if getgenv().MoonTP then getgenv().MoonTP:Destroy() end local bp=LocalPlayer:FindFirstChild("Backpack") if bp then for _,x in ipairs(bp:GetChildren()) do if x.Name=="Moon TP" then x:Destroy() end end end local c=getCharacter() if c then for _,x in ipairs(c:GetChildren()) do if x.Name=="Moon TP" then x:Destroy() end end end end
end})
Tabs.Utility:AddInput("TPPlayer",{Title="Teleport to Player",Placeholder="Username",Callback=function() end})
Tabs.Utility:AddButton({Title="Teleport",Callback=function() local plr=findPlayer(Options.TPPlayer.Value) local target=plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") local root=getRoot() if target and root then root.CFrame=target.CFrame+Vector3.new(0,2,0) else Fluent:Notify({Title="Teleport",Content="Player not found",Duration=3}) end end})
Tabs.Utility:AddSection("Server")
Tabs.Utility:AddButton({Title="Rejoin Server",Callback=function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,LocalPlayer) end})
Tabs.Utility:AddButton({Title="Server Hop",Callback=function() local s=game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100") local d=game:GetService("HttpService"):JSONDecode(s) for _,sv in ipairs(d.data) do if sv.id~=game.JobId and sv.playing<sv.maxPlayers then TeleportService:TeleportToPlaceInstance(game.PlaceId,sv.id,LocalPlayer) return end end Fluent:Notify({Title="Server Hop",Content="No servers",Duration=3}) end})
Tabs.Utility:AddButton({Title="Copy JobId",Callback=function() if setclipboard then setclipboard(game.JobId) Fluent:Notify({Title="Copied",Content=game.JobId,Duration=3}) end end})
Tabs.Utility:AddButton({Title="FPS Boost",Callback=function() for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material=Enum.Material.SmoothPlastic v.Reflectance=0 elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1 elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled=false end end Lighting.GlobalShadows=false Fluent:Notify({Title="Optimization",Content="FPS Boost",Duration=3}) end})

------------------------------------------------
-- SETTINGS
------------------------------------------------
Tabs.Settings:AddDropdown("Language",{Title="Language",Values={"EN","UA","BY","KZ"},Default=1,Callback=function(v)
    local map={EN="en",UA="uk",BY="be",KZ="kk"}
    local code=map[v] or "en"
    applyLang(code)
end})

pcall(function()
    if InterfaceManager and SaveManager then
        InterfaceManager:SetLibrary(Fluent)
        SaveManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        InterfaceManager:SetFolder("MoonHub")
        SaveManager:SetFolder("MoonHub/config")
        SaveManager:BuildConfigSection(Tabs.Settings)
        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:LoadAutoloadConfig()
    end
end)
pcall(function() Window:SelectTab(1) end)
RunService.RenderStepped:Connect(function()
    if speedEnabled then local h=getHumanoid() if h then h.WalkSpeed=speedValue end end
    if spectateEnabled then local t=getClosest() if t and t.Parent and t.Parent:FindFirstChildOfClass("Humanoid") then Camera.CameraSubject=t.Parent:FindFirstChildOfClass("Humanoid") end end
    if fovCircle then fovCircle.Visible=showFOV and aimEnabled fovCircle.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2) fovCircle.Radius=fovRadius end
    if aimEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then local target=getClosest() if target then local pos,onScreen=Camera:WorldToViewportPoint(target.Position) if onScreen then local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2) local delta=Vector2.new(pos.X,pos.Y)-center if mousemoverel then mousemoverel(delta.X,delta.Y) end end end end
    updateESP()
end)
LocalPlayer.Idled:Connect(function() if antiAFK then VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end end)
Fluent:Notify({Title="MoonHub",Content="Amethyst theme  •  Bold text  •  LeftControl to hide",Duration=5})
