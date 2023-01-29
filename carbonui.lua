--[[
    Carbon UI library
    by woffle#0001
]]--

local root = Instance.new("ScreenGui")
root.Name = "Carbon"
local userInputService = game:GetService("UserInputService")

local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()

local util = {
    create = function(obj, properties)
        local o = Instance.new(obj)
        for i,v in pairs(properties) do
            if i == "Parent" then continue end
            o[i] = v
        end
        if properties["Parent"] then
            o.Parent = properties["Parent"]
        end
        return o
    end,

    roundify = function(f, r)
        local uiCorner = Instance.new("UICorner", f)
        uiCorner.CornerRadius = UDim.new(0, r)
    end,

    makeDraggable = function(w)
        local dragging = false
        local offsetX, offsetY = 0, 0

        mouse.Button1Down:Connect(function()
            offsetX, offsetY = mouse.X - w.AbsolutePosition.X, mouse.Y - w.AbsolutePosition.Y
            dragging = not (offsetX < 0 or offsetY < 0 or offsetX > w.AbsoluteSize.X or offsetY > w.AbsoluteSize.Y)
            for _,ow in pairs(root:GetChildren()) do
                if ow == w then continue end
                local _offsetX, _offsetY = mouse.X - ow.AbsolutePosition.X, mouse.Y - ow.AbsolutePosition.Y
                if not (_offsetX < 0 or _offsetY < 0 or _offsetX > ow.AbsoluteSize.X or _offsetY > ow.AbsoluteSize.Y) then
                    dragging = false
                end
            end
        end)
        mouse.Button1Up:Connect(function()
            dragging = false
        end)

        task.spawn(function()
            while true do
                if dragging then
                    w.Position = UDim2.new(0, mouse.X - offsetX, 0, mouse.Y - offsetY)
                end
                task.wait()
            end
        end)
    end,

    getPos = function(category)
        local pos = 0
        for _, el in pairs(category:GetChildren()) do
            if el:IsA("UIPadding") then continue end
            pos += (el.Size.Y.Offset + 5) * el.Size.X.Scale
        end
        return pos
    end,

    isCategory = function(category)
        return category.Parent.Name == "category"
    end,

    isWindow = function(win)
        return type(win) == "table" and #win == 3 and win[1].Name == "Carbon" and win[2].Name == "Tabs" and win[3].Name == "Content"
    end,

    depend = function(bool, error)
        if not bool then
            warn(error)
            return false
        end
        return true
    end,

    checkTypes = function(values, types)
        for i,v in pairs(values) do
            if type(v) ~= types[i] then return false end
        end
        return true
    end,

    formatTab = function(tab)
        if tab.Name ~= "Tab" then
            warn("Can't format a non-tab")
            return
        end
        local categories = {}
        for _,category in pairs(tab:GetChildren()) do
            if category.Name == "category" then
                table.insert(categories, category)
            end
        end
        local row1 = {}
        local row2 = {}
        local cr = 1
        while #categories > 0 do
            local largest
            local largestIdx
            local largestSize = 0
            for i,v in pairs(categories) do
                if v.Size.Y.Offset > largestSize then
                    largest = v
                    largestIdx = i
                    largestSize = v.Size.Y.Offset
                end
            end
            if cr == 1 then
                row1[#row1+1] = largest
                cr = 2
            else
                row2[#row2+1] = largest
                cr = 1
            end
            table.remove(categories, largestIdx)
        end
        for i,category in pairs(row1) do
            if i == 1 then continue end
            category.Position = UDim2.new(0, 0, 0, row1[i-1].Position.Y.Offset + row1[i-1].Size.Y.Offset + 5)
        end
        for i,category in pairs(row2) do
            if i == 1 then
                category.Position = UDim2.new(0.5, 5, 0, 0)
                continue
            end
            category.Position = UDim2.new(0.5, 5, 0, row2[i-1].Position.Y.Offset + row2[i-1].Size.Y.Offset + 5)
        end
    end
}

local bindingFunc = function(k) end
local handlers = {}
local settingKeybind = false

userInputService.InputBegan:Connect(function(key, gameProcessed)
    if gameProcessed then return end
    if key.UserInputType == Enum.UserInputType.Keyboard then
        if settingKeybind then
            bindingFunc(key.KeyCode)
        else
            if handlers[key.KeyCode] then
                handlers[key.KeyCode]()
            end
        end
    end
end)

carbon = {
    new = function(width, height, title, icon)
        if not util.depend(util.checkTypes({width, height, title}, {"number", "number", "string"}), "Invalid types passed to carbon.new") then return end
        local border = util.create("Frame", {
            Size = UDim2.new(0, width + 4, 0, height + 4),
            Position = UDim2.new(0,10,0,10),
            Parent = root,
            ClipsDescendants = true,
            Name = "Carbon"
        })
        util.roundify(border, 12)

        local maximizer = util.create("TextButton", {
            Parent = border,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            Text = "",
            AutoButtonColor = false,
            Visible = false
        })

        local gradient = util.create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 212)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(153, 0, 255))
            }),
            Parent = border,
            Rotation = 45
        })

        util.makeDraggable(border)

        task.spawn(function()
            while true do
                gradient.Rotation += 1
                task.wait()
            end
        end)

        local main = util.create("Frame", {
            Size = UDim2.new(0, width, 0, height),
            Position = UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = Color3.fromHex("#24283b"),
            Parent = border
        })
        util.roundify(main, 12)

        local content = util.create("ScrollingFrame", {
            Size = UDim2.new(1,-120,1,-30),
            Position = UDim2.new(0,120,0,30),
            BackgroundTransparency = 1,
            Parent = main,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0,0,0,0),
            Name = "Content"
        })

        local topbar = util.create("Frame", {
            Size = UDim2.new(0, width, 0, 30),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Color3.fromHex("#1a1b26"),
            Parent = main
        })
        util.roundify(topbar, 12)
        util.create("Frame", {
            Size = UDim2.new(0, width, 0, 15),
            Position = UDim2.new(0, 0, 0, 15),
            BackgroundColor3 = Color3.fromHex("#1a1b26"),
            Parent = topbar,
            BorderSizePixel = 0,
            ZIndex = 2
        })
        local sidebar = util.create("Frame", {
            Size = UDim2.new(0, 120, 0, height),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Color3.fromHex("#1a1b26"),
            Parent = main
        })
        util.roundify(sidebar, 12)
        util.create("Frame", {
            Size = UDim2.new(0.5, 0, 0, height),
            Position = UDim2.new(0.5, 0, 0),
            BackgroundColor3 = Color3.fromHex("#1a1b26"),
            Parent = sidebar,
            BorderSizePixel = 0
        })
        local tabs = util.create("ScrollingFrame", {
            Size = UDim2.new(1,0,1,-30),
            Position = UDim2.new(0,0,0,30),
            BackgroundTransparency = 1,
            Parent = sidebar,
            BorderSizePixel = 0,
            AutomaticCanvasSize = 2,
            CanvasSize = UDim2.new(1,0,0,0),
            Name = "Tabs"
        })
        util.create("UIListLayout", {
            Parent = tabs
        })

        util.create("TextLabel", {
            Size = UDim2.new(0, width-(icon and 30 or 0), 0, 30),
            Position = UDim2.new(0, icon and 30 or 0, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            TextColor3 = Color3.fromHex("#c0caf5"),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "  " .. title,
            Parent = topbar,
            ZIndex = 3
        })

        -- control buttons

        local close = util.create("TextButton", {
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(1, -20, 0.5, -7.5),
            BackgroundColor3 = Color3.fromHex("#f7768e"),
            Parent = topbar,
            ZIndex = 4,
            Text = ""
        })
        util.roundify(close, 15)
        close.MouseButton1Down:Connect(function()
            root:Destroy()
        end)

        local minimize = util.create("TextButton", {
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(1, -40, 0.5, -7.5),
            BackgroundColor3 = Color3.fromHex("#e0af68"),
            Parent = topbar,
            ZIndex = 4,
            Text = ""
        })
        util.roundify(minimize, 15)
        local minimized = false

        local function toggleMinimize()
            if not minimized then
                minimized = true
                maximizer.Visible = true
                border:TweenSize(UDim2.new(0, 30, 0, 30), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.25, true)
                main.Visible = false
            else
                minimized = false
                maximizer.Visible = false
                border:TweenSize(UDim2.new(0, width + 4, 0, height + 4), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.25, true)
                main.Visible = true
            end
        end

        minimize.MouseButton1Down:Connect(toggleMinimize)
        maximizer.MouseButton1Down:Connect(toggleMinimize)
        return {border, tabs, content}
    end,
    addTab = function(win, title)
        if not
            util.depend(util.isWindow(win), "Can't add a Tab to a non-window.") or not
            util.depend(util.checkTypes({title}, {"string"}), "Tab title must be a string!")
        then return end
        local tab = util.create("ScrollingFrame", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Parent = win[3],
            Position = #win[2]:GetChildren() < 2 and UDim2.new(0,0,0,0) or UDim2.new(0,0,-1,0),
            Name = "Tab",
            ScrollBarThickness = 0,
            BorderSizePixel = 0
        })
        util.create("UIPadding", {
            Parent = tab,
            PaddingLeft = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5)
        })
        task.spawn(function()
            while true do
                local lowest = 0
                for _, category in pairs(tab:GetChildren()) do
                    if not category:IsA("GuiObject") then continue end
                    if category.Position.Y.Offset + category.Size.Y.Offset > lowest then lowest = category.Position.Y.Offset + category.Size.Y.Offset end
                end
                tab.CanvasSize = UDim2.new(0,0,0,lowest + 10)
                task.wait()
            end
        end)

        local tabBtn = util.create("TextButton", {
            Size = UDim2.new(1,0,0,25),
            BackgroundColor3 = #win[2]:GetChildren() < 2 and Color3.fromHex("#24283b") or Color3.fromHex("#1a1b26"),
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            Text = title,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Parent = win[2],
            BorderSizePixel = 0,
        })

        tabBtn.MouseButton1Down:Connect(function()
            if tabBtn.BackgroundColor3 == Color3.fromHex("#24283b") then return end
            for _,v in pairs(win[3]:GetChildren()) do
                if v == tab then continue end
                v:TweenPosition(UDim2.new(0, 0, -1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
            end
            tab.Position = UDim2.new(0,0,1,0)
            tab:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
            for _,v in pairs(win[2]:GetChildren()) do
                if not v:IsA("TextButton") then continue end
                v.BackgroundColor3 = Color3.fromHex("#1a1b26")
            end
            tabBtn.BackgroundColor3 = Color3.fromHex("#24283b")
        end)
        return tab
    end,
    addCategory = function(tab, title)
        if not
            util.depend(tab.Name == "Tab", "Can't add a category to a non-tab.") or not
            util.depend(util.checkTypes({title}, {"string"}), "Category title must be a string!")
        then return end
        local category = util.create("Frame", {
            BackgroundColor3 = Color3.fromHex("#1a1b26"),
            Parent = tab,
            Name = "category",
            Size = UDim2.new(0.5, -5, 0, 25)
        })

        util.roundify(category, 12)

        util.create("TextLabel", {
            Parent = category,
            Size = UDim2.new(1,0,0,20),
            BackgroundTransparency = 1,
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            Text = title,
            TextColor3 = Color3.fromHex("#a9b1d6"),
        })
        util.create("Frame", {
            Parent = category,
            Size = UDim2.new(1,0,0,1),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromHex("#a9b1d6"),
            Position = UDim2.new(0,0,0,20)
        })
        local categoryContent = util.create("ScrollingFrame", {
            Parent = category,
            Size = UDim2.new(1,0,1,-21),
            Position = UDim2.new(0,0,0,21),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        categoryContent.ChildAdded:Connect(function(child)
            if not child:IsA("GuiObject") then return end
            category.Size += UDim2.new(0, 0, 0, child.AbsoluteSize.Y + 5)
        end)
        util.create("UIPadding", {
            Parent = categoryContent,
            PaddingLeft = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5)
        })
        return categoryContent
    end,
    addButton = function(category, text, callback)
        if not
            util.depend(util.isCategory(category), "Can't add a button to non-category") or not
            util.depend(util.checkTypes({text, callback}, {"string", "function"}), "Invalid types passed to carbon.addButton")
        then return end
        local btn = util.create("TextButton", {
            Parent = category,
            BackgroundColor3 = Color3.fromHex("#24283b"),
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            Text = text,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Size = UDim2.new(1, 0, 0, 25),
            AutoButtonColor = false,
            ClipsDescendants = true,
            Position = UDim2.new(0,0,0,util.getPos(category))
        })
        util.roundify(btn, 6)
        btn.MouseButton1Down:Connect(function()
            callback()
            local circleEffect = util.create("Frame", {
                Parent = btn,
                BackgroundColor3 = Color3.new(1,1,1),
                Size = UDim2.new(0,1,0,1),
                Position = UDim2.new(0, mouse.X - btn.AbsolutePosition.X, 0, mouse.Y - btn.AbsolutePosition.Y),
                AnchorPoint = Vector2.new(0.5,0.5)
            })
            util.create("UICorner", {
                Parent = circleEffect,
                CornerRadius = UDim.new(1,0)
            })
            task.spawn(function()
                for i = 0,40 do
                    circleEffect.Size += UDim2.new(0,25,0,25)
                    circleEffect.BackgroundTransparency = i / 40
                    task.wait()
                end
                circleEffect:Destroy()
            end)
        end)
        return btn
    end,
    addToggle = function(category, text, callback)
        if not
            util.depend(util.isCategory(category), "Can't add a toggle to non-category") or not
            util.depend(util.checkTypes({text, callback}, {"string", "function"}), "Invalid types passed to carbon.addToggle")
        then return end
        local toggleBg = util.create("Frame", {
            Parent = category,
            BackgroundColor3 = Color3.fromHex("#24283b"),
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0,0,0,util.getPos(category)),
        })
        util.roundify(toggleBg, 6)
        local toggle = util.create("TextButton", {
            Text = "",
            Parent = toggleBg,
            Size = UDim2.new(0,21,0,21),
            Position = UDim2.new(0,2,0,2),
            BackgroundColor3 = Color3.fromHex("#1a1b26"),
            AutoButtonColor = false
        })
        local toggleDisplay = toggle:Clone()
        toggleDisplay.BackgroundColor3 = Color3.fromRGB(153, 0, 255)
        toggleDisplay.Size = UDim2.new(0,0,0,0)
        toggleDisplay.AnchorPoint = Vector2.new(0.5,0.5)
        toggleDisplay.Position = UDim2.new(0.5,0,0.5,0)
        toggleDisplay.Parent = toggle
        toggleDisplay.Visible = false
        util.roundify(toggle, 6)
        util.roundify(toggleDisplay, 6)
        local txt = util.create("TextLabel", {
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            Text = "  " .. text,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Parent = toggleBg,
            Position = UDim2.new(0,23,0,0),
            Size = UDim2.new(1,-23,1,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local toggeled = false
        local function _toggle()
            if not toggeled then
                toggleDisplay.Visible = true
                toggleDisplay:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)
            else
                toggleDisplay:TweenSize(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)
                task.delay(0.2, function()
                    toggleDisplay.Visible = false
                end)
            end
            toggeled = not toggeled
            callback(toggeled)
        end
        toggle.MouseButton1Down:Connect(_toggle)
        toggleDisplay.MouseButton1Down:Connect(_toggle)
        return toggleBg
    end,
    addSlider = function(category, text, min, max, default, decimalPercision, callback)
        if not
            util.depend(util.isCategory(category), "Can't add a slider to non-category") or not
            util.depend(util.checkTypes({text, min, max, default, decimalPercision, callback}, {"string", "number", "number", "number", "number", "function"}), "Invalid types passed to carbon.addSlider")
        then return end
        decimalPercision = math.clamp(decimalPercision, 0, math.huge)
        local slidereBg = util.create("Frame", {
            Parent = category,
            BackgroundColor3 = Color3.fromHex("#24283b"),
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0,0,0,util.getPos(category)),
        })
        util.roundify(slidereBg, 6)
        local barBg = util.create("TextButton", {
            Text = "",
            Parent = slidereBg,
            Size = UDim2.new(1,-20,0,7),
            Position = UDim2.new(0,10, 1,-19),
            BackgroundColor3 = Color3.fromHex("#1a1b26"),
            AutoButtonColor = false
        })
        local bar = barBg:Clone()
        bar.BackgroundColor3 = Color3.fromRGB(153, 0, 255)
        bar.Position = UDim2.new(0,0,0,0)
        bar.Parent = barBg
        bar.Size = UDim2.new((math.clamp(default, min, max) - min) / (max-min), 0, 1, 0)
        util.roundify(barBg, 12)
        util.roundify(bar, 12)
        util.create("TextLabel", {
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            Text = "  " .. text,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Parent = slidereBg,
            Position = UDim2.new(0,0,0,0),
            Size = UDim2.new(1,0,0.5,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local display = util.create("TextLabel", {
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            Text = tostring(math.clamp(default, min, max)) .. "  ",
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Parent = slidereBg,
            Position = UDim2.new(0,0,0,0),
            Size = UDim2.new(1,0,0.5,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Right
        })
        local dragging = false
        local function beginDrag()
            dragging = true
        end
        local function endDrag()
            dragging = false
        end
        bar.MouseButton1Down:Connect(beginDrag)
        barBg.MouseButton1Down:Connect(beginDrag)
        bar.MouseButton1Up:Connect(endDrag)
        barBg.MouseButton1Up:Connect(endDrag)
        mouse.Button1Up:Connect(endDrag)
        task.spawn(function()
            while true do
                if dragging then
                    local percent = math.clamp((mouse.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                    local value = math.round((percent * (max-min) + min)*(10^decimalPercision))/(10^decimalPercision)
                    display.Text = tostring(value) .. "  "
                    bar.Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)
                    callback(value)
                end
                task.wait()
            end
        end)
        return slidereBg
    end,
    addInput = function(category, text, callback)
        if not
            util.depend(util.isCategory(category), "Can't add an input to non-category") or not
            util.depend(util.checkTypes({text, callback}, {"string", "function"}), "Invalid types passed to carbon.addInput")
        then return end
        local inputBg = util.create("Frame", {
            Parent = category,
            BackgroundColor3 = Color3.fromHex("#24283b"),
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0,0,0,util.getPos(category)),
        })
        util.roundify(inputBg, 6)
        util.create("TextLabel", {
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            Text = "  " .. text,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Parent = inputBg,
            Position = UDim2.new(0,0,0,0),
            Size = UDim2.new(0.5,0,1,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local input = util.create("TextBox", {
            Text = "",
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            ClearTextOnFocus = false,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Parent = inputBg,
            Position = UDim2.new(0.5,-2,0,2),
            Size = UDim2.new(0.5,0,1,-4),
            BackgroundColor3 = Color3.fromHex("#1a1b26"),
            TextXAlignment = Enum.TextXAlignment.Center
        })
        util.roundify(input, 6)
        input.FocusLost:Connect(function()
            callback(input.Text)
        end)
        return inputBg
    end,
    addRGBColorPicker = function(category, text, callback)
        if not
            util.depend(util.isCategory(category), "Can't add a color picker to non-category") or not
            util.depend(util.checkTypes({text, callback}, {"string", "function"}), "Invalid types passed to carbon.addRGBColorPicker")
        then return end
        local bg = util.create("Frame", {
            Parent = category,
            BackgroundColor3 = Color3.fromHex("#24283b"),
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0,0,0,util.getPos(category)),
        })
        util.roundify(bg, 6)
        util.create("TextLabel", {
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            Text = "  " .. text,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Parent = bg,
            Position = UDim2.new(0,0,0,0),
            Size = UDim2.new(0.5,0,1,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local colorBtn = util.create("TextButton", {
            Text = "",
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Parent = bg,
            Position = UDim2.new(1,-23,0,2),
            Size = UDim2.new(0,21,0,21),
            BackgroundColor3 = Color3.fromRGB(255,0,0),
            TextXAlignment = Enum.TextXAlignment.Center
        })
        util.roundify(colorBtn, 6)
        colorBtn.MouseButton1Down:Connect(function()
            if root:FindFirstChild("RGBSelection") then
                root.RGBSelection:Destroy()
            end
            local border = util.create("Frame", {
                Size = UDim2.new(0, 354, 0, 242),
                Position = UDim2.new(0,mouse.X,0,mouse.Y),
                Parent = root,
                ClipsDescendants = true,
                Name = "RGBSelection"
            })
            util.roundify(border, 12)

            local gradient = util.create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 212)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(153, 0, 255))
                }),
                Parent = border,
                Rotation = 45
            })

            task.spawn(function()
                while true do
                    gradient.Rotation += 1
                    task.wait()
                end
            end)
            local selectionWindow = util.create("Frame", {
                Parent = border,
                Size = UDim2.new(1, -4, 1, -4),
                Position = UDim2.new(0, 2, 0, 2),
                BackgroundColor3 = Color3.fromHex("#1a1b26")
            })
            util.roundify(selectionWindow, 12)
            local rgb = util.create("Frame", {
                Parent = selectionWindow,
                Size = UDim2.new(0, 200, 0, 200),
                Position = UDim2.new(0, 10, 0, 10),
                BorderSizePixel = 0
            })
            local seq = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            util.create("UIGradient", {
                Color = seq,
                Parent = rgb,
            })
            local saturation = util.create("Frame", {
                Parent = rgb,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BorderSizePixel = 0
            })
            util.create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                }),
                Parent = saturation,
                Rotation = -90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })
            })
            local value = util.create("Frame", {
                Parent = selectionWindow,
                Size = UDim2.new(0, 21, 0, 200),
                Position = UDim2.new(0, 220, 0, 10),
                BorderSizePixel = 0
            })
            local valueGradient = util.create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                }),
                Parent = value,
                Rotation = 90
            })

            util.create("Frame", {
                Parent = selectionWindow,
                Position = UDim2.new(0, 250, 0, 15),
                Size = UDim2.new(0,90,0,50),
                BackgroundColor3 = colorBtn.BackgroundColor3,
                BorderSizePixel = 0
            })
            local preview = util.create("Frame", {
                Parent = selectionWindow,
                Position = UDim2.new(0, 250, 0, 65),
                Size = UDim2.new(0,90,0,55),
                BackgroundColor3 = Color3.fromRGB(255,0,0),
                BorderSizePixel = 0
            })

            local picker = util.create("Frame", {
                Parent = rgb,
                Size = UDim2.new(0, 4, 0, 4),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(0,0,0),
                BorderSizePixel = 0,
                BackgroundTransparency = 0.3
            })

            local inputHex = util.create("TextBox", {
                Parent = selectionWindow,
                Size = UDim2.new(0, 90, 0, 25),
                Position = UDim2.new(0, 250, 0, 125),
                BackgroundColor3 = Color3.fromHex("#24283b"),
                Text = "",
                Font = Enum.Font.Ubuntu,
                FontSize = Enum.FontSize.Size18,
                TextColor3 = Color3.fromHex("#a9b1d6"),
                PlaceholderText = "#FFFFFF"
            })

            util.roundify(inputHex, 6)

            local r = util.create("TextBox", {
                Parent = selectionWindow,
                Size = UDim2.new(0, 25, 0, 25),
                Position = UDim2.new(0, 250, 0, 155),
                BackgroundColor3 = Color3.fromHex("#24283b"),
                Text = "",
                Font = Enum.Font.Ubuntu,
                FontSize = Enum.FontSize.Size14,
                TextColor3 = Color3.fromHex("#a9b1d6"),
                PlaceholderText = "r"
            })

            util.roundify(r, 6)

            local g = r:Clone()
            g.Parent = selectionWindow
            g.Position += UDim2.new(0, 30, 0, 0)
            g.Size += UDim2.new(0,5,0,0)
            g.PlaceholderText = "g"

            local b = g:Clone()
            b.Parent = selectionWindow
            b.Position += UDim2.new(0, 35, 0, 0)
            b.Size -= UDim2.new(0,5,0,0)
            b.PlaceholderText = "b"

            local h = r:Clone()
            h.Position += UDim2.new(0, 0, 0, 30)
            h.Parent = selectionWindow
            h.PlaceholderText = "h"
            local s = g:Clone()

            s.Position += UDim2.new(0, 0, 0, 30)
            s.Parent = selectionWindow
            s.PlaceholderText = "s"
            local v = b:Clone()

            v.Position += UDim2.new(0, 0, 0, 30)
            v.Parent = selectionWindow
            v.PlaceholderText = "v"

            inputHex.FocusLost:Connect(function()
                preview.BackgroundColor3 = Color3.fromHex(inputHex.Text)
            end)

            r.FocusLost:Connect(function()
                pcall(function()preview.BackgroundColor3 = Color3.fromRGB(r.Text, g.Text or 0, b.Text or 0)end)
            end)

            g.FocusLost:Connect(function()
                pcall(function()preview.BackgroundColor3 = Color3.fromRGB(r.Text or 0, g.Text, b.Text or 0)end)
            end)

            b.FocusLost:Connect(function()
                pcall(function()preview.BackgroundColor3 = Color3.fromRGB(r.Text or 0, g.Text or 0, b.Text)end)
            end)

            h.FocusLost:Connect(function()
                pcall(function()preview.BackgroundColor3 = Color3.fromHSV(h.Text, s.Text or 0, v.Text or 0)end)
            end)

            s.FocusLost:Connect(function()
                pcall(function()preview.BackgroundColor3 = Color3.fromHSV(h.Text or 0, s.Text, v.Text or 0)end)
            end)

            v.FocusLost:Connect(function()
                pcall(function()preview.BackgroundColor3 = Color3.fromHSV(h.Text or 0, s.Text or 0, v.Text)end)
            end)

            local btnConfirm = util.create("TextButton", {
                Parent = selectionWindow,
                Size = UDim2.new(0, 97, 0, 21),
                Position = UDim2.new(0, 10, 1, -24),
                Text = "Confirm",
                Font = Enum.Font.Ubuntu,
                FontSize = Enum.FontSize.Size18,
                TextColor3 = Color3.fromHex("#a9b1d6"),
                BackgroundColor3 = Color3.fromHex("#24283b")
            })

            local btnCancel = util.create("TextButton", {
                Parent = selectionWindow,
                Size = UDim2.new(0, 97, 0, 21),
                Position = UDim2.new(0, 113, 1, -24),
                Text = "Cancel",
                Font = Enum.Font.Ubuntu,
                FontSize = Enum.FontSize.Size18,
                TextColor3 = Color3.fromHex("#a9b1d6"),
                BackgroundColor3 = Color3.fromHex("#24283b")
            })

            util.roundify(btnConfirm, 6)
            util.roundify(btnCancel, 6)

            btnCancel.MouseButton1Down:Connect(function()
                border:Destroy()
            end)
            btnConfirm.MouseButton1Down:Connect(function()
                callback(preview.BackgroundColor3)
                colorBtn.BackgroundColor3 = preview.BackgroundColor3
                border:Destroy()
            end)

            local picking = false
            local pickingValue = false

            local function beginPicking()
                if mouse.X >= rgb.AbsolutePosition.X and mouse.Y >= rgb.AbsolutePosition.Y and mouse.X <= rgb.AbsolutePosition.X + rgb.AbsoluteSize.X and mouse.Y <= rgb.AbsolutePosition.Y + rgb.AbsoluteSize.Y then
                    picking = true
                elseif mouse.X >= value.AbsolutePosition.X and mouse.Y >= value.AbsolutePosition.Y and mouse.X <= value.AbsolutePosition.X + value.AbsoluteSize.X and mouse.Y <= value.AbsolutePosition.Y + value.AbsoluteSize.Y then
                    pickingValue = true
                end
            end
            local function endPicking()
                picking = false
                pickingValue = false
            end

            mouse.Button1Down:Connect(beginPicking)
            mouse.Button1Up:Connect(endPicking)
            local function getColorOnOffset(cs, time)
                if time == 0 then return cs.Keypoints[1].Value end
                if time == 1 then return cs.Keypoints[#cs.Keypoints].Value end
                for i = 1, #cs.Keypoints - 1 do
                    local this = cs.Keypoints[i]
                    local next = cs.Keypoints[i + 1]
                    if time >= this.Time and time < next.Time then
                        local alpha = (time - this.Time) / (next.Time - this.Time)
                        return Color3.new(
                            (next.Value.R - this.Value.R) * alpha + this.Value.R,
                            (next.Value.G - this.Value.G) * alpha + this.Value.G,
                            (next.Value.B - this.Value.B) * alpha + this.Value.B
                        )
                    end
                end
            end
            task.spawn(function()
                while true do
                    if picking then
                        picker.Position = UDim2.new(0, math.clamp(mouse.X - rgb.AbsolutePosition.X, 0, rgb.AbsoluteSize.X), 0, math.clamp(mouse.Y - rgb.AbsolutePosition.Y, 0, rgb.AbsoluteSize.Y))
                        local color = getColorOnOffset(seq, picker.Position.X.Offset / 200)
                        color = Color3.fromRGB(
                            math.clamp(color.R * 255 + picker.Position.Y.Offset / 200 * 255, 0, 255),
                            math.clamp(color.G * 255 + picker.Position.Y.Offset / 200 * 255, 0, 255),
                            math.clamp(color.B * 255 + picker.Position.Y.Offset / 200 * 255, 0, 255)
                        )
                        valueGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, color),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                        })
                        preview.BackgroundColor3 = color
                        r.Text = math.floor(color.R * 255)
                        g.Text = math.floor(color.G * 255)
                        b.Text = math.floor(color.B * 255)
                        local hv, sv, vv = color:ToHSV()
                        h.Text = math.floor(hv * 360)
                        s.Text = math.floor(sv * 100)
                        v.Text = math.floor(vv * 100)
                        inputHex.Text = "#" .. color:ToHex()
                    elseif pickingValue then
                        local color = getColorOnOffset(seq, picker.Position.X.Offset / 200)
                        color = Color3.fromRGB(
                            math.clamp(color.R * 255 + picker.Position.Y.Offset / 200 * 255, 0, 255),
                            math.clamp(color.G * 255 + picker.Position.Y.Offset / 200 * 255, 0, 255),
                            math.clamp(color.B * 255 + picker.Position.Y.Offset / 200 * 255, 0, 255)
                        )
                        local newColor = Color3.new(
                            color.R * (1 - math.clamp(math.clamp(mouse.Y - value.AbsolutePosition.Y, 0, 200) / 200, 0, 1)),
                            color.G * (1 - math.clamp(math.clamp(mouse.Y - value.AbsolutePosition.Y, 0, 200) / 200, 0, 1)),
                            color.B * (1 - math.clamp(math.clamp(mouse.Y - value.AbsolutePosition.Y, 0, 200) / 200, 0, 1))
                        )
                        preview.BackgroundColor3 = newColor
                        r.Text = math.floor(newColor.R * 255)
                        g.Text = math.floor(newColor.G * 255)
                        b.Text = math.floor(newColor.B * 255)
                        local hv, sv, vv = newColor:ToHSV()
                        h.Text = math.floor(hv * 360)
                        s.Text = math.floor(sv * 100)
                        v.Text = math.floor(vv * 100)
                        inputHex.Text = "#" .. newColor:ToHex()
                    end
                    task.wait()
                end
            end)
        end)
        return bg
    end,
    addLabel = function(category, text)
        if not
            util.depend(util.isCategory(category), "Can't add a label to non-category") or not
            util.depend(util.checkTypes({text}, {"string"}), "Invalid types passed to carbon.addLabel")
        then return end
        return util.roundify(util.create("TextLabel", {
            Parent = category,
            BackgroundColor3 = Color3.fromHex("#24283b"),
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            Text = text,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0,0,0,util.getPos(category))
        }), 6)
    end,
    addDropdown = function(category, text, values, default, callback)
        if not
            util.depend(util.isCategory(category), "Can't add a dropdown to non-category") or not
            util.depend(util.checkTypes({text, values, default, callback}, {"string", "table", "string", "function"}), "Invalid types passed to carbon.addDropdown")
        then return end
        local dropdownBg = util.create("Frame", {
            Parent = category,
            BackgroundColor3 = Color3.fromHex("#24283b"),
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0,0,0,util.getPos(category)),
        })
        util.roundify(dropdownBg, 6)
        util.create("TextLabel", {
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            Text = "  " .. text,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Parent = dropdownBg,
            Position = UDim2.new(0,0,0,0),
            Size = UDim2.new(0.5,0,1,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local selectBtn = util.create("TextButton", {
            Text = default, -- Doesn't have to be in the list of values in case it's "none" or something
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Parent = dropdownBg,
            Position = UDim2.new(0.5,-2,0,2),
            Size = UDim2.new(0.5,0,1,-4),
            BackgroundColor3 = Color3.fromHex("#1a1b26"),
            TextXAlignment = Enum.TextXAlignment.Center
        })
        util.roundify(selectBtn, 6)
        local indicator = util.create("TextLabel", {
            Text = "+",
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Size = UDim2.new(0, 25, 0, 25),
            Position = UDim2.new(1,-25,0,0),
            Parent = selectBtn
        })
        selectBtn.MouseButton1Down:Connect(function()
            if root:FindFirstChild(text .. "Sel") then
                root:FindFirstChild(text .. "Sel"):TweenSize(UDim2.new(0, selectBtn.AbsoluteSize.X, 0, 0), Enum.PoseEasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
                task.delay(0.2, function()root:FindFirstChild(text .. "Sel"):Destroy()end)
                indicator.Text = "+"
                return
            end
            indicator.Text = "-"
            local selection = util.create("Frame", {
                Parent = root,
                Size = UDim2.new(0, selectBtn.AbsoluteSize.X, 0, 0),
                Position = UDim2.new(0, selectBtn.AbsolutePosition.X, 0, selectBtn.AbsolutePosition.Y + selectBtn.AbsoluteSize.Y),
                BackgroundColor3 = Color3.fromHex("#24283b"),
                Name = text .. "Sel"
            })
            util.create("UIListLayout", {
                Parent = selection
            })
            util.roundify(selection, 6)
            for i,v in pairs(values) do
                util.create("TextButton", {
                    Parent = selection,
                    Size = UDim2.new(1,0,0,20),
                    Text = tostring(v),
                    Font = Enum.Font.Ubuntu,
                    FontSize = Enum.FontSize.Size18,
                    TextColor3 = Color3.fromHex("#a9b1d6"),
                    BackgroundTransparency = 1
                }).MouseButton1Down:Connect(function()
                    callback(v)
                    selection:Destroy()
                    selectBtn.Text = tostring(v)
                end)
            end
            selection:TweenSize(UDim2.new(0, selectBtn.AbsoluteSize.X, 0, #values * 20), Enum.PoseEasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
        end)
        return dropdownBg
    end,
    addKeybind = function(category, text, callback)
        if not
            util.depend(util.isCategory(category), "Can't add a keybind to non-category") or not
            util.depend(util.checkTypes({text, callback}, {"string", "function"}), "Invalid types passed to carbon.addKeybinds")
        then return end
        local kbBg = util.create("Frame", {
            Parent = category,
            BackgroundColor3 = Color3.fromHex("#24283b"),
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0,0,0,util.getPos(category)),
        })
        util.roundify(kbBg, 6)
        util.create("TextLabel", {
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            Text = "  " .. text,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Parent = kbBg,
            Position = UDim2.new(0,0,0,0),
            Size = UDim2.new(0.5,0,1,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local key = util.create("TextButton", {
            Text = "[ Keybind ]",
            Font = Enum.Font.Ubuntu,
            FontSize = Enum.FontSize.Size18,
            TextColor3 = Color3.fromHex("#a9b1d6"),
            Parent = kbBg,
            Position = UDim2.new(0.5,-2,0,2),
            Size = UDim2.new(0.5,0,1,-4),
            BackgroundColor3 = Color3.fromHex("#1a1b26"),
            TextXAlignment = Enum.TextXAlignment.Center
        })
        util.roundify(key, 6)
        key.MouseButton1Down:Connect(function()
            if settingKeybind then return end
            settingKeybind = true
            key.Text = "[ ... ]"
            bindingFunc = function(k)
                settingKeybind = false
                key.Text = "[ " .. tostring(k.Name) .. " ]"
                handlers[k] = callback
                bindingFunc = function(k) end
            end
        end)
        return kbBg
    end,
    inline = function(oldWidget, newWidget)
        if oldWidget.Parent.Parent.Name ~= "category" then
            warn("Attempt to inline widget to nonwidget!")
            return
        end
        if oldWidget.Size.Y.Offset ~= newWidget.Size.Y.Offset then
            warn("Cannot inline widgets varying in height!")
            return
        end
        if oldWidget.Size.X.Scale ~= 1 then
            warn("Can only inline at most 2 widgets together!")
            return
        end
        oldWidget.Size = UDim2.new(0.5, -3, 0, oldWidget.Size.Y.Offset)
        newWidget.Size = UDim2.new(0.5, -3, 0, newWidget.Size.Y.Offset)
        newWidget.Position = oldWidget.Position + UDim2.new(0.5, 3, 0, 0)
    end
}

if gethui and gethui():FindFirstChild(root.Name) then
    gethui():FindFirstChild(root.Name):Destroy()
elseif game.CoreGui:FindFirstChild(root.Name) then
    game.CoreGui:FindFirstChild(root.Name):Destroy()
end
root.Parent = gethui and gethui() or game.CoreGui

return carbon