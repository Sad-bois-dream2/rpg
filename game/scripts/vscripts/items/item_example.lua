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

-- this is flat like AS but capped at 8 this is so that old code dont need fix. Every flat spellhaste related stuff need to be *0.01 in lua from the display value in addon_english
function modifier_inventory_item_example:GetSpellHasteBonus()
    return 0
end
--this work like % AS 1.0 = 100%
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

function modifier_inventory_item_example:GetBlockBonus()
    return 0
end

function modifier_inventory_item_example:GetBlockPercentBonus()
    return 0
end

function modifier_inventory_item_example:GetMagicBlockBonus()
    return 0
end

function modifier_inventory_item_example:GetMagicBlockPercentBonus()
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

-- 1.0 = 100%, pls no, decrease % cooldown (capped at 50%). Fixed from set % cooldown to decrease % cooldown.
function modifier_inventory_item_example:GetCooldownReduction()
    return 0.0
end

-- exact value
function modifier_inventory_item_example:GetBaseAttackTime()
    return 1.7
end

function modifier_inventory_item_example:GetHealingReceivedBonus()
    return 0 -- finalHeal = heal + this
end

function modifier_inventory_item_example:GetHealingReceivedPercentBonus()
    return 0 -- finalHeal = heal * (1 + this)
end

function modifier_inventory_item_example:GetHealingCausedBonus()
    return 0 -- finalHeal = heal + this
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



-- Don't forget basic stuff too
LinkLuaModifier("modifier_inventory_item_example", "items/item_example", LUA_MODIFIER_MOTION_NONE)

--Stats that can set as multi "intended for boss debuff"
-- copy the additive one and add multi to the back
--for example
--function modifier_inventory_item_example:GetStrengthPercentBonusMulti()
--    return 2 --this will *2 overall strength (calculate after the % additive)
--end
--function modifier_inventory_item_example:GetSpellHastePercentBonusMulti()
--    return 0.2 --this will set spellhaste to 20%  (calculate after the % additive )
--end
--[[local unitBonusPercentStrMulti = 1
local unitBonusPercentAgiMulti = 1
local unitBonusPercentIntMulti = 1
local unitBonusPercentPrimaryMulti = 1
local unitBonusPercentAttackDamageMulti = 1
local unitBonusPercentAttackSpeedMulti = 1
local unitBonusSpellDamageMulti = 1
local unitBonusPercentSpellHasteMulti = 1
local unitBonusPercentAttackRangeMulti = 1
local unitBonusPercentCastRangeMulti = 1
local unitBonusPercentMoveSpeedMulti = 1
local unitBonusPercentHealthRegenerationMulti = 1
local unitBonusPercentManaRegenerationMulti = 1
local unitBonusPercentHealthMulti = 1
local unitBonusPercentManaMulti = 1
local unitArmorPercentMulti = 1
local unitHealingReceivedPercentMulti = 1
local unitHealingCausedPercentMulti = 1 --]]