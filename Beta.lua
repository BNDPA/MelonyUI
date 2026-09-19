local Library = {}
Library.Registry = {}

-- Сервисы
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Library:CreateWindow(config)
    config = config or {}
    local WindowName = config.Title or "MelonyUI"
    
    -- Определяем, играет ли пользователь с телефона/планшета
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    
    -- Автоматический выбор размера в зависимости от платформы
    local windowSize = isMobile and UDim2.fromOffset(460, 280) or (config.Size or UDim2.fromOffset(850, 600))
    
    local Window = {}
    Window.Tabs = {}

    -- Главный ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MelonyUI_Neverlose"
    ScreenGui.ResetOnSpawn = false
    
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        pcall(function()
            ScreenGui.Parent = CoreGui
        end)
    end
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Главное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = windowSize
    MainFrame.Position = UDim2.new(0.5, -windowSize.X.Offset / 2, 0.5, -windowSize.Y.Offset / 2)
    MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 15) -- Neverlose Dark Theme
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICCorner = Instance.new("UICorner")
    UICCorner.CornerRadius = UDim.new(0, 6)
    UICCorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(30, 30, 35)
    UIStroke.Thickness = 1
    UIStroke.Parent = MainFrame

    -- Масштабирование элементов интерфейса для телефонов
    if isMobile then
        local uiScale = Instance.new("UIScale")
        uiScale.Scale = 0.85 -- Компактный масштаб для мобильных экранов
        uiScale.Parent = MainFrame
    end

    -- Перетаскивание окна (поддерживает и мышь, и пальцы на мобильных)
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
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

    -- Левая панель вкладок
    local TabBar = Instance.new("ScrollingFrame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(0, isMobile ? 130 : 180, 1, -20)
    TabBar.Position = UDim2.new(0, 10, 0, 10)
    TabBar.BackgroundTransparency = 1
    TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabBar.ScrollBarThickness = 0
    TabBar.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)
    UIListLayout.Parent = TabBar

    -- Контейнер для страниц
    local ContainerHolder = Instance.new("Frame")
    ContainerHolder.Name = "ContainerHolder"
    ContainerHolder.Size = UDim2.new(1, isMobile ? -150 : -210, 1, -20)
    ContainerHolder.Position = UDim2.new(0, isMobile ? 145 : 200, 0, 10)
    ContainerHolder.BackgroundTransparency = 1
    ContainerHolder.Parent = MainFrame

    -- Функция создания вкладки (Tab)
    function Window:Tab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName = tabConfig.Title or "Tab"

        local Tab = {}

        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName .. "Button"
        TabButton.Size = UDim2.new(1, 0, 0, isMobile ? 32 : 38)
        TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 160)
        TabButton.TextSize = isMobile and 12 or 14
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.Text = "   " .. TabName
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabBar

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabButton

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = TabName .. "Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 2
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.Parent = ContainerHolder

        TabButton.MouseButton1Click:Connect(function()
            for _, otherTab in pairs(Window.Tabs) do
                otherTab.Page.Visible = false
                TweenService:Create(otherTab.Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(20, 20, 24),
                    TextColor3 = Color3.fromRGB(150, 150, 160)
                }):Play()
            end
            TabPage.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 40),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end)

        if #Window.Tabs == 0 then
            TabPage.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        table.insert(Window.Tabs, { Button = TabButton, Page = TabPage })

        -- Колонки (Левая и Правая)
        local LeftColumn = Instance.new("ScrollingFrame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Size = UDim2.new(0.48, 0, 1, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.ScrollBarThickness = 0
        LeftColumn.Parent = TabPage

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 8)
        LeftLayout.Parent = LeftColumn

        local RightColumn = Instance.new("ScrollingFrame")
        RightColumn.Name = "RightColumn"
        RightColumn.Size = UDim2.new(0.48, 0, 1, 0)
        RightColumn.Position = UDim2.new(0.52, 0, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.ScrollBarThickness = 0
        RightColumn.Parent = TabPage

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 8)
        RightLayout.Parent = RightColumn

        -- Функция создания Секции (Section)
        function Tab:Section(secConfig)
            secConfig = secConfig or {}
            local SecTitle = secConfig.Title or "Section"
            local Side = secConfig.Side or "Left"

            local ParentColumn = (Side:lower() == "right") and RightColumn or LeftColumn

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = SecTitle .. "Section"
            SectionFrame.Size = UDim2.new(1, 0, 0, 40)
            SectionFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
            SectionFrame.Parent = ParentColumn

            local SecCorner = Instance.new("UICorner")
            SecCorner.CornerRadius = UDim.new(0, 4)
            SecCorner.Parent = SectionFrame

            local SecStroke = Instance.new("UIStroke")
            SecStroke.Color = Color3.fromRGB(28, 28, 35)
            SecStroke.Parent = SectionFrame

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(1, -16, 0, 26)
            TitleLabel.Position = UDim2.new(0, 8, 0, 4)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = SecTitle:upper()
            TitleLabel.TextColor3 = Color3.fromRGB(100, 100, 115)
            TitleLabel.TextSize = isMobile and 9 or 11
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = SectionFrame

            local ContentHolder = Instance.new("Frame")
            ContentHolder.Name = "Content"
            ContentHolder.Size = UDim2.new(1, 0, 1, -30)
            ContentHolder.Position = UDim2.new(0, 0, 0, 30)
            ContentHolder.BackgroundTransparency = 1
            ContentHolder.Parent = SectionFrame

            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Padding = UDim.new(0, 6)
            ContentLayout.Parent = ContentHolder

            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 38)
            end)

            local Section = {}

            -- Создание Тумблера (Toggle)
            function Section:Toggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                local TTitle = toggleConfig.Title or "Toggle"
                local Default = toggleConfig.Default or false
                local Callback = toggleConfig.Callback or function() end

                local State = Default

                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(1, 0, 0, isMobile and 20 or 24)
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Text = ""
                ToggleButton.Parent = ContentHolder

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -35, 1, 0)
                Label.Position = UDim2.new(0, 8, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = TTitle
                Label.TextColor3 = Color3.fromRGB(200, 200, 210)
                Label.TextSize = isMobile and 11 or 13
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ToggleButton

                local Box = Instance.new("Frame")
                Box.Size = UDim2.fromOffset(isMobile and 14 or 16, isMobile and 14 or 16)
                Box.Position = UDim2.new(1, isMobile and -22 or -24, 0.5, isMobile and -7 or -8)
                Box.BackgroundColor3 = State and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(25, 25, 30)
                Box.Parent = ToggleButton

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 3)
                BoxCorner.Parent = Box

                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = State and Color3.fromRGB(80, 140, 255) or Color3.fromRGB(45, 45, 55)
                BoxStroke.Parent = Box

                local function UpdateState()
                    TweenService:Create(Box, TweenInfo.new(0.15), {
                        BackgroundColor3 = State and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(25, 25, 30)
                    }):Play()
                    BoxStroke.Color = State and Color3.fromRGB(80, 140, 255) or Color3.fromRGB(45, 45, 55)
                    task.spawn(function()
                        pcall(Callback, State)
                    end)
                end

                ToggleButton.MouseButton1Click:Connect(function()
                    State = not State
                    UpdateState()
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Library

