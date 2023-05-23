local UserInputService = cloneref(game:GetService("UserInputService"))

local Roact: Roact = require(script.Parent.Parent.Roact) :: any
local RoactHooks = require(script.Parent.Parent.RoactHooks)
local RoactSpring = require(script.Parent.Parent.RoactSpring)
local RoactTemplate = require(script.Parent.RoactTemplate)

local Templates = require(script.Parent.Templates)
local Types = require(script.Parent.Types)

local Ripple = require(script.Parent.Ripple)
local Tip = require(script.Parent.Tip)

local INPUTS = {
    Enum.UserInputType.MouseButton2,
    Enum.UserInputType.MouseButton3,
}

type keybind = Enum.KeyCode | Enum.UserInputType

type props = {
    info: Types.info,
    initialValue: keybind,

    update: (value: keybind) -> (),
}

type styles = {
    background: RoactBinding<Color3>,
}

local function Keybind(props: props, hooks: RoactHooks.Hooks)
    local ref = hooks.useValue(Roact.createRef())

    local keybind, updateKeybind = hooks.useState(props.initialValue :: keybind?)

    local styles: any, api = RoactSpring.useSpring(hooks, function()
        return {
            background = props.info.theme.elementColor,
            config = RoactSpring.config.stiff :: any,
        }
    end)

    local styles: styles = styles

    hooks.useEffect(function()
        if keybind then
            props.update(keybind)
        end
    end, { keybind })

    return Roact.createElement(Templates.Toggle, {
        [Roact.Ref] = ref.value :: any,

        BackgroundColor3 = styles.background,
        LayoutOrder = props.info.order,
        Text = keybind and keybind.Name or ". . .",

        [Roact.Event.MouseButton1Click] = function(_self: TextButton)
            updateKeybind(nil :: any)

            local input = UserInputService.InputEnded:Wait(); if 
                (input.KeyCode and input.KeyCode ~= Enum.KeyCode.Escape) or 
                (input.UserInputType and table.find(INPUTS, input.UserInputType))
            then
                updateKeybind(input.KeyCode or input.UserInputType)
                props.update(input.KeyCode or input.UserInputType)
            end
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

        Icon = { ImageColor3 = props.info.theme.schemeColor },
    })
end

return (RoactHooks.new(Roact :: any)(Keybind) :: any) :: RoactElementFn<props>
