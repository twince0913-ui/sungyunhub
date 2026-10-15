-- 성윤HUB Combat Module

return function(S, Utils, CombatTab, Rayfield)
    local Players = Utils.Players
    local RunService = Utils.RunService
    local UserInputService = Utils.UserInputService
    local ReplicatedStorage = Utils.ReplicatedStorage
    local LocalPlayer = Utils.LocalPlayer
    local Camera = Utils.Camera

    local util, enums
    pcall(function()
        util = require(ReplicatedStorage.Modules.Utility)
        enums = require(ReplicatedStorage.Modules.EnumLibrary)
    end)

    local useItemRemote = ReplicatedStorage.Remotes.Replication.Fighter.UseItem

    local function buildCamData(fromPos, part)
        if not util or not part then return nil end
        local look = CFrame.new(fromPos, part.Position)
        return {
            [utf8.char(1)] = {
                [utf8.char(0)] = util:EncodeCFrame(look),
                [utf8.char(1)] = util:EncodeCFrame(look),
                [utf8.char(2)] = part,
                [utf8.char(3)] = util:EncodeCFrame(part.CFrame:ToObjectSpace(CFrame.new(part.Position)))
            }
        }
    end

    local cache = {}
    local lastCache = 0
    local function getTargets()
        local now = tick()
        if now - lastCache < 0.1 and #cache > 0 then return cache end
        lastCache = now
        table.clear(cache)
        for _, p in Players:GetPlayers() do
            if p ~= LocalPlayer and Utils.isAlive(p) then
                if not S.SilentTeamCheck or p.Team ~= LocalPlayer.Team then
                    table.insert(cache, p)
                end
            end
        end
        return cache
    end

    local function getClosest(range)
        local r = Utils.getRoot(LocalPlayer.Character)
        if not r then return nil end
        local c, d = nil, range or math.huge
        for _, p in getTargets() do
            local tr = Utils.getRoot(p.Character)
            if tr then
                local dist = (tr.Position - r.Position).Magnitude
                if dist < d then d = dist c = p end
            end
        end
        return c
    end

    local function getClosestByScreen(fov, partName)
        local mp = UserInputService:GetMouseLocation()
        local c, d = nil, fov or math.huge
        for _, p in getTargets() do
            local ch = p.Character
            local part = ch:FindFirstChild(partName or "Head") or ch:FindFirstChild("HumanoidRootPart")
            if part and Utils.wallCheck(part) then
                local sp, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local dist = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
                    if dist < d then d = dist c = part end
                end
            end
        end
        return c
    end

    -- Silent Aim
    if hookfunction and useItemRemote then
        local oldFire = useItemRemote.FireServer
        hookfunction(oldFire, newcclosure(function(self, oid, action, cameradata, ...)
            if not S.SilentAim then return oldFire(self, oid, action, cameradata, ...) end
            if enums and action == enums:ToEnum("StartShooting") then
                local t = getClosest(S.SilentFOV * 10)
                if t then
                    local ch = t.Character
                    local part = ch:FindFirstChild(S.SilentPart) or ch:FindFirstChild("Head")
                    if part and math.random(1, 100) <= S.SilentHitchance then
                        local nd = buildCamData(Camera.CFrame.Position, part)
                        if nd then return oldFire(self, oid, action, nd, ...) end
                    end
                end
            end
            return oldFire(self, oid, action, cameradata, ...)
        end))
    end

    CombatTab:CreateToggle({Name="Silent Aim", CurrentValue=false, Flag="SilentAim", Callback=function(v) S.SilentAim = v end})
    CombatTab:CreateDropdown({Name="Silent Part", Options={"Head","UpperTorso","HumanoidRootPart"}, CurrentOption={"Head"}, Flag="SilentPart", Callback=function(v) S.SilentPart = v[1] end})
    CombatTab:CreateSlider({Name="Silent FOV", Range={10,1000}, Increment=10, CurrentValue=150, Flag="SilentFOV", Callback=function(v) S.SilentFOV = v end})
    CombatTab:CreateSlider({Name="Silent Hit %", Range={0,100}, Increment=1, CurrentValue=100, Suffix="%", Flag="SilentHit", Callback=function(v) S.SilentHitchance = v end})
    CombatTab:CreateToggle({Name="Silent Wallcheck", CurrentValue=true, Flag="SilentWall", Callback=function(v) S.SilentWallCheck = v end})
    CombatTab:CreateToggle({Name="Silent Teamcheck", CurrentValue=true, Flag="SilentTeam", Callback=function(v) S.SilentTeamCheck = v end})

    -- FOV Circle
    local fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Thickness = 1
    fovCircle.Color = Color3.fromRGB(120, 180, 255)
    fovCircle.Filled = false

    -- Aimbot
    RunService.RenderStepped:Connect(function()
        fovCircle.Position = UserInputService:GetMouseLocation()
        fovCircle.Radius = S.AimFOV
        fovCircle.Visible = S.ShowAimFOV and S.Aimbot
        if not S.Aimbot then return end
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        local part = getClosestByScreen(S.AimFOV, S.AimPart)
        if part then
            local target = CFrame.lookAt(Camera.CFrame.Position, part.Position)
            Camera.CFrame = Camera.CFrame:Lerp(target, math.clamp(S.AimSmooth/100, 0.01, 1) * 0.5)
        end
    end)

    CombatTab:CreateToggle({Name="Aimbot (RMB)", CurrentValue=false, Flag="Aimbot", Callback=function(v) S.Aimbot = v end})
    CombatTab:CreateDropdown({Name="Aimbot Part", Options={"Head","UpperTorso","HumanoidRootPart"}, CurrentOption={"Head"}, Flag="AimPart", Callback=function(v) S.AimPart = v[1] end})
    CombatTab:CreateSlider({Name="Aimbot FOV", Range={10,500}, Increment=10, CurrentValue=120, Flag="AimFOV", Callback=function(v) S.AimFOV = v end})
    CombatTab:CreateSlider({Name="Aimbot Smooth", Range={1,100}, Increment=1, CurrentValue=100, Suffix="%", Flag="AimSmooth", Callback=function(v) S.AimSmooth = v end})
    CombatTab:CreateToggle({Name="Show FOV", CurrentValue=false, Flag="ShowFOV", Callback=function(v) S.ShowAimFOV = v end})

    -- Triggerbot
    local lastTrig = 0
    RunService.Heartbeat:Connect(function()
        if not S.Triggerbot then return end
        if os.clock() - lastTrig < S.TriggerReactionTime/1000 then return end
        local t = LocalPlayer:GetMouse().Target
        if not t then return end
        local m = t:FindFirstAncestorOfClass("Model")
        local p = m and Players:GetPlayerFromCharacter(m)
        if p and p ~= LocalPlayer then
            lastTrig = os.clock()
            pcall(function() mouse1click() end)
        end
    end)

    CombatTab:CreateToggle({Name="Triggerbot", CurrentValue=false, Flag="Trigger", Callback=function(v) S.Triggerbot = v end})
    CombatTab:CreateSlider({Name="Trigger Reaction", Range={0,500}, Increment=10, CurrentValue=100, Suffix="ms", Flag="TrigReact", Callback=function(v) S.TriggerReactionTime = v end})

    -- Ragebot
    local rageConn, rageGen = nil, 0
    local function startRage()
        if rageConn then return end
        rageGen += 1
        local gen = rageGen
        rageConn = RunService.Heartbeat:Connect(function()
            if not S.Ragebot or rageGen ~= gen then return end
            local root = Utils.getRoot(LocalPlayer.Character)
            if not root then return end
            local t = getClosest(1000)
            if not t then return end
            local tc, tr = t.Character, Utils.getRoot(t.Character)
            local head = tc and tc:FindFirstChild("Head")
            if not tr or not head then return end
            local pos
            if S.RageMode == "Orbit" then
                local a = os.clock() * 8
                pos = head.Position + Vector3.new(math.cos(a)*S.RageDistance, S.RageHeight, math.sin(a)*S.RageDistance)
            elseif S.RageMode == "Behind" then
                pos = head.Position - tr.CFrame.LookVector * S.RageDistance + Vector3.new(0, S.RageHeight, 0)
            elseif S.RageMode == "Underground" then
                pos = head.Position + Vector3.new(0, -6, 0)
            else
                pos = head.Position + Vector3.new(0, S.RageHeight, 0)
            end
            root.CFrame = CFrame.new(pos, head.Position)
            if S.AutoFire and os.clock() - (S._lastFire or 0) >= S.FireRate then
                S._lastFire = os.clock()
                local it = Utils.getItem()
                if it and enums and util then
                    local payload = buildCamData(pos, head)
                    if payload then
                        pcall(function()
                            useItemRemote:FireServer(it:Get("ObjectID"), enums:ToEnum("StartShooting"), payload, nil)
                        end)
                    end
                end
            end
            if S.KillNotification then
                local h = Utils.getHum(tc)
                if h and h.Health <= 0 then
                    Rayfield:Notify({Title="성윤HUB", Content="Killed: " .. t.Name, Duration=2})
                end
            end
        end)
    end
    local function stopRage()
        rageGen += 1
        if rageConn then rageConn:Disconnect() rageConn = nil end
    end

    CombatTab:CreateToggle({Name="Ragebot", CurrentValue=false, Flag="Ragebot", Callback=function(v) S.Ragebot=v if v then startRage() else stopRage() end end})
    CombatTab:CreateDropdown({Name="Rage Mode", Options={"Orbit","Behind","Underground","Above"}, CurrentOption={"Orbit"}, Flag="RageMode", Callback=function(v) S.RageMode=v[1] end})
    CombatTab:CreateSlider({Name="Rage Distance", Range={1,15}, Increment=1, CurrentValue=3, Flag="RageDist", Callback=function(v) S.RageDistance=v end})
    CombatTab:CreateSlider({Name="Rage Height", Range={-5,10}, Increment=1, CurrentValue=2, Flag="RageHeight", Callback=function(v) S.RageHeight=v end})
    CombatTab:CreateSlider({Name="Fire Rate", Range={1,100}, Increment=1, CurrentValue=50, Flag="FireRate", Callback=function(v) S.FireRate=v/100000 end})
    CombatTab:CreateToggle({Name="Auto Fire", CurrentValue=true, Flag="AutoFire", Callback=function(v) S.AutoFire=v end})

    -- No Recoil / Spread / Rapid
    pcall(function()
        local CI = require(LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
        if CI and hookfunction then
            local oi = CI.Input
            hookfunction(oi, newcclosure(function(self, ...)
                local a = {...}
                if type(a[1])=="table" and a[1].Info then
                    if S.NoRecoil then a[1].Info.ShootRecoil = 0 end
                    if S.NoSpread then a[1].Info.ShootSpread = 0 end
                    if S.RapidFire then
                        a[1].Info.ShootCooldown = 0
                        a[1].Info.QuickShotCooldown = 0
                    end
                end
                return oi(self, ...)
            end))
        end
    end)

    CombatTab:CreateToggle({Name="No Recoil", CurrentValue=false, Flag="NoRecoil", Callback=function(v) S.NoRecoil=v end})
    CombatTab:CreateToggle({Name="No Spread", CurrentValue=false, Flag="NoSpread", Callback=function(v) S.NoSpread=v end})
    CombatTab:CreateToggle({Name="Rapid Fire", CurrentValue=false, Flag="RapidFire", Callback=function(v) S.RapidFire=v end})
end
