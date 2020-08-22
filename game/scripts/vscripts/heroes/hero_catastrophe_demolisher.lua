local LinkedModifiers = {}

--CURSE OF DOOM--
modifier_catastrophe_demolisher_curse_of_doom_dot = class({
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
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end,
    GetEffectName = function(self)
        return "particles/units/catastrophe_demolisher/curse_of_doom/curse_of_doom_debuff.vpcf"
    end
})

function modifier_catastrophe_demolisher_curse_of_doom_dot:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self:StartIntervalThink(self.ability.tick)
end

function modifier_catastrophe_demolisher_curse_of_doom_dot:OnIntervalThink()
    if not IsServer() then
        return
    end
    local damage = Units:GetHeroStrength(self.caster) * self.ability.damage
    local damageTable = {}
    damageTable.damage = damage
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.infernodmg = true
    GameMode:DamageUnit(damageTable)
end

LinkedModifiers["modifier_catastrophe_demolisher_curse_of_doom_dot"] = LUA_MODIFIER_MOTION_NONE

modifier_catastrophe_demolisher_curse_of_doom_aura = class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.ability.auraRadius or 0
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
        return DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_catastrophe_demolisher_curse_of_doom_aura_debuff"
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_catastrophe_demolisher_curse_of_doom_aura:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

LinkedModifiers["modifier_catastrophe_demolisher_curse_of_doom_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_catastrophe_demolisher_curse_of_doom_aura_debuff = class({
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

function modifier_catastrophe_demolisher_curse_of_doom_aura_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_catastrophe_demolisher_curse_of_doom_aura_debuff:GetInfernoProtectionBonus()
    return self.ability.infernoRes
end

LinkedModifiers["modifier_catastrophe_demolisher_curse_of_doom_aura_debuff"] = LUA_MODIFIER_MOTION_NONE

catastrophe_demolisher_curse_of_doom = class({
    GetIntrinsicModifierName = function(self)
        return "modifier_catastrophe_demolisher_curse_of_doom_aura"
    end
})

function catastrophe_demolisher_curse_of_doom:GetAOERadius()
    return self:GetSpecialValueFor("damage_aoe")
end

function catastrophe_demolisher_curse_of_doom:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.aoe = self:GetSpecialValueFor("damage_aoe")
    self.auraRadius = self:GetSpecialValueFor("aura_radius")
    self.threat = self:GetSpecialValueFor("threat") / 100
    self.infernoRes = self:GetSpecialValueFor("inferno_res") / 100
    self.tick = self:GetSpecialValueFor("tick")
    self.duration = self:GetSpecialValueFor("duration")
end

function catastrophe_demolisher_curse_of_doom:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if (self.aoe > 0) then
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                target:GetAbsOrigin(),
                nil,
                self.aoe,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        if (self.threat > 0) then
            local addedAggro = caster:GetMaxHealth() * self.threat
            for _, enemy in pairs(enemies) do
                self:ApplyDot(caster, enemy)
                Aggro:Add(caster, enemy, addedAggro)
            end
        else
            for _, enemy in pairs(enemies) do
                self:ApplyDot(caster, enemy)
            end
        end
        local particle = ParticleManager:CreateParticle("particles/units/catastrophe_demolisher/curse_of_doom/curse_of_doom.vpcf", PATTACH_ABSORIGIN, target)
        Timers:CreateTimer(1, function()
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
        end)
    else
        self:ApplyDot(caster, target)
        local particle = ParticleManager:CreateParticle("particles/units/catastrophe_demolisher/curse_of_doom/curse_of_doom_single.vpcf", PATTACH_ABSORIGIN, target)
        Timers:CreateTimer(1, function()
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
        end)
    end
    EmitSoundOn("Hero_SkeletonKing.Hellfire_Blast", caster)
end

function catastrophe_demolisher_curse_of_doom:ApplyDot(caster, target)
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_catastrophe_demolisher_curse_of_doom_dot"
    modifierTable.duration = self.duration
    GameMode:ApplyDebuff(modifierTable)
end

--FLAMING BLAST--

modifier_catastrophe_demolisher_flaming_blast_stack = class({
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
    end,
    GetEffectName = function(self)
        return "particles/units/catastrophe_demolisher/flaming_blast/flaming_blast_buff.vpcf"
    end
})

function modifier_catastrophe_demolisher_flaming_blast_stack:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_catastrophe_demolisher_flaming_blast_stack:GetStrengthPercentBonus()
    return self:GetStackCount() * self.ability.strPerStack
end

function modifier_catastrophe_demolisher_flaming_blast_stack:OnTooltip()
    return self:GetStackCount() * self.ability:GetSpecialValueFor("str_per_stack")
end

LinkedModifiers["modifier_catastrophe_demolisher_flaming_blast_stack"] = LUA_MODIFIER_MOTION_NONE

catastrophe_demolisher_flaming_blast = class({
    GetCastRange = function(self)
        return self:GetSpecialValueFor("radius")
    end
})

function catastrophe_demolisher_flaming_blast:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.stunDuration = self:GetSpecialValueFor("stun_duration")
    self.strPerStack = self:GetSpecialValueFor("str_per_stack") / 100
    self.strStackDuration = self:GetSpecialValueFor("str_stack_duration")
    self.strStackCap = self:GetSpecialValueFor("str_stack_cap")
    self.radius = self:GetSpecialValueFor("radius")
    self.strStackBonus = self:GetSpecialValueFor("str_stack_bonus")
    self.strStacksPerCreep = self:GetSpecialValueFor("str_stacks_per_creep")
    self.strStacksPerElite = self:GetSpecialValueFor("str_stacks_per_elite")
    self.strStacksPerBoss = self:GetSpecialValueFor("str_stacks_per_boss")
end

function catastrophe_demolisher_flaming_blast:OnSpellStart()
    local caster = self:GetCaster()
    local impactPosition = caster:GetAbsOrigin() + caster:GetForwardVector() * 150
    local damage = caster:GetMaxHealth() * self.damage
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
            impactPosition,
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(units) do
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = enemy
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_stunned"
        modifierTable.duration = self.stunDuration
        GameMode:ApplyDebuff(modifierTable)
        local damageTable = {}
        damageTable.damage = damage
        damageTable.caster = caster
        damageTable.ability = self
        damageTable.target = enemy
        damageTable.infernodmg = true
        GameMode:DamageUnit(damageTable)
        local stacksPerEnemy = self.strStacksPerCreep
        if Enemies:IsBoss(enemy) then
            stacksPerEnemy = self.strStacksPerBoss
        elseif Enemies:IsElite(enemy) then
            stacksPerEnemy = self.strStacksPerElite
        end
        stacksPerEnemy = stacksPerEnemy + self.strStackBonus
        local modifierTable = {}
        modifierTable.caster = caster
        modifierTable.target = caster
        modifierTable.ability = self
        modifierTable.modifier_name = "modifier_catastrophe_demolisher_flaming_blast_stack"
        modifierTable.duration = self.strStackDuration
        modifierTable.max_stacks = self.strStackCap
        modifierTable.stacks = stacksPerEnemy
        GameMode:ApplyStackingBuff(modifierTable)
    end
    local particle = ParticleManager:CreateParticle("particles/units/catastrophe_demolisher/flaming_blast/flaming_blast.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 1, impactPosition)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end)
    EmitSoundOn("Hero_SkeletonKing.CriticalStrike.TI8", caster)
end

--BLOOD OBLATION--
modifier_catastrophe_demolisher_blood_oblation_toggle = class({
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
        return "particles/units/catastrophe_demolisher/blood_oblation/blood_oblation.vpcf"
    end
})

function modifier_catastrophe_demolisher_blood_oblation_toggle:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_catastrophe_demolisher_blood_oblation_toggle:GetArmorBonus()
    return self.ability.armorLoss
end

function modifier_catastrophe_demolisher_blood_oblation_toggle:GetFireProtectionBonus()
    return self.ability.spellArmorLoss
end

function modifier_catastrophe_demolisher_blood_oblation_toggle:GetFrostProtectionBonus()
    return self.ability.spellArmorLoss
end

function modifier_catastrophe_demolisher_blood_oblation_toggle:GetEarthProtectionBonus()
    return self.ability.spellArmorLoss
end

function modifier_catastrophe_demolisher_blood_oblation_toggle:GetVoidProtectionBonus()
    return self.ability.spellArmorLoss
end

function modifier_catastrophe_demolisher_blood_oblation_toggle:GetHolyProtectionBonus()
    return self.ability.spellArmorLoss
end

function modifier_catastrophe_demolisher_blood_oblation_toggle:GetNatureProtectionBonus()
    return self.ability.spellArmorLoss
end

function modifier_catastrophe_demolisher_blood_oblation_toggle:GetInfernoProtectionBonus()
    return self.ability.spellArmorLoss
end

function modifier_catastrophe_demolisher_blood_oblation_toggle:GetCriticalDamageBonus()
    return self.ability.bonusCritDamage
end

function modifier_catastrophe_demolisher_blood_oblation_toggle:GetCriticalChanceBonus()
    return self.ability.bonusCritChance
end

function modifier_catastrophe_demolisher_blood_oblation_toggle:OnCriticalDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_catastrophe_demolisher_blood_oblation_toggle")
    if (modifier) then
        local modifierTable = {}
        modifierTable.ability = modifier.ability
        modifierTable.target = damageTable.attacker
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_catastrophe_demolisher_blood_oblation_zealot"
        modifierTable.duration = modifier.ability.stackDuration
        modifierTable.stacks = 1
        modifierTable.max_stacks = 99999
        GameMode:ApplyStackingBuff(modifierTable)
    end
end

function modifier_catastrophe_demolisher_blood_oblation_toggle:OnPostTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_catastrophe_demolisher_blood_oblation_toggle")
    if (not modifier or damageTable.ability or not damageTable.physdmg) then
        return damageTable
    end
    local ability = damageTable.attacker:FindAbilityByName("catastrophe_demolisher_curse_of_doom")
    if (not ability or ability:GetLevel() < 1) then
        return damageTable
    end
    local cd = ability:GetCooldownTimeRemaining()
    ability:EndCooldown()
    damageTable.attacker:SetCursorCastTarget(damageTable.victim)
    ability:OnSpellStart()
    ability:StartCooldown(cd)
end

LinkedModifiers["modifier_catastrophe_demolisher_blood_oblation_toggle"] = LUA_MODIFIER_MOTION_NONE

modifier_catastrophe_demolisher_blood_oblation = class({
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
})

function modifier_catastrophe_demolisher_blood_oblation:OnCreated()
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
end

function modifier_catastrophe_demolisher_blood_oblation:GetInfernoDamageBonus()
    if (self.caster:FindModifierByName("modifier_catastrophe_demolisher_blood_oblation_toggle")) then
        return self.ability.infernoBonus
    else
        return self.ability.infernoBonusActive
    end
    return 0
end

LinkedModifiers["modifier_catastrophe_demolisher_blood_oblation"] = LUA_MODIFIER_MOTION_NONE

modifier_catastrophe_demolisher_blood_oblation_zealot = class({
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

function modifier_catastrophe_demolisher_blood_oblation_zealot:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_catastrophe_demolisher_blood_oblation_zealot:GetArmorBonus()
    return self:GetStackCount() * self.ability.armorLossPerStack
end

function modifier_catastrophe_demolisher_blood_oblation_zealot:GetFireProtectionBonus()
    return self:GetStackCount() * self.ability.spellArmorLossPerStack
end

function modifier_catastrophe_demolisher_blood_oblation_zealot:GetFrostProtectionBonus()
    return self:GetStackCount() * self.ability.spellArmorLossPerStack
end

function modifier_catastrophe_demolisher_blood_oblation_zealot:GetEarthProtectionBonus()
    return self:GetStackCount() * self.ability.spellArmorLossPerStack
end

function modifier_catastrophe_demolisher_blood_oblation_zealot:GetVoidProtectionBonus()
    return self:GetStackCount() * self.ability.spellArmorLossPerStack
end

function modifier_catastrophe_demolisher_blood_oblation_zealot:GetHolyProtectionBonus()
    return self:GetStackCount() * self.ability.spellArmorLossPerStack
end

function modifier_catastrophe_demolisher_blood_oblation_zealot:GetNatureProtectionBonus()
    return self:GetStackCount() * self.ability.spellArmorLossPerStack
end

function modifier_catastrophe_demolisher_blood_oblation_zealot:GetInfernoProtectionBonus()
    return self:GetStackCount() * self.ability.spellArmorLossPerStack
end

function modifier_catastrophe_demolisher_blood_oblation_zealot:GetCriticalChanceBonus()
    return self:GetStackCount() * self.ability.critChancePerStack
end

LinkedModifiers["modifier_catastrophe_demolisher_blood_oblation_zealot"] = LUA_MODIFIER_MOTION_NONE

catastrophe_demolisher_blood_oblation = class({
    GetIntrinsicModifierName = function(self)
        return "modifier_catastrophe_demolisher_blood_oblation"
    end
})

function catastrophe_demolisher_blood_oblation:OnUpgrade()
    self.armorLoss = self:GetSpecialValueFor("armor_loss")
    self.spellArmorLoss = self:GetSpecialValueFor("spell_armor_loss") / 100
    self.bonusCritDamage = self:GetSpecialValueFor("bonus_crit_damage") / 100
    self.bonusCritChance = self:GetSpecialValueFor("bonus_crit_chance") / 100
    self.critChancePerStack = self:GetSpecialValueFor("crit_chance_per_stack") / 100
    self.armorLossPerStack = self:GetSpecialValueFor("armor_loss_per_stack")
    self.spellArmorLossPerStack = self:GetSpecialValueFor("spell_armor_loss_per_stack") / 100
    self.infernoBonus = self:GetSpecialValueFor("inferno_bonus") / 100
    self.infernoBonusActive = self:GetSpecialValueFor("inferno_bonus_active") / 100
    self.stackDuration = self:GetSpecialValueFor("zealot_stack_duration")
end

function catastrophe_demolisher_blood_oblation:OnToggle(unit, special_cast)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    caster.catastrophe_demolisher_blood_oblation = caster.catastrophe_demolisher_blood_oblation or {}
    if (self:GetToggleState()) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_catastrophe_demolisher_blood_oblation_toggle"
        modifierTable.duration = -1
        caster.catastrophe_demolisher_blood_oblation.modifier = GameMode:ApplyBuff(modifierTable)
        self:EndCooldown()
        self:StartCooldown(self:GetCooldown(1))
    else
        if (caster.catastrophe_demolisher_blood_oblation.modifier ~= nil) then
            caster.catastrophe_demolisher_blood_oblation.modifier:Destroy()
        end
        local modifier = caster:FindModifierByName("modifier_catastrophe_demolisher_blood_oblation_zealot")
        if (modifier) then
            modifier:Destroy()
        end
    end
end

--ESSENCE DEVOURER--
modifier_catastrophe_demolisher_essence_devouer = class({
    IsPurgable = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsDebuff = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.ability.hpRegenAuraRadius
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
        return "modifier_catastrophe_demolisher_essence_devouer_buff"
    end,
    GetAuraDuration = function(self)
        return 0
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_catastrophe_demolisher_essence_devouer:GetAuraEntityReject(npc)
    return self:GetStackCount() == 0
end

function modifier_catastrophe_demolisher_essence_devouer:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.casterTeam = self.caster:GetTeamNumber()
    self.particlesTable = {}
    local tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
end

function modifier_catastrophe_demolisher_essence_devouer:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    for _, particle in pairs(self.particlesTable) do
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end
    local damage = Units:GetHeroStrength(self.caster) * self.ability.damage
    local casterPos = self.caster:GetAbsOrigin()
    local enemies = FindUnitsInRadius(self.casterTeam, casterPos, nil, self.ability.damageRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _, enemy in pairs(enemies) do
        local particle = ParticleManager:CreateParticle("particles/units/catastrophe_demolisher/essence_devouer/essence_devouer_tick_rope.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
        ParticleManager:SetParticleControlEnt(particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", casterPos, true)
        table.insert(self.particlesTable, particle)
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.infernodmg = true
        GameMode:DamageUnit(damageTable)
    end
    self:SetStackCount(#enemies)
end

LinkedModifiers["modifier_catastrophe_demolisher_essence_devouer"] = LUA_MODIFIER_MOTION_NONE

modifier_catastrophe_demolisher_essence_devouer_buff = class({
    IsPurgable = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsDebuff = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end
})

function modifier_catastrophe_demolisher_essence_devouer_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
end

function modifier_catastrophe_demolisher_essence_devouer_buff:GetHealthRegenerationBonus()
    return (self.ability.hpRegen or 0) * self.caster:GetMaxHealth()
end

LinkedModifiers["modifier_catastrophe_demolisher_essence_devouer_buff"] = LUA_MODIFIER_MOTION_NONE

--[[
function catastrophe_demolisher_essence_devouer_effect:OnTakeDamage(damageTable)
    if (damageTable.damage > 0) and not damageTable.ability and damageTable.physdmg then
        local healFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_POINT_FOLLOW, damageTable.attacker)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(healFX, false)
            ParticleManager:ReleaseParticleIndex(healFX)
        end)
        local healTable = {}
        healTable.caster = damageTable.attacker
        healTable.target = damageTable.attacker
        healTable.heal = damageTable.damage --* self:GetAbility():GetSpecialValueFor("phys_lifesteal") / 100
        GameMode:HealUnit(healTable)
    elseif (damageTable.damage > 0 and (not damageTable.physdmg) and damageTable.ability) then
        local healFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_POINT_FOLLOW, damageTable.attacker)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(healFX, false)
            ParticleManager:ReleaseParticleIndex(healFX)
        end)
        local healTable = {}
        healTable.caster = damageTable.attacker
        healTable.target = damageTable.attacker
        healTable.heal = damageTable.damage --* self:GetAbility():GetSpecialValueFor("magic_lifesteal") / 100
        GameMode:HealUnit(healTable)
    end
end
--]]

catastrophe_demolisher_essence_devouer = class({
    GetIntrinsicModifierName = function(self)
        return "modifier_catastrophe_demolisher_essence_devouer"
    end,
    GetCastRange = function(self)
        return self:GetSpecialValueFor("damage_radius")
    end
})

function catastrophe_demolisher_essence_devouer:OnUpgrade()
    self.hpRegen = self:GetSpecialValueFor("hp_regen") / 100
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.damageRadius = self:GetSpecialValueFor("damage_radius")
    self.hpRegenAuraRadius = self:GetSpecialValueFor("hp_regen_aura_radius")
    self.lifesteal = self:GetSpecialValueFor("lifesteal")
    self.lifestealAuraRadius = self:GetSpecialValueFor("lifesteal_aura_radius")
end

--CRIMSON FANATICISM--
catastrophe_demolisher_crimson_fanaticism_aura = class({
    IsAura = function(self)
        return true
    end,
    GetAuraRadius = function(self)
        return 1200
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "catastrophe_demolisher_crimson_fanaticism_effect"
    end,
    IsPurgable = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsDebuff = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
})

catastrophe_demolisher_crimson_fanaticism_effect = class({
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

catastrophe_demolisher_crimson_fanaticism_buff = class({
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

function catastrophe_demolisher_crimson_fanaticism_effect:GetAttackDamagePercentBonus()
    return self:GetAbility():GetSpecialValueFor("damage_bonus")
end

function catastrophe_demolisher_crimson_fanaticism_effect:GetMoveSpeedBonus()
    return self:GetAbility():GetSpecialValueFor("ms_bonus")
end

function catastrophe_demolisher_crimson_fanaticism_effect:DeclareFunctions()
    return { MODIFIER_EVENT_ON_DEATH }
end

function catastrophe_demolisher_crimson_fanaticism_effect:OnDeath(event)
    if event.attacker == self:GetParent() then
        local stacks = 1
        if Enemies:IsBoss(event.unit) then
            stacks = 5
        elseif Enemies:IsElite(event.unit) then
            stacks = 3
        end
        local modifierTable = {}
        modifierTable.ability = self:GetAbility()
        modifierTable.caster = self:GetParent()
        modifierTable.target = self:GetParent()
        modifierTable.modifier_name = "catastrophe_demolisher_crimson_fanaticism_buff"
        modifierTable.duration = 10
        modifierTable.stacks = stacks
        modifierTable.max_stacks = 5
        GameMode:ApplyStackingBuff(modifierTable)
    end
end

function catastrophe_demolisher_crimson_fanaticism_buff:GetAttackSpeedBonus()
    return self:GetSpecialValueFor("aspd") * self:GetStackCount()
end

function catastrophe_demolisher_crimson_fanaticism_buff:GetSpellHasteBonus()
    return self:GetSpecialValueFor("spellhaste") * self:GetStackCount()
end

LinkedModifiers["catastrophe_demolisher_crimson_fanaticism_aura"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["catastrophe_demolisher_crimson_fanaticism_effect"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["catastrophe_demolisher_crimson_fanaticism_buff"] = LUA_MODIFIER_MOTION_NONE

catastrophe_demolisher_crimson_fanaticism = class({})

function catastrophe_demolisher_crimson_fanaticism:GetIntrinsicModifierName()
    return "catastrophe_demolisher_essence_devouer_aura"
end

--CLAYMORE OF DESTRUCTION--

catastrophe_demolisher_claymore_of_destruction_effect = class({
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

function catastrophe_demolisher_claymore_of_destruction_effect:GetArmorPercentBonus()
    return self:GetSpecialValueFor("armor_loss") * (-1)
end

catastrophe_demolisher_claymore_of_destruction = class({
    IsRequireCastbar = function(self)
        return true
    end
})

LinkedModifiers["catastrophe_demolisher_claymore_of_destruction_effect"] = LUA_MODIFIER_MOTION_NONE

function catastrophe_demolisher_claymore_of_destruction:OnSpellStart()
end

function catastrophe_demolisher_claymore_of_destruction:OnChannelFinish(interrupted)
    if not IsServer() then
        return
    end
    local target = self:GetCursorTarget()
    if (interrupted and (not target or target:IsNull() or not target:IsAlive())) then
        local caster = self:GetCaster()
        local damageTable = {}
        damageTable.ability = self
        damageTable.caster = caster
        damageTable.target = target
        damageTable.damage = self:GetSpecialValueFor("damage") * Units:GetAttackDamage(caster)
        GameMode:DamageUnit(damageTable)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = target
        modifierTable.modifier_name = "modifier_stunned"
        modifierTable.duration = 1000--self:GetSpecialValueFor("stun_duration")* 1000
        GameMode:ApplyDebuff(modifierTable)
        local caster = self:GetCaster()
        local modifierTable1 = {}
        modifierTable1.ability = self
        modifierTable1.target = caster
        modifierTable1.caster = target
        modifierTable1.modifier_name = "catastrophe_demolisher_claymore_of_destruction_effect"
        modifierTable1.duration = 10
        GameMode:ApplyDebuff(modifierTable1)
    end
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_catastrophe_demolisher", MotionController)
end

if (IsServer() and not GameMode.CATASTROPHE_DEMOLISHER_INIT) then
    GameMode:RegisterCritDamageEventHandler(Dynamic_Wrap(modifier_catastrophe_demolisher_blood_oblation_toggle, 'OnCriticalDamage'))
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_catastrophe_demolisher_blood_oblation_toggle, 'OnPostTakeDamage'))
    GameMode.CATASTROPHE_DEMOLISHER_INIT = true
end
