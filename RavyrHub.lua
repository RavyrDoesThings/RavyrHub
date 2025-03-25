l-- When you die, re-execute the script.

ocal Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local sprinting = false
local noclipping = false
local canDoubleJump = true

-- UI Creation
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "RavyrHub"

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 250, 0, 300)
mainFrame.Position = UDim2.new(0.02, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(128, 0, 128)
mainFrame.Visible = false -- Starts hidden

-- "RavyrHub" Title
local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "RavyrHub"
titleLabel.TextColor3 = Color3.fromRGB(128, 0, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20

local scrollingFrame = Instance.new("ScrollingFrame", mainFrame)
scrollingFrame.Size = UDim2.new(1, 0, 1, -35)
scrollingFrame.Position = UDim2.new(0, 0, 0, 35)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 1.5, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 128)

-- Mobile UI Toggle Button
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0.9, 0, 0.1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
toggleButton.Text = "☰"
toggleButton.TextScaled = true
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- PC Keybind Toggle (P)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.P then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Button function creator
local function createButton(name, toggle, callback)
    local button = Instance.new("TextButton", scrollingFrame)
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Position = UDim2.new(0, 5, 0, (#scrollingFrame:GetChildren() - 1) * 45)
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16

    if toggle then
        local isOn = false
        button.MouseButton1Click:Connect(function()
            isOn = not isOn
            button.Text = name .. (isOn and " [ON]" or " [OFF]")
            callback(isOn)
        end)
    else
        button.MouseButton1Click:Connect(callback)
    end
end

-- Sprint Toggle
createButton("Sprint", true, function(state)
    humanoid.WalkSpeed = state and 30 or 16
end)

-- See You! (Teleport to closest player)
createButton("See You!", false, function()
    local closestPlayer = nil
    local minDist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closestPlayer = p
            end
        end
    end
    if closestPlayer then
        character.HumanoidRootPart.CFrame = closestPlayer.Character.HumanoidRootPart.CFrame
    end
end)

-- Double Jump
UserInputService.JumpRequest:Connect(function()
    if canDoubleJump and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        canDoubleJump = false
    end
end)

createButton("DoubleJump", false, function()
    canDoubleJump = true
end)

-- FrontFlip (Now a Dash!)
createButton("FrontFlip", false, function()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local dashVelocity = Instance.new("BodyVelocity", rootPart)
        dashVelocity.Velocity = rootPart.CFrame.LookVector * 1000
        dashVelocity.MaxForce = Vector3.new(5000, 0, 5000)
        game:GetService("Debris"):AddItem(dashVelocity, 0.2)
    end
end)

-- NoClip Toggle
RunService.Stepped:Connect(function()
    if noclipping then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

createButton("NoClipper", true, function(state)
    noclipping = state
end)