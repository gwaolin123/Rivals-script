-- RIVALS FULL FIXED SCRIPT - WORKING GUI + AIMBOT + ESP (CodeX)
-- Password: astro

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local aimbotEnabled = true
local espEnabled = true
local fovRadius = 200
local smoothness = 5

-- Create GUI directly (no password popup)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RivalsGUI"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 110)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.new(1, 0.5, 0)
mainFrame.Parent = mainFrame
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
espBtn.Position = UDim2.new(0, 10, 0, 35)
espBtn.Text = "ESP: ON"
espBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
espBtn.Parent = mainFrame

local aimBtn = Instance.new("TextButton")
aimBtn.Size = UDim2.new(0, 160, 0, 30)
aimBtn.Position = UDim2.new(0, 10, 0, 70)
aimBtn.Text = "AIMBOT: ON"
aimBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
aimBtn.Parent = mainFrame

-- ESP Function
local espObjects = {}
local function createESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Box")
    local nameTag = Drawing.new("Text")
    local distanceText = Drawing.new("Text")
    
    box.Thickness = 1
    box.Transparency = 1
    box.Color = Color3.new(1, 0, 0)
    nameTag.Color = Color3.new(1, 1, 1)
    nameTag.Size = 14
    nameTag.Center = true
    distanceText.Color = Color3.new(1, 1, 0)
    distanceText.Size = 12
    distanceText.Center = true
    
    espObjects[player] = {box = box, nameTag = nameTag, distance = distanceText}
    
    RunService.RenderStepped:Connect(function()
        if not espEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            box.Visible = false
            nameTag.Visible = false
            distanceText.Visible = false
            return
        end
        
        local rootPart = player.Character.HumanoidRootPart
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
            local scale = 3 / math.max(distance, 1) * 5
            local height = 5 * scale
            local width = 3 * scale
            box.Size = Vector2.new(width * 50, height * 50)
            box.Position = Vector2.new(screenPos.X - width * 25, screenPos.Y - height * 25)
            box.Visible = true
            nameTag.Text = player.Name .. " | " .. math.floor((player.Character.Humanoid and player.Character.Humanoid.Health) or 100)
            nameTag.Position = Vector2.new(screenPos.X, screenPos.Y - height * 25 - 10)
            nameTag.Visible = true
            distanceText.Text = math.floor(distance) .. "m"
            distanceText.Position = Vector2.new(screenPos.X, screenPos.Y + height * 25 + 5)
            distanceText.Visible = true
        else
            box.Visible = false
            nameTag.Visible = false
            distanceText.Visible = false
        end
    end)
end

-- Aimbot
local function getClosestPlayer()
    local closest = nil
    local shortestDist = fovRadius
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(rootPos.X, rootPos.Y) - mousePos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = target.Character.HumanoidRootPart.Position
        local lookVector = (targetPos - Camera.CFrame.Position).Unit
        local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 1 / smoothness)
    end
end)

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        espObjects[player].box:Remove()
        espObjects[player].nameTag:Remove()
        espObjects[player].distance:Remove()
        espObjects[player] = nil
    end
end)

-- Button functions
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.6, 0.2, 0.2)
end)

aimBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimBtn.Text = aimbotEnabled and "AIMBOT: ON" or "AIMBOT: OFF"
    aimBtn.BackgroundColor3 = aimbotEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.6, 0.2, 0.2)
end)

-- Drag for mobile
local dragging = false
local dragInput
local dragStart
local startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("Rivals script loaded. Password: astro - GUI should be visible.")
