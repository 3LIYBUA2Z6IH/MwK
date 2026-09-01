--// Nova UI Library
--// Window > Page > Section > Button

local Library = {
    Pages = {},
    CurrentPage = nil,
    Flags = {},
    LogsEnabled = false
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

--// Helpers
local function Create(class, properties)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    return object
end

local function Corner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 5),
        Parent = parent
    })
end

local function Stroke(parent, transparency)
    return Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = transparency or 0.92,
        Thickness = 1,
        Parent = parent
    })
end

local function Tween(object, properties, duration)
    TweenService:Create(
        object,
        TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    ):Play()
end

--// Log
function Library:Log(message)
    if not self.LogsEnabled then
        return
    end

    print("[Nova UI] " .. tostring(message))
end

--// Window
function Library:Window(options)
    options = options or {}

    local WindowObject = {}

    local WindowName = options.Name or "Nova UI"
    local SubName = options.SubName or ""
    local MenuKeybind = options.MenuKeybind or Enum.KeyCode.RightShift

    --// ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "NovaUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = Player:WaitForChild("PlayerGui")
    })

    --// Main Window
    local Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(720, 470),
        Position = UDim2.new(0.5, -360, 0.5, -235),
        BackgroundColor3 = Color3.fromRGB(15, 15, 18),
        BorderSizePixel = 0,
        Parent = ScreenGui
    })

    Corner(Main, 7)
    Stroke(Main, 0.88)

    --// Header
    local Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = Color3.fromRGB(18, 18, 22),
        BorderSizePixel = 0,
        Parent = Main
    })

    Corner(Header, 7)

    --// Name
    local NameLabel = Create("TextLabel", {
        Name = "Name",
        Size = UDim2.new(1, -100, 0, 25),
        Position = UDim2.fromOffset(18, 8),
        BackgroundTransparency = 1,
        Text = WindowName,
        TextColor3 = Color3.fromRGB(235, 235, 240),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })

    --// SubName
    local SubNameLabel = Create("TextLabel", {
        Name = "SubName",
        Size = UDim2.new(1, -100, 0, 18),
        Position = UDim2.fromOffset(18, 32),
        BackgroundTransparency = 1,
        Text = SubName,
        TextColor3 = Color3.fromRGB(120, 120, 130),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })

    --// Minimize
    local Minimize = Create("TextButton", {
        Name = "Minimize",
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -68, 0, 14),
        BackgroundTransparency = 1,
        Text = "—",
        TextColor3 = Color3.fromRGB(150, 150, 160),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = Header
    })

    --// Close
    local Close = Create("TextButton", {
        Name = "Close",
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -35, 0, 14),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Color3.fromRGB(150, 150, 160),
        TextSize = 20,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Parent = Header
    })

    --// Body
    local Body = Create("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -58),
        Position = UDim2.fromOffset(0, 58),
        BackgroundTransparency = 1,
        Parent = Main
    })

    --// Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.fromOffset(82, 1),
        Position = UDim2.fromOffset(0, 0),
        BackgroundColor3 = Color3.fromRGB(17, 17, 20),
        BorderSizePixel = 0,
        Parent = Body
    })

    local PageList = Create("ScrollingFrame", {
        Name = "PageList",
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.fromOffset(0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Sidebar
    })

    local PageLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 9),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = PageList
    })

    --// Content
    local Content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -82, 1, 0),
        Position = UDim2.fromOffset(82, 0),
        BackgroundColor3 = Color3.fromRGB(13, 13, 16),
        BorderSizePixel = 0,
        Parent = Body
    })

    --// Dragging
    local Dragging = false
    local DragStart
    local StartPosition

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPosition = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = input.Position - DragStart

            Main.Position = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
        end
    end)

    --// Minimize
    local Minimized = false
    local OriginalSize = Main.Size

    Minimize.MouseButton1Click:Connect(function()
        Minimized = not Minimized

        if Minimized then
            Tween(Main, {
                Size = UDim2.fromOffset(720, 58)
            })
        else
            Tween(Main, {
                Size = OriginalSize
            })
        end
    end)

    --// Close
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    --// Keybind
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end

        if input.KeyCode == MenuKeybind then
            Main.Visible = not Main.Visible
        end
    end)

    --// Page
    function WindowObject:Page(pageOptions)
        pageOptions = pageOptions or {}

        local PageObject = {
            Name = pageOptions.Name or "Page",
            Sections = {}
        }

        local PageName = PageObject.Name
        local Letter = string.upper(string.sub(PageName, 1, 1))

        --// Page Button
        local PageButton = Create("TextButton", {
            Name = PageName,
            Size = UDim2.fromOffset(38, 38),
            BackgroundColor3 = Color3.fromRGB(23, 23, 27),
            BorderSizePixel = 0,
            Text = Letter,
            TextColor3 = Color3.fromRGB(125, 125, 135),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            Parent = PageList
        })

        Corner(PageButton, 5)
        Stroke(PageButton, 0.93)

        --// Page Content
        local PageFrame = Create("ScrollingFrame", {
            Name = PageName,
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.fromOffset(10, 10),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageTransparency = 0.7,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = Content
        })

        local LeftColumn = Create("Frame", {
            Name = "Left",
            Size = UDim2.new(0.5, -6, 1, 0),
            BackgroundTransparency = 1,
            Parent = PageFrame
        })

        local RightColumn = Create("Frame", {
            Name = "Right",
            Size = UDim2.new(0.5, -6, 1, 0),
            Position = UDim2.new(0.5, 6, 0, 0),
            BackgroundTransparency = 1,
            Parent = PageFrame
        })

        local LeftLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = LeftColumn
        })

        local RightLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = RightColumn
        })

        local function UpdateCanvas()
            local leftHeight = LeftLayout.AbsoluteContentSize.Y
            local rightHeight = RightLayout.AbsoluteContentSize.Y

            PageFrame.CanvasSize = UDim2.fromOffset(
                0,
                math.max(leftHeight, rightHeight) + 10
            )
        end

        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        --// Select Page
        local function SelectPage()
            for _, page in ipairs(Library.Pages) do
                page.Frame.Visible = false

                Tween(page.Button, {
                    BackgroundColor3 = Color3.fromRGB(23, 23, 27)
                }, 0.12)

                page.Button.TextColor3 = Color3.fromRGB(125, 125, 135)
            end

            PageFrame.Visible = true

            Tween(PageButton, {
                BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            }, 0.12)

            PageButton.TextColor3 = Color3.fromRGB(235, 235, 240)

            Library.CurrentPage = PageObject
        end

        PageButton.MouseButton1Click:Connect(SelectPage)

        --// Tooltip
        PageButton.MouseEnter:Connect(function()
            if Library.CurrentPage ~= PageObject then
                Tween(PageButton, {
                    BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                }, 0.1)
            end
        end)

        PageButton.MouseLeave:Connect(function()
            if Library.CurrentPage ~= PageObject then
                Tween(PageButton, {
                    BackgroundColor3 = Color3.fromRGB(23, 23, 27)
                }, 0.1)
            end
        end)

        --// Section
        function PageObject:Section(sectionOptions)
            sectionOptions = sectionOptions or {}

            local SectionObject = {}

            local SectionName = sectionOptions.Name or "Section"
            local Side = sectionOptions.Side or 1

            local ParentColumn

            if Side == 2 then
                ParentColumn = RightColumn
            else
                ParentColumn = LeftColumn
            end

            local SectionFrame = Create("Frame", {
                Name = SectionName,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = Color3.fromRGB(19, 19, 23),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = ParentColumn
            })

            Corner(SectionFrame, 5)
            Stroke(SectionFrame, 0.93)

            --// Section Header
            local SectionHeader = Create("TextLabel", {
                Name = "Header",
                Size = UDim2.new(1, -20, 0, 34),
                Position = UDim2.fromOffset(10, 0),
                BackgroundTransparency = 1,
                Text = SectionName,
                TextColor3 = Color3.fromRGB(220, 220, 225),
                TextSize = 12,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionFrame
            })

            local Elements = Create("Frame", {
                Name = "Elements",
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.fromOffset(8, 34),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionFrame
            })

            local ElementLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = Elements
            })

            local Padding = Create("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
                Parent = Elements
            })

            --// Button
            function SectionObject:Button(buttonOptions)
                buttonOptions = buttonOptions or {}

                local ButtonObject = {}

                local ButtonName = buttonOptions.Name or "Button"
                local Callback = buttonOptions.Callback or function() end

                local Button = Create("TextButton", {
                    Name = ButtonName,
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Color3.fromRGB(25, 25, 29),
                    BorderSizePixel = 0,
                    Text = ButtonName,
                    TextColor3 = Color3.fromRGB(195, 195, 200),
                    TextSize = 11,
                    Font = Enum.Font.GothamMedium,
                    AutoButtonColor = false,
                    Parent = Elements
                })

                Corner(Button, 4)
                Stroke(Button, 0.94)

                Button.MouseEnter:Connect(function()
                    Tween(Button, {
                        BackgroundColor3 = Color3.fromRGB(34, 34, 40)
                    }, 0.1)
                end)

                Button.MouseLeave:Connect(function()
                    Tween(Button, {
                        BackgroundColor3 = Color3.fromRGB(25, 25, 29)
                    }, 0.1)
                end)

                Button.MouseButton1Click:Connect(function()
                    Callback()
                end)

                ButtonObject.Instance = Button

                return ButtonObject
            end

            table.insert(PageObject.Sections, SectionObject)

            return SectionObject
        end

        table.insert(Library.Pages, {
            Object = PageObject,
            Button = PageButton,
            Frame = PageFrame
        })

        PageList.CanvasSize = UDim2.fromOffset(
            0,
            PageLayout.AbsoluteContentSize.Y + 10
        )

        --// First page
        if #Library.Pages == 1 then
            SelectPage()
        end

        return PageObject
    end

    WindowObject.Instance = Main
    WindowObject.ScreenGui = ScreenGui

    return WindowObject
end

return Library
