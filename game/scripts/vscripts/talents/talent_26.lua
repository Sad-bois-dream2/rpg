LinkLuaModifier("modifier_talent_26", "talents/talent_26", LUA_MODIFIER_MOTION_NONE)

modifier_talent_26 = class({
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

function modifier_talent_26:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_26:GetFrostDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 26) * 0.1
	return bonus
end

function modifier_talent_26:GetNatureDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 26) * 0.1
	return bonus
end

function modifier_talent_26:GetHolyDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 26) * 0.1
	return bonus
end
