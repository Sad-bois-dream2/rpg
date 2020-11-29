LinkLuaModifier("modifier_talent_1", "talents/talent_1", LUA_MODIFIER_MOTION_NONE)

modifier_talent_1 = class({
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

function modifier_talent_1:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_1:GetStrengthBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 1) * 10
end