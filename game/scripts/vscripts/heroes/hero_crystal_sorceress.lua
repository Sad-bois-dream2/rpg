local LinkedModifiers = {}

-- crystal_sorceress_frost_comet
modifier_crystal_sorceress_frost_comet_debuff = class({
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
    end,
    DeclareFunctions = function()
        return {
            MODIFIER_PROPERTY_TOOLTIP
        }
    end
})

function modifier_crystal_sorceress_frost_comet_debuff:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_crystal_sorceress_frost_comet_debuff:GetFrostProtectionBonus()
    return self.ability.frostResistanceReduction
end

function modifier_crystal_sorceress_frost_comet_debuff:OnTooltip()
    return self:GetAbility():GetSpecialValueFor("frost_resistance_reduction")
end

LinkedModifiers["modifier_crystal_sorceress_frost_comet_debuff"] = LUA_MODIFIER_MOTION_NONE

crystal_sorceress_frost_comet = class({
    IsRequireCastbar = function()
        return true
    end
})

function crystal_sorceress_frost_comet:OnAbilityPhaseStart(causeEffect)
    if (not IsServer()) then
        return true
    end
    self.caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    local casterPosition = self.caster:GetAbsOrigin()
    local targetPosition = self.target:GetAbsOrigin()
    local direction = (targetPosition - casterPosition):Normalized()
    self.orbPosition = casterPosition + (direction * 100) + Vector(0, 0, 200)
    local lifeDuration = ((100 - math.abs(modifier_castbar.GetModifierPercentageCasttime({ hero = self.caster }))) / 100) * 2
    if (causeEffect == false) then
        lifeDuration = 0.1
    else
        EmitSoundOn("Hero_Ancient_Apparition.ColdFeetCast", self.caster)
    end
    self.pidx = ParticleManager:CreateParticle("particles/units/crystal_sorceress/frost_comet/crystal_sorceress_frost_comet_cast.vpcf", PATTACH_POINT, self.caster)
    ParticleManager:SetParticleControl(self.pidx, 0, self.orbPosition)
    ParticleManager:SetParticleControl(self.pidx, 1, Vector(0, lifeDuration, 0))
    return true
end

function crystal_sorceress_frost_comet:OnAbilityPhaseInterrupted()
    if (not IsServer()) then
        return
    end
    self:DestroyAbilityPhaseEffects()
end

function crystal_sorceress_frost_comet:DestroyAbilityPhaseEffects()
    if (not IsServer()) then
        return
    end
    StopSoundOn("Hero_Ancient_Apparition.ColdFeetCast", self.caster)
    ParticleManager:DestroyParticle(self.pidx, true)
    ParticleManager:ReleaseParticleIndex(self.pidx)
end

function crystal_sorceress_frost_comet:OnProjectileHit(target)
    if (not IsServer() or not target) then
        return
    end
    self:DestroyAbilityPhaseEffects()
    if (RollPercentage(self.procChance)) then
        local pidx = ParticleManager:CreateParticle("particles/units/crystal_sorceress/frost_comet/crystal_sorceress_frost_comet_hit_b.vpcf", PATTACH_ABSORIGIN, target)
        ParticleManager:ReleaseParticleIndex(pidx)
        local enemies = FindUnitsInRadius(self.casterTeam,
                target:GetAbsOrigin(),
                nil,
                self.procAoe,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        local damage = Units:GetHeroIntellect(self.caster) * self.procDamage
        for _, enemy in pairs(enemies) do
            local damageTable = {}
            damageTable.caster = self.caster
            damageTable.target = enemy
            damageTable.ability = self
            damageTable.damage = damage
            damageTable.frostdmg = true
            damageTable.aoe = true
            GameMode:DamageUnit(damageTable)
            local pidx = ParticleManager:CreateParticle("particles/units/crystal_sorceress/frost_comet/crystal_sorceress_frost_comet_hit_smoke.vpcf", PATTACH_POINT, enemy)
            ParticleManager:SetParticleControlEnt(pidx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(pidx)
        end
    end
    local damageTable = {}
    damageTable.caster = self.caster
    damageTable.target = target
    damageTable.ability = self
    damageTable.damage = Units:GetHeroIntellect(self.caster) * self.damage
    damageTable.frostdmg = true
    damageTable.single = true
    GameMode:DamageUnit(damageTable)
end

function crystal_sorceress_frost_comet:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local projectile = {
        Target = self.target,
        Ability = self,
        vSourceLoc = self.orbPosition,
        EffectName = "particles/units/crystal_sorceress/frost_comet/crystal_sorceress_frost_comet.vpcf",
        bDodgable = false,
        bProvidesVision = false,
        iMoveSpeed = 800
    }
    ProjectileManager:CreateTrackingProjectile(projectile)
    EmitSoundOn("Hero_Ancient_Apparition.ChillingTouch.Cast", self.caster)
    if (self.freezingDestructionCdrFlat > 0) then
        local cooldownTable = {
            target = self.caster,
            ability = "crystal_sorceress_freezing_destruction",
            reduction = self.freezingDestructionCdrFlat,
            isflat = true
        }
        GameMode:ReduceAbilityCooldown(cooldownTable)
    end
end

function crystal_sorceress_frost_comet:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.procDamage = self:GetSpecialValueFor("proc_damage") / 100
    self.procChance = self:GetSpecialValueFor("proc_chance")
    self.procAoe = self:GetSpecialValueFor("proc_aoe")
    self.frostResistanceReduction = self:GetSpecialValueFor("frost_resistance_reduction") / -100
    self.frostResistanceReductionDuration = self:GetSpecialValueFor("frost_resistance_reduction_duration")
    self.freezingDestructionCdrFlat = self:GetSpecialValueFor("freezing_destruction_cdr_flat")
    self.casterTeam = self:GetCaster():GetTeamNumber()
end

function crystal_sorceress_frost_comet:OnPostTakeDamage(damageTable)
    local ability = damageTable.attacker:FindAbilityByName("crystal_sorceress_frost_comet")
    if (ability and damageTable.ability and damageTable.ability == ability and ability.frostResistanceReduction and ability.frostResistanceReductionDuration > 0) then
        local modifierTable = {}
        modifierTable.ability = ability
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_crystal_sorceress_frost_comet_debuff"
        modifierTable.duration = ability.frostResistanceReductionDuration
        GameMode:ApplyDebuff(modifierTable)
    end
end

-- crystal_sorceress_deep_freeze
modifier_crystal_sorceress_deep_freeze_aura = class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.ability.radius
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_crystal_sorceress_deep_freeze_aura_debuff"
    end,
    GetAuraDuration = function(self)
        return 0
    end,
    GetEffectName = function(self)
        return "particles/units/crystal_sorceress/deep_freeze/deep_freeze.vpcf"
    end
})

function modifier_crystal_sorceress_deep_freeze_aura:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self:OnIntervalThink()
    self:StartIntervalThink(self.ability.tick)
end

function modifier_crystal_sorceress_deep_freeze_aura:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local manaCost = (self.caster:GetMaxMana() * self.ability.maxManaCostPerSecond)
    if (self.caster:HasModifier("modifier_crystal_sorceress_deep_freeze_buff")) then
        manaCost = manaCost * self.ability.maxManaCostMultiplierAfterGlacierRush
    end
    local newMana = math.max(0, self.caster:GetMana() - manaCost)
    self.caster:SetMana(newMana)
    if (newMana < 1) then
        self.ability:ToggleAbility()
        self:Destroy()
    end
end
LinkedModifiers["modifier_crystal_sorceress_deep_freeze_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_deep_freeze_aura_debuff = class({
    IsDebuff = function(self)
        return true
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

function modifier_crystal_sorceress_deep_freeze_aura_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self:StartIntervalThink(self.ability.tick)
end

function modifier_crystal_sorceress_deep_freeze_aura_debuff:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local modifierTable = {}
    modifierTable.ability = self.ability
    modifierTable.caster = self.caster
    modifierTable.target = self.target
    modifierTable.modifier_name = "modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks"
    modifierTable.duration = self.ability.debuffLingerDuration
    modifierTable.stacks = 1
    modifierTable.max_stacks = self.ability.maxStacks
    GameMode:ApplyStackingDebuff(modifierTable)
end

LinkedModifiers["modifier_crystal_sorceress_deep_freeze_aura_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks = class({
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
    end,
    GetEffectName = function(self)
        return "particles/units/crystal_sorceress/deep_freeze/deep_freeze_debuff.vpcf"
    end
})

function modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

---@param damageTable DAMAGE_TABLE
function modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks:GetAdditionalConditionalDamage(damageTable)
    if (damageTable.frostdmg) then
        return self:GetStackCount() * self.ability.bonusFrostDamagePerStack
    end
end

LinkedModifiers["modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_deep_freeze_buff = class({
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
    end
})

LinkedModifiers["modifier_crystal_sorceress_deep_freeze_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_deep_freeze = class({
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
    DeclareFunctions = function()
        return {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
        }
    end
})

function modifier_crystal_sorceress_deep_freeze:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.casterTeam = self.caster:GetTeamNumber()
    self.frostCometAbility = self.caster:FindAbilityByName("crystal_sorceress_frost_comet")
end

function modifier_crystal_sorceress_deep_freeze:OnRefresh()
    if (not IsServer()) then
        return
    end
    self.ability:OnUpgrade()
    self:StartIntervalThink(-1)
    self:StartIntervalThink(self.ability.frostCometCastEvery)
end

function modifier_crystal_sorceress_deep_freeze:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    if (not self.frostCometAbility or self.frostCometAbility:GetLevel() < 1) then
        return
    end
    local enemies = FindUnitsInRadius(self.casterTeam,
            self.caster:GetAbsOrigin(),
            nil,
            self.ability.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        if (enemy:HasModifier("modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks")) then
            self.caster:SetCursorCastTarget(enemy)
            self.frostCometAbility:OnAbilityPhaseStart(false)
            self.frostCometAbility:OnSpellStart()
        end
    end
end

function modifier_crystal_sorceress_deep_freeze:OnAbilityFullyCast(keys)
    if (not IsServer()) then
        return
    end
    if (keys.unit == self.caster and self.ability.maxManaCostMultiplierAfterGlacierRushDuration > 0) then
        local modifierTable = {}
        modifierTable.caster = self.caster
        modifierTable.ability = self.ability
        modifierTable.target = self.caster
        modifierTable.modifier_name = "modifier_crystal_sorceress_deep_freeze_buff"
        modifierTable.duration = self.ability.maxManaCostMultiplierAfterGlacierRushDuration
        GameMode:ApplyBuff(modifierTable)
    end
end

LinkedModifiers["modifier_crystal_sorceress_deep_freeze"] = LUA_MODIFIER_MOTION_NONE

crystal_sorceress_deep_freeze = class({
    GetCastRange = function(self)
        return self:GetSpecialValueFor("radius")
    end,
    GetIntrinsicModifierName = function()
        return "modifier_crystal_sorceress_deep_freeze"
    end
})

function crystal_sorceress_deep_freeze:OnToggle()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    if (self:GetToggleState()) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_crystal_sorceress_deep_freeze_aura"
        modifierTable.duration = -1
        caster.deepFreezeModifier = GameMode:ApplyBuff(modifierTable)
        self:UseResources(true, true, true)
        EmitSoundOn("Hero_Ancient_Apparition.IceVortexCast", caster)
    else
        if (caster.deepFreezeModifier) then
            caster.deepFreezeModifier:Destroy()
            caster.deepFreezeModifier = nil
        end
    end
end

function crystal_sorceress_deep_freeze:OnUpgrade()
    self.bonusFrostDamagePerStack = self:GetSpecialValueFor("bonus_frost_damage_per_stack") / 100
    self.maxManaCostPerSecond = self:GetSpecialValueFor("max_mana_cost_per_second") / 100
    self.maxStacks = self:GetSpecialValueFor("max_stacks")
    self.radius = self:GetSpecialValueFor("radius")
    self.tick = self:GetSpecialValueFor("tick")
    self.frostCometCastEvery = self:GetSpecialValueFor("frost_comet_cast_every")
    self.debuffLingerDuration = self:GetSpecialValueFor("debuff_linger_duration")
    self.maxManaCostMultiplierAfterGlacierRush = self:GetSpecialValueFor("max_mana_cost_multiplier_after_glacier_rush")
    self.maxManaCostMultiplierAfterGlacierRushDuration = self:GetSpecialValueFor("max_mana_cost_multiplier_after_glacier_rush_duration")
end

-- crystal_sorceress_glacier_rush
modifier_crystal_sorceress_glacier_rush_slow = class({
    IsDebuff = function(self)
        return true
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
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_TOOLTIP }
    end
})

function modifier_crystal_sorceress_glacier_rush_slow:OnTooltip()
    return self:GetAbility():GetSpecialValueFor("movespeed_slow")
end

function modifier_crystal_sorceress_glacier_rush_slow:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_crystal_sorceress_glacier_rush_slow:GetMoveSpeedPercentBonus()
    return self.movespeedSlow
end

LinkedModifiers["modifier_crystal_sorceress_glacier_rush_slow"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_glacier_rush_buff = class({
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
        return { MODIFIER_PROPERTY_TOOLTIP }
    end
})

function modifier_crystal_sorceress_glacier_rush_buff:OnTooltip()
    return self:GetAbility():GetSpecialValueFor("bonus_crit_chance_per_stack") * self:GetStackCount()
end

function modifier_crystal_sorceress_glacier_rush_buff:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_crystal_sorceress_glacier_rush_buff:GetCriticalChanceBonus()
    return self.ability.bonusCritChancePerStack * self:GetStackCount()
end

LinkedModifiers["modifier_crystal_sorceress_glacier_rush_buff"] = LUA_MODIFIER_MOTION_NONE

crystal_sorceress_glacier_rush = class({})

function crystal_sorceress_glacier_rush:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local casterPosition = caster:GetAbsOrigin()
    local targetPosition = self:GetCursorPosition()
    local direction = (targetPosition - casterPosition):Normalized()
    local lifeDuration = 2
    targetPosition = casterPosition + (direction * self.range)
    EmitSoundOn("Hero_Jakiro.IcePath", caster)
    local pidx = ParticleManager:CreateParticle("particles/econ/items/jakiro/jakiro_ti7_immortal_head/jakiro_ti7_immortal_head_ice_path_b.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx, 1, targetPosition)
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifeDuration, 0, 0))
    local pidx2 = ParticleManager:CreateParticle("particles/econ/items/jakiro/jakiro_ti7_immortal_head/jakiro_ti7_immortal_head_ice_path.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx2, 1, targetPosition)
    ParticleManager:SetParticleControl(pidx2, 2, Vector(lifeDuration, 0, 0))
    Timers:CreateTimer(lifeDuration, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
        ParticleManager:DestroyParticle(pidx2, false)
        ParticleManager:ReleaseParticleIndex(pidx2)
        StopSoundOn("Hero_Jakiro.IcePath", caster)
    end)
    local enemies = FindUnitsInLine(caster:GetTeam(),
            casterPosition,
            targetPosition,
            caster,
            self.width,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE)
    local damage = self.damage * Units:GetHeroIntellect(caster)
    for _, enemy in pairs(enemies) do
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.frostdmg = true
        damageTable.aoe = true
        GameMode:DamageUnit(damageTable)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.caster = caster
        modifierTable.target = enemy
        modifierTable.modifier_name = "modifier_stunned"
        modifierTable.duration = self.stunDuration
        GameMode:ApplyDebuff(modifierTable)
        if (self.movespeedSlowDuration > 0) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.caster = caster
            modifierTable.target = enemy
            modifierTable.modifier_name = "modifier_crystal_sorceress_glacier_rush_slow"
            modifierTable.duration = self.movespeedSlowDuration
            GameMode:ApplyDebuff(modifierTable)
        end
    end
    if (self.bonusCritChancePerStack > 0) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.caster = caster
        modifierTable.target = caster
        modifierTable.modifier_name = "modifier_crystal_sorceress_glacier_rush_buff"
        modifierTable.duration = self.stacksDuration
        modifierTable.stacks = #enemies
        modifierTable.max_stacks = self.maxStacks
        GameMode:ApplyStackingBuff(modifierTable)
    end
    if (self.cdrFlatPerEnemyDamaged > 0) then
        local cooldownTable = {
            target = caster,
            ability = "crystal_sorceress_glacier_rush",
            reduction = self.cdrFlatPerEnemyDamaged * #enemies,
            isflat = true
        }
        GameMode:ReduceAbilityCooldown(cooldownTable)
    end
end

function crystal_sorceress_glacier_rush:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.bonusCritChancePerStack = self:GetSpecialValueFor("bonus_crit_chance_per_stack") / 100
    self.stacksDuration = self:GetSpecialValueFor("stacks_duration")
    self.maxStacks = self:GetSpecialValueFor("max_stacks")
    self.stunDuration = self:GetSpecialValueFor("stun_duration")
    self.range = self:GetSpecialValueFor("range")
    self.width = self:GetSpecialValueFor("width")
    self.movespeedSlow = -self:GetSpecialValueFor("movespeed_slow") / 100
    self.movespeedSlowDuration = self:GetSpecialValueFor("movespeed_slow_duration")
    self.cdrFlatPerEnemyDamaged = self:GetSpecialValueFor("cdr_flat_per_enemy_damaged")
end

-- crystal_sorceress_freezing_destruction
modifier_crystal_sorceress_freezing_destruction = class({
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
    end
})

function modifier_crystal_sorceress_freezing_destruction:OnCreated()
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
    self.ability:OnUpgrade()
end

function modifier_crystal_sorceress_freezing_destruction:GetManaRegenerationBonus()
    return self.ability.passiveMaxManaRegeneration * self.caster:GetMaxMana()
end

LinkedModifiers["modifier_crystal_sorceress_freezing_destruction"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_freezing_destruction_buff = class({
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
    end
})

function modifier_crystal_sorceress_freezing_destruction_buff:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_crystal_sorceress_freezing_destruction_buff:GetCriticalDamageBonus()
    return self.ability.bonusCritDmg
end

LinkedModifiers["modifier_crystal_sorceress_freezing_destruction_buff"] = LUA_MODIFIER_MOTION_NONE

crystal_sorceress_freezing_destruction = class({
    IsRequireCastbar = function(self)
        return true
    end,
    GetBehavior = function(self)
        if (self:GetSpecialValueFor("stun_duration") > 0) then
            return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_AUTOCAST
        else
            return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
        end
    end,
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("radius")
    end,
    GetIntrinsicModifierName = function()
        return "modifier_crystal_sorceress_freezing_destruction"
    end
})

function crystal_sorceress_freezing_destruction:OnAbilityPhaseStart()
    if (not IsServer()) then
        return true
    end
    self.caster = self:GetCaster()
    self.casterTeam = self.caster:GetTeamNumber()
    self.targetPosition = self:GetCursorPosition()
    EmitSoundOn("hero_Crystal.freezingField.wind", self.caster)
    self.pidx = ParticleManager:CreateParticle("particles/units/crystal_sorceress/freezing_destruction/freezing_destruction_aoe.vpcf", PATTACH_ABSORIGIN, self.caster)
    ParticleManager:SetParticleControl(self.pidx, 0, self.targetPosition)
    ParticleManager:SetParticleControl(self.pidx, 1, Vector(self.radius, 0, 0))
    self.pidx2 = ParticleManager:CreateParticle("particles/units/crystal_sorceress/freezing_destruction/freezing_destruction_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
    ParticleManager:SetParticleControlEnt(self.pidx2, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_staff1", self.caster:GetAbsOrigin(), true)
    return true
end

function crystal_sorceress_freezing_destruction:OnAbilityPhaseInterrupted()
    if (not IsServer()) then
        return
    end
    self:DestroyCastEffect()
end

function crystal_sorceress_freezing_destruction:DestroyCastEffect()
    if (not IsServer()) then
        return
    end
    StopSoundOn("hero_Crystal.freezingField.wind", self.caster)
    if (self.pidx) then
        ParticleManager:DestroyParticle(self.pidx, false)
        ParticleManager:ReleaseParticleIndex(self.pidx)
        self.pidx = nil
    end
    if (self.pidx2) then
        ParticleManager:DestroyParticle(self.pidx2, false)
        ParticleManager:ReleaseParticleIndex(self.pidx2)
        self.pidx2 = nil
    end
end

function crystal_sorceress_freezing_destruction:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.meteors = self:GetSpecialValueFor("meteors")
    self.bonusCritDmg = self:GetSpecialValueFor("bonus_crit_dmg") / 100
    self.stunDuration = self:GetSpecialValueFor("stun_duration")
    self.radius = self:GetSpecialValueFor("radius")
    self.passiveMaxManaRegeneration = self:GetSpecialValueFor("passive_max_mana_regeneration") / 100
end

function crystal_sorceress_freezing_destruction:OnSpellStart()
    if (not IsServer()) then
        return
    end
    self:DestroyCastEffect()
    local angleBetweenMeteors = 360 / self.meteors
    local distanceFromCenter = self.radius / 2
    local currentAngle = 0
    local velocity
    local meteorProjectiles = {}
    for _ = 1, self.meteors do
        local angleInRadians = math.rad(currentAngle)
        local landPoint = Vector(self.targetPosition[1] + distanceFromCenter * math.cos(angleInRadians), self.targetPosition[2] + distanceFromCenter * math.sin(angleInRadians), self.targetPosition[3])
        local direction = (landPoint - self.targetPosition):Normalized()
        local spawnPoint = landPoint + (direction * self.radius * 2) + Vector(0, 0, 700)
        local pidx = ParticleManager:CreateParticle("particles/units/crystal_sorceress/freezing_destruction/freezing_destruction_projectile.vpcf", PATTACH_ABSORIGIN, self.caster)
        ParticleManager:SetParticleControl(pidx, 0, spawnPoint)
        velocity = landPoint - spawnPoint
        ParticleManager:SetParticleControl(pidx, 1, velocity)
        table.insert(meteorProjectiles, { pidx = pidx, landPoint = landPoint })
        currentAngle = currentAngle + angleBetweenMeteors
    end
    local meteorSpeed = 1250
    local landTime = velocity:Length() / meteorSpeed
    local damage = self.damage * Units:GetHeroIntellect(self.caster)
    Timers:CreateTimer(landTime, function()
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.caster
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_crystal_sorceress_freezing_destruction_buff"
        modifierTable.duration = -1
        local critDmgModifier = GameMode:ApplyBuff(modifierTable)
        for _, meteorInfo in pairs(meteorProjectiles) do
            ParticleManager:DestroyParticle(meteorInfo.pidx, true)
            ParticleManager:ReleaseParticleIndex(meteorInfo.pidx)
            local pidx = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf", PATTACH_ABSORIGIN, self.caster)
            ParticleManager:SetParticleControl(pidx, 0, meteorInfo.landPoint)
            ParticleManager:SetParticleControl(pidx, 1, Vector(distanceFromCenter, 0, 0))
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
            local enemies = FindUnitsInRadius(self.casterTeam,
                    meteorInfo.landPoint,
                    nil,
                    self.radius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            for _, enemy in pairs(enemies) do
                local damageTable = {}
                damageTable.caster = self.caster
                damageTable.target = enemy
                damageTable.ability = self
                damageTable.damage = damage
                damageTable.frostdmg = true
                damageTable.aoe = true
                GameMode:DamageUnit(damageTable)
                if (self:GetAutoCastState()) then
                    local modifierTable = {}
                    modifierTable.ability = self
                    modifierTable.target = enemy
                    modifierTable.caster = self.caster
                    modifierTable.modifier_name = "modifier_stunned"
                    modifierTable.duration = self.stunDuration
                    GameMode:ApplyDebuff(modifierTable)
                end
            end
            EmitSoundOnLocationWithCaster(meteorInfo.landPoint, "Hero_Ancient_Apparition.IceBlast.Target", self.caster)
        end
        critDmgModifier:Destroy()
    end, self)
end

-- crystal_sorceress_cold_embrace
modifier_crystal_sorceress_cold_embrace_buff = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetEffectName = function()
        return "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf"
    end,
    CheckState = function()
        return {
            [MODIFIER_STATE_FROZEN] = true,
            [MODIFIER_STATE_STUNNED] = true
        }
    end,
})

function modifier_crystal_sorceress_cold_embrace_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.target = self:GetParent()
    EmitSoundOn("Hero_Winter_Wyvern.ColdEmbrace.Cast", self.target)
    EmitSoundOn("Hero_Winter_Wyvern.ColdEmbrace", self.target)
end

function modifier_crystal_sorceress_cold_embrace_buff:OnDestroy()
    if (not IsServer()) then
        return
    end
    if (self.ability.bonusDamageReduction > 0) then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.target = self.target
        modifierTable.caster = self.ability:GetCaster()
        modifierTable.modifier_name = "modifier_crystal_sorceress_cold_embrace_buff_damage_reduction"
        modifierTable.duration = self.ability.bonusDamageReductionDuration
        GameMode:ApplyBuff(modifierTable)
    end
    StopSoundOn("Hero_Winter_Wyvern.ColdEmbrace", self.target)
end

function modifier_crystal_sorceress_cold_embrace_buff:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_crystal_sorceress_cold_embrace_buff")
    if (modifier) then
        damageTable.damage = 0
        return damageTable
    end
end

LinkedModifiers["modifier_crystal_sorceress_cold_embrace_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_cold_embrace_buff_damage_reduction = class({
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

function modifier_crystal_sorceress_cold_embrace_buff_damage_reduction:OnTooltip()
    return self:GetAbility():GetSpecialValueFor("bonus_damage_reduction")
end

function modifier_crystal_sorceress_cold_embrace_buff_damage_reduction:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_crystal_sorceress_cold_embrace_buff_damage_reduction:GetStatusEffectName()
    return "particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf"
end

function modifier_crystal_sorceress_cold_embrace_buff_damage_reduction:StatusEffectPriority()
    return 5
end

function modifier_crystal_sorceress_cold_embrace_buff_damage_reduction:GetDamageReductionBonus()
    return self.ability.bonusDamageReduction
end

LinkedModifiers["modifier_crystal_sorceress_cold_embrace_buff_damage_reduction"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_cold_embrace_buff_cast_speed = class({
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
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
            MODIFIER_PROPERTY_TOOLTIP
        }
    end
})

function modifier_crystal_sorceress_cold_embrace_buff_cast_speed:OnTooltip()
    return self:GetAbility():GetSpecialValueFor("bonus_cast_speed")
end

function modifier_crystal_sorceress_cold_embrace_buff_cast_speed:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
end

function modifier_crystal_sorceress_cold_embrace_buff_cast_speed:OnAbilityFullyCast(keys)
    if (not IsServer()) then
        return
    end
    if (keys.unit == self.caster and keys.ability.IsRequireCastbar and keys.ability:IsRequireCastbar() == true) then
        local stacks = self:GetStackCount() - 1
        self:SetStackCount(stacks)
        if (stacks < 1) then
            self:Destroy()
        end
    end
end

function modifier_crystal_sorceress_cold_embrace_buff_cast_speed:GetSpellHasteBonus()
    return self.ability.bonusCastSpeed
end

LinkedModifiers["modifier_crystal_sorceress_cold_embrace_buff_cast_speed"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_cold_embrace = class({
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
    end
})

function modifier_crystal_sorceress_cold_embrace:OnCreated()
    self.ability = self:GetAbility()
    self.ability:OnUpgrade()
end

function modifier_crystal_sorceress_cold_embrace:OnPostTakeDamage(damageTable)
    local ability = damageTable.victim:FindAbilityByName("crystal_sorceress_cold_embrace")
    if (ability and ability.cdrFlatOnDamage and ability.cdrFlatOnDamage > 0) then
        GameMode:ReduceAbilityCooldown({
            target = damageTable.victim,
            ability = "crystal_sorceress_cold_embrace",
            reduction = ability.cdrFlatOnDamage,
            isflat = true
        })
    end
end

LinkedModifiers["modifier_crystal_sorceress_cold_embrace"] = LUA_MODIFIER_MOTION_NONE

crystal_sorceress_cold_embrace = class({
    GetIntrinsicModifierName = function()
        return "modifier_crystal_sorceress_cold_embrace"
    end
})

function crystal_sorceress_cold_embrace:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = self:GetCursorTarget()
    modifierTable.caster = self:GetCaster()
    modifierTable.modifier_name = "modifier_crystal_sorceress_cold_embrace_buff"
    modifierTable.duration = self.duration
    GameMode:ApplyBuff(modifierTable)
    if (self.bonusCastSpeed > 0) then
        modifierTable.duration = self.bonusCastSpeedDuration
        modifierTable.stacks = self.bonusCastSpeedStacks
        modifierTable.max_stacks = self.bonusCastSpeedStacks
        modifierTable.target = modifierTable.caster
        modifierTable.modifier_name = "modifier_crystal_sorceress_cold_embrace_buff_cast_speed"
        GameMode:ApplyStackingBuff(modifierTable)
    end
end

function crystal_sorceress_cold_embrace:OnUpgrade()
    self.duration = self:GetSpecialValueFor("duration")
    self.bonusDamageReduction = self:GetSpecialValueFor("bonus_damage_reduction") / 100
    self.bonusDamageReductionDuration = self:GetSpecialValueFor("bonus_damage_reduction_duration")
    self.bonusCastSpeed = self:GetSpecialValueFor("bonus_cast_speed")
    self.bonusCastSpeedStacks = self:GetSpecialValueFor("bonus_cast_speed_stacks")
    self.bonusCastSpeedDuration = self:GetSpecialValueFor("bonus_cast_speed_duration")
    self.cdrFlatOnDamage = self:GetSpecialValueFor("cdr_flat_on_damage")
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_crystal_sorceress", MotionController)
end

if (IsServer() and not GameMode.CRYSTAL_SORCERESS_INIT) then
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(crystal_sorceress_frost_comet, 'OnPostTakeDamage'))
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_crystal_sorceress_cold_embrace, 'OnPostTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_crystal_sorceress_cold_embrace_buff, 'OnTakeDamage'))
    GameMode.CRYSTAL_SORCERESS_INIT = true
end