-- 성윤HUB Loader (단계별 로드)
local baseUrl = "https://raw.githubusercontent.com/twince0913-ui/sungyunhub/main/"

print("[성윤HUB] 로드 시작...")
task.wait(0.5)

-- 1. Utils
print("[성윤HUB] 1/4 utils.lua 로드중...")
local ok1, Utils = pcall(function()
    return loadstring(game:HttpGet(baseUrl .. "utils.lua"))()
end)
if not ok1 then
    warn("[성윤HUB] utils.lua 실패: " .. tostring(Utils))
    return
end
print("[성윤HUB] 1/4 완료!")
task.wait(0.5)

-- 2. Combat
print("[성윤HUB] 2/4 combat.lua 로드중...")
local ok2, combatMod = pcall(function()
    return loadstring(game:HttpGet(baseUrl .. "modules/combat.lua"))()
end)
if not ok2 then
    warn("[성윤HUB] combat.lua 실패: " .. tostring(combatMod))
    return
end
print("[성윤HUB] 2/4 완료!")
task.wait(0.5)

-- 3. Visuals
print("[성윤HUB] 3/4 visuals.lua 로드중...")
local ok3, visualsMod = pcall(function()
    return loadstring(game:HttpGet(baseUrl .. "modules/visuals.lua"))()
end)
if not ok3 then
    warn("[성윤HUB] visuals.lua 실패: " .. tostring(visualsMod))
    return
end
print("[성윤HUB] 3/4 완료!")
task.wait(0.5)

-- 4. Misc
print("[성윤HUB] 4/4 misc.lua 로드중...")
local ok4, miscMod = pcall(function()
    return loadstring(game:HttpGet(baseUrl .. "modules/misc.lua"))()
end)
if not ok4 then
    warn("[성윤HUB] misc.lua 실패: " .. tostring(miscMod))
    return
end
print("[성윤HUB] 4/4 완료!")
task.wait(0.5)

-- 상태 테이블
local S = {
    SilentAim=false, SilentPart="Head", SilentFOV=150,
    SilentWallCheck=true, SilentTeamCheck=true, SilentHitchance=100,
    Aimbot=false, AimPart="Head", AimFOV=120, AimSmooth=100, ShowAimFOV=false,
    Triggerbot=false, TriggerReactionTime=100,
    Ragebot=false, RageMode="Orbit", RageDistance=3, RageHeight=2,
    FireRate=0.0005, AutoFire=true, KillNotification=true,
    NoRecoil=false, NoSpread=false, RapidFire=false,
    ESP=false, ESPBox=false, ESPName=false, ESPHealth=false,
    ESPDistance=false, ESPWeapon=false, ESPTeamColor=true,
    Crosshair=false, CrosshairColor=Color3.fromRGB(0, 255, 0),
    HitSound=false, HitSoundVolume=0.5, HitSoundID="rbxassetid://6607204501",
    Speed=16, JumpPower=50, InfiniteJump=false,
    AutoQueue=false, AutoBan=false, DeviceMode="MouseKeyboard",
}

-- UI 로드
print("[성윤HUB] UI 로드중...")
task.wait(0.5)

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

print("[성윤HUB] 모듈 초기화중...")
task.wait(0.5)

combatMod(S, Utils, CombatTab, Rayfield)
print("[성윤HUB] Combat 초기화 완료")
task.wait(0.3)

visualsMod(S, Utils, VisualsTab, Rayfield)
print("[성윤HUB] Visuals 초기화 완료")
task.wait(0.3)

miscMod(S, Utils, MiscTab, Rayfield)
print("[성윤HUB] Misc 초기화 완료")
task.wait(0.3)

Utils.UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Rayfield:Toggle()
    end
end)

print("[성윤HUB] ✅ 로드 완료!")
Rayfield:Notify({
    Title="성윤HUB",
    Content="로드 완료! RightShift로 UI 토글",
    Duration=5,
})
