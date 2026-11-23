-- Wisteria Hub v3.2: catalog-limited horn previews and reversible cosmetic tools.
-- No remote downloads or inventory actions; executor mouse support is optional.
warn("[Wisteria Hub] v3.2 starting")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local parent = player:WaitForChild("PlayerGui")
local environment=(type(getgenv)=="function" and getgenv()) or _G
if type(environment.PurrvotionCleanup)=="function" then pcall(environment.PurrvotionCleanup) end
local liveConnections={}
local function track(connection)
    table.insert(liveConnections,connection)
    return connection
end

do
local old = parent:FindFirstChild("PurrvotionMenu")
if old then old:Destroy() end
local oldRain = parent:FindFirstChild("PurrvotionRain")
if oldRain then oldRain:Destroy() end
local oldToggle = parent:FindFirstChild("PurrvotionToggle")
if oldToggle then oldToggle:Destroy() end
local oldQuick = parent:FindFirstChild("PurrvotionQuickbar")
if oldQuick then oldQuick:Destroy() end
local oldMoon = parent:FindFirstChild("PurrvotionMoon")
if oldMoon then oldMoon:Destroy() end
local oldButterflies = parent:FindFirstChild("PurrvotionButterflies")
if oldButterflies then oldButterflies:Destroy() end
end

local presets = {
    Mono = Color3.fromRGB(245, 245, 245),
    Black = Color3.fromRGB(45,45,45),
    Silver = Color3.fromRGB(185,191,204),
    Lavender = Color3.fromRGB(191,157,255),
    Burgundy = Color3.fromRGB(145,41,74),
    Cyan = Color3.fromRGB(84,220,238),
    Emerald = Color3.fromRGB(78,199,141),
    Gold = Color3.fromRGB(242,199,104),
    Peach = Color3.fromRGB(255,179,143),
    Purple = Color3.fromRGB(168, 85, 247),
    Blue = Color3.fromRGB(96, 165, 250),
    Red = Color3.fromRGB(239, 68, 68),
    Pink = Color3.fromRGB(244, 114, 182),
}
local accent = presets.Mono
local performanceMode=false
local adaptiveReduced=false
local function isPerformanceActive() return performanceMode or adaptiveReduced end
local controls = {}
local quickStroke
local esp = {enabled=false, highlight=true, names=true, distance=true, health=true, maxDistance=1000}
local visuals = {}
local hitbox = {enabled=false, size=5, transparency=1, color=Color3.fromRGB(0,102,255)}
local originalHitboxes = {}
local function restoreHitbox(part)
    local saved=originalHitboxes[part]
    if not saved then return end
    if part.Parent then
        pcall(function()
            part.Size=saved.Size
            part.Transparency=saved.Transparency
            part.Color=saved.Color
            part.Material=saved.Material
            part.CanCollide=saved.CanCollide
        end)
    end
    originalHitboxes[part]=nil
end
local function restoreAllHitboxes()
    for part in pairs(originalHitboxes) do restoreHitbox(part) end
end
local function refreshHitboxes()
    if not hitbox.enabled then restoreAllHitboxes(); return end
    local active={}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr~=player and plr.Character then
            local root=plr.Character:FindFirstChild("HumanoidRootPart")
            local humanoid=plr.Character:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health>0 then
                active[root]=true
                if not originalHitboxes[root] then
                    originalHitboxes[root]={Size=root.Size,Transparency=root.Transparency,Color=root.Color,Material=root.Material,CanCollide=root.CanCollide}
                end
                pcall(function()
                    root.Size=Vector3.new(hitbox.size,hitbox.size,hitbox.size)
                    root.Transparency=hitbox.transparency
                    root.Color=hitbox.color
                    root.Material=Enum.Material.SmoothPlastic
                    root.CanCollide=false
                end)
            end
        end
    end
    for part in pairs(originalHitboxes) do
        if not active[part] then restoreHitbox(part) end
    end
end
local function new(class, props, parentToUse)
    local obj = Instance.new(class)
    for name, value in pairs(props) do obj[name] = value end
    obj.Parent = parentToUse
    return obj
end

local gui = new("ScreenGui", {Name="PurrvotionMenu", ResetOnSpawn=false, DisplayOrder=5, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, parent)
local panel = new("Frame", {Size=UDim2.fromOffset(600,440), Position=UDim2.new(.5,-300,.5,-220), BackgroundColor3=Color3.fromRGB(12,12,12), BackgroundTransparency=.1, BorderSizePixel=0, Active=true}, gui)
new("UICorner", {CornerRadius=UDim.new(0,15)}, panel)
local stroke = new("UIStroke", {Color=accent, Thickness=1}, panel)

local bar = new("Frame", {Size=UDim2.new(1,0,0,46), BackgroundTransparency=1, Active=true}, panel)
new("TextLabel", {Size=UDim2.new(1,-100,1,0), Position=UDim2.fromOffset(16,0), BackgroundTransparency=1, Text="✦  Wisteria Hub  ·  v3.2", TextColor3=Color3.new(1,1,1), TextSize=18, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left}, bar)
do
local close = new("TextButton", {Size=UDim2.fromOffset(30,28), Position=UDim2.new(1,-40,0,9), Text="×", TextSize=22, TextColor3=Color3.new(1,1,1), BackgroundColor3=Color3.fromRGB(36,36,36)}, bar)
new("UICorner", {CornerRadius=UDim.new(0,6)}, close)
close.MouseButton1Click:Connect(function() gui.Enabled = false end)
end
-- This button is in its own ScreenGui so it stays visible when the menu is hidden.
local toggleGui=new("ScreenGui",{Name="PurrvotionToggle",ResetOnSpawn=false,DisplayOrder=6},parent)
do
local menuToggle=new("TextButton",{
    Name="OpenMenu",Size=UDim2.fromOffset(84,34),Position=UDim2.fromOffset(14,190),
    BackgroundColor3=Color3.fromRGB(15,15,15),BackgroundTransparency=.1,BorderSizePixel=0,
    Text="♛  Menu",TextColor3=Color3.fromRGB(245,245,245),TextSize=13,Font=Enum.Font.GothamBold,
},toggleGui)
new("UICorner",{CornerRadius=UDim.new(0,9)},menuToggle)
new("UIStroke",{Color=Color3.fromRGB(145,145,145),Thickness=1},menuToggle)
menuToggle.MouseButton1Click:Connect(function() gui.Enabled=not gui.Enabled end)
end

local sidebar = new("Frame", {Position=UDim2.fromOffset(12,54), Size=UDim2.new(0,150,1,-66), BackgroundColor3=Color3.fromRGB(22,22,22), BorderSizePixel=0}, panel)
new("UICorner", {CornerRadius=UDim.new(0,7)}, sidebar)
new("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder}, sidebar)
local menuSearch=new("TextBox", {Size=UDim2.new(1,-12,0,35),LayoutOrder=-10,BackgroundColor3=Color3.fromRGB(35,35,35),BorderSizePixel=0,Text="",PlaceholderText="⌕ Search tabs",TextColor3=Color3.new(1,1,1),PlaceholderColor3=Color3.fromRGB(160,160,160),TextSize=13,Font=Enum.Font.Gotham,ClearTextOnFocus=false},sidebar)
new("UICorner",{CornerRadius=UDim.new(0,7)},menuSearch)
local content = new("ScrollingFrame", {Position=UDim2.fromOffset(174,54), Size=UDim2.new(1,-186,1,-66), BackgroundColor3=Color3.fromRGB(20,20,20), BorderSizePixel=0, ScrollBarThickness=3, CanvasSize=UDim2.fromOffset(0,0)}, panel)
new("UICorner", {CornerRadius=UDim.new(0,7)}, content)
local layout = new("UIListLayout", {Padding=UDim.new(0,9), SortOrder=Enum.SortOrder.LayoutOrder}, content)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() content.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+18) end)
local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if child ~= layout and not child:IsA("UICorner") then child:Destroy() end
    end
end
local function label(text, height)
    return new("TextLabel", {Size=UDim2.new(1,-20,0,height or 32), BackgroundTransparency=1, Text=text, TextWrapped=true, TextColor3=Color3.fromRGB(225,225,225), TextSize=13, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left}, content)
end
local function button(text, callback)
    local b = new("TextButton", {Size=UDim2.new(1,-20,0,35), BackgroundColor3=Color3.fromRGB(43,43,43), Text=text, TextColor3=Color3.new(1,1,1), TextSize=13, Font=Enum.Font.GothamMedium}, content)
    new("UICorner", {CornerRadius=UDim.new(0,6)}, b)
    b.MouseButton1Click:Connect(callback)
    return b
end
local function updateAccent()
    stroke.Color = accent
    if quickStroke and quickStroke.Parent then quickStroke.Color=accent end
    for _, b in ipairs(controls) do if b.Parent then b.TextColor3=accent end end
    for _, entry in pairs(visuals) do
        if entry.highlight then
            entry.highlight.FillColor = accent
            entry.highlight.OutlineColor = accent
        end
        if entry.label then entry.label.TextColor3 = accent end
    end
end
local function cleanupVisual(plr)
    local entry=visuals[plr]
    if not entry then return end
    if entry.highlight then entry.highlight:Destroy() end
    if entry.billboard then entry.billboard:Destroy() end
    visuals[plr]=nil
end
local function refreshVisuals()
    if not esp.enabled then
        for plr in pairs(visuals) do cleanupVisual(plr) end
        return
    end
    local ownCharacter=player.Character
    local ownPosition=ownCharacter and ownCharacter:FindFirstChild("HumanoidRootPart")
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr~=player then
            local character=plr.Character
            local head=character and character:FindFirstChild("Head")
            local root=character and character:FindFirstChild("HumanoidRootPart")
            local distance=root and ownPosition and (root.Position-ownPosition.Position).Magnitude or math.huge
            local visible=esp.enabled and head and distance<=esp.maxDistance
            if not visible then
                cleanupVisual(plr)
            else
                local entry=visuals[plr]
                if entry and entry.character~=character then cleanupVisual(plr); entry=nil end
                if not entry then entry={character=character}; visuals[plr]=entry end
                if esp.highlight and not entry.highlight then
                    entry.highlight=new("Highlight", {Name="PurrvotionHighlight", FillColor=accent, FillTransparency=.8, OutlineColor=accent, OutlineTransparency=0, DepthMode=Enum.HighlightDepthMode.AlwaysOnTop}, character)
                elseif not esp.highlight and entry.highlight then entry.highlight:Destroy(); entry.highlight=nil end
                if (esp.names or esp.distance or esp.health) and not entry.billboard then
                    entry.billboard=new("BillboardGui", {Name="PurrvotionESP", Adornee=head, Size=UDim2.fromOffset(220,48), StudsOffsetWorldSpace=Vector3.new(0,2.8,0), AlwaysOnTop=true, ResetOnSpawn=false}, gui)
                    entry.label=new("TextLabel", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextSize=13, TextStrokeTransparency=.35, TextColor3=accent}, entry.billboard)
                elseif not (esp.names or esp.distance or esp.health) and entry.billboard then
                    entry.billboard:Destroy(); entry.billboard=nil; entry.label=nil
                end
                if entry.billboard then entry.billboard.Adornee=head end
                if entry.label then
                    local parts={}
                    if esp.names then table.insert(parts,plr.DisplayName) end
                    if esp.distance then table.insert(parts,string.format("%d studs",math.floor(distance))) end
                    if esp.health then
                        local humanoid=character:FindFirstChildOfClass("Humanoid")
                        if humanoid then table.insert(parts,string.format("%d HP",math.ceil(humanoid.Health))) end
                    end
                    entry.label.Text=table.concat(parts,"  |  ")
                end
            end
        end
    end
end
track(Players.PlayerRemoving:Connect(cleanupVisual))
local hitboxElapsed=0
track(RunService.Heartbeat:Connect(function(dt)
    hitboxElapsed+=dt
    if hitboxElapsed>=(isPerformanceActive() and .20 or .10) then
        hitboxElapsed=0
        if hitbox.enabled or next(originalHitboxes) then refreshHitboxes() end
    end
end))
local tabs = {}
local pageOpeners={}
menuSearch:GetPropertyChangedSignal("Text"):Connect(function()
    local query=menuSearch.Text:lower()
    for _, tab in ipairs(tabs) do tab.Visible=query=="" or tab.Text:lower():find(query,1,true)~=nil end
end)
local function page(name, draw)
    local tab = new("TextButton", {Size=UDim2.new(1,-12,0,38), BackgroundColor3=Color3.fromRGB(22,22,22), BorderSizePixel=0, Text=name, TextColor3=Color3.fromRGB(205,205,205), Font=Enum.Font.GothamMedium, TextSize=13}, sidebar)
    table.insert(tabs, tab)
    local function open()
        clearContent()
        for _, item in ipairs(tabs) do item.TextColor3=Color3.fromRGB(205,205,205) end
        tab.TextColor3=accent
        draw()
    end
    pageOpeners[name]=open
    tab.MouseButton1Click:Connect(open)
    return tab
end

-- Keep optional feature state together to stay under Luau's active-local limit.
local opt={}
opt.selectedTarget=nil
opt.autoTargetEnabled=true
local autoTarget
opt.holdMode=true
opt.holdKey="V"
opt.holdActive=false
opt.wasHolding=false
opt.lockedTarget=nil
opt.targetFov=160
opt.targetMaxDistance=700
opt.showTargetFov=false
opt.aimPart="Head"
opt.smoothAssistEnabled=false
opt.aimMode="Gentle"
opt.assistStrength=0.12
opt.assistMaxStep=6
opt.aimDeadzone=4
opt.targetSwitchKey="B"
opt.targetSwitchRequested=false
opt.autoSwitchLost=false
opt.targetLostElapsed=0
opt.assistAccumulator=Vector2.zero
opt.mouseMoveAvailable=type(mousemoverel)=="function"
local function aimCursor(camera)
    if UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter then
        local inset=GuiService:GetGuiInset()
        return camera.ViewportSize/2+inset
    end
    return UserInputService:GetMouseLocation()
end
local ownRoot
local targetIndicator=new("TextLabel",{Name="SelectedTarget",Position=UDim2.new(.5,-125,0,65),Size=UDim2.fromOffset(250,30),BackgroundColor3=Color3.fromRGB(12,12,12),BackgroundTransparency=.2,Text="Target: none",TextColor3=accent,TextSize=14,Font=Enum.Font.GothamBold,Visible=false},gui)
new("UICorner",{CornerRadius=UDim.new(0,8)},targetIndicator)
local fovRing=new("Frame",{Name="TargetFOV",AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(opt.targetFov*2,opt.targetFov*2),BackgroundTransparency=1,Visible=false},gui)
new("UICorner",{CornerRadius=UDim.new(1,0)},fovRing)
new("UIStroke",{Color=accent,Thickness=1,Transparency=.35},fovRing)
local trackingReticle=new("Frame",{Name="TrackingReticle",AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(24,24),BackgroundTransparency=1,Visible=false},gui)
new("UICorner",{CornerRadius=UDim.new(1,0)},trackingReticle)
new("UIStroke",{Color=accent,Thickness=2},trackingReticle)
local function matchesHoldInput(input)
    if opt.holdKey=="RightMouse" then return input.UserInputType==Enum.UserInputType.MouseButton2 end
    return input.KeyCode.Name==opt.holdKey
end
track(UserInputService.InputBegan:Connect(function(input,processed)
    if not processed and matchesHoldInput(input) then opt.holdActive=true end
end))
track(UserInputService.InputEnded:Connect(function(input)
    if matchesHoldInput(input) then opt.holdActive=false; opt.lockedTarget=nil;opt.targetLostElapsed=0 end
end))
track(UserInputService.InputBegan:Connect(function(input,processed)
    if not processed and input.KeyCode.Name==opt.targetSwitchKey and opt.holdActive then
        opt.targetSwitchRequested=true
    end
end))
local function pickCrosshairTarget(camera)
    -- In third person, select relative to the visible cursor, not Shift Lock.
    local center=aimCursor(camera)
    -- Narrow acquisition prevents grabbing unrelated players near the cursor.
    local best,bestDistance=nil,math.min(opt.targetFov,100)
    local own=ownRoot()
    for _, other in ipairs(Players:GetPlayers()) do
        if other~=player and other.Character then
            local humanoid=other.Character:FindFirstChildOfClass("Humanoid")
            local part=other.Character:FindFirstChild(opt.aimPart)
            if humanoid and humanoid.Health>0 and part and (not own or (part.Position-own.Position).Magnitude<=opt.targetMaxDistance) then
                local screenPoint,onScreen=camera:WorldToScreenPoint(part.Position)
                if onScreen and screenPoint.Z>0 then
                    local distance=(Vector2.new(screenPoint.X,screenPoint.Y)-center).Magnitude
                    if distance<bestDistance then best,bestDistance=other,distance end
                end
            end
        end
    end
    return best
end
local function switchCrosshairTarget(camera,current)
    local center=aimCursor(camera)
    local choices={}
    local own=ownRoot()
    for _,other in ipairs(Players:GetPlayers()) do
        if other~=player and other.Character then
            local hum=other.Character:FindFirstChildOfClass("Humanoid")
            local part=other.Character:FindFirstChild(opt.aimPart)
            if hum and hum.Health>0 and part and (not own or (part.Position-own.Position).Magnitude<=opt.targetMaxDistance) then
                local point,visible=camera:WorldToScreenPoint(part.Position)
                if visible and point.Z>0 then
                    local distance=(Vector2.new(point.X,point.Y)-center).Magnitude
                    if distance<=opt.targetFov then table.insert(choices,{player=other,distance=distance}) end
                end
            end
        end
    end
    table.sort(choices,function(a,b) return a.distance<b.distance end)
    for i,choice in ipairs(choices) do
        if choice.player==current then return choices[i%#choices+1].player end
    end
    return choices[1] and choices[1].player or nil
end
local function targetStillValid(target)
    if not target or not target.Character then return false end
    local humanoid=target.Character:FindFirstChildOfClass("Humanoid")
    local part=target.Character:FindFirstChild(opt.aimPart)
    local root=ownRoot()
    return humanoid~=nil and humanoid.Health>0 and part~=nil
        and (not root or (part.Position-root.Position).Magnitude<=opt.targetMaxDistance)
end
opt.flyEnabled=false
opt.flySpeed=45
local MAX_FLIGHT_SPEED=300
opt.flightHover=true
opt.fakeMacroEnabled=false
opt.fakeMacroSpeed=38
opt.macroTapWindow=.35
opt.lastMacroTap=0
local flyVelocity, flyGyro
opt.speedEnabled=false
opt.walkSpeed=24
opt.savedWalkSpeed=nil
opt.noclipEnabled=false
local originalCollisions={}
local shopBookmarks={}
opt.previousTeleportPosition=nil
local teleportHistory={}
local favoriteShops={}
local settingsProfiles={}
local savedSkies={}
opt.menuKeyName="P"
opt.flyKeyName="None"
opt.quickWheelKey="G"
opt.minimalHudKey="H"
opt.minimalHud=false
opt.quickWheelVisible=false
opt.compactMenu=false
opt.menuScale=1
opt.menuTransparency=.1
opt.selectedMovementPreset="Custom"
opt.weatherPreset="Normal"
opt.rainEnabled=false
opt.heavyRain=false
opt.rainIntensity=2
opt.rainSpeed=1
opt.splashesEnabled=true
opt.puddlesEnabled=false
opt.windStrength=0
opt.particleEnabled=false
opt.particleDensity=2
opt.particleSize=1
opt.particleSpeed=1
opt.particleColor=Color3.fromRGB(189,166,255)
opt.particleStyle="Sparkles"
opt.snowfallEnabled=false
opt.petalsEnabled=false
opt.thunderEnabled=false
opt.shootingStarsEnabled=false
opt.customNightBrightness=.15
opt.dayNightCycle=false
opt.dayNightCycleMinutes=12
opt.weatherPreviewName=nil
opt.rainColor=Color3.fromRGB(210,217,227)
opt.customSkyColor=nil
opt.storedWeatherSettings=nil
local captureWeather
opt.filterMode="None"
opt.starsEnabled=false
opt.moonEnabled=false
local butterfliesEnabled=false -- legacy setting ignored: butterfly assets were unreliable
local butterflyIntensity=2
opt.firefliesEnabled=false
opt.hideEffectsEnabled=false
opt.smoothTransitionsEnabled=true
local moonTintColor=Color3.new(1,1,1)
local moonTintName="White"
opt.adaptivePerfEnabled=false
opt.quickToolbarEnabled=true
local quickGui
local quickFrame
local quickPosition={1,-400,0,108}
opt.menuBackgroundStyle="Midnight"
opt.menuCustomColor=Color3.fromRGB(28,28,28)
local saveFile="purrvotion_settings_"..tostring(game.PlaceId)..".json"
local saveAvailable=type(writefile)=="function" and type(readfile)=="function"
local function savePreferences()
    if not saveAvailable then return false end
    local bookmarks={}
    for name,cf in pairs(shopBookmarks) do bookmarks[name]={cf:GetComponents()} end
    local payload={bookmarks=bookmarks,hitboxSize=hitbox.size,hitboxTransparency=hitbox.transparency,
        hitboxColor={math.floor(hitbox.color.R*255+.5),math.floor(hitbox.color.G*255+.5),math.floor(hitbox.color.B*255+.5)},
        hitboxEnabled=hitbox.enabled,aim={enabled=opt.autoTargetEnabled,hold=opt.holdMode,key=opt.holdKey,mode=opt.aimMode,switchPolicy=opt.autoSwitchLost and "auto" or "manual",
            fov=opt.targetFov,distance=opt.targetMaxDistance,part=opt.aimPart,smooth=opt.smoothAssistEnabled,
            strength=opt.assistStrength,maxStep=opt.assistMaxStep,deadzone=opt.aimDeadzone,switchKey=opt.targetSwitchKey},
        accent={math.floor(accent.R*255+.5),math.floor(accent.G*255+.5),math.floor(accent.B*255+.5)},
        favoriteShops=favoriteShops,profiles=settingsProfiles,savedSkies=savedSkies,
        weather=captureWeather and captureWeather() or opt.storedWeatherSettings,
        movement={fly=opt.flySpeed,walk=opt.walkSpeed,preset=opt.selectedMovementPreset,hover=opt.flightHover,
            macroSpeed=opt.fakeMacroSpeed,macroWindow=opt.macroTapWindow},
        keybinds={menu=opt.menuKeyName,fly=opt.flyKeyName,wheel=opt.quickWheelKey,hud=opt.minimalHudKey},
        compact=opt.compactMenu,menuScale=opt.menuScale,menuTransparency=opt.menuTransparency,performance=performanceMode,
        hideEffects=opt.hideEffectsEnabled,adaptive=opt.adaptivePerfEnabled,quickToolbar=opt.quickToolbarEnabled,
        quickPosition=quickPosition,
        smoothWeather=opt.smoothTransitionsEnabled,background=opt.menuBackgroundStyle,
        backgroundColor={math.floor(opt.menuCustomColor.R*255+.5),math.floor(opt.menuCustomColor.G*255+.5),math.floor(opt.menuCustomColor.B*255+.5)}}
    return pcall(function() writefile(saveFile,HttpService:JSONEncode(payload)) end)
end
local function loadPreferences()
    if not saveAvailable then return end
    local ok,data=pcall(function() return HttpService:JSONDecode(readfile(saveFile)) end)
    if not ok or type(data)~="table" then return end
    if type(data.bookmarks)=="table" then
        for name,components in pairs(data.bookmarks) do
            if type(name)=="string" and type(components)=="table" and #components==12 then
                local valid=true
                for _,v in ipairs(components) do if type(v)~="number" then valid=false; break end end
                if valid then
                    local success,cf=pcall(function() return CFrame.new(table.unpack(components)) end)
                    if success then shopBookmarks[name]=cf end
                end
            end
        end
    end
    if type(data.hitboxSize)=="number" then hitbox.size=math.clamp(data.hitboxSize,2,20) end
    if data.hitboxTransparency==1 or data.hitboxTransparency==.5 then hitbox.transparency=data.hitboxTransparency end
    if type(data.hitboxColor)=="table" and #data.hitboxColor==3 then
        local r,g,b=table.unpack(data.hitboxColor)
        if type(r)=="number" and type(g)=="number" and type(b)=="number" then
            hitbox.color=Color3.fromRGB(math.clamp(r,0,255),math.clamp(g,0,255),math.clamp(b,0,255))
        end
    end
    hitbox.enabled=data.hitboxEnabled==true
    if type(data.aim)=="table" then
        opt.autoTargetEnabled=data.aim.enabled~=false
        opt.holdMode=data.aim.hold~=false
        if type(data.aim.key)=="string" and (Enum.KeyCode[data.aim.key] or data.aim.key=="RightMouse") then opt.holdKey=data.aim.key end
        if opt.holdKey=="C" then opt.holdKey="V" end -- C is reserved for the double-tap macro
        if type(data.aim.fov)=="number" then opt.targetFov=math.clamp(data.aim.fov,25,450) end
        if type(data.aim.distance)=="number" then opt.targetMaxDistance=math.clamp(data.aim.distance,50,2000) end
        if data.aim.part=="Head" or data.aim.part=="HumanoidRootPart" then opt.aimPart=data.aim.part end
        if data.aim.mode=="Mouse" or data.aim.mode=="Gentle" then opt.aimMode=data.aim.mode end
        opt.autoSwitchLost=data.aim.switchPolicy=="auto"
        opt.smoothAssistEnabled=data.aim.smooth==true
        if type(data.aim.strength)=="number" then opt.assistStrength=math.clamp(data.aim.strength,.01,.5) end
        if type(data.aim.maxStep)=="number" then opt.assistMaxStep=math.clamp(data.aim.maxStep,1,15) end
        if type(data.aim.deadzone)=="number" then opt.aimDeadzone=math.clamp(data.aim.deadzone,0,35) end
        if type(data.aim.switchKey)=="string" and Enum.KeyCode[data.aim.switchKey] then opt.targetSwitchKey=data.aim.switchKey end
    end
    if type(data.accent)=="table" and #data.accent==3 then
        local r,g,b=table.unpack(data.accent)
        if type(r)=="number" and type(g)=="number" and type(b)=="number" then
            accent=Color3.fromRGB(math.clamp(r,0,255),math.clamp(g,0,255),math.clamp(b,0,255))
            updateAccent()
        end
    end
    if type(data.favoriteShops)=="table" then favoriteShops=data.favoriteShops end
    if type(data.profiles)=="table" then settingsProfiles=data.profiles end
    if type(data.savedSkies)=="table" then savedSkies=data.savedSkies end
    if type(data.weather)=="table" then opt.storedWeatherSettings=data.weather end
    if type(data.movement)=="table" then
        if type(data.movement.fly)=="number" then opt.flySpeed=math.clamp(data.movement.fly,10,MAX_FLIGHT_SPEED) end
        if type(data.movement.walk)=="number" then opt.walkSpeed=math.clamp(data.movement.walk,16,100) end
        opt.flightHover=data.movement.hover~=false
        if type(data.movement.macroSpeed)=="number" then opt.fakeMacroSpeed=math.clamp(data.movement.macroSpeed,16,90) end
        if type(data.movement.macroWindow)=="number" then opt.macroTapWindow=math.clamp(data.movement.macroWindow,.2,.7) end
        opt.selectedMovementPreset=tostring(data.movement.preset or "Custom")
    end
    if type(data.keybinds)=="table" then
        if type(data.keybinds.menu)=="string" and Enum.KeyCode[data.keybinds.menu] and data.keybinds.menu~="RightShift" then opt.menuKeyName=data.keybinds.menu end
        if type(data.keybinds.fly)=="string" and (Enum.KeyCode[data.keybinds.fly] or data.keybinds.fly=="None") then opt.flyKeyName=data.keybinds.fly end
        if opt.flyKeyName==opt.menuKeyName then opt.flyKeyName="None" end
        if type(data.keybinds.wheel)=="string" and Enum.KeyCode[data.keybinds.wheel] then opt.quickWheelKey=data.keybinds.wheel end
        if type(data.keybinds.hud)=="string" and Enum.KeyCode[data.keybinds.hud] then opt.minimalHudKey=data.keybinds.hud end
    end
    opt.compactMenu=data.compact==true
    if type(data.menuScale)=="number" then opt.menuScale=math.clamp(data.menuScale,.7,1.25) end
    if type(data.menuTransparency)=="number" then opt.menuTransparency=math.clamp(data.menuTransparency,0,.55) end
    performanceMode=data.performance==true
    opt.hideEffectsEnabled=data.hideEffects==true
    opt.adaptivePerfEnabled=data.adaptive==true
    opt.quickToolbarEnabled=data.quickToolbar~=false
    if type(data.quickPosition)=="table" and #data.quickPosition==4 then
        local valid=true
        for _,n in ipairs(data.quickPosition) do if type(n)~="number" then valid=false end end
        if valid then quickPosition=data.quickPosition end
    end
    opt.smoothTransitionsEnabled=data.smoothWeather~=false
    if type(data.background)=="string" then opt.menuBackgroundStyle=data.background end
    if type(data.backgroundColor)=="table" and #data.backgroundColor==3 then
        local r,g,b=table.unpack(data.backgroundColor)
        if type(r)=="number" and type(g)=="number" and type(b)=="number" then
            opt.menuCustomColor=Color3.fromRGB(math.clamp(r,0,255),math.clamp(g,0,255),math.clamp(b,0,255))
        end
    end
end
loadPreferences()
local function applyMenuBackground()
    local styles={
        Midnight={Color3.fromRGB(12,12,12),Color3.fromRGB(22,22,22),Color3.fromRGB(20,20,20),.10},
        Glass={Color3.fromRGB(31,34,42),Color3.fromRGB(29,32,39),Color3.fromRGB(23,27,36),.33},
        Charcoal={Color3.fromRGB(38,38,38),Color3.fromRGB(28,28,28),Color3.fromRGB(34,34,34),.04},
        Plum={Color3.fromRGB(29,13,32),Color3.fromRGB(37,20,40),Color3.fromRGB(26,14,31),.08},
    }
    local selected=styles[opt.menuBackgroundStyle]
    if not selected then
        local darkened=opt.menuCustomColor:Lerp(Color3.new(0,0,0),.62)
        selected={darkened,darkened:Lerp(Color3.new(0,0,0),.25),darkened:Lerp(Color3.new(0,0,0),.18),.12}
    end
    panel.BackgroundColor3=selected[1]
    panel.BackgroundTransparency=opt.menuTransparency
    sidebar.BackgroundColor3=selected[2]
    sidebar.BackgroundTransparency=opt.menuBackgroundStyle=="Glass" and .20 or 0
    content.BackgroundColor3=selected[3]
    content.BackgroundTransparency=opt.menuBackgroundStyle=="Glass" and .15 or 0
end
applyMenuBackground()
local function applyCompactMenu()
    local width=(opt.compactMenu and 500 or 600)*opt.menuScale
    local height=(opt.compactMenu and 345 or 440)*opt.menuScale
    panel.Size=UDim2.fromOffset(width,height)
    panel.Position=UDim2.new(.5,-width/2,.5,-height/2)
    panel.BackgroundTransparency=opt.menuTransparency
end
applyCompactMenu()
local function targetRoot()
    return opt.selectedTarget and opt.selectedTarget.Character and opt.selectedTarget.Character:FindFirstChild("HumanoidRootPart")
end
ownRoot=function()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end
local function stopFlight()
    if flyVelocity then flyVelocity:Destroy(); flyVelocity=nil end
    if flyGyro then flyGyro:Destroy(); flyGyro=nil end
end
local function restoreCollisions()
    for part, original in pairs(originalCollisions) do
        if part.Parent then part.CanCollide=original end
        originalCollisions[part]=nil
    end
end
local noclipElapsed=0
local targetUpdateElapsed=0
track(RunService.RenderStepped:Connect(function(dt)
    local root=ownRoot()
    local camera=workspace.CurrentCamera
    targetUpdateElapsed+=dt
    if camera and (not isPerformanceActive() or targetUpdateElapsed>=.08) then
        targetUpdateElapsed=0
        if not opt.holdActive then opt.lockedTarget=nil;opt.targetLostElapsed=0 end
        if opt.holdActive and not opt.wasHolding and opt.autoTargetEnabled then
            opt.lockedTarget=pickCrosshairTarget(camera)
            opt.targetLostElapsed=0
        end
        if opt.targetSwitchRequested then
            opt.targetSwitchRequested=false
            opt.lockedTarget=switchCrosshairTarget(camera,opt.lockedTarget)
            opt.targetLostElapsed=0
        end
        if opt.holdActive and opt.autoTargetEnabled then
            if not targetStillValid(opt.lockedTarget) then
                -- Require releasing V or pressing B before choosing someone else.
                opt.lockedTarget=nil
                opt.targetLostElapsed=0
            elseif opt.autoSwitchLost then
                local trackedPart=opt.lockedTarget.Character:FindFirstChild(opt.aimPart)
                local projected,visible=camera:WorldToScreenPoint(trackedPart.Position)
                if visible and projected.Z>0 then
                    opt.targetLostElapsed=0
                else
                    opt.targetLostElapsed+=dt
                    if opt.targetLostElapsed>=.25 then
                        opt.lockedTarget=pickCrosshairTarget(camera)
                        opt.targetLostElapsed=0
                    end
                end
            end
        end
        opt.wasHolding=opt.holdActive
        local active=opt.autoTargetEnabled and (not opt.holdMode or opt.holdActive)
        if opt.holdActive then
            autoTarget=active and targetStillValid(opt.lockedTarget) and opt.lockedTarget or nil
        else
            autoTarget=active and pickCrosshairTarget(camera) or nil
        end
        targetIndicator.Visible=opt.autoTargetEnabled
        targetIndicator.Text="Target: "..(autoTarget and autoTarget.DisplayName or (opt.holdActive and "key held; no target" or (opt.holdMode and "hold key to track" or "none")))
        fovRing.Visible=opt.autoTargetEnabled and opt.showTargetFov
        fovRing.Position=UDim2.fromOffset(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
        fovRing.Size=UDim2.fromOffset(opt.targetFov*2,opt.targetFov*2)
        trackingReticle.Visible=false
        local part=autoTarget and autoTarget.Character and autoTarget.Character:FindFirstChild(opt.aimPart)
        if part then
            local screenPoint,onScreen=camera:WorldToScreenPoint(part.Position)
            if onScreen and screenPoint.Z>0 then
                local inset=GuiService:GetGuiInset()
                trackingReticle.Position=UDim2.fromOffset(screenPoint.X-inset.X,screenPoint.Y-inset.Y)
                trackingReticle.Visible=true
                -- Optional, capped relative mouse motion. This depends on the executor.
                -- Never adjusts the camera directly or redirects shots.
                if opt.smoothAssistEnabled and opt.aimMode=="Mouse" and opt.holdActive and opt.mouseMoveAvailable then
                    local cursor=aimCursor(camera)
                    local movement=(Vector2.new(screenPoint.X,screenPoint.Y)-cursor)*opt.assistStrength
                    if movement.Magnitude<=opt.aimDeadzone then movement=Vector2.zero end
                    if movement.Magnitude>opt.assistMaxStep then movement=movement.Unit*opt.assistMaxStep end
                    opt.assistAccumulator+=movement
                    local dx=math.round(opt.assistAccumulator.X)
                    local dy=math.round(opt.assistAccumulator.Y)
                    opt.assistAccumulator-=Vector2.new(dx,dy)
                    if dx~=0 or dy~=0 then
                        local ok=pcall(mousemoverel,dx,dy)
                        if not ok then opt.mouseMoveAvailable=false end
                    end
                else
                    opt.assistAccumulator=Vector2.zero
                end
            end
        end
    end
    if opt.flyEnabled and root and camera then
        if not flyVelocity or flyVelocity.Parent~=root then
            stopFlight()
            flyVelocity=new("BodyVelocity", {MaxForce=Vector3.new(100000,100000,100000),Velocity=Vector3.zero},root)
            flyGyro=new("BodyGyro", {MaxTorque=Vector3.new(100000,100000,100000),P=10000},root)
        end
        local direction=Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction+=camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction-=camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction+=camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction-=camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction+=Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction-=Vector3.yAxis end
        flyVelocity.Velocity=direction.Magnitude>0 and direction.Unit*opt.flySpeed or (opt.flightHover and Vector3.zero or root.AssemblyLinearVelocity*.98)
        flyGyro.CFrame=camera.CFrame
    elseif flyVelocity then stopFlight() end
    local character=player.Character
    local humanoid=character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and (opt.speedEnabled or opt.fakeMacroEnabled) then
        if not opt.savedWalkSpeed then opt.savedWalkSpeed=humanoid.WalkSpeed end
        humanoid.WalkSpeed=opt.fakeMacroEnabled and opt.fakeMacroSpeed or opt.walkSpeed
    end
    noclipElapsed+=dt
    if opt.noclipEnabled and character and noclipElapsed>=(isPerformanceActive() and .20 or .10) then
        noclipElapsed=0
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if originalCollisions[part]==nil then originalCollisions[part]=part.CanCollide end
                part.CanCollide=false
            end
        end
    end
end))
-- Run after Roblox's camera controller so normal third-person movement stays available.
local aimRenderBinding="WisteriaGentleAim_"..tostring(player.UserId)
RunService:BindToRenderStep(aimRenderBinding,Enum.RenderPriority.Camera.Value+1,function(dt)
    if not opt.smoothAssistEnabled or opt.aimMode~="Gentle" or not opt.holdActive then return end
    if not opt.autoTargetEnabled or not targetStillValid(autoTarget) then return end
    if UserInputService:GetFocusedTextBox() then return end
    local camera=workspace.CurrentCamera
    local character=autoTarget.Character
    local part=character and (character:FindFirstChild(opt.aimPart) or character:FindFirstChild("Head"))
    if not camera or not part then return end
    local direction=part.Position-camera.CFrame.Position
    if direction.Magnitude<1 then return end
    local desired=CFrame.lookAt(camera.CFrame.Position,part.Position)
    local response=math.clamp(opt.assistStrength*26,0.3,8)
    local alpha=math.min(.16,1-math.exp(-math.clamp(dt,0,.06)*response))
    camera.CFrame=camera.CFrame:Lerp(desired,alpha)
end)
local function valueInput(current, callback)
    local field=new("TextBox", {Size=UDim2.new(1,-20,0,34),BackgroundColor3=Color3.fromRGB(43,43,43),Text=tostring(current),TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,TextSize=14,ClearTextOnFocus=false},content)
    new("UICorner",{CornerRadius=UDim.new(0,6)},field)
    field.FocusLost:Connect(function() callback(field.Text,field) end)
    return field
end
local function numericSlider(title,minimum,maximum,current,step,onChange)
    local caption=label(title..": "..tostring(current),29)
    local trackBar=new("TextButton",{Size=UDim2.new(1,-20,0,22),BackgroundColor3=Color3.fromRGB(42,42,42),Text="",AutoButtonColor=false,BorderSizePixel=0},content)
    new("UICorner",{CornerRadius=UDim.new(0,7)},trackBar)
    local fill=new("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=accent,BorderSizePixel=0},trackBar)
    new("UICorner",{CornerRadius=UDim.new(0,7)},fill)
    local function refresh(value)
        caption.Text=title..": "..tostring(value)
        fill.Size=UDim2.fromScale(math.clamp((value-minimum)/(maximum-minimum),0,1),1)
    end
    refresh(current)
    local function update(x)
        local width=trackBar.AbsoluteSize.X
        if width<=0 then return end
        local fraction=math.clamp((x-trackBar.AbsolutePosition.X)/width,0,1)
        local value=math.floor((minimum+fraction*(maximum-minimum))/step+.5)*step
        value=math.clamp(value,minimum,maximum)
        refresh(value);onChange(value)
    end
    trackBar.InputBegan:Connect(function(input)
        if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
        update(input.Position.X)
        local moving,ended
        moving=UserInputService.InputChanged:Connect(function(changed)
            if changed==input or (input.UserInputType==Enum.UserInputType.MouseButton1 and changed.UserInputType==Enum.UserInputType.MouseMovement) then update(changed.Position.X) end
        end)
        ended=UserInputService.InputEnded:Connect(function(finished)
            if finished==input or (input.UserInputType==Enum.UserInputType.MouseButton1 and finished.UserInputType==Enum.UserInputType.MouseButton1) then
                moving:Disconnect();ended:Disconnect();savePreferences()
            end
        end)
    end)
    return refresh
end

-- Local rain streak overlay and reversible gray weather grading.
local rainGui=new("ScreenGui",{Name="PurrvotionRain",IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=0,Enabled=false},parent)
local rainCanvas=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Active=false},rainGui)
local moonGui=new("ScreenGui",{Name="PurrvotionMoon",IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=1,Enabled=false},parent)
local moonDisc=new("Frame",{Name="TintedMoon",AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(90,90),
    BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.68,BorderSizePixel=0,Visible=false},moonGui)
new("UICorner",{CornerRadius=UDim.new(1,0)},moonDisc)
local moonImage=new("ImageLabel",{Name="MoonTexture",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
    Image="rbxasset://sky/moon.jpg",ImageColor3=Color3.new(1,1,1),ScaleType=Enum.ScaleType.Fit},moonDisc)
new("UICorner",{CornerRadius=UDim.new(1,0)},moonImage)
local butterflyFX=(function()
local butterflyGui=new("ScreenGui",{Name="PurrvotionButterflies",Enabled=false,ResetOnSpawn=false},parent)
return {gui=butterflyGui,set=function() butterfliesEnabled=false end}
end)()
-- World-space weather is local to this client. It follows the player without covering the UI.
local worldFX=(function()
    local folder=Instance.new("Folder")
    folder.Name="PurrvotionWorldEffects"
    folder.Parent=workspace
    local rainAnchor=Instance.new("Part")
    rainAnchor.Name="RainCloud"
    rainAnchor.Anchored=true
    rainAnchor.CanCollide=false
    rainAnchor.CanTouch=false
    rainAnchor.CanQuery=false
    rainAnchor.Transparency=1
    rainAnchor.Size=Vector3.new(90,1,90)
    rainAnchor.Parent=folder
    local rainfall=Instance.new("ParticleEmitter")
    rainfall.Name="WorldRain"
    rainfall.Texture="rbxasset://textures/particles/raindrop_main.dds"
    rainfall.EmissionDirection=Enum.NormalId.Bottom
    rainfall.Shape=Enum.ParticleEmitterShape.Box
    rainfall.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume
    rainfall.Speed=NumberRange.new(62,78)
    rainfall.Lifetime=NumberRange.new(.75,1.2)
    rainfall.Rate=0
    rainfall.SpreadAngle=Vector2.new(4,4)
    rainfall.Size=NumberSequence.new(.18)
    rainfall.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.3),NumberSequenceKeypoint.new(.85,.35),NumberSequenceKeypoint.new(1,1)})
    rainfall.LightInfluence=.5
    rainfall.Color=ColorSequence.new(Color3.fromRGB(205,218,240))
    rainfall.Parent=rainAnchor
    -- Render real streak geometry as a fallback; some executors hide rain particle textures.
    local streaks={}
    for i=1,110 do
        local streak=Instance.new("Part")
        streak.Name="RainStreak"
        streak.Size=Vector3.new(.055,math.random(26,52)/10,.055)
        streak.Anchored=true
        streak.CanCollide=false
        streak.CanTouch=false
        streak.CanQuery=false
        streak.Material=Enum.Material.Neon
        streak.Color=Color3.fromRGB(183,206,237)
        streak.Transparency=.42+math.random()*.26
        streak.Parent=folder
        streaks[i]={part=streak,x=math.random(-110,110),z=math.random(-110,110),
            y=math.random()*54,speed=math.random(70,105)}
        streak.Transparency=1
    end
    local swarmAnchor=Instance.new("Part")
    swarmAnchor.Name="FireflyField"
    swarmAnchor.Anchored=true
    swarmAnchor.CanCollide=false
    swarmAnchor.CanTouch=false
    swarmAnchor.CanQuery=false
    swarmAnchor.Transparency=1
    swarmAnchor.Size=Vector3.new(36,15,36)
    swarmAnchor.Parent=folder
    local fireflies=Instance.new("ParticleEmitter")
    fireflies.Name="ShinobuFireflies"
    fireflies.Texture="rbxasset://textures/particles/sparkles_main.dds"
    fireflies.Shape=Enum.ParticleEmitterShape.Box
    fireflies.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume
    fireflies.Speed=NumberRange.new(.35,1.4)
    fireflies.Lifetime=NumberRange.new(3,5)
    fireflies.Rate=0
    fireflies.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.06),NumberSequenceKeypoint.new(.5,.24),NumberSequenceKeypoint.new(1,0)})
    fireflies.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.3,.2),NumberSequenceKeypoint.new(.7,.28),NumberSequenceKeypoint.new(1,1)})
    fireflies.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(128,164,255)),ColorSequenceKeypoint.new(.55,Color3.fromRGB(177,130,250)),ColorSequenceKeypoint.new(1,Color3.fromRGB(238,230,255))})
    fireflies.LightEmission=.9
    fireflies.Parent=swarmAnchor
    local shootingStars=Instance.new("ParticleEmitter")
    shootingStars.Name="ShootingStars"
    shootingStars.Texture="rbxasset://textures/particles/sparkles_main.dds"
    shootingStars.Rate=0
    shootingStars.Speed=NumberRange.new(95,140)
    shootingStars.Lifetime=NumberRange.new(.65,1.1)
    shootingStars.EmissionDirection=Enum.NormalId.Right
    shootingStars.SpreadAngle=Vector2.new(10,10)
    shootingStars.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.3),NumberSequenceKeypoint.new(1,0)})
    shootingStars.LightEmission=1
    shootingStars.Parent=rainAnchor
    local atmosphereParticles={}
    for _,style in ipairs({"Sparkles","Petals","Snow","Embers"}) do
        local emitter=Instance.new("ParticleEmitter")
        emitter.Name="Wisteria"..style
        emitter.Texture=style=="Petals" and "rbxasset://textures/particles/smoke_main.dds"
            or (style=="Snow" and "rbxasset://textures/particles/sparkles_main.dds"
            or "rbxasset://textures/particles/sparkles_main.dds")
        emitter.Shape=Enum.ParticleEmitterShape.Box
        emitter.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume
        emitter.EmissionDirection=Enum.NormalId.Bottom
        emitter.Lifetime=NumberRange.new(4,8)
        emitter.Speed=NumberRange.new(.6,2)
        emitter.Size=NumberSequence.new(.18)
        emitter.Rate=0
        emitter.LightEmission=style=="Sparkles" and .8 or .15
        emitter.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.2,.15),NumberSequenceKeypoint.new(.8,.25),NumberSequenceKeypoint.new(1,1)})
        emitter.Parent=swarmAnchor
        atmosphereParticles[style]=emitter
    end
    local puddleParts={}
    for i=1,8 do
        local part=Instance.new("Part")
        part.Name="CosmeticPuddle";part.Anchored=true;part.CanCollide=false
        part.CanTouch=false;part.CanQuery=false
        part.Size=Vector3.new(5,.02,3);part.Transparency=1
        part.Material=Enum.Material.Glass;part.Color=Color3.fromRGB(95,118,147)
        part.Parent=folder
        puddleParts[i]=part
    end
    local splashes={}
    for i=1,8 do
        local splashPart=Instance.new("Part")
        splashPart.Name="RainSplashPoint"
        splashPart.Anchored=true
        splashPart.CanCollide=false
        splashPart.CanTouch=false
        splashPart.CanQuery=false
        splashPart.Transparency=1
        splashPart.Size=Vector3.new(.2,.2,.2)
        splashPart.Parent=folder
        local droplets=Instance.new("ParticleEmitter")
        droplets.Name="GroundSplash"
        droplets.Enabled=false
        droplets.EmissionDirection=Enum.NormalId.Top
        droplets.Speed=NumberRange.new(2,6)
        droplets.SpreadAngle=Vector2.new(70,70)
        droplets.Lifetime=NumberRange.new(.18,.38)
        droplets.Acceleration=Vector3.new(0,-26,0)
        droplets.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.13),NumberSequenceKeypoint.new(1,0)})
        droplets.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.35),NumberSequenceKeypoint.new(1,1)})
        droplets.Color=ColorSequence.new(Color3.fromRGB(200,220,245))
        droplets.Parent=splashPart
        splashes[i]={part=splashPart,emitter=droplets}
    end
    local splashElapsed=0
    local particlesElapsed=0
    local starsElapsed=0
    local splashIndex=0
    local splashRayParams=RaycastParams.new()
    splashRayParams.FilterType=Enum.RaycastFilterType.Exclude
    local wasRaining=false
    local function update(dt,root,lowPerf)
        if not root then
            rainfall.Rate=0; fireflies.Rate=0
            for _,entry in ipairs(streaks) do entry.part.Transparency=1 end
            for _,emitter in pairs(atmosphereParticles) do emitter.Rate=0 end
            return
        end
        local position=root.Position
        local gridX=math.floor(position.X/80+.5)*80
        local gridZ=math.floor(position.Z/80+.5)*80
        rainAnchor.Position=Vector3.new(gridX,position.Y+38,gridZ)
        swarmAnchor.Position=Vector3.new(gridX,position.Y+5,gridZ)
        rainfall.Rate=0 -- explicit streaks below are reliable without custom particle assets
        fireflies.Rate=(opt.firefliesEnabled and (lowPerf and 2 or 8)) or 0
        particlesElapsed+=dt
        if particlesElapsed>=.2 then
        particlesElapsed=0
        for style,emitter in pairs(atmosphereParticles) do
            local enabled=(style==opt.particleStyle and opt.particleEnabled)
                or (style=="Petals" and opt.petalsEnabled) or (style=="Snow" and opt.snowfallEnabled)
            emitter.Rate=enabled and (lowPerf and 2 or opt.particleDensity*5) or 0
            emitter.Color=ColorSequence.new(opt.particleColor)
            emitter.Size=NumberSequence.new(math.clamp(opt.particleSize*(style=="Petals" and .38 or .16),.04,1.5))
            emitter.Speed=NumberRange.new(.5*opt.particleSpeed,2*opt.particleSpeed)
            emitter.Acceleration=Vector3.new(opt.windStrength*8,style=="Petals" and -3 or (style=="Snow" and -5 or 0),0)
        end
        end
        starsElapsed+=dt
        if opt.shootingStarsEnabled and starsElapsed>8 then
            starsElapsed=0
            shootingStars:Emit(lowPerf and 1 or 3)
        end
        local step=math.min(dt,.07)
        if opt.rainEnabled then
            splashElapsed+=step
            if splashElapsed>.12/math.max(.5,opt.rainIntensity/2) then
                splashElapsed=0
                for _=1,(lowPerf and 1 or 2) do
                    splashIndex=splashIndex%#splashes+1
                    local entry=splashes[splashIndex]
                    local origin=position+Vector3.new(math.random(-42,42),45,math.random(-42,42))
                    splashRayParams.FilterDescendantsInstances={folder,player.Character}
                    local hit=workspace:Raycast(origin,Vector3.new(0,-110,0),splashRayParams)
                    if hit and hit.Instance and not hit.Instance:IsDescendantOf(folder) then
                        entry.part.Position=hit.Position+Vector3.new(0,.12,0)
                        if opt.splashesEnabled then entry.emitter:Emit(lowPerf and 2 or 5) end
                        local puddle=puddleParts[splashIndex]
                        if puddle then
                            puddle.Position=hit.Position+Vector3.new(0,.025,0)
                            puddle.Transparency=opt.puddlesEnabled and .72 or 1
                        end
                    end
                end
            end
        end
        if opt.rainEnabled then
        wasRaining=true
        for i,entry in ipairs(streaks) do
            local visible=i<=(lowPerf and 35 or math.floor(110*opt.rainIntensity/3))
            local part=entry.part
            if visible then
                entry.y-=entry.speed*step*opt.rainSpeed
                if entry.y<0 then entry.y=54+math.random()*12 end
                part.Color=opt.rainColor
                part.Transparency=.42+(i%4)*.08
                part.Position=Vector3.new(gridX+entry.x+opt.windStrength*(54-entry.y)*.4,position.Y+entry.y-9,gridZ+entry.z)
            else
                part.Transparency=1
            end
        end
        elseif wasRaining then
            wasRaining=false
            for _,entry in ipairs(streaks) do entry.part.Transparency=1 end
        end
        if not opt.rainEnabled or not opt.puddlesEnabled then
            for _,puddle in ipairs(puddleParts) do puddle.Transparency=1 end
        end
    end
    return {update=update,rain=rainfall,fireflies=fireflies,folder=folder}
end)()
local drops={}
for i=1,48 do
    local frame=new("Frame",{
        Size=UDim2.fromOffset(1,math.random(18,42)),
        BackgroundColor3=Color3.fromRGB(210,217,227),
        BackgroundTransparency=math.random(48,78)/100,
        BorderSizePixel=0,Rotation=12,
    },rainCanvas)
    drops[i]={frame=frame,x=math.random(),y=math.random(),speed=math.random(65,135)/100}
end
local graySkyEnabled=false
local fogBeforeRain
local atmosphereBeforeRain
local weatherAtmosphere
local createdAtmosphere=false
local weatherColorEffect
local originalTimeAndLight
local function setGraySky(enabled)
    if enabled==graySkyEnabled then return end
    graySkyEnabled=enabled
    if enabled then
        fogBeforeRain={Start=Lighting.FogStart,Finish=Lighting.FogEnd,Color=Lighting.FogColor}
        Lighting.FogStart=75
        Lighting.FogEnd=750
        Lighting.FogColor=Color3.fromRGB(160,166,177)
        weatherAtmosphere=Lighting:FindFirstChildOfClass("Atmosphere")
        createdAtmosphere=weatherAtmosphere==nil
        if not weatherAtmosphere then weatherAtmosphere=Instance.new("Atmosphere"); weatherAtmosphere.Parent=Lighting end
        if not createdAtmosphere then
            atmosphereBeforeRain={Density=weatherAtmosphere.Density,Haze=weatherAtmosphere.Haze,Glare=weatherAtmosphere.Glare,Color=weatherAtmosphere.Color,Decay=weatherAtmosphere.Decay}
        end
        weatherAtmosphere.Density=.25
        weatherAtmosphere.Haze=1.1
        weatherAtmosphere.Glare=0
        weatherAtmosphere.Color=Color3.fromRGB(182,190,202)
        weatherAtmosphere.Decay=Color3.fromRGB(151,157,176)
        weatherColorEffect=new("ColorCorrectionEffect",{Name="PurrvotionGrayRain",Brightness=.02,Contrast=.02,Saturation=-.25,TintColor=Color3.fromRGB(225,229,238)},Lighting)
    else
        if fogBeforeRain then
            Lighting.FogStart=fogBeforeRain.Start
            Lighting.FogEnd=fogBeforeRain.Finish
            Lighting.FogColor=fogBeforeRain.Color
            fogBeforeRain=nil
        end
        if weatherColorEffect then weatherColorEffect:Destroy(); weatherColorEffect=nil end
        if weatherAtmosphere then
            if createdAtmosphere then weatherAtmosphere:Destroy()
            elseif atmosphereBeforeRain then
                for property,value in pairs(atmosphereBeforeRain) do weatherAtmosphere[property]=value end
            end
        end
        weatherAtmosphere=nil
        atmosphereBeforeRain=nil
    end
end
local weatherLooks={
    ["Gray"]={fog=850,color=Color3.fromRGB(160,168,181),density=.20,haze=.9,brightness=.04,saturation=-.26,tint=Color3.fromRGB(224,229,238),time=14},
    ["Storm"]={fog=650,color=Color3.fromRGB(116,128,151),density=.31,haze=1.4,brightness=0,saturation=-.38,tint=Color3.fromRGB(196,208,232),time=15},
    ["Misty"]={fog=520,color=Color3.fromRGB(183,190,205),density=.40,haze=2,brightness=.07,saturation=-.3,tint=Color3.fromRGB(229,234,242),time=10},
    ["Night"]={fog=850,color=Color3.fromRGB(87,106,153),density=.24,haze=1.1,brightness=.06,saturation=-.25,tint=Color3.fromRGB(184,197,245),time=21},
    ["Butterfly Night"]={fog=900,color=Color3.fromRGB(125,118,191),density=.22,haze=1.1,
        brightness=.08,saturation=-.12,tint=Color3.fromRGB(211,202,255),time=20},
    ["Sunset"]={fog=420,color=Color3.fromRGB(172,114,126),density=.24,haze=1.6,brightness=-.04,saturation=-.18,tint=Color3.fromRGB(255,207,197),time=18.3},
}
local skyHoldAfter=0
local cancelWeatherTransition
local function setWeatherPreset(name)
    if cancelWeatherTransition then cancelWeatherTransition() end
    if name==opt.weatherPreset then return end
    opt.customSkyColor=nil
    setGraySky(false)
    if originalTimeAndLight then
        Lighting.ClockTime=originalTimeAndLight.ClockTime
        Lighting.Brightness=originalTimeAndLight.Brightness
        Lighting.Ambient=originalTimeAndLight.Ambient
        Lighting.OutdoorAmbient=originalTimeAndLight.OutdoorAmbient
        Lighting.ExposureCompensation=originalTimeAndLight.ExposureCompensation
        originalTimeAndLight=nil
    end
    opt.weatherPreset=name
    local look=weatherLooks[name]
    if not look then return end
    originalTimeAndLight={ClockTime=Lighting.ClockTime,Brightness=Lighting.Brightness,
        Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient,
        ExposureCompensation=Lighting.ExposureCompensation}
    setGraySky(true)
    Lighting.FogEnd=look.fog
    Lighting.FogColor=look.color
    if weatherAtmosphere then
        weatherAtmosphere.Density=look.density
        weatherAtmosphere.Haze=look.haze
        weatherAtmosphere.Color=look.color
    end
    if weatherColorEffect then
        weatherColorEffect.Brightness=look.brightness
        weatherColorEffect.Saturation=look.saturation
        weatherColorEffect.TintColor=look.tint
    end
    Lighting.ClockTime=look.time
    skyHoldAfter=os.clock()+1.15
    Lighting.Brightness=math.max(Lighting.Brightness,2)
    Lighting.Ambient=Color3.fromRGB(100,104,124)
    Lighting.OutdoorAmbient=Color3.fromRGB(146,150,174)
    Lighting.ExposureCompensation=opt.customNightBrightness
end
do
    local binding="PurrvotionSkyClock"
    pcall(function() RunService:UnbindFromRenderStep(binding) end)
    RunService:BindToRenderStep(binding,Enum.RenderPriority.Last.Value+10,function(dt)
        if opt.dayNightCycle and opt.weatherPreset~="Normal" then
            Lighting.ClockTime=(Lighting.ClockTime+dt*24/(opt.dayNightCycleMinutes*60))%24
            return
        end
        if os.clock()<skyHoldAfter then return end
        local look=weatherLooks[opt.weatherPreset]
        if look and math.abs(Lighting.ClockTime-look.time)>.05 then
            Lighting.ClockTime=look.time
        end
    end)
    gui.Destroying:Connect(function()
        pcall(function() RunService:UnbindFromRenderStep(binding) end)
    end)
end
local weatherTweens={}
local weatherGeneration=0
cancelWeatherTransition=function()
    weatherGeneration+=1
    for _,tween in ipairs(weatherTweens) do tween:Cancel() end
    table.clear(weatherTweens)
end
local function startWeatherTween(object,goal)
    if not object or not next(goal) then return end
    local ok,tween=pcall(function()
        return TweenService:Create(object,TweenInfo.new(.85,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),goal)
    end)
    if ok and tween then
        table.insert(weatherTweens,tween)
        tween:Play()
    end
end
local function setWeatherPresetSmooth(name)
    if name==opt.weatherPreset then return end
    if not opt.smoothTransitionsEnabled then setWeatherPreset(name); return end
    cancelWeatherTransition()
    if name=="Normal" and graySkyEnabled then
        local originalFog=fogBeforeRain
        local originalLight=originalTimeAndLight
        local goal={}
        if originalFog then
            goal.FogStart=originalFog.Start
            goal.FogEnd=originalFog.Finish
            goal.FogColor=originalFog.Color
        end
        if originalLight then goal.ClockTime=originalLight.ClockTime; goal.Brightness=originalLight.Brightness end
        startWeatherTween(Lighting,goal)
        if weatherAtmosphere and atmosphereBeforeRain then startWeatherTween(weatherAtmosphere,atmosphereBeforeRain) end
        if weatherColorEffect then
            startWeatherTween(weatherColorEffect,{Brightness=0,Contrast=0,Saturation=0,TintColor=Color3.new(1,1,1)})
        end
        local currentGeneration=weatherGeneration
        task.delay(.88,function()
            if weatherGeneration==currentGeneration then setWeatherPreset("Normal") end
        end)
        return
    end
    local beforeLighting={FogStart=Lighting.FogStart,FogEnd=Lighting.FogEnd,FogColor=Lighting.FogColor,
        ClockTime=Lighting.ClockTime,Brightness=Lighting.Brightness}
    local beforeAtmosphere=weatherAtmosphere and {Density=weatherAtmosphere.Density,Haze=weatherAtmosphere.Haze,
        Color=weatherAtmosphere.Color,Decay=weatherAtmosphere.Decay} or nil
    local beforeCorrection=weatherColorEffect and {Brightness=weatherColorEffect.Brightness,
        Contrast=weatherColorEffect.Contrast,Saturation=weatherColorEffect.Saturation,
        TintColor=weatherColorEffect.TintColor} or nil
    setWeatherPreset(name)
    local afterLighting={FogStart=Lighting.FogStart,FogEnd=Lighting.FogEnd,FogColor=Lighting.FogColor,
        ClockTime=Lighting.ClockTime,Brightness=Lighting.Brightness}
    for property,value in pairs(beforeLighting) do Lighting[property]=value end
    startWeatherTween(Lighting,afterLighting)
    if weatherAtmosphere then
        local afterAtmosphere={Density=weatherAtmosphere.Density,Haze=weatherAtmosphere.Haze,
            Color=weatherAtmosphere.Color,Decay=weatherAtmosphere.Decay}
        for property,value in pairs(beforeAtmosphere or {Density=0,Haze=0,Color=Color3.new(1,1,1),Decay=Color3.new(1,1,1)}) do
            weatherAtmosphere[property]=value
        end
        startWeatherTween(weatherAtmosphere,afterAtmosphere)
    end
    if weatherColorEffect then
        local afterCorrection={Brightness=weatherColorEffect.Brightness,Contrast=weatherColorEffect.Contrast,
            Saturation=weatherColorEffect.Saturation,TintColor=weatherColorEffect.TintColor}
        for property,value in pairs(beforeCorrection or {Brightness=0,Contrast=0,Saturation=0,TintColor=Color3.new(1,1,1)}) do
            weatherColorEffect[property]=value
        end
        startWeatherTween(weatherColorEffect,afterCorrection)
    end
end
local function parseHexColor(text)
    local hex=text:gsub("#",""):gsub("%s","")
    if not hex:match("^%x%x%x%x%x%x$") then return nil end
    return Color3.fromRGB(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16))
end
local function applySkyColor(color)
    cancelWeatherTransition()
    if opt.weatherPreset=="Normal" then setWeatherPreset("Gray") end
    opt.weatherPreset="Custom"
    opt.customSkyColor=color
    Lighting.FogColor=color
    if weatherAtmosphere then
        weatherAtmosphere.Color=color
        weatherAtmosphere.Decay=color:Lerp(Color3.new(0,0,0),.45)
    end
    if weatherColorEffect then weatherColorEffect.TintColor=color:Lerp(Color3.new(1,1,1),.55) end
end
local function applySkyColorSmooth(color)
    if not opt.smoothTransitionsEnabled then applySkyColor(color); return end
    local oldFog=Lighting.FogColor
    local oldAtmosphere=weatherAtmosphere and {Color=weatherAtmosphere.Color,Decay=weatherAtmosphere.Decay} or nil
    local oldEffect=weatherColorEffect and weatherColorEffect.TintColor or nil
    applySkyColor(color)
    local newFog=Lighting.FogColor
    Lighting.FogColor=oldFog
    startWeatherTween(Lighting,{FogColor=newFog})
    if weatherAtmosphere then
        local goal={Color=weatherAtmosphere.Color,Decay=weatherAtmosphere.Decay}
        weatherAtmosphere.Color=(oldAtmosphere and oldAtmosphere.Color) or oldFog
        weatherAtmosphere.Decay=(oldAtmosphere and oldAtmosphere.Decay) or oldFog
        startWeatherTween(weatherAtmosphere,goal)
    end
    if weatherColorEffect then
        local goal={TintColor=weatherColorEffect.TintColor}
        weatherColorEffect.TintColor=oldEffect or Color3.new(1,1,1)
        startWeatherTween(weatherColorEffect,goal)
    end
end
local function applyRainColor(color)
    opt.rainColor=color
    for _,drop in ipairs(drops) do drop.frame.BackgroundColor3=color end
    worldFX.rain.Color=ColorSequence.new(color)
end
local function setRain(enabled)
    opt.rainEnabled=enabled
    rainGui.Enabled=false
    if not enabled then worldFX.rain.Rate=0 end
end

local originalSky
local skyMadeByPurrvotion=false
local skyProperties
local function setCelestials()
    local enable=opt.starsEnabled or opt.moonEnabled
    -- Keep the game's native moon. A 2-D tinted overlay looks like a floating planet.
    moonGui.Enabled=false
    if enable then
        if not originalSky or not originalSky.Parent then
            originalSky=Lighting:FindFirstChildOfClass("Sky")
            skyMadeByPurrvotion=originalSky==nil
            if not originalSky then originalSky=Instance.new("Sky"); originalSky.Parent=Lighting end
            skyProperties={Stars=originalSky.StarCount,Shown=originalSky.CelestialBodiesShown,Moon=originalSky.MoonAngularSize}
        end
        originalSky.CelestialBodiesShown=true
        originalSky.StarCount=opt.starsEnabled and (isPerformanceActive() and 350 or 1800) or 0
        originalSky.MoonAngularSize=opt.moonEnabled and (skyProperties and skyProperties.Moon or 11) or 0
    elseif originalSky then
        if skyMadeByPurrvotion then originalSky:Destroy()
        elseif originalSky.Parent and skyProperties then
            originalSky.StarCount=skyProperties.Stars
            originalSky.CelestialBodiesShown=skyProperties.Shown
            originalSky.MoonAngularSize=skyProperties.Moon
        end
        originalSky=nil
        skyProperties=nil
    end
end

local extraFilter
local filterOptions={
    Monochrome={saturation=-1,contrast=.11,brightness=0,tint=Color3.fromRGB(255,255,255)},
    Pastel={saturation=-.32,contrast=-.09,brightness=.08,tint=Color3.fromRGB(255,226,244)},
    Vintage={saturation=-.48,contrast=.09,brightness=-.03,tint=Color3.fromRGB(246,217,172)},
    Cool={saturation=-.15,contrast=.07,brightness=-.02,tint=Color3.fromRGB(196,220,255)},
    Cinematic={saturation=-.45,contrast=.25,brightness=-.08,tint=Color3.fromRGB(218,225,236)},
}
local function setColorFilter(name)
    if extraFilter then extraFilter:Destroy(); extraFilter=nil end
    opt.filterMode=filterOptions[name] and name or "None"
    local settings=filterOptions[opt.filterMode]
    if settings then
        extraFilter=new("ColorCorrectionEffect",{
            Name="PurrvotionColorFilter",Saturation=settings.saturation,Contrast=settings.contrast,
            Brightness=settings.brightness,TintColor=settings.tint,
        },Lighting)
    end
end

local hiddenEffects=setmetatable({},{__mode="k"})
local effectsToHide={ParticleEmitter=true,Trail=true,Beam=true,Smoke=true,Fire=true,Sparkles=true,
    BloomEffect=true,SunRaysEffect=true,DepthOfFieldEffect=true}
local function suppressEffect(instance)
    if not (opt.hideEffectsEnabled or isPerformanceActive()) then return end
    if effectsToHide[instance.ClassName] and hiddenEffects[instance]==nil then
        local ok,enabled=pcall(function() return instance.Enabled end)
        if ok then
            hiddenEffects[instance]=enabled and "on" or "off"
            pcall(function() instance.Enabled=false end)
        end
    end
end
local function refreshSuppressedEffects()
    if opt.hideEffectsEnabled or isPerformanceActive() then
        task.spawn(function()
            for i,instance in ipairs(workspace:GetDescendants()) do
                if not (opt.hideEffectsEnabled or isPerformanceActive()) then break end
                suppressEffect(instance)
                if i%250==0 then task.wait() end
            end
            for _,instance in ipairs(Lighting:GetChildren()) do suppressEffect(instance) end
        end)
    else
        for instance,value in pairs(hiddenEffects) do
            if instance.Parent then pcall(function() instance.Enabled=(value=="on") end) end
            hiddenEffects[instance]=nil
        end
    end
end
track(workspace.DescendantAdded:Connect(suppressEffect))

local function setPerformanceMode(enabled)
    performanceMode=enabled
    rainGui.Enabled=false
    if originalSky then setCelestials() end
    refreshSuppressedEffects()
end
local lastMeasuredFps=60
local function setAdaptiveReduced(enabled)
    if adaptiveReduced==enabled then return end
    adaptiveReduced=enabled
    setPerformanceMode(performanceMode)
end
do -- Keep FPS sampling counters out of the main script's local-register budget.
local fpsFrames,fpsElapsed,slowChecks,fastChecks=0,0,0,0
track(RunService.RenderStepped:Connect(function(dt)
    if not opt.adaptivePerfEnabled then
        if adaptiveReduced then setAdaptiveReduced(false) end
        fpsFrames=0; fpsElapsed=0; slowChecks=0; fastChecks=0
        return
    end
    fpsFrames+=1
    fpsElapsed+=math.min(dt,.25)
    if fpsElapsed<1 then return end
    lastMeasuredFps=math.floor(fpsFrames/fpsElapsed+.5)
    fpsFrames=0; fpsElapsed=0
    if lastMeasuredFps<43 then
        slowChecks+=1; fastChecks=0
    elseif lastMeasuredFps>55 then
        fastChecks+=1; slowChecks=0
    else
        slowChecks=0; fastChecks=0
    end
    if not adaptiveReduced and slowChecks>=2 then
        setAdaptiveReduced(true); slowChecks=0
    elseif adaptiveReduced and fastChecks>=4 then
        setAdaptiveReduced(false); fastChecks=0
    end
end))
end

local function colorArray(color)
    return {math.floor(color.R*255+.5),math.floor(color.G*255+.5),math.floor(color.B*255+.5)}
end
local function arrayColor(value)
    if type(value)~="table" or #value~=3 then return nil end
    for _,item in ipairs(value) do if type(item)~="number" then return nil end end
    return Color3.fromRGB(math.clamp(value[1],0,255),math.clamp(value[2],0,255),math.clamp(value[3],0,255))
end
captureWeather=function()
    return {preset=opt.weatherPreset,sky=opt.customSkyColor and colorArray(opt.customSkyColor) or nil,
        fog=weatherAtmosphere and weatherAtmosphere.Density or nil,
        time=Lighting.ClockTime,rain=opt.rainEnabled,heavy=opt.heavyRain,rainColor=colorArray(opt.rainColor),
        rainIntensity=opt.rainIntensity,rainSpeed=opt.rainSpeed,splashes=opt.splashesEnabled,puddles=opt.puddlesEnabled,
        wind=opt.windStrength,particles=opt.particleEnabled,particleDensity=opt.particleDensity,
        particleSize=opt.particleSize,particleSpeed=opt.particleSpeed,particleColor=colorArray(opt.particleColor),
        particleStyle=opt.particleStyle,petals=opt.petalsEnabled,snow=opt.snowfallEnabled,thunder=opt.thunderEnabled,
        shootingStars=opt.shootingStarsEnabled,nightBrightness=opt.customNightBrightness,
        dayCycle=opt.dayNightCycle,dayCycleMinutes=opt.dayNightCycleMinutes,
        stars=opt.starsEnabled,moon=opt.moonEnabled,moonName=moonTintName,moonColor=colorArray(moonTintColor),
        fireflies=opt.firefliesEnabled,filter=opt.filterMode}
end
local function applyWeather(data)
    if type(data)~="table" then return end
    setWeatherPreset("Normal")
    local preset=tostring(data.preset or "Night")
    if preset=="Butterfly Night" then preset="Night" end
    setWeatherPreset(weatherLooks[preset] and preset or (preset=="Custom" and "Gray" or "Normal"))
    local sky=arrayColor(data.sky)
    if sky then applySkyColor(sky) end
    if weatherAtmosphere and type(data.fog)=="number" then weatherAtmosphere.Density=math.clamp(data.fog,0,1) end
    if opt.weatherPreset~="Normal" and type(data.time)=="number" then Lighting.ClockTime=math.clamp(data.time,0,24) end
    opt.heavyRain=data.heavy==true
    if type(data.rainIntensity)=="number" then opt.rainIntensity=math.clamp(math.floor(data.rainIntensity),1,3) end
    if type(data.rainSpeed)=="number" then opt.rainSpeed=math.clamp(data.rainSpeed,.4,3) end
    opt.splashesEnabled=data.splashes~=false
    opt.puddlesEnabled=data.puddles==true
    if type(data.wind)=="number" then opt.windStrength=math.clamp(data.wind,-3,3) end
    opt.particleEnabled=data.particles==true
    if type(data.particleDensity)=="number" then opt.particleDensity=math.clamp(math.floor(data.particleDensity),1,3) end
    if type(data.particleSize)=="number" then opt.particleSize=math.clamp(data.particleSize,.3,3) end
    if type(data.particleSpeed)=="number" then opt.particleSpeed=math.clamp(data.particleSpeed,.3,3) end
    opt.particleColor=arrayColor(data.particleColor) or opt.particleColor
    if data.particleStyle=="Sparkles" or data.particleStyle=="Embers" then opt.particleStyle=data.particleStyle end
    opt.petalsEnabled=data.petals==true;opt.snowfallEnabled=data.snow==true
    opt.thunderEnabled=data.thunder==true;opt.shootingStarsEnabled=data.shootingStars==true
    if type(data.nightBrightness)=="number" then opt.customNightBrightness=math.clamp(data.nightBrightness,-.2,.7) end
    opt.dayNightCycle=data.dayCycle==true
    if type(data.dayCycleMinutes)=="number" then opt.dayNightCycleMinutes=math.clamp(data.dayCycleMinutes,1,60) end
    local rcolor=arrayColor(data.rainColor)
    if rcolor then applyRainColor(rcolor) end
    setRain(data.rain==true)
    opt.starsEnabled=data.stars==true;opt.moonEnabled=data.moon==true
    moonTintName=tostring(data.moonName or "White")
    moonTintColor=arrayColor(data.moonColor) or Color3.new(1,1,1)
    setCelestials()
    butterflyFX.set(false)
    opt.firefliesEnabled=data.fireflies==true
    setColorFilter(tostring(data.filter or "None"))
end

local movementPresets={
    Chill={fly=30,walk=18},Balanced={fly=45,walk=24},Fast={fly=90,walk=38},
}
local function setMovementPreset(name)
    local preset=movementPresets[name]
    if not preset then return end
    opt.flySpeed=preset.fly
    opt.walkSpeed=preset.walk
    opt.selectedMovementPreset=name
    if opt.speedEnabled and player.Character then
        local humanoid=player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed=opt.walkSpeed end
    end
end
local function captureProfile()
    return {weather=captureWeather(),movement={fly=opt.flySpeed,walk=opt.walkSpeed},
        hitbox={size=hitbox.size,visible=hitbox.transparency,enabled=hitbox.enabled,color=colorArray(hitbox.color)},
        aim={enabled=opt.autoTargetEnabled,hold=opt.holdMode,part=opt.aimPart,key=opt.holdKey,mode=opt.aimMode,switchPolicy=opt.autoSwitchLost and "auto" or "manual",
            fov=opt.targetFov,distance=opt.targetMaxDistance,smooth=opt.smoothAssistEnabled,
            strength=opt.assistStrength,maxStep=opt.assistMaxStep,deadzone=opt.aimDeadzone},
        accent=colorArray(accent),menu=opt.menuKeyName,flyKey=opt.flyKeyName,targetKey=opt.holdKey,
        compact=opt.compactMenu,performance=performanceMode,hideEffects=opt.hideEffectsEnabled,
        adaptive=opt.adaptivePerfEnabled,quickToolbar=opt.quickToolbarEnabled,smoothWeather=opt.smoothTransitionsEnabled,
        quickPosition={table.unpack(quickPosition)},
        background=opt.menuBackgroundStyle,backgroundColor=colorArray(opt.menuCustomColor)}
end
local function applyProfile(data)
    if type(data)~="table" then return false end
    if type(data.weather)=="table" then applyWeather(data.weather) end
    if type(data.movement)=="table" then
        if type(data.movement.fly)=="number" then opt.flySpeed=math.clamp(data.movement.fly,10,MAX_FLIGHT_SPEED) end
        if type(data.movement.walk)=="number" then opt.walkSpeed=math.clamp(data.movement.walk,16,100) end
        opt.selectedMovementPreset="Custom"
    end
    if type(data.hitbox)=="table" then
        if type(data.hitbox.size)=="number" then hitbox.size=math.clamp(data.hitbox.size,2,20) end
        if data.hitbox.visible==1 or data.hitbox.visible==.5 then hitbox.transparency=data.hitbox.visible end
        hitbox.enabled=data.hitbox.enabled==true
        local hitboxTint=arrayColor(data.hitbox.color)
        if hitboxTint then hitbox.color=hitboxTint end
        refreshHitboxes()
    end
    if type(data.aim)=="table" then
        opt.autoTargetEnabled=data.aim.enabled~=false
        opt.holdMode=data.aim.hold~=false
        if data.aim.part=="Head" or data.aim.part=="HumanoidRootPart" then opt.aimPart=data.aim.part end
        if data.aim.mode=="Mouse" or data.aim.mode=="Gentle" then opt.aimMode=data.aim.mode end
        opt.autoSwitchLost=data.aim.switchPolicy=="auto"
        if type(data.aim.key)=="string" and (Enum.KeyCode[data.aim.key] or data.aim.key=="RightMouse") then opt.holdKey=data.aim.key end
        if type(data.aim.fov)=="number" then opt.targetFov=math.clamp(data.aim.fov,25,450) end
        if type(data.aim.distance)=="number" then opt.targetMaxDistance=math.clamp(data.aim.distance,50,2000) end
        opt.smoothAssistEnabled=data.aim.smooth==true
        if type(data.aim.strength)=="number" then opt.assistStrength=math.clamp(data.aim.strength,.01,.5) end
        if type(data.aim.maxStep)=="number" then opt.assistMaxStep=math.clamp(data.aim.maxStep,1,15) end
        if type(data.aim.deadzone)=="number" then opt.aimDeadzone=math.clamp(data.aim.deadzone,0,35) end
    end
    local color=arrayColor(data.accent)
    if color then accent=color;updateAccent() end
    if type(data.menu)=="string" and Enum.KeyCode[data.menu] and data.menu~="RightShift" then opt.menuKeyName=data.menu end
    if type(data.flyKey)=="string" and (Enum.KeyCode[data.flyKey] or data.flyKey=="None") then opt.flyKeyName=data.flyKey end
    if type(data.targetKey)=="string" and (Enum.KeyCode[data.targetKey] or data.targetKey=="RightMouse") then opt.holdKey=data.targetKey end
    if opt.holdKey=="C" then opt.holdKey="V" end
    opt.compactMenu=data.compact==true
    applyCompactMenu()
    opt.adaptivePerfEnabled=data.adaptive==true
    opt.quickToolbarEnabled=data.quickToolbar~=false
    if quickGui then quickGui.Enabled=opt.quickToolbarEnabled end
    if type(data.quickPosition)=="table" and #data.quickPosition==4 then
        local valid=true
        for _,n in ipairs(data.quickPosition) do if type(n)~="number" then valid=false end end
        if valid then
            quickPosition={table.unpack(data.quickPosition)}
            if quickFrame then quickFrame.Position=UDim2.new(table.unpack(quickPosition)) end
        end
    end
    opt.smoothTransitionsEnabled=data.smoothWeather~=false
    if type(data.background)=="string" then opt.menuBackgroundStyle=data.background end
    local bgColor=arrayColor(data.backgroundColor)
    if bgColor then opt.menuCustomColor=bgColor end
    applyMenuBackground()
    opt.hideEffectsEnabled=data.hideEffects==true
    setPerformanceMode(data.performance==true)
    refreshSuppressedEffects()
    return true
end
local function setBind(which,name)
    local allowed={P=true,B=true,G=true,H=true,J=true,K=true,L=true,N=true,O=true,V=true,Z=true,
        Insert=true,RightControl=true,None=true,RightMouse=true}
    if not allowed[name] then return false end
    if which=="menu" and name~="None" and name~="RightMouse" and name~=opt.flyKeyName and name~=opt.holdKey then opt.menuKeyName=name
    elseif which=="fly" and name~=opt.menuKeyName and name~=opt.holdKey and name~="RightMouse" then opt.flyKeyName=name
    elseif which=="target" and name~="None" and name~=opt.menuKeyName and name~=opt.flyKeyName and name~=opt.targetSwitchKey then
        opt.holdKey=name; opt.holdActive=false; opt.lockedTarget=nil
    else return false end
    savePreferences()
    return true
end
local function saveSkySlot(slot)
    savedSkies[slot]=captureWeather()
    return savePreferences()
end
local function loadSkySlot(slot)
    if not savedSkies[slot] then return false end
    applyWeather(savedSkies[slot])
    savePreferences()
    return true
end

-- Loading is delayed until all visual controllers exist.
if type(opt.storedWeatherSettings)=="table" then
    if opt.storedWeatherSettings.preset=="Normal" or opt.storedWeatherSettings.preset=="Butterfly Night" then opt.storedWeatherSettings.preset="Night" end
    applyWeather(opt.storedWeatherSettings)
else
    setWeatherPreset("Night")
    opt.moonEnabled=true;setCelestials()
end
if performanceMode then setPerformanceMode(true)
elseif opt.hideEffectsEnabled then refreshSuppressedEffects() end
local moonElapsed=0
local function updateMoonOverlay(dt)
    if not moonGui.Enabled then moonDisc.Visible=false; return end
    moonElapsed+=dt
    if moonElapsed<(isPerformanceActive() and .12 or .055) then return end
    moonElapsed=0
    local camera=workspace.CurrentCamera
    if not camera then moonDisc.Visible=false; return end
    local direction=Lighting:GetMoonDirection()
    if direction.Y<=0 then moonDisc.Visible=false; return end
    local projected,onScreen=camera:WorldToViewportPoint(camera.CFrame.Position+direction*1000)
    if not onScreen or projected.Z<=0 then moonDisc.Visible=false; return end
    local size=math.clamp(camera.ViewportSize.Y*math.tan(math.rad(6))/math.tan(math.rad(camera.FieldOfView*.5)),25,170)
    moonDisc.Size=UDim2.fromOffset(size,size)
    moonDisc.Position=UDim2.fromOffset(projected.X,projected.Y)
    moonDisc.Visible=true
end
local weatherConnection=track(RunService.RenderStepped:Connect(function(dt)
    updateMoonOverlay(dt)
    worldFX.update(dt,player.Character and player.Character:FindFirstChild("HumanoidRootPart"),isPerformanceActive())
end))
do -- Gentle, infrequent lightning: no strobe effect.
    local thunderClock=0
    track(RunService.Heartbeat:Connect(function(dt)
        thunderClock+=dt
        if thunderClock<22 then return end
        thunderClock=0
        if not opt.thunderEnabled or opt.weatherPreset=="Normal" then return end
        local old=Lighting.ExposureCompensation
        Lighting.ExposureCompensation=math.min(old+.15,.75)
        task.delay(.18,function()
            if Lighting.Parent then Lighting.ExposureCompensation=opt.customNightBrightness end
        end)
    end))
end
gui.Destroying:Connect(function()
    setWeatherPreset("Normal")
    setRain(false)
    butterflyFX.set(false)
    if cancelWeatherTransition then cancelWeatherTransition() end
    opt.starsEnabled=false; opt.moonEnabled=false; setCelestials()
    setColorFilter("None")
    opt.hideEffectsEnabled=false; performanceMode=false; refreshSuppressedEffects()
    restoreAllHitboxes()
    weatherConnection:Disconnect()
    rainGui:Destroy()
    moonGui:Destroy()
    butterflyFX.gui:Destroy()
    worldFX.folder:Destroy()
end)

local function emergencyReset()
    opt.flyEnabled=false; stopFlight()
    opt.fakeMacroEnabled=false;opt.lastMacroTap=0
    opt.noclipEnabled=false; restoreCollisions()
    opt.speedEnabled=false
    local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and opt.savedWalkSpeed then humanoid.WalkSpeed=opt.savedWalkSpeed end
    opt.savedWalkSpeed=nil
    opt.particleEnabled=false;opt.petalsEnabled=false;opt.snowfallEnabled=false
    opt.thunderEnabled=false;opt.shootingStarsEnabled=false;opt.puddlesEnabled=false
    opt.autoTargetEnabled=false; opt.holdActive=false; opt.lockedTarget=nil; autoTarget=nil
    opt.smoothAssistEnabled=false; opt.assistAccumulator=Vector2.zero
    hitbox.enabled=false; restoreAllHitboxes()
    setWeatherPreset("Normal")
    setRain(false)
    butterflyFX.set(false)
    opt.moonEnabled=false; opt.starsEnabled=false; setCelestials()
    setColorFilter("None")
    opt.adaptivePerfEnabled=false; setAdaptiveReduced(false)
    opt.hideEffectsEnabled=false; setPerformanceMode(false)
    savePreferences()
end

quickGui=new("ScreenGui",{Name="PurrvotionQuickbar",ResetOnSpawn=false,DisplayOrder=7,Enabled=opt.quickToolbarEnabled},parent)
quickFrame=new("Frame",{Name="QuickActions",Size=UDim2.fromOffset(381,42),Position=UDim2.new(table.unpack(quickPosition)),
    BackgroundColor3=Color3.fromRGB(15,15,15),BackgroundTransparency=.08,BorderSizePixel=0,Active=true},quickGui)
new("UICorner",{CornerRadius=UDim.new(0,10)},quickFrame)
quickStroke=new("UIStroke",{Color=accent,Thickness=1},quickFrame)
new("UIPadding",{PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),PaddingTop=UDim.new(0,5)},quickFrame)
new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},quickFrame)
local function quickAction(name,width,callback)
    local item=new("TextButton",{Size=UDim2.fromOffset(width,31),BackgroundColor3=Color3.fromRGB(39,39,39),
        Text=name,TextColor3=Color3.fromRGB(242,242,242),TextSize=11,Font=Enum.Font.GothamBold,BorderSizePixel=0},quickFrame)
    new("UICorner",{CornerRadius=UDim.new(0,6)},item)
    item.MouseButton1Click:Connect(callback)
    return item
end
local dragGrip=quickAction("⋮",16,function() end)
local quickFly
quickFly=quickAction("Fly",51,function()
    opt.flyEnabled=not opt.flyEnabled
    if not opt.flyEnabled then stopFlight() end
    quickFly.Text=opt.flyEnabled and "Fly ON" or "Fly"
end)
local quickHit
quickHit=quickAction(hitbox.enabled and "Hit ON" or "Hit",53,function()
    hitbox.enabled=not hitbox.enabled
    refreshHitboxes(); savePreferences()
    quickHit.Text=hitbox.enabled and "Hit ON" or "Hit"
end)
quickAction("TP",44,function()
    if pageOpeners.Teleport then pageOpeners.Teleport(); gui.Enabled=true end
end)
quickAction("Sky",45,function()
    if pageOpeners.Visuals then pageOpeners.Visuals(); gui.Enabled=true end
end)
do
local resetQuick
resetQuick=quickAction("Reset",52,function()
    emergencyReset()
    quickFly.Text="Fly"; quickHit.Text="Hit"; resetQuick.Text="Done!"
    task.delay(2,function() if resetQuick.Parent then resetQuick.Text="Reset" end end)
end)
end
quickAction("Menu",50,function() gui.Enabled=not gui.Enabled end)
local wheelGui=new("ScreenGui",{Name="WisteriaWheel",ResetOnSpawn=false,DisplayOrder=9,Enabled=false},parent)
local wheelFrame=new("Frame",{Size=UDim2.fromOffset(190,190),Position=UDim2.new(.5,-95,.5,-95),BackgroundColor3=Color3.fromRGB(19,19,23),BackgroundTransparency=.12},wheelGui)
new("UICorner",{CornerRadius=UDim.new(1,0)},wheelFrame)
new("UIStroke",{Color=accent,Thickness=2},wheelFrame)
local function wheelButton(name,x,y,callback)
    local item=new("TextButton",{Size=UDim2.fromOffset(77,35),Position=UDim2.fromOffset(x,y),
        Text=name,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Color3.new(1,1,1),
        BackgroundColor3=Color3.fromRGB(43,43,49),BorderSizePixel=0},wheelFrame)
    new("UICorner",{CornerRadius=UDim.new(0,9)},item)
    item.MouseButton1Click:Connect(function() wheelGui.Enabled=false;opt.quickWheelVisible=false;callback() end)
end
wheelButton("Fly",10,48,function() opt.flyEnabled=not opt.flyEnabled;if not opt.flyEnabled then stopFlight() end;quickFly.Text=opt.flyEnabled and "Fly ON" or "Fly" end)
wheelButton("Weather",103,48,function() if pageOpeners.Visuals then pageOpeners.Visuals();gui.Enabled=true end end)
wheelButton("Teleports",10,106,function() if pageOpeners.Teleport then pageOpeners.Teleport();gui.Enabled=true end end)
wheelButton("Settings",103,106,function() if pageOpeners.Settings then pageOpeners.Settings();gui.Enabled=true end end)
local sessionStarted=os.clock()
local statusGui=new("ScreenGui",{Name="WisteriaStatus",ResetOnSpawn=false,DisplayOrder=4},parent)
local sessionLabel=new("TextLabel",{Size=UDim2.fromOffset(230,26),Position=UDim2.new(1,-245,0,78),
    BackgroundColor3=Color3.fromRGB(18,18,22),BackgroundTransparency=.3,
    TextColor3=Color3.fromRGB(230,230,234),TextSize=12,Font=Enum.Font.GothamMedium,
    Text="Session 00:00 • FPS --"},statusGui)
new("UICorner",{CornerRadius=UDim.new(0,7)},sessionLabel)
do
    local elapsed,frames=0,0
    track(RunService.RenderStepped:Connect(function(dt)
        elapsed+=dt;frames+=1
        if elapsed>=1 then
            local seconds=math.floor(os.clock()-sessionStarted)
            sessionLabel.Text=string.format("Session %02d:%02d • FPS %d",math.floor(seconds/60),seconds%60,math.floor(frames/elapsed+.5))
            elapsed=0;frames=0
        end
    end))
end
do
local quickDragging,quickDragStart,quickStart=false,nil,nil
track(dragGrip.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        quickDragging=true;quickDragStart=input.Position;quickStart=quickFrame.Position
    end
end))
track(UserInputService.InputChanged:Connect(function(input)
    if quickDragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-quickDragStart
        quickFrame.Position=UDim2.new(quickStart.X.Scale,quickStart.X.Offset+delta.X,quickStart.Y.Scale,quickStart.Y.Offset+delta.Y)
    end
end))
track(UserInputService.InputEnded:Connect(function(input)
    if quickDragging and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
        quickDragging=false
        quickPosition={quickFrame.Position.X.Scale,quickFrame.Position.X.Offset,quickFrame.Position.Y.Scale,quickFrame.Position.Y.Offset}
        savePreferences()
    end
end))
end

page("Main", function()
    label("Automatic target selection near your cursor", 40)
    local aimButton
    aimButton=button(opt.autoTargetEnabled and "Auto target: ON" or "Auto target: OFF",function()
        opt.autoTargetEnabled=not opt.autoTargetEnabled
        aimButton.Text=opt.autoTargetEnabled and "Auto target: ON" or "Auto target: OFF"
        savePreferences()
    end)
    local modeButton
    modeButton=button("Mode: Hold to track",function()
        opt.holdMode=not opt.holdMode
        modeButton.Text=opt.holdMode and "Mode: Hold to track" or "Mode: Always on"
        savePreferences()
    end)
    local keyButton
    keyButton=button("Hold key: "..opt.holdKey,function()
        local candidates={"V","Z","RightMouse"}
        local currentIndex=0
        for i,choice in ipairs(candidates) do if choice==opt.holdKey then currentIndex=i; break end end
        for _=1,#candidates do
            currentIndex=currentIndex%#candidates+1
            local candidate=candidates[currentIndex]
            if candidate~=opt.menuKeyName and candidate~=opt.flyKeyName then opt.holdKey=candidate; break end
        end
        opt.holdActive=false
        opt.lockedTarget=nil
        keyButton.Text="Hold key: "..(opt.holdKey=="RightMouse" and "Right mouse" or opt.holdKey)
        savePreferences()
    end)
    label("Hold V near your intended player. Release to retarget; press B to switch.",58)
    local autoSwitchButton
    autoSwitchButton=button("Switch when target leaves screen: "..(opt.autoSwitchLost and "ON" or "OFF"),function()
        opt.autoSwitchLost=not opt.autoSwitchLost
        autoSwitchButton.Text="Switch when target leaves screen: "..(opt.autoSwitchLost and "ON" or "OFF")
        savePreferences()
    end)
    numericSlider("Aim deadzone (pixels)",0,35,opt.aimDeadzone,1,function(value) opt.aimDeadzone=value end)
    label("FOV radius in pixels (25–450)",32)
    valueInput(opt.targetFov,function(text,field)
        opt.targetFov=math.clamp(tonumber(text) or 160,25,450); field.Text=tostring(opt.targetFov)
        savePreferences()
    end)
    label("Maximum player distance in studs (50–2000)",42)
    valueInput(opt.targetMaxDistance,function(text,field)
        opt.targetMaxDistance=math.clamp(tonumber(text) or 700,50,2000); field.Text=tostring(opt.targetMaxDistance)
        savePreferences()
    end)
    label("FOV ring is hidden; the radius still controls target selection.",45)
    local aimPartButton
    aimPartButton=button("Aim part: "..opt.aimPart,function()
        opt.aimPart=opt.aimPart=="Head" and "HumanoidRootPart" or "Head"
        aimPartButton.Text="Aim part: "..opt.aimPart
        savePreferences()
    end)
    local assistButton
    assistButton=button("Aim follow: "..(opt.smoothAssistEnabled and "ON" or "OFF"),function()
        opt.smoothAssistEnabled=not opt.smoothAssistEnabled
        assistButton.Text=opt.smoothAssistEnabled and "Aim follow: ON" or "Aim follow: OFF"
        savePreferences()
    end)
    local assistModeButton
    assistModeButton=button("Follow style: "..opt.aimMode,function()
        opt.aimMode=opt.aimMode=="Gentle" and "Mouse" or "Gentle"
        opt.assistAccumulator=Vector2.zero
        assistModeButton.Text="Follow style: "..opt.aimMode
        savePreferences()
    end)
    label("Gentle = smooth third-person view follow. Mouse = old experimental movement.",58)
    label("Aim follow strength (0.01–0.5)",32)
    valueInput(opt.assistStrength,function(text,field)
        opt.assistStrength=math.clamp(tonumber(text) or .12,.01,.5)
        field.Text=tostring(opt.assistStrength)
        savePreferences()
    end)
    label("Max mouse pixels per frame (1–15)",32)
    valueInput(opt.assistMaxStep,function(text,field)
        opt.assistMaxStep=math.clamp(tonumber(text) or 6,1,15)
        field.Text=tostring(opt.assistMaxStep)
        savePreferences()
    end)
    label("Hold "..opt.holdKey.." to track a target; your mouse side buttons are unchanged.",62)
    label(opt.mouseMoveAvailable and "Hold the selected key for ONE target. Release to switch." or "Mouse movement API unavailable here: visual tracking only.",62)
    label("Gentle follow moves your view only while V is held; it cannot guarantee shots will register.",58)
    label("Silent aim: not implemented. Da Hood shot redirection needs separate verification.",55)
    label("Manual teleport target (optional)",35)
    valueInput(opt.selectedTarget and opt.selectedTarget.Name or "",function(text,field)
        opt.selectedTarget=nil
        for _, other in ipairs(Players:GetPlayers()) do
            if other~=player and other.Name:lower():find(text:lower(),1,true) and #text>0 then opt.selectedTarget=other; break end
        end
        field.Text=opt.selectedTarget and opt.selectedTarget.Name or "Player not found"
    end)
    label("Press "..opt.menuKeyName.." or tap the small Menu button to show/hide Wisteria Hub.", 52)
end)
page("Visuals", function()
    label("Weather • choose a sky mood (rain is separate)",42)
    local weatherLabel=label("Current sky: "..opt.weatherPreset,32)
    local starsButton,moonButton
    local transitionButton
    transitionButton=button("Smooth sky transitions: "..(opt.smoothTransitionsEnabled and "ON" or "OFF"),function()
        opt.smoothTransitionsEnabled=not opt.smoothTransitionsEnabled
        transitionButton.Text="Smooth sky transitions: "..(opt.smoothTransitionsEnabled and "ON" or "OFF")
        savePreferences()
    end)
    for _,name in ipairs({"Normal","Gray","Storm","Misty","Night","Sunset"}) do
        button("Sky: "..name,function()
            setWeatherPresetSmooth(name)
            weatherLabel.Text="Current sky: "..name
            if opt.smoothTransitionsEnabled then task.delay(.91,savePreferences)
            else savePreferences() end
        end)
    end
    label("Custom sky color • any 6-digit hex (#RRGGBB)",40)
    local skyInput=valueInput("#A0A0A0",function(text,field)
        local color=parseHexColor(text)
        if not color then field.Text="Invalid hex • try #A0A0A0"; return end
        applySkyColorSmooth(color)
        weatherLabel.Text="Current sky: Custom"
        if opt.smoothTransitionsEnabled then task.delay(.91,savePreferences) else savePreferences() end
    end)
    local skyColors={
        {"White","#FFFFFF"},{"Black","#292929"},{"Pink","#F29FC5"},
        {"Purple","#A68BEA"},{"Blue","#6AAFFF"},{"Red","#E37474"},
        {"Green","#83BB99"},{"Orange","#F6AD75"},{"Gray","#A0A0A0"},
    }
    local colorIndex=0
    local colorButton
    colorButton=button("Quick colors: tap to cycle",function()
        colorIndex=colorIndex%#skyColors+1
        local choice=skyColors[colorIndex]
        skyInput.Text=choice[2]
        applySkyColorSmooth(parseHexColor(choice[2]))
        weatherLabel.Text="Current sky: "..choice[1]
        colorButton.Text="Quick color: "..choice[1].." • tap for next"
        if opt.smoothTransitionsEnabled then task.delay(.91,savePreferences) else savePreferences() end
    end)
    numericSlider("Fog thickness",0,1,weatherAtmosphere and weatherAtmosphere.Density or .24,.05,function(density)
        if opt.weatherPreset=="Normal" then setWeatherPreset("Night") end
        if weatherAtmosphere then weatherAtmosphere.Density=density end
    end)
    numericSlider("Night brightness",-.2,.7,opt.customNightBrightness,.05,function(value)
        opt.customNightBrightness=value
        if opt.weatherPreset~="Normal" then Lighting.ExposureCompensation=value end
    end)
    local cycleButton
    cycleButton=button("Day/night cycle: "..(opt.dayNightCycle and "ON" or "OFF"),function()
        opt.dayNightCycle=not opt.dayNightCycle
        cycleButton.Text="Day/night cycle: "..(opt.dayNightCycle and "ON" or "OFF")
        savePreferences()
    end)
    numericSlider("Full day cycle (minutes)",1,60,opt.dayNightCycleMinutes,1,function(value) opt.dayNightCycleMinutes=value end)
    label("Time of day (0–24; 0=midnight, 12=noon)",40)
    valueInput("14",function(text,field)
        local hour=tonumber(text)
        if not hour then field.Text="Enter 0 to 24"; return end
        if opt.weatherPreset=="Normal" then setWeatherPreset("Gray") end
        Lighting.ClockTime=math.clamp(hour,0,24)
        field.Text=tostring(Lighting.ClockTime)
        savePreferences()
    end)
    local rainButton
    rainButton=button("Falling rain: OFF",function()
        setRain(not opt.rainEnabled)
        rainButton.Text=opt.rainEnabled and "Falling rain: ON" or "Falling rain: OFF"
        savePreferences()
    end)
    numericSlider("Rain intensity",1,3,opt.rainIntensity,1,function(value) opt.rainIntensity=value end)
    numericSlider("Rain fall speed",.5,3,opt.rainSpeed,.25,function(value) opt.rainSpeed=value end)
    local splashButton
    splashButton=button("Ground splashes: "..(opt.splashesEnabled and "ON" or "OFF"),function()
        opt.splashesEnabled=not opt.splashesEnabled
        splashButton.Text="Ground splashes: "..(opt.splashesEnabled and "ON" or "OFF")
        savePreferences()
    end)
    local puddleButton
    puddleButton=button("Lightweight puddles: "..(opt.puddlesEnabled and "ON" or "OFF"),function()
        opt.puddlesEnabled=not opt.puddlesEnabled
        puddleButton.Text="Lightweight puddles: "..(opt.puddlesEnabled and "ON" or "OFF")
        savePreferences()
    end)
    label("Rain color • any hex (or use white/blue/pink)",38)
    valueInput("#D2D9E3",function(text,field)
        local color=parseHexColor(text)
        if not color then field.Text="Invalid hex"; return end
        applyRainColor(color)
        field.Text="#"..text:gsub("#",""):upper()
        savePreferences()
    end)
    button("Rain: White",function() applyRainColor(Color3.fromRGB(245,245,245)); savePreferences() end)
    button("Rain: Blue",function() applyRainColor(Color3.fromRGB(140,184,255)); savePreferences() end)
    button("Rain: Pink",function() applyRainColor(Color3.fromRGB(249,164,205)); savePreferences() end)
    label("Try gray + rain, storm + heavy rain, or mist without rain. All effects are local.",54)
    local previewMessage=label("Weather preview: try storm/rain briefly without saving it.",38)
    local previewGeneration=0
    button("Preview storm + rain for 5 seconds",function()
        previewGeneration+=1
        local current=previewGeneration
        local before=captureWeather()
        setWeatherPreset("Storm");setRain(true);opt.rainIntensity=3
        previewMessage.Text="Previewing storm... returning in 5 seconds"
        task.delay(5,function()
            if current~=previewGeneration or not gui.Parent then return end
            applyWeather(before)
            previewMessage.Text="Preview ended; your original weather is restored."
        end)
    end)
    label("Saved skies: keep three favorite weather combinations",45)
    local skyStatus=label("Save or restore your sky, time, rain, stars and filter.",44)
    for _,slot in ipairs({"Sky 1","Sky 2","Sky 3"}) do
        button("Save current look: "..slot,function()
            skyStatus.Text=(saveSkySlot(slot) and "Saved " or "Saved in this session: ")..slot
        end)
        button("Load look: "..slot,function()
            skyStatus.Text=loadSkySlot(slot) and ("Loaded "..slot) or ("Nothing saved in "..slot)
        end)
    end
    starsButton=button("Stars: "..(opt.starsEnabled and "ON" or "OFF"),function()
        opt.starsEnabled=not opt.starsEnabled; setCelestials(); savePreferences()
        starsButton.Text="Stars: "..(opt.starsEnabled and "ON" or "OFF")
    end)
    moonButton=button("Moon: "..(opt.moonEnabled and "ON" or "OFF"),function()
        opt.moonEnabled=not opt.moonEnabled; setCelestials(); savePreferences()
        moonButton.Text="Moon: "..(opt.moonEnabled and "ON" or "OFF")
    end)
    label("Particles & weather mixing • effects can run together",44)
    local particleButton
    particleButton=button("Floating particles: "..(opt.particleEnabled and "ON" or "OFF"),function()
        opt.particleEnabled=not opt.particleEnabled
        particleButton.Text="Floating particles: "..(opt.particleEnabled and "ON" or "OFF")
        savePreferences()
    end)
    local particleStyleButton
    particleStyleButton=button("Particle style: "..opt.particleStyle,function()
        opt.particleStyle=opt.particleStyle=="Sparkles" and "Embers" or "Sparkles"
        particleStyleButton.Text="Particle style: "..opt.particleStyle
        savePreferences()
    end)
    numericSlider("Particle amount",1,3,opt.particleDensity,1,function(value) opt.particleDensity=value end)
    numericSlider("Particle size",.3,3,opt.particleSize,.1,function(value) opt.particleSize=value end)
    numericSlider("Particle speed",.3,3,opt.particleSpeed,.1,function(value) opt.particleSpeed=value end)
    numericSlider("Wind direction/strength",-3,3,opt.windStrength,.25,function(value) opt.windStrength=value end)
    label("Particle/petal color (6-digit HEX)",34)
    valueInput("#BDA6FF",function(text,field)
        local color=parseHexColor(text)
        if color then opt.particleColor=color;savePreferences();field.Text="#"..text:gsub("#",""):upper() else field.Text="Invalid color" end
    end)
    for _,option in ipairs({{"White","#FFFFFF"},{"Lavender","#BDA6FF"},{"Blue","#91CFFF"},{"Pink","#FFB7DD"},{"Red","#FF6677"}}) do
        button("Particles: "..option[1],function() opt.particleColor=parseHexColor(option[2]);savePreferences() end)
    end
    for _,pair in ipairs({{"Falling petals", "petals"},{"Snowfall", "snow"},{"Thunder flashes", "thunder"},{"Shooting stars", "stars"}}) do
        local toggle
        toggle=button(pair[1]..": OFF",function()
            if pair[2]=="petals" then opt.petalsEnabled=not opt.petalsEnabled;toggle.Text="Falling petals: "..(opt.petalsEnabled and "ON" or "OFF") end
            if pair[2]=="snow" then opt.snowfallEnabled=not opt.snowfallEnabled;toggle.Text="Snowfall: "..(opt.snowfallEnabled and "ON" or "OFF") end
            if pair[2]=="thunder" then opt.thunderEnabled=not opt.thunderEnabled;toggle.Text="Thunder flashes: "..(opt.thunderEnabled and "ON" or "OFF") end
            if pair[2]=="stars" then opt.shootingStarsEnabled=not opt.shootingStarsEnabled;toggle.Text="Shooting stars: "..(opt.shootingStarsEnabled and "ON" or "OFF") end
            savePreferences()
        end)
    end
    local fireflyButton
    fireflyButton=button("Shinobu fireflies: "..(opt.firefliesEnabled and "ON" or "OFF"),function()
        opt.firefliesEnabled=not opt.firefliesEnabled
        fireflyButton.Text="Shinobu fireflies: "..(opt.firefliesEnabled and "ON" or "OFF")
        savePreferences()
    end)
    label("3D effects drift around you; performance mode reduces particles.",50)
    label("Original game moon preserved. Moon recoloring needs a separate uploaded sky texture; the old fake overlay is removed.",62)
    label("Color filters (choose one; None disables)",40)
    local filterStatus=label("Active filter: "..opt.filterMode,34)
    for _,filter in ipairs({"None","Monochrome","Pastel","Vintage","Cool","Cinematic"}) do
        button("Filter: "..filter,function()
            setColorFilter(filter); savePreferences()
            filterStatus.Text="Active filter: "..opt.filterMode
        end)
    end
    local effectsButton
    effectsButton=button("Hide distracting effects: "..(opt.hideEffectsEnabled and "ON" or "OFF"),function()
        opt.hideEffectsEnabled=not opt.hideEffectsEnabled
        refreshSuppressedEffects()
        effectsButton.Text="Hide distracting effects: "..(opt.hideEffectsEnabled and "ON" or "OFF")
        savePreferences()
    end)
    label("Hides particles and heavy post-processing locally. Turn off to restore.",52)
    label("ESP removed to keep performance smooth.", 36)
    label("Nitrogen-style hitbox expander • local settings", 36)
    local hitboxButton
    local function updateHitboxButton()
        hitboxButton.Text=(hitbox.enabled and "●  " or "○  ").."Hitbox expander"
    end
    hitboxButton=button("",function()
        hitbox.enabled=not hitbox.enabled
        updateHitboxButton()
        refreshHitboxes()
        savePreferences()
    end)
    updateHitboxButton()
    label("Box color (hex only, e.g. #0066FF)", 32)
    local hexInput=valueInput("#0066FF",function() end)
    label("Hitbox size (2–20, Nitrogen example: 5)", 32)
    local sizeInput=valueInput(hitbox.size,function() end)
    local saveStatus=label("Current size: "..hitbox.size.." • Invisible",30)
    button("Save hitbox settings",function()
        local clean=hexInput.Text:gsub("#",""):upper()
        if not clean:match("^%x%x%x%x%x%x$") then
            saveStatus.Text="Invalid color: enter 6 hex digits, like #0066FF"
            return
        end
        local newSize=tonumber(sizeInput.Text)
        if not newSize then
            saveStatus.Text="Invalid size: enter a number from 2 to 20"
            return
        end
        hitbox.size=math.clamp(newSize,2,20)
        hitbox.color=Color3.fromRGB(tonumber(clean:sub(1,2),16),tonumber(clean:sub(3,4),16),tonumber(clean:sub(5,6),16))
        hexInput.Text="#"..clean
        sizeInput.Text=tostring(hitbox.size)
        saveStatus.Text="Saved size "..hitbox.size.." • #"..clean
        savePreferences()
        refreshHitboxes()
    end)
    local visibilityButton
    visibilityButton=button("Hitbox appearance: Invisible",function()
        hitbox.transparency=hitbox.transparency==1 and 0.5 or 1
        visibilityButton.Text=hitbox.transparency==1 and "Hitbox appearance: Invisible" or "Hitbox appearance: Color preview"
        savePreferences()
        refreshHitboxes()
    end)
    button("Use accent color",function() hitbox.color=accent; refreshHitboxes(); savePreferences() end)
    button("Restore original hitboxes",function() hitbox.enabled=false; updateHitboxButton(); restoreAllHitboxes(); savePreferences() end)
    label("Local part changes may not affect server-side hit detection.", 55)
end)
page("Movement", function()
    label("Movement presets • use a preset or fine-tune below",44)
    local presetStatus=label("Current: "..opt.selectedMovementPreset.." • fly "..opt.flySpeed.." / walk "..opt.walkSpeed,42)
    local refreshFlightSlider=function() end
    for _,name in ipairs({"Chill","Balanced","Fast"}) do
        button("Movement: "..name,function()
            setMovementPreset(name); savePreferences()
            presetStatus.Text="Current: "..name.." • fly "..opt.flySpeed.." / walk "..opt.walkSpeed
            refreshFlightSlider()
        end)
    end
    label("Fly • WASD / Space / Left Ctrl", 38)
    local flyButton
    flyButton=button("Fly: OFF",function()
        opt.flyEnabled=not opt.flyEnabled
        if not opt.flyEnabled then stopFlight() end
        flyButton.Text=opt.flyEnabled and "Fly: ON" or "Fly: OFF"
    end)
    local flySpeedLabel=label("Flight speed: "..opt.flySpeed.." (10–"..MAX_FLIGHT_SPEED..")",30)
    local flightTrack=new("Frame",{Size=UDim2.new(1,-20,0,28),BackgroundColor3=Color3.fromRGB(42,42,42),BorderSizePixel=0,Active=true},content)
    new("UICorner",{CornerRadius=UDim.new(0,8)},flightTrack)
    local flightFill=new("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=accent,BorderSizePixel=0},flightTrack)
    new("UICorner",{CornerRadius=UDim.new(0,8)},flightFill)
    local flightThumb=new("Frame",{Size=UDim2.fromOffset(17,17),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},flightTrack)
    new("UICorner",{CornerRadius=UDim.new(1,0)},flightThumb)
    refreshFlightSlider=function()
        local fraction=(opt.flySpeed-10)/(MAX_FLIGHT_SPEED-10)
        flightFill.Size=UDim2.fromScale(fraction,1)
        flightFill.BackgroundColor3=accent
        flightThumb.Position=UDim2.fromScale(fraction,.5)
        flySpeedLabel.Text="Flight speed: "..opt.flySpeed.." (10–"..MAX_FLIGHT_SPEED..")"
    end
    refreshFlightSlider()
    local function adjustFlightSpeed(screenX)
        local width=flightTrack.AbsoluteSize.X
        if width<=0 then return end
        local fraction=math.clamp((screenX-flightTrack.AbsolutePosition.X)/width,0,1)
        opt.flySpeed=math.floor(10+fraction*(MAX_FLIGHT_SPEED-10)+.5)
        opt.selectedMovementPreset="Custom"
        presetStatus.Text="Current: Custom • fly "..opt.flySpeed.." / walk "..opt.walkSpeed
        refreshFlightSlider()
    end
    flightTrack.InputBegan:Connect(function(input)
        if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
        adjustFlightSpeed(input.Position.X)
        local moving,ending
        moving=UserInputService.InputChanged:Connect(function(changed)
            if (input.UserInputType==Enum.UserInputType.MouseButton1 and changed.UserInputType==Enum.UserInputType.MouseMovement) or changed==input then
                adjustFlightSpeed(changed.Position.X)
            end
        end)
        ending=UserInputService.InputEnded:Connect(function(finished)
            if finished~=input and not (input.UserInputType==Enum.UserInputType.MouseButton1 and finished.UserInputType==Enum.UserInputType.MouseButton1) then return end
            moving:Disconnect();ending:Disconnect()
            savePreferences()
        end)
    end)
    label("Drag the slider while flying to change speed instantly.",36)
    local hoverButton
    hoverButton=button("Flight hover: "..(opt.flightHover and "ON" or "OFF"),function()
        opt.flightHover=not opt.flightHover
        hoverButton.Text="Flight hover: "..(opt.flightHover and "ON" or "OFF")
        savePreferences()
    end)
    label("While flying: = speeds up, - slows down (10–300)",40)
    label("Double-tap C fake macro: normal running animation; double-tap again to stop.",52)
    numericSlider("Macro run speed",16,90,opt.fakeMacroSpeed,1,function(value) opt.fakeMacroSpeed=value end)
    numericSlider("Double-tap window (sec)",.2,.7,opt.macroTapWindow,.05,function(value) opt.macroTapWindow=value end)
    local speedButton
    speedButton=button("Walk speed boost: OFF",function()
        opt.speedEnabled=not opt.speedEnabled
        if not opt.speedEnabled then
            local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum and opt.savedWalkSpeed then hum.WalkSpeed=opt.savedWalkSpeed end
            opt.savedWalkSpeed=nil
        end
        speedButton.Text=opt.speedEnabled and "Walk speed boost: ON" or "Walk speed boost: OFF"
    end)
    label("Walk speed (16–100)",30)
    valueInput(opt.walkSpeed,function(text,field)
        opt.walkSpeed=math.clamp(tonumber(text) or 24,16,100); field.Text=tostring(opt.walkSpeed)
        opt.selectedMovementPreset="Custom"; savePreferences()
        presetStatus.Text="Current: Custom • fly "..opt.flySpeed.." / walk "..opt.walkSpeed
    end)
    local noclipButton
    noclipButton=button("Noclip: OFF",function()
        opt.noclipEnabled=not opt.noclipEnabled
        if not opt.noclipEnabled then restoreCollisions() end
        noclipButton.Text=opt.noclipEnabled and "Noclip: ON" or "Noclip: OFF"
    end)
end)
page("Teleport", function()
    label("Teleport controls",36)
    local teleportStatus=label("Choose a shop. Wisteria Hub will look for its location.",46)
    local groups={
        {name="Guns",items={"Revolver","Double Barrel","Shotgun","Tactical Shotgun","SMG","Rifle","RPG","Flamethrower","AK47","P90","Drum Gun","LMG","Silencer"}},
        {name="Armor",items={"Medium Armor","High-Medium Armor","Flame Armor"}},
        {name="Food",items={"Pizza","Taco","Hamburger","Chicken","Popcorn","Donut","Hotdog"}},
        {name="Other",items={"Hospital","Bank","Casino","Police Station"}},
    }
    local function findShop(item)
        local ignored=workspace:FindFirstChild("Ignored")
        local shop=ignored and ignored:FindFirstChild("Shop")
        if not shop then return nil end
        local aliases={
            ["Double Barrel"]={"double-barrel", "double barrel"},
            ["Tactical Shotgun"]={"tacticalshotgun","tactical shotgun"},
            ["High-Medium Armor"]={"high-medium armor","high medium armor"},
            ["Flame Armor"]={"flame armor","flamearmor"},
            ["Flamethrower"]={"flamethrower","flame thrower"},
            ["Drum Gun"]={"drumgun","drum gun"},
            ["SMG"]={"smg"},
        }
        local words=aliases[item] or {item:lower()}
        local best,score=nil,math.huge
        local playerRoot=ownRoot()
        for _,entry in ipairs(shop:GetChildren()) do
            local lower=entry.Name:lower()
            local matched=false
            for _,word in ipairs(words) do
                if lower:find(word,1,true) then matched=true; break end
            end
            if item=="Shotgun" and lower:find("tactical",1,true) then matched=false end
            if item=="Medium Armor" and lower:find("high",1,true) then matched=false end
            -- Avoid choosing an ammo purchase instead of the weapon.
            if matched and not lower:find("ammo",1,true) then
                local part=entry:FindFirstChild("Head") or entry:FindFirstChildWhichIsA("BasePart",true)
                if part and part:IsA("BasePart") then
                    local distance=playerRoot and (part.Position-playerRoot.Position).Magnitude or 0
                    if distance<score then best=part.CFrame; score=distance end
                end
            end
        end
        return best
    end
    local function teleportTo(cf)
        local root=ownRoot()
        if not root or not cf then return false end
        opt.previousTeleportPosition=root.CFrame
        table.insert(teleportHistory,1,root.CFrame)
        if #teleportHistory>8 then table.remove(teleportHistory) end
        root.CFrame=cf*CFrame.new(0,3,0)
        return true
    end
    button("Return to last position",function()
        local root=ownRoot()
        if root and opt.previousTeleportPosition then
            local back=root.CFrame
            root.CFrame=opt.previousTeleportPosition
            opt.previousTeleportPosition=back
            teleportStatus.Text="Returned to previous spot"
        else teleportStatus.Text="No previous teleport yet" end
    end)
    button("Teleport to selected player",function()
        local target=targetRoot()
        if target and teleportTo(target.CFrame*CFrame.new(0,-1,4)) then
            teleportStatus.Text="Teleported to selected player"
        end
    end)
    button("Save my position",function()
        local root=ownRoot(); if root then gui:SetAttribute("SavedX",root.Position.X); gui:SetAttribute("SavedY",root.Position.Y); gui:SetAttribute("SavedZ",root.Position.Z) end
    end)
    button("Teleport to saved position",function()
        local x=gui:GetAttribute("SavedX")
        if x and teleportTo(CFrame.new(x,gui:GetAttribute("SavedY")-3,gui:GetAttribute("SavedZ"))) then
            teleportStatus.Text="Returned to saved position"
        end
    end)
    label("Teleport history • your last 8 starting spots",44)
    local historyStatus=label("History is kept for this play session.",35)
    for index=1,8 do
        button("Return to history spot "..index,function()
            local cf=teleportHistory[index]
            local root=ownRoot()
            if root and cf then
                local current=root.CFrame
                root.CFrame=cf
                opt.previousTeleportPosition=current
                historyStatus.Text="Returned to spot "..index
            else historyStatus.Text="No history spot "..index.." yet" end
        end)
    end
    label("Da Hood shop teleport: finds the shop automatically when available. You can also save a backup spot.",60)
    label("★ Favorite teleports • reopen this tab after changing favorites",48)
    local favoriteCount=0
    for _,group in ipairs(groups) do
        for _,item in ipairs(group.items) do
            local name=group.name.." / "..item
            if favoriteShops[name] then
                favoriteCount+=1
                button("★ Quick TP: "..item,function()
                    local detected=findShop(item)
                    if teleportTo(detected or shopBookmarks[name]) then
                        teleportStatus.Text="Favorite: "..item
                    else teleportStatus.Text="Can't locate "..item.."; try saving its spot" end
                end)
            end
        end
    end
    if favoriteCount==0 then label("No favorites yet • star a shop below.",32) end
    for _,group in ipairs(groups) do
        label(group.name,30)
        for _,item in ipairs(group.items) do
            local name=group.name.." / "..item
            button("Save current spot: "..item,function()
                local root=ownRoot()
                if root then
                    shopBookmarks[name]=root.CFrame
                    teleportStatus.Text=(savePreferences() and "Saved permanently: " or "Saved for this session: ")..item
                end
            end)
            button("TP to "..item,function()
                local detected=findShop(item)
                if teleportTo(detected or shopBookmarks[name]) then
                    teleportStatus.Text="Teleported to "..item..(detected and " (found on map)" or " (saved spot)")
                else
                    teleportStatus.Text="Could not find "..item..". Stand by the shop and save its spot once."
                end
            end)
            local favoriteButton
            favoriteButton=button((favoriteShops[name] and "★ " or "☆ ").."Favorite: "..item,function()
                favoriteShops[name]=not favoriteShops[name]
                favoriteButton.Text=(favoriteShops[name] and "★ " or "☆ ").."Favorite: "..item
                teleportStatus.Text="Favorites changed • reopen Teleport to update shortcuts"
                savePreferences()
            end)
        end
    end
    label(saveAvailable and "Saved backup spots load next time. Automatic detection depends on the current Da Hood map." or "This executor has no file saving. Automatic detection may still work; backups last only this session.",70)
end)
page("Settings", function()
    label("Choose an accent color", 36)
    for _, name in ipairs({"Mono","Black","Silver","Purple","Lavender","Blue","Cyan","Red","Burgundy","Pink","Emerald","Gold","Peach"}) do
        local b = button(name, function() accent=presets[name]; updateAccent(); savePreferences() end)
        table.insert(controls,b)
    end
    label("Custom accent color (hex, e.g. #00FFAA)",40)
    valueInput("#FFFFFF",function(text,field)
        local clean=text:gsub("#","")
        if clean:match("^%x%x%x%x%x%x$") then
            accent=Color3.fromRGB(tonumber(clean:sub(1,2),16),tonumber(clean:sub(3,4),16),tonumber(clean:sub(5,6),16))
            updateAccent()
            savePreferences()
            field.Text="#"..clean:upper()
        else field.Text="Invalid hex color" end
    end)
    label("Menu background styles",32)
    local backgroundStatus=label("Background: "..opt.menuBackgroundStyle,32)
    for _,name in ipairs({"Midnight","Glass","Charcoal","Plum"}) do
        button("Background: "..name,function()
            opt.menuBackgroundStyle=name;applyMenuBackground();savePreferences()
            backgroundStatus.Text="Background: "..name
        end)
    end
    label("Custom background • enter a hex color",38)
    valueInput("#1C1C1C",function(text,field)
        local color=parseHexColor(text)
        if not color then field.Text="Invalid hex"; return end
        opt.menuBackgroundStyle="Custom";opt.menuCustomColor=color
        applyMenuBackground();savePreferences()
        backgroundStatus.Text="Background: Custom"
    end)
    label("Compact menu",32)
    numericSlider("Menu size",.7,1.25,opt.menuScale,.05,function(value) opt.menuScale=value;applyCompactMenu() end)
    numericSlider("Menu transparency",0,.55,opt.menuTransparency,.05,function(value) opt.menuTransparency=value;applyCompactMenu() end)
    local compactButton
    compactButton=button("Compact layout: "..(opt.compactMenu and "ON" or "OFF"),function()
        opt.compactMenu=not opt.compactMenu
        applyCompactMenu()
        compactButton.Text="Compact layout: "..(opt.compactMenu and "ON" or "OFF")
        savePreferences()
    end)
    local toolbarButton
    toolbarButton=button("Mini floating toolbar: "..(opt.quickToolbarEnabled and "ON" or "OFF"),function()
        opt.quickToolbarEnabled=not opt.quickToolbarEnabled
        quickGui.Enabled=opt.quickToolbarEnabled
        toolbarButton.Text="Mini floating toolbar: "..(opt.quickToolbarEnabled and "ON" or "OFF")
        savePreferences()
    end)
    label("Drag the mini toolbar by its left handle. Use Reset if movement glitches.",54)
    label("Custom keybinds • C is reserved for double-tap macro. No Shift needed!",48)
    local keyStatus=label("Menu: "..opt.menuKeyName.." • Fly: "..opt.flyKeyName.." • Aim: "..opt.holdKey,42)
    label("Menu key (P, B, G, H, J, K, L, N, O, V, Z, Insert)",48)
    valueInput(opt.menuKeyName,function(text,field)
        local name=text:gsub("%s","")
        if not setBind("menu",name) then field.Text="Invalid or conflicting key" else field.Text=name end
        keyStatus.Text="Menu: "..opt.menuKeyName.." • Fly: "..opt.flyKeyName.." • Aim: "..opt.holdKey
    end)
    label("Fly toggle key (same choices, or None)",34)
    valueInput(opt.flyKeyName,function(text,field)
        local name=text:gsub("%s","")
        if not setBind("fly",name) then field.Text="Invalid or conflicting key" else field.Text=name end
        keyStatus.Text="Menu: "..opt.menuKeyName.." • Fly: "..opt.flyKeyName.." • Aim: "..opt.holdKey
    end)
    label("Target hold key (same choices or RightMouse)",44)
    valueInput(opt.holdKey,function(text,field)
        local name=text:gsub("%s","")
        if not setBind("target",name) then field.Text="Invalid or conflicting key" else field.Text=name end
        keyStatus.Text="Menu: "..opt.menuKeyName.." • Fly: "..opt.flyKeyName.." • Aim: "..opt.holdKey
    end)
    label("Target switch key (default B)",32)
    valueInput(opt.targetSwitchKey,function(text,field)
        local value=text:gsub("%s","")
        if Enum.KeyCode[value] and value~="C" and value~=opt.holdKey and value~=opt.menuKeyName and value~=opt.flyKeyName then
            opt.targetSwitchKey=value;savePreferences();field.Text=value
        else field.Text="Key conflict" end
    end)
    label("Quick settings wheel key (default G)",36)
    valueInput(opt.quickWheelKey,function(text,field)
        local value=text:gsub("%s","")
        if Enum.KeyCode[value] and value~="C" and value~=opt.menuKeyName and value~=opt.holdKey then
            opt.quickWheelKey=value;savePreferences();field.Text=value
        else field.Text="Key conflict" end
    end)
    label("Minimal HUD key (default H)",34)
    valueInput(opt.minimalHudKey,function(text,field)
        local value=text:gsub("%s","")
        if Enum.KeyCode[value] and value~="C" and value~=opt.menuKeyName and value~=opt.holdKey then
            opt.minimalHudKey=value;savePreferences();field.Text=value
        else field.Text="Key conflict" end
    end)
    label("Performance mode",32)
    local performanceButton
    performanceButton=button("Performance mode: "..(performanceMode and "ON" or "OFF"),function()
        setPerformanceMode(not performanceMode)
        performanceButton.Text="Performance mode: "..(performanceMode and "ON" or "OFF")
        savePreferences()
    end)
    label("Cuts rain animation, particles, heavy effects, and reduces hitbox refresh rate.",55)
    local adaptiveButton
    adaptiveButton=button("Adaptive performance: "..(opt.adaptivePerfEnabled and "ON" or "OFF"),function()
        opt.adaptivePerfEnabled=not opt.adaptivePerfEnabled
        if not opt.adaptivePerfEnabled then setAdaptiveReduced(false) end
        adaptiveButton.Text="Adaptive performance: "..(opt.adaptivePerfEnabled and "ON" or "OFF")
        savePreferences()
    end)
    label("Auto-simplifies effects below ~43 FPS; restores them after FPS stays above ~55.",60)
    label("Recent measured FPS: "..(opt.adaptivePerfEnabled and tostring(lastMeasuredFps) or "enable adaptive mode to measure"),43)
    label("Settings profiles • each saves the current layout, weather, speeds and keybinds",52)
    local profilesStatus=label("Choose a slot to save or load your look.",35)
    for _,slot in ipairs({"Profile 1","Profile 2","Profile 3"}) do
        button("Save: "..slot,function()
            settingsProfiles[slot]=captureProfile()
            profilesStatus.Text=savePreferences() and ("Saved "..slot) or ("Session-only "..slot)
        end)
        button("Load: "..slot,function()
            if applyProfile(settingsProfiles[slot]) then
                profilesStatus.Text="Loaded "..slot.." • reopen tab to refresh controls"
                savePreferences()
            else profilesStatus.Text="Nothing saved in "..slot end
        end)
    end
    label("Auto-load & backup",32)
    local saveStatus=label(saveAvailable and "Auto-load ON: saved settings apply whenever this script starts." or "Auto-load unavailable: Xeno must support readfile / writefile.", 58)
    button("Save settings now",function()
        saveStatus.Text=savePreferences() and "Saved! These settings will auto-load next time." or "Only saved for this play session (no file access)."
    end)
    label("Reset just one feature group",32)
    local groupResetStatus=label("Favorites and profiles stay saved.",32)
    button("Reset weather effects only",function()
        setRain(false);opt.particleEnabled=false;opt.petalsEnabled=false;opt.snowfallEnabled=false
        opt.shootingStarsEnabled=false;opt.thunderEnabled=false;opt.puddlesEnabled=false;opt.firefliesEnabled=false
        setWeatherPreset("Night");savePreferences();groupResetStatus.Text="Weather reset to clear night"
    end)
    button("Reset movement only",function()
        opt.flyEnabled=false;stopFlight();opt.fakeMacroEnabled=false;opt.speedEnabled=false
        local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum and opt.savedWalkSpeed then hum.WalkSpeed=opt.savedWalkSpeed end
        opt.savedWalkSpeed=nil;opt.noclipEnabled=false;restoreCollisions()
        savePreferences();groupResetStatus.Text="Movement reset"
    end)
    button("Reset targeting only",function()
        opt.holdActive=false;opt.lockedTarget=nil;autoTarget=nil;opt.assistAccumulator=Vector2.zero
        opt.autoTargetEnabled=false;opt.smoothAssistEnabled=false
        savePreferences();groupResetStatus.Text="Targeting reset"
    end)
    label("Emergency reset • does not erase favorite teleports or profiles",50)
    local resetStatus=label("Turns off movement, targeting, hitbox and temporary weather effects.",48)
    button("Emergency reset now",function()
        emergencyReset()
        quickFly.Text="Fly";quickHit.Text="Hit"
        resetStatus.Text="Reset complete. Your saved locations and profiles are intact."
    end)
end)

-- Optional, client-side player camera and cosmetic tools.
-- None of these features send damage, inventory or remote requests.
local playerTools={picked=nil,mode="Off",freecam=false,freePosition=nil,freeYaw=0,freePitch=0,
    tracer=false,ghost=false,freezePreview=false,horns=nil,decor={},savedLocal={},
    sessionStart=os.clock(),freeSpeed=45,antiAFK=false,following=false}
local camera=workspace.CurrentCamera
local originalCamera={type=nil,subject=nil,fov=nil}
local function playerRoot(plr)
    local character=plr and plr.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end
local function resolvePlayer(query)
    query=tostring(query or ""):lower():gsub("^%s+",""):gsub("%s+$","")
    if query=="" then return nil end
    local match
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=player then
            if plr.Name:lower()==query or plr.DisplayName:lower()==query then return plr end
            if not match and (plr.Name:lower():sub(1,#query)==query or plr.DisplayName:lower():sub(1,#query)==query) then match=plr end
        end
    end
    return match
end
local function restoreCamera()
    camera=workspace.CurrentCamera or camera
    if not camera then return end
    camera.CameraType=Enum.CameraType.Custom
    local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then camera.CameraSubject=humanoid end
    if originalCamera.fov then camera.FieldOfView=originalCamera.fov end
    playerTools.mode="Off";playerTools.freecam=false
end
local function setCameraMode(mode)
    if mode=="Off" then restoreCamera();return end
    camera=workspace.CurrentCamera or camera
    if not camera then return end
    local target=playerTools.picked
    if mode~="Freecam" and not (target and target.Character and playerRoot(target)) then
        restoreCamera();return
    end
    if playerTools.mode=="Off" then
        originalCamera.type=camera.CameraType
        originalCamera.subject=camera.CameraSubject
        originalCamera.fov=camera.FieldOfView
    end
    playerTools.mode=mode
    playerTools.freecam=(mode=="Freecam")
    if mode=="Freecam" then
        playerTools.freePosition=camera.CFrame.Position
        local look=camera.CFrame.LookVector
        playerTools.freePitch=math.asin(math.clamp(look.Y,-1,1))
        playerTools.freeYaw=math.atan2(-look.X,-look.Z)
        camera.CameraType=Enum.CameraType.Scriptable
    elseif mode=="First-person" then
        camera.CameraType=Enum.CameraType.Scriptable
    else
        camera.CameraType=Enum.CameraType.Custom
        camera.CameraSubject=target.Character:FindFirstChildOfClass("Humanoid")
    end
end
local tracerGui=new("ScreenGui",{Name="WisteriaTracer",ResetOnSpawn=false,DisplayOrder=3,IgnoreGuiInset=true},parent)
local tracerLine=new("Frame",{Size=UDim2.fromOffset(2,2),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=accent,BorderSizePixel=0,Visible=false},tracerGui)
local tracerElapsed=0
track(RunService.RenderStepped:Connect(function(dt)
    if not camera or camera~=workspace.CurrentCamera then camera=workspace.CurrentCamera end
    if not camera then return end
    if playerTools.mode=="First-person" then
        local head=playerTools.picked and playerTools.picked.Character and playerTools.picked.Character:FindFirstChild("Head")
        if head then camera.CFrame=head.CFrame else restoreCamera() end
    elseif playerTools.mode=="Third-person" then
        local hum=playerTools.picked and playerTools.picked.Character and playerTools.picked.Character:FindFirstChildOfClass("Humanoid")
        if not hum then restoreCamera() elseif camera.CameraSubject~=hum then camera.CameraSubject=hum end
    elseif playerTools.mode=="Freecam" then
        local speed=playerTools.freeSpeed*dt
        local direction=Vector3.zero
        if UserInputService:GetFocusedTextBox()==nil then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction+=Vector3.new(0,0,-1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction+=Vector3.new(0,0,1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction+=Vector3.new(-1,0,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction+=Vector3.new(1,0,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction+=Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction-=Vector3.yAxis end
        end
        local rotation=CFrame.fromEulerAnglesYXZ(playerTools.freePitch,playerTools.freeYaw,0)
        if direction.Magnitude>0 then playerTools.freePosition+=rotation:VectorToWorldSpace(direction.Unit)*speed end
        camera.CFrame=CFrame.new(playerTools.freePosition)*rotation
    end
    tracerElapsed+=dt
    if tracerElapsed<.08 then return end
    tracerElapsed=0;tracerLine.Visible=false
    local root=playerRoot(playerTools.picked)
    if playerTools.tracer and root then
        local pos,onScreen=camera:WorldToViewportPoint(root.Position)
        if onScreen and pos.Z>0 then
            local start=Vector2.new(camera.ViewportSize.X*.5,camera.ViewportSize.Y)
            local target=Vector2.new(pos.X,pos.Y)
            local delta=target-start
            tracerLine.BackgroundColor3=accent
            tracerLine.Position=UDim2.fromOffset((start.X+target.X)*.5,(start.Y+target.Y)*.5)
            tracerLine.Size=UDim2.fromOffset(delta.Magnitude,2)
            tracerLine.Rotation=math.deg(math.atan2(delta.Y,delta.X))
            tracerLine.Visible=true
        end
    end
end))
track(UserInputService.InputChanged:Connect(function(input)
    if playerTools.mode=="Freecam" and input.UserInputType==Enum.UserInputType.MouseMovement
        and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        playerTools.freeYaw-=input.Delta.X*.003
        playerTools.freePitch=math.clamp(playerTools.freePitch-input.Delta.Y*.003,-1.5,1.5)
    end
end))
local function setGhost(enabled)
    playerTools.ghost=enabled
    for part,original in pairs(playerTools.savedLocal) do
        if part.Parent then pcall(function() part.LocalTransparencyModifier=original end) end
        playerTools.savedLocal[part]=nil
    end
    if enabled and player.Character then
        for _,item in ipairs(player.Character:GetDescendants()) do
            if item:IsA("BasePart") then
                playerTools.savedLocal[item]=item.LocalTransparencyModifier
                item.LocalTransparencyModifier=.95
            end
        end
    end
end
track(player.CharacterAdded:Connect(function()
    restoreCamera();playerTools.savedLocal={}
    if playerTools.ghost then task.defer(function() setGhost(true) end) end
end))
local function clearHorns()
    for _,obj in ipairs(playerTools.decor) do if obj.Parent then obj:Destroy() end end
    table.clear(playerTools.decor);playerTools.horns=nil
end
local catalogHorns={
    ["Fiery Horns of the Netherworld"]=215718515,
    ["Frozen Horns of the Frigid Planes"]=74891470,
    ["Poisoned Horns of the Toxic Wasteland"]=1744060292,
}
local function makeHorns(style)
    clearHorns()
    local assetId=catalogHorns[style]
    if not assetId then return false,"Unknown limited" end
    local character=player.Character
    local humanoid=character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false,"Character unavailable" end
    -- Some Roblox clients/executors restrict catalog asset loading. Fail visibly.
    local ok,models=pcall(function() return game:GetObjects("rbxassetid://"..assetId) end)
    if not ok or type(models)~="table" then return false,"Catalog asset loading is blocked" end
    local accessory
    for _,model in ipairs(models) do
        if model:IsA("Accessory") then accessory=model
        else accessory=model:FindFirstChildWhichIsA("Accessory",true) end
        if accessory then
            accessory.Parent=nil
            break
        end
    end
    for _,model in ipairs(models) do if model~=accessory then model:Destroy() end end
    if not accessory then return false,"The catalog item did not provide an accessory" end
    accessory.Name="WisteriaPreview_"..style
    local equipped=pcall(function() humanoid:AddAccessory(accessory) end)
    if not equipped then accessory:Destroy();return false,"Could not attach the accessory" end
    playerTools.horns=style
    table.insert(playerTools.decor,accessory)
    return true,"Preview applied locally"
end
track(Players.PlayerRemoving:Connect(function(plr)
    if playerTools.picked==plr then playerTools.picked=nil;restoreCamera() end
end))
track(player.Idled:Connect(function()
    if not playerTools.antiAFK then return end
    pcall(function()
        local vu=game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.zero)
    end)
end))
local followElapsed=0
track(RunService.Heartbeat:Connect(function(dt)
    if not playerTools.following then return end
    followElapsed+=dt
    if followElapsed<.4 then return end
    followElapsed=0
    local root=playerRoot(playerTools.picked)
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if root and hum and hum.Health>0 then
        hum:MoveTo(root.Position-Vector3.new(0,0,4))
    else playerTools.following=false end
end))
page("Players + Spectate",function()
    label("Pick a player in this server by username or display name.",46)
    local input=valueInput(playerTools.picked and playerTools.picked.Name or "",function() end)
    local status=label(playerTools.picked and ("Selected: "..playerTools.picked.Name) or "No player selected",38)
    button("Find player",function()
        playerTools.picked=resolvePlayer(input.Text)
        status.Text=playerTools.picked and ("Selected: "..playerTools.picked.Name) or "Not found in this server"
    end)
    button("Nearest player",function()
        local root=playerRoot(player)
        local nearest,distance=nil,math.huge
        if root then for _,plr in ipairs(Players:GetPlayers()) do
            local other=plr~=player and playerRoot(plr)
            if other and (other.Position-root.Position).Magnitude<distance then
                distance=(other.Position-root.Position).Magnitude;nearest=plr
            end
        end end
        playerTools.picked=nearest
        status.Text=nearest and ("Selected: "..nearest.Name) or "No nearby player"
    end)
    button("Next player",function()
        local pool={}
        for _,plr in ipairs(Players:GetPlayers()) do if plr~=player then table.insert(pool,plr) end end
        table.sort(pool,function(a,b) return a.Name<b.Name end)
        if #pool==0 then status.Text="No players available";return end
        local index=table.find(pool,playerTools.picked) or 0
        playerTools.picked=pool[index%#pool+1]
        status.Text="Selected: "..playerTools.picked.Name
    end)
    button("Spectate: third-person",function() setCameraMode("Third-person") end)
    button("Spectate: first-person",function() setCameraMode("First-person") end)
    button("Stop spectating / restore camera",restoreCamera)
    local tracerButton
    tracerButton=button("Selected-player tracer: "..(playerTools.tracer and "ON" or "OFF"),function()
        playerTools.tracer=not playerTools.tracer
        tracerButton.Text="Selected-player tracer: "..(playerTools.tracer and "ON" or "OFF")
    end)
    button("Copy selected username",function()
        if playerTools.picked and type(setclipboard)=="function" then setclipboard(playerTools.picked.Name) end
    end)
    button("Teleport to selected player",function()
        local root=playerRoot(player);local target=playerRoot(playerTools.picked)
        if root and target then root.CFrame=target.CFrame*CFrame.new(0,0,4) end
    end)
    local followButton
    followButton=button("Follow selected: OFF",function()
        playerTools.following=not playerTools.following
        followButton.Text="Follow selected: "..(playerTools.following and "ON" or "OFF")
    end)
    button("Show selected distance",function()
        local a,b=playerRoot(player),playerRoot(playerTools.picked)
        status.Text=a and b and string.format("%.0f studs away", (a.Position-b.Position).Magnitude) or "Player not available"
    end)
    label("Spectate and tracers are visual only. Remote damage, bringing players and server-wide freezing aren't implemented.",70)
end)
page("Freecam",function()
    label("Explore without moving your avatar. Hold RIGHT MOUSE to look; WASD to move; Space/Ctrl up/down.",65)
    button("Start Freecam",function() setCameraMode("Freecam") end)
    button("Exit Freecam / restore camera",restoreCamera)
    numericSlider("Freecam speed",10,150,playerTools.freeSpeed,5,function(v) playerTools.freeSpeed=v end)
    label("Your character stays where it is. Freecam does not make it invisible to other players.",58)
end)
page("Cosmetics",function()
    label("Client-side avatar effects (other players may not see them).",42)
    local ghostButton
    ghostButton=button("Ghost appearance: "..(playerTools.ghost and "ON" or "OFF"),function()
        setGhost(not playerTools.ghost)
        ghostButton.Text="Ghost appearance: "..(playerTools.ghost and "ON" or "OFF")
    end)
    label("Ghost hides your body, accessories and equipped tools from YOUR view only.",48)
    label("Roblox LIMITED horns • catalog designs, not generic shapes",45)
    local hornStatus=label("Choose a limited below to preview it.",43)
    for _,style in ipairs({
        "Fiery Horns of the Netherworld",
        "Frozen Horns of the Frigid Planes",
        "Poisoned Horns of the Toxic Wasteland",
    }) do
        button(style,function()
            local ok,message=makeHorns(style)
            hornStatus.Text=ok and ("Equipped preview: "..style) or ("Can't load: "..message)
        end)
    end
    button("Remove horns",clearHorns)
    button("Restore my avatar visuals",function()setGhost(false);clearHorns();restoreCamera() end)
    label("These are local accessory previews and may be blocked by Roblox. Other players won't see them unless the game's server equips them.",75)
end)
page("Session + Safety",function()
    local minutes=math.floor((os.clock()-playerTools.sessionStart)/60)
    label("Player: "..player.Name.." • Session: "..minutes.." min",40)
    local ping=math.floor(player:GetNetworkPing()*1000)
    label("Estimated ping: "..ping.." ms",35)
    local afkButton
    afkButton=button("Anti-AFK: "..(playerTools.antiAFK and "ON" or "OFF"),function()
        playerTools.antiAFK=not playerTools.antiAFK
        afkButton.Text="Anti-AFK: "..(playerTools.antiAFK and "ON" or "OFF")
    end)
    button("Restore camera + character",function()
        restoreCamera();setGhost(false);clearHorns();playerTools.tracer=false;playerTools.following=false
    end)
    button("Rejoin current game",function()
        local ok,err=pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,player)
        end)
        if not ok then warn("[Wisteria Hub] Rejoin failed: "..tostring(err)) end
    end)
    button("Leave server",function() player:Kick("Left using Wisteria Hub") end)
    label("Server-wide freeze and true player invisibility require server behavior not verified by these screenshots.",63)
end)

tabs[1].TextColor3=accent
label("Wisteria Hub v3.2",36)
label("Choose Main again to open Target Aim settings.",44)
label(opt.menuKeyName.." or the floating Menu button: hide/show.",36)

-- Drag by the title bar, with mouse or touch.
do
local dragging, dragStart, panelStart = false, nil, nil
track(bar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging=true; dragStart=input.Position; panelStart=panel.Position
    end
end))
track(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-dragStart
        panel.Position=UDim2.new(panelStart.X.Scale,panelStart.X.Offset+delta.X,panelStart.Y.Scale,panelStart.Y.Offset+delta.Y)
    end
end))
track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end))
end
track(player.CharacterAdded:Connect(function()
    opt.fakeMacroEnabled=false;opt.lastMacroTap=0;opt.savedWalkSpeed=nil
end))
track(UserInputService.InputBegan:Connect(function(input, processed)
    if UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode==Enum.KeyCode.C then
        local now=os.clock()
        if now-opt.lastMacroTap<=opt.macroTapWindow then
            opt.fakeMacroEnabled=not opt.fakeMacroEnabled
            opt.lastMacroTap=0
            if not opt.fakeMacroEnabled and not opt.speedEnabled then
                local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum and opt.savedWalkSpeed then hum.WalkSpeed=opt.savedWalkSpeed end
                opt.savedWalkSpeed=nil
            end
        else opt.lastMacroTap=now end
        return
    end
    if processed then return end
    if input.KeyCode.Name==opt.quickWheelKey then
        opt.quickWheelVisible=not opt.quickWheelVisible
        wheelGui.Enabled=opt.quickWheelVisible and not opt.minimalHud
    elseif input.KeyCode.Name==opt.minimalHudKey then
        opt.minimalHud=not opt.minimalHud
        gui.Enabled=false;wheelGui.Enabled=false;opt.quickWheelVisible=false
        quickGui.Enabled=opt.quickToolbarEnabled and not opt.minimalHud
        toggleGui.Enabled=not opt.minimalHud
        statusGui.Enabled=not opt.minimalHud
    elseif input.KeyCode==Enum.KeyCode.Equals and opt.flyEnabled then
        opt.flySpeed=math.clamp(opt.flySpeed+10,10,MAX_FLIGHT_SPEED);opt.selectedMovementPreset="Custom";savePreferences()
    elseif input.KeyCode==Enum.KeyCode.Minus and opt.flyEnabled then
        opt.flySpeed=math.clamp(opt.flySpeed-10,10,MAX_FLIGHT_SPEED);opt.selectedMovementPreset="Custom";savePreferences()
    elseif input.KeyCode.Name==opt.menuKeyName then
        gui.Enabled=not gui.Enabled
    elseif opt.flyKeyName~="None" and input.KeyCode.Name==opt.flyKeyName then
        opt.flyEnabled=not opt.flyEnabled
        if not opt.flyEnabled then stopFlight() end
    end
end))

local stopped=false
local function shutdown()
    if stopped then return end
    stopped=true
    restoreCamera()
    playerTools.following=false
    setGhost(false)
    clearHorns()
    if tracerGui.Parent then tracerGui:Destroy() end
    RunService:UnbindFromRenderStep(aimRenderBinding)
    for _,connection in ipairs(liveConnections) do connection:Disconnect() end
    restoreAllHitboxes()
    for plr in pairs(visuals) do cleanupVisual(plr) end
    stopFlight()
    restoreCollisions()
    local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and opt.savedWalkSpeed then humanoid.WalkSpeed=opt.savedWalkSpeed end
    setWeatherPreset("Normal")
    setRain(false)
    if gui.Parent then gui:Destroy() end
    if rainGui.Parent then rainGui:Destroy() end
    if moonGui.Parent then moonGui:Destroy() end
    if butterflyFX.gui.Parent then butterflyFX.gui:Destroy() end
    if worldFX.folder.Parent then worldFX.folder:Destroy() end
    if quickGui.Parent then quickGui:Destroy() end
    if wheelGui.Parent then wheelGui:Destroy() end
    if statusGui.Parent then statusGui:Destroy() end
    if toggleGui.Parent then toggleGui:Destroy() end
end
environment.PurrvotionCleanup=shutdown
print("[Wisteria Hub] v3.2 ready")
