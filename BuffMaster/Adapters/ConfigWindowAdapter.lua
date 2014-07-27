local ConfigWindowAdapter = {}

function ConfigWindowAdapter.new(viewPrototype)
	local self = setmetatable({}, { __index = ConfigWindowAdapter })

	self.view = viewPrototype:GetInstance(self)
	self.view:FindChild("CloseButton"):AddEventHandler("ButtonSignal", "Close")

	return self
end

function ConfigWindowAdapter:Close()
	self.view:Show(false)
end

function ConfigWindowAdapter:SetStatus(message)
	self.view:FindChild("Status"):SetText(message)
end



_G.BuffMaster.Adapters.ConfigWindow = ConfigWindowAdapter