--[[
    RENZET HUBS - V3 ULTIMATE EDITION
    Map Utama: MOUNT Cillaas
    Fitur: Multi-Save (Bring), Record & Play, Noclip, Anti-Jail, Custom Drag
]]

local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- State Variables
local isRecording, isPlaying, isAutoTP, isLooping = false, false, false, false
local noclipActive, antiJailActive = false, false
local recordedPath, savedCoords = {}, {}
local walkSpeed = 60 

-- UI PROTEKSI
local function GetParent()
    local s, r = pcall(function() return game:GetService("CoreGui") end)
    return s and r or player:WaitForChild("PlayerGui")
end

local TargetParent = GetParent()
if TargetParent:FindFirstChild("RenzetHubUltimate") then TargetParent.RenzetHubUltimate:Destroy() end

local ScreenGui = Instance.new("ScreenGui", TargetParent)
ScreenGui.Name = "RenzetHubUltimate"
ScreenGui.ResetOnSpawn = false

-- TOMBOL FLOATING (OPEN/CLOSE)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -27)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 102, 255)
OpenBtn.Text = "RZ"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 22
OpenBtn.ZIndex = 10
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local StrokeBtn = Instance.new("UIStroke", OpenBtn)
StrokeBtn.Thickness = 2
StrokeBtn.Color = Color3.new(1, 1, 1)

-- FRAME UTAMA
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 360, 0, 440)
Main.Position = UDim2.new(0.5, -180, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(10, 15, 28)
Main.BorderSizePixel = 0
Main.Visible = true
Main.Active = true
local MainCorner = Instance.new("UICorner", Main)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(0, 100, 255)
MainStroke.Thickness = 2

-- HEADER (DRAGGABLE AREA)
local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(0, 85, 200)
Header.Text = "  RENZET HUB V3 - ULTIMATE"
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 16
Header.TextXAlignment = Enum.TextXAlignment.Left
local HeaderCorner = Instance.new("UICorner", Header)

-- LOGIKA DRAG CUSTOM (Bisa digeser di PC & HP)
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- CONTAINER SCROLL
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -65)
Container.Position = UDim2.new(0, 10, 0, 55)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 700)
Container.ScrollBarThickness = 2

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 10)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- FUNGSI TOGGLE
local function createToggle(name, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    Instance.new("UICorner", btn)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = name .. (active and ": ON" or ": OFF")
        local targetColor = active and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(25, 35, 55)
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
        callback(active)
    end)
    return btn
end

-----------------------------------------------------------
-- FITUR IMPLEMENTASI
-----------------------------------------------------------

-- 1. Anti Admin & Noclip
createToggle("ANTI ADMIN JAIL & ANCHOR", function(val) antiJailActive = val end)
createToggle("NOCLIP (TEMBUS DINDING)", function(val) noclipActive = val end)

-- 2. Multi-Save System
local SaveBtn = Instance.new("TextButton", Container)
SaveBtn.Size = UDim2.new(1, 0, 0, 45)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
SaveBtn.Text = "ADD CURRENT POSITION (BRING)"
SaveBtn.TextColor3 = Color3.new(1, 1, 1)
SaveBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", SaveBtn)

local PosCount = Instance.new("TextLabel", Container)
PosCount.Size = UDim2.new(1, 0, 0, 20)
PosCount.Text = "Saved Points: 0"
PosCount.TextColor3 = Color3.new(0.7, 0.7, 0.7)
PosCount.BackgroundTransparency = 1
PosCount.Font = Enum.Font.GothamSemibold

SaveBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        table.insert(savedCoords, player.Character.HumanoidRootPart.CFrame)
        PosCount.Text = "Saved Points: " .. #savedCoords
    end
end)

-- 3. Instant Teleport (Bring Style)
createToggle("START AUTO SUMMIT (INSTANT)", function(val)
    isAutoTP = val
    while isAutoTP do
        for _, cf in ipairs(savedCoords) do
            if not isAutoTP then break end
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = cf
            end
            task.wait(0.6) -- Delay aman agar tidak di-kick server
        end
        task.wait(0.5)
    end
end)

-- 4. Recording System
createToggle("RECORD WALK PATH", function(val)
    isRecording = val
    if val then recordedPath = {} end
end)

createToggle("PLAY RECORDING", function(val)
    isPlaying = val
    if isPlaying and #recordedPath > 0 then
        repeat
            for _, cf in ipairs(recordedPath) do
                if not isPlaying then break end
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = cf
                end
                task.wait()
            end
        until not isLooping or not isPlaying
    end
end)

createToggle("LOOP PLAYBACK", function(val) isLooping = val end)

-- 5. Clear Data
local ClearBtn = Instance.new("TextButton", Container)
ClearBtn.Size = UDim2.new(1, 0, 0, 42)
ClearBtn.Text = "CLEAR ALL SAVED DATA"
ClearBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ClearBtn.TextColor3 = Color3.new(1, 1, 1)
ClearBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ClearBtn)

ClearBtn.MouseButton1Click:Connect(function()
    recordedPath, savedCoords = {}, {}
    PosCount.Text = "Saved Points: 0"
end)

-----------------------------------------------------------
-- CORE LOGIC (RUNSERVICE)
-----------------------------------------------------------

RunService.Stepped:Connect(function()
    if player.Character then
        if noclipActive or antiJailActive then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    if antiJailActive then part.Anchored = false end
                end
            end
        end
        if antiJailActive then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then hum.Sit = false; hum:ChangeState(Enum.HumanoidStateType.Physics) end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if isRecording and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        table.insert(recordedPath, player.Character.HumanoidRootPart.CFrame)
    end
end)

print("Renzet Hub V3 Ultimate Loaded Successfully!")
