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

-- crystal_sorceress_glacier_rush modifiers
modifier_crystal_sorceress_glacier_rush = class({
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
    GetTexture = function(self)
        return crystal_sorceress_glacier_rush:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_TOOLTIP }
    end
})

function modifier_crystal_sorceress_glacier_rush:OnTooltip()
    return self.critChancePerStack * self:GetStackCount() * 100
end

function modifier_crystal_sorceress_glacier_rush:OnCreated()
    self.ability = self:GetAbility()
    self.critChancePerStack = self.ability:GetSpecialValueFor("stack_crit") / 100
end

function modifier_crystal_sorceress_glacier_rush:GetCriticalChanceBonus()
    return self.critChancePerStack * self:GetStackCount()
end

LinkedModifiers["modifier_crystal_sorceress_glacier_rush"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_glacier_rush_stun = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    IsStunDebuff = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return crystal_sorceress_glacier_rush:GetAbilityTextureName()
    end,
    CheckState = function(self)
        return {
            [MODIFIER_STATE_STUNNED] = true,
            [MODIFIER_STATE_FROZEN] = true
        }
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
    end
})

LinkedModifiers["modifier_crystal_sorceress_glacier_rush_stun"] = LUA_MODIFIER_MOTION_NONE

-- crystal_sorceress_glacier_rush
crystal_sorceress_glacier_rush = class({
    GetAbilityTextureName = function(self)
        return "crystal_sorceress_glacier_rush"
    end
})

function crystal_sorceress_glacier_rush:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local casterPosition = caster:GetAbsOrigin()
    local targetPosition = self:GetCursorPosition()
    local direction = (targetPosition - casterPosition):Normalized()
    local width = self:GetSpecialValueFor("width")
    local range = self:GetSpecialValueFor("range")
    local lifeDuration = 2
    targetPosition = casterPosition + (direction * range)
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
            width,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE)
    local damage = self:GetSpecialValueFor("damage") * Units:GetHeroIntellect(caster) * 0.01
    local stunDuration = self:GetSpecialValueFor("stun_duration")
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
        modifierTable.modifier_name = "modifier_crystal_sorceress_glacier_rush_stun"
        modifierTable.duration = stunDuration
        GameMode:ApplyDebuff(modifierTable)
    end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.caster = caster
    modifierTable.target = caster
    modifierTable.modifier_name = "modifier_crystal_sorceress_glacier_rush"
    modifierTable.duration = self:GetSpecialValueFor("stacks_duration")
    modifierTable.stacks = #enemies
    modifierTable.max_stacks = self:GetSpecialValueFor("max_stacks")
    GameMode:ApplyStackingBuff(modifierTable)
end

modifier_crystal_sorceress_freezing_destruction_stun = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    IsStunDebuff = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return crystal_sorceress_freezing_destruction:GetAbilityTextureName()
    end,
    CheckState = function(self)
        return {
            [MODIFIER_STATE_STUNNED] = true,
            [MODIFIER_STATE_FROZEN] = true
        }
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
    end
})

LinkedModifiers["modifier_crystal_sorceress_freezing_destruction_stun"] = LUA_MODIFIER_MOTION_NONE

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
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.bonusCritDamage = self.ability:GetSpecialValueFor("crit_dmg") * 0.01
end

function modifier_crystal_sorceress_freezing_destruction:OnCreated()
    return self.bonusCritDamage
end

function modifier_crystal_sorceress_freezing_destruction:OnPostTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_crystal_sorceress_freezing_destruction")
    if (modifier and damageTable.ability and damageTable.ability == modifier.ability) then
        modifier:Destroy()
    end
end

LinkedModifiers["modifier_crystal_sorceress_freezing_destruction"] = LUA_MODIFIER_MOTION_NONE

-- crystal_sorceress_freezing_destruction
crystal_sorceress_freezing_destruction = class({
    GetAbilityTextureName = function(self)
        return "crystal_sorceress_freezing_destruction"
    end,
    IsRequireCastbar = function(self)
        return true
    end
})

function crystal_sorceress_freezing_destruction:OnAbilityPhaseStart()
    if (not IsServer()) then
        return true
    end
    self.caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    EmitSoundOn("hero_Crystal.freezingField.wind", self.caster)
    self.pidx = ParticleManager:CreateParticle("particles/units/crystal_sorceress/freezing_destruction/freezing_destruction_cast.vpcf", PATTACH_ABSORIGIN, self.caster)
    ParticleManager:SetParticleControlEnt(self.pidx, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_staff1", self.caster:GetAbsOrigin(), true)
    return true
end

function crystal_sorceress_freezing_destruction:OnSpellStart()
    if (not IsServer()) then
        return
    end
    StopSoundOn("hero_Crystal.freezingField.wind", self.caster)
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.caster = self.caster
    modifierTable.target = self.target
    modifierTable.modifier_name = "modifier_crystal_sorceress_freezing_destruction_stun"
    modifierTable.duration = self:GetSpecialValueFor("stun_duration")
    GameMode:ApplyDebuff(modifierTable)
    EmitSoundOn("Hero_Ancient_Apparition.ColdFeetCast", self.target)
    local meteors = self:GetSpecialValueFor("meteors")
    local angleBetweenMeteors = 360 / meteors
    local distanceFromCenter = 200
    local targetPosition = self.target:GetAbsOrigin()
    local currentAngle = angleBetweenMeteors
    local particlesTable = {}
    local landTime = 0
    local meteorSpeed = 1250
    for i = 1, meteors do
        local angleInRadians = math.rad(currentAngle)
        local landPoint = Vector(targetPosition[1] + distanceFromCenter * math.cos(angleInRadians), targetPosition[2] + distanceFromCenter * math.sin(angleInRadians), targetPosition[3])
        local lengthVector = (landPoint - targetPosition)
        local direction = lengthVector:Normalized()
        local spawnPoint = landPoint + (direction * 800) + Vector(0, 0, 700)
        landTime = (landPoint - spawnPoint):Length() / meteorSpeed
        local pidx = ParticleManager:CreateParticle("particles/units/crystal_sorceress/freezing_destruction/freezing_destruction_projectile.vpcf", PATTACH_ABSORIGIN, self.caster)
        ParticleManager:SetParticleControl(pidx, 0, spawnPoint)
        ParticleManager:SetParticleControl(pidx, 1, landPoint)
        ParticleManager:SetParticleControl(pidx, 5, Vector(landTime, 0, 0))
        table.insert(particlesTable, { id = pidx, point = landPoint })
        currentAngle = currentAngle + angleBetweenMeteors
    end
    Timers:CreateTimer(landTime, function()
        local anotherParticleTable = {}
        local casterTeam = self.caster:GetTeam()
        local damageAoe = self:GetSpecialValueFor("damage_aoe")
        local damage = Units:GetHeroIntellect(self.caster) * self:GetSpecialValueFor("damage") * 0.01
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.caster = self.caster
        modifierTable.target = self.caster
        modifierTable.modifier_name = "modifier_crystal_sorceress_freezing_destruction"
        modifierTable.duration = -1
        local modifier = GameMode:ApplyBuff(modifierTable)
        for _, particleInfo in pairs(particlesTable) do
            ParticleManager:DestroyParticle(particleInfo.id, true)
            ParticleManager:ReleaseParticleIndex(particleInfo.id)
            local pidx = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf", PATTACH_ABSORIGIN, self.caster)
            ParticleManager:SetParticleControl(pidx, 0, particleInfo.point)
            local enemies = FindUnitsInRadius(casterTeam,
                    particleInfo.point,
                    nil,
                    damageAoe,
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
            end
            table.insert(anotherParticleTable, pidx)
        end
        modifier:Destroy()
        EmitSoundOn("Hero_Crystal.CrystalNova", self.target)
        Timers:CreateTimer(2, function()
            for _, pidx in pairs(anotherParticleTable) do
                ParticleManager:DestroyParticle(pidx, true)
                ParticleManager:ReleaseParticleIndex(pidx)
            end
        end, self)
    end, self)
end

function crystal_sorceress_freezing_destruction:OnAbilityPhaseInterrupted()
    if (not IsServer()) then
        return
    end
    StopSoundOn("hero_Crystal.freezingField.wind", self.caster)
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_crystal_sorceress", MotionController)
end

if (IsServer() and not GameMode.CRYSTAL_SORCERESS_INIT) then
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_crystal_sorceress_freezing_destruction, 'OnPostTakeDamage'))
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(crystal_sorceress_frost_comet, 'OnPostTakeDamage'))
    GameMode.CRYSTAL_SORCERESS_INIT = true
end