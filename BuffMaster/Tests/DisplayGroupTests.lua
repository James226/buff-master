describe("DisplayGroup", function()
	local DisplayGroup, GeminiGUI
	local loadedForms = {}

	setup(function()
		DisplayGroup = _G.BuffMaster.Adapters.Main.DisplayGroup
		GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage

		local loadForm = Apollo.LoadForm
		Apollo.LoadForm = mock(Apollo.LoadForm, true, function(...)
			local form = loadForm(...)
			table.insert(loadedForms, form)
			return form
		end)
	end)

	teardown(function()
		Apollo.LoadForm:revert()

		for _, form in pairs(loadedForms) do
			form:Destroy()
		end
	end)

	it("should create a view group when constructed", function()
		local displayGroup = DisplayGroup.new(GeminiGUI)
		assert.is.not_nil(displayGroup.view)
	end)

	describe("AddItem", function()
		local displayIcon
		setup(function()
			spy.on(GeminiGUI, "Create")

		end)

		teardown(function()
			GeminiGUI.Create:revert()
		end)

		it("should add new item to view", function()
			local displayGroup = DisplayGroup.new(GeminiGUI)
			displayGroup:AddItem({
				Name = "Test Buff"
			})

			assert.spy(GeminiGUI.Create).was.called_with(GeminiGUI, _G.BuffMaster.Views.Main.DisplayIcon)
		end)
	end)
end)