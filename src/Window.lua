local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

local Roact: Roact = require(script.Parent.Parent.Roact) :: any
local RoactHooks = require(script.Parent.Parent.RoactHooks)
local RoactSpring = require(script.Parent.Parent.RoactSpring)
local RoactTemplate = require(script.Parent.RoactTemplate)

local Templates = require(script.Parent.Templates)
local Types = require(script.Parent.Types)

local Blur = require(script.Parent.Blur)

type props = {
    visible: boolean,
    title: string,
    theme: Types.theme,
    close: () -> (),
}

type styles = {
    position: RoactBinding<UDim2>,
}

local function Window(props: props, hooks: RoactHooks.Hooks)
    local pagesOpened, updatePages = hooks.useState({} :: { boolean })
    local _, render = hooks.useState(nil)
    
    local tips = hooks.useValue({} :: { [string]: boolean })
    local ref = hooks.useValue(Roact.createRef())
    local dragConnection = hooks.useValue(nil :: RBXScriptConnection?)

    local styles: any, api = RoactSpring.useSpring(hooks, function()
        return {
            position = UDim2.fromScale(0.25, 0.25),
            config = RoactSpring.config.stiff :: any,
        }
    end)

    local styles: styles = styles

    hooks.useEffect(function()
        return function()
            if dragConnection.value then
                dragConnection.value:Disconnect()
                dragConnection.value = nil
            end
        end
    end, {})

    local opened; for key, value in pairs(pagesOpened) do
        if value then opened = key; break end
    end

    for pageName, page in pairs(props[Roact.Children]) do 
        for elementName, element in pairs(page.props[Roact.Children]) do
            tips.value[elementName] = tips.value[elementName] or false

            element.props.info.ref = ref.value
            element.props.info.theme = props.theme
            element.props.info.name = elementName
            element.props.info.tip = {
                opened = tips.value[elementName],
                update = function(value: boolean)
                   tips.value[elementName] = value
                   render()
                end,
            }
        end

        page.props = {
            [Roact.Children] = page.props[Roact.Children],

            ref = ref.value,
            theme = props.theme,
            name = pageName,

            opened = opened == pageName and true or false,
            
            open = function()
                local newPages = table.clone(pagesOpened); for key, value in pairs(newPages) do
                    if value == true then
                        newPages[key] = false
                    elseif pageName == key then
                        newPages[key] = true
                    end
                end
    
                updatePages(newPages)
            end,
        }
    end

    return Roact.createElement(Templates.Window, {
        [Roact.Ref] = ref.value,

        Visible = props.visible,
        BackgroundColor3 = props.theme.background,
        Position = styles.position,
    }, {
        Header = {
            BackgroundColor3 = props.theme.header,

            [Roact.Children] = {
                Title = { Text = props.title },
                Coverup = { BackgroundColor3 = props.theme.header },
                Close = {
                    [Roact.Event.MouseButton1Click] = props.close,
                },
            } :: any,

            [Roact.Event.InputBegan] = function(_self: Frame, input: InputObject)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and not dragConnection.value then
                    dragConnection.value = RunService.Heartbeat:Connect(function()
                        local mousePos = UserInputService:GetMouseLocation()

                        api.start({
                            position = UDim2.fromOffset(mousePos.X, mousePos.Y),
                        })
                    end)
                end
            end,

            [Roact.Event.InputEnded] = function(_self: Frame, input: InputObject)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and dragConnection.value then
                    dragConnection.value:Disconnect()
                    dragConnection.value = nil
                end
            end,
        },

        Side = {
            BackgroundColor3 = props.theme.header,

            [Roact.Children] = {
                Coverup = { BackgroundColor3 = props.theme.header },
            },
        },

        Pages = {
            Blur = RoactTemplate.wrapped(Blur, {
                render = render,
                tips = tips.value,
                theme = props.theme,
            }),

            [Roact.Children] = {
                Pages = Roact.createFragment(props[Roact.Children]),
            },
        },
    })
end

return (RoactHooks.new(Roact :: any)(Window) :: any) :: RoactElementFn<props>
