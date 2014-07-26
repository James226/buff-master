local ConfigWindowAdapter = {}

function ConfigWindowAdapter.new(view)
	local self = setmetatable({}, { __index = ConfigWindowAdapter })

	view:FindChild("CloseButton"):AddEventHandler("ButtonSignal", "OnClose", self)

	self.view = view
	return self
end

function ConfigWindowAdapter:OnClose()
	Print("Close")
	self.view.Show(false)
end

function ConfigWindowAdapter:SetStatus(message)
	self.view:FindChild("Status"):SetText(message)
end



_G.BuffMaster.Adapters.ConfigWindow = ConfigWindowAdapter