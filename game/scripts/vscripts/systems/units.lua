if Units == nil then
    _G.Units = class({})
end

---@class UNIT_STATS_ELEMENTS_TABLE
---@field public fire number
---@field public frost number
---@field public earth number
---@field public void number
---@field public holy number
---@field public nature number
---@field public inferno number

---@class UNIT_STATS_TABLE
---@field public str number
---@field public agi number
---@field public int number
---@field public damageReduction number
---@field public spellDamage number
---@field public spellHaste number
---@field public armor number
---@field public block number
---@field public magicBlock number
---@field public movespeedBonus number
---@field public castRangeBonus number
---@field public attackRangeBonus number
---@field public attackSpeed number
---@field public hpRegen number
---@field public mpRegen number
---@field public bonusHealth number
---@field public bonusMana number
---@field public elementsProtection UNIT_STATS_ELEMENTS_TABLE
---@field public elementsDamage UNIT_STATS_ELEMENTS_TABLE

function Units:ForceStatsCalculation(unit)
    if (not unit or unit:IsNull() or not unit.stats) then
        return
    end
    unit.stats = Units:CalculateStats(unit, unit.stats)
    local modifier = unit:FindModifierByName("modifier_stats_system")
    modifier:OnIntervalThink()
end

---@param unit CDOTA_BaseNPC
---@param statsTable UNIT_STATS_TABLE
---@return UNIT_STATS_TABLE
function Units:CalculateStats(unit, statsTable, secondCalc)
    if (unit ~= nil and not unit:IsNull() and statsTable ~= nil and IsServer()) then
        local unitBonusStr = 0
        local unitBonusPercentStr = 1
        local unitBonusPercentStrMulti = 1
        local unitBonusAgi = 0
        local unitBonusPercentAgi = 1
        local unitBonusPercentAgiMulti = 1
        local unitBonusInt = 0
        local unitBonusPercentInt = 1
        local unitBonusPercentIntMulti = 1
        local unitBonusPrimary = 0
        local unitBonusPercentPrimary = 0
        local unitBonusPercentPrimaryMulti = 1
        local unitBonusAttackDamage = 0
        local unitBonusPercentAttackDamage = 1
        local unitBonusPercentAttackDamageMulti = 1
        local unitBonusAttackSpeed = 0
        local unitBonusPercentAttackSpeed = 1
        local unitBonusPercentAttackSpeedMulti = 1
        local unitBonusSpellDamage = 1 --fixed from 0 and remove the +1 in gamemechanics.lua. This make reducing that +1 possible for debuff that reduce damage output. Fixed tooltip by putting -1 before showing
        local unitBonusSpellDamageMulti = 1
        local unitBonusSpellHaste = 0 --this become flat
        local unitBonusPercentSpellHaste = 1 --this is total additive percent
        local unitBonusPercentSpellHasteMulti = 1
        local unitBonusAttackRange = 0
        local unitBonusPercentAttackRange = 1
        local unitBonusPercentAttackRangeMulti = 1
        local unitBonusCastRange = 0
        local unitBonusPercentCastRange = 1
        local unitBonusPercentCastRangeMulti = 1
        local unitBonusMoveSpeed = 0
        local unitBonusPercentMoveSpeed = 1
        local unitBonusPercentMoveSpeedMulti = 1
        local unitBonusHealthRegeneration = 0
        local unitBonusPercentHealthRegeneration = 1
        local unitBonusPercentHealthRegenerationMulti = 1
        local unitBonusManaRegeneration = 0
        local unitBonusPercentManaRegeneration = 1
        local unitBonusPercentManaRegenerationMulti = 1
        local unitBonusHealth = 0
        local unitBonusPercentHealth = 1
        local unitBonusPercentHealthMulti = 1
        local unitBonusMana = 0
        local unitBonusPercentMana = 1
        local unitBonusPercentManaMulti = 1
        local unitDamageReduction = 1
        local unitFireProtection = 1
        local unitFrostProtection = 1
        local unitEarthProtection = 1
        local unitVoidProtection = 1
        local unitHolyProtection = 1
        local unitNatureProtection = 1
        local unitInfernoProtection = 1
        local unitFireDamage = 1
        local unitFrostDamage = 1
        local unitEarthDamage = 1
        local unitVoidDamage = 1
        local unitHolyDamage = 1
        local unitNatureDamage = 1
        local unitInfernoDamage = 1
        local unitBlock = 0
        local unitBlockPercent = 1
        local unitMagicBlock = 0
        local unitMagicBlockPercent = 1
        local unitArmor = 0
        local unitArmorPercent = 1
        local unitArmorPercentMulti = 1
        local unitCooldownReduction = 1
        local unitHealingReceived = 0
        local unitHealingReceivedPercent = 1
        local unitHealingReceivedPercentMulti = 1
        local unitHealingCaused = 0
        local unitHealingCausedPercent = 1
        local unitHealingCausedPercentMulti = 1
        local unitBuffAmplification = 1
        local unitDebuffAmplification = 1
        local unitDebuffResistance = 1
        local unitCriticalChance = 1
        local unitCriticalDamage = 1
        local unitBaseAttackTime = unit:GetBaseAttackTime()
        local unitModifiers = unit:FindAllModifiers()
        table.sort(unitModifiers, function(a, b)
            return (a:GetCreationTime() > b:GetCreationTime())
        end)
        for i = 1, #unitModifiers do
            if (unitModifiers[i].GetStrengthBonus) then
                unitBonusStr = unitBonusStr + (tonumber(unitModifiers[i].GetStrengthBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetStrengthPercentBonus) then
                unitBonusPercentStr = unitBonusPercentStr + (tonumber(unitModifiers[i].GetStrengthPercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetStrengthPercentBonusMulti) then
                unitBonusPercentStrMulti = unitBonusPercentStrMulti * (tonumber(unitModifiers[i].GetStrengthPercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetAgilityBonus) then
                unitBonusAgi = unitBonusAgi + (tonumber(unitModifiers[i].GetAgilityBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetAgilityPercentBonus) then
                unitBonusPercentAgi = unitBonusPercentAgi + (tonumber(unitModifiers[i].GetAgilityPercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetAgilityPercentBonusMulti) then
                unitBonusPercentAgiMulti = unitBonusPercentAgiMulti * (tonumber(unitModifiers[i].GetAgilityPercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetIntellectBonus) then
                unitBonusInt = unitBonusInt + (tonumber(unitModifiers[i].GetIntellectBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetIntellectPercentBonus) then
                unitBonusPercentInt = unitBonusPercentInt + (tonumber(unitModifiers[i].GetIntellectPercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetIntellectPercentBonusMulti) then
                unitBonusPercentIntMulti = unitBonusPercentIntMulti * (tonumber(unitModifiers[i].GetIntellectPercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetPrimaryAttributeBonus) then
                unitBonusPrimary = unitBonusPrimary + (tonumber(unitModifiers[i].GetPrimaryAttributeBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetPrimaryAttributePercentBonus) then
                unitBonusPercentPrimary = unitBonusPercentPrimary + (tonumber(unitModifiers[i].GetPrimaryAttributePercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetPrimaryAttributePercentBonusMulti) then
                unitBonusPercentPrimaryMulti = unitBonusPercentPrimaryMulti * (tonumber(unitModifiers[i].GetPrimaryAttributePercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetAttackDamageBonus) then
                unitBonusAttackDamage = unitBonusAttackDamage + (tonumber(unitModifiers[i].GetAttackDamageBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetAttackDamagePercentBonus) then
                unitBonusPercentAttackDamage = unitBonusPercentAttackDamage + (tonumber(unitModifiers[i].GetAttackDamagePercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetAttackDamagePercentBonusMulti) then
                unitBonusPercentAttackDamageMulti = unitBonusPercentAttackDamageMulti * (tonumber(unitModifiers[i].GetAttackDamagePercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetAttackSpeedBonus) then
                unitBonusAttackSpeed = unitBonusAttackSpeed + (tonumber(unitModifiers[i].GetAttackSpeedBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetAttackSpeedPercentBonus) then
                unitBonusPercentAttackSpeed = unitBonusPercentAttackSpeed + (tonumber(unitModifiers[i].GetAttackSpeedPercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetAttackSpeedPercentBonusMulti) then
                unitBonusPercentAttackSpeedMulti = unitBonusPercentAttackSpeedMulti * (tonumber(unitModifiers[i].GetAttackSpeedPercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetSpellDamageBonus) then
                unitBonusSpellDamage = unitBonusSpellDamage + (tonumber(unitModifiers[i].GetSpellDamageBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetSpellDamageBonusMulti) then
                unitBonusSpellDamageMulti = unitBonusSpellDamageMulti * (tonumber(unitModifiers[i].GetSpellDamageBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetSpellHasteBonus) then
                unitBonusSpellHaste = unitBonusSpellHaste  + (tonumber(unitModifiers[i].GetSpellHasteBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetSpellHastePercentBonus) then
                unitBonusPercentSpellHaste = unitBonusPercentSpellHaste  + (tonumber(unitModifiers[i].GetSpellHastePercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetSpellHastePercentBonusMulti) then
                unitBonusPercentSpellHasteMulti = unitBonusPercentSpellHasteMulti  * (tonumber(unitModifiers[i].GetSpellHastePercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetAttackRangeBonus) then
                unitBonusAttackRange = unitBonusAttackRange + (tonumber(unitModifiers[i].GetAttackRangeBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetAttackRangePercentBonus) then
                unitBonusPercentAttackRange = unitBonusPercentAttackRange + (tonumber(unitModifiers[i].GetAttackRangePercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetAttackRangePercentBonusMulti) then
                unitBonusPercentAttackRangeMulti = unitBonusPercentAttackRangeMulti * (tonumber(unitModifiers[i].GetAttackRangePercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetCastRangeBonus) then
                unitBonusCastRange = unitBonusCastRange + (tonumber(unitModifiers[i].GetCastRangeBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetCastRangePercentBonus) then
                unitBonusPercentCastRange = unitBonusPercentCastRange + (tonumber(unitModifiers[i].GetCastRangePercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetCastRangePercentBonusMulti) then
                unitBonusPercentCastRangeMulti = unitBonusPercentCastRangeMulti * (tonumber(unitModifiers[i].GetCastRangePercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetMoveSpeedBonus) then
                unitBonusMoveSpeed = unitBonusMoveSpeed + (tonumber(unitModifiers[i].GetMoveSpeedBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetMoveSpeedPercentBonus) then
                unitBonusPercentMoveSpeed = unitBonusPercentMoveSpeed + (tonumber(unitModifiers[i].GetMoveSpeedPercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetMoveSpeedPercentBonusMulti) then
                unitBonusPercentMoveSpeedMulti = unitBonusPercentMoveSpeedMulti * (tonumber(unitModifiers[i].GetMoveSpeedPercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetHealthRegenerationBonus) then
                unitBonusHealthRegeneration = unitBonusHealthRegeneration + (tonumber(unitModifiers[i].GetHealthRegenerationBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetHealthRegenerationPercentBonus) then
                unitBonusPercentHealthRegeneration = unitBonusPercentHealthRegeneration + (tonumber(unitModifiers[i].GetHealthRegenerationPercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetHealthRegenerationPercentBonusMulti) then
                unitBonusPercentHealthRegenerationMulti = unitBonusPercentHealthRegenerationMulti * (tonumber(unitModifiers[i].GetHealthRegenerationPercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetManaRegenerationBonus) then
                unitBonusManaRegeneration = unitBonusManaRegeneration + (tonumber(unitModifiers[i].GetManaRegenerationBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetManaRegenerationPercentBonus) then
                unitBonusPercentManaRegeneration = unitBonusPercentManaRegeneration + (tonumber(unitModifiers[i].GetManaRegenerationPercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetManaRegenerationPercentBonusMulti) then
                unitBonusPercentManaRegenerationMulti = unitBonusPercentManaRegenerationMulti * (tonumber(unitModifiers[i].GetManaRegenerationPercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetHealthBonus) then
                unitBonusHealth = unitBonusHealth + (tonumber(unitModifiers[i].GetHealthBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetHealthPercentBonus) then
                unitBonusPercentHealth = unitBonusPercentHealth + (tonumber(unitModifiers[i].GetHealthPercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetHealthPercentBonusMulti) then
                unitBonusPercentHealthMulti = unitBonusPercentHealthMulti * (tonumber(unitModifiers[i].GetHealthPercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetManaBonus) then
                unitBonusMana = unitBonusMana + (tonumber(unitModifiers[i].GetManaBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetManaPercentBonus) then
                unitBonusPercentMana = unitBonusPercentMana + (tonumber(unitModifiers[i].GetManaPercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetManaPercentBonusMulti) then
                unitBonusPercentManaMulti = unitBonusPercentManaMulti * (tonumber(unitModifiers[i].GetManaPercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetDamageReductionBonus) then
                local damageReduction = tonumber(unitModifiers[i].GetDamageReductionBonus(unitModifiers[i])) or 0
                unitDamageReduction = unitDamageReduction * (1 - damageReduction)
            end
            if (unitModifiers[i].GetFireDamageBonus) then
                unitFireDamage = unitFireDamage + (tonumber(unitModifiers[i].GetFireDamageBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetFrostDamageBonus) then
                unitFrostDamage = unitFrostDamage + (tonumber(unitModifiers[i].GetFrostDamageBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetEarthDamageBonus) then
                unitEarthDamage = unitEarthDamage + (tonumber(unitModifiers[i].GetEarthDamageBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetVoidDamageBonus) then
                unitVoidDamage = unitVoidDamage + (tonumber(unitModifiers[i].GetVoidDamageBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetHolyDamageBonus) then
                unitHolyDamage = unitHolyDamage + (tonumber(unitModifiers[i].GetHolyDamageBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetNatureDamageBonus) then
                unitNatureDamage = unitNatureDamage + (tonumber(unitModifiers[i].GetNatureDamageBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetInfernoDamageBonus) then
                unitInfernoDamage = unitInfernoDamage + (tonumber(unitModifiers[i].GetInfernoDamageBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetFireProtectionBonus) then
                unitFireProtection = unitFireProtection * (1 - (tonumber(unitModifiers[i].GetFireProtectionBonus(unitModifiers[i])) or 0))
            end
            if (unitModifiers[i].GetFrostProtectionBonus) then
                unitFrostProtection = unitFrostProtection * (1 - (tonumber(unitModifiers[i].GetFrostProtectionBonus(unitModifiers[i])) or 0))
            end
            if (unitModifiers[i].GetEarthProtectionBonus) then
                unitEarthProtection = unitEarthProtection * (1 - (tonumber(unitModifiers[i].GetEarthProtectionBonus(unitModifiers[i])) or 0))
            end
            if (unitModifiers[i].GetVoidProtectionBonus) then
                unitVoidProtection = unitVoidProtection * (1 - (tonumber(unitModifiers[i].GetVoidProtectionBonus(unitModifiers[i])) or 0))
            end
            if (unitModifiers[i].GetHolyProtectionBonus) then
                unitHolyProtection = unitHolyProtection * (1 - (tonumber(unitModifiers[i].GetHolyProtectionBonus(unitModifiers[i])) or 0))
            end
            if (unitModifiers[i].GetNatureProtectionBonus) then
                unitNatureProtection = unitNatureProtection * (1 - (tonumber(unitModifiers[i].GetNatureProtectionBonus(unitModifiers[i])) or 0))
            end
            if (unitModifiers[i].GetInfernoProtectionBonus) then
                unitInfernoProtection = unitInfernoProtection * (1 - (tonumber(unitModifiers[i].GetInfernoProtectionBonus(unitModifiers[i])) or 0))
            end
            if (unitModifiers[i].GetBlockBonus) then
                unitBlock = unitBlock + (tonumber(unitModifiers[i].GetBlockBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetBlockPercentBonus) then
                unitBlockPercent = unitBlockPercent + (tonumber(unitModifiers[i].GetBlockPercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetMagicBlockBonus) then
                unitMagicBlock = unitMagicBlock + (tonumber(unitModifiers[i].GetMagicBlockBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetMagicBlockPercentBonus) then
                unitMagicBlockPercent = unitMagicBlockPercent + (tonumber(unitModifiers[i].GetMagicBlockPercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetArmorBonus) then
                unitArmor = unitArmor + (tonumber(unitModifiers[i].GetArmorBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetArmorPercentBonus) then
                unitArmorPercent = unitArmorPercent + (tonumber(unitModifiers[i].GetArmorPercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetArmorPercentBonusMulti) then
                unitArmorPercentMulti = unitArmorPercentMulti * (tonumber(unitModifiers[i].GetArmorPercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetCooldownReduction) then
                unitCooldownReduction = unitCooldownReduction * ( 1 - (tonumber(unitModifiers[i].GetCooldownReduction(unitModifiers[i])) or 0))
            end
            if (unitModifiers[i].GetBaseAttackTime) then
                local newBaseAttackTime = tonumber(unitModifiers[i].GetBaseAttackTime(unitModifiers[i]))
                if (newBaseAttackTime and newBaseAttackTime < unitBaseAttackTime) then
                    unitBaseAttackTime = newBaseAttackTime
                end
            end
            if (unitModifiers[i].GetHealingReceivedBonus) then
                unitHealingReceived = unitHealingReceived + (tonumber(unitModifiers[i].GetHealingReceivedBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetHealingReceivedPercentBonus) then
                unitHealingReceivedPercent = unitHealingReceivedPercent + (tonumber(unitModifiers[i].GetHealingReceivedPercentBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetHealingReceivedPercentBonusMulti) then
                unitHealingReceivedPercentMulti = unitHealingReceivedPercentMulti * (tonumber(unitModifiers[i].GetHealingReceivedPercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetHealingCausedBonus) then
                unitHealingCaused = unitHealingCaused + (tonumber(unitModifiers[i].GetHealingCausedBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetHealingCausedPercentBonusMulti) then
                unitHealingCausedPercentMulti = unitHealingCausedPercentMulti * (tonumber(unitModifiers[i].GetHealingCausedPercentBonusMulti(unitModifiers[i])) or 1)
            end
            if (unitModifiers[i].GetDebuffAmplificationBonus) then
                unitDebuffAmplification = unitDebuffAmplification + (tonumber(unitModifiers[i].GetDebuffAmplificationBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetDebuffResistanceBonus) then
                unitDebuffResistance = unitDebuffResistance * (1 - (tonumber(unitModifiers[i].GetDebuffResistanceBonus(unitModifiers[i])) or 0))
            end
            if (unitModifiers[i].GetBuffAmplificationBonus) then
                unitBuffAmplification = unitBuffAmplification + (tonumber(unitModifiers[i].GetBuffAmplificationBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetCriticalDamageBonus) then
                unitCriticalDamage = unitCriticalDamage + (tonumber(unitModifiers[i].GetCriticalDamageBonus(unitModifiers[i])) or 0)
            end
            if (unitModifiers[i].GetCriticalChanceBonus) then
                unitCriticalChance = unitCriticalChance + (tonumber(unitModifiers[i].GetCriticalChanceBonus(unitModifiers[i])) or 0)
            end
        end
        local primaryAttribute = 0
        -- str, agi, int
        if (unit:IsRealHero()) then
            local heroLevel = unit:GetLevel()
            local heroBaseStr = unit:GetBaseStrength() + (heroLevel - 1) * unit:GetStrengthGain()
            local heroBaseAgi = unit:GetBaseAgility() + (heroLevel - 1) * unit:GetAgilityGain()
            local heroBaseInt = unit:GetBaseIntellect() + (heroLevel - 1) * unit:GetIntellectGain()
            statsTable.str = heroBaseStr + unitBonusStr
            statsTable.agi = heroBaseAgi + unitBonusAgi
            statsTable.int = heroBaseInt + unitBonusInt
            local primaryAttributeIndex = unit:GetPrimaryAttribute()
            if (primaryAttributeIndex == 0) then
                statsTable.str = statsTable.str + unitBonusPrimary
                unitBonusPercentStr = (unitBonusPercentStr + unitBonusPercentPrimary)* unitBonusPercentStrMulti * unitBonusPercentPrimaryMulti
                unitBonusPercentAgi = (unitBonusPercentAgi)* unitBonusPercentAgiMulti
                unitBonusPercentInt = (unitBonusPercentInt)* unitBonusPercentIntMulti
                statsTable.str = math.floor(statsTable.str * unitBonusPercentStr )
                statsTable.agi = math.floor(statsTable.agi * unitBonusPercentAgi )
                statsTable.int = math.floor(statsTable.int * unitBonusPercentInt )
                primaryAttribute = statsTable.str
            end
            if (primaryAttributeIndex == 1) then
                statsTable.agi = statsTable.agi + unitBonusPrimary
                unitBonusPercentStr = (unitBonusPercentStr)* unitBonusPercentStrMulti
                unitBonusPercentAgi = (unitBonusPercentAgi + unitBonusPercentPrimary)* unitBonusPercentAgiMulti * unitBonusPercentPrimaryMulti
                unitBonusPercentInt = (unitBonusPercentInt)* unitBonusPercentIntMulti
                statsTable.str = math.floor(statsTable.str * unitBonusPercentStr )
                statsTable.agi = math.floor(statsTable.agi * unitBonusPercentAgi )
                statsTable.int = math.floor(statsTable.int * unitBonusPercentInt )
                primaryAttribute = statsTable.agi
            end
            if (primaryAttributeIndex == 2) then
                statsTable.int = statsTable.int + unitBonusPrimary
                unitBonusPercentStr = (unitBonusPercentStr)* unitBonusPercentStrMulti
                unitBonusPercentAgi = (unitBonusPercentAgi)* unitBonusPercentAgiMulti
                unitBonusPercentInt = (unitBonusPercentInt + unitBonusPercentPrimary)* unitBonusPercentIntMulti * unitBonusPercentPrimaryMulti
                statsTable.str = math.floor(statsTable.str * unitBonusPercentStr )
                statsTable.agi = math.floor(statsTable.agi * unitBonusPercentAgi )
                statsTable.int = math.floor(statsTable.int * unitBonusPercentInt )
                primaryAttribute = statsTable.int
            end
        --old one primary attribute to base damage calculation is wrong
        else
            statsTable.str = 0
            statsTable.agi = 0
            statsTable.int = 0
        end
        -- attack damage
        local heroBaseDamage = 0
        local attackDamagePerPrimary = 1
        local totalAttackDamage = (heroBaseDamage + (primaryAttribute * attackDamagePerPrimary) + unitBonusAttackDamage) * unitBonusPercentAttackDamage * unitBonusPercentAttackDamageMulti
        unit:SetBaseDamageMax(totalAttackDamage)
        unit:SetBaseDamageMin(totalAttackDamage)
        -- attack speed
        local attackSpeedPerAgi = 1
        local totalAttackSpeed = ((attackSpeedPerAgi * statsTable.agi) + unitBonusAttackSpeed) * unitBonusPercentAttackSpeed * unitBonusPercentAttackSpeedMulti
        statsTable.attackSpeed = math.floor(totalAttackSpeed)
        unit:SetModifierStackCount("modifier_stats_system_aaspeed", unit, statsTable.attackSpeed)
        -- spell damage
        statsTable.spellDamage = unitBonusSpellDamage * unitBonusSpellDamageMulti
        -- spell haste
        local totalSpellHaste = unitBonusSpellHaste * unitBonusPercentSpellHaste * unitBonusPercentSpellHasteMulti-- work like AS
        --compared to AS dota vanilla has 600 AS + 100 initial = 700 total AS cap
        --but in our custom game it is 800 (tested) so lets cap it at 800 too for easier balance and late game scaling this mean 2s cast time cap at 0.25 cast time (1.7 BAT need nerf too)
        --everything /100 to not break old code
        statsTable.spellHaste = math.min(8, totalSpellHaste)
        -- attack range
        local baseAttackRange = unit:GetBaseAttackRange()
        statsTable.attackRangeBonus = math.floor(((baseAttackRange + unitBonusAttackRange) * unitBonusPercentAttackRange * unitBonusPercentAttackRangeMulti) - baseAttackRange)
        unit:SetModifierStackCount("modifier_stats_system_aarange", unit, statsTable.attackRangeBonus)
        -- cast range
        statsTable.castRangeBonus = math.floor(unitBonusCastRange * unitBonusPercentCastRange * unitBonusPercentCastRangeMulti)
        unit:SetModifierStackCount("modifier_stats_system_castrange", unit, statsTable.castRangeBonus)
        -- move speed
        local baseMoveSpeed = unit:GetBaseMoveSpeed()
        statsTable.movespeedBonus = math.floor(((baseMoveSpeed + unitBonusMoveSpeed) * unitBonusPercentMoveSpeed * unitBonusPercentMoveSpeedMulti) - baseMoveSpeed)
        unit:SetModifierStackCount("modifier_stats_system_movespeed", unit, statsTable.movespeedBonus)
        -- hp regen
        local healthRegenPerStr = 0.1
        local baseHpRegen = (statsTable.str * healthRegenPerStr)
        statsTable.hpRegen = (baseHpRegen + unitBonusHealthRegeneration) * unitBonusPercentHealthRegeneration  * unitBonusPercentHealthRegenerationMulti
        -- mana regen
        local manaRegenPerInt = 0.05
        local baseMpRegen = (statsTable.int * manaRegenPerInt)
        statsTable.mpRegen = (baseMpRegen + unitBonusManaRegeneration) * unitBonusPercentManaRegeneration * unitBonusPercentManaRegenerationMulti
        -- max hp
        local healthPerStr = 20
        local baseHealthBonus = (statsTable.str * healthPerStr)
        statsTable.bonusHealth = math.floor((baseHealthBonus + unitBonusHealth) * unitBonusPercentHealth * unitBonusPercentHealthMulti)
        statsTable.bonusHealth = statsTable.bonusHealth
        -- max mp
        local manaPerInt = 12
        local baseManaBonus = (manaPerInt * statsTable.int)
        statsTable.bonusMana = math.floor((baseManaBonus + unitBonusMana) * unitBonusPercentMana * unitBonusPercentManaMulti)
        if (not unit:IsRealHero()) then
            unit:AddNewModifier(self.unit, nil, "modifier_stats_system_enemies_maxhp", { Duration = -1 })
            unit:AddNewModifier(self.unit, nil, "modifier_stats_system_enemies_maxmp", { Duration = -1 })
        end
        -- damage reduction
        statsTable.damageReduction = unitDamageReduction
        -- both blocks
        statsTable.block = unitBlock * unitBlockPercent
        statsTable.magicBlock = unitMagicBlock * unitMagicBlockPercent
        -- armor
        statsTable.armor = unitArmor * unitArmorPercent * unitArmorPercentMulti
        -- cdr
        statsTable.cdr = unitCooldownReduction
        -- bat
        statsTable.bat = unitBaseAttackTime
        unit:SetBaseAttackTime(unitBaseAttackTime)
        -- healing related bonuses
        statsTable.healingReceived = unitHealingReceived
        statsTable.healingReceivedPercent = unitHealingReceivedPercent * unitHealingReceivedPercentMulti
        statsTable.healingCaused = unitHealingCaused
        statsTable.healingCausedPercent = unitHealingCausedPercent * unitHealingCausedPercentMulti
        -- modifier related bonuses
        statsTable.buffAmplification = unitBuffAmplification
        statsTable.debuffAmplification = unitDebuffAmplification
        statsTable.debuffResistance = unitDebuffResistance
        -- crit related bonuses
        statsTable.critChance = unitCriticalChance
        statsTable.critDamage = unitCriticalDamage
        -- all elements protections
        statsTable.elementsProtection = statsTable.elementsProtection or {}
        statsTable.elementsProtection.fire = unitFireProtection
        statsTable.elementsProtection.frost = unitFrostProtection
        statsTable.elementsProtection.earth = unitEarthProtection
        statsTable.elementsProtection.void = unitVoidProtection
        statsTable.elementsProtection.holy = unitHolyProtection
        statsTable.elementsProtection.nature = unitNatureProtection
        statsTable.elementsProtection.inferno = unitInfernoProtection
        -- all elements damage
        statsTable.elementsDamage = statsTable.elementsDamage or {}
        statsTable.elementsDamage.fire = unitFireDamage
        statsTable.elementsDamage.frost = unitFrostDamage
        statsTable.elementsDamage.earth = unitEarthDamage
        statsTable.elementsDamage.void = unitVoidDamage
        statsTable.elementsDamage.holy = unitHolyDamage
        statsTable.elementsDamage.nature = unitNatureDamage
        statsTable.elementsDamage.inferno = unitInfernoDamage
        -- fix for panaroma float values
        statsTable.display = {}
        statsTable.display.mana = unit:GetMana()
        statsTable.display.maxmana = unit:GetMaxMana()
        if (unit.CalculateStatBonus) then
            unit:CalculateStatBonus()
        end
        if(secondCalc == false or not secondCalc) then
            statsTable = Units:CalculateStats(unit, statsTable, true)
        end
    end
    return statsTable
end

function Units:OnCreation(unit)
    if (unit == nil or Summons:IsSummmon(unit) or unit:GetUnitName() == "npc_dota_thinker") then
        return
    end
    unit:AddNewModifier(unit, nil, "modifier_stats_system", { Duration = -1 })
    if (not unit:IsRealHero()) then
        Aggro:OnCreepSpawn(unit)
    end
end

modifier_stats_system = class({
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
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_stats_system:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_MODIFIER_ADDED
    }
    return funcs
end

function modifier_stats_system:OnModifierAdded(keys)
    if (not IsServer()) then
        return
    end
    if (keys.unit == self.unit) then
        for _, name in pairs(GameMode.AuraModifiersTable) do
            local auraModifier = self.unit:FindModifierByName(name)
            if (auraModifier and not auraModifier.IsMarkedByGameMechanics) then
                GameMode:OverwriteModifierFunctions(auraModifier)
                Units:ForceStatsCalculation(self.unit)
                auraModifier.IsMarkedByGameMechanics = true
            end
        end
    end
end

function modifier_stats_system:GetModifierConstantManaRegen()
    return Units:GetManaRegeneration(self.unit)
end

function modifier_stats_system:GetModifierConstantHealthRegen()
    return Units:GetHealthRegeneration(self.unit)
end

function modifier_stats_system:GetModifierBonusStats_Strength()
    return -Units:GetHeroStrength(self.unit) or 0
end

function modifier_stats_system:GetModifierBonusStats_Agility()
    return -Units:GetHeroAgility(self.unit) or 0
end

function modifier_stats_system:GetModifierBonusStats_Intellect()
    return -Units:GetHeroIntellect(self.unit) or 0
end

function modifier_stats_system:GetModifierBonusStats_Intellect()
    return -Units:GetHeroIntellect(self.unit) or 0
end

function modifier_stats_system:GetModifierAttackSpeedBonus_Constant()
    return -100
end

function modifier_stats_system:GetAttackSpeedBonus()
    return 100
end

function modifier_stats_system:GetSpellHasteBonus()
    return 1 --this is actually 100 but to prevent fixing everything hero / boss code removing *0.01 from old spellhaste we go with this everything /100
end

function modifier_stats_system:OnAttackLanded(event)
    if IsServer() then
        local attacker = event.attacker
        local target = event.target
        if (attacker ~= nil and target ~= nil and attacker ~= target and attacker == self.unit) then
            if (attacker:IsRealHero()) then
                modifier_summon:OnSummonMasterAttackLanded(event)
            end
            -- deal aa dmg via modifier
            ---@type DAMAGE_TABLE
            local damageTable = {}
            damageTable.damage = event.damage
            damageTable.caster = attacker
            damageTable.target = target
            damageTable.physdmg = true
            damageTable.ability = nil
            GameMode:DamageUnit(damageTable)
        end
    end
end

function modifier_stats_system:OnCreated(event)
    if IsServer() then
        self.unit = self:GetParent()
        self.unit.stats = {
            str = 0,
            agi = 0,
            int = 0,
            damageReduction = 0,
            spellDamage = 0,
            spellHaste = 0,
            armor = 0,
            block = 0,
            magicBlock = 0,
            elementsProtection = {
                fire = 0,
                frost = 0,
                earth = 0,
                void = 0,
                holy = 0,
                nature = 0,
                inferno = 0
            },
            elementsDamage = {
                fire = 0,
                frost = 0,
                earth = 0,
                void = 0,
                holy = 0,
                nature = 0,
                inferno = 0
            }
        }
        self.unit:AddNewModifier(self.unit, nil, "modifier_stats_system_aaspeed", { Duration = -1 })
        self.unit:AddNewModifier(self.unit, nil, "modifier_stats_system_aarange", { Duration = -1 })
        self.unit:AddNewModifier(self.unit, nil, "modifier_stats_system_castrange", { Duration = -1 })
        self.unit:AddNewModifier(self.unit, nil, "modifier_stats_system_movespeed", { Duration = -1 })
        if (self.unit:IsRealHero()) then
            self.unit:AddNewModifier(self.unit, nil, "modifier_stats_system_maxhp", { Duration = -1 })
            self.unit:AddNewModifier(self.unit, nil, "modifier_stats_system_maxmp", { Duration = -1 })
        end
        Units:ForceStatsCalculation(self.unit)
        self:StartIntervalThink(1)
    end
end

function modifier_stats_system:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    if (self.unit:IsRealHero()) then
        local playerID = self.unit:GetPlayerID()
        -- send data to clients
        local dataTable = {
            player_id = playerID,
            statsTable = self.unit.stats
        }
        CustomGameEventManager:Send_ServerToAllClients("rpg_update_hero_stats", { data = json.encode(dataTable) })
    end
end

modifier_stats_system_aaspeed = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
    end,
    GetModifierAttackSpeedBonus_Constant = function(self)
        return self:GetStackCount()
    end
})

modifier_stats_system_aarange = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_ATTACK_RANGE_BONUS }
    end,
    GetModifierAttackRangeBonus = function(self)
        return self:GetStackCount()
    end
})

modifier_stats_system_castrange = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_CAST_RANGE_BONUS }
    end,
    GetModifierCastRangeBonus = function(self)
        return self:GetStackCount()
    end
})

modifier_stats_system_movespeed = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
    end,
    GetModifierMoveSpeedBonus_Constant = function(self)
        return self:GetStackCount()
    end
})

modifier_stats_system_maxhp = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_HEALTH_BONUS }
    end,
    OnCreated = function(self)
        if (not IsServer()) then
            return
        end
        self.unit = self:GetParent()
    end,
    GetModifierHealthBonus = function(self)
        return self.unit.stats.bonusHealth
    end
})

modifier_stats_system_maxmp = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_MANA_BONUS }
    end,
    OnCreated = function(self)
        if (not IsServer()) then
            return
        end
        self.unit = self:GetParent()
    end,
    GetModifierManaBonus = function(self)
        return self.unit.stats.bonusMana
    end
})

modifier_stats_system_enemies_maxhp = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS }
    end,
    OnCreated = function(self)
        if (not IsServer()) then
            return
        end
        self.unit = self:GetParent()
    end,
    GetModifierExtraHealthBonus = function(self)
        return self.unit.stats.bonusHealth
    end
})

modifier_stats_system_enemies_maxmp = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_EXTRA_MANA_BONUS }
    end,
    OnCreated = function(self)
        if (not IsServer()) then
            return
        end
        self.unit = self:GetParent()
    end,
    GetModifierExtraManaBonus = function(self)
        return self.unit.stats.bonusMana
    end
})

---@param hero CDOTA_BaseNPC_Hero
---@return number
function Units:GetHeroStrength(hero)
    if (hero ~= nil and hero.stats ~= nil) then
        return hero.stats.str or 0
    end
    return 0
end

---@param hero CDOTA_BaseNPC_Hero
---@return number
function Units:GetHeroAgility(hero)
    if (hero ~= nil and hero.stats ~= nil) then
        return hero.stats.agi or 0
    end
    return 0
end

---@param hero CDOTA_BaseNPC_Hero
---@return number
function Units:GetHeroIntellect(hero)
    if (hero ~= nil and hero.stats ~= nil) then
        return hero.stats.int or 0
    end
    return 0
end

---@param hero CDOTA_BaseNPC_Hero
---@return number
function Units:GetHeroPrimaryAttribute(hero)
    if (hero ~= nil and hero.stats ~= nil) then
        local primaryAttributeIndex = hero:GetPrimaryAttribute()
        local primaryAttribute = 0
        if (primaryAttributeIndex == 0) then
            primaryAttribute = hero.stats.str
        end
        if (primaryAttributeIndex == 1) then
            primaryAttribute = hero.stats.agi
        end
        if (primaryAttributeIndex == 2) then
            primaryAttribute = hero.stats.int
        end
        return primaryAttribute
    end
    return 0
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetAttackSpeed(unit)
    if (unit == nil) then
        return
    end
    if (unit.stats ~= nil) then
        return unit.stats.attackSpeed or 0
    end
    return 0
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetSpellDamage(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.spellDamage or 0
    end
    return 0
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetSpellHaste(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.spellHaste  -- this is equal to statsTable.spellHaste for hero
    end
    return 1 --for creep
end

---@param unit CDOTA_BaseNPC
---@param includeBonus boolean
---@return number
function Units:GetAttackRange(unit, includeBonus)
    if (unit ~= nil and unit:IsRealHero() and unit.stats ~= nil) then
        local totalAttackRange = unit:Script_GetAttackRange()
        if (not includeBonus) then
            local bonusAttackRange = unit.stats.attackRangeBonus or 0
            totalAttackRange = totalAttackRange - bonusAttackRange
        end
        return totalAttackRange
    end
    return 0
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetAttackDamage(unit)
    if (unit ~= nil) then
        return unit:GetBaseDamageMax()
    end
    return 0
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetMoveSpeed(unit)
    if (unit ~= nil) then
        return unit:GetMoveSpeedModifier(unit:GetBaseMoveSpeed(), false)
    end
    return 0
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetManaRegeneration(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.mpRegen or 0
    end
    return 0
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetArmor(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.armor or 0
    end
    return 0
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetHealthRegeneration(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.hpRegen or 0
    end
    return 0
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetBlock(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.block or 0
    end
    return 0
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetMagicBlock(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.magicBlock or 0
    end
    return 0
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetDamageReduction(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.damageReduction or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetFireDamage(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsDamage.fire or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetFrostDamage(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsDamage.frost or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetEarthDamage(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsDamage.earth or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetVoidDamage(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsDamage.void or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetHolyDamage(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsDamage.holy or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetNatureDamage(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsDamage.nature or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetInfernoDamage(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsDamage.inferno or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetFireProtection(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsProtection.fire or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetFrostProtection(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsProtection.frost or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetEarthProtection(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsProtection.earth or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetVoidProtection(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsProtection.void or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetHolyProtection(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsProtection.holy or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetNatureProtection(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsProtection.nature or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetInfernoProtection(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.elementsProtection.inferno or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetCooldownReduction(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.cdr or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetHealingReceived(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.healingReceived or 0
    end
    return 0
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetHealingReceivedPercent(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.healingReceivedPercent or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetHealingCaused(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.healingCaused or 0
    end
    return 0
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetHealingCausedPercent(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.healingCausedPercent or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetBuffAmplification(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.buffAmplification or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetDebuffAmplification(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.debuffAmplification or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetDebuffResistance(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.debuffResistance or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetCriticalChanceMultiplier(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.critChance or 1
    end
    return 1
end

---@param unit CDOTA_BaseNPC
---@return number
function Units:GetCriticalDamage(unit)
    if (unit ~= nil and unit.stats ~= nil) then
        return unit.stats.critDamage or 1
    end
    return 1
end

LinkLuaModifier("modifier_stats_system", "systems/units", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stats_system_aaspeed", "systems/units", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stats_system_aarange", "systems/units", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stats_system_castrange", "systems/units", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stats_system_movespeed", "systems/units", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stats_system_maxhp", "systems/units", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stats_system_maxmp", "systems/units", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stats_system_enemies_maxhp", "systems/units", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stats_system_enemies_maxmp", "systems/units", LUA_MODIFIER_MOTION_NONE)