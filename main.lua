-- HWID验证系统
local Key = "%%KEY%%" -- 会被替换为实际卡密

-- 配置
local GITHUB_DB_URL = "https://raw.githubusercontent.com/你的数据类账号/script-database/main/database.json"

-- 获取HWID
local function GetHWID()
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    return tostring(localPlayer.UserId) .. "_" .. game.JobId .. "_" .. tostring(os.time())
end

-- 获取数据库
local function GetDatabase()
    local httpService = game:GetService("HttpService")
    
    local success, result = pcall(function()
        local response = httpService:GetAsync(GITHUB_DB_URL .. "?t=" .. tick())
        return httpService:JSONDecode(response)
    end)
    
    if success then
        return result
    else
        warn("无法获取数据库")
        return nil
    end
end

-- 查找卡密信息
local function FindKeyInfo(key)
    local db = GetDatabase()
    if not db or not db.keys then return nil end
    
    for _, keyInfo in ipairs(db.keys) do
        if keyInfo.key == key then
            return keyInfo
        end
    end
    return nil
end

-- 显示HWID错误
local function ShowHwidError(boundHwid)
    local screenGui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local label = Instance.new("TextLabel")
    local closeBtn = Instance.new("TextButton")
    
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- 右下角错误窗口
    frame.Size = UDim2.new(0, 400, 0, 180)
    frame.Position = UDim2.new(1, -420, 1, -190)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0
    
    local hwidDisplay = boundHwid
    if hwidDisplay and string.len(hwidDisplay) > 20 then
        hwidDisplay = string.sub(hwidDisplay, 1, 20) .. "..."
    end
    
    label.Size = UDim2.new(1, -20, 0.7, 0)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 100, 100)
    label.Text = "❌ HWID 不匹配\n\n此脚本已绑定其他设备\n请在Discord使用 /cz 重置HWID\n然后重新注入脚本\n\n绑定HWID: " .. (hwidDisplay or "未知")
    label.TextWrapped = true
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame
    
    closeBtn.Size = UDim2.new(0, 100, 0, 30)
    closeBtn.Position = UDim2.new(0.5, -50, 0.8, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "关闭"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    frame.Parent = screenGui
end

-- 显示绑定成功窗口
local function ShowBindSuccessWindow()
    local screenGui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local label = Instance.new("TextLabel")
    local closeBtn = Instance.new("TextButton")
    
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    frame.Size = UDim2.new(0, 350, 0, 200)
    frame.Position = UDim2.new(0.5, -175, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    
    label.Size = UDim2.new(1, -20, 0.7, 0)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(100, 255, 100)
    label.Text = "✅ HWID绑定成功！\n\n当前设备已成功绑定到你的卡密\n下次可直接使用此设备\n\n如需更换设备，请在Discord使用 /cz 重置"
    label.TextWrapped = true
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.Parent = frame
    
    closeBtn.Size = UDim2.new(0, 120, 0, 35)
    closeBtn.Position = UDim2.new(0.5, -60, 0.8, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "开始使用"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    frame.Parent = screenGui
    
    return screenGui
end

-- 显示过期提示
local function ShowExpiredWindow(expireTime)
    local screenGui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local label = Instance.new("TextLabel")
    local closeBtn = Instance.new("TextButton")
    
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    frame.Size = UDim2.new(0, 380, 0, 180)
    frame.Position = UDim2.new(0.5, -190, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    
    local displayTime = expireTime
    if expireTime then
        displayTime = string.gsub(expireTime, "T", " ")
        displayTime = string.sub(displayTime, 1, 16)
    end
    
    label.Size = UDim2.new(1, -20, 0.7, 0)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 150, 150)
    label.Text = "❌ 卡密已过期\n\n你的卡密已超过使用期限\n到期时间: " .. (displayTime or "未知") .. "\n\n请联系管理员续费或购买新卡密"
    label.TextWrapped = true
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame
    
    closeBtn.Size = UDim2.new(0, 100, 0, 30)
    closeBtn.Position = UDim2.new(0.5, -50, 0.8, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "关闭"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    frame.Parent = screenGui
end

-- 创建测试窗口
local function CreateTestWindow(expireTime)
    local screenGui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local label = Instance.new("TextLabel")
    local infoLabel = Instance.new("TextLabel")
    local closeBtn = Instance.new("TextButton")
    
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    frame.Size = UDim2.new(0, 320, 0, 220)
    frame.Position = UDim2.new(0.5, -160, 0.5, -110)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    
    label.Size = UDim2.new(1, 0, 0.4, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "moon测试"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = frame
    
    -- 显示到期信息
    local displayTime = expireTime
    if expireTime then
        displayTime = string.gsub(expireTime, "T", " ")
        displayTime = string.sub(displayTime, 1, 16)
    end
    
    infoLabel.Size = UDim2.new(1, -20, 0.3, 0)
    infoLabel.Position = UDim2.new(0, 10, 0.4, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.Text = "✅ 授权验证通过\n到期时间: " .. (displayTime or "未知")
    infoLabel.TextWrapped = true
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 12
    infoLabel.Parent = frame
    
    closeBtn.Size = UDim2.new(0, 100, 0, 30)
    closeBtn.Position = UDim2.new(0.5, -50, 0.8, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Text = "关闭窗口"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    frame.Parent = screenGui
    
    print("🎉 moon测试脚本执行成功！")
end

-- 检查是否过期
local function CheckExpired(expiresAt)
    if not expiresAt then
        return false
    end
    
    -- 简单的时间检查（实际应该更精确）
    local currentTime = os.time()
    local expireTime = nil
    
    -- 尝试解析时间字符串
    if string.find(expiresAt, "T") then
        -- ISO格式: 2024-01-01T00:00:00Z
        local year = tonumber(string.sub(expiresAt, 1, 4))
        local month = tonumber(string.sub(expiresAt, 6, 7))
        local day = tonumber(string.sub(expiresAt, 9, 10))
        local hour = tonumber(string.sub(expiresAt, 12, 13))
        local minute = tonumber(string.sub(expiresAt, 15, 16))
        
        if year and month and day then
            expireTime = os.time({year=year, month=month, day=day, hour=hour or 0, min=minute or 0})
        end
    end
    
    if expireTime then
        return currentTime > expireTime
    end
    
    return false
end

-- 模拟更新HWID到数据库（实际需要API调用）
local function UpdateHWIDInDatabase(key, newHwid)
    -- 这里应该是调用API更新数据库的逻辑
    -- 但由于是只读的GitHub，这里只能模拟
    print("📝 [模拟] 更新HWID: " .. key .. " -> " .. newHwid)
    print("💡 实际使用时需要调用可写的API来更新数据库")
    return true -- 模拟成功
end

-- 主验证逻辑
local function Main()
    local currentHwid = GetHWID()
    local keyInfo = FindKeyInfo(Key)
    
    print("🔑 验证卡密: " .. Key)
    print("🆔 当前HWID: " .. currentHwid)
    
    if not keyInfo then
        warn("❌ 卡密无效或不存在")
        return
    end
    
    if not keyInfo.activated then
        warn("❌ 卡密未激活，请先在Discord兑换")
        return
    end
    
    -- 检查是否过期
    if CheckExpired(keyInfo.expiresAt) then
        print("❌ 卡密已过期")
        ShowExpiredWindow(keyInfo.expiresAt)
        return
    end
    
    -- 检查HWID绑定
    if keyInfo.hwid == nil then
        -- 首次使用，自动绑定当前HWID
        print("✅ 首次使用，自动绑定HWID")
        
        -- 模拟更新数据库（实际需要API）
        local updateSuccess = UpdateHWIDInDatabase(Key, currentHwid)
        
        if updateSuccess then
            ShowBindSuccessWindow()
            -- 等待用户关闭绑定成功窗口后再显示主窗口
            wait(2)
            CreateTestWindow(keyInfo.expiresAt)
        else
            warn("❌ HWID绑定失败")
        end
        
    elseif keyInfo.hwid == currentHwid then
        -- HWID匹配，执行脚本
        print("✅ HWID验证通过")
        CreateTestWindow(keyInfo.expiresAt)
        
    else
        -- HWID不匹配，显示错误
        print("❌ HWID不匹配")
        print("当前绑定HWID: " .. (keyInfo.hwid or "无"))
        ShowHwidError(keyInfo.hwid)
    end
end

-- 显示启动信息
print("🚀 moon脚本启动中...")
print("📋 卡密: " .. Key)

-- 启动验证
Main()
