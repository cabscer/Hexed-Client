-- ============================================
-- HEXED GUI FRAMEWORK v2.0
-- Obsidian-inspired Resizable GUI for Roblox
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Hexed = {}
Hexed.__index = Hexed

-- ============================================
-- CONFIGURATION
-- ============================================
local DEFAULT_CONFIG = {
    Title = "Hexed Client",
    Subtitle = "Rivals",
    Size = UDim2.new(0, 1000, 0, 700),
    Position = UDim2.new(0.5, -500, 0.5, -350),
    MinSize = Vector2.new(600, 400),
    CornerRadius = 12,
    PanelGap = 8,
    SidebarWidth = 260,
    Theme = "Obsidian",
    AccentColor = Color3.fromRGB(88, 166, 255),
    BackgroundTransparency = 0,
    Animate = true,
    Draggable = true,
    Resizable = true,
}

local THEMES = {
    Obsidian = {
        Background = Color3.fromRGB(13, 17, 23),
        BackgroundSecondary = Color3.fromRGB(22, 27, 34),
        BackgroundTertiary = Color3.fromRGB(33, 38, 45),
        BackgroundHover = Color3.fromRGB(48, 54, 61),
        Border = Color3.fromRGB(48, 54, 61),
        TextPrimary = Color3.fromRGB(201, 209, 217),
        TextSecondary = Color3.fromRGB(139, 148, 158),
        TextDisabled = Color3.fromRGB(88, 96, 105),
    },
    Midnight = {
        Background = Color3.fromRGB(10, 14, 26),
        BackgroundSecondary = Color3.fromRGB(17, 24, 39),
        BackgroundTertiary = Color3.fromRGB(31, 41, 55),
        BackgroundHover = Color3.fromRGB(55, 65, 81),
        Border = Color3.fromRGB(55, 65, 81),
        TextPrimary = Color3.fromRGB(229, 231, 235),
        TextSecondary = Color3.fromRGB(156, 163, 175),
        TextDisabled = Color3.fromRGB(107, 114, 128),
    },
    Ocean = {
        Background = Color3.fromRGB(12, 30, 46),
        BackgroundSecondary = Color3.fromRGB(19, 47, 76),
        BackgroundTertiary = Color3.fromRGB(26, 74, 110),
        BackgroundHover = Color3.fromRGB(30, 73, 118),
        Border = Color3.fromRGB(30, 73, 118),
        TextPrimary = Color3.fromRGB(224, 242, 254),
        TextSecondary = Color3.fromRGB(125, 211, 252),
        TextDisabled = Color3.fromRGB(56, 189, 248),
    },
    Forest = {
        Background = Color3.fromRGB(10, 31, 10),
        BackgroundSecondary = Color3.fromRGB(15, 46, 15),
        BackgroundTertiary = Color3.fromRGB(26, 61, 26),
        BackgroundHover = Color3.fromRGB(34, 85, 34),
        Border = Color3.fromRGB(34, 85, 34),
        TextPrimary = Color3.fromRGB(220, 252, 231),
        TextSecondary = Color3.fromRGB(134, 239, 172),
        TextDisabled = Color3.fromRGB(74, 222, 128),
    },
    Crimson = {
        Background = Color3.fromRGB(31, 10, 10),
        BackgroundSecondary = Color3.fromRGB(46, 15, 15),
        BackgroundTertiary = Color3.fromRGB(61, 26, 26),
        BackgroundHover = Color3.fromRGB(85, 34, 34),
        Border = Color3.fromRGB(85, 34, 34),
        TextPrimary = Color3.fromRGB(254, 226, 226),
        TextSecondary = Color3.fromRGB(252, 165, 165),
        TextDisabled = Color3.fromRGB(248, 113, 113),
    }
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function Tween(instance, properties, duration, easingStyle, easingDirection)
    duration = duration or 0.2
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out

    local tween = TweenService:Create(instance, TweenInfo.new(duration, easingStyle, easingDirection), properties)
    tween:Play()
    return tween
end

local function Round(num, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(num * mult + 0.5) / mult
end

-- ============================================
-- HEXED GUI CONSTRUCTOR
-- ============================================
function Hexed.new(config)
    local self = setmetatable({}, Hexed)

    self.Config = {}
    for key, value in pairs(DEFAULT_CONFIG) do
        self.Config[key] = config[key] or value
    end

    self.Theme = THEMES[self.Config.Theme] or THEMES.Obsidian
    self.Tabs = {}
    self.ActiveTab = nil
    self.IsMinimized = false
    self.IsMaximized = false
    self.OriginalSize = self.Config.Size
    self.OriginalPosition = self.Config.Position

    self:BuildGUI()
    self:MakeDraggable()
    self:MakeResizable()
    self:BuildSettingsPanel()

    return self
end

-- ============================================
-- GUI BUILDER
-- ============================================
function Hexed:BuildGUI()
    -- Main ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "HexedGUI",
        Parent = game.CoreGui or LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999999,
    })

    -- Main Window Frame
    self.MainFrame = Create("Frame", {
        Name = "MainWindow",
        Parent = self.ScreenGui,
        Size = self.Config.Size,
        Position = self.Config.Position,
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })

    -- Corner Radius
    self.Corner = Create("UICorner", {
        Parent = self.MainFrame,
        CornerRadius = UDim.new(0, self.Config.CornerRadius),
    })

    -- Shadow
    self.Shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = self.ScreenGui,
        Size = UDim2.new(0, self.MainFrame.AbsoluteSize.X + 60, 0, self.MainFrame.AbsoluteSize.Y + 60),
        Position = UDim2.new(0, self.MainFrame.AbsolutePosition.X - 30, 0, self.MainFrame.AbsolutePosition.Y - 30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = -1,
    })

    -- Title Bar
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
    })

    Create("UICorner", {
        Parent = self.TitleBar,
        CornerRadius = UDim.new(0, self.Config.CornerRadius),
    })

    -- Fix title bar corners
    local titleFix = Create("Frame", {
        Parent = self.TitleBar,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = self.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
    })

    -- Window Controls (Traffic Lights)
    self.WindowControls = Create("Frame", {
        Name = "WindowControls",
        Parent = self.TitleBar,
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
    })

    local function CreateWindowButton(color, name, callback)
        local btn = Create("TextButton", {
            Name = name,
            Parent = self.WindowControls,
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0, (#self.WindowControls:GetChildren() - 1) * 20, 0.5, -6),
            BackgroundColor3 = color,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = btn, CornerRadius = UDim.new(1, 0) })

        btn.MouseEnter:Connect(function()
            Tween(btn, { BackgroundTransparency = 0.3 }, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundTransparency = 0 }, 0.15)
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    CreateWindowButton(Color3.fromRGB(255, 95, 87), "Close", function() self:Close() end)
    CreateWindowButton(Color3.fromRGB(255, 189, 46), "Minimize", function() self:Minimize() end)
    CreateWindowButton(Color3.fromRGB(40, 200, 64), "Maximize", function() self:Maximize() end)

    -- Title Icon
    self.TitleIcon = Create("Frame", {
        Name = "Icon",
        Parent = self.TitleBar,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 100, 0.5, -9),
        BackgroundColor3 = self.Config.AccentColor,
        BorderSizePixel = 0,
    })
    Create("UICorner", { Parent = self.TitleIcon, CornerRadius = UDim.new(0, 4) })

    Create("TextLabel", {
        Parent = self.TitleIcon,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "H",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.new(1, 1, 1),
    })

    -- Title Text
    self.TitleText = Create("TextLabel", {
        Name = "Title",
        Parent = self.TitleBar,
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(0, 124, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Config.Title .. " — " .. self.Config.Subtitle,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = self.Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Main Container
    self.Container = Create("Frame", {
        Name = "Container",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 1, -68),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
    })

    -- Sidebar
    self.Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = self.Container,
        Size = UDim2.new(0, self.Config.SidebarWidth, 1, 0),
        BackgroundColor3 = self.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
    })

    -- Sidebar Resize Handle
    self.SidebarResize = Create("Frame", {
        Name = "ResizeHandle",
        Parent = self.Sidebar,
        Size = UDim2.new(0, 4, 1, 0),
        Position = UDim2.new(1, -2, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    self.SidebarResize.MouseEnter:Connect(function()
        self.SidebarResize.BackgroundColor3 = self.Config.AccentColor
        self.SidebarResize.BackgroundTransparency = 0.7
    end)
    self.SidebarResize.MouseLeave:Connect(function()
        self.SidebarResize.BackgroundTransparency = 1
    end)

    -- Sidebar Header
    self.SidebarHeader = Create("Frame", {
        Name = "Header",
        Parent = self.Sidebar,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
    })

    Create("TextLabel", {
        Parent = self.SidebarHeader,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = "NAVIGATION",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = self.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 0.5,
    })

    -- Sidebar Content
    self.SidebarContent = Create("ScrollingFrame", {
        Name = "Content",
        Parent = self.Sidebar,
        Size = UDim2.new(1, -4, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.BackgroundHover,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })

    Create("UIPadding", {
        Parent = self.SidebarContent,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
    })

    Create("UIListLayout", {
        Parent = self.SidebarContent,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- Content Area
    self.ContentArea = Create("Frame", {
        Name = "Content",
        Parent = self.Container,
        Size = UDim2.new(1, -self.Config.SidebarWidth, 1, 0),
        Position = UDim2.new(0, self.Config.SidebarWidth, 0, 0),
        BackgroundTransparency = 1,
    })

    -- Content Header
    self.ContentHeader = Create("Frame", {
        Name = "Header",
        Parent = self.ContentArea,
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
    })

    self.Breadcrumb = Create("TextLabel", {
        Name = "Breadcrumb",
        Parent = self.ContentHeader,
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = "Hexed / Combat",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = self.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Settings Button
    self.SettingsBtn = Create("TextButton", {
        Name = "SettingsBtn",
        Parent = self.ContentHeader,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -52, 0.5, -16),
        BackgroundColor3 = self.Theme.BackgroundTertiary,
        Text = "⚙",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = self.Theme.TextSecondary,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    Create("UICorner", { Parent = self.SettingsBtn, CornerRadius = UDim.new(0, 6) })

    self.SettingsBtn.MouseEnter:Connect(function()
        Tween(self.SettingsBtn, { BackgroundColor3 = self.Theme.BackgroundHover }, 0.15)
    end)
    self.SettingsBtn.MouseLeave:Connect(function()
        Tween(self.SettingsBtn, { BackgroundColor3 = self.Theme.BackgroundTertiary }, 0.15)
    end)
    self.SettingsBtn.MouseButton1Click:Connect(function()
        self:ToggleSettings()
    end)

    -- Panel Grid
    self.PanelGrid = Create("Frame", {
        Name = "PanelGrid",
        Parent = self.ContentArea,
        Size = UDim2.new(1, -self.Config.PanelGap * 2, 1, -48 - self.Config.PanelGap),
        Position = UDim2.new(0, self.Config.PanelGap, 0, 48),
        BackgroundTransparency = 1,
    })

    -- Status Bar
    self.StatusBar = Create("Frame", {
        Name = "StatusBar",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 1, -28),
        BackgroundColor3 = self.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
    })

    Create("Frame", {
        Parent = self.StatusBar,
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = self.Theme.Border,
        BorderSizePixel = 0,
    })

    self.StatusText = Create("TextLabel", {
        Parent = self.StatusBar,
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = "● Connected    FPS: 60    Ping: 24ms    v2.0.0",
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = self.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- FPS Counter
    self.FPS = 60
    self.FrameCount = 0
    self.LastFPSTime = tick()

    RunService.RenderStepped:Connect(function()
        self.FrameCount = self.FrameCount + 1
        local now = tick()
        if now - self.LastFPSTime >= 1 then
            self.FPS = math.floor(self.FrameCount / (now - self.LastFPSTime))
            self.FrameCount = 0
            self.LastFPSTime = now
            self.StatusText.Text = string.format("● Connected    FPS: %d    Ping: --ms    v2.0.0", self.FPS)
        end
    end)

    -- Update shadow position
    self.MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        self.Shadow.Position = UDim2.new(0, self.MainFrame.AbsolutePosition.X - 30, 0, self.MainFrame.AbsolutePosition.Y - 30)
    end)

    self.MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        self.Shadow.Size = UDim2.new(0, self.MainFrame.AbsoluteSize.X + 60, 0, self.MainFrame.AbsoluteSize.Y + 60)
    end)
end

-- ============================================
-- DRAGGING
-- ============================================
function Hexed:MakeDraggable()
    if not self.Config.Draggable then return end

    local dragging = false
    local dragStart = nil
    local startPos = nil

    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
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
end

-- ============================================
-- RESIZING
-- ============================================
function Hexed:MakeResizable()
    if not self.Config.Resizable then return end

    local handles = {}
    local directions = {
        { name = "N", pos = UDim2.new(0.5, 0, 0, -4), size = UDim2.new(1, -self.Config.CornerRadius * 2, 0, 8), cursor = "SizeNS" },
        { name = "S", pos = UDim2.new(0.5, 0, 1, -4), size = UDim2.new(1, -self.Config.CornerRadius * 2, 0, 8), cursor = "SizeNS" },
        { name = "W", pos = UDim2.new(0, -4, 0.5, 0), size = UDim2.new(0, 8, 1, -self.Config.CornerRadius * 2), cursor = "SizeWE" },
        { name = "E", pos = UDim2.new(1, -4, 0.5, 0), size = UDim2.new(0, 8, 1, -self.Config.CornerRadius * 2), cursor = "SizeWE" },
        { name = "NW", pos = UDim2.new(0, -4, 0, -4), size = UDim2.new(0, 12, 0, 12), cursor = "SizeNWSE" },
        { name = "NE", pos = UDim2.new(1, -8, 0, -4), size = UDim2.new(0, 12, 0, 12), cursor = "SizeNESW" },
        { name = "SW", pos = UDim2.new(0, -4, 1, -8), size = UDim2.new(0, 12, 0, 12), cursor = "SizeNESW" },
        { name = "SE", pos = UDim2.new(1, -8, 1, -8), size = UDim2.new(0, 12, 0, 12), cursor = "SizeNWSE" },
    }

    for _, dir in ipairs(directions) do
        local handle = Create("Frame", {
            Name = "Resize" .. dir.name,
            Parent = self.MainFrame,
            Size = dir.size,
            Position = dir.pos,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })

        handle.MouseEnter:Connect(function()
            handle.BackgroundColor3 = self.Config.AccentColor
            handle.BackgroundTransparency = 0.5
        end)

        handle.MouseLeave:Connect(function()
            handle.BackgroundTransparency = 1
        end)

        local resizing = false
        local startSize = nil
        local startPos = nil
        local startInput = nil

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                startSize = self.MainFrame.Size
                startPos = self.MainFrame.Position
                startInput = input.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - startInput
                local newWidth = startSize.X.Offset
                local newHeight = startSize.Y.Offset
                local newX = startPos.X.Offset
                local newY = startPos.Y.Offset

                if dir.name:find("E") then
                    newWidth = math.max(self.Config.MinSize.X, startSize.X.Offset + delta.X)
                end
                if dir.name:find("W") then
                    newWidth = math.max(self.Config.MinSize.X, startSize.X.Offset - delta.X)
                    newX = startPos.X.Offset + (startSize.X.Offset - newWidth)
                end
                if dir.name:find("S") then
                    newHeight = math.max(self.Config.MinSize.Y, startSize.Y.Offset + delta.Y)
                end
                if dir.name:find("N") then
                    newHeight = math.max(self.Config.MinSize.Y, startSize.Y.Offset - delta.Y)
                    newY = startPos.Y.Offset + (startSize.Y.Offset - newHeight)
                end

                self.MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
                self.MainFrame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
            end
        end)

        table.insert(handles, handle)
    end

    self.ResizeHandles = handles
end

-- ============================================
-- TAB SYSTEM
-- ============================================
function Hexed:AddTab(name, icon)
    local tab = {
        Name = name,
        Icon = icon or "📄",
        Panels = {},
        Button = nil,
        Content = nil,
    }

    -- Sidebar Button
    tab.Button = Create("TextButton", {
        Name = name .. "Tab",
        Parent = self.SidebarContent,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    })

    local btnCorner = Create("UICorner", {
        Parent = tab.Button,
        CornerRadius = UDim.new(0, 6),
    })

    local iconLabel = Create("TextLabel", {
        Parent = tab.Button,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0.5, -10),
        BackgroundTransparency = 1,
        Text = icon,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
    })

    local textLabel = Create("TextLabel", {
        Parent = tab.Button,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = self.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    tab.Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.Button, { BackgroundColor3 = self.Theme.BackgroundHover, BackgroundTransparency = 0.5 }, 0.15)
            Tween(textLabel, { TextColor3 = self.Theme.TextPrimary }, 0.15)
        end
    end)

    tab.Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.Button, { BackgroundTransparency = 1 }, 0.15)
            Tween(textLabel, { TextColor3 = self.Theme.TextSecondary }, 0.15)
        end
    end)

    tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)

    -- Content Frame
    tab.Content = Create("Frame", {
        Name = name .. "Content",
        Parent = self.PanelGrid,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
    })

    local gridLayout = Create("UIGridLayout", {
        Parent = tab.Content,
        CellSize = UDim2.new(0.5, -self.Config.PanelGap / 2, 0.5, -self.Config.PanelGap / 2),
        CellPadding = UDim2.new(0, self.Config.PanelGap, 0, self.Config.PanelGap),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    table.insert(self.Tabs, tab)

    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end

    return tab
end

function Hexed:SwitchTab(tab)
    if self.ActiveTab == tab then return end

    if self.ActiveTab then
        self.ActiveTab.Content.Visible = false
        Tween(self.ActiveTab.Button, { BackgroundTransparency = 1 }, 0.2)
        self.ActiveTab.Button:FindFirstChildOfClass("TextLabel").TextColor3 = self.Theme.TextSecondary
    end

    self.ActiveTab = tab
    tab.Content.Visible = true
    Tween(tab.Button, { BackgroundColor3 = Color3.fromRGB(88, 166, 255), BackgroundTransparency = 0.9 }, 0.2)
    tab.Button:FindFirstChildOfClass("TextLabel").TextColor3 = self.Config.AccentColor

    self.Breadcrumb.Text = "Hexed / " .. tab.Name
end

-- ============================================
-- PANEL SYSTEM
-- ============================================
function Hexed:AddPanel(tab, title, icon)
    local panel = Create("Frame", {
        Name = title .. "Panel",
        Parent = tab.Content,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        LayoutOrder = #tab.Content:GetChildren(),
    })

    Create("UICorner", {
        Parent = panel,
        CornerRadius = UDim.new(0, 8),
    })

    -- Panel Header
    local header = Create("Frame", {
        Name = "Header",
        Parent = panel,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
    })

    Create("TextLabel", {
        Parent = header,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = (icon or "📦") .. " " .. title:upper(),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = self.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 0.5,
    })

    -- Panel Content
    local content = Create("ScrollingFrame", {
        Name = "Content",
        Parent = panel,
        Size = UDim2.new(1, -24, 1, -48),
        Position = UDim2.new(0, 12, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.BackgroundHover,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })

    Create("UIListLayout", {
        Parent = content,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    panel.Content = content
    return panel
end

-- ============================================
-- UI ELEMENTS
-- ============================================
function Hexed:CreateToggle(parent, text, default, callback)
    local frame = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
    })

    local label = Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local toggle = Create("Frame", {
        Parent = frame,
        Size = UDim2.new(0, 40, 0, 22),
        Position = UDim2.new(1, -40, 0.5, -11),
        BackgroundColor3 = default and self.Config.AccentColor or self.Theme.BackgroundTertiary,
        BorderSizePixel = 0,
    })

    Create("UICorner", { Parent = toggle, CornerRadius = UDim.new(1, 0) })

    local knob = Create("Frame", {
        Parent = toggle,
        Size = UDim2.new(0, 18, 0, 18),
        Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    })

    Create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

    local enabled = default

    local function updateToggle()
        enabled = not enabled
        Tween(toggle, { BackgroundColor3 = enabled and self.Config.AccentColor or self.Theme.BackgroundTertiary }, 0.2)
        Tween(knob, { Position = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9) }, 0.2)
        if callback then callback(enabled) end
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateToggle()
        end
    end)

    return { Frame = frame, Get = function() return enabled end, Set = function(v) 
        if v ~= enabled then updateToggle() end 
    end }
end

function Hexed:CreateSlider(parent, text, min, max, default, decimals, suffix, callback)
    decimals = decimals or 0
    suffix = suffix or ""

    local frame = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
    })

    local label = Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(0.6, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = self.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local valueLabel = Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(0.4, 0, 0, 20),
        Position = UDim2.new(0.6, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default) .. suffix,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = self.Config.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    local sliderBg = Create("Frame", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundColor3 = self.Theme.BackgroundTertiary,
        BorderSizePixel = 0,
    })

    Create("UICorner", { Parent = sliderBg, CornerRadius = UDim.new(1, 0) })

    local sliderFill = Create("Frame", {
        Parent = sliderBg,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = self.Config.AccentColor,
        BorderSizePixel = 0,
    })

    Create("UICorner", { Parent = sliderFill, CornerRadius = UDim.new(1, 0) })

    local knob = Create("Frame", {
        Parent = sliderBg,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
        BackgroundColor3 = self.Config.AccentColor,
        BorderSizePixel = 0,
    })

    Create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

    local dragging = false
    local currentValue = default

    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * pos
        value = Round(value, decimals)
        currentValue = value

        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -7, 0.5, -7)
        valueLabel.Text = tostring(value) .. suffix

        if callback then callback(value) end
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    return { Frame = frame, Get = function() return currentValue end, Set = function(v)
        currentValue = math.clamp(v, min, max)
        local pos = (currentValue - min) / (max - min)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -7, 0.5, -7)
        valueLabel.Text = tostring(currentValue) .. suffix
    end }
end

function Hexed:CreateDropdown(parent, text, options, default, callback)
    local frame = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
    })

    local label = Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = self.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local dropdown = Create("TextButton", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = self.Theme.BackgroundTertiary,
        Text = default or options[1],
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.Theme.TextPrimary,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })

    Create("UICorner", { Parent = dropdown, CornerRadius = UDim.new(0, 6) })

    local arrow = Create("TextLabel", {
        Parent = dropdown,
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -24, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = self.Theme.TextSecondary,
    })

    local menu = Create("Frame", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, #options * 28),
        Position = UDim2.new(0, 0, 0, 58),
        BackgroundColor3 = self.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10,
    })

    Create("UICorner", { Parent = menu, CornerRadius = UDim.new(0, 6) })

    Create("UIListLayout", {
        Parent = menu,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    Create("UIPadding", {
        Parent = menu,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
    })

    for i, option in ipairs(options) do
        local btn = Create("TextButton", {
            Parent = menu,
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
            Text = option,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = self.Theme.TextPrimary,
            AutoButtonColor = false,
        })

        btn.MouseEnter:Connect(function()
            Tween(btn, { BackgroundTransparency = 0.9, BackgroundColor3 = self.Theme.BackgroundHover }, 0.1)
        end)

        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundTransparency = 1 }, 0.1)
        end)

        btn.MouseButton1Click:Connect(function()
            dropdown.Text = option
            menu.Visible = false
            arrow.Text = "▼"
            if callback then callback(option) end
        end)
    end

    dropdown.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
        arrow.Text = menu.Visible and "▲" or "▼"
    end)

    return { Frame = frame, Get = function() return dropdown.Text end }
end

function Hexed:CreateButton(parent, text, callback)
    local btn = Create("TextButton", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = self.Config.AccentColor,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })

    Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 6) })

    btn.MouseEnter:Connect(function()
        Tween(btn, { BackgroundColor3 = Color3.fromRGB(
            math.min(self.Config.AccentColor.R * 255 + 30, 255),
            math.min(self.Config.AccentColor.G * 255 + 30, 255),
            math.min(self.Config.AccentColor.B * 255 + 30, 255)
        ) }, 0.15)
    end)

    btn.MouseLeave:Connect(function()
        Tween(btn, { BackgroundColor3 = self.Config.AccentColor }, 0.15)
    end)

    btn.MouseButton1Click:Connect(function()
        Tween(btn, { Size = UDim2.new(0.98, 0, 0, 32) }, 0.05)
        task.wait(0.05)
        Tween(btn, { Size = UDim2.new(1, 0, 0, 34) }, 0.1)
        if callback then callback() end
    end)

    return btn
end

-- ============================================
-- SETTINGS PANEL
-- ============================================
function Hexed:BuildSettingsPanel()
    self.SettingsPanel = Create("Frame", {
        Name = "SettingsPanel",
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, -250, 0.5, -200),
        BackgroundColor3 = self.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 100,
    })

    Create("UICorner", {
        Parent = self.SettingsPanel,
        CornerRadius = UDim.new(0, self.Config.CornerRadius),
    })

    -- Shadow
    local settingsShadow = Create("ImageLabel", {
        Parent = self.SettingsPanel,
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = -1,
    })

    -- Header
    local header = Create("Frame", {
        Parent = self.SettingsPanel,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
    })

    Create("TextLabel", {
        Parent = header,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = "GUI Settings",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = self.Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local closeBtn = Create("TextButton", {
        Parent = header,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -44, 0.5, -16),
        BackgroundColor3 = self.Theme.BackgroundTertiary,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = self.Theme.TextSecondary,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })

    Create("UICorner", { Parent = closeBtn, CornerRadius = UDim.new(0, 6) })

    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, { BackgroundColor3 = Color3.fromRGB(248, 81, 73), TextColor3 = Color3.new(1, 1, 1) }, 0.15)
    end)

    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, { BackgroundColor3 = self.Theme.BackgroundTertiary, TextColor3 = self.Theme.TextSecondary }, 0.15)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        self:ToggleSettings()
    end)

    -- Content
    local content = Create("ScrollingFrame", {
        Parent = self.SettingsPanel,
        Size = UDim2.new(1, -40, 1, -110),
        Position = UDim2.new(0, 20, 0, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.BackgroundHover,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })

    Create("UIListLayout", {
        Parent = content,
        Padding = UDim.new(0, 16),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- Corner Radius Slider
    self:CreateSlider(content, "Window Border Radius", 0, 32, self.Config.CornerRadius, 0, "px", function(v)
        self.Config.CornerRadius = v
        self.Corner.CornerRadius = UDim.new(0, v)
        self.SettingsPanel:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, v)
    end)

    -- Panel Gap Slider
    self:CreateSlider(content, "Panel Gap", 0, 24, self.Config.PanelGap, 0, "px", function(v)
        self.Config.PanelGap = v
        for _, tab in ipairs(self.Tabs) do
            local layout = tab.Content:FindFirstChildOfClass("UIGridLayout")
            if layout then
                layout.CellPadding = UDim2.new(0, v, 0, v)
            end
        end
    end)

    -- Sidebar Width Slider
    self:CreateSlider(content, "Sidebar Width", 180, 400, self.Config.SidebarWidth, 0, "px", function(v)
        self.Config.SidebarWidth = v
        self.Sidebar.Size = UDim2.new(0, v, 1, 0)
        self.ContentArea.Size = UDim2.new(1, -v, 1, 0)
        self.ContentArea.Position = UDim2.new(0, v, 0, 0)
    end)

    -- Opacity Slider
    self:CreateSlider(content, "Window Opacity", 50, 100, 100, 0, "%", function(v)
        self.MainFrame.BackgroundTransparency = 1 - (v / 100)
    end)

    -- Theme Dropdown
    self:CreateDropdown(content, "Theme", {"Obsidian", "Midnight", "Ocean", "Forest", "Crimson"}, self.Config.Theme, function(theme)
        self.Config.Theme = theme
        self.Theme = THEMES[theme] or THEMES.Obsidian
        self:ApplyTheme()
    end)

    -- Accent Color Picker
    local colorFrame = Create("Frame", {
        Parent = content,
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1,
    })

    Create("TextLabel", {
        Parent = colorFrame,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "Accent Color",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = self.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local colors = {
        Color3.fromRGB(88, 166, 255),
        Color3.fromRGB(163, 113, 247),
        Color3.fromRGB(63, 185, 80),
        Color3.fromRGB(248, 81, 73),
        Color3.fromRGB(210, 153, 34),
        Color3.fromRGB(247, 120, 186),
        Color3.fromRGB(86, 212, 221),
        Color3.fromRGB(255, 255, 255),
    }

    for i, color in ipairs(colors) do
        local btn = Create("TextButton", {
            Parent = colorFrame,
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(0, (i - 1) * 36, 0, 30),
            BackgroundColor3 = color,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })

        Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 6) })

        local stroke = Create("UIStroke", {
            Parent = btn,
            Color = self.Theme.Border,
            Thickness = 2,
        })

        if color == self.Config.AccentColor then
            stroke.Color = Color3.new(1, 1, 1)
            stroke.Thickness = 3
        end

        btn.MouseButton1Click:Connect(function()
            self.Config.AccentColor = color
            for _, child in ipairs(colorFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:FindFirstChildOfClass("UIStroke").Color = self.Theme.Border
                    child:FindFirstChildOfClass("UIStroke").Thickness = 2
                end
            end
            stroke.Color = Color3.new(1, 1, 1)
            stroke.Thickness = 3
            self:ApplyTheme()
        end)
    end

    -- Save Button
    local saveBtn = self:CreateButton(self.SettingsPanel, "Save Changes", function()
        self:ToggleSettings()
    end)
    saveBtn.Size = UDim2.new(0, 200, 0, 36)
    saveBtn.Position = UDim2.new(1, -220, 1, -50)
    saveBtn.Parent = self.SettingsPanel
end

function Hexed:ApplyTheme()
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.TitleBar.BackgroundColor3 = self.Theme.BackgroundSecondary
    self.Sidebar.BackgroundColor3 = self.Theme.BackgroundSecondary
    self.StatusBar.BackgroundColor3 = self.Theme.BackgroundSecondary
    self.SettingsPanel.BackgroundColor3 = self.Theme.BackgroundSecondary

    self.TitleText.TextColor3 = self.Theme.TextPrimary
    self.Breadcrumb.TextColor3 = self.Theme.TextSecondary
    self.StatusText.TextColor3 = self.Theme.TextSecondary
end

function Hexed:ToggleSettings()
    self.SettingsPanel.Visible = not self.SettingsPanel.Visible
    if self.SettingsPanel.Visible then
        Tween(self.SettingsPanel, { Size = UDim2.new(0, 500, 0, 400) }, 0.3)
    end
end

-- ============================================
-- WINDOW CONTROLS
-- ============================================
function Hexed:Close()
    Tween(self.MainFrame, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.3)
    Tween(self.Shadow, { ImageTransparency = 1 }, 0.3)
    task.wait(0.3)
    self.ScreenGui:Destroy()
end

function Hexed:Minimize()
    if self.IsMinimized then
        Tween(self.MainFrame, { Size = self.OriginalSize }, 0.3)
        self.IsMinimized = false
    else
        self.OriginalSize = self.MainFrame.Size
        Tween(self.MainFrame, { Size = UDim2.new(0, self.MainFrame.AbsoluteSize.X, 0, 40) }, 0.3)
        self.IsMinimized = true
    end
end

function Hexed:Maximize()
    if self.IsMaximized then
        Tween(self.MainFrame, { Size = self.OriginalSize, Position = self.OriginalPosition }, 0.3)
        self.Corner.CornerRadius = UDim.new(0, self.Config.CornerRadius)
        self.IsMaximized = false
    else
        self.OriginalSize = self.MainFrame.Size
        self.OriginalPosition = self.MainFrame.Position
        Tween(self.MainFrame, { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0) }, 0.3)
        self.Corner.CornerRadius = UDim.new(0, 0)
        self.IsMaximized = true
    end
end

-- ============================================
-- NOTIFICATIONS
-- ============================================
function Hexed:Notify(title, message, duration)
    duration = duration or 3

    local notif = Create("Frame", {
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 300, 0, 70),
        Position = UDim2.new(1, -320, 1, -90),
        BackgroundColor3 = self.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        ZIndex = 1000,
    })

    Create("UICorner", { Parent = notif, CornerRadius = UDim.new(0, 8) })

    Create("UIStroke", {
        Parent = notif,
        Color = self.Theme.Border,
        Thickness = 1,
    })

    Create("TextLabel", {
        Parent = notif,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 12, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = self.Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1001,
    })

    Create("TextLabel", {
        Parent = notif,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 12, 0, 32),
        BackgroundTransparency = 1,
        Text = message,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = self.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 1001,
    })

    notif.Position = UDim2.new(1, 20, 1, -90)
    Tween(notif, { Position = UDim2.new(1, -320, 1, -90) }, 0.4, Enum.EasingStyle.Back)

    task.delay(duration, function()
        Tween(notif, { Position = UDim2.new(1, 20, 1, -90) }, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.wait(0.4)
        notif:Destroy()
    end)
end

-- ============================================
-- RETURN
-- ============================================
return Hexed
