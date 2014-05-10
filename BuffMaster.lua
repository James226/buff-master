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
	local groupOptionsList = self.wndMain:FindChild("GroupOptionsList")
	groupOptionsList:DestroyChildren()

	local buffOptions = Apollo.LoadForm(self.xmlDoc, "SubForms.GroupOptions", groupOptionsList, self)
	buffOptions:SetData(self.buffs)
	buffOptions:FindChild("OptionsLabel"):SetText("Buff Bar Options")
	self:InitializeGroup(buffOptions, self.buffs)
	

	local debuffOptions = Apollo.LoadForm(self.xmlDoc, "SubForms.GroupOptions", groupOptionsList, self)
	debuffOptions:SetData(self.debuffs)
	debuffOptions:FindChild("OptionsLabel"):SetText("Debuff Bar Options")
	self:InitializeGroup(debuffOptions, self.debuffs)

	local cooldownOptions = Apollo.LoadForm(self.xmlDoc, "SubForms.GroupOptions", groupOptionsList, self)
	cooldownOptions:SetData(self.cooldowns)
	cooldownOptions:FindChild("OptionsLabel"):SetText("Cooldown Bar Options")
	self:InitializeGroup(cooldownOptions, self.cooldowns)

	groupOptionsList:ArrangeChildrenVert()
end

function BuffMaster:InitializeGroup(groupFrame, group)
	groupFrame:FindChild("Enabled"):SetCheck(group:IsEnabled())
	groupFrame:FindChild("BackgroundColor"):FindChild("Text"):SetTextColor(group.bgColor)
	groupFrame:FindChild("BarColor"):FindChild("Text"):SetTextColor(group.barColor)
	groupFrame:FindChild("StartFromTop"):SetCheck(group.anchorFromTop)
	groupFrame:FindChild("BarWidth"):SetValue(group.barSize.Width)
	groupFrame:FindChild("BarWidthValue"):SetText(string.format("%.f", group.barSize.Width))
	groupFrame:FindChild("BarHeight"):SetValue(group.barSize.Height)
	groupFrame:FindChild("BarHeightValue"):SetText(string.format("%.f", group.barSize.Height))
	local excludedOptions = groupFrame:FindChild("ExcludedOptions")
	excludedOptions:DestroyChildren()
	for _, exclusion in pairs(group.Exclusions) do
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

function BuffMaster:OnBuffEnabledChanged( wndHandler, wndControl, eMouseButton )
	local group = wndHandler:GetParent():GetData()
	group:SetEnabled(wndHandler:IsChecked())
end

---------------------------------------------------------------------------------------------------
-- Appearance Functions
---------------------------------------------------------------------------------------------------

function BuffMaster:OnBarWidthChanged( wndHandler, wndControl, fNewValue, fOldValue )
	local group = wndHandler:GetParent():GetData()
	group:SetBarWidth(fNewValue)
	wndHandler:GetParent():FindChild("BarWidthValue"):SetText(string.format("%.f", fNewValue))
end

function BuffMaster:OnBarWidthValueChanged( wndHandler, wndControl, strText )
	local group = wndHandler:GetParent():GetData()
	local value = tonumber(strText)
	wndHandler:SetText(tostring(value))
	wndHandler:GetParent():FindChild("BarWidth"):SetValue(value)
	group:SetBarWidth(value)
end

function BuffMaster:OnBarHeightChanged( wndHandler, wndControl, fNewValue, fOldValue )
	local group = wndHandler:GetParent():GetData()
	group:SetBarHeight(fNewValue)
	wndHandler:GetParent():FindChild("BarHeightValue"):SetText(string.format("%.f", fNewValue))
end

function BuffMaster:OnBarHeightValueChanged( wndHandler, wndControl, strText )
	local group = wndHandler:GetParent():GetData()
	local value = tonumber(strText)
	wndHandler:SetText(tostring(value))
	wndHandler:GetParent():FindChild("BarHeight"):SetValue(value)
	group:SetBarHeight(value)
end

function BuffMaster:EditBuffBackgroundColor( wndHandler, wndControl, eMouseButton )
	local group = wndHandler:GetParent():GetData()
	local color = group.bgColor
	self.colorPicker:OpenColorPicker(color, function()
		test = wndHandler
		wndHandler:FindChild("Text"):SetTextColor(color)
		group:SetBGColor(color)
	end)
end

function BuffMaster:EditBuffBarColor( wndHandler, wndControl, eMouseButton )
	local group = wndHandler:GetParent():GetData()
	local color = group.barColor
	self.colorPicker:OpenColorPicker(color, function()
		wndHandler:FindChild("Text"):SetTextColor(color)
		group:SetBarColor(color)
	end)
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
	local group = wndHandler:GetParent():GetData()
	local excludedOptions = wndHandler:GetParent():FindChild("ExcludedOptions")
	local filter = Apollo.LoadForm(self.xmlDoc, "ExcludedOption", excludedOptions, self)
	local exclusionName = wndHandler:GetParent():FindChild("Excluded"):GetText()
	filter:SetText(exclusionName)
	group:AddExclusion(exclusionName)
	excludedOptions:ArrangeChildrenVert()
end

function BuffMaster:OnExclusionRemove( wndHandler, wndControl, eMouseButton )
	local group = wndHandler:GetParent():GetData()
	local excludedOptions = wndHandler:GetParent():FindChild("ExcludedOptions")
	for _, excludedOption in pairs(excludedOptions:GetChildren()) do
		if excludedOption:IsChecked() then
			group:RemoveExclusion(excludedOption:GetText())
			excludedOption:Destroy()
		end
	end
	excludedOptions:ArrangeChildrenVert()
end

function BuffMaster:OnBuffStartFromTopChanged( wndHandler, wndControl, eMouseButton )
	local group = wndHandler:GetParent():GetData()
	group:AnchorFromTop(wndHandler:IsChecked())
end

-----------------------------------------------------------------------------------------------
-- BuffMaster Instance
-----------------------------------------------------------------------------------------------
local BuffMasterInst = BuffMaster:new()
BuffMasterInst:Init()
