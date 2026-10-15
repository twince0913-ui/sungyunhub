-- 성윤HUB Main

local baseUrl = "https://raw.githubusercontent.com/twince0913-ui/sungyunhub/main/"

local Utils = loadstring(game:HttpGet(baseUrl .. "utils.lua"))()
local combatMod = loadstring(game:HttpGet(baseUrl .. "modules/combat.lua"))()
local visualsMod = loadstring(game:HttpGet(baseUrl .. "modules/visuals.lua"))()
local miscMod = loadstring(game:HttpGet(baseUrl .. "modules/misc.lua"))()

local S = {
    SilentAim=false, SilentPart="Head", SilentFOV=150, SilentWallCheck=true, SilentTeamCheck=true, SilentHitchance=100,
    ESP=false, ESPBox=false, ESPName=false,
    Speed=16, JumpPower=50, DeviceMode="MouseKeyboard",
}

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "성윤HUB Premium | Rivals",
    LoadingTitle = "성윤HUB 로딩중...",
    LoadingSubtitle = "by 성윤 :3",
    KeySystem = false,
})

local CombatTab = Window:CreateTab("⚔️ Combat")
local VisualsTab = Window:CreateTab("👁️ Visuals")
local MiscTab = Window:CreateTab("🔧 Misc")

combatMod(S, Utils, CombatTab, Rayfield)
visualsMod(S, Utils, VisualsTab, Rayfield)
miscMod(S, Utils, MiscTab, Rayfield)

Utils.UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then Rayfield:Toggle() end
end)

print("성윤HUB 로드 완료 :3")
