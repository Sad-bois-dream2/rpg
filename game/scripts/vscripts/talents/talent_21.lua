LinkLuaModifier("modifier_talent_21", "talents/talent_21", LUA_MODIFIER_MOTION_NONE)

modifier_talent_21 = class({
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

function modifier_talent_21:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
    self:StartIntervalThink(0.1)
end

function modifier_talent_20:OnIntervalThink()
    self:SetStackCount(1)
end

function modifier_talent_21:GetHealthBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 21) * 500
end

function modifier_talent_21:GetArmorBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 21) * 5
end

function modifier_talent_21:GetMoveSpeedPercentBonus()
    if (self.hero:HasModifier("modifier_out_of_combat_buff")) then
        return -0.15
    end
    return 0
end