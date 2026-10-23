local function getService(name)
    local service = game:GetService(name)
    return if cloneref then cloneref(service) else service
end

local CoreGui = getService("CoreGui")
local TweenService = getService("TweenService")
local UserInputService = getService("UserInputService")
local Players = getService("Players")
local RunService = getService("RunService")

local LocalPlayer = Players.LocalPlayer

local Theme = {
    Background     = Color3.fromRGB(214, 210, 194),
    Sidebar        = Color3.fromRGB(196, 192, 176),
    TopBar         = Color3.fromRGB(38, 38, 34),
    Border         = Color3.fromRGB(50, 49, 44),
    BorderLight    = Color3.fromRGB(165, 161, 146),
    ElementBg      = Color3.fromRGB(188, 184, 168),
    ElementHover   = Color3.fromRGB(174, 170, 154),
    ElementActive  = Color3.fromRGB(42, 42, 38),
    Text           = Color3.fromRGB(40, 40, 36),
    TextLight      = Color3.fromRGB(240, 238, 230),
    TextMuted      = Color3.fromRGB(125, 122, 110),
    Font           = Enum.Font.Code
}

-- ─────────────────────────────────────────────────────────────
-- Private module state (module-scoped upvalues, unreachable
-- via getgenv / _G / getrenv without walking this closure).
-- ─────────────────────────────────────────────────────────────
local _activeWindow = nil

local function callSafely(func, ...)
    if type(func) == "function" then
        local success, result = pcall(func, ...)
        if not success then
            warn("[lib] Execution Error: ", result)
            return false
        end
        return result
    end
end

local function GetSafeContainer()
    local success, result = pcall(function()
        if gethui then return gethui() end
        return CoreGui
    end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local Library = {}
Library.__index = Library

function Library.CreateWindow(title)
    -- Tear down previous instance via the private singleton ref.
    if _activeWindow then
        pcall(function() _activeWindow:Destroy() end)
        _activeWindow = nil
    end

    local window = {
        Connections = {}
    }

    -- Internal-only state, never attached to `window`.
    local tabs = {}
    local activeTab = nil

    local function TrackConnection(conn)
        table.insert(window.Connections, conn)
        return conn
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "_" .. tostring(math.random(100000, 999999))
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = GetSafeContainer()

    if protectgui then
        callSafely(protectgui, screenGui)
    elseif syn and syn.protect_gui then
        callSafely(syn.protect_gui, screenGui)
    end

    -- ── Main Container ────────────────────────────────────────
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "_a"
    mainFrame.Size = UDim2.new(0, 640, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -320, 0.5, -200)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.ClipsDescendants = false
    mainFrame.Parent = screenGui

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Border
    stroke.Thickness = 2
    stroke.Parent = mainFrame

    local outerLine = Instance.new("UIStroke")
    outerLine.Color = Theme.BorderLight
    outerLine.Thickness = 1
    outerLine.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    outerLine.Parent = mainFrame

    -- ── Header / Top Bar ─────────────────────────────────────
    local topBar = Instance.new("Frame")
    topBar.Name = "_b"
    topBar.Size = UDim2.new(1, 0, 0, 32)
    topBar.BackgroundColor3 = Theme.TopBar
    topBar.BorderSizePixel = 0
    topBar.Active = true
    topBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "◆ " .. string.upper(title or "SYSTEM // YoRHa PROTOCOL")
    titleLabel.TextColor3 = Theme.TextLight
    titleLabel.TextSize = 13
    titleLabel.Font = Theme.Font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    minimizeBtn.Position = UDim2.new(1, -32, 0, 0)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Theme.TextLight
    minimizeBtn.TextSize = 14
    minimizeBtn.Font = Theme.Font
    minimizeBtn.Parent = topBar

    -- ── Minimized HUD Square ─────────────────────────────────
    local minimizedIcon = Instance.new("Frame")
    minimizedIcon.Name = "_c"
    minimizedIcon.Size = UDim2.new(0, 42, 0, 42)
    minimizedIcon.Position = UDim2.new(0.5, -21, 0, 25)
    minimizedIcon.BackgroundColor3 = Theme.TopBar
    minimizedIcon.BorderSizePixel = 0
    minimizedIcon.Visible = false
    minimizedIcon.Active = true
    minimizedIcon.Parent = screenGui

    local minStroke = Instance.new("UIStroke")
    minStroke.Color = Theme.Border
    minStroke.Thickness = 2
    minStroke.Parent = minimizedIcon

    local maximizeLabel = Instance.new("TextLabel")
    maximizeLabel.Size = UDim2.new(1, 0, 1, 0)
    maximizeLabel.BackgroundTransparency = 1
    maximizeLabel.Text = "◆"
    maximizeLabel.TextColor3 = Theme.TextLight
    maximizeLabel.TextSize = 20
    maximizeLabel.Font = Theme.Font
    maximizeLabel.Parent = minimizedIcon

    -- ── Sidebar ──────────────────────────────────────────────
    local sidebar = Instance.new("Frame")
    sidebar.Name = "_d"
    sidebar.Size = UDim2.new(0, 185, 1, -32)
    sidebar.Position = UDim2.new(0, 0, 0, 32)
    sidebar.BackgroundColor3 = Theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame

    local sideDivider = Instance.new("Frame")
    sideDivider.Size = UDim2.new(0, 2, 1, -32)
    sideDivider.Position = UDim2.new(0, 185, 0, 32)
    sideDivider.BackgroundColor3 = Theme.BorderLight
    sideDivider.BorderSizePixel = 0
    sideDivider.Parent = mainFrame

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 4)
    tabListLayout.Parent = sidebar

    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 8)
    tabPadding.PaddingLeft = UDim.new(0, 8)
    tabPadding.PaddingRight = UDim.new(0, 8)
    tabPadding.Parent = sidebar

    -- ── Content Area ─────────────────────────────────────────
    local contentArea = Instance.new("Frame")
    contentArea.Name = "_e"
    contentArea.Size = UDim2.new(1, -195, 1, -32)
    contentArea.Position = UDim2.new(0, 191, 0, 32)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    -- ── Notifications ────────────────────────────────────────
    local notifContainer = Instance.new("Frame")
    notifContainer.Name = "_f"
    notifContainer.Size = UDim2.new(0, 280, 1, -20)
    notifContainer.Position = UDim2.new(1, -290, 0, 10)
    notifContainer.BackgroundTransparency = 1
    notifContainer.Parent = screenGui

    local notifLayout = Instance.new("UIListLayout")
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.Padding = UDim.new(0, 8)
    notifLayout.Parent = notifContainer

    -- ── Dragging ─────────────────────────────────────────────
    local function MakeDraggable(frame, handle, clickCb)
        local dragging = false
        local dragStart = Vector3.zero
        local startPos = UDim2.new()
        local clickOrigin = Vector3.zero

        TrackConnection(handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                clickOrigin = input.Position
                startPos = frame.Position
            end
        end))

        TrackConnection(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end))

        TrackConnection(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    if clickCb and (input.Position - clickOrigin).Magnitude < 6 then
                        clickCb()
                    end
                end
            end
        end))
    end

    MakeDraggable(mainFrame, topBar)
    MakeDraggable(minimizedIcon, minimizedIcon, function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    TrackConnection(minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        minimizedIcon.Visible = true
    end))

    -- ── Notify ───────────────────────────────────────────────
    function window:Notify(config)
        local nTitle    = config.Title or "POD 042 // NOTICE"
        local nContent  = config.Content or config.Text or ""
        local nDuration = config.Duration or 3.5

        local notifBox = Instance.new("Frame")
        notifBox.Size = UDim2.new(1, 0, 0, 0)
        notifBox.BackgroundColor3 = Theme.TopBar
        notifBox.BorderSizePixel = 0
        notifBox.ClipsDescendants = true
        notifBox.Parent = notifContainer

        local notifStroke = Instance.new("UIStroke")
        notifStroke.Color = Theme.BorderLight
        notifStroke.Thickness = 1
        notifStroke.Parent = notifBox

        local nTLabel = Instance.new("TextLabel")
        nTLabel.Size = UDim2.new(1, -16, 0, 20)
        nTLabel.Position = UDim2.new(0, 10, 0, 6)
        nTLabel.BackgroundTransparency = 1
        nTLabel.Text = "◆ " .. string.upper(nTitle)
        nTLabel.TextColor3 = Theme.TextLight
        nTLabel.Font = Theme.Font
        nTLabel.TextSize = 12
        nTLabel.TextXAlignment = Enum.TextXAlignment.Left
        nTLabel.Parent = notifBox

        local nDLabel = Instance.new("TextLabel")
        nDLabel.Size = UDim2.new(1, -16, 0, 36)
        nDLabel.Position = UDim2.new(0, 10, 0, 26)
        nDLabel.BackgroundTransparency = 1
        nDLabel.Text = nContent
        nDLabel.TextColor3 = Theme.TextLight
        nDLabel.Font = Theme.Font
        nDLabel.TextSize = 11
        nDLabel.TextWrapped = true
        nDLabel.TextXAlignment = Enum.TextXAlignment.Left
        nDLabel.TextYAlignment = Enum.TextYAlignment.Top
        nDLabel.Parent = notifBox

        TweenService:Create(notifBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 68)
        }):Play()

        task.delay(nDuration, function()
            local closeTween = TweenService:Create(notifBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(1, 0, 0, 0)
            })
            closeTween:Play()
            closeTween.Completed:Connect(function()
                notifBox:Destroy()
            end)
        end)
    end

    -- ── CreateTab ────────────────────────────────────────────
    -- Methods live in a closure-private table reached through
    -- the tab's __index metatable; they are not reachable via
    -- `pairs(tab)` / `for k,v in next, tab` from outside.
    function window:CreateTab(tabName)
        local methods = {}
        local tab = setmetatable({}, { __index = methods })

        local ordinal = #tabs + 1

        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "_t" .. tostring(ordinal)
        tabBtn.Size = UDim2.new(1, 0, 0, 30)
        tabBtn.BackgroundColor3 = Theme.Sidebar
        tabBtn.BorderSizePixel = 0
        tabBtn.AutoButtonColor = false
        tabBtn.Text = ""
        tabBtn.Parent = sidebar

        local activeIndicator = Instance.new("Frame")
        activeIndicator.Size = UDim2.new(0, 3, 1, 0)
        activeIndicator.Position = UDim2.new(0, 0, 0, 0)
        activeIndicator.BackgroundColor3 = Theme.Border
        activeIndicator.BorderSizePixel = 0
        activeIndicator.Visible = false
        activeIndicator.Parent = tabBtn

        local squareIcon = Instance.new("Frame")
        squareIcon.Size = UDim2.new(0, 8, 0, 8)
        squareIcon.Position = UDim2.new(0, 12, 0.5, -4)
        squareIcon.BackgroundColor3 = Theme.Border
        squareIcon.BorderSizePixel = 0
        squareIcon.Parent = tabBtn

        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, -30, 1, 0)
        tabLabel.Position = UDim2.new(0, 28, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = string.upper(tabName)
        tabLabel.TextColor3 = Theme.Text
        tabLabel.TextSize = 13
        tabLabel.Font = Theme.Font
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabBtn

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = "_c" .. tostring(ordinal)
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.Visible = false
        tabContent.ScrollBarThickness = 3
        tabContent.ScrollBarImageColor3 = Theme.Border
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Parent = contentArea

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.Parent = tabContent

        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingTop = UDim.new(0, 10)
        contentPadding.PaddingBottom = UDim.new(0, 14)
        contentPadding.PaddingLeft = UDim.new(0, 10)
        contentPadding.PaddingRight = UDim.new(0, 14)
        contentPadding.Parent = tabContent

        local function Activate()
            for _, t in ipairs(tabs) do
                t.Indicator.Visible = false
                t.Button.BackgroundColor3 = Theme.Sidebar
                t.Icon.BackgroundColor3 = Theme.Border
                t.Label.TextColor3 = Theme.Text
                t.Content.Visible = false
            end
            activeIndicator.Visible = true
            tabBtn.BackgroundColor3 = Theme.TopBar
            squareIcon.BackgroundColor3 = Theme.TextLight
            tabLabel.TextColor3 = Theme.TextLight
            tabContent.Visible = true
            activeTab = tab
        end

        TrackConnection(tabBtn.MouseEnter:Connect(function()
            if activeTab ~= tab then
                TweenService:Create(tabBtn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.ElementHover}):Play()
            end
        end))

        TrackConnection(tabBtn.MouseLeave:Connect(function()
            if activeTab ~= tab then
                TweenService:Create(tabBtn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Sidebar}):Play()
            end
        end))

        TrackConnection(tabBtn.MouseButton1Click:Connect(Activate))

        local tabData = {
            Button = tabBtn,
            Indicator = activeIndicator,
            Icon = squareIcon,
            Label = tabLabel,
            Content = tabContent
        }
        table.insert(tabs, tabData)

        if #tabs == 1 then
            Activate()
        end

        -- ── Component 1: Section Title ───────────────────────
        function methods.CreateSection(_, text)
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(1, 0, 0, 24)
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.Parent = tabContent

            local secLabel = Instance.new("TextLabel")
            secLabel.Size = UDim2.new(1, 0, 1, 0)
            secLabel.BackgroundTransparency = 1
            secLabel.Text = "// " .. string.upper(text)
            secLabel.TextColor3 = Theme.TextMuted
            secLabel.TextSize = 11
            secLabel.Font = Theme.Font
            secLabel.TextXAlignment = Enum.TextXAlignment.Left
            secLabel.Parent = sectionFrame

            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, 1, -1)
            line.BackgroundColor3 = Theme.BorderLight
            line.BorderSizePixel = 0
            line.Parent = sectionFrame
        end

        -- ── Component 2: Button ──────────────────────────────
        function methods.CreateButton(_, text, callback)
            if type(text) == "table" then
                callback = text.Callback
                text = text.Name or text.Title or "Button"
            end
            callback = callback or function() end

            local btnFrame = Instance.new("Frame")
            btnFrame.Size = UDim2.new(1, 0, 0, 32)
            btnFrame.BackgroundColor3 = Theme.ElementBg
            btnFrame.BorderSizePixel = 0
            btnFrame.Parent = tabContent

            local strokeMarker = Instance.new("Frame")
            strokeMarker.Size = UDim2.new(0, 2, 1, 0)
            strokeMarker.BackgroundColor3 = Theme.Border
            strokeMarker.BorderSizePixel = 0
            strokeMarker.Visible = false
            strokeMarker.Parent = btnFrame

            local square = Instance.new("Frame")
            square.Size = UDim2.new(0, 6, 0, 6)
            square.Position = UDim2.new(0, 10, 0.5, -3)
            square.BackgroundColor3 = Theme.Border
            square.BorderSizePixel = 0
            square.Parent = btnFrame

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -26, 1, 0)
            btn.Position = UDim2.new(0, 26, 0, 0)
            btn.BackgroundTransparency = 1
            btn.Text = text
            btn.TextColor3 = Theme.Text
            btn.TextSize = 13
            btn.Font = Theme.Font
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = btnFrame

            TrackConnection(btn.MouseEnter:Connect(function()
                strokeMarker.Visible = true
                TweenService:Create(btnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementHover}):Play()
            end))

            TrackConnection(btn.MouseLeave:Connect(function()
                strokeMarker.Visible = false
                TweenService:Create(btnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementBg}):Play()
            end))

            TrackConnection(btn.MouseButton1Click:Connect(function()
                TweenService:Create(btnFrame, TweenInfo.new(0.06), {BackgroundColor3 = Theme.TopBar}):Play()
                square.BackgroundColor3 = Theme.TextLight
                btn.TextColor3 = Theme.TextLight
                task.wait(0.08)
                TweenService:Create(btnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementHover}):Play()
                square.BackgroundColor3 = Theme.Border
                btn.TextColor3 = Theme.Text
                callSafely(callback)
            end))

            local btnObj = {}
            function btnObj:Set(newText) btn.Text = newText end
            return btnObj
        end

        -- ── Component 3: Toggle ──────────────────────────────
        function methods.CreateToggle(_, text, default, callback)
            if type(text) == "table" then
                callback = text.Callback
                default = text.CurrentValue or text.Default
                text = text.Name or text.Title or "Toggle"
            end
            callback = callback or function() end
            local state = default or false

            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 32)
            toggleFrame.BackgroundColor3 = Theme.ElementBg
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = tabContent

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Theme.Text
            label.TextSize = 13
            label.Font = Theme.Font
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = toggleFrame

            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 18, 0, 18)
            box.Position = UDim2.new(1, -28, 0.5, -9)
            box.BackgroundColor3 = Theme.ElementBg
            box.BorderSizePixel = 0
            box.Parent = toggleFrame

            local boxStroke = Instance.new("UIStroke")
            boxStroke.Color = Theme.Border
            boxStroke.Thickness = 1.5
            boxStroke.Parent = box

            local indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0, 10, 0, 10)
            indicator.Position = UDim2.new(0.5, -5, 0.5, -5)
            indicator.BackgroundColor3 = Theme.Border
            indicator.BorderSizePixel = 0
            indicator.BackgroundTransparency = state and 0 or 1
            indicator.Parent = box

            local clickArea = Instance.new("TextButton")
            clickArea.Size = UDim2.new(1, 0, 1, 0)
            clickArea.BackgroundTransparency = 1
            clickArea.Text = ""
            clickArea.Parent = toggleFrame

            local function UpdateState(val)
                state = val
                TweenService:Create(indicator, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
                    BackgroundTransparency = state and 0 or 1
                }):Play()
                callSafely(callback, state)
            end

            TrackConnection(clickArea.MouseButton1Click:Connect(function()
                UpdateState(not state)
            end))

            local toggleObj = {}
            function toggleObj:Set(val) UpdateState(val) end
            function toggleObj:Get() return state end
            return toggleObj
        end

        -- ── Component 4: Slider ──────────────────────────────
        function methods.CreateSlider(_, text, min, max, default, callback, step)
            if type(text) == "table" then
                local config = text
                text     = config.Name or config.Title or "Slider"
                min      = config.Range and config.Range[1] or config.Min or 0
                max      = config.Range and config.Range[2] or config.Max or 100
                default  = config.CurrentValue or config.Default or min
                callback = config.Callback or function() end
                step     = config.Increment or config.Step or 1
            else
                callback = callback or function() end
                min = min or 0
                max = max or 100
                default = default or min
                step = step or 1
            end

            default = math.clamp(default, min, max)

            local function getPrecision(s)
                local str = tostring(s)
                local dec = string.match(str, "%.(%d+)")
                return dec and #dec or 0
            end
            local precision = getPrecision(step)

            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 42)
            sliderFrame.BackgroundColor3 = Theme.ElementBg
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = tabContent

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -70, 0, 20)
            label.Position = UDim2.new(0, 12, 0, 3)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Theme.Text
            label.TextSize = 13
            label.Font = Theme.Font
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = sliderFrame

            local valBox = Instance.new("TextLabel")
            valBox.Size = UDim2.new(0, 50, 0, 16)
            valBox.Position = UDim2.new(1, -58, 0, 5)
            valBox.BackgroundColor3 = Theme.TopBar
            valBox.BorderSizePixel = 0
            valBox.Text = string.format("%." .. precision .. "f", default)
            valBox.TextColor3 = Theme.TextLight
            valBox.TextSize = 11
            valBox.Font = Theme.Font
            valBox.Parent = sliderFrame

            local trackBar = Instance.new("Frame")
            trackBar.Size = UDim2.new(1, -24, 0, 4)
            trackBar.Position = UDim2.new(0, 12, 0, 28)
            trackBar.BackgroundColor3 = Theme.BorderLight
            trackBar.BorderSizePixel = 0
            trackBar.Parent = sliderFrame

            local fillBar = Instance.new("Frame")
            fillBar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fillBar.BackgroundColor3 = Theme.Border
            fillBar.BorderSizePixel = 0
            fillBar.Parent = trackBar

            local handle = Instance.new("Frame")
            handle.Size = UDim2.new(0, 6, 0, 12)
            handle.AnchorPoint = Vector2.new(0.5, 0.5)
            handle.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
            handle.BackgroundColor3 = Theme.TopBar
            handle.BorderSizePixel = 0
            handle.Parent = trackBar

            local sliding = false

            local function SetValue(value)
                value = math.clamp(value, min, max)
                if step > 0 then
                    value = math.floor((value - min) / step + 0.5) * step + min
                    value = tonumber(string.format("%." .. precision .. "f", value))
                end

                local percent = (value - min) / (max - min)
                valBox.Text = string.format("%." .. precision .. "f", value)

                TweenService:Create(fillBar, TweenInfo.new(0.05), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                TweenService:Create(handle, TweenInfo.new(0.05), {Position = UDim2.new(percent, 0, 0.5, 0)}):Play()

                callSafely(callback, value)
            end

            local function UpdateInput(input)
                local pos = math.clamp((input.Position.X - trackBar.AbsolutePosition.X) / trackBar.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * pos
                SetValue(val)
            end

            TrackConnection(trackBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    UpdateInput(input)
                end
            end))

            TrackConnection(UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end))

            TrackConnection(UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateInput(input)
                end
            end))

            local sliderObj = {}
            function sliderObj:Set(v) SetValue(v) end
            function sliderObj:Get() return tonumber(valBox.Text) end
            return sliderObj
        end

        -- ── Component 5: Keybind ─────────────────────────────
        function methods.CreateKeybind(_, text, defaultKey, callback)
            if type(text) == "table" then
                callback = text.Callback
                defaultKey = text.CurrentKeybind or text.Default
                text = text.Name or text.Title or "Keybind"
            end
            callback = callback or function() end
            local currentKey = defaultKey or Enum.KeyCode.E
            local isBinding = false

            local keyFrame = Instance.new("Frame")
            keyFrame.Size = UDim2.new(1, 0, 0, 32)
            keyFrame.BackgroundColor3 = Theme.ElementBg
            keyFrame.BorderSizePixel = 0
            keyFrame.Parent = tabContent

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -110, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Theme.Text
            label.TextSize = 13
            label.Font = Theme.Font
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = keyFrame

            local keyDisplay = Instance.new("TextLabel")
            keyDisplay.Size = UDim2.new(0, 90, 0, 20)
            keyDisplay.Position = UDim2.new(1, -98, 0.5, -10)
            keyDisplay.BackgroundColor3 = Theme.TopBar
            keyDisplay.BorderSizePixel = 0
            keyDisplay.Text = "[" .. currentKey.Name .. "]"
            keyDisplay.TextColor3 = Theme.TextLight
            keyDisplay.TextSize = 11
            keyDisplay.Font = Theme.Font
            keyDisplay.Parent = keyFrame

            local clickArea = Instance.new("TextButton")
            clickArea.Size = UDim2.new(1, 0, 1, 0)
            clickArea.BackgroundTransparency = 1
            clickArea.Text = ""
            clickArea.Parent = keyFrame

            TrackConnection(clickArea.MouseButton1Click:Connect(function()
                isBinding = true
                keyDisplay.Text = "[ _ ]"
            end))

            TrackConnection(UserInputService.InputBegan:Connect(function(input, processed)
                if isBinding then
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                        currentKey = input.KeyCode
                        keyDisplay.Text = "[" .. currentKey.Name .. "]"
                        isBinding = false
                    end
                elseif not processed then
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                        callSafely(callback, currentKey)
                    end
                end
            end))

            local bindObj = {}
            function bindObj:Set(newKey)
                currentKey = newKey
                keyDisplay.Text = "[" .. currentKey.Name .. "]"
            end
            return bindObj
        end

        -- ── Component 6: Text Input ──────────────────────────
        function methods.CreateInput(_, text, placeholder, callback)
            if type(text) == "table" then
                callback = text.Callback
                placeholder = text.PlaceholderText or text.Placeholder
                text = text.Name or text.Title or "Input"
            end
            callback = callback or function() end

            local inputFrame = Instance.new("Frame")
            inputFrame.Size = UDim2.new(1, 0, 0, 32)
            inputFrame.BackgroundColor3 = Theme.ElementBg
            inputFrame.BorderSizePixel = 0
            inputFrame.Parent = tabContent

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 160, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Theme.Text
            label.TextSize = 13
            label.Font = Theme.Font
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = inputFrame

            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(1, -180, 0, 20)
            textBox.Position = UDim2.new(0, 170, 0.5, -10)
            textBox.BackgroundColor3 = Theme.TopBar
            textBox.BorderSizePixel = 0
            textBox.Text = ""
            textBox.PlaceholderText = placeholder or "ENTER TEXT..."
            textBox.PlaceholderColor3 = Theme.TextMuted
            textBox.TextColor3 = Theme.TextLight
            textBox.TextSize = 11
            textBox.Font = Theme.Font
            textBox.ClearTextOnFocus = false
            textBox.Parent = inputFrame

            TrackConnection(textBox.FocusLost:Connect(function(enterPressed)
                callSafely(callback, textBox.Text, enterPressed)
            end))

            local inputObj = {}
            function inputObj:Set(val) textBox.Text = tostring(val) end
            function inputObj:Get() return textBox.Text end
            return inputObj
        end

        -- ── Component 7: Dropdown ────────────────────────────
        function methods.CreateDropdown(_, text, options, default, callback)
            if type(text) == "table" then
                callback = text.Callback
                default = text.CurrentOption or text.Default
                options = text.Options or {}
                text = text.Name or text.Title or "Dropdown"
            end
            options = options or {}
            callback = callback or function() end
            local selected = default or options[1] or "None"
            local isOpen = false

            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, 0, 0, 32)
            dropdownFrame.BackgroundColor3 = Theme.ElementBg
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.Parent = tabContent

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -130, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Theme.Text
            label.TextSize = 13
            label.Font = Theme.Font
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = dropdownFrame

            local displayBox = Instance.new("TextButton")
            displayBox.Size = UDim2.new(0, 118, 0, 20)
            displayBox.Position = UDim2.new(1, -126, 0, 6)
            displayBox.BackgroundColor3 = Theme.TopBar
            displayBox.BorderSizePixel = 0
            displayBox.Text = "  " .. tostring(selected) .. "  ▼"
            displayBox.TextColor3 = Theme.TextLight
            displayBox.TextSize = 11
            displayBox.Font = Theme.Font
            displayBox.TextXAlignment = Enum.TextXAlignment.Left
            displayBox.AutoButtonColor = false
            displayBox.ClipsDescendants = true
            displayBox.Parent = dropdownFrame

            local displayStroke = Instance.new("UIStroke")
            displayStroke.Color = Theme.Border
            displayStroke.Thickness = 1
            displayStroke.Transparency = 0.4
            displayStroke.Parent = displayBox

            local OPTION_HEIGHT = 26
            local optionsFrame = Instance.new("Frame")
            optionsFrame.Size = UDim2.new(1, 0, 0, 0)
            optionsFrame.Position = UDim2.new(0, 0, 0, 32)
            optionsFrame.BackgroundColor3 = Theme.Sidebar
            optionsFrame.BorderSizePixel = 0
            optionsFrame.ClipsDescendants = true
            optionsFrame.Parent = dropdownFrame

            local optionsLayout = Instance.new("UIListLayout")
            optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionsLayout.Parent = optionsFrame

            local optionButtons = {}

            local function SetOpen(open)
                if isOpen == open then return end
                isOpen = open
                local optHeight = #options * OPTION_HEIGHT
                displayBox.Text = "  " .. tostring(selected) .. (open and "  ▲" or "  ▼")
                TweenService:Create(dropdownFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, 32 + (open and optHeight or 0))
                }):Play()
                TweenService:Create(optionsFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, open and optHeight or 0)
                }):Play()
                TweenService:Create(displayStroke, TweenInfo.new(0.18), {
                    Color = open and Theme.TextMuted or Theme.Border
                }):Play()
            end

            local function RefreshSelection()
                for _, entry in ipairs(optionButtons) do
                    if entry.Value == selected then
                        entry.Button.BackgroundColor3 = Theme.TopBar
                        entry.Button.TextColor3 = Theme.TextLight
                    else
                        entry.Button.BackgroundColor3 = Theme.Sidebar
                        entry.Button.TextColor3 = Theme.Text
                    end
                end
            end

            local function BuildOptions(list)
                for _, child in ipairs(optionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                optionButtons = {}
                options = list or options

                for i, opt in ipairs(options) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Size = UDim2.new(1, 0, 0, OPTION_HEIGHT)
                    optBtn.BackgroundColor3 = Theme.Sidebar
                    optBtn.BorderSizePixel = 0
                    optBtn.Text = "   " .. tostring(opt)
                    optBtn.TextColor3 = Theme.Text
                    optBtn.TextSize = 12
                    optBtn.Font = Theme.Font
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    optBtn.AutoButtonColor = false
                    optBtn.LayoutOrder = i
                    optBtn.Parent = optionsFrame

                    table.insert(optionButtons, { Value = opt, Button = optBtn })

                    TrackConnection(optBtn.MouseEnter:Connect(function()
                        if selected ~= opt then
                            TweenService:Create(optBtn, TweenInfo.new(0.08), { BackgroundColor3 = Theme.ElementHover }):Play()
                        end
                    end))
                    TrackConnection(optBtn.MouseLeave:Connect(function()
                        if selected ~= opt then
                            TweenService:Create(optBtn, TweenInfo.new(0.08), { BackgroundColor3 = Theme.Sidebar }):Play()
                        end
                    end))
                    TrackConnection(optBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        displayBox.Text = "  " .. tostring(selected) .. (isOpen and "  ▲" or "  ▼")
                        RefreshSelection()
                        SetOpen(false)
                        callSafely(callback, selected)
                    end))
                end
                RefreshSelection()
            end

            BuildOptions(options)

            TrackConnection(displayBox.MouseButton1Click:Connect(function()
                SetOpen(not isOpen)
            end))

            TrackConnection(displayBox.MouseEnter:Connect(function()
                TweenService:Create(displayBox, TweenInfo.new(0.1), { BackgroundColor3 = Theme.ElementActive }):Play()
            end))
            TrackConnection(displayBox.MouseLeave:Connect(function()
                TweenService:Create(displayBox, TweenInfo.new(0.1), { BackgroundColor3 = Theme.TopBar }):Play()
            end))

            local dropdownObj = {}
            function dropdownObj:Set(value)
                selected = value
                displayBox.Text = "  " .. tostring(selected) .. (isOpen and "  ▲" or "  ▼")
                RefreshSelection()
            end
            function dropdownObj:Get()
                return selected
            end
            function dropdownObj:SetOptions(newOptions)
                BuildOptions(newOptions)
                if isOpen then
                    local optHeight = #options * OPTION_HEIGHT
                    TweenService:Create(dropdownFrame, TweenInfo.new(0.18), { Size = UDim2.new(1, 0, 0, 32 + optHeight) }):Play()
                    TweenService:Create(optionsFrame, TweenInfo.new(0.18), { Size = UDim2.new(1, 0, 0, optHeight) }):Play()
                end
            end
            return dropdownObj
        end

        -- ── Component 8: Divider ─────────────────────────────
        function methods.CreateDivider(_)
            local divider = Instance.new("Frame")
            divider.Size = UDim2.new(1, 0, 0, 6)
            divider.BackgroundTransparency = 1
            divider.Parent = tabContent

            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, 0.5, 0)
            line.BackgroundColor3 = Theme.BorderLight
            line.BorderSizePixel = 0
            line.Parent = divider

            local diamond = Instance.new("Frame")
            diamond.Size = UDim2.new(0, 5, 0, 5)
            diamond.Position = UDim2.new(0.5, -2, 0.5, -2)
            diamond.BackgroundColor3 = Theme.Border
            diamond.BorderSizePixel = 0
            diamond.Rotation = 45
            diamond.Parent = divider
        end

        -- ── Component 9: Label ───────────────────────────────
        function methods.CreateLabel(_, text, color)
            local labelFrame = Instance.new("Frame")
            labelFrame.Size = UDim2.new(1, 0, 0, 22)
            labelFrame.BackgroundTransparency = 1
            labelFrame.Parent = tabContent

            local labelText = Instance.new("TextLabel")
            labelText.Size = UDim2.new(1, -16, 1, 0)
            labelText.Position = UDim2.new(0, 12, 0, 0)
            labelText.BackgroundTransparency = 1
            labelText.Text = text
            labelText.TextColor3 = color or Theme.Text
            labelText.TextSize = 12
            labelText.Font = Theme.Font
            labelText.TextXAlignment = Enum.TextXAlignment.Left
            labelText.TextWrapped = true
            labelText.Parent = labelFrame

            local labelObj = {}
            function labelObj:Set(val) labelText.Text = tostring(val) end
            function labelObj:SetColor(c) labelText.TextColor3 = c end
            return labelObj
        end

        return tab
    end

    -- ── Window Cleanup ───────────────────────────────────────
    function window:Destroy()
        for _, conn in ipairs(window.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        window.Connections = {}
        tabs = {}
        activeTab = nil
        if screenGui and screenGui.Parent then
            pcall(function() screenGui:Destroy() end)
        end
        if _activeWindow == window then
            _activeWindow = nil
        end
    end

    function window:SetTitle(newTitle)
        titleLabel.Text = "◆ " .. string.upper(newTitle or "SYSTEM // YoRHa PROTOCOL")
    end

    _activeWindow = window
    return window
end

Library.Theme = Theme

return Library