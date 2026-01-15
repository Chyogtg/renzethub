--[[
    RENZET HUBS - MOUNT CILLAAS EDITION
    Fitur: Smooth Auto Walk, Noclip, Save Position
    Metode: TweenService (Bypass Anti-Teleport Instan)
]]

local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local isRecording, isPlaying, isAutoTP, isLooping, noclipActive = false, false, false, false, false
local recordedPath, savedCoords = {}, {}
local walkSpeed = 50 -- Kecepatan auto walk (bisa kamu ubah)

-- UI BYPASS PROTECTION
local function GetParent()
    local s, r = pcall(function() return game:GetService("CoreGui") end)
    return s and r or player:WaitForChild("PlayerGui")
end

local TargetParent = GetParent()
if TargetParent:FindFirstChild("RenzetHubCillaas") then TargetParent.RenzetHubCillaas:Destroy() end

local ScreenGui = Instance.new("ScreenGui", TargetParent)
ScreenGui.Name = "RenzetHubCillaas"

-- UI DESIGN (DEEP BLUE)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 340)
Main.Position = UDim2.new(0.5, -160, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Header.Text = "RENZET HUBS - MT. CILLAAS"
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.GothamBold
Instance.new("UICorner", Header)

local function createBtn(txt, pos, color)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = color or Color3.fromRGB(0, 120, 215)
    btn.Text = txt
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn)
    return btn
end

-- BUTTONS
local NoclipBtn = createBtn("NOCLIP: OFF", UDim2.new(0.05, 0, 0, 50), Color3.fromRGB(40, 60, 90))
local SaveBtn = createBtn("SAVE SUMMIT POINT", UDim2.new(0.05, 0, 0, 95))
local AutoTPBtn = createBtn("START AUTO SUMMIT", UDim2.new(0.05, 0, 0, 140), Color3.fromRGB(0, 170, 100))
local RecBtn = createBtn("REC WALK: OFF", UDim2.new(0.05, 0, 0, 185), Color3.fromRGB(180, 0, 0))
local PlayBtn = createBtn("PLAY RECORDED WALK", UDim2.new(0.05, 0, 0, 230))
local LoopBtn = createBtn("LOOP: OFF", UDim2.new(0.05, 0, 0, 275), Color3.fromRGB(60, 60, 60))
LoopBtn.Size = UDim2.new(0.43, 0, 0, 35)
local ClearBtn = createBtn("CLEAR ALL", UDim2.new(0.52, 0, 0, 275), Color3.fromRGB(120, 30, 30))
ClearBtn.Size = UDim2.new(0.43, 0, 0, 35)

-- LOGIC: SMOOTH MOVEMENT (TWEEN)
local function SmoothMove(targetCFrame)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local distance = (char.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
        local info = TweenInfo.new(distance / walkSpeed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(char.HumanoidRootPart, info, {CFrame = targetCFrame})
        tween:Play()
        return tween
    end
end

-- NOCLIP
RunService.Stepped:Connect(function()
    if noclipActive and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

NoclipBtn.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    NoclipBtn.Text = noclipActive and "NOCLIP: ON" or "NOCLIP: OFF"
    NoclipBtn.BackgroundColor3 = noclipActive and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 60, 90)
end)

-- SAVE & AUTO TP
SaveBtn.MouseButton1Click:Connect(function()
    if player.Character then
        table.insert(savedCoords, player.Character.HumanoidRootPart.CFrame)
    end
end)

AutoTPBtn.MouseButton1Click:Connect(function()
    isAutoTP = not isAutoTP
    AutoTPBtn.Text = isAutoTP and "STOP AUTO SUMMIT" or "START AUTO SUMMIT"
    while isAutoTP do
        for _, cf in ipairs(savedCoords) do
            if not isAutoTP then break end
            local tw = SmoothMove(cf)
            if tw then tw.Completed:Wait() end
            task.wait(1)
        end
        task.wait()
    end
end)

-- RECORD & PLAY
RunService.Heartbeat:Connect(function()
    if isRecording and player.Character then
        table.insert(recordedPath, player.Character.HumanoidRootPart.CFrame)
    end
end)

RecBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    if isRecording then recordedPath = {} end
    RecBtn.Text = isRecording and "RECORDING... STOP" or "REC WALK: OFF"
end)

PlayBtn.MouseButton1Click:Connect(function()
    if isPlaying then isPlaying = false return end
    if #recordedPath == 0 then return end
    isPlaying = true
    repeat
        for _, cf in ipairs(recordedPath) do
            if not isPlaying then break end
            player.Character.HumanoidRootPart.CFrame = cf
            task.wait()
        end
    until not isLooping or not isPlaying
    isPlaying = false
end)

LoopBtn.MouseButton1Click:Connect(function()
    isLooping = not isLooping
    LoopBtn.Text = isLooping and "LOOP: ON" or "LOOP: OFF"
end)

ClearBtn.MouseButton1Click:Connect(function()
    recordedPath, savedCoords = {}, {}
end)