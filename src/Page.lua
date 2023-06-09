local HttpService = cloneref(game:GetService("HttpService"))

local Roact: Roact = require(script.Parent.Parent.Roact) :: any
local RoactHooks = require(script.Parent.Parent.RoactHooks)
local RoactRouter: RoactRouter = require(script.Parent.Parent.RoactRouter) :: any

local Templates = require(script.Parent.Templates)
local Types = require(script.Parent.Types)

local merge = require(script.Parent.merge)

local e = Roact.createElement

type internal = {
    location: string,
}

type styles = {
    sideTransparency: RoactBinding<number>,
}

local function Page(props: internal, hooks: RoactHooks.Hooks)
    return e(Types.WindowContext.Consumer, {
        render = function(window)
            local Main = window.ref:getValue(); if not Main then
                return e("Frame", { Visible = false })
            end

            local history = RoactRouter.useHistory(hooks)

            local elementLocations = hooks.useValue({} :: Dictionary<string>)
        
            local elements = table.clone((props :: any)[Roact.Children]); for elementName, element in pairs(elements) do
                elementLocations.value[elementName] = elementLocations.value[elementName] or `/{HttpService:GenerateGUID(false)}_tip`
                element.props = merge(element.props, {
                    info = merge(element.props.info, {
                        name = elementName,
                        location = elementLocations.value[elementName],
                    } :: Types.Info),
                })
            end

            local visible = history.location.path:find(props.location, 1, true)
        
            return e(Templates.Page, {
                Visible = if visible then true else false,
                ScrollBarImageColor3 = Color3.fromRGB(
                    (window.theme.schemeColor.R * 255) - 16,
                    (window.theme.schemeColor.G * 255) - 15,
                    (window.theme.schemeColor.B * 255) - 28
                ),
            }, elements)
        end,
    })
end

return (RoactHooks.new(Roact :: any)(Page) :: any) :: RoactElementFn<internal>
