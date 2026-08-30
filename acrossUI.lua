-- ============================================================
--  UILibrary.lua  |  Skewed Dark UI  |  Roblox LocalScript
--  Usage example at the bottom of this file
-- ============================================================

local UILib = {}
UILib.__index = UILib

-- ── Services ────────────────────────────────────────────────
local Players        = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local RunService     = game:GetService("RunService")

local LocalPlayer    = Players.LocalPlayer
local Mouse          = LocalPlayer:GetMouse()

-- ── Constants ───────────────────────────────────────────────
local SKEW           = -8          -- degrees of italic slant (negative = leans right like image)
local SKEW_UDIM      = math.tan(math.rad(math.abs(SKEW)))

local COLOR = {
    BG          = Color3.fromRGB(18,  16,  14),   -- very dark brown-black (main panel)
    BG2         = Color3.fromRGB(28,  25,  22),   -- slightly lighter (sidebar, rows)
    BG3         = Color3.fromRGB(38,  34,  30),   -- hover / active rows
    SIDEBAR     = Color3.fromRGB(22,  20,  17),   -- left tab sidebar
    ACCENT      = Color3.fromRGB(255, 255, 255),  -- white text (active tab letter)
    TEXT        = Color3.fromRGB(200, 195, 185),  -- main text
    TEXT_DIM    = Color3.fromRGB(110, 105,  95),  -- dim labels / keybind
    SEPARATOR   = Color3.fromRGB(45,  40,  35),
    TOGGLE_OFF  = Color3.fromRGB(55,  50,  45),
    TOGGLE_ON   = Color3.fromRGB(255, 255, 255),
    TAB_ACTIVE  = Color3.fromRGB(38,  34,  30),
    TAB_IDLE    = Color3.fromRGB(22,  20,  17),
    CHECKBOX_OFF= Color3.fromRGB(40,  36,  32),
    CHECKBOX_ON = Color3.fromRGB(220, 215, 205),
    TITLE_DOT   = Color3.fromRGB(160, 145, 120),
    ARROW       = Color3.fromRGB(130, 120, 105),
}

local FONT     = Enum.Font.GothamBold
local FONT_REG = Enum.Font.Gotham
local TWEEN_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

-- ── Helpers ──────────────────────────────────────────────────
local function skewFrame(frame, deg)
    -- Apply UIGradient trick + negative X offset to simulate italic skew
    -- Real skew via ImageLabel rotation trick per row isn't needed;
    -- we use a container rotated slightly with ClipsDescendants=false
    -- For a pixel-perfect skew we tilt the whole ScreenGui frame holder.
    frame.Rotation = deg
end

local function new(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function tween(obj, props)
    TweenService:Create(obj, TWEEN_INFO, props):Play()
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            startPos  = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ── Window ───────────────────────────────────────────────────
function UILib.new(title, subtitle)
    local self = setmetatable({}, UILib)
    self.Tabs       = {}
    self.ActiveTab  = nil

    -- ScreenGui
    local sg = new("ScreenGui", {
        Name            = "UILibrary",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset  = true,
    }, (RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui")))

    -- Outer skew wrapper (rotated slightly to fake italic look)
    local skewWrap = new("Frame", {
        Name            = "SkewWrap",
        AnchorPoint     = Vector2.new(0.5, 0.5),
        Position        = UDim2.fromScale(0.5, 0.5),
        Size            = UDim2.fromOffset(420, 320),
        BackgroundTransparency = 1,
        ClipsDescendants= false,
        Rotation        = SKEW,
    }, sg)

    -- Main panel (un-rotated content inside skewed wrapper)
    local panel = new("Frame", {
        Name            = "Panel",
        Size            = UDim2.fromScale(1, 1),
        BackgroundColor3= COLOR.BG,
        BorderSizePixel = 0,
        ClipsDescendants= false,
        Rotation        = 0,
    }, skewWrap)
    new("UICorner",   {CornerRadius = UDim.new(0,4)}, panel)
    new("UIStroke",   {Color = COLOR.SEPARATOR, Thickness = 1}, panel)

    -- ── Title bar ────────────────────────────────────────────
    local titleBar = new("Frame", {
        Name            = "TitleBar",
        Size            = UDim2.new(1,0,0,30),
        BackgroundColor3= COLOR.BG2,
        BorderSizePixel = 0,
    }, panel)
    new("UICorner", {CornerRadius = UDim.new(0,4)}, titleBar)

    -- Title dot
    new("Frame", {
        Size            = UDim2.fromOffset(6,6),
        Position        = UDim2.new(0,10,0.5,0),
        AnchorPoint     = Vector2.new(0,0.5),
        BackgroundColor3= COLOR.TITLE_DOT,
        BorderSizePixel = 0,
    }, titleBar)

    -- Title text
    new("TextLabel", {
        Position        = UDim2.new(0,22,0,0),
        Size            = UDim2.new(1,-22,1,0),
        BackgroundTransparency = 1,
        Text            = (subtitle and (title.." · "..subtitle) or title),
        TextColor3      = COLOR.TEXT_DIM,
        Font            = FONT,
        TextSize        = 11,
        TextXAlignment  = Enum.TextXAlignment.Left,
    }, titleBar)

    makeDraggable(skewWrap, titleBar)

    -- ── Layout: sidebar + content ─────────────────────────────
    local body = new("Frame", {
        Name            = "Body",
        Position        = UDim2.fromOffset(0,30),
        Size            = UDim2.new(1,0,1,-30),
        BackgroundTransparency = 1,
        ClipsDescendants= false,
    }, panel)

    -- Sidebar (tab letters)
    local sidebar = new("Frame", {
        Name            = "Sidebar",
        Size            = UDim2.new(0,36,1,0),
        BackgroundColor3= COLOR.SIDEBAR,
        BorderSizePixel = 0,
    }, body)

    -- Content area
    local contentArea = new("Frame", {
        Name            = "Content",
        Position        = UDim2.fromOffset(36,0),
        Size            = UDim2.new(1,-36,1,0),
        BackgroundTransparency = 1,
        ClipsDescendants= true,
    }, body)

    local scrollFrame = new("ScrollingFrame", {
        Size                    = UDim2.fromScale(1,1),
        BackgroundTransparency  = 1,
        BorderSizePixel         = 0,
        ScrollBarThickness      = 2,
        ScrollBarImageColor3    = COLOR.SEPARATOR,
        CanvasSize              = UDim2.fromScale(1,0),
        AutomaticCanvasSize     = Enum.AutomaticSize.Y,
    }, contentArea)
    new("UIListLayout", {
        SortOrder   = Enum.SortOrder.LayoutOrder,
        Padding     = UDim.new(0,0),
    }, scrollFrame)

    -- Sidebar list layout
    new("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder}, sidebar)

    self._sg          = sg
    self._skewWrap    = skewWrap
    self._panel       = panel
    self._sidebar     = sidebar
    self._scrollFrame = scrollFrame
    self._tabCount    = 0

    return self
end

-- ── Add Tab ──────────────────────────────────────────────────
function UILib:AddTab(letter)
    self._tabCount = self._tabCount + 1
    local order    = self._tabCount
    local tabData  = { sections = {}, _order = order }

    -- Sidebar button
    local btn = new("TextButton", {
        Name            = "Tab_"..letter,
        Size            = UDim2.new(1,0,0,36),
        BackgroundColor3= COLOR.TAB_IDLE,
        BorderSizePixel = 0,
        Text            = letter,
        TextColor3      = COLOR.TEXT_DIM,
        Font            = FONT,
        TextSize        = 13,
        LayoutOrder     = order,
        AutoButtonColor = false,
    }, self._sidebar)
    new("UIStroke", {Color=COLOR.SEPARATOR, Thickness=1}, btn)

    -- Container in scroll (hidden by default)
    local container = new("Frame", {
        Name            = "Container_"..letter,
        Size            = UDim2.new(1,0,0,0),
        AutomaticSize   = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder     = order,
        Visible         = false,
    }, self._scrollFrame)
    new("UIListLayout", {
        SortOrder   = Enum.SortOrder.LayoutOrder,
        Padding     = UDim.new(0,2),
    }, container)
    new("UIPadding", {
        PaddingLeft  = UDim.new(0,6),
        PaddingRight = UDim.new(0,6),
        PaddingTop   = UDim.new(0,6),
        PaddingBottom= UDim.new(0,6),
    }, container)

    tabData._btn       = btn
    tabData._container = container
    tabData._lib       = self

    -- Switch tab on click
    btn.MouseButton1Click:Connect(function()
        self:_switchTab(tabData)
    end)

    -- Activate first tab automatically
    if self._tabCount == 1 then
        self:_switchTab(tabData)
    end

    table.insert(self.Tabs, tabData)

    -- Return section adder
    local Tab = {}
    function Tab:AddSection(name)
        return UILib._addSection(tabData, name)
    end
    return Tab
end

function UILib:_switchTab(tabData)
    for _, t in ipairs(self.Tabs) do
        t._btn.BackgroundColor3 = COLOR.TAB_IDLE
        t._btn.TextColor3       = COLOR.TEXT_DIM
        t._container.Visible    = false
    end
    tabData._btn.BackgroundColor3 = COLOR.TAB_ACTIVE
    tabData._btn.TextColor3       = COLOR.ACCENT
    tabData._container.Visible    = true
    self.ActiveTab = tabData
end

-- ── Section ──────────────────────────────────────────────────
function UILib._addSection(tabData, name)
    local container = tabData._container
    local sectionData = {}

    -- Arrow + Label row
    local headerRow = new("Frame", {
        Size            = UDim2.new(1,0,0,22),
        BackgroundTransparency = 1,
    }, container)
    local arrow = new("TextLabel", {
        Position        = UDim2.fromOffset(0,0),
        Size            = UDim2.fromOffset(14,22),
        BackgroundTransparency=1,
        Text            = "▸",
        TextColor3      = COLOR.ARROW,
        Font            = FONT,
        TextSize        = 10,
    }, headerRow)
    new("TextLabel", {
        Position        = UDim2.fromOffset(14,0),
        Size            = UDim2.new(1,-14,1,0),
        BackgroundTransparency=1,
        Text            = name,
        TextColor3      = COLOR.TEXT,
        Font            = FONT,
        TextSize        = 12,
        TextXAlignment  = Enum.TextXAlignment.Left,
    }, headerRow)

    -- Item container
    local itemHolder = new("Frame", {
        Size            = UDim2.new(1,0,0,0),
        AutomaticSize   = Enum.AutomaticSize.Y,
        BackgroundTransparency=1,
    }, container)
    new("UIListLayout", {
        SortOrder   = Enum.SortOrder.LayoutOrder,
        Padding     = UDim.new(0,1),
    }, itemHolder)

    -- Collapse toggle
    local collapsed = false
    headerRow.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        collapsed = not collapsed
        itemHolder.Visible = not collapsed
        arrow.Text = collapsed and "▸" or "▾"
        tween(arrow, {TextColor3 = collapsed and COLOR.TEXT_DIM or COLOR.ARROW})
    end)
    arrow.Text = "▾"  -- start expanded

    sectionData._itemHolder = itemHolder
    sectionData._itemCount  = 0

    local Section = {}

    -- ── Toggle ────────────────────────────────────────────────
    function Section:AddToggle(label, default, keybind, callback)
        default  = default or false
        keybind  = keybind or ""
        callback = callback or function() end
        sectionData._itemCount = sectionData._itemCount + 1

        local state = default
        local row   = new("Frame", {
            Size            = UDim2.new(1,0,0,26),
            BackgroundColor3= COLOR.BG2,
            BorderSizePixel = 0,
            LayoutOrder     = sectionData._itemCount,
        }, itemHolder)
        new("UICorner", {CornerRadius=UDim.new(0,3)}, row)

        -- small page box (bullet)
        local pageBox = new("Frame", {
            Position        = UDim2.fromOffset(6,6),
            Size            = UDim2.fromOffset(14,14),
            BackgroundColor3= state and COLOR.CHECKBOX_ON or COLOR.CHECKBOX_OFF,
            BorderSizePixel = 0,
        }, row)
        new("UICorner", {CornerRadius=UDim.new(0,2)}, pageBox)
        new("UIStroke", {Color=COLOR.SEPARATOR, Thickness=1}, pageBox)

        new("TextLabel", {
            Position        = UDim2.fromOffset(26,0),
            Size            = UDim2.new(1,-90,1,0),
            BackgroundTransparency=1,
            Text            = label,
            TextColor3      = COLOR.TEXT,
            Font            = FONT_REG,
            TextSize        = 11,
            TextXAlignment  = Enum.TextXAlignment.Left,
        }, row)

        -- Keybind badge
        if keybind ~= "" then
            new("TextLabel", {
                Position        = UDim2.new(1,-60,0.5,0),
                AnchorPoint     = Vector2.new(1,0.5),
                Size            = UDim2.fromOffset(20,16),
                BackgroundColor3= COLOR.BG,
                BorderSizePixel = 0,
                Text            = keybind,
                TextColor3      = COLOR.TEXT_DIM,
                Font            = FONT,
                TextSize        = 9,
            }, row)
        end

        -- Toggle button
        local toggleBg = new("Frame", {
            Position        = UDim2.new(1,-38,0.5,0),
            AnchorPoint     = Vector2.new(0,0.5),
            Size            = UDim2.fromOffset(34,16),
            BackgroundColor3= state and COLOR.TEXT or COLOR.TOGGLE_OFF,
            BorderSizePixel = 0,
        }, row)
        new("UICorner",{CornerRadius=UDim.new(1,0)}, toggleBg)

        local knob = new("Frame", {
            AnchorPoint     = Vector2.new(0,0.5),
            Position        = state and UDim2.new(1,-14,0.5,0) or UDim2.new(0,2,0.5,0),
            Size            = UDim2.fromOffset(12,12),
            BackgroundColor3= state and COLOR.BG or COLOR.TEXT_DIM,
            BorderSizePixel = 0,
        }, toggleBg)
        new("UICorner",{CornerRadius=UDim.new(1,0)}, knob)

        local function setToggle(val)
            state = val
            tween(toggleBg, {BackgroundColor3 = val and COLOR.TEXT or COLOR.TOGGLE_OFF})
            tween(knob, {
                Position         = val and UDim2.new(1,-14,0.5,0) or UDim2.new(0,2,0.5,0),
                BackgroundColor3 = val and COLOR.BG or COLOR.TEXT_DIM,
            })
            tween(pageBox, {BackgroundColor3 = val and COLOR.CHECKBOX_ON or COLOR.CHECKBOX_OFF})
            callback(val)
        end

        -- Click anywhere on row
        local btn = new("TextButton", {
            Size                = UDim2.fromScale(1,1),
            BackgroundTransparency=1,
            Text                = "",
            ZIndex              = 5,
        }, row)
        btn.MouseButton1Click:Connect(function()
            setToggle(not state)
        end)

        -- Hover effect
        btn.MouseEnter:Connect(function()
            tween(row, {BackgroundColor3 = COLOR.BG3})
        end)
        btn.MouseLeave:Connect(function()
            tween(row, {BackgroundColor3 = COLOR.BG2})
        end)

        -- Keybind listener
        if keybind ~= "" then
            UserInputService.InputBegan:Connect(function(i, gp)
                if gp then return end
                if i.KeyCode == Enum.KeyCode[keybind] then
                    setToggle(not state)
                end
            end)
        end

        local Toggle = {}
        function Toggle:Set(val) setToggle(val) end
        function Toggle:Get() return state end
        return Toggle
    end

    -- ── Button ────────────────────────────────────────────────
    function Section:AddButton(label, keybind, callback)
        keybind  = keybind or ""
        callback = callback or function() end
        sectionData._itemCount = sectionData._itemCount + 1

        local row = new("TextButton", {
            Size            = UDim2.new(1,0,0,26),
            BackgroundColor3= COLOR.BG2,
            BorderSizePixel = 0,
            Text            = "",
            LayoutOrder     = sectionData._itemCount,
            AutoButtonColor = false,
        }, itemHolder)
        new("UICorner",{CornerRadius=UDim.new(0,3)}, row)

        new("TextLabel", {
            Position        = UDim2.fromOffset(26,0),
            Size            = UDim2.new(1,-60,1,0),
            BackgroundTransparency=1,
            Text            = label,
            TextColor3      = COLOR.TEXT,
            Font            = FONT_REG,
            TextSize        = 11,
            TextXAlignment  = Enum.TextXAlignment.Left,
        }, row)

        if keybind ~= "" then
            new("TextLabel", {
                Position        = UDim2.new(1,-6,0.5,0),
                AnchorPoint     = Vector2.new(1,0.5),
                Size            = UDim2.fromOffset(26,16),
                BackgroundColor3= COLOR.BG,
                BorderSizePixel = 0,
                Text            = keybind,
                TextColor3      = COLOR.TEXT_DIM,
                Font            = FONT,
                TextSize        = 9,
            }, row)
        end

        row.MouseButton1Click:Connect(callback)
        row.MouseEnter:Connect(function() tween(row,{BackgroundColor3=COLOR.BG3}) end)
        row.MouseLeave:Connect(function() tween(row,{BackgroundColor3=COLOR.BG2}) end)
    end

    -- ── Slider ────────────────────────────────────────────────
    function Section:AddSlider(label, min, max, default, callback)
        min      = min or 0
        max      = max or 100
        default  = math.clamp(default or min, min, max)
        callback = callback or function() end
        sectionData._itemCount = sectionData._itemCount + 1

        local row = new("Frame", {
            Size            = UDim2.new(1,0,0,32),
            BackgroundColor3= COLOR.BG2,
            BorderSizePixel = 0,
            LayoutOrder     = sectionData._itemCount,
        }, itemHolder)
        new("UICorner",{CornerRadius=UDim.new(0,3)}, row)

        new("TextLabel", {
            Position        = UDim2.fromOffset(6,2),
            Size            = UDim2.new(1,-12,0,14),
            BackgroundTransparency=1,
            Text            = label,
            TextColor3      = COLOR.TEXT_DIM,
            Font            = FONT_REG,
            TextSize        = 10,
            TextXAlignment  = Enum.TextXAlignment.Left,
        }, row)

        local valLabel = new("TextLabel", {
            Position        = UDim2.new(0.5,0,0,2),
            Size            = UDim2.new(0.5,-6,0,14),
            BackgroundTransparency=1,
            Text            = tostring(default),
            TextColor3      = COLOR.TEXT_DIM,
            Font            = FONT,
            TextSize        = 10,
            TextXAlignment  = Enum.TextXAlignment.Right,
        }, row)

        local track = new("Frame", {
            Position        = UDim2.new(0,6,1,-10),
            Size            = UDim2.new(1,-12,0,4),
            BackgroundColor3= COLOR.TOGGLE_OFF,
            BorderSizePixel = 0,
        }, row)
        new("UICorner",{CornerRadius=UDim.new(1,0)}, track)

        local pct  = (default-min)/(max-min)
        local fill = new("Frame", {
            Size            = UDim2.new(pct,0,1,0),
            BackgroundColor3= COLOR.TEXT,
            BorderSizePixel = 0,
        }, track)
        new("UICorner",{CornerRadius=UDim.new(1,0)}, fill)

        local value = default
        local dragging = false

        local function updateSlider(absX)
            local pos   = track.AbsolutePosition.X
            local width = track.AbsoluteSize.X
            local t     = math.clamp((absX - pos) / width, 0, 1)
            value       = math.floor(min + t*(max-min) + 0.5)
            tween(fill, {Size = UDim2.new(t,0,1,0)})
            valLabel.Text = tostring(value)
            callback(value)
        end

        local btn = new("TextButton", {
            Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=5
        }, row)
        btn.MouseButton1Down:Connect(function() dragging=true; updateSlider(Mouse.X) end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                updateSlider(Mouse.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
        end)
        btn.MouseEnter:Connect(function() tween(row,{BackgroundColor3=COLOR.BG3}) end)
        btn.MouseLeave:Connect(function() tween(row,{BackgroundColor3=COLOR.BG2}) end)

        local Slider={}
        function Slider:Set(v) value=math.clamp(v,min,max); local t=(value-min)/(max-min); fill.Size=UDim2.new(t,0,1,0); valLabel.Text=tostring(value); callback(value) end
        function Slider:Get() return value end
        return Slider
    end

    -- ── Label ─────────────────────────────────────────────────
    function Section:AddLabel(text)
        sectionData._itemCount = sectionData._itemCount + 1
        new("TextLabel", {
            Size            = UDim2.new(1,0,0,20),
            BackgroundTransparency=1,
            Text            = "  "..text,
            TextColor3      = COLOR.TEXT_DIM,
            Font            = FONT_REG,
            TextSize        = 10,
            TextXAlignment  = Enum.TextXAlignment.Left,
            LayoutOrder     = sectionData._itemCount,
        }, itemHolder)
    end

    return Section
end

-- ── Keybind to show/hide ──────────────────────────────────────
function UILib:SetToggleKey(key)
    UserInputService.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode[key] then
            self._skewWrap.Visible = not self._skewWrap.Visible
        end
    end)
end

return UILib

-- ============================================================
--  USAGE EXAMPLE  (put in a LocalScript, require this module)
-- ============================================================
--[[
local UILib = require(game.ReplicatedStorage.UILibrary)

local Window = UILib.new("ai.cc", "v2.4")
Window:SetToggleKey("RightShift")   -- press to show/hide

local tabM = Window:AddTab("M")
local tabV = Window:AddTab("V")
local tabC = Window:AddTab("C")

-- Tab V  ──────────────────────────────────────────────────────
local movement = tabV:AddSection("Movement")
movement:AddToggle("Speed Hack",    false, "F", function(v) print("Speed:", v) end)
movement:AddToggle("Fly",           false, "G", function(v) print("Fly:", v) end)
movement:AddToggle("Noclip",        false, "N", function(v) print("Noclip:", v) end)
movement:AddToggle("Infinite Jump", true,  "J", function(v) print("InfJump:", v) end)

local vaultables = tabV:AddSection("Vaultables")
vaultables:AddToggle("Pallet Vacuum",     true,  "V", function(v) end)
vaultables:AddToggle("Vaultables Nodip",  false, "4", function(v) end)
vaultables:AddToggle("Block Vault",       false, "5", function(v) end)
vaultables:AddToggle("Auto Pallet",       false, "B", function(v) end)
vaultables:AddSlider("Drop Distance", 1, 50, 10, function(v) print("Dist:", v) end)

local generator = tabV:AddSection("Generator")
generator:AddToggle("Auto Generator", false, "H", function(v) end)
generator:AddToggle("Generator ESP",  true,  "E", function(v) end)

local dodge = tabV:AddSection("Dodge")
dodge:AddToggle("Auto Dodge", false, "D", function(v) end)

local exploit = tabV:AddSection("Exploit")
exploit:AddToggle("Kill Aura", false, "K", function(v) end)

local fun = tabV:AddSection("Fun")
fun:AddToggle("Big Head", false, "Z", function(v) end)
]]
