-- This is example how to add modifiers to each item and how make any modifier affect any hero stat. Items may work without modifier, but idk reason because they will not give anything.
-- Don't forgot to require item file in items/require.lua

modifier_inventory_item_example = class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end,
})

-- Every Get() function below must return number (can be negative) else will be ignored
-- For all percent Get() functions below: 1.0 = 100%
function modifier_inventory_item_example:GetStrengthBonus()
    return 0
end

function modifier_inventory_item_example:GetStrengthPercentBonus()
    return 0
end

function modifier_inventory_item_example:GetAgilityBonus()
    return 0
end

function modifier_inventory_item_example:GetAgilityPercentBonus()
    return 0
end

function modifier_inventory_item_example:GetIntellectBonus()
    return 0
end

function modifier_inventory_item_example:GetIntellectPercentBonus()
    return 0
end

function modifier_inventory_item_example:GetPrimaryAttributeBonus()
    return 0
end

function modifier_inventory_item_example:GetPrimaryAttributePercentBonus()
    return 0
end

function modifier_inventory_item_example:GetAttackDamageBonus()
    return 0
end

function modifier_inventory_item_example:GetAttackDamagePercentBonus()
    return 0
end

function modifier_inventory_item_example:GetAttackSpeedBonus()
    return 0
end

function modifier_inventory_item_example:GetAttackSpeedPercentBonus()
    return 0
end

-- 1.0 = 100%
function modifier_inventory_item_example:GetSpellDamageBonus()
    return 0
end

-- flat value 1-800
function modifier_inventory_item_example:GetSpellHasteBonus()
    return 0
end

-- 1.0 = 100%
function modifier_inventory_item_example:GetSpellHastePercentBonus()
    return 0
end

function modifier_inventory_item_example:GetAttackRangeBonus()
    return 0
end

function modifier_inventory_item_example:GetAttackRangePercentBonus()
    return 0
end

function modifier_inventory_item_example:GetCastRangeBonus()
    return 0
end

function modifier_inventory_item_example:GetCastRangePercentBonus()
    return 0
end

function modifier_inventory_item_example:GetMoveSpeedBonus()
    return 0
end

function modifier_inventory_item_example:GetMoveSpeedPercentBonus()
    return 0
end

function modifier_inventory_item_example:GetHealthRegenerationBonus()
    return 0
end

function modifier_inventory_item_example:GetHealthRegenerationPercentBonus()
    return 0
end

function modifier_inventory_item_example:GetManaRegenerationBonus()
    return 0
end

function modifier_inventory_item_example:GetManaRegenerationPercentBonus()
    return 0
end

function modifier_inventory_item_example:GetManaBonus()
    return 0
end

function modifier_inventory_item_example:GetManaPercentBonus()
    return 0
end

function modifier_inventory_item_example:GetHealthBonus()
    return 0
end

function modifier_inventory_item_example:GetHealthPercentBonus()
    return 0
end

-- 1.0 = 100%
function modifier_inventory_item_example:GetDamageReductionBonus()
    return 0
end

-- for all elemental dmg/protection: 1.0 = 100%
function modifier_inventory_item_example:GetFireProtectionBonus()
    return 0
end

function modifier_inventory_item_example:GetFrostProtectionBonus()
    return 0
end

function modifier_inventory_item_example:GetEarthProtectionBonus()
    return 0
end

function modifier_inventory_item_example:GetVoidProtectionBonus()
    return 0
end

function modifier_inventory_item_example:GetHolyProtectionBonus()
    return 0
end

function modifier_inventory_item_example:GetNatureProtectionBonus()
    return 0
end

function modifier_inventory_item_example:GetInfernoProtectionBonus()
    return 0
end

function modifier_inventory_item_example:GetFireDamageBonus()
    return 0
end

function modifier_inventory_item_example:GetFrostDamageBonus()
    return 0
end

function modifier_inventory_item_example:GetEarthDamageBonus()
    return 0
end

function modifier_inventory_item_example:GetVoidDamageBonus()
    return 0
end

function modifier_inventory_item_example:GetHolyDamageBonus()
    return 0
end

function modifier_inventory_item_example:GetNatureDamageBonus()
    return 0
end

function modifier_inventory_item_example:GetInfernoDamageBonus()
    return 0
end

function modifier_inventory_item_example:GetSummonDamageBonus()
    return 0
end

-- 1.0 = 100%
function modifier_inventory_item_example:GetSingleDamageBonus()
    return 0
end

-- 1.0 = 100%
function modifier_inventory_item_example:GetAOEDamageBonus()
    return 0
end

-- 1.0 = 100%
function modifier_inventory_item_example:GetDOTDamageBonus()
    return 0
end

-- 1.0 = 100%
function modifier_inventory_item_example:GetFirstAbilitySpellDamageBonus()
    return 0
end

-- 1.0 = 100%
function modifier_inventory_item_example:GetFirstAbilitySpellDamageBonus()
    return 0
end

-- 1.0 = 100%
function modifier_inventory_item_example:GetSecondAbilitySpellDamageBonus()
    return 0
end

-- 1.0 = 100%
function modifier_inventory_item_example:GetThirdAbilitySpellDamageBonus()
    return 0
end

-- 1.0 = 100%
function modifier_inventory_item_example:GetFourthAbilitySpellDamageBonus()
    return 0
end

-- 1.0 = 100%
function modifier_inventory_item_example:GetFifthAbilitySpellDamageBonus()
    return 0
end

-- 1.0 = 100%
function modifier_inventory_item_example:GetSixthAbilitySpellDamageBonus()
    return 0
end
-- 1.0 = 100%, damageTable = table of incoming damage instance
function modifier_inventory_item_example:GetAdditionalConditionalDamage(damageTable)
    return 0
end

function modifier_inventory_item_example:GetArmorBonus()
    return 0
end

function modifier_inventory_item_example:GetArmorPercentBonus()
    return 0
end

-- use this if you wanna make taunt (force creeps nearby ignore all aggro and focus target with taunt modifier)
function modifier_inventory_item_example:IsTaunt()
    return false
end

-- use this if you wanna make skill/something else that force creeps ignore aggro and focus one target, must return valid target to focus or will be ignored
-- p.s. works only for creeps
function modifier_inventory_item_example:GetIgnoreAggroTarget()
    return self:GetParent()
end

-- 1.0 = 100% (capped at 50%).
function modifier_inventory_item_example:GetCooldownReductionBonus()
    return 0.0
end

-- 1.0 = 100% (capped at 50%).
function modifier_inventory_item_example:GetFirstAbilityCooldownReductionBonus()
    return 0.0
end

-- 1.0 = 100% (capped at 50%).
function modifier_inventory_item_example:GetSecondAbilityCooldownReductionBonus()
    return 0.0
end

-- 1.0 = 100% (capped at 50%).
function modifier_inventory_item_example:GetThirdAbilityCooldownReductionBonus()
    return 0.0
end

-- 1.0 = 100% (capped at 50%).
function modifier_inventory_item_example:GetFourthAbilityCooldownReductionBonus()
    return 0.0
end

-- 1.0 = 100% (capped at 50%).
function modifier_inventory_item_example:GetFifthAbilityCooldownReductionBonus()
    return 0.0
end

-- 1.0 = 100% (capped at 50%).
function modifier_inventory_item_example:GetSixthAbilityCooldownReductionBonus()
    return 0.0
end

-- exact value
function modifier_inventory_item_example:GetBaseAttackTime()
    return 1.7
end

-- flat bonus, 0.1 = 0.1
function modifier_inventory_item_example:GetBaseAttackTimeBonus()
    return 0
end

-- percent bonus 1.0 = 100%
function modifier_inventory_item_example:GetBaseAttackTimePercentBonus()
    return 0
end

function modifier_inventory_item_example:GetHealingReceivedPercentBonus()
    return 0 -- finalHeal = heal * (1 + this)
end

function modifier_inventory_item_example:GetHealingCausedPercentBonus()
    return 0 -- finalHeal = heal * (1 + this)
end

-- increase duration all of debuffs caused by entity, 1.0 = 100%
function modifier_inventory_item_example:GetDebuffAmplificationBonus()
    return 0
end

-- decrease duration all of debuffs that entity get, 1.0 = 100% , stacking multiplicatively
function modifier_inventory_item_example:GetDebuffResistanceBonus()
    return 0
end

-- increase duration all of buffs caused by entity, 1.0 = 100%
function modifier_inventory_item_example:GetBuffAmplificationBonus()
    return 0
end

-- increase all critical damage caused by owner, 1.0 = 100%
function modifier_inventory_item_example:GetCriticalDamageBonus()
    return 0
end

-- increase all critical strikes proc chance of owner, 1.0 = 100%. finalCritChance = critChance * this
function modifier_inventory_item_example:GetCriticalChanceBonus()
    return 0
end

-- increase all aggro caused of owner, 1.0 = 100%
function modifier_inventory_item_example:GetAggroCausedPercentBonus()
    return 0
end

-- provide immunity to all stun modifiers
function modifier_inventory_item_example:GetImmunityToStun()
    return false
end

-- provide immunity to all root modifiers
function modifier_inventory_item_example:GetImmunityToRoot()
    return false
end

-- provide immunity to all silence modifiers
function modifier_inventory_item_example:GetImmunityToSilence()
    return false
end

-- provide immunity to all hex modifiers
function modifier_inventory_item_example:GetImmunityToHex()
    return false
end

-- Don't forget basic stuff too
LinkLuaModifier("modifier_inventory_item_example", "items/item_example", LUA_MODIFIER_MOTION_NONE)