local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Lib = {}

local THEME = {
    BG_MAIN    = Color3.fromRGB(18, 12, 28),
    BG_SIDE    = Color3.fromRGB(28, 16, 42),
    BG_GLASS   = Color3.fromRGB(38, 22, 58),
    BG_ITEM    = Color3.fromRGB(48, 28, 72),
    ACCENT     = Color3.fromRGB(200, 100, 220),
    ACCENT2    = Color3.fromRGB(160, 60, 200),
    TEXT       = Color3.fromRGB(255, 240, 255),
    TEXT_DIM   = Color3.fromRGB(180, 140, 200),
    GREEN      = Color3.fromRGB(80, 220, 140),
    RED        = Color3.fromRGB(240, 80, 100),
    WHITE      = Color3.fromRGB(255, 255, 255),
}
Lib.THEME = THEME

local TRANS = {
    GLASS  = 0.35,
    SIDE   = 0.25,
    ITEM   = 0.55,
    TOGGLE_OFF = 0.6,
    BTN    = 0.7,
}

local function getGuiParent()
    if gethui then return gethui() end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    return ok and cg or Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function tw(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = p
end

local function stroke(p, col, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or THEME.ACCENT
    s.Thickness = thick or 1
    s.Transparency = 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function padAll(p, px)
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
                    dragging = false; c:Disconnect()
                end
            end)
        end
    end))
    table.insert(conns, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
end

local function addMethods(target, scroll, conns, screenGui)
    local order = 0
    local function idx() order += 1 return order end

    function target:AddSection(title)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 24)
        f.BackgroundTransparency = 1
        f.LayoutOrder = idx()
        f.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8, 1, 0)
        lbl.Position = UDim2.new(0, 6, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "— " .. title:upper() .. " —"
        lbl.TextColor3 = THEME.ACCENT
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 9
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = f
    end

    function target:AddLabel(text, height)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, height or 18)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = THEME.TEXT_DIM
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        lbl.LayoutOrder = idx()
        lbl.Parent = scroll
        return lbl
    end

    function target:AddToggle(text, default, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 32)
        row.BackgroundColor3 = THEME.BG_ITEM
        row.BackgroundTransparency = TRANS.ITEM
        row.BorderSizePixel = 0
        row.LayoutOrder = idx()
        row.Parent = scroll
        corner(row, 10)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -60, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = THEME.TEXT
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local state = default or false

        local pillBg = Instance.new("Frame")
        pillBg.Size = UDim2.new(0, 38, 0, 20)
        pillBg.Position = UDim2.new(1, -48, 0.5, -10)
        pillBg.BackgroundColor3 = state and THEME.ACCENT or Color3.fromRGB(50, 30, 70)
        pillBg.BackgroundTransparency = state and 0.2 or TRANS.TOGGLE_OFF
        pillBg.BorderSizePixel = 0
        pillBg.Parent = row
        corner(pillBg, 10)
        local pillStroke = stroke(pillBg, state and THEME.ACCENT or THEME.TEXT_DIM, 1)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new(state and 1 or 0, state and -17 or 3, 0.5, -7)
        knob.BackgroundColor3 = state and THEME.WHITE or THEME.TEXT_DIM
        knob.BorderSizePixel = 0
        knob.Parent = pillBg
        corner(knob, 7)

        local hitBtn = Instance.new("TextButton")
        hitBtn.Size = UDim2.new(1, 0, 1, 0)
        hitBtn.BackgroundTransparency = 1
        hitBtn.Text = ""
        hitBtn.Parent = row

        local function refresh()
            tw(pillBg, {
                BackgroundColor3 = state and THEME.ACCENT or Color3.fromRGB(50, 30, 70),
                BackgroundTransparency = state and 0.2 or TRANS.TOGGLE_OFF,
            }, 0.2)
            tw(knob, {
                Position = UDim2.new(state and 1 or 0, state and -17 or 3, 0.5, -7),
                BackgroundColor3 = state and THEME.WHITE or THEME.TEXT_DIM,
            }, 0.2)
            pillStroke.Color = state and THEME.ACCENT or THEME.TEXT_DIM
        end

        table.insert(conns, hitBtn.MouseButton1Click:Connect(function()
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
        local function fmt(v) return (decimals or 0) == 0 and tostring(math.round(v)) or tostring(round(v)) end

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundColor3 = THEME.BG_ITEM
        frame.BackgroundTransparency = TRANS.ITEM
        frame.BorderSizePixel = 0
        frame.LayoutOrder = idx()
        frame.Parent = scroll
        corner(frame, 10)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -12, 0, 20)
        lbl.Position = UDim2.new(0, 10, 0, 4)
        lbl.BackgroundTransparency = 1
        lbl.Text = text .. "  " .. fmt(default)
        lbl.TextColor3 = THEME.TEXT
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local barBg = Instance.new("Frame")
        barBg.Size = UDim2.new(1, -20, 0, 5)
        barBg.Position = UDim2.new(0, 10, 0, 34)
        barBg.BackgroundColor3 = Color3.fromRGB(60, 35, 85)
        barBg.BackgroundTransparency = 0.3
        barBg.BorderSizePixel = 0
        barBg.Parent = frame
        corner(barBg, 3)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = THEME.ACCENT
        fill.BackgroundTransparency = 0.15
        fill.BorderSizePixel = 0
        fill.Parent = barBg
        corner(fill, 3)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 13, 0, 13)
        knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
        knob.BackgroundColor3 = THEME.ACCENT
        knob.BorderSizePixel = 0
        knob.Parent = barBg
        corner(knob, 7)
        stroke(knob, THEME.WHITE, 1)

        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(1, 0, 0, 50)
        hitbox.Position = UDim2.new(0, 0, 0, -30)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.Parent = barBg

        local dragging = false
        local function update(pos)
            local rel = math.clamp((pos.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
            local v = round(min + (max - min) * rel)
            lbl.Text = text .. "  " .. fmt(v)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -6, 0.5, -6)
            pcall(callback, v)
        end

        table.insert(conns, hitbox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; update(input.Position)
            end
        end))
        table.insert(conns, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
        table.insert(conns, UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                update(input.Position)
            end
        end))

        local obj = {}
        function obj.Set(v)
            local rel = math.clamp((v - min) / (max - min), 0, 1)
            lbl.Text = text .. "  " .. fmt(v)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -6, 0.5, -6)
        end
        return obj
    end

    function target:AddButton(text, color, callback)
        if type(color) == "function" then callback, color = color, nil end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = color or THEME.ACCENT2
        btn.BackgroundTransparency = TRANS.BTN
        btn.Text = text
        btn.TextColor3 = THEME.TEXT
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.LayoutOrder = idx()
        btn.Parent = scroll
        corner(btn, 10)
        stroke(btn, color or THEME.ACCENT, 1)

        table.insert(conns, btn.MouseButton1Click:Connect(function()
            tw(btn, {BackgroundTransparency = 0.3}, 0.1)
            task.delay(0.18, function() tw(btn, {BackgroundTransparency = TRANS.BTN}, 0.18) end)
            pcall(callback)
        end))
        return btn
    end

    function target:AddInput(label, default, placeholder, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 54)
        frame.BackgroundColor3 = THEME.BG_ITEM
        frame.BackgroundTransparency = TRANS.ITEM
        frame.BorderSizePixel = 0
        frame.LayoutOrder = idx()
        frame.Parent = scroll
        corner(frame, 10)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -12, 0, 22)
        lbl.Position = UDim2.new(0, 10, 0, 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = THEME.TEXT_DIM
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -16, 0, 22)
        box.Position = UDim2.new(0, 8, 0, 26)
        box.BackgroundColor3 = Color3.fromRGB(30, 18, 48)
        box.BackgroundTransparency = 0.2
        box.Text = default or ""
        box.PlaceholderText = placeholder or ""
        box.TextColor3 = THEME.TEXT
        box.Font = Enum.Font.Gotham
        box.TextSize = 11
        box.ClearTextOnFocus = false
        box.Parent = frame
        corner(box, 6)
        stroke(box, THEME.ACCENT, 1)

        table.insert(conns, box.FocusLost:Connect(function() pcall(callback, box.Text) end))
        return {Instance = frame, TextBox = box}
    end

    function target:AddDropdown(label, items, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = THEME.BG_ITEM
        frame.BackgroundTransparency = TRANS.ITEM
        frame.BorderSizePixel = 0
        frame.LayoutOrder = idx()
        frame.Parent = scroll
        corner(frame, 10)
        stroke(frame, THEME.ACCENT, 1)

        local selected = default or (items[1] or "")
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = "  " .. label .. ":  " .. tostring(selected)
        btn.TextColor3 = THEME.TEXT
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = frame

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 22, 1, 0)
        arrow.Position = UDim2.new(1, -24, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▾"
        arrow.TextColor3 = THEME.ACCENT
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 14
        arrow.Parent = frame

        local obj = {}
        function obj.Set(v)
            selected = v
            btn.Text = "  " .. label .. ":  " .. tostring(v)
        end

        table.insert(conns, btn.MouseButton1Click:Connect(function()
            local root = screenGui or frame:FindFirstAncestorOfClass("ScreenGui")
            if not root then return end

            local absPos = frame.AbsolutePosition
            local absSize = frame.AbsoluteSize
            local itemH = 28
            local totalH = math.min(#items * itemH, 140)

            local overlay = Instance.new("Frame")
            overlay.Size = UDim2.new(0, absSize.X, 0, totalH)
            overlay.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 3)
            overlay.BackgroundColor3 = Color3.fromRGB(28, 14, 44)
            overlay.BackgroundTransparency = 0.08
            overlay.BorderSizePixel = 0
            overlay.ZIndex = 50
            overlay.ClipsDescendants = true
            overlay.Parent = root
            corner(overlay, 10)
            stroke(overlay, THEME.ACCENT, 1)

            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Parent = overlay

            local function closeOverlay()
                tw(overlay, {Size = UDim2.new(0, absSize.X, 0, 0)}, 0.15)
                task.delay(0.15, function() pcall(function() overlay:Destroy() end) end)
                tw(arrow, {TextColor3 = THEME.ACCENT}, 0.15)
            end

            tw(arrow, {TextColor3 = THEME.WHITE}, 0.15)

            for i, v in ipairs(items) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, itemH)
                item.BackgroundTransparency = 1
                item.BorderSizePixel = 0
                item.Text = "    " .. tostring(v)
                item.TextColor3 = THEME.TEXT_DIM
                item.Font = Enum.Font.Gotham
                item.TextSize = 11
                item.TextXAlignment = Enum.TextXAlignment.Left
                item.LayoutOrder = i
                item.ZIndex = 51
                item.Parent = overlay

                item.MouseEnter:Connect(function()
                    tw(item, {TextColor3 = THEME.TEXT, BackgroundTransparency = 0.82}, 0.12)
                    item.BackgroundColor3 = THEME.ACCENT
                end)
                item.MouseLeave:Connect(function()
                    tw(item, {TextColor3 = THEME.TEXT_DIM, BackgroundTransparency = 1}, 0.12)
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
        wrap.Size = UDim2.new(1, 0, 0, 32)
        wrap.BackgroundColor3 = THEME.BG_GLASS
        wrap.BackgroundTransparency = TRANS.GLASS
        wrap.ClipsDescendants = true
        wrap.BorderSizePixel = 0
        wrap.LayoutOrder = idx()
        wrap.Parent = scroll
        corner(wrap, 12)
        stroke(wrap, THEME.ACCENT, 1)

        local header = Instance.new("TextButton")
        header.Size = UDim2.new(1, 0, 0, 32)
        header.BackgroundTransparency = 1
        header.Text = "  ▸  " .. title
        header.TextColor3 = THEME.TEXT_DIM
        header.Font = Enum.Font.GothamBold
        header.TextSize = 11
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = wrap

        local inner = Instance.new("Frame")
        inner.Position = UDim2.new(0, 0, 0, 32)
        inner.Size = UDim2.new(1, 0, 0, 0)
        inner.BackgroundTransparency = 1
        inner.Parent = wrap

        local innerLayout = Instance.new("UIListLayout")
        innerLayout.Padding = UDim.new(0, 5)
        innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        innerLayout.Parent = inner
        padAll(inner, 5)

        local open = false
        local function refresh()
            local h = open and (32 + innerLayout.AbsoluteContentSize.Y + 14) or 32
            tw(wrap, {Size = UDim2.new(1, 0, 0, h)}, 0.25)
            header.Text = (open and "  ▾  " or "  ▸  ") .. title
            tw(header, {TextColor3 = open and THEME.ACCENT or THEME.TEXT_DIM}, 0.2)
        end

        table.insert(conns, header.MouseButton1Click:Connect(function()
            open = not open; refresh()
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
    toggleBtn.Size = UDim2.new(0, 52, 0, 52)
    toggleBtn.Position = UDim2.new(0.02, 0, 0.5, -26)
    toggleBtn.BackgroundColor3 = THEME.BG_GLASS
    toggleBtn.BackgroundTransparency = TRANS.GLASS
    toggleBtn.Image = "rbxthumb://type=Asset&id=" .. (iconId or "91598067356551") .. "&w=420&h=420"
    toggleBtn.ScaleType = Enum.ScaleType.Fit
    toggleBtn.ZIndex = 10
    toggleBtn.Parent = screenGui
    corner(toggleBtn, 14)
    stroke(toggleBtn, THEME.ACCENT, 2)
    makeDraggable(toggleBtn, conns)

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 540, 0, 340)
    main.Position = UDim2.new(0.5, -270, 0.5, -170)
    main.BackgroundColor3 = THEME.BG_MAIN
    main.BackgroundTransparency = TRANS.GLASS
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = screenGui
    corner(main, 16)
    stroke(main, THEME.ACCENT, 2)
    makeDraggable(main, conns)

    table.insert(conns, toggleBtn.MouseButton1Click:Connect(function()
        guiVisible = not guiVisible
        main.Visible = guiVisible
        tw(toggleBtn, {BackgroundTransparency = guiVisible and TRANS.GLASS or 0.6}, 0.2)
    end))

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 108, 1, 0)
    sidebar.BackgroundColor3 = THEME.BG_SIDE
    sidebar.BackgroundTransparency = TRANS.SIDE
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    corner(sidebar, 16)

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0, 1, 1, -20)
    divider.Position = UDim2.new(0, 107, 0, 10)
    divider.BackgroundColor3 = THEME.ACCENT
    divider.BackgroundTransparency = 0.6
    divider.BorderSizePixel = 0
    divider.Parent = main

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 34)
    titleLbl.Position = UDim2.new(0, 0, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title or "Script"
    titleLbl.TextColor3 = THEME.ACCENT
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 18
    titleLbl.Parent = sidebar

    local authorLbl = Instance.new("TextLabel")
    authorLbl.Size = UDim2.new(1, 0, 0, 14)
    authorLbl.Position = UDim2.new(0, 0, 0, 40)
    authorLbl.BackgroundTransparency = 1
    authorLbl.Text = author or "dev"
    authorLbl.TextColor3 = THEME.TEXT_DIM
    authorLbl.Font = Enum.Font.Gotham
    authorLbl.TextSize = 9
    authorLbl.Parent = sidebar

    local tabList = Instance.new("Frame")
    tabList.Size = UDim2.new(1, 0, 1, -64)
    tabList.Position = UDim2.new(0, 0, 0, 64)
    tabList.BackgroundTransparency = 1
    tabList.Parent = sidebar
    padAll(tabList, 5)

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = tabList

    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -120, 1, -14)
    contentArea.Position = UDim2.new(0, 115, 0, 7)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main

    local pages, tabBtns = {}, {}

    local Window = {}

    function Window:CreateTab(name)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0.92, 0, 0, 32)
        tabBtn.BackgroundColor3 = THEME.BG_GLASS
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = name
        tabBtn.TextColor3 = THEME.TEXT_DIM
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 11
        tabBtn.Parent = tabList
        corner(tabBtn, 9)

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
        padAll(page, 4)

        table.insert(conns, tabBtn.MouseButton1Click:Connect(function()
            for _, p in ipairs(pages) do p.Visible = false end
            for _, b in ipairs(tabBtns) do
                tw(b, {BackgroundTransparency = 1, TextColor3 = THEME.TEXT_DIM}, 0.2)
            end
            page.Visible = true
            tw(tabBtn, {BackgroundTransparency = 0.45, TextColor3 = THEME.ACCENT}, 0.2)
        end))

        table.insert(pages, page)
        table.insert(tabBtns, tabBtn)

        local Tab = {Instance = page}
        addMethods(Tab, page, conns, screenGui)
        return Tab
    end

    function Window:SelectTab(n)
        if tabBtns[n] then tabBtns[n].MouseButton1Click:Fire() end
    end

    function Window:Destroy()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
        pcall(function() screenGui:Destroy() end)
    end

    return Window
end

return Lib
