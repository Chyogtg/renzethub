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
    btn.Font = Enum.Font.Gotham