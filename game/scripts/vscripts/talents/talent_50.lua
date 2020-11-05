LinkLuaModifier("modifier_talent_50", "talents/talent_50", LUA_MODIFIER_MOTION_NONE)

modifier_talent_50 = class({
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
    end,
})

function modifier_talent_50:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_50:GetMoveSpeedPercentBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 50) * 0.08
end

function modifier_talent_50:GetAdditionalConditionalDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_talent_50")
    if (not modifier or damageTable.attacker ~= modifier.hero) then
        return
    end
    local enemyMovespeed = Units:GetMoveSpeed(damageTable.victim)
    local ownerMovespeed = Units:GetMoveSpeed(damageTable.attacker)
    local msDifference = ownerMovespeed - enemyMovespeed
    if (msDifference > 0) then
        return msDifference * TalentTree:GetHeroTalentLevel(self.hero, 50) * 0.001
    end
    return 0
end