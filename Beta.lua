local Library = {}
Library.Registry = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Library:CreateWindow(config)
    config = config.Title or "MelonyUI"
    
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    
    -- Сильно уменьшаем размеры для телефонов
    local windowSize = isMobile and UDim2.fromOffset(380, 240) or UDim2.fromOffset(850, 600)
    
    local Window = {}
    Window.Tabs = {}

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

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = windowSize
    MainFrame.Position = UDim2.new(0.5, -windowSize.X.Offset / 2, 0.5, -windowSize.Y.Offset / 2)
    MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICCorner = Instance.new("UICorner")
    UICCorner.CornerRadius = UDim.new(0, 6)
    UICCorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(30, 30, 35)
    UIStroke.Thickness = 1
    UIStroke.Parent = MainFrame

    -- Принудительное уменьшение через UIScale для мобильных
    if isMobile then
        local uiScale = Instance.new("UIScale")
        uiScale.Scale = 0.75 -- Уменьшаем интерфейс на 25%, чтобы он стал компактным
        uiScale.Parent = MainFrame
    end

    -- Перетаскивание
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
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

    local TabBar = Instance.new("ScrollingFrame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(0, isMobile and 100 or 180, 1, -16)
    TabBar.Position = UDim2.new(0, 8, 0, 8)
    TabBar.BackgroundTransparency = 1
    TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabBar.ScrollBarThickness = 0
    TabBar.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 4)
    UIListLayout.Parent = TabBar

    local ContainerHolder = Instance.new("Frame")
    ContainerHolder.Name = "ContainerHolder"
    ContainerHolder.Size = UDim2.new(1, isMobile and -114 or -210, 1, -16)
    ContainerHolder.Position = UDim2.new(0, isMobile and 110 or 200, 0, 8)
    ContainerHolder.BackgroundTransparency = 1
    ContainerHolder.Parent = MainFrame

    function Window:Tab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName = tabConfig.Title or "Tab"

        local Tab = {}

        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName .. "Button"
        TabButton.Size = UDim2.new(1, 0, 0, isMobile and 26 or 38)
        TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 160)
        TabButton.TextSize = isMobile and 10 or 14
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.Text = " " .. TabName
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
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Size = UDim2.new(0.48, 0, 1, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.ScrollBarThickness = 0
        LeftColumn.Parent = TabPage

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 6)
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
        RightLayout.Padding = UDim.new(0, 6)
        RightLayout.Parent = RightColumn

        function Tab:Section(secConfig)
            secConfig = secConfig or {}
            local SecTitle = secConfig.Title or "Section"
            local Side = secConfig.Side or "Left"

            local ParentColumn = (Side:lower() == "right") and RightColumn or LeftColumn

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = SecTitle .. "Section"
            SectionFrame.Size = UDim2.new(1, 0, 0, 30)
            SectionFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 21)
            SectionFrame.Parent = ParentColumn

            local SecCorner = Instance.new("UICorner")
            SecCorner.CornerRadius = UDim.new(0, 4)
            SecCorner.Parent = SectionFrame

            local SecStroke = Instance.new("UIStroke")
            SecStroke.Color = Color3.fromRGB(28, 28, 35)
            SecStroke.Parent = SectionFrame

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(1, -12, 0, 20)
            TitleLabel.Position = UDim2.new(0, 6, 0, 2)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = SecTitle:upper()
            TitleLabel.TextColor3 = Color3.fromRGB(100, 100, 115)
            TitleLabel.TextSize = isMobile and 8 or 10
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = SectionFrame

            local ContentHolder = Instance.new("Frame")
            ContentHolder.Name = "Content"
            ContentHolder.Size = UDim2.new(1, 0, 1, -22)
            ContentHolder.Position = UDim2.new(0, 0, 0, 22)
            ContentHolder.BackgroundTransparency = 1
            ContentHolder.Parent = SectionFrame

            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Padding = UDim.new(0, 4)
            ContentLayout.Parent = ContentHolder

            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 28)
            end)

            local Section = {}

            function Section:Toggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                local TTitle = toggleConfig.Title or "Toggle"
                local Default = toggleConfig.Default or false
                local Callback = toggleConfig.Callback or function() end

                local State = Default

                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(1, 0, 0, isMobile and 18 or 22)
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Text = ""
                ToggleButton.Parent = ContentHolder

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -28, 1, 0)
                Label.Position = UDim2.new(0, 6, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = TTitle
                Label.TextColor3 = Color3.fromRGB(200, 200, 210)
                Label.TextSize = isMobile and 10 or 12
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ToggleButton

                local Box = Instance.new("Frame")
                Box.Size = UDim2.fromOffset(isMobile and 12 or 14, isMobile and 12 or 14)
                Box.Position = UDim2.new(1, isMobile and -18 or -20, 0.5, isMobile and -6 or -7)
                Box.BackgroundColor3 = State and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(25, 25, 30)
                Box.Parent = ToggleButton

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 3)
                BoxCorner.Parent = Box

                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = State and Color3.fromRGB(80, 140, 255) or Color3.fromRGB(45, 45, 55)
                BoxStroke.Parent = Box

                local function UpdateState()
                    Box.BackgroundColor3 = State and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(25, 25, 30)
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
