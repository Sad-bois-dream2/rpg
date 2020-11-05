LinkLuaModifier("modifier_talent_22", "talents/talent_22", LUA_MODIFIER_MOTION_NONE)

modifier_talent_22 = class({
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

function modifier_talent_22:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_22:GetAttackDamagePercentBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 22) * (-0.05)
end

function modifier_talent_22:GetAttackSpeedPercentBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 22) * 0.1
end

function modifier_talent_22:GetSpellDamageBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 22) * 0.05
end