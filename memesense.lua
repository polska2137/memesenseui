--[[
    NexusUI - Modern UI Library for Roblox
    Version: 1.0.0
    
    A feature-rich UI library inspired by modern cheat interfaces
    with smooth animations, notifications, and modular design.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local NexusUI = {}
NexusUI.__index = NexusUI

-- Configuration
local CONFIG = {
    Colors = {
        Primary = Color3.fromRGB(168, 85, 247),
        Secondary = Color3.fromRGB(236, 72, 153),
        Background = Color3.fromRGB(15, 23, 42),
        Panel = Color3.fromRGB(30, 41, 59),
        Border = Color3.fromRGB(51, 65, 85),
        Text = Color3.fromRGB(248, 250, 252),
        TextDim = Color3.fromRGB(148, 163, 184),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(251, 146, 60),
        Error = Color3.fromRGB(239, 68, 68),
    },
    Fonts = {
        Regular = Enum.Font.Gotham,
        Bold = Enum.Font.GothamBold,
        Mono = Enum.Font.RobotoMono,
    },
    Animations = {
        Speed = 0.3,
        Style = Enum.EasingStyle.Quart,
        Direction = Enum.EasingDirection.Out,
    }
}

-- Utility Functions
local function CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or CONFIG.Colors.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function Tween(instance, properties, duration)
    local tweenInfo = TweenInfo.new(
        duration or CONFIG.Animations.Speed,
        CONFIG.Animations.Style,
        CONFIG.Animations.Direction
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Main Library Constructor
function NexusUI.new(config)
    local self = setmetatable({}, NexusUI)
    
    self.Config = config or {}
    self.Config.Title = self.Config.Title or "NexusUI"
    self.Config.Size = self.Config.Size or UDim2.new(0, 700, 0, 500)
    self.Config.Theme = self.Config.Theme or CONFIG.Colors
    
    self.Notifications = {}
    self.Tabs = {}
    self.CurrentTab = nil
    self.Dragging = false
    self.MasterSwitch = true
    self.Visible = true
    
    self:CreateUI()
    self:MakeDraggable()
    
    return self
end

-- Create Main UI Structure
function NexusUI:CreateUI()
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NexusUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game:GetService("CoreGui")
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = self.Config.Size
    self.MainFrame.Position = UDim2.new(0.5, -self.Config.Size.X.Offset/2, 0.5, -self.Config.Size.Y.Offset/2)
    self.MainFrame.BackgroundColor3 = CONFIG.Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    CreateCorner(self.MainFrame, 12)
    CreateStroke(self.MainFrame, CONFIG.Colors.Border, 1)
    
    self:CreateHeader()
    self:CreateSidebar()
    self:CreateContentArea()
    self:CreateNotificationContainer()
end

-- Create Header
function NexusUI:CreateHeader()
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = CONFIG.Colors.Panel
    header.BorderSizePixel = 0
    header.Parent = self.MainFrame
    CreateCorner(header, 12)
    CreateGradient(header, CONFIG.Colors.Panel, Color3.fromRGB(20, 30, 48), 90)
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.Config.Title
    title.TextColor3 = CONFIG.Colors.Text
    title.Font = CONFIG.Fonts.Bold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local switchContainer = Instance.new("Frame")
    switchContainer.Name = "MasterSwitch"
    switchContainer.Size = UDim2.new(0, 150, 0, 30)
    switchContainer.Position = UDim2.new(1, -310, 0.5, -15)
    switchContainer.BackgroundTransparency = 1
    switchContainer.Parent = header
    
    local switchLabel = Instance.new("TextLabel")
    switchLabel.Size = UDim2.new(0, 90, 1, 0)
    switchLabel.BackgroundTransparency = 1
    switchLabel.Text = "Master Switch"
    switchLabel.TextColor3 = CONFIG.Colors.TextDim
    switchLabel.Font = CONFIG.Fonts.Regular
    switchLabel.TextSize = 12
    switchLabel.TextXAlignment = Enum.TextXAlignment.Left
    switchLabel.Parent = switchContainer
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0, 48, 0, 24)
    toggleButton.Position = UDim2.new(1, -48, 0.5, -12)
    toggleButton.BackgroundColor3 = CONFIG.Colors.Success
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = switchContainer
    CreateCorner(toggleButton, 12)
    
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Name = "Indicator"
    toggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    toggleIndicator.Position = UDim2.new(0, 26, 0.5, -10)
    toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Parent = toggleButton
    CreateCorner(toggleIndicator, 10)
    
    toggleButton.MouseButton1Click:Connect(function()
        self.MasterSwitch = not self.MasterSwitch
        if self.MasterSwitch then
            Tween(toggleButton, {BackgroundColor3 = CONFIG.Colors.Success})
            Tween(toggleIndicator, {Position = UDim2.new(0, 26, 0.5, -10)})
        else
            Tween(toggleButton, {BackgroundColor3 = CONFIG.Colors.TextDim})
            Tween(toggleIndicator, {Position = UDim2.new(0, 2, 0.5, -10)})
        end
        self:SendNotification("Master Switch " .. (self.MasterSwitch and "Enabled" or "Disabled"), "info")
    end)
    
    local saveButton = Instance.new("TextButton")
    saveButton.Name = "SaveButton"
    saveButton.Size = UDim2.new(0, 80, 0, 30)
    saveButton.Position = UDim2.new(1, -150, 0.5, -15)
    saveButton.BackgroundColor3 = CONFIG.Colors.Primary
    saveButton.BorderSizePixel = 0
    saveButton.Text = "💾 Save"
    saveButton.TextColor3 = CONFIG.Colors.Text
    saveButton.Font = CONFIG.Fonts.Bold
    saveButton.TextSize = 13
    saveButton.Parent = header
    CreateCorner(saveButton, 6)
    CreateGradient(saveButton, CONFIG.Colors.Primary, CONFIG.Colors.Secondary, 45)
    
    saveButton.MouseButton1Click:Connect(function()
        self:SaveConfig()
    end)
    
    saveButton.MouseEnter:Connect(function()
        Tween(saveButton, {Size = UDim2.new(0, 85, 0, 32)})
    end)
    
    saveButton.MouseLeave:Connect(function()
        Tween(saveButton, {Size = UDim2.new(0, 80, 0, 30)})
    end)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -60, 0.5, -15)
    closeButton.BackgroundColor3 = CONFIG.Colors.Error
    closeButton.BackgroundTransparency = 0.8
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = CONFIG.Colors.Text
    closeButton.Font = CONFIG.Fonts.Bold
    closeButton.TextSize = 20
    closeButton.Parent = header
    CreateCorner(closeButton, 6)
    
    closeButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    self.Header = header
end

-- Create Sidebar
function NexusUI:CreateSidebar()
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 180, 1, -60)
    sidebar.Position = UDim2.new(0, 10, 0, 60)
    sidebar.BackgroundTransparency = 1
    sidebar.Parent = self.MainFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = sidebar
    
    self.Sidebar = sidebar
end

-- Create Content Area
function NexusUI:CreateContentArea()
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -210, 1, -70)
    content.Position = UDim2.new(0, 200, 0, 60)
    content.BackgroundColor3 = CONFIG.Colors.Background
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = CONFIG.Colors.Primary
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = self.MainFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = content
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = content
    
    self.Content = content
end

-- Create Notification Container
function NexusUI:CreateNotificationContainer()
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.Size = UDim2.new(0, 300, 1, 0)
    container.Position = UDim2.new(1, -320, 0, 20)
    container.BackgroundTransparency = 1
    container.Parent = self.ScreenGui
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Parent = container
    
    self.NotificationContainer = container
end

-- Make Draggable
function NexusUI:MakeDraggable()
    local dragToggle = nil
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Tween(self.MainFrame, {Position = position}, 0.1)
    end
    
    self.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragToggle then
                updateInput(input)
            end
        end
    end)
end

-- Toggle Visibility
function NexusUI:Toggle()
    self.Visible = not self.Visible
    if self.Visible then
        Tween(self.MainFrame, {Size = self.Config.Size})
        self.MainFrame.Visible = true
    else
        Tween(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0)})
        task.wait(CONFIG.Animations.Speed)
        self.MainFrame.Visible = false
    end
end

-- Send Notification
function NexusUI:SendNotification(message, type)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 60)
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel = 0
    notif.Parent = self.NotificationContainer
    CreateCorner(notif, 8)
    
    local color = CONFIG.Colors.Primary
    if type == "success" then
        color = CONFIG.Colors.Success
    elseif type == "warning" then
        color = CONFIG.Colors.Warning
    elseif type == "error" then
        color = CONFIG.Colors.Error
    end
    
    notif.BackgroundColor3 = color
    CreateStroke(notif, color, 2)
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = type == "success" and "✓" or type == "error" and "✕" or "ℹ"
    icon.TextColor3 = CONFIG.Colors.Text
    icon.Font = CONFIG.Fonts.Bold
    icon.TextSize = 20
    icon.Parent = notif
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -50, 1, 0)
    text.Position = UDim2.new(0, 45, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = CONFIG.Colors.Text
    text.Font = CONFIG.Fonts.Regular
    text.TextSize = 13
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextWrapped = true
    text.Parent = notif
    
    notif.Position = UDim2.new(0, 0, 0, 0)
    notif.Size = UDim2.new(1, 0, 0, 0)
    Tween(notif, {Size = UDim2.new(1, 0, 0, 60)}, 0.2)
    
    task.delay(3, function()
        Tween(notif, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.2)
        task.wait(0.2)
        notif:Destroy()
    end)
end

-- Save Config
function NexusUI:SaveConfig()
    self:SendNotification("Configuration saved successfully!", "success")
end

-- Add Tab
function NexusUI:AddTab(config)
    local tab = {
        Name = config.Name or "Tab",
        Icon = config.Icon or "⚙️",
        Sections = {},
    }
    
    local button = Instance.new("TextButton")
    button.Name = config.Name
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = CONFIG.Colors.Panel
    button.BackgroundTransparency = 0.5
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = self.Sidebar
    CreateCorner(button, 8)
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 1, 0)
    icon.Position = UDim2.new(0, 10, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = tab.Icon
    icon.TextColor3 = CONFIG.Colors.TextDim
    icon.Font = CONFIG.Fonts.Regular
    icon.TextSize = 16
    icon.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 45, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tab.Name
    label.TextColor3 = CONFIG.Colors.TextDim
    label.Font = CONFIG.Fonts.Regular
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    button.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then
            Tween(button, {BackgroundTransparency = 0.2})
        end
    end)
    
    button.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then
            Tween(button, {BackgroundTransparency = 0.5})
        end
    end)
    
    tab.Button = button
    tab.Icon = icon
    tab.Label = label
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return setmetatable({
        Tab = tab,
        UI = self,
    }, {__index = self})
end

-- Select Tab
function NexusUI:SelectTab(tab)
    if self.CurrentTab then
        Tween(self.CurrentTab.Button, {BackgroundTransparency = 0.5})
        Tween(self.CurrentTab.Label, {TextColor3 = CONFIG.Colors.TextDim})
        Tween(self.CurrentTab.Icon, {TextColor3 = CONFIG.Colors.TextDim})
    end
    
    self.CurrentTab = tab
    Tween(tab.Button, {BackgroundTransparency = 0})
    Tween(tab.Label, {TextColor3 = CONFIG.Colors.Text})
    Tween(tab.Icon, {TextColor3 = CONFIG.Colors.Primary})
    
    for _, child in ipairs(self.Content:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for _, section in ipairs(tab.Sections) do
        section:Build()
    end
end

-- Add Section
function NexusUI:AddSection(config)
    local section = {
        Name = config.Name or "Section",
        Tab = self.Tab,
        Elements = {},
        Expanded = true,
    }
    
    function section:Build()
        local frame = Instance.new("Frame")
        frame.Name = section.Name
        frame.Size = UDim2.new(1, -10, 0, 40)
        frame.BackgroundColor3 = CONFIG.Colors.Panel
        frame.BorderSizePixel = 0
        frame.Parent = self.Tab.UI.Content
        CreateCorner(frame, 8)
        CreateStroke(frame, CONFIG.Colors.Border)
        
        local header = Instance.new("TextButton")
        header.Size = UDim2.new(1, 0, 0, 40)
        header.BackgroundTransparency = 1
        header.Text = ""
        header.Parent = frame
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -40, 1, 0)
        title.Position = UDim2.new(0, 40, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = section.Name
        title.TextColor3 = CONFIG.Colors.Text
        title.Font = CONFIG.Fonts.Bold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = header
        
        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 0, 20)
        arrow.Position = UDim2.new(0, 10, 0.5, -10)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = CONFIG.Colors.Primary
        arrow.Font = CONFIG.Fonts.Bold
        arrow.TextSize = 10
        arrow.Parent = header
        
        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, 0, 0, 0)
        content.Position = UDim2.new(0, 0, 0, 40)
        content.BackgroundTransparency = 1
        content.ClipsDescendants = true
        content.Parent = frame
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 8)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = content
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 8)
        padding.PaddingBottom = UDim.new(0, 8)
        padding.PaddingLeft = UDim.new(0, 15)
        padding.PaddingRight = UDim.new(0, 15)
        padding.Parent = content
        
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if section.Expanded then
                local newHeight = listLayout.AbsoluteContentSize.Y + 16
                Tween(content, {Size = UDim2.new(1, 0, 0, newHeight)})
                Tween(frame, {Size = UDim2.new(1, -10, 0, 40 + newHeight)})
            end
        end)
        
        header.MouseButton1Click:Connect(function()
            section.Expanded = not section.Expanded
            if section.Expanded then
                local newHeight = listLayout.AbsoluteContentSize.Y + 16
                Tween(content, {Size = UDim2.new(1, 0, 0, newHeight)})
                Tween(frame, {Size = UDim2.new(1, -10, 0, 40 + newHeight)})
                Tween(arrow, {Rotation = 0})
            else
                Tween(content, {Size = UDim2.new(1, 0, 0, 0)})
                Tween(frame, {Size = UDim2.new(1, -10, 0, 40)})
                Tween(arrow, {Rotation = -90})
            end
        end)
        
        section.Frame = frame
        section.Content = content
        
        for _, element in ipairs(section.Elements) do
            element:Build(content)
        end
    end
    
    table.insert(self.Tab.Sections, section)
    
    return setmetatable({
        Section = section,
        Tab = self.Tab,
        UI = self.UI,
    }, {__index = self})
end

-- Add Toggle
function NexusUI:AddToggle(config)
    local toggle = {
        Name = config.Name or "Toggle",
        Default = config.Default or false,
        Callback = config.Callback or function() end,
        Value = config.Default or false,
    }
    
    function toggle:Build(parent)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = CONFIG.Colors.Background
        frame.BorderSizePixel = 0
        frame.Parent = parent
        CreateCorner(frame, 6)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = toggle.Name
        label.TextColor3 = CONFIG.Colors.Text
        label.Font = CONFIG.Fonts.Regular
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 44, 0, 22)
        button.Position = UDim2.new(1, -50, 0.5, -11)
        button.BackgroundColor3 = toggle.Value and CONFIG.Colors.Success or CONFIG.Colors.TextDim
        button.BorderSizePixel = 0
        button.Text = ""
        button.Parent = frame
        CreateCorner(button, 11)
        
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 18, 0, 18)
        indicator.Position = toggle.Value and UDim2.new(0, 24, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        indicator.BorderSizePixel = 0
        indicator.Parent = button
        CreateCorner(indicator, 9)
        
        button.MouseButton1Click:Connect(function()
            toggle.Value = not toggle.Value
            if toggle.Value then
                Tween(button, {BackgroundColor3 = CONFIG.Colors.Success})
                Tween(indicator, {Position = UDim2.new(0, 24, 0.5, -9)})
            else
                Tween(button, {BackgroundColor3 = CONFIG.Colors.TextDim})
                Tween(indicator, {Position = UDim2.new(0, 2, 0.5, -9)})
            end
            toggle.Callback(toggle.Value)
        end)
        
        toggle.Frame = frame
    end
    
    function toggle:SetValue(value)
        self.Value = value
        if self.Frame then
            local button = self.Frame:FindFirstChild("TextButton")
            local indicator = button and button:FindFirstChild("Frame")
            if button and indicator then
                if value then
                    Tween(button, {BackgroundColor3 = CONFIG.Colors.Success})
                    Tween(indicator, {Position = UDim2.new(0, 24, 0.5, -9)})
                else
                    Tween(button, {BackgroundColor3 = CONFIG.Colors.TextDim})
                    Tween(indicator, {Position = UDim2.new(0, 2, 0.5, -9)})
                end
            end
        end
    end
    
    table.insert(self.Section.Elements, toggle)
    return toggle
end

-- Add Slider
function NexusUI:AddSlider(config)
    local slider = {
        Name = config.Name or "Slider",
        Min = config.Min or 0,
        Max = config.Max or 100,
        Default = config.Default or 50,
        Increment = config.Increment or 1,
        Suffix = config.Suffix or "",
        Callback = config.Callback or function() end,
        Value = config.Default or 50,
    }
    
    function slider:Build(parent)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundColor3 = CONFIG.Colors.Background
        frame.BorderSizePixel = 0
        frame.Parent = parent
        CreateCorner(frame, 6)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -80, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = slider.Name
        label.TextColor3 = CONFIG.Colors.Text
        label.Font = CONFIG.Fonts.Regular
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 70, 0, 20)
        valueLabel.Position = UDim2.new(1, -75, 0, 5)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(slider.Value) .. slider.Suffix
        valueLabel.TextColor3 = CONFIG.Colors.Primary
        valueLabel.Font = CONFIG.Fonts.Bold
        valueLabel.TextSize = 13
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame
        
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -20, 0, 4)
        track.Position = UDim2.new(0, 10, 1, -15)
        track.BackgroundColor3 = CONFIG.Colors.Border
        track.BorderSizePixel = 0
        track.Parent = frame
        CreateCorner(track, 2)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0)
        fill.BackgroundColor3 = CONFIG.Colors.Primary
        fill.BorderSizePixel = 0
        fill.Parent = track
        CreateCorner(fill, 2)
        CreateGradient(fill, CONFIG.Colors.Primary, CONFIG.Colors.Secondary, 90)
        
        local thumb = Instance.new("Frame")
        thumb.Size = UDim2.new(0, 14, 0, 14)
        thumb.Position = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), -7, 0.5, -7)
        thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        thumb.BorderSizePixel = 0
        thumb.Parent = track
        CreateCorner(thumb, 7)
        CreateStroke(thumb, CONFIG.Colors.Primary, 2)
        
        local dragging = false
        
        local function updateSlider(input)
            local pos = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            pos = math.clamp(pos, 0, 1)
            slider.Value = math.floor((pos * (slider.Max - slider.Min) + slider.Min) / slider.Increment + 0.5) * slider.Increment
            slider.Value = math.clamp(slider.Value, slider.Min, slider.Max)
            
            valueLabel.Text = tostring(slider.Value) .. slider.Suffix
            Tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
            Tween(thumb, {Position = UDim2.new(pos, -7, 0.5, -7)}, 0.1)
            
            slider.Callback(slider.Value)
        end
        
        thumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                Tween(thumb, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(thumb.Position.X.Scale, -9, 0.5, -9)}, 0.1)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                Tween(thumb, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(thumb.Position.X.Scale, -7, 0.5, -7)}, 0.1)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        slider.Frame = frame
    end
    
    function slider:SetValue(value)
        self.Value = math.clamp(value, self.Min, self.Max)
        if self.Frame then
            local track = self.Frame:FindFirstChild("Frame")
            if track then
                local fill = track:FindFirstChild("Frame")
                local thumb = track:FindFirstChild("Frame", true)
                local valueLabel = self.Frame:FindFirstChildOfClass("TextLabel")
                if fill and thumb and valueLabel then
                    local pos = (self.Value - self.Min) / (self.Max - self.Min)
                    valueLabel.Text = tostring(self.Value) .. self.Suffix
                    Tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                    Tween(thumb, {Position = UDim2.new(pos, -7, 0.5, -7)}, 0.1)
                end
            end
        end
    end
    
    table.insert(self.Section.Elements, slider)
    return slider
end

-- Add Button
function NexusUI:AddButton(config)
    local button = {
        Name = config.Name or "Button",
        Callback = config.Callback or function() end,
    }
    
    function button:Build(parent)
        local frame = Instance.new("TextButton")
        frame.Size = UDim2.new(1, 0, 0, 36)
        frame.BackgroundColor3 = CONFIG.Colors.Primary
        frame.BorderSizePixel = 0
        frame.Text = button.Name
        frame.TextColor3 = CONFIG.Colors.Text
        frame.Font = CONFIG.Fonts.Bold
        frame.TextSize = 14
        frame.Parent = parent
        CreateCorner(frame, 6)
        CreateGradient(frame, CONFIG.Colors.Primary, CONFIG.Colors.Secondary, 45)
        
        frame.MouseButton1Click:Connect(function()
            Tween(frame, {Size = UDim2.new(1, -4, 0, 34)}, 0.1)
            task.wait(0.1)
            Tween(frame, {Size = UDim2.new(1, 0, 0, 36)}, 0.1)
            button.Callback()
        end)
        
        frame.MouseEnter:Connect(function()
            Tween(frame, {BackgroundColor3 = CONFIG.Colors.Secondary})
        end)
        
        frame.MouseLeave:Connect(function()
            Tween(frame, {BackgroundColor3 = CONFIG.Colors.Primary})
        end)
        
        button.Frame = frame
    end
    
    table.insert(self.Section.Elements, button)
    return button
end

-- Add Dropdown
function NexusUI:AddDropdown(config)
    local dropdown = {
        Name = config.Name or "Dropdown",
        Options = config.Options or {"Option 1", "Option 2"},
        Default = config.Default or config.Options[1],
        Callback = config.Callback or function() end,
        Value = config.Default or config.Options[1],
        Expanded = false,
    }
    
    function dropdown:Build(parent)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 36)
        frame.BackgroundColor3 = CONFIG.Colors.Background
        frame.BorderSizePixel = 0
        frame.Parent = parent
        frame.ClipsDescendants = true
        CreateCorner(frame, 6)
        
        local header = Instance.new("TextButton")
        header.Size = UDim2.new(1, 0, 0, 36)
        header.BackgroundColor3 = CONFIG.Colors.Panel
        header.BorderSizePixel = 0
        header.Text = ""
        header.Parent = frame
        CreateCorner(header, 6)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 100, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = dropdown.Name
        label.TextColor3 = CONFIG.Colors.Text
        label.Font = CONFIG.Fonts.Regular
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = header
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(1, -120, 1, 0)
        valueLabel.Position = UDim2.new(0, 110, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = dropdown.Value
        valueLabel.TextColor3 = CONFIG.Colors.Primary
        valueLabel.Font = CONFIG.Fonts.Bold
        valueLabel.TextSize = 13
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        valueLabel.Parent = header
        
        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 0, 20)
        arrow.Position = UDim2.new(1, -25, 0.5, -10)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = CONFIG.Colors.TextDim
        arrow.Font = CONFIG.Fonts.Bold
        arrow.TextSize = 10
        arrow.Parent = header
        
        local optionsContainer = Instance.new("Frame")
        optionsContainer.Size = UDim2.new(1, 0, 0, 0)
        optionsContainer.Position = UDim2.new(0, 0, 0, 36)
        optionsContainer.BackgroundTransparency = 1
        optionsContainer.Parent = frame
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = optionsContainer
        
        for _, option in ipairs(dropdown.Options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 30)
            optionButton.BackgroundColor3 = CONFIG.Colors.Panel
            optionButton.BackgroundTransparency = 0.3
            optionButton.BorderSizePixel = 0
            optionButton.Text = option
            optionButton.TextColor3 = CONFIG.Colors.Text
            optionButton.Font = CONFIG.Fonts.Regular
            optionButton.TextSize = 12
            optionButton.Parent = optionsContainer
            CreateCorner(optionButton, 4)
            
            optionButton.MouseButton1Click:Connect(function()
                dropdown.Value = option
                valueLabel.Text = option
                dropdown.Expanded = false
                Tween(frame, {Size = UDim2.new(1, 0, 0, 36)})
                Tween(arrow, {Rotation = 0})
                dropdown.Callback(option)
            end)
            
            optionButton.MouseEnter:Connect(function()
                Tween(optionButton, {BackgroundTransparency = 0})
            end)
            
            optionButton.MouseLeave:Connect(function()
                Tween(optionButton, {BackgroundTransparency = 0.3})
            end)
        end
        
        header.MouseButton1Click:Connect(function()
            dropdown.Expanded = not dropdown.Expanded
            if dropdown.Expanded then
                local height = 36 + (#dropdown.Options * 32)
                Tween(frame, {Size = UDim2.new(1, 0, 0, height)})
                Tween(arrow, {Rotation = 180})
            else
                Tween(frame, {Size = UDim2.new(1, 0, 0, 36)})
                Tween(arrow, {Rotation = 0})
            end
        end)
        
        dropdown.Frame = frame
    end
    
    function dropdown:SetValue(value)
        self.Value = value
        if self.Frame then
            local header = self.Frame:FindFirstChildOfClass("TextButton")
            if header then
                local valueLabel = header:FindFirstChild("TextLabel", true)
                if valueLabel then
                    valueLabel.Text = value
                end
            end
        end
    end
    
    table.insert(self.Section.Elements, dropdown)
    return dropdown
end

-- Add Textbox
function NexusUI:AddTextbox(config)
    local textbox = {
        Name = config.Name or "Textbox",
        Default = config.Default or "",
        Placeholder = config.Placeholder or "Enter text...",
        Callback = config.Callback or function() end,
        Value = config.Default or "",
    }
    
    function textbox:Build(parent)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 60)
        frame.BackgroundColor3 = CONFIG.Colors.Background
        frame.BorderSizePixel = 0
        frame.Parent = parent
        CreateCorner(frame, 6)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = textbox.Name
        label.TextColor3 = CONFIG.Colors.Text
        label.Font = CONFIG.Fonts.Regular
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, -20, 0, 30)
        input.Position = UDim2.new(0, 10, 0, 25)
        input.BackgroundColor3 = CONFIG.Colors.Panel
        input.BorderSizePixel = 0
        input.Text = textbox.Value
        input.PlaceholderText = textbox.Placeholder
        input.TextColor3 = CONFIG.Colors.Text
        input.PlaceholderColor3 = CONFIG.Colors.TextDim
        input.Font = CONFIG.Fonts.Regular
        input.TextSize = 12
        input.ClearTextOnFocus = false
        input.Parent = frame
        CreateCorner(input, 6)
        CreateStroke(input, CONFIG.Colors.Border)
        
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.Parent = input
        
        input.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                textbox.Value = input.Text
                textbox.Callback(input.Text)
            end
        end)
        
        input.Focused:Connect(function()
            Tween(input:FindFirstChildOfClass("UIStroke"), {Color = CONFIG.Colors.Primary})
        end)
        
        input.FocusLost:Connect(function()
            Tween(input:FindFirstChildOfClass("UIStroke"), {Color = CONFIG.Colors.Border})
        end)
        
        textbox.Frame = frame
    end
    
    function textbox:SetValue(value)
        self.Value = value
        if self.Frame then
            local input = self.Frame:FindFirstChildOfClass("TextBox")
            if input then
                input.Text = value
            end
        end
    end
    
    table.insert(self.Section.Elements, textbox)
    return textbox
end

-- Add Label
function NexusUI:AddLabel(config)
    local label = {
        Text = config.Text or "Label",
    }
    
    function label:Build(parent)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, -10, 1, 0)
        text.Position = UDim2.new(0, 10, 0, 0)
        text.BackgroundTransparency = 1
        text.Text = label.Text
        text.TextColor3 = CONFIG.Colors.TextDim
        text.Font = CONFIG.Fonts.Regular
        text.TextSize = 12
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.TextWrapped = true
        text.Parent = frame
        
        label.Frame = frame
        label.TextLabel = text
    end
    
    function label:SetText(text)
        self.Text = text
        if self.TextLabel then
            self.TextLabel.Text = text
        end
    end
    
    table.insert(self.Section.Elements, label)
    return label
end

-- Add Keybind
function NexusUI:AddKeybind(config)
    local keybind = {
        Name = config.Name or "Keybind",
        Default = config.Default or Enum.KeyCode.F,
        Callback = config.Callback or function() end,
        Value = config.Default or Enum.KeyCode.F,
        Listening = false,
    }
    
    function keybind:Build(parent)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = CONFIG.Colors.Background
        frame.BorderSizePixel = 0
        frame.Parent = parent
        CreateCorner(frame, 6)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -100, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = keybind.Name
        label.TextColor3 = CONFIG.Colors.Text
        label.Font = CONFIG.Fonts.Regular
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 80, 0, 26)
        button.Position = UDim2.new(1, -85, 0.5, -13)
        button.BackgroundColor3 = CONFIG.Colors.Panel
        button.BorderSizePixel = 0
        button.Text = keybind.Value.Name
        button.TextColor3 = CONFIG.Colors.Primary
        button.Font = CONFIG.Fonts.Bold
        button.TextSize = 12
        button.Parent = frame
        CreateCorner(button, 6)
        CreateStroke(button, CONFIG.Colors.Border)
        
        button.MouseButton1Click:Connect(function()
            keybind.Listening = true
            button.Text = "..."
            Tween(button:FindFirstChildOfClass("UIStroke"), {Color = CONFIG.Colors.Primary})
        end)
        
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
                keybind.Value = input.KeyCode
                button.Text = input.KeyCode.Name
                keybind.Listening = false
                Tween(button:FindFirstChildOfClass("UIStroke"), {Color = CONFIG.Colors.Border})
            end
        end)
        
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == keybind.Value then
                keybind.Callback()
            end
        end)
        
        keybind.Frame = frame
    end
    
    function keybind:SetValue(value)
        self.Value = value
        if self.Frame then
            local button = self.Frame:FindFirstChildOfClass("TextButton")
            if button then
                button.Text = value.Name
            end
        end
    end
    
    table.insert(self.Section.Elements, keybind)
    return keybind
end

return NexusUI
