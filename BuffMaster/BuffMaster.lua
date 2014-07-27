-----------------------------------------------------------------------------------------------
-- Client Lua Script for BuffMaster
-- Copyright (c) James Parker. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
local BuffMaster = {} 

function BuffMaster.new()
    self = setmetatable({}, { __index = BuffMaster })
    return self
end

function BuffMaster:Init()
	local bHasConfigureFunction = true
	local strConfigureButtonText = "BuffMaster"
	local tDependencies = {
		"Lib:Assert-1.0",
		"Lib:Busted-2.0",
		"Gemini:DB-1.0",
		"Gemini:GUI-1.0"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end

function BuffMaster:OnLoad()
	self.tests = {}
	Apollo.GetPackage("Lib:Busted-2.0").tPackage:Register(self.tests)
	self.db = Apollo.GetPackage("Gemini:DB-1.0").tPackage:New(self)
	self.ui = Apollo.GetPackage("Gemini:GUI-1.0").tPackage

	self.configWindow = 
		_G.BuffMaster.Adapters.ConfigWindow.new(
			self.ui
				:Create(_G.BuffMaster.Views.ConfigWindow))

	Apollo.FindWindowByName("BuffMasterConfig"):AddEventHandler("MouseButtonDown", "OnClick", self)

	Apollo.RegisterSlashCommand("bm", "OnCommand", self)
end

function BuffMaster:OnClick()
	Print("Close Me!")
end

function BuffMaster:OnCommand(command, args)
	if args == "runtests" then
		self.tests:RunTests()
	end
	self.configWindow:SetStatus("Status Test!!")
	Apollo.FindWindowByName("BuffMasterConfig"):AddEventHandler("MouseButtonDown", "OnClick", self)
end

function BuffMaster:OnConfigure()
	Print("Open Configuration")
end

local BuffMasterInst = BuffMaster.new()
BuffMasterInst:Init()
