local RoactTemplate = require(script.Parent.RoactTemplate)
local RoactPath = script.Parent.Parent.Roact

local TemplateFolder = game:GetObjects("rbxassetid://13475443187")[1]

local Templates = {}; for _index, ui in ipairs(TemplateFolder:GetChildren()) do
    Templates[ui.Name] = RoactTemplate.fromInstance(RoactPath, ui)
end

return Templates
