LinkLuaModifier("modifier_talent_20", "talents/talent_20", LUA_MODIFIER_MOTION_NONE)

modifier_talent_20 = class({
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

function modifier_talent_20:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
    self:StartIntervalThink(0.1)
end

function modifier_talent_20:OnIntervalThink()
    self:SetStackCount(1)
end

function modifier_talent_20:GetAttackDamagePercentBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 20) * Units:GetArmor(self.hero) * 0.0007
end

function modifier_talent_20:GetSpellDamageBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 20) * Units:GetArmor(self.hero) * 0.0007
end