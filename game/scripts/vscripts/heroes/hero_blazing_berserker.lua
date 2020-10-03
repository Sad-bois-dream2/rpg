local LinkedModifiers = {}

-- blazing_berserker_molten_strike modifiers
modifier_blazing_berserker_molten_strike = class({
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
        return blazing_berserker_molten_strike:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/blazing_berserker/molten_strike/molten_strike.vpcf"
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_blazing_berserker_molten_strike:OnAttackLanded(kv)
    if (not IsServer()) then
        return
    end
    local attacker = kv.attacker
    local target = kv.target
    if (attacker ~= nil and target ~= nil and attacker ~= target and attacker == self.owner) then
        local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                target:GetAbsOrigin(),
                nil,
                self.radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        local pidx = ParticleManager:CreateParticle("particles/units/blazing_berserker/molten_strike/molten_strike_impact.vpcf", PATTACH_ABSORIGIN, target)
        Timers:CreateTimer(2.0, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
        local damage = self.damage * Units:GetAttackDamage(self.owner)
        for _, enemy in pairs(enemies) do
            local damageTable = {}
            damageTable.caster = self.owner
            damageTable.target = enemy
            damageTable.ability = self.ability
            damageTable.damage = damage
            damageTable.firedmg = true
            GameMode:DamageUnit(damageTable)
        end
    end
end

function modifier_blazing_berserker_molten_strike:OnCreated()
    if (not IsServer()) then
        return
    end
    self.owner = self:GetParent()
    self.ability = self:GetAbility()
    self.fire_dmg = self.ability:GetSpecialValueFor("fire_dmg") / 100
    self.damage = self.ability:GetSpecialValueFor("damage") / 100
    self.radius = self.ability:GetSpecialValueFor("radius")
end

function modifier_blazing_berserker_molten_strike:GetFireDamageBonus()
    return self.fire_dmg or 0
end

LinkedModifiers["modifier_blazing_berserker_molten_strike"] = LUA_MODIFIER_MOTION_NONE

-- blazing_berserker_molten_strike
blazing_berserker_molten_strike = class({
    GetAbilityTextureName = function(self)
        return "blazing_berserker_molten_strike"
    end
})

function blazing_berserker_molten_strike:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_blazing_berserker_molten_strike"
    modifierTable.duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyBuff(modifierTable)
end
-- blazing_berserker_incinerating_souls modifiers
modifier_blazing_berserker_incinerating_souls = class({
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
    GetTexture = function(self)
        return blazing_berserker_incinerating_souls:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/blazing_berserker/incinerating_souls/incinerating_souls.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end
})

function modifier_blazing_berserker_incinerating_souls:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self.ms_slow = self.ability:GetSpecialValueFor("ms_slow") * -0.01
    self.damage = self.ability:GetSpecialValueFor("damage") / 100
    local tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
end

function modifier_blazing_berserker_incinerating_souls:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local damageTable = {}
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.damage = self.damage * Units:GetAttackDamage(self.caster)
    damageTable.firedmg = true
    GameMode:DamageUnit(damageTable)
end

function modifier_blazing_berserker_incinerating_souls:GetMoveSpeedPercentBonus()
    return self.ms_slow or 0
end

LinkedModifiers["modifier_blazing_berserker_incinerating_souls"] = LUA_MODIFIER_MOTION_NONE

-- blazing_berserker_incinerating_souls
blazing_berserker_incinerating_souls = class({
    GetAbilityTextureName = function(self)
        return "blazing_berserker_incinerating_souls"
    end
})

function blazing_berserker_incinerating_souls:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = self:GetCursorTarget()
    modifierTable.caster = self:GetCaster()
    modifierTable.modifier_name = "modifier_blazing_berserker_incinerating_souls"
    modifierTable.duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyDebuff(modifierTable)
end

-- blazing_berserker_battle_hunger modifiers
modifier_blazing_berserker_battle_hunger = class({
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
        return blazing_berserker_battle_hunger:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/blazing_berserker/battle_hunger/battle_hunger.vpcf"
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end,
})

function modifier_blazing_berserker_battle_hunger:OnAttackLanded(kv)
    if (not IsServer()) then
        return
    end
    if (self.ability:GetLevel() < 4) then
        return
    end
    local attacker = kv.attacker
    local target = kv.target
    if (attacker ~= nil and target ~= nil and attacker ~= target and attacker == self.caster and RollPercentage(self.stun_chance)) then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.target = target
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_stunned"
        modifierTable.duration = self.stun_duration
        GameMode:ApplyDebuff(modifierTable)
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = target
        damageTable.ability = self.ability
        damageTable.damage = self.stun_bonusdmg * Units:GetAttackDamage(self.caster)
        damageTable.firedmg = true
        GameMode:DamageUnit(damageTable)
    end
end

function modifier_blazing_berserker_battle_hunger:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.primary = self.ability:GetSpecialValueFor("primary") / 100
    self.stun_chance = self.ability:GetSpecialValueFor("stun_chance")
    self.stun_bonusdmg = self.ability:GetSpecialValueFor("stun_bonusdmg") / 100
    self.stun_duration = self.ability:GetSpecialValueFor("stun_duration")
    self.mana = self.ability:GetSpecialValueFor("mana") / 100
    local tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
end

function modifier_blazing_berserker_battle_hunger:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local mana = self.caster:GetMana() - (self.caster:GetMaxMana() * self.mana)
    if (mana < 0) then
        self.ability:ToggleAbility()
        self:Destroy()
    end
    self.caster:SetMana(math.max(0, mana))
end

function modifier_blazing_berserker_battle_hunger:GetPrimaryAttributePercentBonus()
    return self.primary or 0
end

LinkedModifiers["modifier_blazing_berserker_battle_hunger"] = LUA_MODIFIER_MOTION_NONE

-- blazing_berserker_battle_hunger
blazing_berserker_battle_hunger = class({
    GetAbilityTextureName = function(self)
        return "blazing_berserker_battle_hunger"
    end
})

function blazing_berserker_battle_hunger:OnToggle(unit, special_cast)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    caster.blazing_berserker_battle_hunger = caster.blazing_berserker_battle_hunger or {}
    if (self:GetToggleState()) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_blazing_berserker_battle_hunger"
        modifierTable.duration = -1
        caster.blazing_berserker_battle_hunger.modifier = GameMode:ApplyBuff(modifierTable)
        self:EndCooldown()
        self:StartCooldown(self:GetCooldown(1))
        EmitSoundOn("Hero_Axe.Berserkers_Call", caster)
    else
        if (caster.blazing_berserker_battle_hunger.modifier ~= nil) then
            caster.blazing_berserker_battle_hunger.modifier:Destroy()
        end
    end
end
-- blazing_berserker_rage_eruption modifiers
modiifer_blazing_berserker_rage_eruption_buff = class({
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
        return blazing_berserker_rage_eruption:GetAbilityTextureName()
    end
})

function modiifer_blazing_berserker_rage_eruption_buff:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    self.aaspeed = keys.aaspeed or 0
end

function modiifer_blazing_berserker_rage_eruption_buff:GetAttackSpeedBonus()
    return (self.aaspeed * self:GetStackCount()) or 0
end

LinkedModifiers["modiifer_blazing_berserker_rage_eruption_buff"] = LUA_MODIFIER_MOTION_NONE

modiifer_blazing_berserker_rage_eruption = class({
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

function modiifer_blazing_berserker_rage_eruption:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.aaspeed = self.ability:GetSpecialValueFor("aaspeed")
    self.maxstacks = self.ability:GetSpecialValueFor("maxstacks")
    self.proc_chance = self.ability:GetSpecialValueFor("proc_chance")
    self.duration = self.ability:GetSpecialValueFor("duration")
end

function modiifer_blazing_berserker_rage_eruption:OnPostTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modiifer_blazing_berserker_rage_eruption")
    if (modifier) then
        local modifierTable = {}
        modifierTable.ability = modifier.ability
        modifierTable.target = modifier.caster
        modifierTable.caster = modifier.caster
        modifierTable.modifier_name = "modiifer_blazing_berserker_rage_eruption_buff"
        modifierTable.duration = modifier.duration
        modifierTable.stacks = 1
        modifierTable.max_stacks = modifier.maxstacks
        GameMode:ApplyStackingBuff(modifierTable)
        local ability = modifier.caster:FindAbilityByName("blazing_berserker_incinerating_souls")
        if (RollPercentage(modifier.proc_chance) and ability and ability:GetLevel() > 0) then
            local cd = ability:GetCooldownTimeRemaining()
            ability:EndCooldown()
            modifier.caster:SetCursorCastTarget(damageTable.attacker)
            ability:OnSpellStart()
            ability:StartCooldown(cd)
        end
    end
end

LinkedModifiers["modiifer_blazing_berserker_rage_eruption"] = LUA_MODIFIER_MOTION_NONE

-- blazing_berserker_rage_eruption
blazing_berserker_rage_eruption = class({
    GetAbilityTextureName = function(self)
        return "blazing_berserker_rage_eruption"
    end,
    GetIntrinsicModifierName = function(self)
        return "modiifer_blazing_berserker_rage_eruption"
    end
})

-- blazing_berserker_rage_eruption modifiers
modifier_blazing_berserker_furious_stance = class({
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
        return blazing_berserker_furious_stance:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/blazing_berserker/furious_stance/furious_stance.vpcf"
    end
})

function modifier_blazing_berserker_furious_stance:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.damage = self.ability:GetSpecialValueFor("damage") / 100
    self.armor_reduction = self.ability:GetSpecialValueFor("armor_reduction") * -0.01
    self.elemental_reduction = self.ability:GetSpecialValueFor("elemental_reduction") * -0.01
    self.aadamage = self.ability:GetSpecialValueFor("aadamage") / 100
    self.aaspeed = self.ability:GetSpecialValueFor("aaspeed") / 100
    self.firedmg = self.ability:GetSpecialValueFor("firedmg") / 100
    local tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
end

function modifier_blazing_berserker_furious_stance:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local casterHealth = self.caster:GetHealth() - (self.caster:GetMaxHealth() * self.damage)
    if (casterHealth < 1) then
        casterHealth = 1
    end
    self.caster:SetHealth(casterHealth)
end

function modifier_blazing_berserker_furious_stance:GetAttackDamagePercentBonus()
    return self.aadamage or 0
end

function modifier_blazing_berserker_furious_stance:GetAttackSpeedPercentBonus()
    return self.aaspeed or 0
end

function modifier_blazing_berserker_furious_stance:GetArmorPercentBonus()
    return self.armor_reduction or 0
end

function modifier_blazing_berserker_furious_stance:GetFireProtectionBonus()
    return self.elemental_reduction or 0
end

function modifier_blazing_berserker_furious_stance:GetFrostProtectionBonus()
    return self.elemental_reduction or 0
end

function modifier_blazing_berserker_furious_stance:GetEarthProtectionBonus()
    return self.elemental_reduction or 0
end

function modifier_blazing_berserker_furious_stance:GetVoidProtectionBonus()
    return self.elemental_reduction or 0
end

function modifier_blazing_berserker_furious_stance:GetHolyProtectionBonus()
    return self.elemental_reduction or 0
end

function modifier_blazing_berserker_furious_stance:GetNatureProtectionBonus()
    return self.elemental_reduction or 0
end

function modifier_blazing_berserker_furious_stance:GetInfernoProtectionBonus()
    return self.elemental_reduction or 0
end

function modifier_blazing_berserker_furious_stance:GetFireDamageBonus()
    return self.firedmg or 0
end

LinkedModifiers["modifier_blazing_berserker_furious_stance"] = LUA_MODIFIER_MOTION_NONE

-- blazing_berserker_furious_stance
blazing_berserker_furious_stance = class({
    GetAbilityTextureName = function(self)
        return "blazing_berserker_furious_stance"
    end
})

function blazing_berserker_furious_stance:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.caster = self:GetCaster()
    modifierTable.target = modifierTable.caster
    modifierTable.modifier_name = "modifier_blazing_berserker_furious_stance"
    modifierTable.duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyBuff(modifierTable)
    EmitSoundOn("Hero_Axe.Berserkers_Call", modifierTable.caster)
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
    if(self.localTick >= self.ability.spinTick) then
        self.ability:PerformSpin()
        self.localTick = 0
    end
    self.animationTick = self.animationTick + self.tick
    if(self.animationTick >= self.ability.animationDuration) then
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
    GetAbilityTextureName = function(self)
        return "blazing_berserker_fission"
    end,
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

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_blazing_berserker", MotionController)
end

if (IsServer() and not GameMode.BLAZING_BERSERKER_INIT) then
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modiifer_blazing_berserker_rage_eruption, 'OnPostTakeDamage'))
    GameMode.BLAZING_BERSERKER_INIT = true
end
