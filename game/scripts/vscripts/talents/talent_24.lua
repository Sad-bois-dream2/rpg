LinkLuaModifier("modifier_talent_24", "talents/talent_24", LUA_MODIFIER_MOTION_NONE)

modifier_talent_24 = class({
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

function modifier_talent_24:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
    self:OnIntervalThink()
    self:StartIntervalThink(1)
end

function modifier_talent_24:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local ability = self.hero:GetAbilityByIndex(0)
    local abilityCooldown = ability:GetCooldown(ability:GetLevel())
    for i = 1, self.hero:GetAbilityCount() - 1 do
        local newAbility = self.hero:GetAbilityByIndex(i)
        if (ability) then
            local newCooldown = newAbility:GetCooldown(newAbility:GetLevel())
            if (newCooldown < abilityCooldown) then
                abilityCooldown = newCooldown
                ability = newAbility
            end
        end
    end
    self.lowestCdAbility = ability
end

function modifier_talent_24:GetAdditionalConditionalDamage(damageTable)
    if (not damageTable.ability or damageTable.attacker ~= self.hero) then
        return
    end
    if (damageTable.ability == self.lowestCdAbility) then
        return TalentTree:GetHeroTalentLevel(damageTable.attacker, 24) * 0.07
    end
end

function modifier_talent_24:GetAttackSpeedPercentBonus()
    return (TalentTree:GetHeroTalentLevel(self.hero, 24) * 0.05) + 0.05
end
