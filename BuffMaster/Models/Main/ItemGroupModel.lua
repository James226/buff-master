local ItemGroupModel = {}

function ItemGroupModel.new(displayGroup)
	local self = setmetatable({}, { __index = ItemGroupModel })

	self.displayGroup = displayGroup
	self.updateTimer = ApolloTimer.Create(1/60, true, "OnUpdate", self)

	return self
end

function ItemGroupModel:OnUpdate()
	local player = GameLib.GetPlayerUnit()
	player:GetBuffs()
end

_G.BuffMaster.Models.Main.ItemGroupModel = ItemGroupModel