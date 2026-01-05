-- [[ CONFIGURAÇÕES E VARIÁVEIS DE CONTROLE ]]
local _g = getgenv and getgenv() or _G
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Prevenção de execução dupla
if _g.ScriptJaCarregado then 
    warn("O script já está em execução!")
    return 
end
_g.ScriptJaCarregado = true

-- Estados das Funções
local Config = {
    ESP = false,
    Aimbot = false,
    MenuVisible = true
}

--- [[ INTERFACE DO USUÁRIO (UI) ]] ---

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ESPBtn = Instance.new("TextButton")
local AimbotBtn = Instance.new("TextButton")

ScreenGui.Name = "PainelMelhorado"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Active = true
MainFrame.Draggable = true -- Nota: Draggable é antigo, mas funcional para scripts simples

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Menu de Auxílio"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local function ConfigurarBotao(btn, texto, pos)
    btn.Parent = MainFrame
    btn.Position = pos
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Text = texto
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
end

ConfigurarBotao(ESPBtn, "ESP: OFF", UDim2.new(0.1, 0, 0.3, 0))
ConfigurarBotao(AimbotBtn, "Aimbot: OFF", UDim2.new(0.1, 0, 0.6, 0))

--- [[ LÓGICA DAS FUNCIONALIDADES ]] ---

-- Alternar Visibilidade do Menu (Tecla Insert)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        Config.MenuVisible = not Config.MenuVisible
        MainFrame.Visible = Config.MenuVisible
    end
end)

-- Lógica do ESP (Atualização em Loop Único)
ESPBtn.MouseButton1Click:Connect(function()
    Config.ESP = not Config.ESP
    ESPBtn.Text = "ESP: " .. (Config.ESP and "ON" or "OFF")
    ESPBtn.BackgroundColor3 = Config.ESP and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

-- Lógica do Aimbot (Cálculo de Alvo)
AimbotBtn.MouseButton1Click:Connect(function()
    Config.Aimbot = not Config.Aimbot
    AimbotBtn.Text = "Aimbot: " .. (Config.Aimbot and "ON" or "OFF")
    AimbotBtn.BackgroundColor3 = Config.Aimbot and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.PrimaryPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    
                    if distance < shortestDistance then
                        closest = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closest
end

-- LOOP ÚNICO DE RENDERIZAÇÃO (Controla tudo sem criar múltiplos processos)
RunService.RenderStepped:Connect(function()
    -- Lógica de Aimbot
    if Config.Aimbot then
        local target = GetClosestPlayer()
        if target and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end

    -- Lógica de ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESPHighlight")
            
            if Config.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end)

print("Script carregado com sucesso!")
