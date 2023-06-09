local Roact: Roact = require(script.Parent.Parent.Roact) :: any
local RoactHooks = require(script.Parent.Parent.RoactHooks)
local RoactSpring = require(script.Parent.Parent.RoactSpring)
local RoactRouter: RoactRouter = require(script.Parent.Parent.RoactRouter) :: any

local Templates = require(script.Parent.Templates)
local Types = require(script.Parent.Types)

local e = Roact.createElement
local f = Roact.createFragment

type props = {
    description: string,
}

type internal = {
    template: RoactElement,
    location: string,
}

type styles = {
    position: RoactBinding<UDim2>,
}

local function Tip(props: props & internal, hooks: RoactHooks.Hooks)
    return e(Types.WindowContext.Consumer, {
        render = function(window)
            local Main = window.ref:getValue(); if not Main then
                return e("Frame", { Visible = false })
            end
        
            local history = RoactRouter.useHistory(hooks)
        
            local styles: any, api = RoactSpring.useSpring(hooks, function()
                return {
                    position = UDim2.fromScale(0, 2),
                    config = RoactSpring.config.gentle :: any,
                }
            end)
        
            local styles: styles = styles
        
            hooks.useEffect(function()
                local connection; connection = history.onChanged:connect(function(path)
                    local visible = path:find(props.location, 1, true)

                    api.start({
                        position = if visible then
                            UDim2.fromScale(0, 0)
                        else UDim2.fromScale(0, 2)
                    })
                end)
        
                return function()
                    connection:disconnect()
                    connection = nil :: any
                end
            end, {})
        
            return f({
                Button = e(props.template, {
                    ImageColor3 = window.theme.schemeColor,
        
                    [Roact.Event.MouseButton1Click] = function(_self: GuiButton)
                        history:push(history.location.path .. props.location)
                    end,
                }),
        
                Tip = e(Roact.Portal, {
                    target = Main.Tips :: Instance,
                }, {
                    Tip = e(Templates.Tip, {
                        BackgroundColor3 = Color3.fromRGB(
                            (window.theme.schemeColor.R * 255) - 14,
                            (window.theme.schemeColor.G * 255) - 17,
                            (window.theme.schemeColor.B * 255) - 13
                        ),
        
                        Position = styles.position,
                    }, {
                        Tip = {
                            TextColor3 = window.theme.textColor,
                            Text = props.description
                        },
                    }),
                }),
            })
        end,
    })
end

return (RoactHooks.new(Roact :: any)(Tip) :: any) :: RoactElementFn<props>
