-- RIVALS MOBILE WORKING SCRIPT (Hydrogen/CodeX with Drawing support)
-- Password: astro

-- Check executor
local isHydrogen = pcall(function() return getgenv().Hydrogen end)
local isCodeX = pcall(function() return getgenv().CodeX end)

if not isHydrogen and not isCodeX then
    print("This script requires Hydrogen or CodeX executor with Drawing support")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

-- Settings
local aimbotEnabled = true
local espEnabled = true
local fovRadius = 250
local smoothness = 3

-- Create GUI Frame
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RivalsMobile"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 120)
mainFrame.Position = UDim2.new(0.5, -100, 0.85, -60)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.new(1, 0.5, 0)
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "RIVALS | astro"
title.TextColor3 = Color3.new(1, 1, 0)
title.BackgroundTransparency = 1
title.Parent = mainFrame

local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0, 170, 0, 35)
espBtn.Position = UDim2.new(0, 15, 0, 38)
espBtn.Text = "ESP: ON"
espBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
espBtn.Parent = mainFrame

local aimBtn = Instance.new("TextButton")
aimBtn.Size = UDim2.new(0, 170, 0, 35)
aimBtn.Position = UDim2.new(0, 15, 0, 78)
aimBtn.Text = "AIMBOT: ON"
aimBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
aimBtn.Parent = mainFrame

-- ESP using UI elements (works without Drawing)
local espLabels = {}
local function createUESP(player)
    if player == LocalPlayer then return end
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 100, 0, 20)
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.BackgroundTransparency = 0.5
    label.TextColor3 = Color3.new(1, 0, 0)
    label.BorderSizePixel = 1
    label.BorderColor3 = Color3.new(1, 1, 1)
    label.Parent = screenGui
    espLabels[player] = label
    
    RunService.RenderStepped:Connect(function()
        if not espEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            label.Visible = false
            return
        end
        local rootPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
        if onScreen then
            label.Position = UDim2.new(0, rootPos.X - 50, 0, rootPos.Y - 30)
            label.Text = player.Name .. " | " .. math.floor((player.Character.Humanoid and player.Character.Humanoid.Health) or 100) .. " HP"
            label.Visible = true
        else
            label.Visible = false
        end
    end)
end

-- Aimbot for mobile (touch-based)
local function getClosestTouch()
    local closest = nil
    local shortestDist = fovRadius
    local touchPos = UserInputService:GetTouchPositions()
    local touch = touchPos[1] or Vector2.new(0, 0)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(rootPos.X, rootPos.Y) - touch).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

-- Aimbot shoot on touch
UserInputService.TouchTap:Connect(function(touch)
    if not aimbotEnabled then return end
    local target = getClosestTouch()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = target.Character.HumanoidRootPart.Position
        local lookVector = (targetPos - Camera.CFrame.Position).Unit
        local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
        Camera.CFrame = newCFrame
        wait(0.05)
        VirtualUser:Button1Down(Vector2.new(0,0))
        wait(0.02)
        VirtualUser:Button1Up(Vector2.new(0,0))
    end
end)

-- Also aim when holding on screen (for auto-fire)
UserInputService.TouchLongPress:Connect(function(touch)
    if not aimbotEnabled then return end
    local target = getClosestTouch()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = target.Character.HumanoidRootPart.Position
        local lookVector = (targetPos - Camera.CFrame.Position).Unit
        local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
        Camera.CFrame = newCFrame
    end
end)

-- Initialize ESP
for _, player in pairs(Players:GetPlayers()) do
    createUESP(player)
end
Players.PlayerAdded:Connect(createUESP)
Players.PlayerRemoving:Connect(function(player)
    if espLabels[player] then
        espLabels[player]:Destroy()
        espLabels[player] = nil
    end
end)

-- Button toggles
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.6, 0.2, 0.2)
    for _, label in pairs(espLabels) do
        label.Visible = espEnabled
    end
end)

aimBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimBtn.Text = aimbotEnabled and "AIMBOT: ON" or "AIMBOT: OFF"
    aimBtn.BackgroundColor3 = aimbotEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.6, 0.2, 0.2)
end)

-- Drag support for mobile
local dragStart, startPos, dragging
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("Rivals Mobile script loaded. Password: astro - Tap enemies to aim, hold to track.")
