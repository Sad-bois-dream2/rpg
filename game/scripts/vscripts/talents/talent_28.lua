LinkLuaModifier("modifier_talent_28", "talents/talent_28", LUA_MODIFIER_MOTION_NONE)

modifier_talent_28 = class({
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

function modifier_talent_28:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_28:GetStrengthPercentBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 28) * 0.1
end

function modifier_talent_28:GetFireProtectionBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 28) * 0.05
end

function modifier_talent_28:GetFrostProtectionBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 28) * 0.05
end

function modifier_talent_28:GetEarthProtectionBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 28) * 0.05
end

function modifier_talent_28:GetVoidProtectionBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 28) * 0.05
end

function modifier_talent_28:GetHolyProtectionBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 28) * 0.05
end

function modifier_talent_28:GetNatureProtectionBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 28) * 0.05
end

function modifier_talent_28:GetInfernoProtectionBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 28) * 0.05
end

