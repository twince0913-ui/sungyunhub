-- 성윤HUB Utils
local Utils = {}

Utils.Players = game:GetService("Players")
Utils.RunService = game:GetService("RunService")
Utils.UserInputService = game:GetService("UserInputService")
Utils.ReplicatedStorage = game:GetService("ReplicatedStorage")
Utils.Lighting = game:GetService("Lighting")
Utils.CoreGui = game:GetService("CoreGui")
Utils.LocalPlayer = Utils.Players.LocalPlayer
Utils.Camera = workspace.CurrentCamera

function Utils.getRoot(c)
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("RootPart"))
end

function Utils.getHum(c)
    return c and c:FindFirstChildOfClass("Humanoid")
end

function Utils.isAlive(p)
    local c = p and p.Character
    local h = Utils.getHum(c)
    return c and h and h.Health > 0
end

function Utils.getFighter()
    local ok, ctrl = pcall(function()
        return require(Utils.LocalPlayer.PlayerScripts.Controllers.FighterController)
    end)
    return ok and ctrl and (ctrl.LocalFighter or ctrl:GetFighter(Utils.LocalPlayer)) or nil
end

function Utils.getItem()
    local f = Utils.getFighter()
    return f and f.EquippedItem or nil
end

return Utils
