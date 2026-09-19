--[[
    MelonyUI (Neverlose-style) — Beta.lua
    Полная библиотека: Window -> Tab -> Section(Left/Right) -> Toggle/Slider/Dropdown/TextBox/Button

    Использование:
        local Library = loadstring(game:HttpGet("URL_К_ЭТОМУ_ФАЙЛУ"))()
        local Window = Library:CreateWindow({ Title = "My Hub" })
        local Tab = Window:Tab({ Title = "Main" })
        local Section = Tab:Section({ Title = "Settings", Side = "Left" })
        Section:Toggle({ Title = "Example", Default = false, Callback = function(v) end })
--]]

local Library = {}
Library.Registry = {}

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

function Library:CreateWindow(config)
    config = config or {}
    local ToggleImageId = config.Image or Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size42x42)

    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local windowSize = isMobile and UDim2.fromOffset(500, 310) or (config.Size or UDim2.fromOffset(750, 480))

    local Window = {}
    Window.Tabs = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MelonyUI_Neverlose"
    ScreenGui.ResetOnSpawn = false

    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Плавающая круглая кнопка для открытия/закрытия
    local ToggleButtonUI = Instance.new("ImageButton")
    ToggleButtonUI.Name = "ToggleMenuButton"
    ToggleButtonUI.Size = UDim2.fromOffset(45, 45)
    ToggleButtonUI.Position = UDim2.new(0, 30, 0, 100)
    ToggleButtonUI.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
    ToggleButtonUI.Image = ToggleImageId
    ToggleButtonUI.AutoButtonColor = false
    ToggleButtonUI.Parent = ScreenGui

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleButtonUI

    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Color3.fromRGB(60, 120, 255)
    ToggleStroke.Thickness = 1.5
    ToggleStroke.Parent = ToggleButtonUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = windowSize
    MainFrame.Position = UDim2.new(0.5, -windowSize.X.Offset / 2, 0.5, -windowSize.Y.Offset / 2)
    MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local menuVisible = true
    ToggleButtonUI.MouseButton1Click:Connect(function()
        menuVisible = not menuVisible
        MainFrame.Visible = menuVisible
    end)

    -- Перетаскивание круглой кнопки
    local btnDragging, btnDragStart, btnStartPos
    ToggleButtonUI.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            btnDragging = true
            btnDragStart = input.Position
            btnStartPos = ToggleButtonUI.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - btnDragStart
            ToggleButtonUI.Position = UDim2.new(
                btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
                btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            btnDragging = false
        end
    end)

    local UICCorner = Instance.new("UICorner")
    UICCorner.CornerRadius = UDim.new(0, 6)
    UICCorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(30, 30, 35)
    UIStroke.Thickness = 1
    UIStroke.Parent = MainFrame

    -- Перетаскивание ТОЛЬКО за верхнюю шапку
    local TopBarDrag = Instance.new("Frame")
    TopBarDrag.Name = "TopBarDrag"
    TopBarDrag.Size = UDim2.new(1, 0, 0, 30)
    TopBarDrag.BackgroundTransparency = 1
    TopBarDrag.Parent = MainFrame

    local dragging, dragStart, startPos
    TopBarDrag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Левая панель вкладок
    local TabBar = Instance.new("ScrollingFrame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(0, 150, 1, -75)
    TabBar.Position = UDim2.new(0, 10, 0, 10)
    TabBar.BackgroundTransparency = 1
    TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabBar.ScrollBarThickness = 0
    TabBar.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = TabBar

    -- Профиль игрока внизу левой панели
    local UserProfileFrame = Instance.new("Frame")
    UserProfileFrame.Size = UDim2.new(0, 150, 0, 50)
    UserProfileFrame.Position = UDim2.new(0, 10, 1, -60)
    UserProfileFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
    UserProfileFrame.Parent = MainFrame

    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(0, 6)
    ProfileCorner.Parent = UserProfileFrame

    local ProfileStroke = Instance.new("UIStroke")
    ProfileStroke.Color = Color3.fromRGB(28, 28, 35)
    ProfileStroke.Parent = UserProfileFrame

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Size = UDim2.fromOffset(32, 32)
    AvatarImage.Position = UDim2.new(0, 8, 0.5, -16)
    AvatarImage.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    AvatarImage.Image = ToggleImageId
    AvatarImage.Parent = UserProfileFrame

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(0, 4)
    AvatarCorner.Parent = AvatarImage

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -48, 0, 16)
    NameLabel.Position = UDim2.new(0, 46, 0, 9)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = LocalPlayer.Name
    NameLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    NameLabel.TextSize = 11
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = UserProfileFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -48, 0, 14)
    StatusLabel.Position = UDim2.new(0, 46, 0, 25)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Neverlose"
    StatusLabel.TextColor3 = Color3.fromRGB(100, 100, 115)
    StatusLabel.TextSize = 9
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = UserProfileFrame

    local ContainerHolder = Instance.new("Frame")
    ContainerHolder.Size = UDim2.new(1, -175, 1, -20)
    ContainerHolder.Position = UDim2.new(0, 165, 0, 10)
    ContainerHolder.BackgroundTransparency = 1
    ContainerHolder.Parent = MainFrame

    function Window:Tab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName = tabConfig.Title or "Tab"
        local Tab = {}

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 160)
        TabButton.TextSize = 12
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.Text = "   " .. TabName
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabBar

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabButton

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 2
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.Parent = ContainerHolder

        TabButton.MouseButton1Click:Connect(function()
            for _, otherTab in pairs(Window.Tabs) do
                otherTab.Page.Visible = false
                otherTab.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
                otherTab.Button.TextColor3 = Color3.fromRGB(150, 150, 160)
            end
            TabPage.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        if #Window.Tabs == 0 then
            TabPage.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        table.insert(Window.Tabs, { Button = TabButton, Page = TabPage })

        local LeftColumn = Instance.new("ScrollingFrame")
        LeftColumn.Size = UDim2.new(0.48, 0, 1, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.ScrollBarThickness = 2
        LeftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
        LeftColumn.Parent = TabPage

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 6)
        LeftLayout.Parent = LeftColumn
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            LeftColumn.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 10)
        end)

        local RightColumn = Instance.new("ScrollingFrame")
        RightColumn.Size = UDim2.new(0.48, 0, 1, 0)
        RightColumn.Position = UDim2.new(0.52, 0, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.ScrollBarThickness = 2
        RightColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
        RightColumn.Parent = TabPage

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 6)
        RightLayout.Parent = RightColumn
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            RightColumn.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 10)
        end)

        function Tab:Section(secConfig)
            secConfig = secConfig or {}
            local SecTitle = secConfig.Title or "Section"
            local Side = secConfig.Side or "Left"
            local ParentColumn = (Side:lower() == "right") and RightColumn or LeftColumn

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, 0, 0, 35)
            SectionFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
            SectionFrame.Parent = ParentColumn

            local SecCorner = Instance.new("UICorner")
            SecCorner.CornerRadius = UDim.new(0, 4)
            SecCorner.Parent = SectionFrame

            local SecStroke = Instance.new("UIStroke")
            SecStroke.Color = Color3.fromRGB(28, 28, 35)
            SecStroke.Parent = SectionFrame

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(1, -16, 0, 22)
            TitleLabel.Position = UDim2.new(0, 8, 0, 4)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = SecTitle:upper()
            TitleLabel.TextColor3 = Color3.fromRGB(100, 100, 115)
            TitleLabel.TextSize = 9
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = SectionFrame

            local ContentHolder = Instance.new("Frame")
            ContentHolder.Size = UDim2.new(1, 0, 1, -26)
            ContentHolder.Position = UDim2.new(0, 0, 0, 26)
            ContentHolder.BackgroundTransparency = 1
            ContentHolder.Parent = SectionFrame

            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Padding = UDim.new(0, 4)
            ContentLayout.Parent = ContentHolder
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 32)
            end)

            local Section = {}

            -- ============================== TOGGLE ==============================
            function Section:Toggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                local TTitle = toggleConfig.Title or "Toggle"
                local Default = toggleConfig.Default or false
                local Callback = toggleConfig.Callback or function() end
                local State = Default

                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(1, 0, 0, 24)
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Text = ""
                ToggleButton.Parent = ContentHolder

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -30, 1, 0)
                Label.Position = UDim2.new(0, 8, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = TTitle
                Label.TextColor3 = Color3.fromRGB(200, 200, 210)
                Label.TextSize = 11
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ToggleButton

                local Box = Instance.new("Frame")
                Box.Size = UDim2.fromOffset(14, 14)
                Box.Position = UDim2.new(1, -22, 0.5, -7)
                Box.BackgroundColor3 = State and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(25, 25, 30)
                Box.Parent = ToggleButton

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 3)
                BoxCorner.Parent = Box

                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = State and Color3.fromRGB(80, 140, 255) or Color3.fromRGB(45, 45, 55)
                BoxStroke.Parent = Box

                ToggleButton.MouseButton1Click:Connect(function()
                    State = not State
                    Box.BackgroundColor3 = State and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(25, 25, 30)
                    BoxStroke.Color = State and Color3.fromRGB(80, 140, 255) or Color3.fromRGB(45, 45, 55)
                    task.spawn(function() pcall(Callback, State) end)
                end)

                local ToggleObject = {}
                function ToggleObject:Set(newState)
                    State = newState
                    Box.BackgroundColor3 = State and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(25, 25, 30)
                    BoxStroke.Color = State and Color3.fromRGB(80, 140, 255) or Color3.fromRGB(45, 45, 55)
                end
                return ToggleObject
            end

            -- ============================== SLIDER ==============================
            function Section:Slider(sliderConfig)
                sliderConfig = sliderConfig or {}
                local STitle = sliderConfig.Title or "Slider"
                local Min = sliderConfig.Min or 0
                local Max = sliderConfig.Max or 100
                local Rounding = sliderConfig.Rounding or 0
                local Suffix = sliderConfig.Suffix or ""
                local Callback = sliderConfig.Callback or function() end

                local function round(v)
                    local mult = 10 ^ Rounding
                    return math.floor(v * mult + 0.5) / mult
                end

                local Value = round(math.clamp(sliderConfig.Default or Min, Min, Max))

                local Holder = Instance.new("Frame")
                Holder.Size = UDim2.new(1, 0, 0, 40)
                Holder.BackgroundTransparency = 1
                Holder.Parent = ContentHolder

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -16, 0, 16)
                Label.Position = UDim2.new(0, 8, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = STitle
                Label.TextColor3 = Color3.fromRGB(200, 200, 210)
                Label.TextSize = 11
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Holder

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0, 70, 0, 16)
                ValueLabel.Position = UDim2.new(1, -78, 0, 0)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(Value) .. Suffix
                ValueLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
                ValueLabel.TextSize = 10
                ValueLabel.Font = Enum.Font.GothamMedium
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = Holder

                local Track = Instance.new("Frame")
                Track.Size = UDim2.new(1, -16, 0, 6)
                Track.Position = UDim2.new(0, 8, 0, 24)
                Track.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                Track.Parent = Holder

                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(1, 0)
                TrackCorner.Parent = Track

                local TrackStroke = Instance.new("UIStroke")
                TrackStroke.Color = Color3.fromRGB(45, 45, 55)
                TrackStroke.Parent = Track

                local startPercent = (Value - Min) / (Max - Min)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(startPercent, 0, 1, 0)
                Fill.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
                Fill.BorderSizePixel = 0
                Fill.ZIndex = 2
                Fill.Parent = Track

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = Fill

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.fromOffset(10, 10)
                Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Knob.Position = UDim2.new(startPercent, 0, 0.5, 0)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.ZIndex = 3
                Knob.Parent = Track

                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = Knob

                local dragging = false

                local function updateFromInput(input)
                    local relative = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local newValue = round(Min + (Max - Min) * relative)
                    if newValue ~= Value then
                        Value = newValue
                        task.spawn(function() pcall(Callback, Value) end)
                    end
                    local percent = (Value - Min) / (Max - Min)
                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                    Knob.Position = UDim2.new(percent, 0, 0.5, 0)
                    ValueLabel.Text = tostring(Value) .. Suffix
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateFromInput(input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateFromInput(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                local SliderObject = {}
                function SliderObject:Set(newValue)
                    Value = round(math.clamp(newValue, Min, Max))
                    local percent = (Value - Min) / (Max - Min)
                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                    Knob.Position = UDim2.new(percent, 0, 0.5, 0)
                    ValueLabel.Text = tostring(Value) .. Suffix
                end

                task.spawn(function() pcall(Callback, Value) end)
                return SliderObject
            end

            -- ============================= DROPDOWN =============================
            function Section:Dropdown(dropConfig)
                dropConfig = dropConfig or {}
                local DTitle = dropConfig.Title or "Dropdown"
                local Options = dropConfig.Options or {}
                local Selected = dropConfig.Default or Options[1]
                local Callback = dropConfig.Callback or function() end
                local Open = false

                local Holder = Instance.new("Frame")
                Holder.Size = UDim2.new(1, 0, 0, 24)
                Holder.BackgroundTransparency = 1
                Holder.ClipsDescendants = false
                Holder.Parent = ContentHolder

                local DropButton = Instance.new("TextButton")
                DropButton.Size = UDim2.new(1, 0, 0, 24)
                DropButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                DropButton.Text = ""
                DropButton.AutoButtonColor = false
                DropButton.ZIndex = 2
                DropButton.Parent = Holder

                local DropCorner = Instance.new("UICorner")
                DropCorner.CornerRadius = UDim.new(0, 4)
                DropCorner.Parent = DropButton

                local DropStroke = Instance.new("UIStroke")
                DropStroke.Color = Color3.fromRGB(45, 45, 55)
                DropStroke.Parent = DropButton

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.55, 0, 1, 0)
                Label.Position = UDim2.new(0, 8, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = DTitle
                Label.TextColor3 = Color3.fromRGB(150, 150, 160)
                Label.TextSize = 11
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 2
                Label.Parent = DropButton

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0.45, -20, 1, 0)
                ValueLabel.Position = UDim2.new(0.55, 0, 0, 0)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(Selected or "None")
                ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
                ValueLabel.TextSize = 11
                ValueLabel.Font = Enum.Font.GothamMedium
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.ZIndex = 2
                ValueLabel.Parent = DropButton

                local Arrow = Instance.new("TextLabel")
                Arrow.Size = UDim2.fromOffset(16, 16)
                Arrow.Position = UDim2.new(1, -20, 0.5, -8)
                Arrow.BackgroundTransparency = 1
                Arrow.Text = "▾"
                Arrow.TextColor3 = Color3.fromRGB(150, 150, 160)
                Arrow.TextSize = 12
                Arrow.ZIndex = 2
                Arrow.Parent = DropButton

                local ListFrame = Instance.new("Frame")
                ListFrame.Size = UDim2.new(1, 0, 0, math.clamp(#Options, 1, 5) * 22 + 6)
                ListFrame.Position = UDim2.new(0, 0, 1, 4)
                ListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
                ListFrame.Visible = false
                ListFrame.ZIndex = 10
                ListFrame.Parent = Holder

                local ListCorner = Instance.new("UICorner")
                ListCorner.CornerRadius = UDim.new(0, 4)
                ListCorner.Parent = ListFrame

                local ListStroke = Instance.new("UIStroke")
                ListStroke.Color = Color3.fromRGB(45, 45, 55)
                ListStroke.Parent = ListFrame

                local ListScroll = Instance.new("ScrollingFrame")
                ListScroll.Size = UDim2.new(1, -6, 1, -6)
                ListScroll.Position = UDim2.new(0, 3, 0, 3)
                ListScroll.BackgroundTransparency = 1
                ListScroll.ScrollBarThickness = 2
                ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                ListScroll.ZIndex = 10
                ListScroll.Parent = ListFrame

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.Parent = ListScroll
                ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ListScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
                end)

                local function closeList()
                    Open = false
                    ListFrame.Visible = false
                    Holder.Size = UDim2.new(1, 0, 0, 24)
                end

                local function openList()
                    Open = true
                    ListFrame.Visible = true
                    Holder.Size = UDim2.new(1, 0, 0, 24 + ListFrame.Size.Y.Offset + 4)
                end

                local function refreshOptions()
                    for _, child in ipairs(ListScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    for _, option in ipairs(Options) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Size = UDim2.new(1, 0, 0, 20)
                        OptionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                        OptionButton.BackgroundTransparency = (option == Selected) and 0 or 1
                        OptionButton.Text = tostring(option)
                        OptionButton.TextColor3 = Color3.fromRGB(200, 200, 210)
                        OptionButton.TextSize = 10
                        OptionButton.Font = Enum.Font.Gotham
                        OptionButton.AutoButtonColor = false
                        OptionButton.ZIndex = 11
                        OptionButton.Parent = ListScroll

                        local OptCorner = Instance.new("UICorner")
                        OptCorner.CornerRadius = UDim.new(0, 3)
                        OptCorner.Parent = OptionButton

                        OptionButton.MouseButton1Click:Connect(function()
                            Selected = option
                            ValueLabel.Text = tostring(Selected)
                            closeList()
                            task.spawn(function() pcall(Callback, Selected) end)
                        end)
                    end
                end

                refreshOptions()

                DropButton.MouseButton1Click:Connect(function()
                    if Open then closeList() else openList() end
                end)

                local DropdownObject = {}
                function DropdownObject:Refresh(newOptions)
                    Options = newOptions or {}
                    refreshOptions()
                end
                function DropdownObject:Set(option)
                    Selected = option
                    ValueLabel.Text = tostring(Selected)
                end

                if Selected ~= nil then
                    task.spawn(function() pcall(Callback, Selected) end)
                end

                return DropdownObject
            end

            -- ============================= TEXTBOX =============================
            function Section:TextBox(boxConfig)
                boxConfig = boxConfig or {}
                local BTitle = boxConfig.Title or "Input"
                local Placeholder = boxConfig.Placeholder or "..."
                local Default = boxConfig.Default or ""
                local ClearOnFocus = boxConfig.ClearOnFocus or false
                local Callback = boxConfig.Callback or function() end

                local Holder = Instance.new("Frame")
                Holder.Size = UDim2.new(1, 0, 0, 40)
                Holder.BackgroundTransparency = 1
                Holder.Parent = ContentHolder

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -16, 0, 14)
                Label.Position = UDim2.new(0, 8, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = BTitle:upper()
                Label.TextColor3 = Color3.fromRGB(100, 100, 115)
                Label.TextSize = 9
                Label.Font = Enum.Font.GothamBold
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Holder

                local InputFrame = Instance.new("Frame")
                InputFrame.Size = UDim2.new(1, -16, 0, 22)
                InputFrame.Position = UDim2.new(0, 8, 0, 16)
                InputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                InputFrame.Parent = Holder

                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 4)
                InputCorner.Parent = InputFrame

                local InputStroke = Instance.new("UIStroke")
                InputStroke.Color = Color3.fromRGB(45, 45, 55)
                InputStroke.Parent = InputFrame

                local TextInput = Instance.new("TextBox")
                TextInput.Size = UDim2.new(1, -12, 1, 0)
                TextInput.Position = UDim2.new(0, 6, 0, 0)
                TextInput.BackgroundTransparency = 1
                TextInput.Text = Default
                TextInput.PlaceholderText = Placeholder
                TextInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
                TextInput.TextColor3 = Color3.fromRGB(200, 200, 210)
                TextInput.TextSize = 11
                TextInput.Font = Enum.Font.Gotham
                TextInput.TextXAlignment = Enum.TextXAlignment.Left
                TextInput.ClearTextOnFocus = ClearOnFocus
                TextInput.Parent = InputFrame

                TextInput.Focused:Connect(function()
                    InputStroke.Color = Color3.fromRGB(80, 140, 255)
                end)

                TextInput.FocusLost:Connect(function(enterPressed)
                    InputStroke.Color = Color3.fromRGB(45, 45, 55)
                    task.spawn(function() pcall(Callback, TextInput.Text, enterPressed) end)
                end)

                local TextBoxObject = {}
                function TextBoxObject:Set(text)
                    TextInput.Text = text
                end
                function TextBoxObject:Get()
                    return TextInput.Text
                end

                return TextBoxObject
            end

            -- ============================== BUTTON ==============================
            function Section:Button(btnConfig)
                btnConfig = btnConfig or {}
                local BTitle = btnConfig.Title or "Button"
                local Callback = btnConfig.Callback or function() end

                local ActionButton = Instance.new("TextButton")
                ActionButton.Size = UDim2.new(1, 0, 0, 26)
                ActionButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                ActionButton.Text = BTitle
                ActionButton.TextColor3 = Color3.fromRGB(220, 220, 230)
                ActionButton.TextSize = 11
                ActionButton.Font = Enum.Font.GothamMedium
                ActionButton.AutoButtonColor = false
                ActionButton.Parent = ContentHolder

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 4)
                BtnCorner.Parent = ActionButton

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Color3.fromRGB(45, 45, 55)
                BtnStroke.Parent = ActionButton

                ActionButton.MouseEnter:Connect(function()
                    TweenService:Create(ActionButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
                    TweenService:Create(BtnStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(80, 140, 255)}):Play()
                end)

                ActionButton.MouseLeave:Connect(function()
                    TweenService:Create(ActionButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
                    TweenService:Create(BtnStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(45, 45, 55)}):Play()
                end)

                ActionButton.MouseButton1Click:Connect(function()
                    TweenService:Create(ActionButton, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(60, 120, 255)}):Play()
                    task.delay(0.12, function()
                        TweenService:Create(ActionButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
                    end)
                    task.spawn(function() pcall(Callback) end)
                end)

                return ActionButton
            end

            return Section
        end
        return Tab
    end

    return Window
end

return Library
