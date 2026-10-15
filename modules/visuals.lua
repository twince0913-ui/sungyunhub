-- 성윤HUB Visuals Module

return function(S, Utils, VisualsTab, Rayfield)
    local Players = Utils.Players
    local RunService = Utils.RunService
    local UserInputService = Utils.UserInputService
    local Camera = Utils.Camera
    local LocalPlayer = Utils.LocalPlayer
    local CoreGui = Utils.CoreGui
    local SoundService = game:GetService("SoundService")
    local Debris = game:GetService("Debris")

    -- =========================================
    -- ESP
    -- =========================================
    local espCache = {}
    local function createESP(p)
        if espCache[p] then return end
        espCache[p] = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            HealthBar = Drawing.new("Line"),
            HealthBack = Drawing.new("Line"),
            Distance = Drawing.new("Text"),
            Weapon = Drawing.new("Text"),
        }
        for _, d in pairs(espCache[p]) do d.Visible = false end
        espCache[p].Box.Thickness = 1
        espCache[p].Box.Filled = false
        espCache[p].Name.Size = 14
        espCache[p].Name.Center = true
        espCache[p].Name.Outline = true
        espCache[p].Name.Color = Color3.fromRGB(255, 255, 255)
        espCache[p].HealthBar.Thickness = 2
        espCache[p].HealthBack.Thickness = 2
        espCache[p].HealthBack.Color = Color3.fromRGB(0, 0, 0)
        espCache[p].Distance.Size = 12
        espCache[p].Distance.Center = true
        espCache[p].Distance.Outline = true
        espCache[p].Distance.Color = Color3.fromRGB(200, 200, 200)
        espCache[p].Weapon.Size = 12
        espCache[p].Weapon.Center = true
        espCache[p].Weapon.Outline = true
        espCache[p].Weapon.Color = Color3.fromRGB(255, 200, 100)
    end

    local function removeESP(p)
        if espCache[p] then
            for _, d in pairs(espCache[p]) do pcall(function() d:Remove() end) end
            espCache[p] = nil
        end
    end

    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer then createESP(p) end
    end
    Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then createESP(p) end end)
    Players.PlayerRemoving:Connect(removeESP)

    local function getWeaponName(p)
        local vms = workspace:FindFirstChild("ViewModels")
        if not vms then return "" end
        for _, m in vms:GetChildren() do
            if m:IsA("Model") then
                local sp = m.Name:find(" - ", 1, true)
                if sp and m.Name:sub(1, sp-1) == p.Name then
                    return m.Name:sub(sp+3)
                end
            end
        end
        return ""
    end

    -- 최적화: 30fps 제한
    local lastESP = 0
    RunService.RenderStepped:Connect(function()
        local now = tick()
        if now - lastESP < 0.03 then return end
        lastESP = now

        for p, d in pairs(espCache) do
            local ch = p.Character
            local show = S.ESP and ch and Utils.getRoot(ch) and Utils.isAlive(p)
            if show then
                local hrp = Utils.getRoot(ch)
                local head = ch:FindFirstChild("Head")
                local hum = Utils.getHum(ch)
                local rp, on = Camera:WorldToViewportPoint(hrp.Position)
                if on then
                    local tp = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or rp
                    local bp = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local h = math.abs(tp.Y - bp.Y)
                    local w = h / 2
                    local x, y = rp.X, tp.Y

                    d.Box.Visible = S.ESPBox
                    d.Box.Size = Vector2.new(w, h)
                    d.Box.Position = Vector2.new(x - w/2, y)
                    d.Box.Color = S.ESPTeamColor and (p.TeamColor and p.TeamColor.Color or Color3.fromRGB(255, 50, 50)) or Color3.fromRGB(255, 50, 50)

                    d.Name.Visible = S.ESPName
                    d.Name.Text = p.Name
                    d.Name.Position = Vector2.new(x, y - 16)

                    if S.ESPHealth and hum then
                        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        d.HealthBack.Visible = true
                        d.HealthBack.From = Vector2.new(x - w/2 - 6, y + h)
                        d.HealthBack.To = Vector2.new(x - w/2 - 6, y)
                        d.HealthBar.Visible = true
                        d.HealthBar.From = Vector2.new(x - w/2 - 6, y + h)
                        d.HealthBar.To = Vector2.new(x - w/2 - 6, y + h * (1 - pct))
                        d.HealthBar.Color = Color3.fromRGB(255 * (1 - pct), 255 * pct, 0)
                    else
                        d.HealthBar.Visible = false
                        d.HealthBack.Visible = false
                    end

                    d.Distance.Visible = S.ESPDistance
                    local mrp = Utils.getRoot(LocalPlayer.Character)
                    if mrp then
                        d.Distance.Text = tostring(math.floor((hrp.Position - mrp.Position).Magnitude)) .. "m"
                        d.Distance.Position = Vector2.new(x, y + h + 2)
                    end

                    d.Weapon.Visible = S.ESPWeapon
                    d.Weapon.Text = getWeaponName(p)
                    d.Weapon.Position = Vector2.new(x, y + h + 16)
                else
                    for _, o in pairs(d) do o.Visible = false end
                end
            else
                for _, o in pairs(d) do o.Visible = false end
            end
        end
    end)

    VisualsTab:CreateToggle({Name="ESP", CurrentValue=false, Flag="ESP", Callback=function(v) S.ESP=v end})
    VisualsTab:CreateToggle({Name="  Box", CurrentValue=false, Flag="ESPBox", Callback=function(v) S.ESPBox=v end})
    VisualsTab:CreateToggle({Name="  Name", CurrentValue=false, Flag="ESPName", Callback=function(v) S.ESPName=v end})
    VisualsTab:CreateToggle({Name="  Health", CurrentValue=false, Flag="ESPHealth", Callback=function(v) S.ESPHealth=v end})
    VisualsTab:CreateToggle({Name="  Distance", CurrentValue=false, Flag="ESPDistance", Callback=function(v) S.ESPDistance=v end})
    VisualsTab:CreateToggle({Name="  Weapon", CurrentValue=false, Flag="ESPWeapon", Callback=function(v) S.ESPWeapon=v end})
    VisualsTab:CreateToggle({Name="  Team Color", CurrentValue=true, Flag="ESPTeam", Callback=function(v) S.ESPTeamColor=v end})

    -- =========================================
    -- CROSSHAIR
    -- =========================================
    local cGui = Instance.new("ScreenGui")
    cGui.Name = "성윤HUBCross"
    cGui.ResetOnSpawn = false
    cGui.Parent = CoreGui

    local function mkLine()
        local f = Instance.new("Frame")
        f.BackgroundColor3 = S.CrosshairColor
        f.BorderSizePixel = 0
        f.Visible = false
        f.Parent = cGui
        return f
    end

    local chL = {Top=mkLine(), Bottom=mkLine(), Left=mkLine(), Right=mkLine(), Center=mkLine()}

    local function updateCH()
        local v = S.Crosshair
        for _, l in pairs(chL) do l.Visible = v end
        if not v then return end
        for _, l in pairs(chL) do l.BackgroundColor3 = S.CrosshairColor end
        chL.Top.Size = UDim2.new(0, 2, 0, 10); chL.Top.Position = UDim2.new(0.5, -1, 0.5, -14)
        chL.Bottom.Size = UDim2.new(0, 2, 0, 10); chL.Bottom.Position = UDim2.new(0.5, -1, 0.5, 4)
        chL.Left.Size = UDim2.new(0, 10, 0, 2); chL.Left.Position = UDim2.new(0.5, -14, 0.5, -1)
        chL.Right.Size = UDim2.new(0, 10, 0, 2); chL.Right.Position = UDim2.new(0.5, 4, 0.5, -1)
        chL.Center.Size = UDim2.new(0, 2, 0, 2); chL.Center.Position = UDim2.new(0.5, -1, 0.5, -1)
    end
    updateCH()

    VisualsTab:CreateToggle({Name="Crosshair", CurrentValue=false, Flag="Cross", Callback=function(v) S.Crosshair=v updateCH() end})
    VisualsTab:CreateColorPicker({Name="Crosshair Color", Color=Color3.fromRGB(0,255,0), Flag="CrossColor", Callback=function(c) S.CrosshairColor=c updateCH() end})

    -- =========================================
    -- HIT SOUND (여러 종류)
    -- =========================================
    local hitSound = Instance.new("Sound")
    hitSound.SoundId = S.HitSoundID
    hitSound.Parent = SoundService

    local hitSoundOptions = {
        ["기본"] = "rbxassetid://6607204501",
        ["Neverlose"] = "rbxassetid://6607204501",
        ["Gamesense"] = "rbxassetid://4817809188",
        ["Skeet"] = "rbxassetid://5447626464",
        ["Rust"] = "rbxassetid://5043539486",
        ["Bell"] = "rbxassetid://6534947240",
        ["Bubble"] = "rbxassetid://6534947588",
        ["Minecraft"] = "rbxassetid://4018616850",
        ["Osu"] = "rbxassetid://7149255551",
        ["TF2"] = "rbxassetid://2868331684",
    }

    pcall(function()
        local II = require(LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ItemInterface)
        if II and II.DamageEffect then
            local old = II.DamageEffect
            II.DamageEffect = function(self, ...)
                if S.HitSound then
                    local s = hitSound:Clone()
                    s.Volume = S.HitSoundVolume
                    s.SoundId = S.HitSoundID
                    s.Parent = SoundService
                    s:Play()
                    Debris:AddItem(s, 2)
                end
                return old(self, ...)
            end
        end
    end)

    VisualsTab:CreateToggle({Name="Hit Sound", CurrentValue=false, Flag="HitSound", Callback=function(v) S.HitSound=v end})
    VisualsTab:CreateDropdown({
        Name="Hit Sound Type",
        Options={"기본","Neverlose","Gamesense","Skeet","Rust","Bell","Bubble","Minecraft","Osu","TF2"},
        CurrentOption={"기본"},
        Flag="HitSoundType",
        Callback=function(v)
            S.HitSoundID = hitSoundOptions[v[1]] or hitSoundOptions["기본"]
        end
    })
    VisualsTab:CreateSlider({Name="Hit Sound Vol", Range={0,100}, Increment=1, CurrentValue=50, Flag="HitVol", Callback=function(v) S.HitSoundVolume=v/100 end})
end
