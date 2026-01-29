-- ======================
-- AUTO GRAB GUN SUAVE Y FLUIDA CON TOGGLE
-- ======================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local GUN_NAME = "GunDrop"
local MAX_DISTANCE = 1000
local DISTANCE_ABOVE = 2
local MOVE_SPEED = 0.15 -- tiempo de tween rápido y suave

-- Toggle global
if _G.AutoGrabGunActive == nil then
    _G.AutoGrabGunActive = false
end

-- Si ya estaba activo, desactivar
if _G.AutoGrabGunActive then
    _G.AutoGrabGunActive = false
    if _G._AutoGrabGunConnection then
        _G._AutoGrabGunConnection:Disconnect()
        _G._AutoGrabGunConnection = nil
    end
    print("❌ Auto Grab Gun desactivado")
    return
end

-- Activar
_G.AutoGrabGunActive = true
print("✅ Auto Grab Gun activado")

local gunDetected = nil
local angle = 0

-- Función para revisar si somos Murderer
local function isMurderer()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name == "Knife" then return true end
        end
    end
    if backpack then
        for _, t in ipairs(backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name == "Knife" then return true end
        end
    end
    return false
end

-- Función para comprobar distancia
local function inRange(obj)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    return (obj.Position - char.HumanoidRootPart.Position).Magnitude <= MAX_DISTANCE
end

-- Loop principal
_G._AutoGrabGunConnection = RunService.RenderStepped:Connect(function(delta)
    if not _G.AutoGrabGunActive then return end
    if isMurderer() then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    -- Buscar GunDrop
    local gun = nil
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == GUN_NAME and inRange(obj) then
            gun = obj
            break
        end
    end

    if gun then
        gunDetected = gun

        -- Movimiento circular + arriba/abajo suave
        angle = angle + delta * 2
        local xOffset = math.cos(angle) * 1
        local zOffset = math.sin(angle) * 1
        local yOffset = DISTANCE_ABOVE + math.sin(angle*2)*0.5

        local targetCFrame = CFrame.new(hrp.Position + Vector3.new(xOffset, yOffset, zOffset))

        local tween = TweenService:Create(
            gun,
            TweenInfo.new(MOVE_SPEED, Enum.EasingStyle.Linear),
            {CFrame = targetCFrame}
        )
        tween:Play()
    elseif gunDetected then
        gunDetected = nil
    end
end)
