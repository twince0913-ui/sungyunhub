-- 성윤HUB Misc Module

return function(S, Utils, MiscTab, Rayfield)
    local RunService = Utils.RunService
    local ReplicatedStorage = Utils.ReplicatedStorage
    local LocalPlayer = Utils.LocalPlayer
    local UserInputService = Utils.UserInputService

    -- =========================================
    -- SPEED / JUMP (최적화)
    -- =========================================
    local lastSpeed = 0
    RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastSpeed < 0.2 then return end
        lastSpeed = now
        local h = Utils.getHum(LocalPlayer.Character)
        if h then
            h.WalkSpeed = S.Speed
            h.JumpPower = S.JumpPower
        end
    end)

    MiscTab:CreateSlider({Name="Walk Speed", Range={16,200}, Increment=1, CurrentValue=16, Flag="Speed", Callback=function(v) S.Speed=v end})
    MiscTab:CreateSlider({Name="Jump Power", Range={50,300}, Increment=1, CurrentValue=50, Flag="Jump", Callback=function(v) S.JumpPower=v end})

    -- =========================================
    -- INFINITE JUMP
    -- =========================================
    UserInputService.JumpRequest:Connect(function()
        if S.InfiniteJump then
            local h = Utils.getHum(LocalPlayer.Character)
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    MiscTab:CreateToggle({Name="Infinite Jump", CurrentValue=false, Flag="InfJump", Callback=function(v) S.InfiniteJump=v end})

    -- =========================================
    -- AUTO QUEUE
    -- =========================================
    local queueConn
    local function startAutoQueue()
        if queueConn then return end
        queueConn = RunService.Heartbeat:Connect(function()
            if not S.AutoQueue then return end
            pcall(function()
                local ctrl = require(LocalPlayer.PlayerScripts.Controllers.MatchmakingController)
                if ctrl and ctrl.QueueInto then ctrl:QueueInto("1v1") end
            end)
        end)
    end

    MiscTab:CreateToggle({Name="Auto Queue (1v1)", CurrentValue=false, Flag="AutoQueue", Callback=function(v)
        S.AutoQueue = v
        if v then startAutoQueue() end
    end})

    -- =========================================
    -- AUTO BAN
    -- =========================================
    local banConn
    local function startAutoBan()
        if banConn then return end
        banConn = RunService.Heartbeat:Connect(function()
            if not S.AutoBan then return end
            pcall(function()
                ReplicatedStorage.Remotes.Duels.Vote:FireServer("Riot Shield")
            end)
        end)
    end

    MiscTab:CreateToggle({Name="Auto Ban (Riot Shield)", CurrentValue=false, Flag="AutoBan", Callback=function(v)
        S.AutoBan = v
        if v then startAutoBan() end
    end})

    -- =========================================
    -- DEVICE SPOOFER
    -- =========================================
    local function getSetControlsRemote()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local rep = remotes and remotes:FindFirstChild("Replication")
        local fighter = rep and rep:FindFirstChild("Fighter")
        return fighter and fighter:FindFirstChild("SetControls")
    end

    local function spoofDevice(mode)
        local remote = getSetControlsRemote()
        if remote then
            pcall(function() remote:FireServer(mode) end)
        end
    end

    MiscTab:CreateDropdown({
        Name="Device Spoofer",
        Options={"MouseKeyboard","Touch","Gamepad","VR"},
        CurrentOption={"MouseKeyboard"},
        Flag="DeviceSpoof",
        Callback=function(v)
            S.DeviceMode = v[1]
            spoofDevice(v[1])
        end
    })
end
