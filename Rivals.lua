-- RIVALS AIMBOT + ESP WITH PASSWORD (CodeX)
-- Password: astro

local password = "astro"
local userInput = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Password check
local function checkPassword()
    local pwd = string.lower(game:GetService("TextService"):FilterStringAsync(userInput:GetString(), LocalPlayer.UserId))
    if pwd == password then
        return true
    else
        return false
    end
end

-- Load only if password matches
if not checkPassword() then
    print("Incorrect password")
    return
end

-- Settings
local aimbotEnabled = true
local espEnabled = true
local fovRadius = 150
local smoothness = 8

-- ESP
local function createESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Box")
    local nameTag = Drawing.new("Text")
    box.Thickness = 1
    box.Transparency = 1
    box.Color = Color3.new(1, 0, 0)
    nameTag.Color = Color3.new(1, 1, 1)
    nameTag.Size = 12
    nameTag.Center = true
    
    RunService.RenderStepped:Connect(function()
        if not espEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            box.Visible = false
            nameTag.Visible = false
            return
        end
        local rootPart = player.Character.HumanoidRootPart
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
            local scale = 3 / distance * 5
            local height = 5 * scale
            local width = 3 * scale
            box.Size = Vector2.new(width * 50, height * 50)
            box.Position = Vector2.new(screenPos.X - width * 25, screenPos.Y - height * 25)
            box.Visible = true
            nameTag.Text = player.Name .. " | " .. math.floor(distance) .. "m"
            nameTag.Position = Vector2.new(screenPos.X, screenPos.Y - height * 25 - 10)
            nameTag.Visible = true
        else
            box.Visible = false
            nameTag.Visible = false
        end
    end)
end

-- Aimbot
local function getClosestPlayer()
    local closest = nil
    local shortestDist = fovRadius
    local mousePos = userInput:GetMouseLocation()
    
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

if aimbotEnabled then
    RunService.RenderStepped:Connect(function()
        if not userInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            local lookVector = (targetPos - Camera.CFrame.Position).Unit
            local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 1 / smoothness)
        end
    end)
end

-- ESP for all players
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end
Players.PlayerAdded:Connect(createESP)

-- GUI
local screenGui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local title = Instance.new("TextLabel")
local espBtn = Instance.new("TextButton")
local aimBtn = Instance.new("TextButton")

screenGui.Parent = game:GetService("CoreGui")
frame.Parent = screenGui
frame.Size = UDim2.new(0, 150, 0, 120)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.3

title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "RIVALS | astro"
title.TextColor3 = Color3.new(1, 1, 0)

espBtn.Parent = frame
espBtn.Size = UDim2.new(0, 130, 0, 30)
espBtn.Position = UDim2.new(0, 10, 0, 40)
espBtn.Text = "ESP: ON"
espBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)

aimBtn.Parent = frame
aimBtn.Size = UDim2.new(0, 130, 0, 30)
aimBtn.Position = UDim2.new(0, 10, 0, 80)
aimBtn.Text = "AIMBOT: ON"
aimBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)

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

print("Rivals script loaded. Password: astro")
