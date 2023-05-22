local RunService = cloneref(game:GetService("UserInputService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

local Roact: Roact = require(script.Parent.Parent.Roact) :: any
local RoactHooks = require(script.Parent.Parent.RoactHooks)
local RoactSpring = require(script.Parent.Parent.RoactSpring)
local RoactTemplate = require(script.Parent.RoactTemplate)

local Templates = require(script.Parent.Templates)
local Types = require(script.Parent.Types)

local Ripple = require(script.Parent.Ripple)
local Tip = require(script.Parent.Tip)

type props = {
    info: Types.info,
    initialValue: Color3,

    update: (value: Color3) -> (),
}

type styles = {
    rainbowToggleTransparency: RoactBinding<number>,
    background: RoactBinding<Color3>,
    canvasSize: RoactBinding<UDim2>,
}

local function zigzag(t: number)
    return math.acos(math.cos((t / 100) * math.pi)) / math.pi
end

local function ColorPicker(props: props, hooks: RoactHooks.Hooks)
    local ref = hooks.useValue(Roact.createRef())

    local colorSize = hooks.useValue(Vector2.zero)
    local opacitySize = hooks.useValue(Vector2.zero)
    local colorPosition = hooks.useValue(Vector2.zero)
    local opacityPosition = hooks.useValue(Vector2.zero)

    local colorCursorSize = hooks.useValue(Vector2.zero)
    local opacityCursorSize = hooks.useValue(Vector2.zero)
    
    local frames = hooks.useValue(0)
    local opened = hooks.useValue(false)
    local rainbowConnection = hooks.useValue(nil :: RBXScriptConnection?)
    
    local hsv: RoactBinding<table>, updateHsv = hooks.useBinding({ Color3.toHSV(props.initialValue) })

    local styles: any, api = RoactSpring.useSpring(function()
        return {
            background = props.info.theme.background,
            canvasSize = UDim2.fromOffset(352, 33),
            rainbowToggleTransparency = 1,

            config = RoactSpring.config.stiff :: any,
        }
    end)

    local styles: styles = styles

    hooks.useEffect(function()
        return function()
            if rainbowConnection.value then
                rainbowConnection.value:Disconnect()
                rainbowConnection.value = nil
            end
        end
    end, {})

    return Roact.createElement(Templates.ColorPicker, {
        [Roact.Ref] = ref.value :: any,

        Size = styles.canvasSize,
        LayoutOrder = props.info.order,
        
        [Roact.Event.MouseButton1Click] = function(_self: TextButton)
            api.start({
                canvasSize = opened.value and UDim2.fromOffset(352, 33) or UDim2.fromOffset(352, 141),
            })
        end,

        [Roact.Event.MouseEnter] = function(_self: TextButton)
            api.start({
                background = Color3.fromRGB(
                    (props.info.theme.elementColor.R * 255) + 8,
                    (props.info.theme.elementColor.G * 255) + 9,
                    (props.info.theme.elementColor.B * 255) + 10
                ),
            }) 
        end,

        [Roact.Event.MouseLeave] = function(_self: TextButton)
            api.start({
                background = props.info.theme.elementColor,
            }) 
        end,
    }, {
        Header = {
            BackgroundColor3 = styles.background,

            [Roact.Children] = {
                Ripple = RoactTemplate.wrapped(Ripple, {
                    ref = ref.value,
                    theme = props.info.theme,
                }),
        
                Tip = RoactTemplate.wrapped(Tip, {
                    ref = props.info.ref,
                    description = props.info.description or "",
                    theme = props.info.theme,
                    opened = props.info.tip.opened,
                    update = props.info.tip.update,
                }),
        
                Name = {
                    TextColor3 = props.info.theme.textColor,
                    Text = props.info.name,
                },

                Color = {
                    BackgroundColor3 = hsv:map(function(value)
                        return Color3.fromHSV(table.unpack(value))
                    end),
                },

                Icon = { ImageColor3 = props.info.theme.schemeColor },
            },
        },

        Inners = {
            BackgroundColor3 = props.info.theme.elementColor,

            [Roact.Children] = {
                Rainbow = {
                    [Roact.Children] = {
                        Button = {
                            [Roact.Event.MouseButton1Click] = function(_self: TextButton)
                                if rainbowConnection.value then
                                    rainbowConnection.value:Disconnect()
                                    rainbowConnection.value = nil
                                else
                                    rainbowConnection.value = RunService.RenderStepped:Connect(function()
                                        frames.value += 1

                                        updateHsv({ zigzag(frames.value), 1, 1 })
                                        props.update(Color3.fromHSV(table.unpack(hsv:getValue())))
                                    end)
                                end

                                api.start({
                                    rainbowToggleTransparency = rainbowConnection.value and 0 or 1,
                                })
                            end,
                        },

                        Fill = {
                            ImageColor3 = props.info.theme.schemeColor,
                            ImageTransparency = styles.rainbowToggleTransparency,
                        },

                        Outline = { ImageColor3 = props.info.theme.schemeColor },

                        Name = { TextColor3 = props.info.theme.textColor },
                    },
                },

                Opacity = {
                    [Roact.Children] = {
                        Cursor = {
                            Position = hsv:map(function(value)
                                return UDim2.new(0.5, 0, value[3] - 1, -colorSize.value.Y / 2)
                            end),

                            ImageColor3 = hsv:map(function(value)
                                return Color3.fromHSV(0, 0, 1 - value[3])
                            end),

                            [Roact.Change.AbsoluteSize] = function(self: ImageLabel)
                                opacityCursorSize.value = self.AbsoluteSize
                            end,
                        }
                    } :: any,

                    [Roact.Event.InputBegan] = function(_self: ImageButton, input: InputObject)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local connection; connection = input.Changed:Connect(function()
                                if input.UserInputState == Enum.UserInputState.Change then
                                    local mousePosition = UserInputService:GetMouseLocation()
                                    local y = mousePosition.Y - colorSize.value.Y
                                    local currentHsv = hsv:getValue()

                                    if y < 0 then
                                        y = 0
                                    end

                                    if y > opacitySize.value.Y then
                                        y = opacitySize.value.Y
                                    end

                                    y = y / opacitySize.value.Y

                                    updateHsv({ currentHsv[1], currentHsv[2], 1 - y })
                                    props.update(Color3.fromHSV(table.unpack(hsv:getValue())))
                                elseif input.UserInputState == Enum.UserInputState.End then
                                    connection:Disconnect()
                                    connection = nil :: any
                                end
                            end)
                        end
                    end,

                    [Roact.Change.AbsoluteSize] = function(self: ImageButton)
                        opacitySize.value = self.AbsoluteSize
                    end,

                    [Roact.Change.AbsolutePosition] = function(self: ImageButton)
                        opacityPosition.value = self.AbsolutePosition
                    end,
                },

                Color = {
                    [Roact.Children] = {
                        Cursor = {
                            Position = hsv:map(function(value)
                                local absoluteSize = colorSize.value / 2
                                return UDim2.new(value[1], -absoluteSize.X, value[2] - 1, -absoluteSize.Y)
                            end),

                            ImageColor3 = hsv:map(function(value)
                                return Color3.fromHSV(table.unpack(value))
                            end),

                            [Roact.Change.AbsoluteSize] = function(self: ImageLabel)
                                colorCursorSize.value = self.AbsoluteSize
                            end,
                        }
                    } :: any,

                    [Roact.Event.InputBegan] = function(_self: ImageButton, input: InputObject)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local connection; connection = input.Changed:Connect(function()
                                if input.UserInputState == Enum.UserInputState.Change then
                                    local mousePosition = UserInputService:GetMouseLocation()
                                    local position = mousePosition - colorSize.value

                                    if position.x < 0 then
                                        position.x = 0
                                    end

                                    if position.x > colorSize.value.X then
                                        position.x = colorSize.value.X
                                    end

                                    if position.y < 0 then
                                        position.y = 0
                                    end

                                    if position.y > colorSize.value.Y then
                                        position.y = colorSize.value.Y
                                    end

                                    position.x = position.x / colorSize.value.X
                                    position.y = position.y / colorSize.value.Y

                                    updateHsv({ 1 - position.x, 1 - position.y, hsv:getValue()[3] })
                                    props.update(Color3.fromHSV(table.unpack(hsv:getValue())))
                                elseif input.UserInputState == Enum.UserInputState.End then
                                    connection:Disconnect()
                                    connection = nil :: any
                                end
                            end)
                        end
                    end,

                    [Roact.Change.AbsoluteSize] = function(self: ImageButton)
                        colorSize.value = self.AbsoluteSize
                    end,

                    [Roact.Change.AbsolutePosition] = function(self: ImageButton)
                        colorPosition.value = self.AbsolutePosition
                    end,
                }, 
            },
        },
    })
end

return (RoactHooks.new(Roact :: any)(ColorPicker) :: any) :: RoactElementFn<props>