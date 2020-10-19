local LinkedModifiers = {}

-- blazing_berserker_molten_strike
modifier_blazing_berserker_molten_strike_buff = class({
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

function modifier_blazing_berserker_molten_strike_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_blazing_berserker_molten_strike_buff:GetFireDamageBonus()
    return self.ability.fireDamageBonus
end

LinkedModifiers["modifier_blazing_berserker_molten_strike_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_blazing_berserker_molten_strike_dot = class({
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
        return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
    end
})

function modifier_blazing_berserker_molten_strike_dot:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self:OnIntervalThink()
    self:StartIntervalThink(self.ability.dotTick)
end

function modifier_blazing_berserker_molten_strike_dot:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local damageTable = {}
    damageTable.damage = Units:GetHeroStrength(self.caster) * self.ability.dotDamage
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.dot = true
    damageTable.firedmg = true
    GameMode:DamageUnit(damageTable)
end

LinkedModifiers["modifier_blazing_berserker_molten_strike_dot"] = LUA_MODIFIER_MOTION_NONE

modifier_blazing_berserker_molten_strike = class({
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

function modifier_blazing_berserker_molten_strike:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.ability.cooldownProc = 0
    self:OnIntervalThink()
    self:StartIntervalThink(0.05)
end

function modifier_blazing_berserker_molten_strike:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local casterHealth = self.caster:GetHealth()
    local casterMaxHealth = self.caster:GetMaxHealth()
    if (self.ability.maxHpForCooldownProc and casterHealth / casterMaxHealth <= self.ability.maxHpForCooldownProc) then
        self.ability.cooldownProc = 1
    else
        self.ability.cooldownProc = 0
    end
end

LinkedModifiers["modifier_blazing_berserker_molten_strike"] = LUA_MODIFIER_MOTION_NONE

blazing_berserker_molten_strike = class({
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("radius")
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_blazing_berserker_molten_strike"
    end,
    GetCooldown = function(self, lvl)
        if (self.cooldownProc and self.cooldownProc > 0) then
            return self.cooldownProcValue
        end
        return self.BaseClass.GetCooldown(self, lvl)
    end
})

function blazing_berserker_molten_strike:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local targetPosition = self:GetCursorPosition()
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
            targetPosition,
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local damage = Units:GetHeroStrength(caster) * self.damage
    for _, enemy in pairs(enemies) do
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.aoe = true
        damageTable.firedmg = true
        GameMode:DamageUnit(damageTable)
        if (self.dotDuration > 0) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_blazing_berserker_molten_strike_dot"
            modifierTable.duration = self.dotDuration
            GameMode:ApplyDebuff(modifierTable)
        end
    end
    local particle = ParticleManager:CreateParticle("particles/units/blazing_berserker/molten_strike/molten_strike.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, targetPosition)
    ParticleManager:SetParticleControl(particle, 7, Vector(self.radius, 0, 0))
    ParticleManager:SetParticleControl(particle, 60, Vector(210, 105, 30))
    Timers:CreateTimer(0.3, function()
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end)
    if (self.fireDamageBonusDuration > 0) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_blazing_berserker_molten_strike_buff"
        modifierTable.duration = self.fireDamageBonusDuration
        GameMode:ApplyBuff(modifierTable)
    end
    EmitSoundOnLocationWithCaster(targetPosition, "Hero_Invoker.ChaosMeteor.Impact", caster)
    caster:SetHealth(math.max(caster:GetHealth() - (self.maxHpCost * caster:GetMaxHealth()), 1))
    self:EndCooldown()
end

function blazing_berserker_molten_strike:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.maxHpCost = self:GetSpecialValueFor("max_hp_cost") / 100
    self.radius = self:GetSpecialValueFor("radius")
    self.fireDamageBonus = self:GetSpecialValueFor("fire_damage_bonus") / 100
    self.fireDamageBonusDuration = self:GetSpecialValueFor("fire_damage_bonus_duration")
    self.dotDamage = self:GetSpecialValueFor("dot_damage") / 100
    self.dotDuration = self:GetSpecialValueFor("dot_duration")
    self.dotTick = self:GetSpecialValueFor("dot_tick")
    self.maxHpForCooldownProc = self:GetSpecialValueFor("max_hp_for_cooldown_proc") / 100
    self.cooldownProcValue = self:GetSpecialValueFor("cooldown_proc_value")
end

-- blazing_berserker_incinerating_souls
modifier_blazing_berserker_incinerating_souls_dot = class({
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
    GetEffectName = function(self)
        return "particles/units/blazing_berserker/incinerating_souls/incinerating_souls.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_MISS_PERCENTAGE }
    end,
    ShouldUseOverheadOffset = function(self)
        return true
    end
})

function modifier_blazing_berserker_incinerating_souls_dot:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self:OnIntervalThink()
    self:StartIntervalThink(self.ability.dotTick)
end

function modifier_blazing_berserker_incinerating_souls_dot:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local damageTable = {}
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.damage = self.ability.dotDamage * Units:GetHeroStrength(self.caster)
    damageTable.dot = true
    damageTable.firedmg = true
    GameMode:DamageUnit(damageTable)
end

function modifier_blazing_berserker_incinerating_souls_dot:GetModifierMiss_Percentage()
    return self.ability.missChance
end

LinkedModifiers["modifier_blazing_berserker_incinerating_souls_dot"] = LUA_MODIFIER_MOTION_NONE

modifier_blazing_berserker_incinerating_souls = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_blazing_berserker_incinerating_souls:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self:OnIntervalThink()
    self:StartIntervalThink(0.05)
end

function modifier_blazing_berserker_incinerating_souls:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local keysToRemove = {}
    if (self.ability.affectedEnemies) then
        for key, enemy in pairs(self.ability.affectedEnemies) do
            local modifier = enemy:FindModifierByName("modifier_blazing_berserker_incinerating_souls_dot")
            if (not (modifier and modifier.caster and modifier.caster == self.caster)) then
                table.insert(keysToRemove, key)
            end
        end
        for _, key in pairs(keysToRemove) do
            self.ability.affectedEnemies[key] = nil
        end
    end
    self:SetStackCount(1)
end

function modifier_blazing_berserker_incinerating_souls:GetHealthRegenerationBonus()
    local bonus = 0
    if (self.ability and self.ability.maxHpRegenBonusPerEnemy and self.ability.maxHpRegenBonusPerEnemy > 0 and self.ability.affectedEnemies) then
        local casterMaxHealth = self.caster:GetMaxHealth()
        local hpPercent = 1 - (self.caster:GetHealth() / casterMaxHealth)
        bonus = math.max(self.ability.minHpRegenBonusPerEnemy, hpPercent * self.ability.maxHpRegenBonusPerEnemy) * #self.ability.affectedEnemies * casterMaxHealth
    end
    return bonus
end

LinkedModifiers["modifier_blazing_berserker_incinerating_souls"] = LUA_MODIFIER_MOTION_NONE

blazing_berserker_incinerating_souls = class({
    GetIntrinsicModifierName = function(self)
        return "modifier_blazing_berserker_incinerating_souls"
    end,
    GetBehavior = function(self)
        if (self:GetSpecialValueFor("radius") > 0) then
            return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
        else
            return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
        end
    end,
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("radius")
    end,
})

function blazing_berserker_incinerating_souls:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if (self.radius > 0) then
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                target:GetAbsOrigin(),
                nil,
                self.radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            self:ApplyEffect(caster, enemy)
        end
    else
        self:ApplyEffect(caster, target)
    end
end

function blazing_berserker_incinerating_souls:ApplyEffect(caster, target)
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_blazing_berserker_incinerating_souls_dot"
    modifierTable.duration = self.dotDuration
    GameMode:ApplyDebuff(modifierTable)
    if (TableContains(self.affectedEnemies, modifierTable.target) == false) then
        table.insert(self.affectedEnemies, modifierTable.target)
    end
    EmitSoundOn("Hero_Axe.Battle_Hunger", modifierTable.target)
end

function blazing_berserker_incinerating_souls:OnUpgrade()
    self.dotDamage = self:GetSpecialValueFor("dot_damage") / 100
    self.dotDuration = self:GetSpecialValueFor("dot_duration")
    self.dotTick = self:GetSpecialValueFor("dot_tick")
    self.maxHpRegenBonusPerEnemy = self:GetSpecialValueFor("max_hp_regen_bonus_per_enemy") / 100
    self.minHpRegenBonusPerEnemy = self:GetSpecialValueFor("min_hp_regen_bonus_per_enemy") / 100
    self.missChance = self:GetSpecialValueFor("miss_chance")
    self.radius = self:GetSpecialValueFor("radius")
    if (not self.affectedEnemies) then
        self.affectedEnemies = {}
    end
end

-- blazing_berserker_boiling_rage
modifier_blazing_berserker_boiling_rage = class({
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

function modifier_blazing_berserker_boiling_rage:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.missingHealthPct = 0
    self:StartIntervalThink(0.05)
end

function modifier_blazing_berserker_boiling_rage:OnIntervalThink()
    self:SetStackCount(1)
end

function modifier_blazing_berserker_boiling_rage:GetDamageReductionBonus()
    local missingHealthPct = 1 - (self.caster:GetHealth() / self.caster:GetMaxHealth())
    return math.min((self.ability.missingHealthToDamageReduction or 0) * missingHealthPct, self.ability.missingHealthToDamageReductionCap or 0)
end

function modifier_blazing_berserker_boiling_rage:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_blazing_berserker_boiling_rage")
    if (not (damageTable.damage > 0 and modifier)) then
        return damageTable
    end
    if (not (modifier.ability and modifier.ability.missingHealthToBaseSpellDamage and modifier.ability.missingHealthToBaseSpellDamage > 0)) then
        return damageTable
    end
    if (not damageTable.ability) then
        return damageTable
    end
    local missingHealth = damageTable.attacker:GetMaxHealth() - damageTable.attacker:GetHealth()
    damageTable.damage = damageTable.damage + (missingHealth * modifier.ability.missingHealthToBaseSpellDamage)
    return damageTable
end

LinkedModifiers["modifier_blazing_berserker_boiling_rage"] = LUA_MODIFIER_MOTION_NONE

modifier_blazing_berserker_boiling_rage_toggle = class({
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
    GetEffectName = function()
        return "particles/units/blazing_berserker/boiling_rage/boiling_rage_buff.vpcf"
    end
})

function modifier_blazing_berserker_boiling_rage_toggle:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.fissionAbility = self.caster:FindAbilityByName("blazing_berserker_fission")
    self:StartIntervalThink(self.ability.tick)
end

function modifier_blazing_berserker_boiling_rage_toggle:OnIntervalThink()
    local casterNewHealth = self.caster:GetHealth() - (self.caster:GetMaxHealth() * self.ability.maxHpCostPerSec)
    self.caster:SetHealth(math.max(1, casterNewHealth))
    if (self.caster:IsAlive() and casterNewHealth <= self.ability.fissionProcHealth and self.fissionAbility and self.fissionAbility:GetLevel() > 0) then
        self.fissionAbility:PerformSpin(true)
    end
end

function modifier_blazing_berserker_boiling_rage_toggle:GetAttackSpeedPercentBonus()
    local missingHealthPct = 1 - (self.caster:GetHealth() / self.caster:GetMaxHealth())
    return (self.ability.bonusAsPerMissingHealthPct or 0) * missingHealthPct
end

function modifier_blazing_berserker_boiling_rage_toggle:GetFireDamageBonus()
    local missingHealthPct = 1 - (self.caster:GetHealth() / self.caster:GetMaxHealth())
    return (self.ability.bonusFireDamagePerMissingHealthPct or 0) * missingHealthPct
end

LinkedModifiers["modifier_blazing_berserker_boiling_rage_toggle"] = LUA_MODIFIER_MOTION_NONE

blazing_berserker_boiling_rage = class({
    GetIntrinsicModifierName = function()
        return "modifier_blazing_berserker_boiling_rage"
    end
})

function blazing_berserker_boiling_rage:OnToggle()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local modifier = caster:FindModifierByName("modifier_blazing_berserker_boiling_rage_toggle")
    if (modifier) then
        modifier:Destroy()
    end
    if (self:GetToggleState()) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_blazing_berserker_boiling_rage_toggle"
        modifierTable.duration = -1
        GameMode:ApplyBuff(modifierTable)
        self:UseResources(true, true, true)
    end
end

function blazing_berserker_boiling_rage:OnUpgrade()
    self.maxHpCostPerSec = self:GetSpecialValueFor("max_hp_cost_per_sec") / 100
    self.bonusAsPerMissingHealthPct = self:GetSpecialValueFor("bonus_as_per_missing_health_pct")
    self.bonusFireDamagePerMissingHealthPct = self:GetSpecialValueFor("bonus_fire_damage_per_missing_health_pct")
    self.missingHealthToDamageReduction = self:GetSpecialValueFor("missing_health_to_damage_reduction")
    self.missingHealthToDamageReductionCap = self:GetSpecialValueFor("missing_health_to_damage_reduction_max") / 100
    self.missingHealthToBaseSpellDamage = self:GetSpecialValueFor("missing_health_to_base_spell_damage") / 100
    self.tick = self:GetSpecialValueFor("tick")
    self.fissionProcHealth = self:GetSpecialValueFor("fission_proc_health") / 100
end

-- blazing_berserker_fission
modifier_blazing_berserker_fission_dot = class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
})

function modifier_blazing_berserker_fission_dot:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self:OnIntervalThink()
    self:StartIntervalThink(self.ability.dotTick)
end

function modifier_blazing_berserker_fission_dot:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local damageTable = {}
    damageTable.damage = Units:GetHeroStrength(self.caster) * self.ability.dotDamage
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.dot = true
    damageTable.firedmg = true
    GameMode:DamageUnit(damageTable)
end

LinkedModifiers["modifier_blazing_berserker_fission_dot"] = LUA_MODIFIER_MOTION_NONE

modifier_blazing_berserker_fission = class({
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

function modifier_blazing_berserker_fission:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
end

function modifier_blazing_berserker_fission:OnAbilityFullyCast(kv)
    if (not IsServer()) then
        return
    end
    local abilityLevel = kv.ability:GetLevel()
    local abilityCooldown = kv.ability:GetCooldown(abilityLevel)
    if (abilityCooldown < self.ability.minCdForProc or kv.unit ~= self.caster or not self.ability:IsCooldownReady()) then
        return
    end
    self.ability:PerformSpin(true)
end

LinkedModifiers["modifier_blazing_berserker_fission"] = LUA_MODIFIER_MOTION_NONE

modifier_blazing_berserker_fission_spin = class({
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

function modifier_blazing_berserker_fission_spin:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.pidx = ParticleManager:CreateParticle("particles/units/blazing_berserker/fission/fission.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
    ParticleManager:SetParticleControl(self.pidx, 5, Vector(self.ability.radius, 0, 0))
    self.tick = 0.1
    self.localTick = 0
    self.animationTick = 0
    self:OnIntervalThink()
    self:StartIntervalThink(self.tick)
end

function modifier_blazing_berserker_fission_spin:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.localTick = self.localTick + self.tick
    if (self.localTick >= self.ability.spinTick) then
        self.ability:PerformSpin()
        self.localTick = 0
    end
    self.animationTick = self.animationTick + self.tick
    if (self.animationTick >= self.ability.animationDuration) then
        self.caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
        EmitSoundOn("Hero_Axe.CounterHelix", self.caster)
        self.animationTick = 0
    end
end

function modifier_blazing_berserker_fission_spin:OnDestroy()
    if (not IsServer()) then
        return
    end
    ParticleManager:DestroyParticle(self.pidx, true)
    ParticleManager:ReleaseParticleIndex(self.pidx)
end

LinkedModifiers["modifier_blazing_berserker_fission_spin"] = LUA_MODIFIER_MOTION_NONE

modifier_blazing_berserker_fission_aa_fix = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
    end,
    GetModifierBaseDamageOutgoing_Percentage = function(self)
        return -100
    end
})

LinkedModifiers["modifier_blazing_berserker_fission_aa_fix"] = LUA_MODIFIER_MOTION_NONE

blazing_berserker_fission = class({
    GetIntrinsicModifierName = function(self)
        return "modifier_blazing_berserker_fission"
    end,
    GetCastRange = function(self)
        return self:GetSpecialValueFor("radius")
    end,
    GetBehavior = function(self)
        local behavior = DOTA_ABILITY_BEHAVIOR_PASSIVE
        if (self:GetSpecialValueFor("spin_duration") > 0) then
            behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
        end
        return behavior
    end,
    GetCooldown = function(self)
        return self:GetSpecialValueFor("spin_cd")
    end,
})

function blazing_berserker_fission:PerformSpin(showAnimation)
    local enemies = FindUnitsInRadius(self.casterTeam,
            self.caster:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local damage = Units:GetHeroStrength(self.caster) * self.damage
    for _, enemy in pairs(enemies) do
        local damageTable = {}
        damageTable.damage = damage
        damageTable.caster = self.caster
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.firedmg = true
        damageTable.aoe = true
        GameMode:DamageUnit(damageTable)
        if (self.dotDuration > 0) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_blazing_berserker_fission_dot"
            modifierTable.duration = self.dotDuration
            GameMode:ApplyDebuff(modifierTable)
        end
        if (self.aaProc > 0) then
            local attackDamageModifier = self.caster:AddNewModifier(self.caster, nil, "modifier_blazing_berserker_fission_aa_fix", {})
            self.caster:PerformAttack(enemy, true, true, true, true, false, false, true)
            attackDamageModifier:Destroy()
        end
    end
    if (showAnimation) then
        local pidx = ParticleManager:CreateParticle("particles/units/blazing_berserker/fission/fission.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
        ParticleManager:SetParticleControl(pidx, 5, Vector(self.radius, 0, 0))
        self.caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
        EmitSoundOn("Hero_Axe.CounterHelix", self.caster)
        Timers:CreateTimer(self.animationDuration, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
    end
end

function blazing_berserker_fission:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.radius = self:GetSpecialValueFor("radius")
    self.minCdForProc = self:GetSpecialValueFor("min_cd_for_proc")
    self.dotDamage = self:GetSpecialValueFor("dot_damage") / 100
    self.dotDuration = self:GetSpecialValueFor("dot_duration")
    self.dotTick = self:GetSpecialValueFor("dot_tick")
    self.spinDuration = self:GetSpecialValueFor("spin_duration")
    self.spinCd = self:GetSpecialValueFor("spin_cd")
    self.spinTick = self:GetSpecialValueFor("spin_tick")
    self.aaProc = self:GetSpecialValueFor("aa_proc")
    if (not self.caster and IsServer()) then
        self.caster = self:GetCaster()
        self.casterTeam = self.caster:GetTeamNumber()
        self.animationDuration = self.caster:SequenceDuration("counter_helix_anim")
    end
end

function blazing_berserker_fission:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = self.caster
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_blazing_berserker_fission_spin"
    modifierTable.duration = self.spinDuration
    GameMode:ApplyBuff(modifierTable)
end

-- blazing_berserker_flame_dash
modifier_blazing_berserker_flame_dash_thinker = class({
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
    end
})

function modifier_blazing_berserker_flame_dash_thinker:OnCreated(kv)
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.thinker = self:GetParent()
    self.startLocation = self.thinker:GetAbsOrigin()
    self.endLocation = Vector(kv.x, kv.y, kv.z)
    self.caster = self.ability:GetCaster()
    self.casterTeam = self.caster:GetTeamNumber()
    self.pidx = ParticleManager:CreateParticle("particles/units/molten_guardian/lava_spear/lava_spear_ground.vpcf", PATTACH_ABSORIGIN, self.thinker)
    ParticleManager:SetParticleControl(self.pidx, 0, self.startLocation)
    ParticleManager:SetParticleControl(self.pidx, 1, self.endLocation)
    ParticleManager:SetParticleControl(self.pidx, 2, Vector(self.ability.trailDuration, 0, 0))
    ParticleManager:SetParticleControl(self.pidx, 4, self.startLocation)
    self:OnIntervalThink()
    self:StartIntervalThink(self.ability.trailTick)
end

function modifier_blazing_berserker_flame_dash_thinker:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local enemies = FindUnitsInLine(self.casterTeam,
            self.startLocation,
            self.endLocation,
            nil,
            self.ability.trailWidth,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE)
    local damage = Units:GetHeroStrength(self.caster) * self.ability.trailDamage
    for _, enemy in pairs(enemies) do
        local damageTable = {}
        damageTable.damage = damage
        damageTable.caster = self.caster
        damageTable.target = enemy
        damageTable.ability = self.ability
        damageTable.aoe = true
        damageTable.firedmg = true
        GameMode:DamageUnit(damageTable)
    end
end

function modifier_blazing_berserker_flame_dash_thinker:OnDestroy()
    if (not IsServer()) then
        return
    end
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
    UTIL_Remove(self.thinker)
end

LinkedModifiers["modifier_blazing_berserker_flame_dash_thinker"] = LUA_MODIFIER_MOTION_NONE

modifier_blazing_berserker_flame_dash_debuff = class({
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
    DeclareFunctions = function(self)
        return {
            MODIFIER_PROPERTY_TOOLTIP
        }
    end
})

function modifier_blazing_berserker_flame_dash_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_blazing_berserker_flame_dash_debuff:GetFireProtectionBonus()
    return -self.ability.fireResistanceReduction
end

function modifier_blazing_berserker_flame_dash_debuff:OnTooltip()
    return self:GetAbility():GetSpecialValueFor("fire_resistance_reduction")
end

LinkedModifiers["modifier_blazing_berserker_flame_dash_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_blazing_berserker_flame_dash_motion = class({
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
    GetMotionControllerPriority = function(self)
        return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM
    end,
    GetEffectName = function(self)
        return "particles/units/blazing_berserker/flame_dash/flame_dash.vpcf"
    end,
    CheckState = function(self)
        return {
            [MODIFIER_STATE_STUNNED] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true
        }
    end
})

function modifier_blazing_berserker_flame_dash_motion:OnCreated(kv)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.startLocation = self.caster:GetAbsOrigin()
    self.dashRange = math.min(self.ability.dashRange, DistanceBetweenVectors(self.startLocation, self.ability:GetCursorPosition()))
    self.damagedEnemies = {}
    self.caster:AddActivityModifier("forcestaff_friendly")
    self.caster:StartGesture(ACT_DOTA_FLAIL)
    if (self:ApplyHorizontalMotionController() == false) then
        self:Destroy()
    end
end

function modifier_blazing_berserker_flame_dash_motion:OnDestroy()
    if not IsServer() then
        return
    end
    self.caster:RemoveHorizontalMotionController(self)
    self.caster:ClearActivityModifiers()
    self.caster:RemoveGesture(ACT_DOTA_FLAIL)
    local casterPosition = self.caster:GetAbsOrigin()
    CreateModifierThinker(
            self.ability.caster,
            self.ability,
            "modifier_blazing_berserker_flame_dash_thinker",
            {
                duration = self.ability.trailDuration,
                x = casterPosition[1],
                y = casterPosition[2],
                z = casterPosition[3],
            },
            self.startLocation,
            self.caster:GetTeamNumber(),
            false
    )
end

function modifier_blazing_berserker_flame_dash_motion:OnHorizontalMotionInterrupted()
    if IsServer() then
        self:Destroy()
    end
end

function modifier_blazing_berserker_flame_dash_motion:UpdateHorizontalMotion(me, dt)
    if (IsServer()) then
        local currentLocation = self.caster:GetAbsOrigin()
        local expectedLocation = currentLocation + self.caster:GetForwardVector() * self.ability.dashSpeed * dt
        local isTraversable = GridNav:IsTraversable(expectedLocation)
        local isBlocked = GridNav:IsBlocked(expectedLocation)
        local isTreeNearby = GridNav:IsNearbyTree(expectedLocation, self.caster:GetHullRadius(), true)
        local traveled_distance = DistanceBetweenVectors(currentLocation, self.startLocation)
        if (isTraversable and not isBlocked and not isTreeNearby and traveled_distance < self.dashRange) then
            self.caster:SetAbsOrigin(expectedLocation)
            local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                    expectedLocation,
                    nil,
                    self.ability.trailWidth,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            local damage = self.ability.damage * Units:GetHeroStrength(self.caster)
            for _, enemy in pairs(enemies) do
                if (not TableContains(self.damagedEnemies, enemy)) then
                    local damageTable = {}
                    damageTable.caster = self.caster
                    damageTable.target = enemy
                    damageTable.ability = self.ability
                    damageTable.damage = damage
                    damageTable.firedmg = true
                    damageTable.aoe = true
                    GameMode:DamageUnit(damageTable)
                    table.insert(self.damagedEnemies, enemy)
                end
            end
        else
            self:Destroy()
        end
    end
end

LinkedModifiers["modifier_blazing_berserker_flame_dash_motion"] = LUA_MODIFIER_MOTION_HORIZONTAL

blazing_berserker_flame_dash = class({})

function blazing_berserker_flame_dash:OnPostTakeDamage(damageTable)
    local ability = damageTable.attacker:FindAbilityByName("blazing_berserker_flame_dash")
    if (ability and damageTable.ability and damageTable.ability == ability and ability.fireResistanceReductionDuration and ability.fireResistanceReductionDuration > 0) then
        local modifierTable = {}
        modifierTable.ability = ability
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_blazing_berserker_flame_dash_debuff"
        modifierTable.duration = ability.fireResistanceReductionDuration
        GameMode:ApplyDebuff(modifierTable)
    end
end

function blazing_berserker_flame_dash:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.dashSpeed = self:GetSpecialValueFor("dash_speed")
    self.dashRange = self:GetSpecialValueFor("dash_range")
    self.trailWidth = self:GetSpecialValueFor("trail_width")
    self.trailDamage = self:GetSpecialValueFor("trail_damage") / 100
    self.trailTick = self:GetSpecialValueFor("trail_tick")
    self.trailDuration = self:GetSpecialValueFor("trail_duration")
    self.fireResistanceReduction = self:GetSpecialValueFor("fire_resistance_reduction") / 100
    self.fireResistanceReductionDuration = self:GetSpecialValueFor("fire_resistance_reduction_duration")
    self.charges = self:GetSpecialValueFor("charges")
    if (self.charges > 0 and not self.chargesModifier) then
        local caster = self:GetCaster()
        self.chargesModifier = caster:AddNewModifier(caster, self, "modifier_charges", {
            max_count = self.charges,
            start_count = self.charges,
            replenish_time = self:GetCooldown(self:GetLevel())
        })
    end
end

function blazing_berserker_flame_dash:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local location = caster:GetAbsOrigin()
    local vector = (self:GetCursorPosition() - location):Normalized()
    caster:SetForwardVector(vector)
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_blazing_berserker_flame_dash_motion"
    modifierTable.duration = -1
    GameMode:ApplyBuff(modifierTable)
    EmitSoundOn("Hero_Mars.Spear.Cast", caster)
end

-- blazing_berserker_fire_frenzy
modifier_blazing_berserker_fire_frenzy_buff = class({
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
    GetEffectName = function()
        return "particles/units/blazing_berserker/fire_frenzy/fire_frenzy_buff.vpcf"
    end,
    DeclareFunctions = function()
        return {
            MODIFIER_PROPERTY_MIN_HEALTH
        }
    end,
    GetMinHealth = function()
        return 1
    end
})

function modifier_blazing_berserker_fire_frenzy_buff:GetStatusEffectName()
    return "particles/status_fx/status_effect_snapfire_magma.vpcf"
end

function modifier_blazing_berserker_fire_frenzy_buff:StatusEffectPriority()
    return 15
end

function modifier_blazing_berserker_fire_frenzy_buff:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.damage = 0
end

function modifier_blazing_berserker_fire_frenzy_buff:OnDestroy()
    if not IsServer() then
        return
    end
    if (self.ability.endHealing > 0) then
        local healTable = {}
        healTable.caster = self.caster
        healTable.target = self.caster
        healTable.ability = self.ability
        healTable.heal = self.damage * self.ability.endHealing
        GameMode:HealUnit(healTable)
    end
end

function modifier_blazing_berserker_fire_frenzy_buff:OnPostTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_blazing_berserker_fire_frenzy_buff")
    if (modifier and modifier.ability and modifier.ability.endHealing and modifier.ability.endHealing > 0) then
        modifier.damage = modifier.damage + damageTable.damage
    end
end

LinkedModifiers["modifier_blazing_berserker_fire_frenzy_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_blazing_berserker_fire_frenzy = class({
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

function modifier_blazing_berserker_fire_frenzy:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.casterTeam = self.caster:GetTeamNumber()
    self:StartIntervalThink(self.ability:GetSpecialValueFor("incineration_souls_tick"))
end

function modifier_blazing_berserker_fire_frenzy:OnIntervalThink()
    if (not (self.ability.incinerationSoulsRadius > 0) or not self.ability.incinerationSoulsAbility or self.ability.incinerationSoulsAbility:GetLevel() == 0) then
        return
    end
    local enemies = FindUnitsInRadius(self.casterTeam,
            self.caster:GetAbsOrigin(),
            nil,
            self.ability.incinerationSoulsRadius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        if (not enemy:HasModifier("modifier_blazing_berserker_incinerating_souls_dot")) then
            local cooldownRemaining = self.ability.incinerationSoulsAbility:GetCooldownTimeRemaining()
            self.ability.incinerationSoulsAbility:EndCooldown()
            self.caster:SetCursorCastTarget(enemy)
            self.ability.incinerationSoulsAbility:OnSpellStart()
            self.ability.incinerationSoulsAbility:StartCooldown(cooldownRemaining)
            return
        end
    end
end

function modifier_blazing_berserker_fire_frenzy:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_blazing_berserker_fire_frenzy")
    if (modifier and modifier.ability and modifier.ability.autoUse and modifier.ability.autoUse > 0 and modifier.ability:IsCooldownReady()) then
        local healthAfterDamage = damageTable.victim:GetHealth() - damageTable.damage
        if (healthAfterDamage < 1) then
            modifier.ability:OnSpellStart()
            modifier.ability:UseResources(false, false, true)
        end
    end
    return damageTable
end

LinkedModifiers["modifier_blazing_berserker_fire_frenzy"] = LUA_MODIFIER_MOTION_NONE

blazing_berserker_fire_frenzy = class({
    GetIntrinsicModifierName = function()
        return "modifier_blazing_berserker_fire_frenzy"
    end
})

function blazing_berserker_fire_frenzy:OnUpgrade()
    self.duration = self:GetSpecialValueFor("duration")
    self.endHealing = self:GetSpecialValueFor("end_healing") / 100
    self.autoUse = self:GetSpecialValueFor("auto_use")
    self.incinerationSoulsRadius = self:GetSpecialValueFor("incineration_souls_radius")
    if (not self.incinerationSoulsAbility) then
        self.incinerationSoulsAbility = self:GetCaster():FindAbilityByName("blazing_berserker_incinerating_souls")
    end
end

function blazing_berserker_fire_frenzy:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_blazing_berserker_fire_frenzy_buff"
    modifierTable.duration = self.duration
    local modifier = GameMode:ApplyBuff(modifierTable)
    modifier:SetDuration(self.duration, true)
    EmitSoundOn("Hero_Axe.Berserkers_Call", caster)
    local pidx = ParticleManager:CreateParticle("particles/units/blazing_berserker/fire_frenzy/fire_frenzy_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(pidx)
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_blazing_berserker", MotionController)
end

if (IsServer() and not GameMode.BLAZING_BERSERKER_INIT) then
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(blazing_berserker_flame_dash, 'OnPostTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_blazing_berserker_boiling_rage, 'OnTakeDamage'), true)
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_blazing_berserker_fire_frenzy_buff, 'OnPostTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_blazing_berserker_fire_frenzy, 'OnTakeDamage'))
    GameMode:RegisterMinimumAbilityCooldown('blazing_berserker_fire_frenzy', 30)
    GameMode.BLAZING_BERSERKER_INIT = true
end
