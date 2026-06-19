-- ============================================================
-- Delta Admin v1 — Full Edition
-- Залей этот файл на GitHub как main.lua
-- В Delta вставляй:
-- loadstring(game:HttpGet("ССЫЛКА"))()
-- ============================================================

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Light = game:GetService("Lighting")
local WS = game:GetService("Workspace")
local SG = game:GetService("StarterGui")
local SS = game:GetService("SoundService")
local VU = game:GetService("VirtualUser")
local TPS = game:GetService("TeleportService")
local Cam = WS.CurrentCamera
local LP = Players.LocalPlayer
local Mobile = false
pcall(function()
    Mobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
end)

-- ============================================================
-- СИСТЕМА ПОДКЛЮЧЕНИЙ
-- ============================================================
local Conns = {}

local function tagConn(tag, conn)
    if not Conns[tag] then
        Conns[tag] = {}
    end
    table.insert(Conns[tag], conn)
end

local function cleanTag(tag)
    if Conns[tag] then
        for i = 1, #Conns[tag] do
            pcall(function()
                Conns[tag][i]:Disconnect()
            end)
        end
        Conns[tag] = {}
    end
end

-- ============================================================
-- УТИЛИТЫ
-- ============================================================
local function getChar()
    local ch = LP.Character
    if not ch then
        return nil, nil, nil
    end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    return ch, hum, hrp
end

local function notify(txt)
    pcall(function()
        SG:SetCore("SendNotification", {
            Title = "Delta Admin",
            Text = txt,
            Duration = 3
        })
    end)
end

local StateFlags = {}
local savedPos1 = nil
local savedPos2 = nil
local savedPos3 = nil
local currentMusic = nil

-- ============================================================
-- СОЗДАНИЕ GUI
-- ============================================================
local oldGui = nil
pcall(function()
    oldGui = game:GetService("CoreGui"):FindFirstChild("DeltaAdminV1")
    if oldGui then
        oldGui:Destroy()
    end
end)
pcall(function()
    oldGui = LP:FindFirstChild("PlayerGui")
    if oldGui then
        local old2 = oldGui:FindFirstChild("DeltaAdminV1")
        if old2 then
            old2:Destroy()
        end
    end
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "DeltaAdminV1"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiOk = false
pcall(function()
    Gui.Parent = game:GetService("CoreGui")
    guiOk = true
end)
if not guiOk then
    pcall(function()
        Gui.Parent = LP:WaitForChild("PlayerGui")
    end)
end

-- ============================================================
-- ЦВЕТА
-- ============================================================
local ColBg = Color3.fromRGB(10, 10, 20)
local ColCard = Color3.fromRGB(24, 24, 42)
local ColAccent = Color3.fromRGB(130, 80, 255)
local ColGreen = Color3.fromRGB(45, 225, 105)
local ColRed = Color3.fromRGB(255, 60, 60)
local ColText = Color3.fromRGB(245, 245, 255)
local ColDim = Color3.fromRGB(130, 130, 160)
local ColCyan = Color3.fromRGB(0, 215, 255)
local ColOrange = Color3.fromRGB(255, 150, 40)
local ColPink = Color3.fromRGB(255, 90, 200)
local ColYellow = Color3.fromRGB(255, 220, 50)
local ColSide = Color3.fromRGB(14, 14, 26)

-- ============================================================
-- ПЛАВАЮЩАЯ КНОПКА
-- ============================================================
local fbSize = 50
if Mobile then
    fbSize = 58
end

local FB = Instance.new("TextButton")
FB.Name = "FloatBtn"
FB.Size = UDim2.new(0, fbSize, 0, fbSize)
FB.Position = UDim2.new(0, 16, 0.5, 0)
FB.BackgroundColor3 = ColAccent
FB.Text = "ADM"
FB.TextColor3 = ColText
FB.TextSize = 12
FB.Font = Enum.Font.GothamBold
FB.AutoButtonColor = false
FB.BorderSizePixel = 0
FB.ZIndex = 100
FB.Parent = Gui

local fbCorner = Instance.new("UICorner")
fbCorner.CornerRadius = UDim.new(1, 0)
fbCorner.Parent = FB

local fbStroke = Instance.new("UIStroke")
fbStroke.Color = ColAccent
fbStroke.Thickness = 2
fbStroke.Parent = FB

-- Пульсация
task.spawn(function()
    while true do
        pcall(function()
            local tw1 = TS:Create(fbStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.8})
            tw1:Play()
            tw1.Completed:Wait()
            local tw2 = TS:Create(fbStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0})
            tw2:Play()
            tw2.Completed:Wait()
        end)
        task.wait(0.1)
    end
end)

-- Перетаскивание кнопки
local fDragging = false
local fDragStart = nil
local fStartPos = nil
local fMoved = false

FB.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fDragging = true
        fMoved = false
        fDragStart = input.Position
        fStartPos = FB.Position
    end
end)

FB.InputChanged:Connect(function(input)
    if fDragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - fDragStart
            if delta.Magnitude > 5 then
                fMoved = true
            end
            FB.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fDragging = false
    end
end)

-- ============================================================
-- ГЛАВНОЕ ОКНО
-- ============================================================
local mW = 390
local mH = 460
if Mobile then
    mW = 410
    mH = 480
end

local MF = Instance.new("Frame")
MF.Name = "MainFrame"
MF.Size = UDim2.new(0, 0, 0, 0)
MF.Position = UDim2.new(0.5, 0, 0.5, 0)
MF.AnchorPoint = Vector2.new(0.5, 0.5)
MF.BackgroundColor3 = ColBg
MF.BorderSizePixel = 0
MF.Visible = false
MF.ZIndex = 50
MF.ClipsDescendants = true
MF.Parent = Gui

local mfCorner = Instance.new("UICorner")
mfCorner.CornerRadius = UDim.new(0, 14)
mfCorner.Parent = MF

local mfStroke = Instance.new("UIStroke")
mfStroke.Color = ColAccent
mfStroke.Thickness = 2
mfStroke.Parent = MF

local menuOpen = false

local function openMenu()
    if menuOpen then
        return
    end
    menuOpen = true
    MF.Visible = true
    MF.Size = UDim2.new(0, 0, 0, 0)
    local tw = TS:Create(MF, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, mW, 0, mH)})
    tw:Play()
end

local function closeMenu()
    if not menuOpen then
        return
    end
    local tw = TS:Create(MF, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
    tw:Play()
    tw.Completed:Connect(function()
        MF.Visible = false
        menuOpen = false
    end)
end

FB.MouseButton1Click:Connect(function()
    if fMoved then
        return
    end
    if menuOpen then
        closeMenu()
    else
        openMenu()
    end
end)

-- Перетаскивание окна
local mDragging = false
local mDragStart = nil
local mDragPos = nil

-- ============================================================
-- БОКОВАЯ ПАНЕЛЬ
-- ============================================================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 52, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = ColSide
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 51
Sidebar.Parent = MF

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 14)
sbCorner.Parent = Sidebar

local sbCover = Instance.new("Frame")
sbCover.Name = "SBCover"
sbCover.Size = UDim2.new(0, 14, 1, 0)
sbCover.Position = UDim2.new(1, -14, 0, 0)
sbCover.BackgroundColor3 = ColSide
sbCover.BorderSizePixel = 0
sbCover.ZIndex = 51
sbCover.Parent = Sidebar

local sbDivider = Instance.new("Frame")
sbDivider.Name = "SBDivider"
sbDivider.Size = UDim2.new(0, 1, 1, -10)
sbDivider.Position = UDim2.new(1, -1, 0, 5)
sbDivider.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
sbDivider.BorderSizePixel = 0
sbDivider.ZIndex = 52
sbDivider.Parent = Sidebar

-- Логотип
local LogoLabel = Instance.new("TextLabel")
LogoLabel.Name = "Logo"
LogoLabel.Size = UDim2.new(0, 38, 0, 38)
LogoLabel.Position = UDim2.new(0.5, 0, 0, 6)
LogoLabel.AnchorPoint = Vector2.new(0.5, 0)
LogoLabel.BackgroundColor3 = ColAccent
LogoLabel.Text = "ADM"
LogoLabel.TextColor3 = ColText
LogoLabel.TextSize = 10
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.BorderSizePixel = 0
LogoLabel.ZIndex = 53
LogoLabel.Parent = Sidebar

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(1, 0)
logoCorner.Parent = LogoLabel

-- Прокрутка боковой панели
local SBScroll = Instance.new("ScrollingFrame")
SBScroll.Name = "SBScroll"
SBScroll.Size = UDim2.new(1, 0, 1, -52)
SBScroll.Position = UDim2.new(0, 0, 0, 52)
SBScroll.BackgroundTransparency = 1
SBScroll.BorderSizePixel = 0
SBScroll.ScrollBarThickness = 0
SBScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SBScroll.ZIndex = 53
SBScroll.Parent = Sidebar

local sbLayout = Instance.new("UIListLayout")
sbLayout.FillDirection = Enum.FillDirection.Vertical
sbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sbLayout.Padding = UDim.new(0, 3)
sbLayout.SortOrder = Enum.SortOrder.LayoutOrder
sbLayout.Parent = SBScroll

sbLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SBScroll.CanvasSize = UDim2.new(0, 0, 0, sbLayout.AbsoluteContentSize.Y + 8)
end)

-- ============================================================
-- ПРАВАЯ ЧАСТЬ
-- ============================================================
local RightArea = Instance.new("Frame")
RightArea.Name = "RightArea"
RightArea.Size = UDim2.new(1, -52, 1, 0)
RightArea.Position = UDim2.new(0, 52, 0, 0)
RightArea.BackgroundTransparency = 1
RightArea.BorderSizePixel = 0
RightArea.ZIndex = 51
RightArea.Parent = MF

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundTransparency = 1
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 52
TitleBar.Parent = RightArea

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mDragging = true
        mDragStart = input.Position
        mDragPos = MF.Position
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if mDragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - mDragStart
            MF.Position = UDim2.new(mDragPos.X.Scale, mDragPos.X.Offset + delta.X, mDragPos.Y.Scale, mDragPos.Y.Offset + delta.Y)
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mDragging = false
    end
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -44, 1, 0)
TitleLabel.Position = UDim2.new(0, 8, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.BorderSizePixel = 0
TitleLabel.Text = "Delta Admin v1"
TitleLabel.TextColor3 = ColText
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 53
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 4)
CloseBtn.BackgroundColor3 = ColRed
CloseBtn.Text = "X"
CloseBtn.TextColor3 = ColText
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 54
CloseBtn.Parent = TitleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    pcall(function()
        closeMenu()
    end)
end)

-- ============================================================
-- ПОЛЕ ПОИСКА
-- ============================================================
local SearchFrame = Instance.new("Frame")
SearchFrame.Name = "SearchFrame"
SearchFrame.Size = UDim2.new(1, -8, 0, 28)
SearchFrame.Position = UDim2.new(0, 4, 0, 37)
SearchFrame.BackgroundColor3 = ColCard
SearchFrame.BorderSizePixel = 0
SearchFrame.ZIndex = 52
SearchFrame.Parent = RightArea

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = SearchFrame

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -10, 1, 0)
SearchBox.Position = UDim2.new(0, 5, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.BorderSizePixel = 0
SearchBox.Text = ""
SearchBox.PlaceholderText = "Поиск команд..."
SearchBox.PlaceholderColor3 = ColDim
SearchBox.TextColor3 = ColText
SearchBox.TextSize = 12
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.ZIndex = 53
SearchBox.Parent = SearchFrame

-- Контент
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "Content"
ContentScroll.Size = UDim2.new(1, -6, 1, -70)
ContentScroll.Position = UDim2.new(0, 3, 0, 68)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = ColAccent
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.ZIndex = 52
ContentScroll.Parent = RightArea

local contentLayout = Instance.new("UIListLayout")
contentLayout.FillDirection = Enum.FillDirection.Vertical
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.Padding = UDim.new(0, 3)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = ContentScroll

contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
end)

-- ============================================================
-- СИСТЕМА СТРАНИЦ
-- ============================================================
local PageFrames = {}
local SidebarBtns = {}
local AllCards = {}
local layoutCounter = 0
local currentPageName = ""

local Categories = {
    {name = "Move", label = "MOV"},
    {name = "Combat", label = "CMB"},
    {name = "Troll", label = "TRL"},
    {name = "Visual", label = "VIS"},
    {name = "TP", label = "TP"},
    {name = "Modes", label = "MOD"},
    {name = "World", label = "WLD"},
    {name = "Music", label = "MUS"},
}

for idx, cat in ipairs(Categories) do
    local pageFrame = Instance.new("Frame")
    pageFrame.Name = "Page_" .. cat.name
    pageFrame.Size = UDim2.new(1, 0, 0, 0)
    pageFrame.BackgroundTransparency = 1
    pageFrame.BorderSizePixel = 0
    pageFrame.Visible = false
    pageFrame.ZIndex = 52
    pageFrame.AutomaticSize = Enum.AutomaticSize.Y
    pageFrame.Parent = ContentScroll

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.FillDirection = Enum.FillDirection.Vertical
    pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pageLayout.Padding = UDim.new(0, 3)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = pageFrame

    PageFrames[cat.name] = pageFrame

    local sBtn = Instance.new("TextButton")
    sBtn.Name = "SB_" .. cat.name
    sBtn.Size = UDim2.new(0, 38, 0, 38)
    sBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    sBtn.Text = cat.label
    sBtn.TextSize = 8
    sBtn.TextColor3 = ColText
    sBtn.Font = Enum.Font.GothamBold
    sBtn.AutoButtonColor = false
    sBtn.BorderSizePixel = 0
    sBtn.ZIndex = 54
    sBtn.LayoutOrder = idx
    sBtn.Parent = SBScroll

    local sBtnCorner = Instance.new("UICorner")
    sBtnCorner.CornerRadius = UDim.new(0, 10)
    sBtnCorner.Parent = sBtn

    SidebarBtns[cat.name] = sBtn
end

local function ShowPage(name)
    currentPageName = name
    for k, frame in pairs(PageFrames) do
        frame.Visible = (k == name)
    end
    TitleLabel.Text = "Delta - " .. name
    for k, btn in pairs(SidebarBtns) do
        if k == name then
            btn.BackgroundColor3 = ColAccent
        else
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        end
    end
    SearchBox.Text = ""
    -- Показать все карточки на текущей странице
    for i = 1, #AllCards do
        if AllCards[i].page == name then
            AllCards[i].frame.Visible = true
        end
    end
end

for idx, cat in ipairs(Categories) do
    SidebarBtns[cat.name].MouseButton1Click:Connect(function()
        pcall(function()
            ShowPage(cat.name)
        end)
    end)
end

-- ============================================================
-- ПОИСК
-- ============================================================
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    pcall(function()
        local query = string.lower(SearchBox.Text)
        if query == "" then
            for i = 1, #AllCards do
                if AllCards[i].page == currentPageName then
                    AllCards[i].frame.Visible = true
                end
            end
            return
        end
        for i = 1, #AllCards do
            if AllCards[i].page == currentPageName then
                local nameMatch = string.find(string.lower(AllCards[i].name), query, 1, true)
                local descMatch = string.find(string.lower(AllCards[i].desc), query, 1, true)
                if nameMatch or descMatch then
                    AllCards[i].frame.Visible = true
                else
                    AllCards[i].frame.Visible = false
                end
            end
        end
    end)
end)

-- ============================================================
-- КОНСТРУКТОРЫ ЭЛЕМЕНТОВ
-- ============================================================
local function nextOrder()
    layoutCounter = layoutCounter + 1
    return layoutCounter
end

local function Sec(pageName, text)
    local page = PageFrames[pageName]
    if not page then
        return
    end

    local frame = Instance.new("Frame")
    frame.Name = "Sec"
    frame.Size = UDim2.new(1, -6, 0, 22)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ZIndex = 52
    frame.LayoutOrder = nextOrder()
    frame.Parent = page

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Text = "  " .. string.upper(text)
    label.TextColor3 = ColAccent
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 53
    label.Parent = frame

    table.insert(AllCards, {page = pageName, name = text, desc = text, frame = frame})
end

local function Tog(pageName, name, desc, col, callback)
    local page = PageFrames[pageName]
    if not page then
        return
    end

    local isOn = false

    local card = Instance.new("Frame")
    card.Name = "Tog"
    card.Size = UDim2.new(1, -6, 0, 50)
    card.BackgroundColor3 = ColCard
    card.BorderSizePixel = 0
    card.ZIndex = 52
    card.LayoutOrder = nextOrder()
    card.Parent = page

    lo
