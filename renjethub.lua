--[[
    RENZET HUBS - ALL-IN-ONE EDITION
    Map Utama: MOUNT Cillaas
    Fitur: Multi-Save, Record & Play, Noclip, Anti-Jail, Anti-Bring
]]

local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- State Variables
local isRecording, isPlaying, isAutoTP, isLooping = false, false, false, false
local noclipActive, antiJailActive = false, false
local recordedPath, savedCoords = {}, {}
local walkSpeed = 60 

-- UI PROTEKSI (Agar tidak dihapus sistem game)
local function GetParent()
    local s, r = pcall(function() return game:GetService("CoreGui") end)
    return s and r or player:WaitForChild("PlayerGui")
end

local TargetParent = GetParent()
if TargetParent:FindFirstChild("RenzetHubFinal") then TargetParent.RenzetHubFinal:Destroy() end

local ScreenGui = Instance.new("ScreenGui", TargetParent)
ScreenGui.Name = "RenzetHubFinal"
ScreenGui.ResetOnSpawn = false

-- TOMBOL FLOATING (OPEN/CLOSE)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -25)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 102, 255)
OpenBtn.Text = "RZ"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 20
OpenBtn.ZIndex = 10
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- FRAME UTAMA
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 420)
Main.Position = UDim2.new(0.5, -175, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(12, 20, 38)
Main.BorderSizePixel = 0
Main.Visible = true
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- HEADER
local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(0, 85, 200)
Header.Text = "RENZET HUBS - ALL IN ONE"
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.GothamBold
Instance.new("UICorner", Header)

-- CONTAINER SCROLL
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 650)
Container.ScrollBarThickness = 4

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 10)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- FUNGSI MEMBUAT TOMBOL TOGGLE
local function createToggle(name, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 45, 75)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = name .. (active and ": ON" or ": OFF")
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(30, 45, 75)
        callback(active)
    end)
    return btn
end

-----------------------------------------------------------
-- FITUR-FITUR
-----------------------------------------------------------

-- 1. Anti-Admin Jail & Anti-Bring
createToggle("ANTI-ADMIN JAIL", function(val)
    antiJailActive = val
end)

-- 2. Noclip
createToggle("NOCLIP MODE", function(val)
    noclipActive = val
end)

-- 3. Multi-Save Position System
local SaveSection = Instance.new("Frame", Container)
SaveSection.Size = UDim2.new(1, 0, 0, 80)
SaveSection.BackgroundTransparency = 1

local SaveBtn = Instance.new("TextButton", SaveSection)
SaveBtn.Size = UDim2.new(1, 0, 0, 40)
SaveBtn.Text = "ADD CURRENT POSITION"
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
SaveBtn.TextColor3 = Color3.new(1, 1, 1)
SaveBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", SaveBtn)

local PosCount = Instance.new("TextLabel", SaveSection)
PosCount.Size = UDim2.new(1, 0, 0, 30)
PosCount.Position = UDim2.new(0, 0, 0, 45)
PosCount.Text = "Saved Positions: 0"
PosCount.TextColor3 = Color3.new(0.7, 0.7, 0.7)
PosCount.BackgroundTransparency = 1

SaveBtn.MouseButton1Click:Connect(function()
    if player.Character then
        table.insert(savedCoords, player.Character.HumanoidRootPart.CFrame)
        PosCount.Text = "Saved Positions: " .. #savedCoords
    end
end)

-- 4. Auto Teleport (Smooth Tween)
createToggle("START AUTO SUMMIT", function(val)
    isAutoTP = val
    while isAutoTP do
        for _, cf in ipairs(savedCoords) do
            if not isAutoTP then break end
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local dist = (char.HumanoidRootPart.Position - cf.Position).Magnitude
                local info = TweenInfo.new(dist/walkSpeed, Enum.EasingStyle.Linear)
                local tw = TweenService:Create(char.HumanoidRootPart, info, {CFrame = cf})
                tw:Play()
                tw.Completed:Wait()
            end
            task.wait(1)
        end
        task.wait()
    end
end)

-- 5. Record Walk System
createToggle("RECORD WALK", function(val)
    isRecording = val
    if isRecording then recordedPath = {} end
end)

-- 6. Playback Walk
createToggle("PLAY RECORDING", function(val)
    isPlaying = val
    if isPlaying and #recordedPath > 0 then
        repeat
            for _, cf in ipairs(recordedPath) do
                if not isPlaying then break end
                player.Character.HumanoidRootPart.CFrame = cf
                task.wait()
            end
        until not isLooping or not isPlaying
    end
end)

-- 7. Loop Playback
createToggle("LOOP RECORDING", function(val)
    isLooping = val
end)

-- 8. Clear Data
local ClearBtn = Instance.new("TextButton", Container)
ClearBtn.Size = UDim2.new(1, 0, 0, 40)
ClearBtn.Text = "CLEAR ALL DATA"
ClearBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ClearBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", ClearBtn)

ClearBtn.MouseButton1Click:Connect(function()
    recordedPath, savedCoords = {}, {}
    PosCount.Text = "Saved Positions: 0"
end)

-----------------------------------------------------------
-- SISTEM LOGIC (RUNSERVICE)
-----------------------------------------------------------

RunService.Stepped:Connect(function()
    if player.Character then
        -- Logic Noclip & Anti-Jail
        if noclipActive or antiJailActive then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    if antiJailActive and part.Anchored then
                        part.Anchored = false
                    end
                end
            end
        end
        
        -- Logic Anti-Bring/Anti-Sit
        if antiJailActive then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then 
                hum.Sit = false 
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if isRecording and player.Character then
        table.insert(recordedPath, player.Character.HumanoidRootPart.CFrame)
    end
end)

print("Renzet Hubs Final Edition Loaded!")