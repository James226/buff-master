local ConfigWindowAdapter = {}

function ConfigWindowAdapter.new(viewPrototype)
	local self = setmetatable({},  { __index = ConfigWindowAdapter })

	viewPrototype:GetChild("CloseButton"):AddEvent("ButtonSignal", function() self:OnClose() end)
	self.view = viewPrototype:GetInstance(self)

	return self
end

function ConfigWindowAdapter:OnClose()
	self.view:Show(false)
end

function ConfigWindowAdapter:SetStatus(message)
	self.view:FindChild("Status"):SetText(message)
end

_G.BuffMaster.Adapters.ConfigWindow = ConfigWindowAdapter