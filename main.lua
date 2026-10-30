-- 1. Tunggu game selesai loading penuh
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local startPlaceId = game.PlaceId

-- ==================== [ GUI USERNAME AKUN ] ====================
local CoreGui = game:GetService("CoreGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AccountInfoGui"
screenGui.ResetOnSpawn = false

local myUsername = LocalPlayer.Name

local suksesGui, errGui = pcall(function()
    screenGui.Parent = CoreGui
end)
if not suksesGui then
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 50)
frame.Position = UDim2.new(0.5, -125, 0.5, -25)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.2
frame.Parent = screenGui

pcall(function()
    GuiService.MenuOpened:Connect(function() screenGui.Enabled = false end)
    GuiService.MenuClosed:Connect(function() screenGui.Enabled = true end)
end)

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -40, 1, 0)
label.Position = UDim2.new(0, 10, 0, 0)
label.BackgroundTransparency = 1
label.Text = "Account: " .. myUsername
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 18
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 25, 0, 25)
toggleBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.Text = "-"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleBtn

local invisibleClicker = Instance.new("TextButton")
invisibleClicker.Size = UDim2.new(1, 0, 1, 0)
invisibleClicker.BackgroundTransparency = 1
invisibleClicker.Text = ""
invisibleClicker.Visible = false
invisibleClicker.Parent = frame

local isMinimized = false

toggleBtn.MouseButton1Click:Connect(function()
    if not isMinimized then
        isMinimized = true
        toggleBtn.Visible = false
        label.Visible = false
        frame:TweenSize(UDim2.new(0, 50, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        task.wait(0.3)
        invisibleClicker.Visible = true
    end
end)

invisibleClicker.MouseButton1Click:Connect(function()
    if isMinimized then
        isMinimized = false
        invisibleClicker.Visible = false
        frame:TweenSize(UDim2.new(0, 250, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        task.wait(0.15)
        label.Visible = true
        toggleBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
        toggleBtn.Text = "-"
        toggleBtn.Visible = true
    end
end)

print("[MELOAD] Template Berjalan!")

-- Variabel Kontrol Auto Reconnect
local autoReconnectEnabled = true
local isReconnecting = false

local function handleReconnect(reason)
    if isReconnecting or not autoReconnectEnabled then return end
    isReconnecting = true
    warn("[AutoReconnect]", reason)
    pcall(function()
        if #Players:GetPlayers() <= 1 then
            LocalPlayer:Kick("\nRejoining...")
        end
        TeleportService:Teleport(startPlaceId, LocalPlayer)
    end)
    isReconnecting = false
end

pcall(function()
    if GuiService then
        GuiService.ErrorMessageChanged:Connect(function(msg)
            msg = tostring(msg):lower()
            if msg:find("disconnect") or msg:find("internet") or msg:find("connection") or msg:find("kicked") then
                handleReconnect("Connection Error Detected")
            end
        end)
    end
end)

-- ==================== [ ANTI-AFK ] ====================
local function setupSafeAntiAFK()
    if getconnections then
        for _, c in getconnections(LocalPlayer.Idled) do
            pcall(function() c:Disable() end)
            pcall(function() c:Disconnect() end)
        end
    end
    LocalPlayer.Idled:Connect(function()
        pcall(function()
            local VIM = Instance.new("VirtualInputManager")
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            VIM:Destroy()
        end)
    end)
end
setupSafeAntiAFK()

-- ==================== [ FUNGSI DETEKSI PLOT & TELEPORT ] ====================
local function findMyPlot()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        for _, descendant in ipairs(plot:GetDescendants()) do
            if descendant.Name == "Name" and descendant:IsA("TextLabel") then
                local text = descendant.Text:lower()
                if text == LocalPlayer.Name:lower() or text == LocalPlayer.DisplayName:lower() then
                    return plot
                end
            end
        end
    end
    return nil
end

local function teleportToPullUpStand()
    local myPlot = findMyPlot()
    if myPlot then
        local serverFolder = myPlot:FindFirstChild("Server")
        local pullUpStand = serverFolder and serverFolder:FindFirstChild("PullUpStand")
        if pullUpStand then
            local targetPart = pullUpStand:IsA("BasePart") and pullUpStand 
                or pullUpStand:FindFirstChildWhichIsA("BasePart", true)
                
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if targetPart and rootPart then
                rootPart.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
                print("[Teleport] Sukses pindah ke PullUpStand di plot:", myPlot.Name)
                return true
            end
        end
    end
    return false
end

task.spawn(function()
    task.wait(2)
    teleportToPullUpStand()
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3)
    teleportToPullUpStand()
end)

-- ==================== [ AUTO UPGRADE OTOMATIS ] ====================
local upgradeEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Stand_Upgrade")

local function parseMoney(text)
    if type(text) == "number" then return text end
    local cleanText = tostring(text):lower():gsub("[%$%,%s]", "")
    local numberPart = tonumber(cleanText:match("[%d%.]+"))
    if not numberPart then return 0 end

    local suffix = cleanText:match("([a-z]+)$") or ""
    local multiplier = ({
        k = 1e3,
        m = 1e6,
        b = 1e9,
        t = 1e12,
        qa = 1e15,
        qi = 1e18,
        sx = 1e21,
        sp = 1e24,
        oc = 1e27,
        no = 1e30,
        dc = 1e33,
    })[suffix] or 1

    return numberPart * multiplier
end

local lastAttemptPrice = nil
local lastAttemptTime = 0
local lastDebugSnapshot = nil

local function getUpgradePriceLabel()
    local localPlotProps = workspace:FindFirstChild("LocalPlotProps")
    local trainingSpot = localPlotProps
        and localPlotProps:FindFirstChild("TrainingArea")
        and localPlotProps.TrainingArea:FindFirstChild("TrainingSpot")
    local upgradeButton = trainingSpot and trainingSpot:FindFirstChild("UpgradeButton")
    local priceAnchor = upgradeButton and upgradeButton:FindFirstChild("PriceAnchor")
    local billboard = priceAnchor and priceAnchor:FindFirstChild("PriceBillboard")
    local holder = billboard and billboard:FindFirstChild("Holder")
    local priceHolder = holder and holder:FindFirstChild("PriceHolder")
    local priceLabel = priceHolder and priceHolder:FindFirstChild("Price")

    if priceLabel and priceLabel:IsA("TextLabel") then
        return priceLabel
    end
    return nil
end

-- Cek saldo berulang. Jika request tidak mengubah harga, coba lagi setelah jeda.
task.spawn(function()
    while task.wait(1) do
        local priceLabel = getUpgradePriceLabel()
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        local moneyStat = leaderstats and leaderstats:FindFirstChild("Money")

        if priceLabel and moneyStat then
            local hargaUpgrade = parseMoney(priceLabel.Text)
            local uangGua = parseMoney(moneyStat.Value)

            local debugSnapshot = tostring(priceLabel.Text) .. "|" .. tostring(moneyStat.Value)
            if debugSnapshot ~= lastDebugSnapshot then
                lastDebugSnapshot = debugSnapshot
                print(string.format(
                    "[AutoUpgrade] Harga=%s (%s) | Uang=%s (%s)",
                    tostring(priceLabel.Text), tostring(hargaUpgrade),
                    tostring(moneyStat.Value), tostring(uangGua)
                ))
            end

            -- Harga berubah setelah upgrade, jadi izinkan request untuk harga baru.
            if lastAttemptPrice and hargaUpgrade ~= lastAttemptPrice then
                lastAttemptPrice = nil
                lastAttemptTime = 0
            end

            local retryReady = lastAttemptPrice ~= hargaUpgrade or (os.clock() - lastAttemptTime >= 5)
            if hargaUpgrade > 0 and uangGua >= hargaUpgrade and retryReady then
                lastAttemptPrice = hargaUpgrade
                lastAttemptTime = os.clock()
                print("[AutoUpgrade] Saldo cukup; mengirim request untuk", priceLabel.Text)

                local success, result = pcall(function()
                    return upgradeEvent:InvokeServer()
                end)

                if success then
                    print("[AutoUpgrade] Request terkirim. Hasil server:", tostring(result))
                    task.spawn(function()
                        -- Anggap upgrade berhasil setelah harga berubah, lalu kembali ke PullUpStand.
                        for _ = 1, 8 do
                            task.wait(1)
                            local updatedPriceLabel = getUpgradePriceLabel()
                            if updatedPriceLabel and parseMoney(updatedPriceLabel.Text) ~= hargaUpgrade then
                                task.wait(0.5)
                                for attempt = 1, 5 do
                                    if teleportToPullUpStand() then
                                        print("[AutoUpgrade] Karakter dikembalikan ke PullUpStand.")
                                        break
                                    end
                                    task.wait(1)
                                end
                                break
                            end
                        end
                    end)
                else
                    warn("[AutoUpgrade] Request gagal:", tostring(result))
                    lastAttemptPrice = nil
                end
            end
        end
    end
end)
