-- RIVALS PERFECT AIMLOCK + AIM ASSIST 100% (Hydrogen/CodeX)
-- Password: astro

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

-- Settings
local aimlockEnabled = true
local espEnabled = true
local circleRadius = 120
local aimAssistStrength = 1.0 -- 100% strength

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RivalsPerfectAim"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 110)
mainFrame.Position = UDim2.new(0, 10, 0, 80)
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
espBtn.Size = UDim2.new(0, 160, 0, 30)
espBtn.Position = UDim2.new(0, 10, 0, 38)
espBtn.Text = "ESP: ON"
espBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
espBtn.Parent = mainFrame

local aimBtn = Instance.new("TextButton")
aimBtn.Size = UDim2.new(0, 160, 0, 30)
aimBtn.Position = UDim2.new(0, 10, 0, 72)
aimBtn.Text = "AIMLOCK: ON"
aimBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
aimBtn.Parent = mainFrame

-- Draw center circle
local circle = Drawing.new("Circle")
circle.Radius = circleRadius
circle.Thickness = 3
circle.Color = Color3.new(0, 1, 0)
circle.Filled = false
circle.Visible = true
circle.Transparency = 0.8
circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- ESP
local espLabels = {}
local function createESP(player)
    if player == LocalPlayer then return end
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 100, 0, 20)
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.BackgroundTransparency = 0.6
    label.TextColor3 = Color3.new(1, 0, 0)
    label.BorderSizePixel = 1
    label.BorderColor3 = Color3.new(1, 1, 1)
    label.Parent = screenGui
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    espLabels[player] = label
    
    RunService.RenderStepped:Connect(function()
        if not espEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            if label then label.Visible = false end
            return
        end
        local rootPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
        if onScreen then
            label.Position = UDim2.new(0, rootPos.X - 50, 0, rootPos.Y - 35)
            local health = player.Character:FindFirstChild("Humanoid") and math.floor(player.Character.Humanoid.Health) or 100
            label.Text = player.Name .. " | " .. health .. " HP"
            label.Visible = true
        else
            label.Visible = false
        end
    end)
end

-- Get closest player to circle center
local function getTargetInCircle()
    local center = circle.Position
    local bestTarget = nil
    local bestDistance = circleRadius
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distToCenter = (Vector2.new(rootPos.X, rootPos.Y) - center).Magnitude
                if distToCenter < bestDistance then
                    bestDistance = distToCenter
                    bestTarget = player
                end
            end
        end
    end
    return bestTarget, bestDistance
end

-- 100% AIM ASSIST + AIMLOCK
local currentTarget = nil
local targetLocked = false

RunService.RenderStepped:Connect(function()
    if not aimlockEnabled then 
        circle.Color = Color3.new(0, 1, 0)
        return 
    end
    
    local target, dist = getTargetInCircle()
    
    if target then
        circle.Color = Color3.new(1, 0, 0) -- Red when target in circle
        currentTarget = target
        targetLocked = true
        
        -- Get target position
        local targetPos = target.Character.HumanoidRootPart.Position
        local currentCamPos = Camera.CFrame.Position
        local direction = (targetPos - currentCamPos).Unit
        
        -- 100% aim assist: instant snap to target
        local newCFrame = CFrame.new(currentCamPos, currentCamPos + direction)
        Camera.CFrame = newCFrame
        
        -- Auto shoot when target locked
        VirtualUser:Button1Down(Vector2.new(0,0))
        wait(0.01)
        VirtualUser:Button1Up(Vector2.new(0,0))
        
    else
        circle.Color = Color3.new(0, 1, 0) -- Green when empty
        targetLocked = false
        currentTarget = nil
    end
end)

-- Also aim assist on touch (manual shooting)
UserInputService.TouchTap:Connect(function(touch)
    if not aimlockEnabled then return end
    local target, _ = getTargetInCircle()
    if target then
        local targetPos = target.Character.HumanoidRootPart.Position
        local direction = (targetPos - Camera.CFrame.Position).Unit
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
    end
end)

-- Initialize ESP
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end
Players.PlayerAdded:Connect(createESP)
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
    aimlockEnabled = not aimlockEnabled
    aimBtn.Text = aimlockEnabled and "AIMLOCK: ON" or "AIMLOCK: OFF"
    aimBtn.BackgroundColor3 = aimlockEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.6, 0.2, 0.2)
    if not aimlockEnabled then
        circle.Color = Color3.new(0, 1, 0)
    end
end)

-- Drag support
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

print("Rivals 100% AIMLOCK + AIM ASSIST ACTIVE. Circle turns RED when enemy inside. Auto aims and shoots.")
