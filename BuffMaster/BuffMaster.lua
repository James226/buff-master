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
		"Lib:Busted-2.0"
		--"Gemini:DB-1.0"
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end

function BuffMaster:OnLoad()
	self.tests = {}
	Apollo.GetPackage("Lib:Busted-2.0").tPackage:Register(self.tests)

	Apollo.RegisterSlashCommand("bm", "OnCommand", self)
end

function BuffMaster:OnCommand(command, args)
	if args == "runtests" then
		self.tests:RunTests()
	end
end

function BuffMaster:OnConfigure()
	Print("Open Configuration")
end

local BuffMasterInst = BuffMaster.new()
BuffMasterInst:Init()
