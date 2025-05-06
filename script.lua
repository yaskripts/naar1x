-- Настройки Dash
local DashSettings = {
    DashDistance = 51,          -- Дистанция рывка
    DashDuration = 0.1,         -- Длительность рывка
    ButtonSize = UDim2.new(0, 50, 0, 50), -- Квадратная кнопка 50x50
    BackButtonPosition = UDim2.new(0.9, 0, 0.85, 0), -- Позиция кнопки назад
    ForwardButtonPosition = UDim2.new(0.8, 0, 0.85, 0), -- Позиция кнопки вперед
    ButtonColor = Color3.new(0, 0, 0), -- Черный цвет
    TextColor = Color3.new(1, 1, 1) -- Белый текст
}

-- Создаем интерфейс
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Удаляем старый UI если есть
if playerGui:FindFirstChild("DashUI") then
    playerGui.DashUI:Destroy()
end

-- Создаем экранный GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DashUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- Функция создания кнопки
local function createDashButton(name, text, position)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = DashSettings.ButtonSize
    button.Position = position
    button.Text = text
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.TextSize = 24
    button.BackgroundColor3 = DashSettings.ButtonColor
    button.TextColor3 = DashSettings.TextColor
    button.BorderSizePixel = 0
    button.ZIndex = 10
    button.Active = true
    button.Draggable = true

    -- Стилизация кнопки
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = button

    -- Эффекты при взаимодействии
    button.MouseEnter:Connect(function()
        button.BackgroundTransparency = 0.3
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundTransparency = 0
    end)

    button.MouseButton1Down:Connect(function()
        button.BackgroundTransparency = 0.5
    end)

    button.MouseButton1Up:Connect(function()
        button.BackgroundTransparency = 0
    end)

    return button
end

-- Создаем кнопки
local backButton = createDashButton("BackDashButton", "←", DashSettings.BackButtonPosition)
local forwardButton = createDashButton("ForwardDashButton", "→", DashSettings.ForwardButtonPosition)

screenGui.Parent = playerGui
backButton.Parent = screenGui
forwardButton.Parent = screenGui

-- Логика Dash
local function performDash(direction)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart or humanoid:GetState() == Enum.HumanoidStateType.Dead then
        return
    end
    
    -- Определяем направление рывка
    local camera = workspace.CurrentCamera
    local dashVector = camera.CFrame.LookVector * DashSettings.DashDistance * direction
    
    -- Плавное перемещение
    local startPos = rootPart.Position
    local endPos = startPos + Vector3.new(dashVector.X, 0, dashVector.Z)
    local startTime = os.clock()
    
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        local elapsed = os.clock() - startTime
        local progress = math.min(elapsed / DashSettings.DashDuration, 1)
        
        if progress < 1 then
            local smoothProgress = progress^2
            rootPart.CFrame = CFrame.new(startPos:Lerp(endPos, smoothProgress)) * rootPart.CFrame.Rotation
        else
            connection:Disconnect()
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end

-- Обработчики кнопок
backButton.MouseButton1Click:Connect(function()
    performDash(-1) -- -1 для рывка назад
end)

forwardButton.MouseButton1Click:Connect(function()
    performDash(1) -- 1 для рывка вперед
end)

-- Сохранение позиции кнопок
backButton.DragStopped:Connect(function()
    DashSettings.BackButtonPosition = backButton.Position
end)

forwardButton.DragStopped:Connect(function()
    DashSettings.ForwardButtonPosition = forwardButton.Position
end)

-- Автоматическая настройка при респавне
player.CharacterAdded:Connect(function()
    task.wait(0.5) -- Ждем полной загрузки персонажа
end)
