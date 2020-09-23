local LinkedModifiers = {}

--DANCE OF DARKNESS--
modifier_abyssal_stalker_dance_of_darkness = class({
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
    DeclareFunctions = function(self)
        return
        {
            MODIFIER_EVENT_ON_ATTACK_LANDED
        }
    end
})

function modifier_abyssal_stalker_dance_of_darkness:OnCreated(kv)
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_abyssal_stalker_dance_of_darkness:OnAttackLanded(kv)
    if (not IsServer()) then
        return
    end
    local attacker = kv.attacker
    local target = kv.target
    if (attacker and target and not target:IsNull() and attacker == self.caster) then
        local activeModifier = attacker:FindModifierByName("modifier_abyssal_stalker_dance_of_darkness_buff")
        local proc
        if (activeModifier) then
            proc = RollPercentage(self.ability.chanceActive)
        else
            proc = RollPercentage(self.ability.chance)
        end
        if (proc) then
            local modifierTable = {}
            modifierTable.ability = self.ability
            modifierTable.caster = self.caster
            modifierTable.target = self.caster
            modifierTable.modifier_name = "modifier_abyssal_stalker_dance_of_darkness_agi"
            modifierTable.duration = self.ability.stackDuration
            modifierTable.stacks = 1
            modifierTable.max_stacks = self.ability.maxStacks
            GameMode:ApplyStackingBuff(modifierTable)
            if (self.ability.dotDuration > 0) then
                local modifierTable = {}
                modifierTable.caster = self.caster
                modifierTable.target = target
                modifierTable.ability = self.ability
                modifierTable.modifier_name = "modifier_abyssal_stalker_dance_of_darkness_dot"
                modifierTable.duration = self.ability.dotDuration
                modifierTable.max_stacks = self.ability.dotMaxStacks
                modifierTable.stacks = 1
                GameMode:ApplyStackingDebuff(modifierTable)
            end
        end
        local additonalAAProcChance = RollPercentage(self.ability.strikeChance)
        if (additonalAAProcChance and not self.ability.strikeCD) then
            self.caster:PerformAttack(target, false, true, true, false, false, false, false)
            self.ability.strikeCD = true
            local ability = self.ability
            Timers:CreateTimer(self.ability.strikeCooldown, function()
                ability.strikeCD = nil
            end)
        end
    end
end

LinkedModifiers["modifier_abyssal_stalker_dance_of_darkness"] = LUA_MODIFIER_MOTION_NONE

modifier_abyssal_stalker_dance_of_darkness_buff = class({
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

LinkedModifiers["modifier_abyssal_stalker_dance_of_darkness_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_abyssal_stalker_dance_of_darkness_dot = class({
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

function modifier_abyssal_stalker_dance_of_darkness_dot:OnCreated(kv)
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self:StartIntervalThink(self.ability.dotTick)
end

function modifier_abyssal_stalker_dance_of_darkness_dot:OnIntervalThink()
    if not IsServer() then
        return
    end
    local damage = Units:GetAttackDamage(self.caster) * self.ability.dotDamage * self:GetStackCount()
    local damageTable = {}
    damageTable.damage = damage
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.voiddmg = true
    GameMode:DamageUnit(damageTable)
end

LinkedModifiers["modifier_abyssal_stalker_dance_of_darkness_dot"] = LUA_MODIFIER_MOTION_NONE

modifier_abyssal_stalker_dance_of_darkness_agi = class({
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
            MODIFIER_PROPERTY_TOOLTIP,
            MODIFIER_PROPERTY_TOOLTIP2
        }
    end
})

function modifier_abyssal_stalker_dance_of_darkness_agi:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
end

function modifier_abyssal_stalker_dance_of_darkness_agi:GetAttackSpeedPercentBonus()
    return self:GetStackCount() * self.ability.attackSpeedPerStack
end

function modifier_abyssal_stalker_dance_of_darkness_agi:GetAttackDamageBonus()
    return self:GetStackCount() * self.ability.aaSpeedToAADmgPerStack * Units:GetAttackSpeed(self.caster)
end

LinkedModifiers["modifier_abyssal_stalker_dance_of_darkness_agi"] = LUA_MODIFIER_MOTION_NONE

abyssal_stalker_dance_of_darkness = class({
    GetAbilityTextureName = function(self)
        return "abyssal_stalker_dance_of_darkness"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_abyssal_stalker_dance_of_darkness"
    end
})

function abyssal_stalker_dance_of_darkness:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.duration = self:GetSpecialValueFor("duration")
    self.chance = self:GetSpecialValueFor("chance")
    self.chanceActive = self:GetSpecialValueFor("chance_active")
    self.attackSpeedPerStack = self:GetSpecialValueFor("aa_speed_per_stack") / 100
    self.maxStacks = self:GetSpecialValueFor("max_stacks")
    self.stackDuration = self:GetSpecialValueFor("stack_duration")
    self.strikeChance = self:GetSpecialValueFor("bonus_aa_chance")
    self.strikeCooldown = self:GetSpecialValueFor("bonus_aa_chance_cooldown")
    self.dotDamage = self:GetSpecialValueFor("dot_damage") / 100
    self.dotTick = self:GetSpecialValueFor("dot_tick")
    self.dotMaxStacks = self:GetSpecialValueFor("dot_max_stacks")
    self.dotDuration = self:GetSpecialValueFor("dot_duration")
    self.aaSpeedToAADmgPerStack = self:GetSpecialValueFor("aa_speed_to_aa_dmg_per_stack") / 100
end

function abyssal_stalker_dance_of_darkness:OnSpellStart()
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_abyssal_stalker_dance_of_darkness_buff"
    modifierTable.duration = self.duration
    GameMode:ApplyBuff(modifierTable)
end

--SHADOW RUSH--
modifier_abyssal_stalker_shadow_rush_buff = class({
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
            MODIFIER_PROPERTY_TOOLTIP,
            MODIFIER_PROPERTY_TOOLTIP2
        }
    end
})

function modifier_abyssal_stalker_shadow_rush_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_abyssal_stalker_shadow_rush_buff:GetVoidDamageBonus()
    return self:GetStackCount() * self.ability.voidDmgPerStack
end

function modifier_abyssal_stalker_shadow_rush_buff:GetAttackSpeedBonus()
    return self:GetStackCount() * self.ability.aaSpeedPerStack
end

function modifier_abyssal_stalker_shadow_rush_buff:OnTooltip()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("void_dmg_per_stack")
end

function modifier_abyssal_stalker_shadow_rush_buff:OnTooltip2()
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("aa_speed_per_stack")
end

LinkedModifiers["modifier_abyssal_stalker_shadow_rush_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_abyssal_stalker_shadow_rush_shadows = class({
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
    end,
    GetTexture = function(self)
        return abyssal_stalker_shadow_rush:GetAbilityTextureName()
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_abyssal_stalker_shadow_rush_shadows:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
end

function modifier_abyssal_stalker_shadow_rush_shadows:OnAttackLanded(kv)
    if not IsServer() then
        return
    end
    local attacker = kv.attacker
    local target = kv.target
    if (attacker and target and not target:IsNull() and attacker == self.caster) then
        local newStacks = math.min(self:GetStackCount() + 1, self.ability.maxShadows)
        self:SetStackCount(newStacks)
    end
end

LinkedModifiers["modifier_abyssal_stalker_shadow_rush_shadows"] = LUA_MODIFIER_MOTION_NONE

abyssal_stalker_shadow_rush = class({
    GetAbilityTextureName = function(self)
        return "abyssal_stalker_shadow_rush"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_abyssal_stalker_shadow_rush_shadows"
    end
})

function abyssal_stalker_shadow_rush:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.maxShadows = self:GetSpecialValueFor("shadows")
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.instances = self:GetSpecialValueFor("instance")
    self.voidDmgPerStack = self:GetSpecialValueFor("void_dmg_per_stack") / 100
    self.aaSpeedPerStack = self:GetSpecialValueFor("aa_speed_per_stack")
    self.stacksPerStrike = self:GetSpecialValueFor("stacks_per_strike")
    self.maxStacks = self:GetSpecialValueFor("max_stacks")
    self.stacksDuration = self:GetSpecialValueFor("stacks_duration")
    self.procChancePerStack = self:GetSpecialValueFor("proc_chance_per_stack")
    if (not self.shadowsModifier) then
        self.shadowsModifier = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
    end
end

function abyssal_stalker_shadow_rush:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local blinkStartPos = caster:GetAbsOrigin()
    local blink = ParticleManager:CreateParticle("particles/units/abyssal_stalker/shadow_rush/shadow_rush.vpcf", PATTACH_ABSORIGIN, caster)
    local targetPos = target:GetAbsOrigin()
    FindClearSpaceForUnit(caster, targetPos, true)
    ParticleManager:SetParticleControl(blink, 0, blinkStartPos)
    local blinkEndPos = caster:GetAbsOrigin()
    ParticleManager:SetParticleControl(blink, 1, blinkEndPos)
    ParticleManager:SetParticleControl(blink, 2, blinkEndPos)
    ParticleManager:SetParticleControl(blink, 3, blinkEndPos)
    ParticleManager:SetParticleControl(blink, 4, targetPos)
    ParticleManager:ReleaseParticleIndex(blink)
    Timers:CreateTimer(1, function()
        ParticleManager:DestroyParticle(blink, false)
        ParticleManager:ReleaseParticleIndex(blink)
    end)
    self.target = target
    EmitSoundOn("Hero_PhantomAssassin.Strike.Start", caster)
    local totalShadows = self.shadowsModifier:GetStackCount()
    local strikes = math.min(self.instances, totalShadows)
    if (strikes > 0) then
        local executionerModifier = caster:FindModifierByName("modifier_abyssal_stalker_shadow_rush_buff")
        if (not (executionerModifier and self.procChancePerStack > 0 and RollPercentage(self.procChancePerStack * executionerModifier:GetStackCount()))) then
            self.shadowsModifier:SetStackCount(math.min(0, totalShadows - strikes))
        end
    else
        return
    end
    local damage = Units:GetAttackDamage(caster) * self.damage
    while strikes > 0 do
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.voiddmg = true
        GameMode:DamageUnit(damageTable)
        if (self.stacksPerStrike > 0) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = caster
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_abyssal_stalker_shadow_rush_buff"
            modifierTable.duration = self.stacksDuration
            modifierTable.stacks = self.stacksPerStrike
            modifierTable.max_stacks = self.maxStacks
            GameMode:ApplyStackingBuff(modifierTable)
        end
        strikes = strikes - 1
    end
end

--ABYSSAL STRIKE--
modifier_abyssal_stalker_blade_of_abyss_cdr = class({
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
})

function modifier_abyssal_stalker_blade_of_abyss_cdr:OnCreated(kv)
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.abilityName = self.ability:GetAbilityName()
    self:OnIntervalThink()
    self:StartIntervalThink(1.0)
end

function modifier_abyssal_stalker_blade_of_abyss_cdr:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local cooldownTable = {
        target = self.ability,
        ability = self.abilityName,
        reduction = self.ability.voidDustProcCdrFlat,
        isflat = true
    }
    GameMode:ReduceAbilityCooldown(cooldownTable)
end

LinkedModifiers["modifier_abyssal_stalker_blade_of_abyss_cdr"] = LUA_MODIFIER_MOTION_NON

modifier_abyssal_stalker_blade_of_abyss = class({
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
        return {
            MODIFIER_EVENT_ON_ABILITY_START
        }
    end,
})

function modifier_abyssal_stalker_blade_of_abyss:OnCreated(kv)
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.voidDustAbility = self.caster:FindAbilityByName("abyssal_stalker_void_dust")
end

function modifier_abyssal_stalker_blade_of_abyss:OnAbilityStart(keys)
    if (not IsServer()) then
        return
    end
    local ability = keys.ability
    if (keys.unit == self.caster and ability == self.voidDustAbility) then
        local modifierTable = {}
        modifierTable.caster = self.caster
        modifierTable.ability = self.ability
        modifierTable.target = self.caster
        modifierTable.modifier_name = "modifier_abyssal_stalker_blade_of_abyss_cdr"
        modifierTable.duration = self.ability.voidDustProcCdrFlatDuration
        GameMode:ApplyBuff(modifierTable)
    end
end

LinkedModifiers["modifier_abyssal_stalker_blade_of_abyss"] = LUA_MODIFIER_MOTION_NONE

modifier_abyssal_stalker_blade_of_abyss_crit = class({
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

function modifier_abyssal_stalker_blade_of_abyss_crit:OnCreated(kv)
    if (not IsServer()) then
        return
    end
    self.critMulti = kv.critMulti or 1
end

function modifier_abyssal_stalker_blade_of_abyss_crit:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_abyssal_stalker_blade_of_abyss_crit")
    if (modifier and damageTable.damage > 0 and modifier.critMulti and modifier.critMulti > 1) then
        damageTable.crit = modifier.ability.crit
        local victimPos = damageTable.victim:GetAbsOrigin()
        local coup_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, damageTable.victim)
        ParticleManager:SetParticleControlEnt(coup_pfx, 0, damageTable.victim, PATTACH_POINT_FOLLOW, "attach_hitloc", victimPos, true)
        ParticleManager:SetParticleControl(coup_pfx, 1, victimPos)
        ParticleManager:SetParticleControlOrientation(coup_pfx, 1, damageTable.attacker:GetForwardVector() * -1, damageTable.attacker:GetRightVector(), damageTable.attacker:GetUpVector())
        Timers:CreateTimer(1, function()
            ParticleManager:DestroyParticle(coup_pfx, false)
            ParticleManager:ReleaseParticleIndex(coup_pfx)
        end)
        EmitSoundOn("Hero_PhantomAssassin.CoupDeGrace", damageTable.victim)
        return damageTable
    end
end

LinkedModifiers["modifier_abyssal_stalker_blade_of_abyss_crit"] = LUA_MODIFIER_MOTION_NONE

modifier_abyssal_stalker_blade_of_abyss_sneaking = class({
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
        return "particles/units/abyssal_stalker/blade_of_abyss/blade_of_abyss_buff.vpcf"
    end,
    DeclareFunctions = function(self)
        return {
            MODIFIER_PROPERTY_INVISIBILITY_LEVEL
        }
    end,
    CheckState = function(self)
        return {
            [MODIFIER_STATE_INVISIBLE] = true
        }
    end,
    GetModifierInvisibilityLevel = function(self)
        return 1
    end
})

function modifier_abyssal_stalker_blade_of_abyss_sneaking:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_abyssal_stalker_blade_of_abyss_sneaking:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_abyssal_stalker_blade_of_abyss_sneaking")
    if (modifier and damageTable.damage > 0 and modifier.ability) then
        local attackerForwardVector = damageTable.attacker:GetForwardVector()
        local backstab = ((damageTable.victim:GetForwardVector():Dot(attackerForwardVector)) >= 0)
        if (modifier.ability.silenceDuration > 0) then
            local modifierTable = {}
            modifierTable.caster = damageTable.attacker
            modifierTable.ability = modifier.ability
            modifierTable.target = damageTable.victim
            modifierTable.modifier_name = "modifier_silence"
            modifierTable.duration = modifier.ability.silenceDuration
            GameMode:ApplyDebuff(modifierTable)
        end
        if (modifier.ability.critDuration > 0) then
            local critMulti = 1
            if (backstab) then
                critMulti = modifier.ability.critBack * modifier.ability.critMultiplier
            else
                critMulti = modifier.ability.crit * modifier.ability.critMultiplier
            end
            local modifierTable = {}
            modifierTable.caster = damageTable.attacker
            modifierTable.ability = modifier.ability
            modifierTable.target = damageTable.attacker
            modifierTable.modifier_name = "modifier_abyssal_stalker_blade_of_abyss_crit"
            modifierTable.duration = modifier.ability.critDuration
            modifierTable.modifier_params = {
                critMulti = critMulti
            }
            GameMode:ApplyBuff(modifierTable)
        else
            if (backstab) then
                damageTable.crit = modifier.ability.critBack
            else
                damageTable.crit = modifier.ability.crit
            end
            local victimPos = damageTable.victim:GetAbsOrigin()
            local coup_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, damageTable.victim)
            ParticleManager:SetParticleControlEnt(coup_pfx, 0, damageTable.victim, PATTACH_POINT_FOLLOW, "attach_hitloc", victimPos, true)
            ParticleManager:SetParticleControl(coup_pfx, 1, victimPos)
            ParticleManager:SetParticleControlOrientation(coup_pfx, 1, attackerForwardVector * -1, damageTable.attacker:GetRightVector(), damageTable.attacker:GetUpVector())
            Timers:CreateTimer(1, function()
                ParticleManager:DestroyParticle(coup_pfx, false)
                ParticleManager:ReleaseParticleIndex(coup_pfx)
            end)
            EmitSoundOn("Hero_PhantomAssassin.CoupDeGrace", damageTable.victim)
        end
        modifier:Destroy()
        return damageTable
    end
end

LinkedModifiers["modifier_abyssal_stalker_blade_of_abyss_sneaking"] = LUA_MODIFIER_MOTION_NONE

abyssal_stalker_blade_of_abyss = class({
    GetAbilityTextureName = function(self)
        return "abyssal_stalker_blade_of_abyss"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_abyssal_stalker_blade_of_abyss"
    end
})

function abyssal_stalker_blade_of_abyss:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.duration = self:GetSpecialValueFor("duration")
    self.crit = self:GetSpecialValueFor("damage") / 100
    self.critBack = self:GetSpecialValueFor("backstab_damage") / 100
    self.silenceDuration = self:GetSpecialValueFor("silence_duration")
    self.critDuration = self:GetSpecialValueFor("crit_duration")
    self.critMultiplier = self:GetSpecialValueFor("crit_multiplier")
    self.voidDustProcCdrFlat = self:GetSpecialValueFor("void_dust_proc_cdr_flat")
    self.voidDustProcCdrFlatDuration = self:GetSpecialValueFor("void_dust_proc_cdr_flat_duration")
end

function abyssal_stalker_blade_of_abyss:OnSpellStart()
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.caster = caster
    modifierTable.target = caster
    modifierTable.ability = self
    modifierTable.modifier_name = "modifier_abyssal_stalker_blade_of_abyss_sneaking"
    modifierTable.duration = self.duration
    GameMode:ApplyBuff(modifierTable)
    local particle = ParticleManager:CreateParticle("particles/units/abyssal_stalker/blade_of_abyss/blade_of_abyss.vpcf", PATTACH_ABSORIGIN, modifierTable.caster)
    local casterPos = modifierTable.caster:GetAbsOrigin()
    ParticleManager:SetParticleControl(particle, 1, casterPos)
    ParticleManager:SetParticleControl(particle, 2, casterPos)
    ParticleManager:SetParticleControl(particle, 3, casterPos)
    ParticleManager:SetParticleControl(particle, 4, casterPos)
    Timers:CreateTimer(1, function()
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end)
    EmitSoundOn("Hero_PhantomAssassin.Blur", modifierTable.caster)
end

--VOID DUST--
modifier_abyssal_stalker_void_dust_buff = class({
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
        return abyssal_stalker_void_dust:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/abyssal_stalker/void_dust/void_dust_buff.vpcf"
    end
})

modifier_abyssal_stalker_void_dust_debuff = class({
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
        return "particles/units/abyssal_stalker/void_dust/void_dust.vpcf"
    end,
    GetStatusEffectName = function(self)
        return "particles/units/abyssal_stalker/void_dust/status_fx/status_effect_void_dust.vpcf"
    end,
    StatusEffectPriority = function(self)
        return 5
    end
})

function modifier_abyssal_stalker_void_dust_buff:GetStatusEffectName()
    return "particles/units/abyssal_stalker/void_dust/status_fx/status_effect_void_dust.vpcf"
end

function modifier_abyssal_stalker_void_dust_buff:StatusEffectPriority()
    return 5
end

function modifier_abyssal_stalker_void_dust_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_abyssal_stalker_void_dust_buff:GetFireProtectionBonus()
    return self.ability.protection
end

function modifier_abyssal_stalker_void_dust_buff:GetFrostProtectionBonus()
    return self.ability.protection
end

function modifier_abyssal_stalker_void_dust_buff:GetEarthProtectionBonus()
    return self.ability.protection
end

function modifier_abyssal_stalker_void_dust_buff:GetVoidProtectionBonus()
    return self.ability.protection
end

function modifier_abyssal_stalker_void_dust_buff:GetHolyProtectionBonus()
    return self.ability.protection
end

function modifier_abyssal_stalker_void_dust_buff:GetNatureProtectionBonus()
    return self.ability.protection
end

function modifier_abyssal_stalker_void_dust_buff:GetInfernoProtectionBonus()
    return self.ability.protection
end

function modifier_abyssal_stalker_void_dust_buff:GetDebuffResistanceBonus()
    return self.ability.resist
end

function modifier_abyssal_stalker_void_dust_buff:OnDestroy()
    if not IsServer() then
        return
    end
    local caster = self.ability:GetCaster()
    local units = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            self.ability.aoeDamageRadius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local particle = ParticleManager:CreateParticle("particles/units/abyssal_stalker/void_dust/void_dust_explosion.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 2, Vector(self.ability.aoeDamageRadius, 0, 0))
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end)
    local damage = self.ability.aoeDamage * Units:GetAttackDamage(caster)
    for key, unit in pairs(units) do
        local modifierTable = {}
        modifierTable.caster = caster
        modifierTable.target = unit
        modifierTable.ability = self.ability
        modifierTable.modifier_name = "modifier_abyssal_stalker_void_dust_debuff"
        modifierTable.duration = self.ability.aoeMissDuration
        GameMode:ApplyDebuff(modifierTable)
        local damageTable = {}
        damageTable.damage = damage
        damageTable.caster = caster
        damageTable.target = unit
        damageTable.ability = self.ability
        damageTable.voiddmg = true
        GameMode:DamageUnit(damageTable)
    end
end

LinkedModifiers["modifier_abyssal_stalker_void_dust_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_abyssal_stalker_void_dust_debuff = class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_MISS_PERCENTAGE }
    end
})

function modifier_abyssal_stalker_void_dust_debuff:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_abyssal_stalker_void_dust_debuff:GetModifierMiss_Percentage()
    return self.ability.aoeMissChance
end

LinkedModifiers["modifier_abyssal_stalker_void_dust_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_abyssal_stalker_void_dust = class({
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

function modifier_abyssal_stalker_void_dust:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
end

function modifier_abyssal_stalker_void_dust:GetFireProtectionBonus()
    return Units:GetMoveSpeed(self.caster) * (self.ability.resPerMs or 0)
end

function modifier_abyssal_stalker_void_dust:GetFrostProtectionBonus()
    return Units:GetMoveSpeed(self.caster) * (self.ability.resPerMs or 0)
end

function modifier_abyssal_stalker_void_dust:GetEarthProtectionBonus()
    return Units:GetMoveSpeed(self.caster) * (self.ability.resPerMs or 0)
end

function modifier_abyssal_stalker_void_dust:GetVoidProtectionBonus()
    return Units:GetMoveSpeed(self.caster) * (self.ability.resPerMs or 0)
end

function modifier_abyssal_stalker_void_dust:GetHolyProtectionBonus()
    return Units:GetMoveSpeed(self.caster) * (self.ability.resPerMs or 0)
end

function modifier_abyssal_stalker_void_dust:GetNatureProtectionBonus()
    return Units:GetMoveSpeed(self.caster) * (self.ability.resPerMs or 0)
end

function modifier_abyssal_stalker_void_dust:GetInfernoProtectionBonus()
    return Units:GetMoveSpeed(self.caster) * (self.ability.resPerMs or 0)
end

function modifier_abyssal_stalker_void_dust:GetVoidDamageBonus()
    return Units:GetMoveSpeed(self.caster) * (self.ability.resPerMs or 0)
end

function modifier_abyssal_stalker_void_dust:GetDamageReductionBonus()
    if (self.caster:HasModifier("modifier_abyssal_stalker_void_dust_buff")) then
        return self.ability.damageReductionActive
    end
    return self.ability.damageReduction
end

LinkedModifiers["modifier_abyssal_stalker_void_dust"] = LUA_MODIFIER_MOTION_NONE

abyssal_stalker_void_dust = class({
    GetAbilityTextureName = function(self)
        return "abyssal_stalker_void_dust"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_abyssal_stalker_void_dust"
    end,
    GetCastRange = function(self)
        local dmgRadius = self:GetSpecialValueFor("aoe_damage_radius")
        if (dmgRadius > 0) then
            return dmgRadius
        end
        return 0
    end
})

function abyssal_stalker_void_dust:OnUpgrade()
    self.protection = self:GetSpecialValueFor("magic_res") / 100
    self.resist = self:GetSpecialValueFor("status_res") / 100
    self.duration = self:GetSpecialValueFor("duration")
    self.aoeDamageRadius = self:GetSpecialValueFor("aoe_damage_radius")
    self.aoeDamage = self:GetSpecialValueFor("aoe_damage") / 100
    self.aoeMissChance = self:GetSpecialValueFor("aoe_miss_chance")
    self.aoeMissDuration = self:GetSpecialValueFor("aoe_miss_duration")
    self.resPerMs = self:GetSpecialValueFor("res_per_ms") / 100
    self.damageReduction = self:GetSpecialValueFor("dmg_reduction") / 100
    self.damageReductionActive = self:GetSpecialValueFor("dmg_reduction_active") / 100
end

function abyssal_stalker_void_dust:OnSpellStart()
    local modifierTable = {}
    modifierTable.caster = self:GetCaster()
    modifierTable.target = modifierTable.caster
    modifierTable.ability = self
    modifierTable.modifier_name = "modifier_abyssal_stalker_void_dust_buff"
    modifierTable.duration = self.duration
    GameMode:ApplyBuff(modifierTable)
    EmitSoundOn("Hero_PhantomAssassin.Blur.Break", modifierTable.caster)
end

--GAZE OF ABYSS--
abyssal_stalker_gaze_of_abyss_effect = class({
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
        return { MODIFIER_EVENT_ON_TAKEDAMAGE }
    end
})

abyssal_stalker_gaze_of_abyss_buff = class({
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
})

LinkedModifiers["abyssal_stalker_gaze_of_abyss_effect"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_gaze_of_abyss_buff"] = LUA_MODIFIER_MOTION_NONE

function abyssal_stalker_gaze_of_abyss_effect:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function abyssal_stalker_gaze_of_abyss_effect:OnTakeDamage(damageTable)
    local victim = damageTable.victim
    if not victim then
        return
    end
    local mod = damageTable.victim:FindModifierByName("abyssal_stalker_gaze_of_abyss_effect")
    if mod then
        if damageTable.attacker:GetUnitName() == "npc_dota_hero_phantom_assassin" then
            local modifierTable = {}
            modifierTable.caster = damageTable.attacker
            modifierTable.target = damageTable.attacker
            modifierTable.ability = mod:GetAbility()
            modifierTable.modifier_name = "abyssal_stalker_gaze_of_abyss_buff"
            modifierTable.duration = mod:GetAbility():GetSpecialValueFor("buff_duration")
            GameMode:ApplyBuff(modifierTable)
        end
        if damageTable.physdmg then
            local amp = mod:GetAbility():GetSpecialValueFor("phys_amp") / 100 + 1
            damageTable.damage = damageTable.damage * amp
            return damageTable
        end
    end
end

function abyssal_stalker_gaze_of_abyss_effect:GetVoidProtectionBonus()
    local reduc = self:GetAbility():GetSpecialValueFor("void_amp") / 100 * (-1)
    return reduc
end

function abyssal_stalker_gaze_of_abyss_buff:GetCriticalDamageBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_crit_damage") / 100
end
function abyssal_stalker_gaze_of_abyss_buff:GetAttackDamagePercentBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_damage") / 100
end

abyssal_stalker_gaze_of_abyss = class({})
function abyssal_stalker_gaze_of_abyss:OnSpellStart()
    local target = self:GetCursorTarget()
    local modifierTable = {}
    modifierTable.caster = self:GetCaster()
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.modifier_name = "abyssal_stalker_gaze_of_abyss_effect"
    modifierTable.duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyDebuff(modifierTable)
end

--CURSE OF ABYSS--

modifier_abyssal_stalker_curse_of_abyss_rip_armor = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

modifier_abyssal_stalker_curse_of_abyss_slow = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})
modifier_abyssal_stalker_curse_of_abyss_blind = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_MISS_PERCENTAGE }
    end
})

modifier_abyssal_stalker_curse_of_abyss_passive = class({
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
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED,
                 MODIFIER_EVENT_ON_MODIFIER_ADDED,
                 MODIFIER_EVENT_ON_TAKDEDAMAGE }
    end
})

modifier_abyssal_stalker_curse_of_abyss_buff = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_TAKDEDAMAGE }
    end
})
function modifier_abyssal_stalker_curse_of_abyss_blind:GetModifierMiss_Percentage()
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("miss_perc"))
end

function modifier_abyssal_stalker_curse_of_abyss_rip_armor:GetArmorBonus()
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("armor_break")) * (-1)
end

function modifier_abyssal_stalker_curse_of_abyss_slow:GetAttackSpeedBonus()
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("slow")) * (-1)
end

function modifier_abyssal_stalker_curse_of_abyss_slow:GetMoveSpeedBonus()
    return self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("slow")) * (-1)
end

function modifier_abyssal_stalker_curse_of_abyss_passive:OnAttackLanded(kv)
    if not IsServer() then
        return
    end
    if kv.attacker == self:GetCaster() and kv.target ~= self:GetCaster() then
        local modifiers = {
            "modifier_abyssal_stalker_curse_of_abyss_blind",
            "modifier_abyssal_stalker_curse_of_abyss_rip_armor",
            "modifier_abyssal_stalker_curse_of_abyss_slow"
        }
        local debuffs = {}
        for i, v in pairs(modifiers) do
            table.insert(debuffs, v)
        end
        local chance = self:GetAbility():GetSpecialValueFor("aa_proc_chance")
        local proc = RollPercentage(chance)
        if proc then

            local chance = self:GetAbility():GetSpecialValueFor("multi_chance")
            local proc = RollPercentage(chance)
            local multi = 1
            if proc then
                multi = multi + 1
            end
            for i = 1, multi do
                local debuff = debuffs[RandomInt(1, #debuffs)]
                local modifierTable = {}
                modifierTable.caster = self:GetCaster()
                modifierTable.target = kv.target
                modifierTable.ability = self:GetAbility()
                modifierTable.modifier_name = debuff
                modifierTable.duration = self:GetAbility():GetSpecialValueFor("duration")
                modifierTable.stacks = 1
                modifierTable.max_stacks = 5
                GameMode:ApplyStackingDebuff(modifierTable)
            end
        end
    end
end

---@param modifierTable MODIFIER_TABLE
function modifier_abyssal_stalker_curse_of_abyss_passive:OnPostModifierApplied(modifierTable)
    local target = modifierTable.target
    local modifier = target:FindModifierByName(modifierTable.modifier_name)
    local caster = modifierTable.caster
    if modifier then
        if modifier.IsHidden and modifier:IsHidden() then
            return
        end
        if modifier:IsDebuff() then
            local mod = {}
            mod.caster = caster
            mod.target = caster
            mod.ability = caster:FindAbilityByName("abyssal_stalker_curse_of_abyss")
            mod.modifier_name = "modifier_abyssal_stalker_curse_of_abyss_buff"
            mod.stacks = 1
            mod.max_stacks = 999999
            mod.duration = 5
            GameMode:ApplyStackingBuff(mod)
            return modifierTable
        end
    end
end

function modifier_abyssal_stalker_curse_of_abyss_passive:OnIntervalThink()
    if not IsServer() then
        return
    end
    self:SetStackCount(0)
    self:StartIntervalThink(-1)
end

function modifier_abyssal_stalker_curse_of_abyss_passive:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_abyssal_stalker_curse_of_abyss_passive")
    if modifier then
        if damageTable.victim:IsSilenced() then
            damageTable.damage = damageTable.damage * (modifier:GetAbility():GetSpecialValueFor("sil_amp") / 100 + 1)
        end
        if damageTable.victim:IsStunned() then
            damageTable.damage = damageTable.damage * (modifier:GetAbility():GetSpecialValueFor("stun_amp") / 100 + 1)
        end
        return damageTable
    end
end

function modifier_abyssal_stalker_curse_of_abyss_buff:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_abyssal_stalker_curse_of_abyss_buff")
    if modifier then
        local amp = modifier:GetAbility():GetSpecialValueFor("amp_per_stack")
        local output = modifier:GetStackCount() * amp / 100 + 1
        damageTable.damage = damageTable.damage * output
        return damageTable
    end
end

LinkedModifiers["modifier_abyssal_stalker_curse_of_abyss_blind"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_abyssal_stalker_curse_of_abyss_rip_armor"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_abyssal_stalker_curse_of_abyss_slow"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_abyssal_stalker_curse_of_abyss_passive"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_abyssal_stalker_curse_of_abyss_buff"] = LUA_MODIFIER_MOTION_NONE

abyssal_stalker_curse_of_abyss = class({
    GetIntrinsicModifierName = function(self)
        return "modifier_abyssal_stalker_curse_of_abyss_passive"
    end
})

function abyssal_stalker_curse_of_abyss:OnSpellStart()
    local target = self:GetCursorTarget()
    local modifiers = {
        "modifier_abyssal_stalker_curse_of_abyss_blind",
        "modifier_abyssal_stalker_curse_of_abyss_rip_armor",
        "modifier_abyssal_stalker_curse_of_abyss_slow"
    }
    local debuffs = {}
    for i, v in pairs(modifiers) do
        table.insert(debuffs, v)
    end
    local chance = self:GetSpecialValueFor("multi_chance")
    local proc = RollPercentage(chance)

    local multi = 1
    if proc then
        multi = multi + 1
    end
    for i = 1, multi do
        local debuff = debuffs[RandomInt(1, #debuffs)]
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = target
        modifierTable.ability = self
        modifierTable.modifier_name = debuff
        modifierTable.duration = self:GetSpecialValueFor("duration")
        modifierTable.stacks = 1
        modifierTable.max_stacks = 5
        GameMode:ApplyStackingDebuff(modifierTable)
    end
end

-- Internal stuff
if (IsServer() and not GameMode.ABYSSAL_STALKER_INIT) then
    GameMode:RegisterPostApplyModifierEventHandler(Dynamic_Wrap(modifier_abyssal_stalker_curse_of_abyss_passive, 'OnPostModifierApplied'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(abyssal_stalker_gaze_of_abyss_effect, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_abyssal_stalker_curse_of_abyss_passive, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_abyssal_stalker_curse_of_abyss_buff, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_abyssal_stalker_blade_of_abyss_sneaking, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_abyssal_stalker_blade_of_abyss_crit, 'OnTakeDamage'))
    GameMode.ABYSSAL_STALKER_INIT = true
end

for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_abyssal_stalker", MotionController)
end
