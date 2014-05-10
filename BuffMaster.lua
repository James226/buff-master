-----------------------------------------------------------------------------------------------
-- Client Lua Script for BuffMaster
-- Copyright (c) James Parker 2014. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
local BuffMaster = {} 
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function BuffMaster:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    return o
end

function BuffMaster:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- BuffMaster OnLoad
-----------------------------------------------------------------------------------------------
function BuffMaster:OnLoad()
	Apollo.LoadSprites("BarTextures.xml")
	self.xmlDoc = XmlDoc.CreateFromFile("BuffMaster.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- BuffMaster OnDocLoaded
-----------------------------------------------------------------------------------------------
function BuffMaster:OnDocLoaded()
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "BuffMasterForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

	    self.buffs = BuffMasterLibs.DisplayBlock.new(self.xmlDoc)
	    self.buffs:SetName("Buffs")
	    self.buffs:SetPosition(0.3, 0.5)

	    self.debuffs = BuffMasterLibs.DisplayBlock.new(self.xmlDoc)
	    self.debuffs:SetName("Debuffs")
	    self.debuffs:SetPosition(0.7, 0.5)

	    self.cooldowns = BuffMasterLibs.DisplayBlock.new(self.xmlDoc)
	    self.cooldowns:SetName("Cooldowns")
	    self.cooldowns:SetPosition(0.5, 0.4)

	    if self.saveData ~= nil then
	    	self:LoadSaveData(self.saveData)
	    end
	
		self.colorPicker = BuffMasterLibs.ColorPicker.new(self.xmlDoc)

		Apollo.RegisterEventHandler("VarChange_FrameCount", "OnFrame", self)
		Apollo.RegisterSlashCommand("bm", "OnBuffMasterOn", self)

		self:InitializeConfigForm()
	end
end

function BuffMaster:InitializeConfigForm()
	local buffOptions = self.wndMain:FindChild("BuffOptions")
	buffOptions:FindChild("Enabled"):SetCheck(self.buffs:IsEnabled())
	buffOptions:FindChild("BackgroundColor"):FindChild("Text"):SetTextColor(self.buffs.bgColor)
	buffOptions:FindChild("BarColor"):FindChild("Text"):SetTextColor(self.buffs.barColor)
	buffOptions:FindChild("StartFromTop"):SetCheck(self.buffs.anchorFromTop)
	local excludedOptions = buffOptions:FindChild("ExcludedOptions")
	excludedOptions:DestroyChildren()
	for _, exclusion in pairs(self.buffs.Exclusions) do
		local filter = Apollo.LoadForm(self.xmlDoc, "ExcludedOption", excludedOptions, self)
		filter:SetText(exclusion)
	end
	excludedOptions:ArrangeChildrenVert()

	local debuffOptions = self.wndMain:FindChild("DebuffOptions")
	debuffOptions:FindChild("Enabled"):SetCheck(self.debuffs:IsEnabled())
	debuffOptions:FindChild("BackgroundColor"):FindChild("Text"):SetTextColor(self.debuffs.bgColor)
	debuffOptions:FindChild("BarColor"):FindChild("Text"):SetTextColor(self.debuffs.barColor)
	debuffOptions:FindChild("StartFromTop"):SetCheck(self.debuffs.anchorFromTop)
	local excludedOptions = debuffOptions:FindChild("ExcludedOptions")
	excludedOptions:DestroyChildren()
	for _, exclusion in pairs(self.debuffs.Exclusions) do
		local filter = Apollo.LoadForm(self.xmlDoc, "ExcludedOption", excludedOptions, self)
		filter:SetText(exclusion)
	end
	excludedOptions:ArrangeChildrenVert()

	local cooldownOptions = self.wndMain:FindChild("CooldownOptions")
	cooldownOptions:FindChild("Enabled"):SetCheck(self.cooldowns:IsEnabled())
	cooldownOptions:FindChild("BackgroundColor"):FindChild("Text"):SetTextColor(self.cooldowns.bgColor)
	cooldownOptions:FindChild("BarColor"):FindChild("Text"):SetTextColor(self.cooldowns.barColor)
	cooldownOptions:FindChild("StartFromTop"):SetCheck(self.cooldowns.anchorFromTop)
	local excludedOptions = cooldownOptions:FindChild("ExcludedOptions")
	excludedOptions:DestroyChildren()
	for _, exclusion in pairs(self.cooldowns.Exclusions) do
		local filter = Apollo.LoadForm(self.xmlDoc, "ExcludedOption", excludedOptions, self)
		filter:SetText(exclusion)
	end
	excludedOptions:ArrangeChildrenVert()
end

function BuffMaster:OnSave(eLevel)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return nil
    end
	local saveData = { 
		buffs = self.buffs:GetSaveData(),
		debuffs = self.debuffs:GetSaveData(),
		cooldowns = self.cooldowns:GetSaveData()
	}
	
	return saveData
end

function BuffMaster:OnRestore(eLevel, tData)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return nil
	end

	if self.Loaded then
		self:LoadSaveData(tData)
		self:InitializeConfigForm()	
	else
		self.saveData = tData
	end
end

function BuffMaster:LoadSaveData(tData)
	if tData.buffs then
		self.buffs:Load(tData.buffs)
	end

	if tData.debuffs then
		self.debuffs:Load(tData.debuffs)
	end

	if tData.cooldowns then
		self.cooldowns:Load(tData.cooldowns)
	end
end

function BuffMaster:OnFrame()
	self.currentPass = not self.currentPass

	local player = GameLib.GetPlayerUnit()
	if player then
		self.buffs:ProcessBuffs(player:GetBuffs().arBeneficial)
		self.debuffs:ProcessBuffs(player:GetBuffs().arHarmful)
		self.cooldowns:ProcessSpells()
	end
end

-----------------------------------------------------------------------------------------------
-- BuffMaster Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

function BuffMaster:OnBuffMasterOn()
	self:InitializeConfigForm()
	self.wndMain:Invoke()
end


-----------------------------------------------------------------------------------------------
-- BuffMasterForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function BuffMaster:OnOK()
	self.wndMain:Close()
end

function BuffMaster:EditBuffBackgroundColor( wndHandler, wndControl, eMouseButton )
	local color = self.buffs.bgColor
	self.colorPicker:OpenColorPicker(color, function()
		test = wndHandler
		wndHandler:FindChild("Text"):SetTextColor(color)
		self.buffs:SetBGColor(color)
	end)
end

function BuffMaster:EditBuffBarColor( wndHandler, wndControl, eMouseButton )
	local color = self.buffs.barColor
	self.colorPicker:OpenColorPicker(color, function()
		wndHandler:FindChild("Text"):SetTextColor(color)
		self.buffs:SetBarColor(color)
	end)
end

function BuffMaster:EditDebuffBackgroundColor( wndHandler, wndControl, eMouseButton )
	local color = self.debuffs.bgColor
	self.colorPicker:OpenColorPicker(color, function()
		test = wndHandler
		wndHandler:FindChild("Text"):SetTextColor(color)
		self.debuffs:SetBGColor(color)
	end)
end

function BuffMaster:EditDebuffBarColor( wndHandler, wndControl, eMouseButton )
	local color = self.debuffs.barColor
	self.colorPicker:OpenColorPicker(color, function()
		wndHandler:FindChild("Text"):SetTextColor(color)
		self.debuffs:SetBarColor(color)
	end)
end

function BuffMaster:EditCooldownBackgroundColor( wndHandler, wndControl, eMouseButton )
	local color = self.cooldowns.bgColor
	self.colorPicker:OpenColorPicker(color, function()
		wndHandler:FindChild("Text"):SetTextColor(color)
		self.cooldowns:SetBGColor(color)
	end)
end

function BuffMaster:EditCooldownBarColor( wndHandler, wndControl, eMouseButton )
	local color = self.cooldowns.barColor
	self.colorPicker:OpenColorPicker(color, function()
		wndHandler:FindChild("Text"):SetTextColor(color)
		self.cooldowns:SetBarColor(color)
	end)
end


function BuffMaster:OnBuffEnabledChanged( wndHandler, wndControl, eMouseButton )
	self.buffs:SetEnabled(wndHandler:IsChecked())
end

function BuffMaster:OnDebuffEnabledChanged( wndHandler, wndControl, eMouseButton )
	self.debuffs:SetEnabled(wndHandler:IsChecked())
end

function BuffMaster:OnCooldownEnabledChanged( wndHandler, wndControl, eMouseButton )
	self.cooldowns:SetEnabled(wndHandler:IsChecked())
end

function BuffMaster:OnMoveBars( wndHandler, wndControl, eMouseButton )
	if wndHandler:GetText() == "Move Bars" then
		wndHandler:SetText("Lock Bars")
		self.buffs:SetMovable(true)
		self.debuffs:SetMovable(true)
		self.cooldowns:SetMovable(true)
	else
		wndHandler:SetText("Move Bars")
		self.buffs:SetMovable(false)
		self.debuffs:SetMovable(false)
		self.cooldowns:SetMovable(false)
	end
end


function BuffMaster:OnExcludedChanged( wndHandler, wndControl, strText )
	if strText == "" then
		wndHandler:FindChild("Placeholder"):Show(true)
	else
		wndHandler:FindChild("Placeholder"):Show(false)
	end
end

function BuffMaster:OnAddExclusion( wndHandler, wndControl, eMouseButton )
	local excludedOptions = wndHandler:GetParent():FindChild("ExcludedOptions")
	local filter = Apollo.LoadForm(self.xmlDoc, "ExcludedOption", excludedOptions, self)
	local exclusionName = wndHandler:GetParent():FindChild("Excluded"):GetText()
	filter:SetText(exclusionName)
	self.buffs:AddExclusion(exclusionName)
	excludedOptions:ArrangeChildrenVert()
end

function BuffMaster:OnExclusionRemove( wndHandler, wndControl, eMouseButton )
	local excludedOptions = wndHandler:GetParent():FindChild("ExcludedOptions")
	for _, excludedOption in pairs(excludedOptions:GetChildren()) do
		if excludedOption:IsChecked() then
			self.buffs:RemoveExclusion(excludedOption:GetText())
			excludedOption:Destroy()
		end
	end
	excludedOptions:ArrangeChildrenVert()
end

function BuffMaster:OnAddDebuffExclusion( wndHandler, wndControl, eMouseButton )
	local excludedOptions = wndHandler:GetParent():FindChild("ExcludedOptions")
	local filter = Apollo.LoadForm(self.xmlDoc, "ExcludedOption", excludedOptions, self)
	local exclusionName = wndHandler:GetParent():FindChild("Excluded"):GetText()
	filter:SetText(exclusionName)
	self.debuffs:AddExclusion(exclusionName)
	excludedOptions:ArrangeChildrenVert()
end

function BuffMaster:OnRemoveDebuffExclusion( wndHandler, wndControl, eMouseButton )
	local excludedOptions = wndHandler:GetParent():FindChild("ExcludedOptions")
	for _, excludedOption in pairs(excludedOptions:GetChildren()) do
		if excludedOption:IsChecked() then
			self.debuffs:RemoveExclusion(excludedOption:GetText())
			excludedOption:Destroy()
		end
	end
	excludedOptions:ArrangeChildrenVert()
end

function BuffMaster:OnAddCooldownExclusion( wndHandler, wndControl, eMouseButton )
	local excludedOptions = wndHandler:GetParent():FindChild("ExcludedOptions")
	local filter = Apollo.LoadForm(self.xmlDoc, "ExcludedOption", excludedOptions, self)
	local exclusionName = wndHandler:GetParent():FindChild("Excluded"):GetText()
	filter:SetText(exclusionName)
	self.cooldowns:AddExclusion(exclusionName)
	excludedOptions:ArrangeChildrenVert()
end

function BuffMaster:OnRemoveCooldownExclusion( wndHandler, wndControl, eMouseButton )
	local excludedOptions = wndHandler:GetParent():FindChild("ExcludedOptions")
	for _, excludedOption in pairs(excludedOptions:GetChildren()) do
		if excludedOption:IsChecked() then
			self.cooldowns:RemoveExclusion(excludedOption:GetText())
			excludedOption:Destroy()
		end
	end
	excludedOptions:ArrangeChildrenVert()
end

function BuffMaster:OnBuffStartFromTopChanged( wndHandler, wndControl, eMouseButton )
	self.buffs:AnchorFromTop(wndHandler:IsChecked())
end

function BuffMaster:OnDebuffStartFromTopChanged( wndHandler, wndControl, eMouseButton )
	self.debuffs:AnchorFromTop(wndHandler:IsChecked())
end

function BuffMaster:OnCooldownStartFromTopChanged( wndHandler, wndControl, eMouseButton )
	self.cooldowns:AnchorFromTop(wndHandler:IsChecked())
end

-----------------------------------------------------------------------------------------------
-- BuffMaster Instance
-----------------------------------------------------------------------------------------------
local BuffMasterInst = BuffMaster:new()
BuffMasterInst:Init()
