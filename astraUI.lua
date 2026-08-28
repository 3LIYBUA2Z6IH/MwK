--// SimpleUI
--// Lightweight Modern Roblox UI Library

local Library = {}
Library.__index = Library

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

--// Theme
Library.Theme = {
    Background = Color3.fromRGB(15, 16, 20),
    Secondary = Color3.fromRGB(20, 21, 26),
    Element = Color3.fromRGB(27, 29, 35),
    Hover = Color3.fromRGB(35, 38, 46),

    Accent = Color3.fromRGB(90, 140, 255),

    Text = Color3.fromRGB(240, 242, 247),
    SubText = Color3.fromRGB(145, 149, 160),

    Border = Color3.fromRGB(42, 44, 52)
}

--// Utility
local function Create(class, properties, parent)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent

    return object
end

local function Corner(parent, radius)
    Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6)
    }, parent)
end

local function Stroke(parent)
    Create("UIStroke", {
        Color = Library.Theme.Border,
        Thickness = 1
    }, parent)
end

local function Tween(object, properties, duration)
    TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.15,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    ):Play()
end

--// Drag
local function MakeDraggable(handle, target)

    local dragging = false
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)

        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = target.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end

        end)

    end)

    UserInputService.InputChanged:Connect(function(input)

        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local delta = input.Position - dragStart

        target.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,

            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )

    end)

end

----------------------------------------------------------------
--// WINDOW
----------------------------------------------------------------

function Library:CreateWindow(config)

    config = config or {}

    local Window = {}
    Window.Tabs = {}

    local Gui = Create("ScreenGui", {
        Name = config.Name or "SimpleUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, Player:WaitForChild("PlayerGui"))

    local Main = Create("Frame", {
        Name = "Main",

        Size = config.Size or UDim2.fromOffset(560, 390),

        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),

        BackgroundColor3 = Library.Theme.Background,

        BorderSizePixel = 0
    }, Gui)

    Corner(Main, 10)
    Stroke(Main)

    ------------------------------------------------------------
    --// TOP BAR
    ------------------------------------------------------------

    local TopBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 58),

        BackgroundColor3 = Library.Theme.Secondary,

        BorderSizePixel = 0
    }, Main)

    local Title = Create("TextLabel", {
        Position = UDim2.fromOffset(18, 8),

        Size = UDim2.new(1, -36, 0, 24),

        BackgroundTransparency = 1,

        Text = config.Title or "Simple UI",

        Font = Enum.Font.GothamBold,

        TextSize = 16,

        TextColor3 = Library.Theme.Text,

        TextXAlignment = Enum.TextXAlignment.Left
    }, TopBar)

    local Subtitle = Create("TextLabel", {
        Position = UDim2.fromOffset(18, 31),

        Size = UDim2.new(1, -36, 0, 16),

        BackgroundTransparency = 1,

        Text = config.Subtitle or "Lightweight Interface",

        Font = Enum.Font.Gotham,

        TextSize = 11,

        TextColor3 = Library.Theme.SubText,

        TextXAlignment = Enum.TextXAlignment.Left
    }, TopBar)

    MakeDraggable(TopBar, Main)

    ------------------------------------------------------------
    --// TAB LIST
    ------------------------------------------------------------

    local TabList = Create("ScrollingFrame", {

        Position = UDim2.fromOffset(10, 68),

        Size = UDim2.new(0, 125, 1, -78),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        ScrollBarThickness = 0,

        CanvasSize = UDim2.new()
    }, Main)

    local TabLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 5),

        SortOrder = Enum.SortOrder.LayoutOrder
    }, TabList)

    ------------------------------------------------------------
    --// CONTENT
    ------------------------------------------------------------

    local Content = Create("Frame", {

        Position = UDim2.fromOffset(145, 68),

        Size = UDim2.new(1, -155, 1, -78),

        BackgroundTransparency = 1
    }, Main)

    ------------------------------------------------------------
    --// CREATE TAB
    ------------------------------------------------------------

    function Window:CreateTab(name)

        local Tab = {}

        local Button = Create("TextButton", {

            Size = UDim2.new(1, 0, 0, 36),

            BackgroundColor3 = Library.Theme.Secondary,

            Text = name,

            Font = Enum.Font.GothamMedium,

            TextSize = 12,

            TextColor3 = Library.Theme.SubText,

            AutoButtonColor = false,

            BorderSizePixel = 0
        }, TabList)

        Corner(Button, 7)

        local Page = Create("ScrollingFrame", {

            Size = UDim2.fromScale(1, 1),

            BackgroundTransparency = 1,

            BorderSizePixel = 0,

            ScrollBarThickness = 3,

            ScrollBarImageColor3 = Library.Theme.Accent,

            Visible = false,

            CanvasSize = UDim2.new()
        }, Content)

        local Layout = Create("UIListLayout", {

            Padding = UDim.new(0, 7),

            SortOrder = Enum.SortOrder.LayoutOrder
        }, Page)

        local Padding = Create("UIPadding", {

            PaddingTop = UDim.new(0, 2),

            PaddingBottom = UDim.new(0, 8)
        }, Page)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()

            Page.CanvasSize = UDim2.new(
                0,
                0,
                0,
                Layout.AbsoluteContentSize.Y + 10
            )

        end)

        function Tab:Show()

            for _, other in pairs(Window.Tabs) do
                other.Page.Visible = false

                Tween(
                    other.Button,
                    {
                        BackgroundColor3 = Library.Theme.Secondary,
                        TextColor3 = Library.Theme.SubText
                    }
                )
            end

            Page.Visible = true

            Tween(Button, {
                BackgroundColor3 = Library.Theme.Accent,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            })

        end

        Button.MouseEnter:Connect(function()

            if not Page.Visible then
                Tween(Button, {
                    BackgroundColor3 = Library.Theme.Hover
                })
            end

        end)

        Button.MouseLeave:Connect(function()

            if not Page.Visible then
                Tween(Button, {
                    BackgroundColor3 = Library.Theme.Secondary
                })
            end

        end)

        Button.MouseButton1Click:Connect(function()
            Tab:Show()
        end)

        --------------------------------------------------------
        --// SECTION
        --------------------------------------------------------

        function Tab:CreateSection(name)

            local Section = {}

            local Frame = Create("Frame", {

                Size = UDim2.new(1, 0, 0, 32),

                BackgroundTransparency = 1
            }, Page)

            local Text = Create("TextLabel", {

                Size = UDim2.new(1, 0, 1, 0),

                BackgroundTransparency = 1,

                Text = name,

                Font = Enum.Font.GothamBold,

                TextSize = 12,

                TextColor3 = Library.Theme.Text,

                TextXAlignment = Enum.TextXAlignment.Left
            }, Frame)

            ----------------------------------------------------
            --// LABEL
            ----------------------------------------------------

            function Section:CreateLabel(text)

                local Label = Create("TextLabel", {

                    Size = UDim2.new(1, 0, 0, 30),

                    BackgroundColor3 = Library.Theme.Element,

                    Text = text,

                    Font = Enum.Font.Gotham,

                    TextSize = 12,

                    TextColor3 = Library.Theme.SubText,

                    TextXAlignment = Enum.TextXAlignment.Left
                }, Page)

                Corner(Label, 7)

                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 12)
                }, Label)

                return Label

            end

            ----------------------------------------------------
            --// BUTTON
            ----------------------------------------------------

            function Section:CreateButton(config)

                local Button = Create("TextButton", {

                    Size = UDim2.new(1, 0, 0, 38),

                    BackgroundColor3 = Library.Theme.Element,

                    Text = config.Name or "Button",

                    Font = Enum.Font.GothamMedium,

                    TextSize = 12,

                    TextColor3 = Library.Theme.Text,

                    AutoButtonColor = false,

                    BorderSizePixel = 0
                }, Page)

                Corner(Button, 7)

                Button.MouseEnter:Connect(function()

                    Tween(Button, {
                        BackgroundColor3 = Library.Theme.Hover
                    })

                end)

                Button.MouseLeave:Connect(function()

                    Tween(Button, {
                        BackgroundColor3 = Library.Theme.Element
                    })

                end)

                Button.MouseButton1Click:Connect(function()

                    if config.Callback then
                        task.spawn(config.Callback)
                    end

                end)

                return Button

            end

            ----------------------------------------------------
            --// TOGGLE
            ----------------------------------------------------

            function Section:CreateToggle(config)

                local Enabled = config.Default or false

                local Frame = Create("Frame", {

                    Size = UDim2.new(1, 0, 0, 42),

                    BackgroundColor3 = Library.Theme.Element,

                    BorderSizePixel = 0
                }, Page)

                Corner(Frame, 7)

                local Label = Create("TextLabel", {

                    Position = UDim2.fromOffset(12, 0),

                    Size = UDim2.new(1, -65, 1, 0),

                    BackgroundTransparency = 1,

                    Text = config.Name or "Toggle",

                    Font = Enum.Font.GothamMedium,

                    TextSize = 12,

                    TextColor3 = Library.Theme.Text,

                    TextXAlignment = Enum.TextXAlignment.Left
                }, Frame)

                local Switch = Create("TextButton", {

                    Position = UDim2.new(1, -48, 0.5, -10),

                    Size = UDim2.fromOffset(38, 20),

                    BackgroundColor3 = Enabled
                        and Library.Theme.Accent
                        or Library.Theme.Hover,

                    Text = "",

                    AutoButtonColor = false,

                    BorderSizePixel = 0
                }, Frame)

                Corner(Switch, 10)

                local Circle = Create("Frame", {

                    Size = UDim2.fromOffset(16, 16),

                    Position = Enabled
                        and UDim2.new(1, -18, 0.5, -8)
                        or UDim2.fromOffset(2, 2),

                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),

                    BorderSizePixel = 0
                }, Switch)

                Corner(Circle, 10)

                local function Update()

                    Tween(Switch, {
                        BackgroundColor3 = Enabled
                            and Library.Theme.Accent
                            or Library.Theme.Hover
                    })

                    Tween(Circle, {
                        Position = Enabled
                            and UDim2.new(1, -18, 0.5, -8)
                            or UDim2.fromOffset(2, 2)
                    })

                    if config.Callback then
                        task.spawn(config.Callback, Enabled)
                    end

                end

                Switch.MouseButton1Click:Connect(function()

                    Enabled = not Enabled

                    Update()

                end)

                local Object = {}

                function Object:Set(value)

                    Enabled = value
                    Update()

                end

                function Object:Get()
                    return Enabled
                end

                return Object

            end

            ----------------------------------------------------
            --// SLIDER
            ----------------------------------------------------

            function Section:CreateSlider(config)

                local Min = config.Min or 0
                local Max = config.Max or 100
                local Value = config.Default or Min

                local Frame = Create("Frame", {

                    Size = UDim2.new(1, 0, 0, 55),

                    BackgroundColor3 = Library.Theme.Element,

                    BorderSizePixel = 0
                }, Page)

                Corner(Frame, 7)

                local Label = Create("TextLabel", {

                    Position = UDim2.fromOffset(12, 6),

                    Size = UDim2.new(1, -70, 0, 20),

                    BackgroundTransparency = 1,

                    Text = config.Name or "Slider",

                    Font = Enum.Font.GothamMedium,

                    TextSize = 12,

                    TextColor3 = Library.Theme.Text,

                    TextXAlignment = Enum.TextXAlignment.Left
                }, Frame)

                local ValueLabel = Create("TextLabel", {

                    Position = UDim2.new(1, -55, 0, 6),

                    Size = UDim2.fromOffset(45, 20),

                    BackgroundTransparency = 1,

                    Text = tostring(Value),

                    Font = Enum.Font.GothamMedium,

                    TextSize = 11,

                    TextColor3 = Library.Theme.SubText,

                    TextXAlignment = Enum.TextXAlignment.Right
                }, Frame)

                local Bar = Create("Frame", {

                    Position = UDim2.fromOffset(12, 34),

                    Size = UDim2.new(1, -24, 0, 5),

                    BackgroundColor3 = Library.Theme.Hover,

                    BorderSizePixel = 0
                }, Frame)

                Corner(Bar, 5)

                local Fill = Create("Frame", {

                    Size = UDim2.new(
                        (Value - Min) / (Max - Min),
                        0,
                        1,
                        0
                    ),

                    BackgroundColor3 = Library.Theme.Accent,

                    BorderSizePixel = 0
                }, Bar)

                Corner(Fill, 5)

                local Drag = Create("TextButton", {

                    Size = UDim2.fromScale(1, 1),

                    BackgroundTransparency = 1,

                    Text = ""
                }, Bar)

                local function SetValue(value)

                    Value = math.clamp(value, Min, Max)

                    local Percent = (Value - Min) / (Max - Min)

                    Fill.Size = UDim2.new(
                        Percent,
                        0,
                        1,
                        0
                    )

                    ValueLabel.Text = tostring(math.floor(Value))

                    if config.Callback then
                        task.spawn(config.Callback, Value)
                    end

                end

                local function UpdateFromMouse()

                    local MouseX = UserInputService:GetMouseLocation().X

                    local Percent = math.clamp(
                        (MouseX - Bar.AbsolutePosition.X)
                        / Bar.AbsoluteSize.X,
                        0,
                        1
                    )

                    SetValue(
                        Min + ((Max - Min) * Percent)
                    )

                end

                Drag.MouseButton1Down:Connect(function()

                    UpdateFromMouse()

                    local connection

                    connection = UserInputService.InputChanged:Connect(function(input)

                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            UpdateFromMouse()
                        end

                    end)

                    UserInputService.InputEnded:Wait()

                    connection:Disconnect()

                end)

                local Object = {}

                function Object:Set(value)
                    SetValue(value)
                end

                function Object:Get()
                    return Value
                end

                return Object

            end

            return Section

        end

        table.insert(Window.Tabs, Tab)

        -- First tab automatically opens
        if #Window.Tabs == 1 then
            Tab:Show()
        end

        return Tab

    end

    ------------------------------------------------------------
    --// NOTIFICATION
    ------------------------------------------------------------

    function Window:Notify(config)

        local Holder = Gui:FindFirstChild("Notifications")

        if not Holder then

            Holder = Create("Frame", {

                Name = "Notifications",

                Position = UDim2.new(1, -15, 1, -15),

                Size = UDim2.fromOffset(280, 300),

                AnchorPoint = Vector2.new(1, 1),

                BackgroundTransparency = 1
            }, Gui)

            Create("UIListLayout", {

                Padding = UDim.new(0, 7),

                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }, Holder)

        end

        local Notification = Create("Frame", {

            Size = UDim2.new(1, 0, 0, 60),

            BackgroundColor3 = Library.Theme.Secondary,

            BorderSizePixel = 0
        }, Holder)

        Corner(Notification, 8)
        Stroke(Notification)

        Create("TextLabel", {

            Position = UDim2.fromOffset(12, 7),

            Size = UDim2.new(1, -24, 0, 20),

            BackgroundTransparency = 1,

            Text = config.Title or "Notification",

            Font = Enum.Font.GothamBold,

            TextSize = 12,

            TextColor3 = Library.Theme.Text,

            TextXAlignment = Enum.TextXAlignment.Left
        }, Notification)

        Create("TextLabel", {

            Position = UDim2.fromOffset(12, 28),

            Size = UDim2.new(1, -24, 0, 25),

            BackgroundTransparency = 1,

            Text = config.Content or "",

            Font = Enum.Font.Gotham,

            TextSize = 11,

            TextColor3 = Library.Theme.SubText,

            TextWrapped = true,

            TextXAlignment = Enum.TextXAlignment.Left
        }, Notification)

        task.delay(config.Duration or 3, function()

            if Notification then

                Tween(Notification, {
                    BackgroundTransparency = 1
                }, 0.2)

                task.wait(0.2)

                Notification:Destroy()

            end

        end)

    end

    return Window

end

return Library
