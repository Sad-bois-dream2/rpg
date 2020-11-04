LinkLuaModifier("modifier_talent_31", "talents/talent_31", LUA_MODIFIER_MOTION_NONE)

modifier_talent_31 = class({
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

function modifier_talent_31:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_31:GetAgilityPercentBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 31) * 0.1
end

function modifier_talent_31:GetAttackSpeedPercentBonus()
    return (TalentTree:GetHeroTalentLevel(self.hero, 31) * 0.05) + 0.05
end