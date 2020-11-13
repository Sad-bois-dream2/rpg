LinkLuaModifier("modifier_talent_27", "talents/talent_27", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_27_effect", "talents/talent_27", LUA_MODIFIER_MOTION_NONE)

modifier_talent_27 = class({
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
	 IsAura = function(self)
        return true
    end,
    GetModifierAura = function(self)
        return "modifier_talent_27_effect"
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraDuration = function(self)
        return 0
    end,
    GetAuraRadius = function(self)
        return 900
    end,
	GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

modifier_talent_27_effect = class({
	IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end
})

function modifier_talent_27:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_27_effect:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
end

function modifier_talent_27_effect:GetFireProtectionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 27) * 0.05
	return bonus
end

function modifier_talent_27_effect:GetFrostProtectionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 27) * 0.05
	return bonus
end

function modifier_talent_27_effect:GetEarthProtectionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 27) * 0.05
	return bonus
end

function modifier_talent_27_effect:GetVoidProtectionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 27) * 0.05
	return bonus
end

function modifier_talent_27_effect:GetInfernoProtectionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 27) * 0.05
	return bonus
end

function modifier_talent_27_effect:GetHolyProtectionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 27) * 0.05
	return bonus
end

function modifier_talent_27_effect:GetNatureProtectionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 27) * 0.05
	return bonus
end

function modifier_talent_27_effect:GetAttackSpeedBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 27) * 20
	return bonus
end

function modifier_talent_27_effect:GetSpellHasteBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 27) * 20
	return bonus
end
