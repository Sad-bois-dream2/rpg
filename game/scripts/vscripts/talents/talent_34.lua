LinkLuaModifier("modifier_talent_34", "talents/talent_34", LUA_MODIFIER_MOTION_NONE)

modifier_talent_34 = class({
	IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_talent_34:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_34:GetIntellectPercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 34) * 0.1
	return bonus
end

function modifier_talent_34:GetSpellDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 34) * 0.07
	return bonus
end
