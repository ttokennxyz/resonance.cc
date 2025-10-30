repeat task.wait() until getgenv().window
print("Visuals now loading!")

local runservice = game:GetService("RunService")
local camera = game.Workspace.Camera

local function deepCopy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local espFrames = {}
local espComponents = {
    cornerHolders = {},
    corners = {},
    boxHolders = {},
    boxes = {},
    healthbarHolders = {},
    healthbars = {},
    textHolders = {},
    textLabels = {},
    backgroundHolders = {},
    backgrounds = {},
}

local espSettings = {
    enabled = true,
    debugMode = true,
    
    components = {
        corners = false,
        boxes = false,
        name = false,
        distance = false,
        healthText = false,
        heldItem = false,
        heldItemImage = false,
        action = false,
        healthbars = false,
        background = false,
    },
    
    colors = {
        corners = Color3.fromRGB(255, 255, 255),
        boxes = Color3.fromRGB(255, 255, 255),
        name = Color3.fromRGB(255, 255, 255),
        distance = Color3.fromRGB(180, 145, 250),
        healthText = Color3.fromRGB(0, 255, 0),
        heldItem = Color3.fromRGB(85, 2, 250),
        action = Color3.fromRGB(255, 255, 0),
        healthbarFull = Color3.fromRGB(0, 255, 0),
        healthbarEmpty = Color3.fromRGB(255, 0, 0),
        outline = Color3.new(0, 0, 0),
        backgroundTop = Color3.fromRGB(112, 30, 252),
        backgroundBottom = Color3.fromRGB(58, 0, 158),
    },
    
    padding = {
        healthbar = 5,
        text = 5,
        textSpacing = 2,
    },
    
    textOrder = {
        "name",
        "healthText",
        "action",
        "distance",
        "heldItemImage",
        "heldItem",
    },
    
    text = {
        fontSize = 11,
        font = Enum.Font.Code,
        strokeThickness = 1,
        distanceFormat = "%d studs",
        healthFormat = "%d/%d HP",
    },
    
    background = {
        transparency = 0.8,
    },
    
    getActionText = function(char, humanoid)
        if not humanoid then return "" end
        
        local state = humanoid:GetState()
        
        if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Flying then
            return "Jumping"
        elseif humanoid.Sit then
            return "Sitting"
        elseif humanoid.MoveDirection.Magnitude > 0 then
            return "Walking"
        else
            return "Standing"
        end
    end,
    
    maxDistance = 1000,
    cornerLength = 15,
    cornerGap = 10,
    boxThickness = 1,
    
    healthbar = {
        position = "left",
        thickness = 4,
        useGradient = false,
        lerpHealth = true,
        lerpSpeed = 5,
    },
    
    heldItemImages = {
        ["Bruno's M4A1"] = "rbxassetid://15574295393",
        ["Crossbow"] = "rbxassetid://15305596532",
        ["Salvaged Shovel"] = "rbxassetid://15073386763",
        ["Salvaged Pipe Rifle"] = "rbxassetid://15092314723",
        ["Steel Axe"] = "rbxassetid://15132541486",
        ["Salvaged RPG"] = "rbxassetid://15132772506",
        ["Small Medkit"] = "rbxassetid://15132566142",
        ["Yellow Keycard"] = "rbxassetid://15303938691",
        ["Salvaged Pump Action"] = "rbxassetid://15092313032",
        ["Pink Keycard"] = "rbxassetid://15303938752",
        ["Salvaged SMG"] = "rbxassetid://15132874040",
        ["Salvaged AK47"] = "rbxassetid://14882620172",
        ["Boulder"] = "rbxassetid://15304806846",
        ["Care Package Signal"] = "rbxassetid://15132798244",
        ["Salvaged AK74u"] = "rbxassetid://15073408197",
        ["ez shovel"] = "rbxassetid://15073386763",
        ["Dynamite Stick"] = "rbxassetid://15127430886",
        ["Military Barrett"] = "rbxassetid://15346280030",
        ["Nail Gun"] = "rbxassetid://15305104734",
        ["Iron Shard Hatchet"] = "rbxassetid://15132541025",
        ["Military M4A1"] = "rbxassetid://15346201415",
        ["Wooden Spear"] = "rbxassetid://15303292373",
        ["Dynamite Bundle"] = "rbxassetid://15127431071",
        ["Stone Spear"] = "rbxassetid://15303292549",
        ["Salvaged P250"] = "rbxassetid://15305065991",
        ["Iron Shard Pickaxe"] = "rbxassetid://15132541267",
        ["Military PKM"] = "rbxassetid://15346287550",
        ["Steel Shovel"] = "rbxassetid://15132541679",
        ["Timed Charge"] = "rbxassetid://15132620220",
        ["Steel Pickaxe"] = "rbxassetid://15132541554",
        ["Lighter"] = "rbxassetid://15128007580",
        ["Blueprint"] = "rbxassetid://15132469785",
        ["Salvaged M14"] = "rbxassetid://14882876522",
        ["Machete"] = "rbxassetid://16249771824",
        ["Stone Hatchet"] = "rbxassetid://15073617325",
        ["Bandage"] = "rbxassetid://14134567329",
        ["Saw Bat"] = "rbxassetid://16249771997",
        ["Wooden Bow"] = "rbxassetid://15313266356",
        ["Military Grenade"] = "rbxassetid://15346283342",
        ["Health Pen"] = "rbxassetid://15304289469",
        ["Candy Cane"] = "rbxassetid://15132567147",
        ["Hammer"] = "rbxassetid://15318044673",
        ["Military AA12"] = "rbxassetid://15346289730",
        ["Salvaged Python"] = "rbxassetid://15188995729",
        ["Purple Keycard"] = "rbxassetid://15303938707",
        ["Bone Tool"] = "rbxassetid://15073616534",
        ["Stone Pickaxe"] = "rbxassetid://15073617163",
        ["Salvaged Skorpion"] = "rbxassetid://15369212859",
        ["Salvaged Break Action"] = "rbxassetid://15188994406"
    },
}

local function shouldShowESP(plr)
    if not espSettings.enabled then return false end
    if plr == game.Players.LocalPlayer then return false end
    if not plr.Character then return false end
    
    if espSettings.debugMode then
        local name = plr.Name
        if name:find("Rig") or name:find("Bot") then
            return true
        end
    end
    
    local char = plr.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local localHrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if hrp and localHrp and espSettings.maxDistance > 0 then
        local dist = (hrp.Position - localHrp.Position).Magnitude
        if dist > espSettings.maxDistance then
            return false
        end
    end
    
    return true
end

local function getBoundingBox(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local allBehindCamera = true
    
    local parts = {}
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(parts, part)
        end
    end
    
    if #parts == 0 then
        parts = {hrp}
    end
    
    for _, part in pairs(parts) do
        local size = part.Size
        local cf = part.CFrame
        
        local corners = {
            cf * CFrame.new(size.X/2, size.Y/2, size.Z/2),
            cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
            cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
            cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
            cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
            cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
            cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2),
            cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
        }
        
        for _, corner in pairs(corners) do
            local screenPos, onScreen = camera:WorldToViewportPoint(corner.Position)
            
            if onScreen then
                allBehindCamera = false
            end
            
            minX = math.min(minX, screenPos.X)
            minY = math.min(minY, screenPos.Y)
            maxX = math.max(maxX, screenPos.X)
            maxY = math.max(maxY, screenPos.Y)
        end
    end
    
    if allBehindCamera then
        return nil
    end
    
    local width = maxX - minX
    local height = maxY - minY
    
    return {
        x = minX,
        y = minY,
        width = width,
        height = height,
        centerX = minX + width / 2,
        centerY = minY + height / 2
    }
end

local function createESP(plr)
    local screenGui = Instance.new('ScreenGui')
    screenGui.Name = "ESP_" .. plr.Name
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.Players.LocalPlayer.PlayerGui

    local mainContainer = Instance.new('Frame')
    mainContainer.Size = UDim2.new(0, 100, 0, 100)
    mainContainer.Position = UDim2.new(0, 0, 0, 0)
    mainContainer.BackgroundTransparency = 1
    mainContainer.Visible = true
    mainContainer.ZIndex = 1
    mainContainer.Parent = screenGui
    mainContainer.ClipsDescendants = false

    espFrames[plr] = {screenGui = screenGui, container = mainContainer}
    return screenGui, mainContainer
end

local function createCorners(container)
    local cornerHolder = Instance.new('Frame')
    cornerHolder.Size = UDim2.new(1, 0, 1, 0)
    cornerHolder.BackgroundTransparency = 1
    cornerHolder.Visible = false
    cornerHolder.ZIndex = 10
    cornerHolder.Parent = container
    cornerHolder.ClipsDescendants = false

    local corners = {}
    for _,pos in pairs({{0,0}, {1,0}, {0,1}, {1,1}}) do
        local horiz = Instance.new('Frame')
        horiz.AnchorPoint = Vector2.new(pos[1], pos[2])
        horiz.Position = UDim2.new(pos[1], 0, pos[2], 0)
        horiz.Size = UDim2.new(0, espSettings.cornerLength, 0, 1)
        horiz.BorderSizePixel = 0
        horiz.ZIndex = 12
        horiz.Parent = cornerHolder
        horiz.ClipsDescendants = false

        local horizoutline = Instance.new('Frame')
        horizoutline.BackgroundColor3 = espSettings.colors.outline
        horizoutline.Size = UDim2.new(1, 2, 1, 2)
        horizoutline.Position = UDim2.new(0, -1, 0, -1)
        horizoutline.BorderSizePixel = 0
        horizoutline.ZIndex = 11
        horizoutline.Parent = horiz
        horizoutline.ClipsDescendants = false

        local vert = Instance.new('Frame')
        vert.AnchorPoint = Vector2.new(pos[1], pos[2])
        vert.Position = UDim2.new(pos[1], 0, pos[2], 0)
        vert.Size = UDim2.new(0, 1, 0, espSettings.cornerLength)
        vert.BorderSizePixel = 0
        vert.ZIndex = 12
        vert.Parent = cornerHolder
        vert.ClipsDescendants = false

        local vertoutline = Instance.new('Frame')
        vertoutline.BackgroundColor3 = espSettings.colors.outline
        vertoutline.Size = UDim2.new(1, 2, 1, 2)
        vertoutline.Position = UDim2.new(0, -1, 0, -1)
        vertoutline.BorderSizePixel = 0
        vertoutline.ZIndex = 11
        vertoutline.Parent = vert
        vertoutline.ClipsDescendants = false

        table.insert(corners, {horiz = horiz, vert = vert, horizOutline = horizoutline, vertOutline = vertoutline})
    end

    return corners, cornerHolder
end

local function updateCorners(corners, bounds)
    local cornerLength = espSettings.cornerLength
    local maxAvailable = math.min(bounds.width / 2 - espSettings.cornerGap, bounds.height / 2 - espSettings.cornerGap)
    if maxAvailable < cornerLength then
        cornerLength = math.max(1, maxAvailable)
    end
    
    for _, corner in pairs(corners) do
        corner.horiz.Size = UDim2.new(0, cornerLength, 0, 1)
        corner.vert.Size = UDim2.new(0, 1, 0, cornerLength)
        corner.horiz.BackgroundColor3 = espSettings.colors.corners
        corner.vert.BackgroundColor3 = espSettings.colors.corners
        corner.horizOutline.BackgroundColor3 = espSettings.colors.outline
        corner.vertOutline.BackgroundColor3 = espSettings.colors.outline
    end
end

local function createBox(container)
    local boxHolder = Instance.new('Frame')
    boxHolder.Size = UDim2.new(1, 0, 1, 0)
    boxHolder.BackgroundTransparency = 1
    boxHolder.Visible = false
    boxHolder.ZIndex = 10
    boxHolder.Parent = container
    boxHolder.ClipsDescendants = false

    local thickness = espSettings.boxThickness
    local boxes = {}

    local positions = {
        {pos = UDim2.new(0, 0, 0, 0), size = UDim2.new(1, 0, 0, thickness)},
        {pos = UDim2.new(1, -thickness, 0, 0), size = UDim2.new(0, thickness, 1, 0)},
        {pos = UDim2.new(0, 0, 1, -thickness), size = UDim2.new(1, 0, 0, thickness)},
        {pos = UDim2.new(0, 0, 0, 0), size = UDim2.new(0, thickness, 1, 0)}
    }

    for _, data in pairs(positions) do
        local box = Instance.new('Frame')
        box.Position = data.pos
        box.Size = data.size
        box.BorderSizePixel = 0
        box.BackgroundColor3 = espSettings.colors.boxes
        box.ZIndex = 12
        box.Parent = boxHolder
        box.ClipsDescendants = false

        local outline = Instance.new('Frame')
        outline.BackgroundColor3 = espSettings.colors.outline
        outline.Size = UDim2.new(1, 2, 1, 2)
        outline.Position = UDim2.new(0, -1, 0, -1)
        outline.BorderSizePixel = 0
        outline.ZIndex = 11
        outline.Parent = box
        outline.ClipsDescendants = false

        table.insert(boxes, {frame = box, outline = outline})
    end

    return boxes, boxHolder
end

local function updateBox(boxes)
    for _, box in pairs(boxes) do
        box.frame.BackgroundColor3 = espSettings.colors.boxes
        box.outline.BackgroundColor3 = espSettings.colors.outline
    end
end

local function createTextESP(container)
    local textHolder = Instance.new('Frame')
    textHolder.Size = UDim2.new(1, 0, 1, 0)
    textHolder.Position = UDim2.new(0, 0, 0, 0)
    textHolder.BackgroundTransparency = 1
    textHolder.Visible = true
    textHolder.ZIndex = 10
    textHolder.Parent = container
    textHolder.ClipsDescendants = false

    local textLabels = {}

    for _, textType in ipairs(espSettings.textOrder) do
        local label = Instance.new('TextLabel')
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.Font = espSettings.text.font
        label.TextSize = espSettings.text.fontSize
        label.TextScaled = false
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.ZIndex = 15
        label.Visible = false
        label.Parent = textHolder

        local imageLabel = nil
        if textType == "heldItemImage" then
            imageLabel = Instance.new('ImageLabel')
            imageLabel.Size = UDim2.new(0, 50, 0, 50)
            imageLabel.BackgroundTransparency = 1
            imageLabel.ZIndex = 15
            imageLabel.Visible = false
            imageLabel.Parent = textHolder
            imageLabel.ClipsDescendants = false
            imageLabel.ScaleType = Enum.ScaleType.Fit
        end

        textLabels[textType] = {
            label = label,
            image = imageLabel
        }
    end

    return textLabels, textHolder
end

local function updateTextESP(textLabels, plr, bounds)
    if not plr.Character then return false end

    local char = plr.Character
    local humanoid = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local localHrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    local currentY = bounds.y - espSettings.padding.text
    
    if espSettings.components.healthbars and espSettings.healthbar.position == "top" then
        currentY = currentY - espSettings.padding.healthbar - espSettings.healthbar.thickness
    end

    local visibleCount = 0
    local lineSpacing = espSettings.text.fontSize + espSettings.padding.textSpacing

    for _, textType in ipairs(espSettings.textOrder) do
        local data = textLabels[textType]
        if not data then continue end

        local shouldShow = espSettings.components[textType]
        local text = ""

        if shouldShow then
            if textType == "name" then
                text = plr.Name
                data.label.TextColor3 = espSettings.colors.name

            elseif textType == "distance" then
                if hrp and localHrp then
                    local dist = math.floor((hrp.Position - localHrp.Position).Magnitude)
                    text = string.format(espSettings.text.distanceFormat, dist)
                    data.label.TextColor3 = espSettings.colors.distance
                else
                    shouldShow = false
                end

            elseif textType == "healthText" then
                if humanoid then
                    local health = math.floor(humanoid.Health)
                    local maxHealth = math.floor(humanoid.MaxHealth)
                    text = string.format(espSettings.text.healthFormat, health, maxHealth)
                    data.label.TextColor3 = espSettings.colors.healthText
                else
                    shouldShow = false
                end

            elseif textType == "heldItem" then
                local tool = char:FindFirstChildOfClass("Model")
                if tool then
                    text = tool.Name
                    data.label.TextColor3 = espSettings.colors.heldItem
                else
                    shouldShow = false
                end

            elseif textType == "action" then
                if humanoid then
                    text = espSettings.getActionText(char, humanoid)
                    if text ~= "" then
                        data.label.TextColor3 = espSettings.colors.action
                    else
                        shouldShow = false
                    end
                else
                    shouldShow = false
                end

            elseif textType == "heldItemImage" then
                local tool = char:FindFirstChildOfClass("Model")
                if tool and data.image then
                    local imageId = espSettings.heldItemImages[tool.Name]
                    if imageId and imageId ~= "" then
                        data.image.Image = imageId
                        data.image.Position = UDim2.new(0, bounds.width / 2 - 25, 0, currentY - bounds.y - 50)
                        data.image.Visible = true
                        currentY = currentY - 50 - espSettings.padding.textSpacing
                        visibleCount = visibleCount + 1
                    else
                        if data.image then data.image.Visible = false end
                    end
                else
                    if data.image then data.image.Visible = false end
                end
            end

            if textType ~= "heldItemImage" then
                if shouldShow and text ~= "" then
                    data.label.Text = text
                    data.label.Position = UDim2.new(0, bounds.width / 2, 0, currentY - bounds.y - espSettings.text.fontSize)
                    data.label.Size = UDim2.new(0, 200, 0, espSettings.text.fontSize)
                    data.label.AnchorPoint = Vector2.new(0.5, 0)
                    data.label.Visible = true
                    currentY = currentY - lineSpacing
                    visibleCount = visibleCount + 1
                else
                    data.label.Visible = false
                end
            end
        else
            data.label.Visible = false
            if data.image then data.image.Visible = false end
        end
    end

    return visibleCount > 0
end

local function createBackground(container)
    local backgroundHolder = Instance.new('Frame')
    backgroundHolder.Size = UDim2.new(1, 0, 1, 0)
    backgroundHolder.BackgroundTransparency = espSettings.background.transparency
    backgroundHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    backgroundHolder.Visible = true
    backgroundHolder.ZIndex = 5
    backgroundHolder.BorderSizePixel = 0
    backgroundHolder.Parent = container
    backgroundHolder.ClipsDescendants = false

    local gradient = Instance.new('UIGradient')
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, espSettings.colors.backgroundTop),
        ColorSequenceKeypoint.new(1, espSettings.colors.backgroundBottom)
    }
    gradient.Parent = backgroundHolder

    return {holder = backgroundHolder, gradient = gradient}, backgroundHolder
end

local function updateBackground(backgroundData)
    backgroundData.holder.BackgroundTransparency = espSettings.background.transparency
    local currentColor = backgroundData.gradient.Color
    local newTop = espSettings.colors.backgroundTop
    local newBottom = espSettings.colors.backgroundBottom

    if currentColor.Keypoints[1].Value ~= newTop or currentColor.Keypoints[2].Value ~= newBottom then
        backgroundData.gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, newTop),
            ColorSequenceKeypoint.new(1, newBottom)
        }
    end
end

local function createHealthbar(container)
    local healthbarHolder = Instance.new('Frame')
    healthbarHolder.Size = UDim2.new(1, 0, 1, 0)
    healthbarHolder.BackgroundTransparency = 1
    healthbarHolder.Visible = false
    healthbarHolder.ZIndex = 10
    healthbarHolder.Parent = container
    healthbarHolder.ClipsDescendants = false

    local background = Instance.new('Frame')
    background.BorderSizePixel = 0
    background.BackgroundColor3 = Color3.new(0, 0, 0)
    background.ZIndex = 11
    background.Parent = healthbarHolder
    
    local outline = Instance.new('Frame')
    outline.BackgroundColor3 = Color3.new(0, 0, 0)
    outline.Size = UDim2.new(1, 2, 1, 2)
    outline.Position = UDim2.new(0, -1, 0, -1)
    outline.BorderSizePixel = 0
    outline.ZIndex = 10
    outline.Parent = background

    local healthBar = Instance.new('Frame')
    healthBar.BorderSizePixel = 0
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.ZIndex = 12
    healthBar.Parent = background

    local gradient = Instance.new('UIGradient')
    gradient.Parent = healthBar

    return {
        holder = healthbarHolder,
        background = background,
        outline = outline,
        bar = healthBar,
        gradient = gradient,
        currentHealth = 100,
        displayHealth = nil
    }, healthbarHolder
end

local function updateHealthbar(healthbarData, plr, dt, bounds)
    if not plr.Character then return end
    local humanoid = plr.Character:FindFirstChild("Humanoid")
    if not humanoid then return end

    local settings = espSettings.healthbar
    local padding = espSettings.padding.healthbar
    local maxHealth = humanoid.MaxHealth
    local currentHealth = humanoid.Health

    healthbarData.currentHealth = currentHealth

    if healthbarData.displayHealth == nil then
        healthbarData.displayHealth = currentHealth
    end

    if settings.lerpHealth then
        healthbarData.displayHealth = healthbarData.displayHealth + (currentHealth - healthbarData.displayHealth) * math.min(1, dt * settings.lerpSpeed)
    else
        healthbarData.displayHealth = currentHealth
    end

    local healthPercent = math.clamp(healthbarData.displayHealth / maxHealth, 0, 1)

    if settings.useGradient then
        healthbarData.gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 165, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }
        healthbarData.gradient.Enabled = true
    else
        healthbarData.gradient.Enabled = false
        if healthPercent > 0.5 then
            local t = (healthPercent - 0.5) * 2
            healthbarData.bar.BackgroundColor3 = Color3.fromRGB(255 * (1 - t), 255, 0)
        else
            local t = healthPercent * 2
            healthbarData.bar.BackgroundColor3 = Color3.fromRGB(255, 255 * t, 0)
        end
    end

    local thickness = settings.thickness

    if settings.position == "top" then
        healthbarData.background.Position = UDim2.new(0, 0, 0, -padding - thickness)
        healthbarData.background.Size = UDim2.new(0, bounds.width, 0, thickness)
        healthbarData.background.AnchorPoint = Vector2.new(0, 1)

        healthbarData.bar.Position = UDim2.new(0, 1, 0, 1)
        healthbarData.bar.Size = UDim2.new(healthPercent, -2, 1, -2)
        healthbarData.bar.AnchorPoint = Vector2.new(0, 0)

        healthbarData.gradient.Rotation = 0

    elseif settings.position == "bottom" then
        healthbarData.background.Position = UDim2.new(0, 0, 0, bounds.height + padding)
        healthbarData.background.Size = UDim2.new(0, bounds.width, 0, thickness)
        healthbarData.background.AnchorPoint = Vector2.new(0, 0)

        healthbarData.bar.Position = UDim2.new(0, 1, 0, 1)
        healthbarData.bar.Size = UDim2.new(healthPercent, -2, 1, -2)
        healthbarData.bar.AnchorPoint = Vector2.new(0, 0)

        healthbarData.gradient.Rotation = 0

    elseif settings.position == "left" then
        healthbarData.background.Position = UDim2.new(0, -padding, 0, 0)
        healthbarData.background.Size = UDim2.new(0, thickness, 0, bounds.height)
        healthbarData.background.AnchorPoint = Vector2.new(1, 0)
        
        healthbarData.bar.Position = UDim2.new(0, 1, 1, -1)
        healthbarData.bar.Size = UDim2.new(1, -2, healthPercent, -2)
        healthbarData.bar.AnchorPoint = Vector2.new(0, 1)
        
        healthbarData.gradient.Rotation = 90
        
    elseif settings.position == "right" then
        healthbarData.background.Position = UDim2.new(0, bounds.width + padding, 0, 0)
        healthbarData.background.Size = UDim2.new(0, thickness, 0, bounds.height)
        healthbarData.background.AnchorPoint = Vector2.new(0, 0)
        
        healthbarData.bar.Position = UDim2.new(0, 1, 1, -1)
        healthbarData.bar.Size = UDim2.new(1, -2, healthPercent, -2)
        healthbarData.bar.AnchorPoint = Vector2.new(0, 1)
        
        healthbarData.gradient.Rotation = 90
    end
end

local function initializePlayer(plr)
    if plr == game.Players.LocalPlayer then return end
    if not plr.Character then return end
    
    if espSettings.debugMode then
        local name = plr.Name
        if not (name:find("Rig") or name:find("Bot")) then
            if not game.Players:FindFirstChild(plr.Name) then
                return
            end
        end
    else
        if not game.Players:FindFirstChild(plr.Name) then
            return
        end
    end

    local screenGui, container = createESP(plr)

    local cornerData, cornerHolder = createCorners(container)
    espComponents.corners[plr] = cornerData
    espComponents.cornerHolders[plr] = cornerHolder

    local boxData, boxHolder = createBox(container)
    espComponents.boxes[plr] = boxData
    espComponents.boxHolders[plr] = boxHolder

    local healthbarData, healthbarHolder = createHealthbar(container)
    espComponents.healthbars[plr] = healthbarData
    espComponents.healthbarHolders[plr] = healthbarHolder

    local textLabels, textHolder = createTextESP(container)
    espComponents.textLabels[plr] = textLabels
    espComponents.textHolders[plr] = textHolder

    local backgroundData, backgroundHolder = createBackground(container)
    espComponents.backgrounds[plr] = backgroundData
    espComponents.backgroundHolders[plr] = backgroundHolder
end

local function cleanupPlayer(plr)
    if espFrames[plr] then
        espFrames[plr].screenGui:Destroy()
        espFrames[plr] = nil
    end

    for componentType, data in pairs(espComponents) do
        data[plr] = nil
    end
end

for _, plr in pairs(game.Players:GetPlayers()) do
    if plr.Character then
        initializePlayer(plr)
    end
    plr.CharacterAdded:Connect(function()
        wait(0.1)
        initializePlayer(plr)
    end)
end

if espSettings.debugMode then
    for _, model in pairs(workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") then
            local name = model.Name
            if name:find("Rig") or name:find("Bot") then
                local pseudoPlayer = {
                    Name = name,
                    Character = model
                }
                initializePlayer(pseudoPlayer)
            end
        end
    end
    
    workspace.ChildAdded:Connect(function(model)
        if model:IsA("Model") and model:FindFirstChild("Humanoid") then
            local name = model.Name
            if name:find("Rig") or name:find("Bot") then
                wait(0.1)
                local pseudoPlayer = {
                    Name = name,
                    Character = model
                }
                initializePlayer(pseudoPlayer)
            end
        end
    end)
end

game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        wait(0.1)
        initializePlayer(plr)
    end)
end)

game.Players.PlayerRemoving:Connect(function(plr)
    cleanupPlayer(plr)
end)

local lastFrameTime = tick()
runservice.RenderStepped:Connect(function()
    local currentTime = tick()
    local dt = currentTime - lastFrameTime
    lastFrameTime = currentTime

    for plr, espData in pairs(espFrames) do
        if not shouldShowESP(plr) then
            espData.container.Visible = false
            continue
        end

        local bounds = getBoundingBox(plr.Character)
        if not bounds then
            espData.container.Visible = false
            continue
        end

        espData.container.Position = UDim2.new(0, bounds.x, 0, bounds.y)
        espData.container.Size = UDim2.new(0, bounds.width, 0, bounds.height)
        espData.container.Visible = true

        if espSettings.components.background and espComponents.backgrounds[plr] and espComponents.backgroundHolders[plr] then
            espComponents.backgroundHolders[plr].Visible = true
            updateBackground(espComponents.backgrounds[plr])
        elseif espComponents.backgroundHolders[plr] then
            espComponents.backgroundHolders[plr].Visible = false
        end

        if espSettings.components.corners and espComponents.corners[plr] and espComponents.cornerHolders[plr] then
            espComponents.cornerHolders[plr].Visible = true
            updateCorners(espComponents.corners[plr], bounds)
        elseif espComponents.cornerHolders[plr] then
            espComponents.cornerHolders[plr].Visible = false
        end

        if espSettings.components.boxes and espComponents.boxes[plr] and espComponents.boxHolders[plr] then
            espComponents.boxHolders[plr].Visible = true
            updateBox(espComponents.boxes[plr])
        elseif espComponents.boxHolders[plr] then
            espComponents.boxHolders[plr].Visible = false
        end

        if espSettings.components.healthbars and espComponents.healthbars[plr] and espComponents.healthbarHolders[plr] then
            espComponents.healthbarHolders[plr].Visible = true
            updateHealthbar(espComponents.healthbars[plr], plr, dt, bounds)
        elseif espComponents.healthbarHolders[plr] then
            espComponents.healthbarHolders[plr].Visible = false
        end

        if espComponents.textLabels[plr] and espComponents.textHolders[plr] then
            updateTextESP(espComponents.textLabels[plr], plr, bounds)
        end
    end
end)

local visuals = getgenv().window:addMenu({text = "Visuals"})
--
local playerESP = visuals:addSection({
    text = "Player ESP",
    side = "left",
    showMinButton = true,
})
--
do
    local enabledtoggle = true
    local configbackup = deepCopy(espSettings.components)
    local Enabled = playerESP:addToggle({
        text = "Enabled",
        state = true,
    })
    Enabled:bindToEvent('onToggle', function(val)
        enabledtoggle = val
        if val == false then
            configbackup = deepCopy(espSettings.components)
            for i,v in pairs(espSettings.components) do
                espSettings.components[i] = false
            end
        elseif val == true then
            for i,v in pairs(configbackup) do
                espSettings.components[i] = v
            end
        end
    end)

    local boxreal = false
    local cornerreal = false

    local Box = playerESP:addToggle({
        text = "Player Box",
        state = false,
    })
    Box:bindToEvent('onToggle', function(val)
        boxreal = val
        if enabledtoggle then
            if cornerreal == true and val == true then
                espSettings.components.boxes = false
                espSettings.components.corners = true
            elseif cornerreal == false and val == true then
                espSettings.components.boxes = true
            elseif cornerreal == true and val == false then
                espSettings.components.corners = true
                espSettings.components.boxes = false
            elseif cornerreal == false and val == false then
                espSettings.components.boxes = false
                espSettings.components.corners = false
            end
        else
            if cornerreal == true and val == true then
                configbackup.boxes = false
                configbackup.corners = true
            elseif cornerreal == false and val == true then
                configbackup.boxes = true
            elseif cornerreal == true and val == false then
                configbackup.corners = true
                configbackup.boxes = false
            elseif cornerreal == false and val == false then
                configbackup.boxes = false
                configbackup.corners = false
            end
        end
    end)

    local Corner = playerESP:addToggle({
        text = "Corners Only",
        state = false,
    })
    Corner:bindToEvent('onToggle', function(val)
        cornerreal = val
        if enabledtoggle then
            if boxreal == true and val == true then
                espSettings.components.boxes = false
                espSettings.components.corners = true
            elseif boxreal == false and val == true then
                espSettings.components.corners = true
            elseif boxreal == true and val == false then
                espSettings.components.corners = false
                espSettings.components.boxes = true
            elseif boxreal == false and val == false then
                espSettings.components.boxes = false
                espSettings.components.corners = false
            end
        else
            if boxreal == true and val == true then
                configbackup.boxes = false
                configbackup.corners = true
            elseif boxreal == false and val == true then
                configbackup.corners = true
            elseif boxreal == true and val == false then
                configbackup.corners = false
                configbackup.boxes = true
            elseif boxreal == false and val == false then
                configbackup.boxes = false
                configbackup.corners = false
            end
        end
    end)

    local Name = playerESP:addToggle({
        text = "Name",
        state = false,
    })
    Name:bindToEvent('onToggle', function(val)
        if enabledtoggle then
            espSettings.components.name = val
        else
            configbackup.name = val
        end
    end)

    local Distance = playerESP:addToggle({
        text = "Distance",
        state = false,
    })
    Distance:bindToEvent('onToggle', function(val)
        if enabledtoggle then
            espSettings.components.distance = val
        else
            configbackup.distance = val
        end
    end)

    local Health = playerESP:addToggle({
        text = "Health",
        state = false,
    })
    Health:bindToEvent('onToggle', function(val)
        if enabledtoggle then
            espSettings.components.healthText = val
        else
            configbackup.healthText = val
        end
    end)

    local Weapon = playerESP:addToggle({
        text = "Weapon",
        state = false,
    })
    Weapon:bindToEvent('onToggle', function(val)
        if enabledtoggle then
            espSettings.components.heldItem = val
        else
            configbackup.heldItem = val
        end
    end)

    local WeaponImage = playerESP:addToggle({
        text = "Weapon Image",
        state = false,
    })
    WeaponImage:bindToEvent('onToggle', function(val)
        if enabledtoggle then
            espSettings.components.heldItemImage = val
        else
            configbackup.heldItemImage = val
        end
    end)

    local Action = playerESP:addToggle({
        text = "Action",
        state = false,
    })
    Action:bindToEvent('onToggle', function(val)
        if enabledtoggle then
            espSettings.components.action = val
        else
            configbackup.action = val
        end
    end)

    local Healthbar = playerESP:addToggle({
        text = "Healthbar",
        state = false,
    })
    Healthbar:bindToEvent('onToggle', function(val)
        if enabledtoggle then
            espSettings.components.healthbars = val
        else
            configbackup.healthbars = val
        end
    end)

    local Background = playerESP:addToggle({
        text = "Background",
        state = false,
    })
    Background:bindToEvent('onToggle', function(val)
        if enabledtoggle then
            espSettings.components.background = val
        else
            configbackup.background = val
        end
    end)
end
--
local playerESPColors = visuals:addSection({
    text = "Player ESP Colors",
    side = "right",
    showMinButton = true,
})
--
do
    playerESPColors:addColorPicker({
        text = 'Player Box',
        color = Color3.fromRGB(255, 255, 255)
    }, function(val)
        espSettings.colors.corners = val
        espSettings.colors.boxes = val
    end)

    playerESPColors:addColorPicker({
        text = 'Player ESP Outlines',
        color = Color3.fromRGB(0, 0, 0)
    }, function(val)
        espSettings.colors.outline = val
    end)

    playerESPColors:addColorPicker({
        text = 'Player Name',
        color = Color3.fromRGB(255, 255, 255)
    }, function(val)
        espSettings.colors.name = val
    end)

    playerESPColors:addColorPicker({
        text = 'Player Distance',
        color = Color3.fromRGB(255, 255, 255)
    }, function(val)
        espSettings.colors.distance = val
    end)

    playerESPColors:addColorPicker({
        text = 'Player Health',
        color = Color3.fromRGB(255, 255, 255)
    }, function(val)
        espSettings.colors.healthText = val
    end)

    playerESPColors:addColorPicker({
        text = 'Player Weapon',
        color = Color3.fromRGB(255, 255, 255)
    }, function(val)
        espSettings.colors.heldItem = val
    end)

    playerESPColors:addColorPicker({
        text = 'Player Action',
        color = Color3.fromRGB(255, 255, 255)
    }, function(val)
        espSettings.colors.action = val
    end)

    playerESPColors:addColorPicker({
        text = 'Player Healthbar Full',
        color = Color3.fromRGB(0, 255, 0)
    }, function(val)
        espSettings.colors.healthbarFull = val
    end)

    playerESPColors:addColorPicker({
        text = 'Player Healthbar Empty',
        color = Color3.fromRGB(255, 0, 0)
    }, function(val)
        espSettings.colors.healthbarEmpty = val
    end)

    playerESPColors:addColorPicker({
        text = 'Player Healthbar Empty',
        color = Color3.fromRGB(255, 0, 0)
    }, function(val)
        espSettings.colors.healthbarEmpty = val
    end)

    playerESPColors:addColorPicker({
        text = 'Player Background 1',
        color = Color3.fromRGB(0, 0, 0)
    }, function(val)
        espSettings.colors.backgroundTop = val
    end)

    playerESPColors:addColorPicker({
        text = 'Player Background 2',
        color = Color3.fromRGB(0, 0, 0)
    }, function(val)
        espSettings.colors.backgroundBottom = val
    end)
end

getgenv().VisualsTabCreated = true -- allow other script to continue
