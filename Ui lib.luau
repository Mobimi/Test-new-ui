local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Lib = {}

local THEME = {
    BG_MAIN    = Color3.fromRGB(20, 20, 25),
    BG_SIDE    = Color3.fromRGB(15, 15, 20),
    BG_CONTENT = Color3.fromRGB(25, 25, 30),
    ACCENT     = Color3.fromRGB(155, 89, 182),
    TEXT       = Color3.fromRGB(240, 240, 240),
    TEXT_DIM   = Color3.fromRGB(150, 150, 150),
    GREEN      = Color3.fromRGB(50, 200, 50),
    RED        = Color3.fromRGB(220, 50, 50),
    DARK_ITEM  = Color3.fromRGB(35, 35, 40),
}
Lib.THEME = THEME

local function getGuiParent()
    if gethui then return gethui() end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    return ok and cg or Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function tw(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quart), props):Play()
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
end

local function stroke(p, col, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or THEME.ACCENT
    s.Thickness = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
end

local function listPadding(p, px)
    local u = Instance.new("UIPadding")
    local ud = UDim.new(0, px or 5)
    u.PaddingTop, u.PaddingBottom, u.PaddingLeft, u.PaddingRight = ud, ud, ud, ud
    u.Parent = p
end

local function makeDraggable(frame, conns)
    local dragging, dragStart, startPos = false, nil, nil
    table.insert(conns, frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, frame.Position
            local c; c = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    c:Disconnect()
                end
            end)
        end
    end))
    table.insert(conns, UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        ) then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end))
end

local function addMethods(target, scroll, conns, screenGui)
    local order = 0
    local function idx() order += 1 return order end

    function target:AddSection(title)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 22)
        f.BackgroundTransparency = 1
        f.LayoutOrder = idx()
        f.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8, 1, 0)
        lbl.Position = UDim2.new(0, 4, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = title:upper()
        lbl.TextColor3 = THEME.ACCENT
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = f

        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 1, -1)
        line.BackgroundColor3 = THEME.ACCENT
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0
        line.Parent = f
    end

    function target:AddLabel(text, height)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, height or 18)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = THEME.TEXT_DIM
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        lbl.LayoutOrder = idx()
        lbl.Parent = scroll
        return lbl
    end

    function target:AddToggle(text, default, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundTransparency = 1
        row.LayoutOrder = idx()
        row.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -50, 1, 0)
        lbl.Position = UDim2.new(0, 6, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = THEME.TEXT
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local track = Instance.new("TextButton")
        track.Size = UDim2.new(0, 32, 0, 17)
        track.Position = UDim2.new(1, -38, 0.5, -8)
        track.BackgroundColor3 = default and THEME.ACCENT or Color3.fromRGB(55, 55, 65)
        track.Text = ""
        track.Parent = row
        corner(track, 8)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 13, 0, 13)
        knob.Position = UDim2.new(default and 1 or 0, default and -15 or 2, 0.5, -6)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.Parent = track
        corner(knob, 7)

        local state = default or false
        local function refresh()
            tw(track, {BackgroundColor3 = state and THEME.ACCENT or Color3.fromRGB(55, 55, 65)}, 0.2)
            tw(knob, {Position = UDim2.new(state and 1 or 0, state and -15 or 2, 0.5, -6)}, 0.2)
        end

        table.insert(conns, track.MouseButton1Click:Connect(function()
            state = not state
            refresh()
            pcall(callback, state)
        end))

        local obj = {}
        function obj.Set(v) state = v refresh() end
        function obj.Get() return state end
        return obj
    end

    function target:AddSlider(text, min, max, default, decimals, callback)
        local prec = 10 ^ (decimals or 0)
        local function round(v) return math.floor(v * prec + 0.5) / prec end
        local function fmt(v)
            return (decimals or 0) == 0 and tostring(math.round(v)) or tostring(round(v))
        end

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 44)
        frame.BackgroundTransparency = 1
        frame.LayoutOrder = idx()
        frame.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -12, 0, 20)
        lbl.Position = UDim2.new(0, 6, 0, 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = text .. ": " .. fmt(default)
        lbl.TextColor3 = THEME.TEXT
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -12, 0, 4)
        bar.Position = UDim2.new(0, 6, 0, 30)
        bar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        bar.Parent = frame
        corner(bar, 2)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = THEME.ACCENT
        fill.Parent = bar
        corner(fill, 2)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 11, 0, 11)
        knob.Position = UDim2.new((default - min) / (max - min), -5, 0.5, -5)
        knob.BackgroundColor3 = THEME.ACCENT
        knob.Parent = bar
        corner(knob, 6)

        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(1, 0, 0, 44)
        hitbox.Position = UDim2.new(0, 0, 0, -20)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.Parent = bar

        local dragging = false
        local function update(pos)
            local rel = math.clamp((pos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = round(min + (max - min) * rel)
            lbl.Text = text .. ": " .. fmt(v)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -5, 0.5, -5)
            pcall(callback, v)
        end

        table.insert(conns, hitbox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input.Position)
            end
        end))
        table.insert(conns, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
        table.insert(conns, UserInputService.InputChanged:Connect(function(input)
            if dragging and (
                input.UserInputType == Enum.UserInputType.MouseMovement or
                input.UserInputType == Enum.UserInputType.Touch
            ) then
                update(input.Position)
            end
        end))

        local obj = {}
        function obj.Set(v)
            local rel = math.clamp((v - min) / (max - min), 0, 1)
            lbl.Text = text .. ": " .. fmt(v)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -5, 0.5, -5)
        end
        return obj
    end

    function target:AddButton(text, color, callback)
        if type(color) == "function" then
            callback, color = color, nil
        end
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = color or THEME.ACCENT
        btn.BackgroundTransparency = 0.75
        btn.Text = text
        btn.TextColor3 = THEME.TEXT
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.LayoutOrder = idx()
        btn.Parent = scroll
        corner(btn, 6)
        stroke(btn, color or THEME.ACCENT)

        table.insert(conns, btn.MouseButton1Click:Connect(function()
            tw(btn, {BackgroundTransparency = 0.4}, 0.1)
            task.delay(0.15, function() tw(btn, {BackgroundTransparency = 0.75}, 0.1) end)
            pcall(callback)
        end))
        return btn
    end

    function target:AddInput(label, default, placeholder, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 52)
        frame.BackgroundTransparency = 1
        frame.LayoutOrder = idx()
        frame.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -12, 0, 22)
        lbl.Position = UDim2.new(0, 6, 0, 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = THEME.TEXT
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -12, 0, 24)
        box.Position = UDim2.new(0, 6, 0, 24)
        box.BackgroundColor3 = Color3.fromRGB(38, 38, 45)
        box.Text = default or ""
        box.PlaceholderText = placeholder or ""
        box.TextColor3 = THEME.TEXT
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        box.ClearTextOnFocus = false
        box.Parent = frame
        corner(box, 4)
        stroke(box, THEME.ACCENT)

        table.insert(conns, box.FocusLost:Connect(function() pcall(callback, box.Text) end))
        return {Instance = frame, TextBox = box}
    end

    function target:AddDropdown(label, items, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        frame.BorderSizePixel = 0
        frame.LayoutOrder = idx()
        frame.Parent = scroll
        corner(frame, 6)
        stroke(frame, THEME.ACCENT)

        local selected = default or (items[1] or "")
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = "  " .. label .. ": " .. tostring(selected)
        btn.TextColor3 = THEME.TEXT
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = frame

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -22, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = THEME.ACCENT
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 10
        arrow.Parent = frame

        local obj = {}
        function obj.Set(v)
            selected = v
            btn.Text = "  " .. label .. ": " .. tostring(v)
        end

        table.insert(conns, btn.MouseButton1Click:Connect(function()
            local root = screenGui or frame:FindFirstAncestorOfClass("ScreenGui")
            if not root then return end

            local absPos = frame.AbsolutePosition
            local absSize = frame.AbsoluteSize
            local itemH = 26
            local totalH = math.min(#items * itemH, 130)

            local overlay = Instance.new("Frame")
            overlay.Size = UDim2.new(0, absSize.X, 0, totalH)
            overlay.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
            overlay.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
            overlay.BorderSizePixel = 0
            overlay.ZIndex = 50
            overlay.ClipsDescendants = true
            overlay.Parent = root
            corner(overlay, 6)
            stroke(overlay, THEME.ACCENT)

            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Parent = overlay

            local function closeOverlay()
                tw(overlay, {Size = UDim2.new(0, absSize.X, 0, 0)}, 0.15)
                task.delay(0.15, function() pcall(function() overlay:Destroy() end) end)
                tw(arrow, {TextColor3 = THEME.ACCENT}, 0.15)
            end

            tw(arrow, {TextColor3 = THEME.TEXT}, 0.15)

            for i, v in ipairs(items) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, itemH)
                item.BackgroundTransparency = 1
                item.BorderSizePixel = 0
                item.Text = "  " .. tostring(v)
                item.TextColor3 = THEME.TEXT_DIM
                item.Font = Enum.Font.Gotham
                item.TextSize = 11
                item.TextXAlignment = Enum.TextXAlignment.Left
                item.LayoutOrder = i
                item.ZIndex = 51
                item.Parent = overlay

                item.MouseEnter:Connect(function()
                    tw(item, {TextColor3 = THEME.TEXT, BackgroundTransparency = 0.85}, 0.15)
                end)
                item.MouseLeave:Connect(function()
                    tw(item, {TextColor3 = THEME.TEXT_DIM, BackgroundTransparency = 1}, 0.15)
                end)
                item.MouseButton1Click:Connect(function()
                    obj.Set(v)
                    pcall(callback, v)
                    closeOverlay()
                end)
            end

            local blocker = Instance.new("TextButton")
            blocker.Size = UDim2.new(1, 0, 1, 0)
            blocker.BackgroundTransparency = 1
            blocker.Text = ""
            blocker.ZIndex = 49
            blocker.Parent = root
            blocker.MouseButton1Click:Connect(function()
                closeOverlay()
                blocker:Destroy()
            end)
        end))

        return obj
    end

    function target:AddCollapsible(title)
        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, 0, 0, 30)
        wrap.BackgroundColor3 = THEME.BG_CONTENT
        wrap.BackgroundTransparency = 0.3
        wrap.ClipsDescendants = true
        wrap.BorderSizePixel = 0
        wrap.LayoutOrder = idx()
        wrap.Parent = scroll
        corner(wrap, 6)
        stroke(wrap, THEME.ACCENT)

        local header = Instance.new("TextButton")
        header.Size = UDim2.new(1, 0, 0, 30)
        header.BackgroundTransparency = 1
        header.Text = "  " .. title .. "  ▼"
        header.TextColor3 = THEME.TEXT
        header.Font = Enum.Font.GothamBold
        header.TextSize = 10
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = wrap

        local inner = Instance.new("Frame")
        inner.Position = UDim2.new(0, 0, 0, 30)
        inner.Size = UDim2.new(1, 0, 0, 0)
        inner.BackgroundTransparency = 1
        inner.Parent = wrap

        local innerLayout = Instance.new("UIListLayout")
        innerLayout.Padding = UDim.new(0, 4)
        innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        innerLayout.Parent = inner
        listPadding(inner, 4)

        local open = false
        local function refresh()
            local h = open and (30 + innerLayout.AbsoluteContentSize.Y + 10) or 30
            tw(wrap, {Size = UDim2.new(1, 0, 0, h)}, 0.25)
            header.Text = "  " .. title .. (open and "  ▲" or "  ▼")
            header.TextColor3 = open and THEME.ACCENT or THEME.TEXT
        end

        table.insert(conns, header.MouseButton1Click:Connect(function()
            open = not open
            refresh()
        end))
        table.insert(conns, innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if open then refresh() end
        end))

        local sub = {Instance = wrap, Container = inner}
        addMethods(sub, inner, conns, screenGui)
        return sub
    end
end

function Lib:CreateWindow(title, author, iconId)
    local conns = {}
    local guiVisible = true

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HB_" .. math.random(1000, 9999)
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() screenGui.IgnoreGuiInset = true end)
    screenGui.Parent = getGuiParent()

    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Size = UDim2.new(0, 54, 0, 54)
    toggleBtn.Position = UDim2.new(0.02, 0, 0.5, -27)
    toggleBtn.BackgroundColor3 = THEME.BG_SIDE
    toggleBtn.BackgroundTransparency = 0.15
    toggleBtn.Image = "rbxthumb://type=Asset&id=" .. (iconId or "91598067356551") .. "&w=420&h=420"
    toggleBtn.ScaleType = Enum.ScaleType.Fit
    toggleBtn.ZIndex = 10
    toggleBtn.Parent = screenGui
    corner(toggleBtn, 12)
    stroke(toggleBtn, THEME.ACCENT, 2)
    makeDraggable(toggleBtn, conns)

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 530, 0, 330)
    main.Position = UDim2.new(0.5, -265, 0.5, -165)
    main.BackgroundColor3 = THEME.BG_MAIN
    main.BackgroundTransparency = 0.08
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = screenGui
    corner(main, 12)
    stroke(main, THEME.ACCENT, 2)
    makeDraggable(main, conns)

    table.insert(conns, toggleBtn.MouseButton1Click:Connect(function()
        guiVisible = not guiVisible
        main.Visible = guiVisible
        tw(toggleBtn, {BackgroundTransparency = guiVisible and 0.15 or 0.5}, 0.2)
    end))

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 105, 1, 0)
    sidebar.BackgroundColor3 = THEME.BG_SIDE
    sidebar.BackgroundTransparency = 0.15
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    corner(sidebar, 12)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 32)
    titleLbl.Position = UDim2.new(0, 0, 0, 6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title or "Script"
    titleLbl.TextColor3 = THEME.ACCENT
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 20
    titleLbl.Parent = sidebar

    local authorLbl = Instance.new("TextLabel")
    authorLbl.Size = UDim2.new(1, 0, 0, 16)
    authorLbl.Position = UDim2.new(0, 0, 0, 36)
    authorLbl.BackgroundTransparency = 1
    authorLbl.Text = "by " .. (author or "dev")
    authorLbl.TextColor3 = THEME.TEXT_DIM
    authorLbl.Font = Enum.Font.GothamMedium
    authorLbl.TextSize = 9
    authorLbl.Parent = sidebar

    local tabList = Instance.new("Frame")
    tabList.Size = UDim2.new(1, 0, 1, -62)
    tabList.Position = UDim2.new(0, 0, 0, 62)
    tabList.BackgroundTransparency = 1
    tabList.Parent = sidebar
    listPadding(tabList, 4)

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = tabList

    local contentArea = Instance.new("Frame")
    contentArea.Name = "Content"
    contentArea.Size = UDim2.new(1, -118, 1, -12)
    contentArea.Position = UDim2.new(0, 112, 0, 6)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main

    local pages, tabBtns = {}, {}

    local Window = {}

    function Window:CreateTab(name)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0.9, 0, 0, 34)
        tabBtn.BackgroundColor3 = THEME.DARK_ITEM
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = name
        tabBtn.TextColor3 = THEME.TEXT_DIM
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 11
        tabBtn.Parent = tabList
        corner(tabBtn, 7)

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = THEME.ACCENT
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Parent = contentArea

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 6)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Parent = page
        listPadding(page, 4)

        table.insert(conns, tabBtn.MouseButton1Click:Connect(function()
            for _, p in ipairs(pages) do p.Visible = false end
            for _, b in ipairs(tabBtns) do
                tw(b, {BackgroundTransparency = 1, TextColor3 = THEME.TEXT_DIM}, 0.2)
            end
            page.Visible = true
            tw(tabBtn, {BackgroundTransparency = 0, TextColor3 = THEME.ACCENT}, 0.2)
        end))

        table.insert(pages, page)
        table.insert(tabBtns, tabBtn)

        local Tab = {Instance = page}
        addMethods(Tab, page, conns, screenGui)
        return Tab
    end

    function Window:SelectTab(n)
        if tabBtns[n] then
            tabBtns[n].MouseButton1Click:Fire()
        end
    end

    function Window:Destroy()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
        pcall(function() screenGui:Destroy() end)
    end

    return Window
end

return Lib
