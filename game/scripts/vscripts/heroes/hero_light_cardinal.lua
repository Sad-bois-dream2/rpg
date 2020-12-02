local LinkedModifiers = {}

-- light_cardinal_piety
modifier_light_cardinal_piety_hot = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
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
    GetEffectName = function(self)
        return "particles/units/light_cardinal/piety/light_sphere_buff.vpcf"
    end
})

function modifier_light_cardinal_piety_hot:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self:OnIntervalThink()
    self:StartIntervalThink(self.ability.hotTick)
end

function modifier_light_cardinal_piety_hot:OnIntervalThink()
    if not IsServer() then
        return
    end
    local healTable = {}
    healTable.caster = self.caster
    healTable.target = self.target
    healTable.ability = self.ability
    healTable.heal = self.ability.hotHealing * Units:GetHeroIntellect(self.caster) + self.ability.hotHealingMissingHp * (self.caster:GetMaxHealth() - self.caster:GetHealth())
    GameMode:HealUnit(healTable)
end

LinkedModifiers["modifier_light_cardinal_piety_hot"] = LUA_MODIFIER_MOTION_NONE

modifier_light_cardinal_piety_stacks = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
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
    DeclareFunctions = function(self)
        return {
            MODIFIER_PROPERTY_TOOLTIP
        }
    end
})

function modifier_light_cardinal_piety_stacks:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_light_cardinal_piety_stacks:GetStatusAmplificationBonus()
    return self.ability.buffsDurationPerStack * self:GetStackCount()
end

function modifier_light_cardinal_piety_stacks:OnTooltip()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("buffs_duration_per_stack")
end

LinkedModifiers["modifier_light_cardinal_piety_stacks"] = LUA_MODIFIER_MOTION_NONE

modifier_light_cardinal_piety = class({
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
    end
})

function modifier_light_cardinal_piety:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.totalModifiersCount = 0
    self:StartIntervalThink(0.5)
end

function modifier_light_cardinal_piety:OnIntervalThink()
    if not IsServer() then
        return
    end
    local removeTable = {}
    self.totalModifiersCount = 0
    for allyIndex, ally in pairs(self.ability.buffsTable) do
        local modifiersOnTargetCount = 0
        local modifiersOnTarget = ally:FindAllModifiers()
        for _, modifier in pairs(modifiersOnTarget) do
            if (modifier.IsDebuff and modifier:IsDebuff() == false and modifier.IsHidden and modifier:IsHidden() == false and modifier:GetCaster() == self.caster) then
                modifiersOnTargetCount = modifiersOnTargetCount + 1
            end
        end
        if (modifiersOnTargetCount == 0) then
            table.insert(removeTable, allyIndex)
        end
        self.totalModifiersCount = self.totalModifiersCount + modifiersOnTargetCount
    end
    for _, index in pairs(removeTable) do
        self.ability.buffsTable[index] = nil
    end
    self:SetStackCount(1)
end

function modifier_light_cardinal_piety:GetHealingCausedPercentBonus()
    return math.min(self.totalModifiersCount * (self.ability.healingCausedPerBuff or 0), (self.ability.maxHealingCausedFromBuffs or 0))
end

function modifier_light_cardinal_piety:OnPostModifierApplied(modifierTable)
    local ability = modifierTable.caster:FindAbilityByName("light_cardinal_piety")
    if (not ability) then
        return modifierTable
    end
    if (self.IsHidden and self:IsHidden() == true) then
        return modifierTable
    end
    if (self.IsDebuff and self:IsDebuff() == true) then
        return modifierTable
    end
    if (ability.healingCausedPerBuff and ability.healingCausedPerBuff > 0 and ability.buffsTable) then
        if (not TableContains(ability.buffsTable, modifierTable.target)) then
            table.insert(ability.buffsTable, modifierTable.target)
        end
    end
end

LinkedModifiers["modifier_light_cardinal_piety"] = LUA_MODIFIER_MOTION_NONE

light_cardinal_piety = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_piety"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_light_cardinal_piety"
    end
})

function light_cardinal_piety:OnUpgrade()
    if not IsServer() then
        return
    end
    self.hotHealing = self:GetSpecialValueFor("hot_healing") / 100
    self.hotHealingMissingHp = self:GetSpecialValueFor("hot_missing_health_healing") / 100
    self.hotDuration = self:GetSpecialValueFor("hot_duration")
    self.hotTick = self:GetSpecialValueFor("hot_tick")
    self.radius = self:GetSpecialValueFor("radius")
    self.healing = self:GetSpecialValueFor("healing") / 100
    self.healingMissingHp = self:GetSpecialValueFor("healing_missing_hp") / 100
    self.buffsDurationPerStack = self:GetSpecialValueFor("buffs_duration_per_stack") / 100
    self.stacksDuration = self:GetSpecialValueFor("stacks_duration")
    self.maxStacks = self:GetSpecialValueFor("max_stacks")
    self.healingCausedPerBuff = self:GetSpecialValueFor("healing_caused_per_buff") / 100
    self.maxHealingCausedFromBuffs = self:GetSpecialValueFor("max_healing_caused_from_buffs") / 100
    if (not self.buffsTable) then
        self.buffsTable = {}
    end
end

function light_cardinal_piety:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local allies = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local instaHealing = self.healing * Units:GetHeroIntellect(caster) + self.healingMissingHp * (caster:GetMaxHealth() - caster:GetHealth())
    for _, ally in pairs(allies) do
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = ally
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_light_cardinal_piety_hot"
        modifierTable.duration = self.hotDuration
        GameMode:ApplyBuff(modifierTable)
        if (self.healing > 0) then
            local healTable = {}
            healTable.caster = caster
            healTable.target = ally
            healTable.ability = self
            healTable.heal = instaHealing
            GameMode:HealUnit(healTable)
        end
    end
    if (self.buffsDurationPerStack > 0) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.caster = caster
        modifierTable.target = caster
        modifierTable.modifier_name = "modifier_light_cardinal_piety_stacks"
        modifierTable.duration = self.stacksDuration
        modifierTable.stacks = #allies
        modifierTable.max_stacks = self.maxStacks
        GameMode:ApplyStackingBuff(modifierTable)
    end
    local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/piety/light_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    Timers:CreateTimer(3.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    EmitSoundOn("Hero_Omniknight.Purification", caster)
end

-- light_cardinal_purification modifiers
modifier_light_cardinal_purification = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
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
    GetEffectName = function(self)
        return "particles/items_fx/black_king_bar_avatar.vpcf"
    end
})

function modifier_light_cardinal_purification:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.target = self:GetParent()
    self.caster = self:GetCaster()
    self.tick = 0.1
    self.currentTime = 0
    self:OnIntervalThink()
    self:StartIntervalThink(self.tick)
end

function modifier_light_cardinal_purification:OnDestroy()
    if not IsServer() then
        return
    end
    if (not self.endHealingTriggered) then
        local healTable = {}
        healTable.caster = self.caster
        healTable.target = self.target
        healTable.ability = self.ability
        healTable.heal = self.ability.intToEndHealing * Units:GetHeroIntellect(self.caster) + self.ability.missingHpToEndHealing * (self.caster:GetMaxHealth() - self.caster:GetHealth())
        GameMode:HealUnit(healTable)
    end
    self.caster:StopSound("Hero_Omniknight.Repel")
end

function modifier_light_cardinal_purification:OnIntervalThink()
    if not IsServer() then
        return
    end
    if (self.ability.maxHealthToHot > 0) then
        self.currentTime = self.currentTime + self.tick
        if (self.currentTime > self.ability.hotTick) then
            local healTable = {}
            healTable.caster = self.caster
            healTable.target = self.target
            healTable.ability = self.ability
            healTable.heal = self.ability.maxHealthToHot * (self.caster:GetMaxHealth() - self.caster:GetHealth())
            GameMode:HealUnit(healTable)
            self.currentTime = 0
        end
    end
    if (self.ability.allyMaxHpToEndHealingProc > 0 and (self.target:GetMaxHealth() / self.target:GetHealth()) <= self.ability.allyMaxHpToEndHealingProc) then
        local healTable = {}
        healTable.caster = self.caster
        healTable.target = self.target
        healTable.ability = self.ability
        healTable.heal = self.ability.intToEndHealing * Units:GetHeroIntellect(self.caster) + self.ability.missingHpToEndHealing * (self.caster:GetMaxHealth() - self.caster:GetHealth())
        GameMode:HealUnit(healTable)
        self.endHealingTriggered = true
    end
    self.target:Purge(false, true, false, true, true)
end

function modifier_light_cardinal_purification:GetFireProtectionBonus()
    return self.ability.eleArmor
end

function modifier_light_cardinal_purification:GetFrostProtectionBonus()
    return self.ability.eleArmor
end

function modifier_light_cardinal_purification:GetEarthProtectionBonus()
    return self.ability.eleArmor
end

function modifier_light_cardinal_purification:GetVoidProtectionBonus()
    return self.ability.eleArmor
end

function modifier_light_cardinal_purification:GetHolyProtectionBonus()
    return self.ability.eleArmor
end

function modifier_light_cardinal_purification:GetNatureProtectionBonus()
    return self.ability.eleArmor
end

function modifier_light_cardinal_purification:GetInfernoProtectionBonus()
    return self.ability.eleArmor
end

LinkedModifiers["modifier_light_cardinal_purification"] = LUA_MODIFIER_MOTION_NONE

-- light_cardinal_purification
light_cardinal_purification = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_purification"
    end
})

function light_cardinal_purification:OnUpgrade()
    if not IsServer() then
        return
    end
    self.duration = self:GetSpecialValueFor("duration")
    self.eleArmor = self:GetSpecialValueFor("elearmor") / 100
    self.maxHealthToHot = self:GetSpecialValueFor("max_health_to_hot") / 100
    self.hotTick = self:GetSpecialValueFor("hot_tick")
    self.intToEndHealing = self:GetSpecialValueFor("int_to_end_healing") / 100
    self.missingHpToEndHealing = self:GetSpecialValueFor("missing_hp_to_end_healing") / 100
    self.allyMaxHpToEndHealingProc = self:GetSpecialValueFor("ally_max_hp_to_end_healing_proc") / 100
end

function light_cardinal_purification:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = self:GetCursorTarget()
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_light_cardinal_purification"
    modifierTable.duration = self.duration
    GameMode:ApplyBuff(modifierTable)
    caster:EmitSound("Hero_Omniknight.Repel")
end

-- light_cardinal_sublimation
modifier_light_cardinal_sublimation = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetEffectName = function(self)
        return "particles/units/light_cardinal/sublimation/sublimation_buff.vpcf"
    end
})

function modifier_light_cardinal_sublimation:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    if (self.ability.intToHealing > 0) then
        local healTable = {}
        healTable.caster = self.caster
        healTable.target = self.target
        healTable.ability = self.ability
        healTable.heal = self.ability.intToHealing * Units:GetHeroIntellect(self.caster) + self.ability.missingHealthToHealing * (self.caster:GetMaxHealth() - self.caster:GetHealth())
        GameMode:HealUnit(healTable)
    end
end

function modifier_light_cardinal_sublimation:GetDamageReductionBonus()
    return self.ability.dmgReduction
end

function modifier_light_cardinal_sublimation:GetPrimaryAttributeBonus()
    return self.ability.intToPrimaryBonus * Units:GetHeroIntellect(self.caster)
end

function modifier_light_cardinal_sublimation:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_light_cardinal_sublimation")
    if (not (modifier and damageTable.damage > 0)) then
        return damageTable
    end
    if (modifier.caster and modifier.ability and modifier.ability.damageTransfer and modifier.caster:IsAlive()) then
        local block = damageTable.damage * modifier.ability.damageTransfer
        local casterHealth = modifier.caster:GetHealth()
        if (casterHealth > 1) then
            local healthReduce = 0
            if (block < casterHealth) then
                healthReduce = block
                damageTable.damage = damageTable.damage - block
            else
                return damageTable
            end
            local finalHealth = casterHealth - healthReduce
            if (finalHealth < 1) then
                finalHealth = 1
            end
            local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/sublimation/sublimation_chain.vpcf", PATTACH_ROOTBONE_FOLLOW, damageTable.victim)
            ParticleManager:SetParticleControlEnt(pidx, 0, damageTable.victim, PATTACH_POINT_FOLLOW, "attach_hitloc", damageTable.victim:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(pidx, 1, modifier.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", modifier.caster:GetAbsOrigin(), true)
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
            modifier.caster:SetHealth(finalHealth)
            return damageTable
        end
    end
end

LinkedModifiers["modifier_light_cardinal_sublimation"] = LUA_MODIFIER_MOTION_NONE

light_cardinal_sublimation = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_sublimation"
    end
})

function light_cardinal_sublimation:OnUpgrade()
    if not IsServer() then
        return
    end
    self.dmgReduction = self:GetSpecialValueFor("dmg_reduction") / 100
    self.duration = self:GetSpecialValueFor("duration")
    self.intToHealing = self:GetSpecialValueFor("int_to_healing") / 100
    self.missingHealthToHealing = self:GetSpecialValueFor("missing_health_to_healing") / 100
    self.damageTransfer = self:GetSpecialValueFor("damage_transfer") / 100
    self.intToPrimaryBonus = self:GetSpecialValueFor("int_to_primary_bonus") / 100
end

function light_cardinal_sublimation:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = self:GetCursorTarget()
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_light_cardinal_sublimation"
    modifierTable.duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyBuff(modifierTable)
    caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast")
end

-- light_cardinal_salvation
modifier_light_cardinal_salvation_aura = class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.ability.salvationAuraRadius
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_light_cardinal_salvation_aura_buff"
    end,
    GetAuraDuration = function(self)
        return 0
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetEffectName = function(self)
        return "particles/units/light_cardinal/salvation/salvation_aura.vpcf"
    end
})

function modifier_light_cardinal_salvation_aura:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

LinkedModifiers["modifier_light_cardinal_salvation_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_light_cardinal_salvation_aura_buff = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end
})

function modifier_light_cardinal_salvation_aura_buff:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_light_cardinal_salvation_aura_buff")
    if (not (damageTable.damage > 0 and modifier)) then
        return damageTable
    end
    local cooldown = damageTable.victim:HasModifier("modifier_light_cardinal_salvation_aura_cd")
    if (cooldown) then
        return damageTable
    end
    local healthAfterDamage = damageTable.victim:GetHealth() - damageTable.damage
    if (healthAfterDamage < 1) then
        local auraAbility = modifier:GetAbility()
        damageTable.victim:AddNewModifier(damageTable.victim, auraAbility, "modifier_light_cardinal_salvation_aura_cd", { duration = auraAbility.salvationAuraCd })
        damageTable.victim:Purge(false, true, false, true, true)
        local healTable = {}
        healTable.caster = auraAbility:GetCaster()
        healTable.target = damageTable.victim
        healTable.ability = auraAbility
        healTable.heal = auraAbility.salvationAuraIntHealing * Units:GetHeroIntellect(healTable.caster) + auraAbility.salvationAuraMissingHpHealing * (healTable.caster:GetMaxHealth() - healTable.caster:GetHealth())
        GameMode:HealUnit(healTable)
        local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/salvation/salvation_aura_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, damageTable.victim)
        Timers:CreateTimer(2, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
        damageTable.victim:EmitSound("Item.GuardianGreaves.Activate")
        damageTable.damage = 0
        return damageTable
    end
end

LinkedModifiers["modifier_light_cardinal_salvation_aura_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_light_cardinal_salvation_aura_cd = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end
})

LinkedModifiers["modifier_light_cardinal_salvation_aura_cd"] = LUA_MODIFIER_MOTION_NONE

modifier_light_cardinal_salvation_buff = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end
})

function modifier_light_cardinal_salvation_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_light_cardinal_salvation_buff:GetHealingReceivedPercentBonus()
    return self.ability.bonusHealingReceived
end

LinkedModifiers["modifier_light_cardinal_salvation_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_light_cardinal_salvation = class({
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
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end
})

function modifier_light_cardinal_salvation:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.abilityName = self.ability:GetAbilityName()
    self.caster = self.ability:GetCaster()
end

function modifier_light_cardinal_salvation:OnAbilityFullyCast(kv)
    if (not IsServer()) then
        return
    end
    local abilityLevel = kv.ability:GetLevel()
    local abilityCooldown = kv.ability:GetCooldown(abilityLevel)
    if (abilityCooldown < self.ability.cdrMinCdForProc or kv.unit ~= self.caster) then
        return
    end
    local cooldownTable = {}
    cooldownTable.reduction = self.ability.cdrOnProc
    cooldownTable.ability = self.abilityName
    cooldownTable.isflat = true
    cooldownTable.target = self.caster
    GameMode:ReduceAbilityCooldown(cooldownTable)
end

LinkedModifiers["modifier_light_cardinal_salvation"] = LUA_MODIFIER_MOTION_NONE

light_cardinal_salvation = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_salvation"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_light_cardinal_salvation"
    end
})

function light_cardinal_salvation:OnUpgrade()
    if not IsServer() then
        return
    end
    self.healing = self:GetSpecialValueFor("healing") / 100
    self.healingMissingHealth = self:GetSpecialValueFor("healing_missing_health") / 100
    self.healthCost = self:GetSpecialValueFor("health_cost") / 100
    self.radius = self:GetSpecialValueFor("radius")
    self.silenceDuration = self:GetSpecialValueFor("silence_duration")
    self.salvationAuraIntHealing = self:GetSpecialValueFor("salvation_aura_int_healing") / 100
    self.salvationAuraMissingHpHealing = self:GetSpecialValueFor("salvation_aura_missing_hp_healing") / 100
    self.salvationAuraCd = self:GetSpecialValueFor("salvation_aura_cd")
    self.salvationAuraRadius = self:GetSpecialValueFor("salvation_aura_radius")
    self.cdrMinCdForProc = self:GetSpecialValueFor("cdr_min_cd_for_proc")
    self.cdrOnProc = self:GetSpecialValueFor("cdr_on_proc")
    self.bonusHealingReceived = self:GetSpecialValueFor("bonus_healing_received") / 100
    self.bonusHealingReceivedDuration = self:GetSpecialValueFor("bonus_healing_received_duration")
    if (self.salvationAuraRadius > 0) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.caster = self:GetCaster()
        modifierTable.target = modifierTable.caster
        modifierTable.modifier_name = "modifier_light_cardinal_salvation_aura"
        modifierTable.duration = -1
        GameMode:ApplyBuff(modifierTable)
    end
end

function light_cardinal_salvation:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_silence"
    modifierTable.duration = self.silenceDuration
    GameMode:ApplyDebuff(modifierTable)
    local casterHealth = caster:GetHealth()
    local casterMaxHealth = caster:GetMaxHealth()
    caster:SetHealth(math.max(casterHealth - (self.healthCost * casterMaxHealth), 1))
    caster:EmitSound("Hero_Silencer.Curse.Cast")
    local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/salvation/light.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:ReleaseParticleIndex(pidx)
    local healing = self.healing * Units:GetHeroIntellect(caster) + self.healingMissingHealth * (casterMaxHealth - casterHealth)
    local allies = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, ally in pairs(allies) do
        if (self.bonusHealingReceivedDuration > 0) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = ally
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_light_cardinal_salvation_buff"
            modifierTable.duration = self.bonusHealingReceivedDuration
            GameMode:ApplyBuff(modifierTable)
        end
        local healTable = {}
        healTable.caster = self.caster
        healTable.target = ally
        healTable.ability = self
        healTable.heal = healing
        GameMode:HealUnit(healTable)
        ally:Purge(false, true, false, true, true)
    end
end

-- light_cardinal_harmony
modifier_light_cardinal_harmony = class({
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

function modifier_light_cardinal_harmony:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_light_cardinal_harmony:GetHealthPercentBonus()
    return self.ability.bonusMaxHealth or 0
end

function modifier_light_cardinal_harmony:GetManaPercentBonus()
    return self.ability.bonusMaxMana or 0
end

function modifier_light_cardinal_harmony:GetHealthRegenerationPercentBonus()
    return self.ability.bonusHpRegeneration or 0
end

function modifier_light_cardinal_harmony:GetManaRegenerationPercentBonus()
    return self.ability.bonusManaRegeneration or 0
end

function modifier_light_cardinal_harmony:GetHealthBonus()
    return (self.ability.intToHealth or 0) * Units:GetHeroIntellect(self.caster)
end

function modifier_light_cardinal_harmony:GetStatusResistanceBonus()
    local missingHpPercent = 1 - (self.caster:GetHealth() / self.caster:GetMaxHealth())
    return math.min(missingHpPercent * (self.ability.debuffResistancePerMissingHpPct or 0), (self.ability.debuffResistancePerMissingHpPctMax or 0))
end

LinkedModifiers["modifier_light_cardinal_harmony"] = LUA_MODIFIER_MOTION_NONE

light_cardinal_harmony = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_harmony"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_light_cardinal_harmony"
    end,
    GetBehavior = function(self)
        if (self:GetSpecialValueFor("swap_active") > 0) then
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
        else
            return DOTA_ABILITY_BEHAVIOR_PASSIVE
        end
    end,
    GetCooldown = function(self)
        return self:GetSpecialValueFor("swap_cd")
    end,
})

function light_cardinal_harmony:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local casterMaxHp = caster:GetMaxHealth()
    local casterMaxMp = caster:GetMaxMana()
    local hpPercent = caster:GetHealth() / casterMaxHp
    local mpPercent = caster:GetMana() / casterMaxMp
    caster:SetHealth(mpPercent * casterMaxHp)
    caster:SetMana(hpPercent * casterMaxMp)
    local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/harmony/harmony.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    Timers:CreateTimer(2.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
end

function light_cardinal_harmony:OnUpgrade()
    if not IsServer() then
        return
    end
    self.intToHealth = self:GetSpecialValueFor("int_to_health")
    self.slowImmunityMaxHp = self:GetSpecialValueFor("slow_immunity_max_hp") / 100
    self.bonusMaxHealth = self:GetSpecialValueFor("bonus_max_health") / 100
    self.bonusMaxMana = self:GetSpecialValueFor("bonus_max_mana") / 100
    self.bonusHpRegeneration = self:GetSpecialValueFor("bonus_hp_regeneration") / 100
    self.bonusManaRegeneration = self:GetSpecialValueFor("bonus_mana_regeneration") / 100
    self.debuffResistancePerMissingHpPct = self:GetSpecialValueFor("debuff_resistance_per_missing_hp_pct")
    self.debuffResistancePerMissingHpPctMax = self:GetSpecialValueFor("debuff_resistance_per_missing_hp_pct_max") / 100
end

-- light_cardinal_consecration
light_cardinal_consecration = class({
    GetAbilityTextureName = function(self)
        return "light_cardinal_consecration"
    end,
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("aoe")
    end,
    GetBehavior = function(self)
        local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
        if (self:GetSpecialValueFor("aoe") > 0) then
            behavior = behavior + DOTA_ABILITY_BEHAVIOR_AOE
        end
        if (self:GetSpecialValueFor("max_hp_burn") > 0) then
            behavior = behavior + DOTA_ABILITY_BEHAVIOR_AUTOCAST
        end
        return behavior
    end,
    IsRequireCastbar = function(self)
        return true
    end
})

function light_cardinal_consecration:OnTakeDamage(damageTable)
    local ability = damageTable.victim:FindAbilityByName("light_cardinal_consecration")
    if (damageTable.damage > 0 and ability and ability.manaShield and ability.manaShield > 0) then
        local casterMana = damageTable.victim:GetMana()
        if (damageTable.damage >= casterMana) then
            damageTable.damage = damageTable.damage - casterMana
            damageTable.victim:SetMana(0)
        else
            damageTable.victim:SetMana(casterMana - damageTable.damage)
            damageTable.damage = 0
        end
        modifier_out_of_combat:ResetTimer(damageTable.victim)
        return damageTable
    end
end

function light_cardinal_consecration:OnPostTakeDamage(damageTable)
    local ability = damageTable.victim:FindAbilityByName("light_cardinal_consecration")
    if (ability and ability.manaShield and ability.manaShield > 0) then
        damageTable.victim:ForceKill(false)
    end
end

function light_cardinal_consecration:OnPreHeal(healTable)
    local ability = healTable.target:FindAbilityByName("light_cardinal_consecration")
    if (ability and ability.healingBlock and ability.healingBlock > 0 and ability:GetAutoCastState()) then
        healTable.heal = 0
        return healTable
    end
    return healTable
end

function light_cardinal_consecration:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local pidx = ParticleManager:CreateParticle("particles/units/light_cardinal/consecration/consecration.vpcf", PATTACH_ABSORIGIN, target)
    local casterHealth = caster:GetHealth()
    local casterMaxHealth = caster:GetMaxHealth()
    local damage = (casterMaxHealth - casterHealth) * self.damage
    caster:SetHealth(math.max(1, casterHealth - (casterMaxHealth * self.maxHpBurn)))
    if (self.aoe > 0) then
        ParticleManager:SetParticleControl(pidx, 1, Vector(self.aoe, self.aoe, self.aoe))
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                target:GetAbsOrigin(),
                nil,
                self.aoe,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            local damageTable = {}
            damageTable.caster = caster
            damageTable.target = enemy
            damageTable.ability = self
            damageTable.damage = damage
            damageTable.holydmg = true
            damageTable.aoe = true
            GameMode:DamageUnit(damageTable)
        end
    else
        ParticleManager:SetParticleControl(pidx, 1, Vector(50, 50, 50))
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.holydmg = true
        damageTable.single = true
        GameMode:DamageUnit(damageTable)
    end
    ParticleManager:ReleaseParticleIndex(pidx)
    EmitSoundOn("Hero_Omniknight.Purification", target)
end

function light_cardinal_consecration:OnUpgrade()
    if not IsServer() then
        return
    end
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.maxHpBurn = self:GetSpecialValueFor("max_hp_burn") / 100
    self.aoe = self:GetSpecialValueFor("aoe")
    self.manaShield = self:GetSpecialValueFor("mana_shield")
    self.healingBlock = self:GetSpecialValueFor("healing_block")
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_light_cardinal", MotionController)
end

if (IsServer() and not GameMode.LIGHT_CARDINAL_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_light_cardinal_salvation_aura_buff, 'OnTakeDamage'))
    GameMode:RegisterPostApplyModifierEventHandler(Dynamic_Wrap(modifier_light_cardinal_piety, 'OnPostModifierApplied'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_light_cardinal_sublimation, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(light_cardinal_consecration, 'OnTakeDamage'))
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(light_cardinal_consecration, 'OnPostTakeDamage'))
    GameMode:RegisterPreHealEventHandler(Dynamic_Wrap(light_cardinal_consecration, 'OnPreHeal'))
    GameMode.LIGHT_CARDINAL_INIT = true
end