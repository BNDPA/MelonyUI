--[[
    Title: Comprehensive Menu Library (Lua)
    Description: Общая библиотека для управления меню, вкладками, табами, системой уведомлений, темами и конфигурациями.
]]

local MenuLib = {}
MenuLib.__index = MenuLib

-- Хранилище состояния, активных вкладок и конфигураций
MenuLib.Flags = {}
MenuLib.ActiveWindow = nil
MenuLib.ActiveTab = nil
MenuLib.NotificationsList = {}

MenuLib.Theme = {
    Text = Color3.fromRGB(255, 255, 255),
    Background = Color3.fromRGB(15, 15, 15),
    SecondaryBackground = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(0, 181, 6),
    Outline = Color3.fromRGB(40, 40, 40)
}

-- =========================================================================
-- 1. УПРАВЛЕНИЕ ОКНАМИ И ВКЛАДКАМИ (WINDOWS & TABS)
-- =========================================================================

function MenuLib.CreateWindow(config)
    config = config or {}
    local window = {
        Title = config.Title or "Menu Library",
        Size = config.Size or UDim2.new(0, 500, 0, 400),
        Tabs = {},
        CurrentTab = nil
    }
    
    MenuLib.ActiveWindow = window
    return window
end

function MenuLib.CreateTab(window, tabName)
    local tab = {
        Name = tabName or "Tab",
        Sections = {},
        ParentWindow = window
    }
    
    table.insert(window.Tabs, tab)
    if not window.CurrentTab then
        window.CurrentTab = tab
    end
    
    return tab
end

function MenuLib.CreateSection(tab, sectionName)
    local section = {
        Name = sectionName or "Section",
        Items = {},
        ParentTab = tab
    }
    
    table.insert(tab.Sections, section)
    return section
end

-- =========================================================================
-- 2. СИСТЕМА УВЕДОМЛЕНИЙ И СООБЩЕНИЙ (NOTIFICATIONS / MESSAGES)
-- =========================================================================

function MenuLib.SendNotification(title, text, duration)
    local notification = {
        Title = title or "Notification",
        Text = text or "",
        Duration = duration or 3,
        Timestamp = tick()
    }
    
    table.insert(MenuLib.NotificationsList, notification)
    
    -- Пример логики вывода сообщения в чат/консоль или интерфейс
    print(string.format("[MenuLib] [%s]: %s", notification.Title, notification.Text))
    
    -- Автоматическое удаление по истечении времени (упрощенно)
    task.delay(notification.Duration, function()
        for i, notif in ipairs(MenuLib.NotificationsList) do
            if notif == notification then
                table.remove(MenuLib.NotificationsList, i)
                break
            end
        end
    end)
    
    return notification
end

-- =========================================================================
-- 3. ЭЛЕМЕНТЫ ИНТЕРФЕЙСА (UI COMPONENTS)
-- =========================================================================

-- Переключатель (Toggle)
function MenuLib.CreateToggle(section, data)
    data = data or {}
    local toggle = {
        Name = data.Name or "Toggle",
        State = data.Default or false,
        Flag = data.Flag or ("Toggle_" .. math.random(1000, 9999)),
        Callback = data.Callback or function() end
    }
    
    MenuLib.Flags[toggle.Flag] = toggle.State
    table.insert(section.Items, toggle)
    
    function toggle:Set(state)
        self.State = state
        MenuLib.Flags[self.Flag] = state
        success, err = pcall(self.Callback, state)
    end
    
    return toggle
end

-- Слайдер (Slider)
function MenuLib.CreateSlider(section, data)
    data = data or {}
    local slider = {
        Name = data.Name or "Slider",
        Min = data.Min or 0,
        Max = data.Max or 100,
        Value = data.Default or 50,
        Flag = data.Flag or ("Slider_" .. math.random(1000, 9999)),
        Callback = data.Callback or function() end
    }
    
    MenuLib.Flags[slider.Flag] = slider.Value
    table.insert(section.Items, slider)
    
    function slider:Set(val)
        self.Value = math.clamp(val, self.Min, self.Max)
        MenuLib.Flags[self.Flag] = self.Value
        pcall(self.Callback, self.Value)
    end
    
    return slider
end

-- Выпадающий список (Dropdown)
function MenuLib.CreateDropdown(section, data)
    data = data or {}
    local dropdown = {
        Name = data.Name or "Dropdown",
        Items = data.Items or {},
        Value = data.Default or (data.Items and data.Items[1]) or "",
        Flag = data.Flag or ("Dropdown_" .. math.random(1000, 9999)),
        Callback = data.Callback or function() end
    }
    
    MenuLib.Flags[dropdown.Flag] = dropdown.Value
    table.insert(section.Items, dropdown)
    
    function dropdown:Set(val)
        self.Value = val
        MenuLib.Flags[self.Flag] = val
        pcall(self.Callback, val)
    end
    
    return dropdown
end

-- =========================================================================
-- 4. СИСТЕМА КОНФИГУРАЦИЙ (CONFIG SYSTEM)
-- =========================================================================

function MenuLib.SaveConfig(configName)
    local savedData = {}
    for flag, value in pairs(MenuLib.Flags) do
        -- Сохраняем только примитивные типы данных, пригодные для сериализации
        if typeof(value) ~= "Color3" and typeof(value) ~= "EnumItem" then
            savedData[flag] = value
        end
    end
    
    MenuLib.SendNotification("Config", "Конфигурация '" .. (configName or "default") .. "' сохранена!", 2)
    return savedData
end

function MenuLib.LoadConfig(savedData)
    if type(savedData) ~= "table" then return end
    
    for flag, value in pairs(savedData) do
        if MenuLib.Flags[flag] ~= nil then
            MenuLib.Flags[flag] = value
        end
    end
    
    MenuLib.SendNotification("Config", "Конфигурация успешно загружена!", 2)
end

return MenuLib
