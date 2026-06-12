-- RIVALS TRUE AIMBOT - REMOTE MANIPULATION (Hydrogen/CodeX)
-- Password: astro

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

-- Settings
local aimbotEnabled = true
local espEnabled = true
local circleRadius = 150

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RivalsTrueAimbot"
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
aimBtn.Text = "AIMBOT: ON"
aimBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
aimBtn.Parent = mainFrame

-- Circle
local circle = Drawing.new("Circle")
circle.Radius = circleRadius
circle.Thickness = 3
circle.Color = Color3.new(0, 1, 0)
circle.Filled = false
circle.Visible = true

RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- ESP
local espLabels = {}
local function createESP(player)
    if player == LocalPlayer then return end
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 110, 0, 22)
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.BackgroundTransparency = 0.5
    label.TextColor3 = Color3.new(1, 0.5, 0)
    label.BorderSizePixel = 1
    label.Parent = screenGui
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    espLabels[player] = label
    
    RunService.RenderStepped:Connect(function()
        if not espEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            if label then label.Visible = false end
            return
        end
        local rootPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
        if onScreen then
            label.Position = UDim2.new(0, rootPos.X - 55, 0, rootPos.Y - 40)
            local health = player.Character:FindFirstChild("Humanoid") and math.floor(player.Character.Humanoid.Health) or 100
            label.Text = player.Name .. " ❤️ " .. health
            label.Visible = true
        else
            label.Visible = false
        end
    end)
end

-- Get target in circle
local function getTargetInCircle()
    local center = circle.Position
    local bestTarget = nil
    local bestDist = circleRadius
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(rootPos.X, rootPos.Y) - center).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestTarget = player
                end
            end
        end
    end
    return bestTarget
end

-- HOOK FIRE REMOTE AND REDIRECT BULLETS
local function hookFireRemote(target)
    if not target then return end
    
    -- Get target head position
    local headPos = target.Character:FindFirstChild("Head") and target.Character.Head.Position or target.Character.HumanoidRootPart.Position
    local screenPos = Camera:WorldToViewportPoint(headPos)
    
    -- Simulate mouse movement to target (forces bullet direction)
    local originalMousePos = UserInputService:GetMouseLocation()
    local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
    
    -- Move mouse to target instantly
    mousemoveabs(targetScreenPos.X, targetScreenPos.Y)
    wait(0.01)
    
    -- Fire weapon
    VirtualUser:Button1Down(Vector2.new(0,0))
    wait(0.01)
    VirtualUser:Button1Up(Vector2.new(0,0))
    
    -- Restore mouse position (optional)
    mousemoveabs(originalMousePos.X, originalMousePos.Y)
end

-- Override mouse functions if available
local mouseMove = mousemoveabs or (syn and syn.mousemoveabs) or (keypress and keypress)
if not mouseMove then
    print("Mouse manipulation not supported. Using fallback method.")
end

-- AIMBOT LOOP
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then 
        circle.Color = Color3.new(0, 1, 0)
        return 
    end
    
    local target = getTargetInCircle()
    if target then
        circle.Color = Color3.new(1, 0, 0)
        
        -- Method 1: Mouse move + click
        if mouseMove then
            local headPos = target.Character:FindFirstChild("Head") and target.Character.Head.Position or target.Character.HumanoidRootPart.Position
            local screenPos = Camera:WorldToViewportPoint(headPos)
            if screenPos then
                mouseMove(screenPos.X, screenPos.Y)
                VirtualUser:Button1Down(Vector2.new(0,0))
                wait(0.01)
                VirtualUser:Button1Up(Vector2.new(0,0))
            end
        else
            -- Fallback: lock camera and use CFrame
            local headPos = target.Character:FindFirstChild("Head") and target.Character.Head.Position or target.Character.HumanoidRootPart.Position
            local targetDir = (headPos - Camera.CFrame.Position).Unit
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + targetDir)
            VirtualUser:Button1Down(Vector2.new(0,0))
            wait(0.01)
            VirtualUser:Button1Up(Vector2.new(0,0))
        end
    else
        circle.Color = Color3.new(0, 1, 0)
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
    aimbotEnabled = not aimbotEnabled
    aimBtn.Text = aimbotEnabled and "AIMBOT: ON" or "AIMBOT: OFF"
    aimBtn.BackgroundColor3 = aimbotEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.6, 0.2, 0.2)
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

print("TRUE AIMBOT ACTIVE - Using mouse move + click for accuracy. If still inaccurate, your executor does not support mousemoveabs.")
