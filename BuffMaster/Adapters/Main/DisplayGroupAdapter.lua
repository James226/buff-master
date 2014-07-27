require "Window"

local DisplayGroupAdapter = {}

function DisplayGroupAdapter.new(ui)
	local self = setmetatable({}, { __index = DisplayGroupAdapter })

	self.ui = ui
	self.view = ui
				:Create(_G.BuffMaster.Views.Main.DisplayGroup)
				:GetInstance(self)

	return self
end

function DisplayGroupAdapter:AddItem(item)
	local icon = self.ui:Create(_G.BuffMaster.Views.Main.DisplayIcon):GetInstance(self, self.view)
	icon:SetSprite("")
end

_G.BuffMaster.Adapters.Main.DisplayGroup = DisplayGroupAdapter