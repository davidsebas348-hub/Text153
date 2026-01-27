-- ======================
-- AUTO GRAB GUN + VERIFICAR INVENTARIO/CHARACTER
-- ======================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local GUN_NAME = "GunDrop"
local DISTANCE_ABOVE = 2
local MAX_DISTANCE = 1000 -- radio máximo

-- ======================
-- TOGGLE GLOBAL
-- ======================
if _G.AutoGrabGun == nil then
    _G.AutoGrabGun = true
else
    _G.AutoGrabGun = not _G.AutoGrabGun
end

-- ======================
-- VARIABLES GLOBALES
-- ======================
if _G.AutoGrabConnection then
    _G.AutoGrabConnection:Disconnect()
    _G.AutoGrabConnection = nil
end

local grabbed = false
local gunOrigin = nil

-- ======================
-- FUNCIONES
-- ======================

-- Revisa si tenemos alguna herramienta (Knife, Gun, Pistol)
local function HasWeapon()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")

    -- Revisar tools en Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then
                return true
            end
        end
    end

    -- Revisar tools en Backpack
    if backpack then
        for _, t in ipairs(backpack:GetChildren()) do
            if t:IsA("Tool") then
                return true
            end
        end
    end

    return false
end

-- Función para agarrar la Gun
local function GrabGun()
    if HasWeapon() then return end -- no teletransportar si tenemos herramienta

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == GUN_NAME and obj:IsA("BasePart") and not grabbed then
            local distance = (obj.Position - hrp.Position).Magnitude
            if distance <= MAX_DISTANCE then
                grabbed = true
                gunOrigin = hrp.CFrame

                -- Teleport hacia la Gun
                local tween = TweenService:Create(
                    hrp,
                    TweenInfo.new(0.25),
                    {CFrame = obj.CFrame + Vector3.new(0,DISTANCE_ABOVE,0)}
                )
                tween:Play()

                -- Esperar a que la Gun desaparezca y volver
                obj.AncestryChanged:Connect(function(_, parent)
                    if not parent then
                        local backTween = TweenService:Create(hrp, TweenInfo.new(0.25), {CFrame = gunOrigin})
                        backTween:Play()
                        grabbed = false
                    end
                end)
            end
        end
    end
end

-- ======================
-- DESACTIVAR SI TOGGLE OFF
-- ======================
if not _G.AutoGrabGun then
    grabbed = false
    warn("❌ AUTO GRAB GUN DESACTIVADO")
    return
end

warn("✅ AUTO GRAB GUN ACTIVADO")

-- ======================
-- LOOP PRINCIPAL
-- ======================
_G.AutoGrabConnection = RunService.RenderStepped:Connect(function()
    if _G.AutoGrabGun then
        pcall(GrabGun)
    end
end)
