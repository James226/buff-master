local DisplayBar = {} 

DisplayBar.__index = DisplayBar

setmetatable(DisplayBar, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function DisplayBar.new(xmlDoc, spell, id, maxTime, block)
    local self = setmetatable({}, DisplayBar)
    self.buff = buff
    self.Id = id
    self.isSet = false
    self.MaxTime = maxTime

    self.Frame = Apollo.LoadForm(xmlDoc, "BarTemplate", block.buffFrame:FindChild("ItemList"), self)
    self.Frame:FindChild("Text"):SetText(spell:GetName())
    self.Frame:FindChild("Icon"):SetSprite(spell:GetIcon())
    self.Frame:FindChild("RemainingOverlay"):SetMax(maxTime)
    self.Frame:SetSprite("BarTextures_Fire")
    self.Frame:FindChild("RemainingOverlay"):SetFullSprite("BarTextures_Fire")
    return self
end

function DisplayBar:OnGenerateSpellTooltip( wndHandler, wndControl, eToolTipType, x, y )
    if wndControl == wndHandler then
        Tooltip.GetSpellTooltipForm(self, wndHandler, GameLib.GetSpell(self.buff.splEffect:GetId()), false)
    end
end

function DisplayBar:SetBuff(buff, buffPosition)
    self.Frame:FindChild("RemainingOverlay"):SetProgress(buff.fTimeRemaining)
    if buff.nCount > 1 then
        self.Frame:FindChild("Text"):SetText(buff.splEffect:GetName() .. " (" .. buff.nCount .. ")")
    else
        self.Frame:FindChild("Text"):SetText(buff.splEffect:GetName())
    end

    if buff.fTimeRemaining ~= 0 then
        self.Frame:FindChild("Timer"):SetText(string.format("%.1fs", buff.fTimeRemaining))
    else
        self.Frame:FindChild("Timer"):SetText("")
    end
end

function DisplayBar:SetSpell(spell)
    local remainingCd = spell:GetCooldownRemaining()
    self.Frame:FindChild("RemainingOverlay"):SetProgress(remainingCd)
    self.Frame:FindChild("Text"):SetText(spell:GetName())

    if remainingCd ~= 0 then
        self.Frame:FindChild("Timer"):SetText(string.format("%.1fs", remainingCd))
    else
        self.Frame:FindChild("Timer"):SetText("")
    end
end

function DisplayBar:SetHeight(height)
    local left, top, right, bottom = self.Frame:GetAnchorOffsets()
    self.Frame:SetAnchorOffsets(left, top, right, top + height)

    local icon = self.Frame:FindChild("Icon")
    local iconHeight = icon:GetHeight()
    local left, top, right, bottom = icon:GetAnchorOffsets()
    icon:SetAnchorOffsets(left, top, left + iconHeight, bottom)

    local text = self.Frame:FindChild("Text")
    local left, top, right, bottom = text:GetAnchorOffsets()
    text:SetAnchorOffsets(iconHeight + 9, top, right, bottom)
end

function DisplayBar:SetBGColor(color)
    self.Frame:SetBGColor(color)
end

function DisplayBar:SetBarColor(color)
    test = self.Frame:FindChild("RemainingOverlay")
    self.Frame:FindChild("RemainingOverlay"):SetBarColor(color)
end

if _G["BuffMasterLibs"] == nil then
    _G["BuffMasterLibs"] = { }
end
_G["BuffMasterLibs"]["DisplayBar"] = DisplayBar