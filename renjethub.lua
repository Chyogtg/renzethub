--[[
    RENZET HUBS - V2
    Fitur: Auto Teleport, Record Walk, Noclip, Player TP
    Warna: Deep Blue Edition
]]

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local isRecording, isPlaying, isAutoTeleporting, isLooping, noclipActive = false, false, false, false, false
local recordedPath, savedCoords = {}, {}

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "RenzetHubsV2"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 320)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 20, 40)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(0, 85, 255)
local HeaderCorner = Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "RENZET HUBS - V2"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

local function createBtn(text, pos, size, color, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = size or UDim2.new(0.9, 0, 0, 30)
    btn.Position = pos
    btn.BackgroundColor3 = color or Color3.fromRGB(0, 100, 200)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    return btn
end

-- TAB CONTENT
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -40)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.BackgroundTransparency = 1

-- 1. Player TP
local PlayerInput = Instance.new("TextBox", Content)
PlayerInput.Size = UDim2.new(0.65, 0, 0, 30)
PlayerInput.Position = UDim2.new(0.05, 0, 0, 10)
PlayerInput.PlaceholderText = "Nama Pemain..."
PlayerInput.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
PlayerInput.TextColor3 = Color3.new(1, 1, 1)
PlayerInput.Text = ""
Instance.new("UICorner", PlayerInput)

local TPBtn = createBtn("TP", UDim2.new(0.72, 0, 0, 10), UDim2.new(0.23, 0, 0, 30), nil, Content)

-- 2. Noclip Toggle
local NoclipBtn = createBtn("NOCLIP: OFF", UDim2.new(0.05, 0, 0, 45), nil, Color3.fromRGB(60, 60, 80), Content)

-- 3. Auto TP
local SavePosBtn = createBtn("SAVE POSITION", UDim2.new(0.05, 0, 0, 80), nil, nil, Content)
local StartTPBtn = createBtn("START AUTO TELEPORT", UDim2.new(0.05, 0, 0, 115), nil, Color3.fromRGB(0, 150, 80), Content)

-- 4. Record Walk
local RecBtn = createBtn("REC WALK: OFF", UDim2.new(0.05, 0, 0, 150), nil, Color3.fromRGB(150, 0, 0), Content)
local PlayBtn = createBtn("PLAY RECORDING", UDim2.new(0.05, 0, 0, 185), nil, nil, Content)

local LoopBtn = createBtn("LOOP: OFF", UDim2.new(0.05, 0, 0, 220), UDim2.new(0.43, 0, 0, 30), Color3.fromRGB(50, 50, 50), Content)
local ClearBtn = createBtn("CLEAR DATA", UDim2.new(0.52, 0, 0, 220), UDim2.new(0.43, 0, 0, 30), Color3.fromRGB(100, 30, 30), Content)

local Status = Instance.new("TextLabel", Content)
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 0, 255)
Status.Text = "Status: Ready"
Status.TextColor3 = Color3.fromRGB(0, 200, 255)
Status.BackgroundTransparency = 1

-- LOGIC --
RunService.Stepped:Connect(function()
    if noclipActive and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

NoclipBtn.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    NoclipBtn.Text = noclipActive and "NOCLIP: ON" or "NOCLIP: OFF"
    NoclipBtn.BackgroundColor3 = noclipActive and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 80)
end)

TPBtn.MouseButton1Click:Connect(function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if string.find(string.lower(p.Name), string.lower(PlayerInput.Text)) and p.Character then
            player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
        end
    end
end)

SavePosBtn.MouseButton1Click:Connect(function()
    if player.Character then
        table.insert(savedCoords, player.Character.HumanoidRootPart.CFrame)
        Status.Text = "Saved: " .. #savedCoords .. " coords"
    end
end)

StartTPBtn.MouseButton1Click:Connect(function()
    isAutoTeleporting = not isAutoTeleporting
    StartTPBtn.Text = isAutoTeleporting and "STOP TELEPORT" or "START AUTO TELEPORT"
    while isAutoTeleporting do
        for _, cf in ipairs(savedCoords) do
            if not isAutoTeleporting then break end
            player.Character.HumanoidRootPart.CFrame = cf
            task.wait(2)
        end
        task.wait()
    end
end)

RunService.Heartbeat:Connect(function()
    if isRecording and player.Character then
        table.insert(recordedPath, player.Character.HumanoidRootPart.CFrame)
        Status.Text = "Recorded: " .. #recordedPath .. " pts"
    end
end)

RecBtn.MouseButton1Click:Connect(function()
    isRecording = not isRecording
    if isRecording then recordedPath = {} end
    RecBtn.Text = isRecording and "RECORDING... STOP" or "REC WALK: OFF"
end)

PlayBtn.MouseButton1Click:Connect(function()
    if isPlaying then isPlaying = false return end
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
    Status.Text = "All Data Cleared!"
end)