LinkLuaModifier("modifier_talent_3", "talents/talent_3", LUA_MODIFIER_MOTION_NONE)

modifier_talent_3 = class({
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

function modifier_talent_3:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_3:GetHealthBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 3) * 150
end