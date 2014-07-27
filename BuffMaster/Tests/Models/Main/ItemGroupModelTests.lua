describe("ItemGroupModel", function()
	local ItemGroupModel, DisplayGroup
	local itemGroupModel, displayGroup

	setup(function()
		ItemGroupModel = _G.BuffMaster.Models.Main.ItemGroupModel
		DisplayGroup = _G.BuffMaster.Adapters.Main.DisplayGroup
	end)

	before_each(function()
		DisplayGroup = mock(DisplayGroup, true)
		displayGroup = DisplayGroup.new()
	end)

	after_each(function()
		unmock(DisplayGroup)
	end)

	describe("constructor tests", function()
		it("should start a 10ms timer when created", function()
			spy.on(ApolloTimer, "Create")

			itemGroupModel = ItemGroupModel.new(displayGroup)

			assert.spy(ApolloTimer.Create).was.called_with(1/60, true, "OnUpdate", itemGroupModel)

			ApolloTimer.Create:revert()
		end)
	end)

	describe("functionality", function()
		local player
		before_each(function()
			itemGroupModel = ItemGroupModel.new(displayGroup)

			player = {
				GetBuffs = function() end
			}

			stub(GameLib, "GetPlayerUnit", function()
				return player
			end)
		end)

		after_each(function()
			GameLib.GetPlayerUnit:revert()
		end)

		describe("OnUpdate", function()
			it("should get player buffs", function()
				spy.on(player, "GetBuffs")

				itemGroupModel:OnUpdate()

				assert.spy(player.GetBuffs).was.called(1)
			end)
		end)
	end)

	
end)