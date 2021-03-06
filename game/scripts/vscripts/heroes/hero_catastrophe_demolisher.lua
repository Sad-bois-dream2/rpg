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
    damageTable.dot = true
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
    self.caster = self.ability:GetCaster()
end

function modifier_catastrophe_demolisher_curse_of_doom_aura:GetAggroCausedPercentBonus()
    local totalResistances = 0
    totalResistances = totalResistances + Units:GetFireProtection(self.caster)
    totalResistances = totalResistances + Units:GetFrostProtection(self.caster)
    totalResistances = totalResistances + Units:GetEarthProtection(self.caster)
    totalResistances = totalResistances + Units:GetVoidProtection(self.caster)
    totalResistances = totalResistances + Units:GetHolyProtection(self.caster)
    totalResistances = totalResistances + Units:GetNatureProtection(self.caster)
    totalResistances = totalResistances + Units:GetInfernoProtection(self.caster)
    totalResistances = totalResistances - 7
    return (totalResistances * (self.ability.primalBuffPerEleArmorAggro or 0)) + (Units:GetArmor(self.caster) * (self.ability.primalBuffPerArmorAggro or 0)) + (self.caster:GetMaxHealth() * (self.ability.primalBuffPerMaxHpAggro or 0))
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

modifier_catastrophe_demolisher_curse_of_doom_stacks = class({
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

function modifier_catastrophe_demolisher_curse_of_doom_stacks:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_catastrophe_demolisher_curse_of_doom_stacks:GetStrengthPercentBonus()
    return self.ability.stacksStr * self:GetStackCount()
end

LinkedModifiers["modifier_catastrophe_demolisher_curse_of_doom_stacks"] = LUA_MODIFIER_MOTION_NONE

catastrophe_demolisher_curse_of_doom = class({
    GetIntrinsicModifierName = function(self)
        return "modifier_catastrophe_demolisher_curse_of_doom_aura"
    end,
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("damage_aoe")
    end
})

function catastrophe_demolisher_curse_of_doom:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.aoe = self:GetSpecialValueFor("damage_aoe")
    self.auraRadius = self:GetSpecialValueFor("aura_radius")
    self.infernoRes = self:GetSpecialValueFor("inferno_res") / 100
    self.tick = self:GetSpecialValueFor("tick")
    self.duration = self:GetSpecialValueFor("duration")
    self.primalBuffPerArmorAggro = self:GetSpecialValueFor("primal_buff_per_armor_aggro") / 100
    self.primalBuffPerEleArmorAggro = self:GetSpecialValueFor("primal_buff_per_ele_armor_aggro") / 100
    self.primalBuffPerMaxHpAggro = self:GetSpecialValueFor("primal_buff_per_max_hp_aggro") / 100
end

function catastrophe_demolisher_curse_of_doom:OnSpellStart()
    if (not IsServer()) then
        return
    end
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
        for _, enemy in pairs(enemies) do
            self:ApplyDot(caster, enemy)
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
    if (not IsServer()) then
        return
    end
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
    local stunModifierTable = {
        ability = self,
        target = nil,
        caster = caster,
        modifier_name = "modifier_stunned",
        duration = self.stunDuration,
    }
    local damageTable = {
        damage = damage,
        caster = caster,
        ability = self,
        target = nil,
        infernodmg = true,
        aoe = true
    }
    local stacksModifierTable = {
        caster = caster,
        target = caster,
        ability = self,
        modifier_name = "modifier_catastrophe_demolisher_flaming_blast_stack",
        duration = self.strStackDuration,
        max_stacks = self.strStackCap,
        stacks = 0
    }
    for _, enemy in pairs(units) do
        if (self:GetAutoCastState()) then
            damageTable.target = enemy
            GameMode:ApplyDebuff(stunModifierTable)
        end
        damageTable.target = enemy
        GameMode:DamageUnit(damageTable)
        local stacksPerEnemy = self.strStacksPerCreep
        if (Enemies:IsBoss(enemy)) then
            stacksPerEnemy = self.strStacksPerBoss
        elseif Enemies:IsElite(enemy) then
            stacksPerEnemy = self.strStacksPerElite
        end
        stacksPerEnemy = stacksPerEnemy + self.strStackBonus
        stacksModifierTable.stacks = stacksPerEnemy
        GameMode:ApplyStackingBuff(stacksModifierTable)
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
        return true
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
        damageTable.aoe = true
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
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
end

function modifier_catastrophe_demolisher_essence_devouer_buff:GetHealthRegenerationBonus()
    return (self.ability.hpRegen or 0) * self.caster:GetMaxHealth()
end

LinkedModifiers["modifier_catastrophe_demolisher_essence_devouer_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_catastrophe_demolisher_essence_devouer_lifesteal_aura = class({
    IsPurgable = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
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
        return self.ability.lifestealAuraRadius
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
        return "modifier_catastrophe_demolisher_essence_devouer_lifesteal_aura_buff"
    end,
    GetAuraDuration = function(self)
        return 0
    end,
    GetEffectName = function(self)
        return "particles/units/catastrophe_demolisher/essence_devouer/essence_devouer_ground.vpcf"
    end
})

function modifier_catastrophe_demolisher_essence_devouer_lifesteal_aura:OnCreated()
    self.ability = self:GetAbility()
end

LinkedModifiers["modifier_catastrophe_demolisher_essence_devouer_lifesteal_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_catastrophe_demolisher_essence_devouer_lifesteal_aura_buff = class({
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

function modifier_catastrophe_demolisher_essence_devouer_lifesteal_aura_buff:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_catastrophe_demolisher_essence_devouer_lifesteal_aura_buff:OnPostTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_catastrophe_demolisher_essence_devouer_lifesteal_aura_buff")
    if (modifier) then
        local healFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_POINT_FOLLOW, damageTable.attacker)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(healFX, false)
            ParticleManager:ReleaseParticleIndex(healFX)
        end)
        local healTable = {}
        healTable.caster = damageTable.attacker
        healTable.target = damageTable.attacker
        healTable.heal = damageTable.damage * modifier.ability.lifesteal
        GameMode:HealUnit(healTable)
    end
end

LinkedModifiers["modifier_catastrophe_demolisher_essence_devouer_lifesteal_aura_buff"] = LUA_MODIFIER_MOTION_NONE

catastrophe_demolisher_essence_devouer = class({
    GetIntrinsicModifierName = function(self)
        return "modifier_catastrophe_demolisher_essence_devouer"
    end,
    GetCastRange = function(self)
        return self:GetSpecialValueFor("damage_radius")
    end,
    GetBehavior = function(self)
        if (self:GetSpecialValueFor("lifesteal") > 0) then
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
        else
            return DOTA_ABILITY_BEHAVIOR_PASSIVE
        end
    end,
    GetCooldown = function(self)
        return self:GetSpecialValueFor("lifesteal_cd")
    end,
    GetManaCost = function(self)
        return self:GetSpecialValueFor("lifesteal_manacost")
    end
})

function catastrophe_demolisher_essence_devouer:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.caster = self:GetCaster()
    modifierTable.target = modifierTable.caster
    modifierTable.modifier_name = "modifier_catastrophe_demolisher_essence_devouer_lifesteal_aura"
    modifierTable.duration = self.lifestealDuration
    GameMode:ApplyBuff(modifierTable)
    EmitSoundOn("skeleton_king_wraith_ability_mortalstrike_0", modifierTable.caster)
end

function catastrophe_demolisher_essence_devouer:OnUpgrade()
    self.hpRegen = self:GetSpecialValueFor("hp_regen") / 100
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.damageRadius = self:GetSpecialValueFor("damage_radius")
    self.hpRegenAuraRadius = self:GetSpecialValueFor("hp_regen_aura_radius")
    self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
    self.lifestealDuration = self:GetSpecialValueFor("lifesteal_duration")
    self.lifestealAuraRadius = self:GetSpecialValueFor("lifesteal_aura_radius")
end

--CRIMSON FANATICISM--
modifier_catastrophe_demolisher_crimson_fanaticism_aura = class({
    IsAura = function(self)
        return true
    end,
    GetAuraRadius = function(self)
        return self.ability.auraRadius
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_catastrophe_demolisher_crimson_fanaticism_aura_buff"
    end,
    IsPurgable = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
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
    GetAuraDuration = function(self)
        return 0
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_catastrophe_demolisher_crimson_fanaticism_aura:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_catastrophe_demolisher_crimson_fanaticism_aura:GetArmorPercentBonus()
    return self.ability.armorBonus
end

function modifier_catastrophe_demolisher_crimson_fanaticism_aura:GetFireProtectionBonus()
    return self.ability.spellArmorBonus
end

function modifier_catastrophe_demolisher_crimson_fanaticism_aura:GetFrostProtectionBonus()
    return self.ability.spellArmorBonus
end

function modifier_catastrophe_demolisher_crimson_fanaticism_aura:GetEarthProtectionBonus()
    return self.ability.spellArmorBonus
end

function modifier_catastrophe_demolisher_crimson_fanaticism_aura:GetVoidProtectionBonus()
    return self.ability.spellArmorBonus
end

function modifier_catastrophe_demolisher_crimson_fanaticism_aura:GetHolyProtectionBonus()
    return self.ability.spellArmorBonus
end

function modifier_catastrophe_demolisher_crimson_fanaticism_aura:GetNatureProtectionBonus()
    return self.ability.spellArmorBonus
end

function modifier_catastrophe_demolisher_crimson_fanaticism_aura:GetInfernoProtectionBonus()
    return self.ability.spellArmorBonus
end

LinkedModifiers["modifier_catastrophe_demolisher_crimson_fanaticism_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_catastrophe_demolisher_crimson_fanaticism_aura_buff = class({
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
        return { MODIFIER_EVENT_ON_DEATH }
    end
})

function modifier_catastrophe_demolisher_crimson_fanaticism_aura_buff:OnCreated()
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.auraOwner = self.ability:GetCaster()
    self.casterTeam = self.caster:GetTeamNumber()
end

function modifier_catastrophe_demolisher_crimson_fanaticism_aura_buff:GetAttackDamagePercentBonus()
    return self.ability.damageBonus
end

function modifier_catastrophe_demolisher_crimson_fanaticism_aura_buff:GetSpellDamageBonus()
    return self.ability.spellDamageBonus
end

function modifier_catastrophe_demolisher_crimson_fanaticism_aura_buff:OnDeath(event)
    if event.attacker == self.caster and self.ability.asPerStack > 0 then
        local stacks = self.ability.stacksNormalCount
        if Enemies:IsBoss(event.unit) then
            stacks = self.ability.stacksBossCount
        elseif Enemies:IsElite(event.unit) then
            stacks = self.ability.stacksEliteCount
        end
        local allies = FindUnitsInRadius(self.casterTeam,
                Vector(0, 0, 0),
                nil,
                FIND_UNITS_EVERYWHERE,
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, ally in pairs(allies) do
            local modifier = ally:FindModifierByName("modifier_catastrophe_demolisher_crimson_fanaticism_aura_buff")
            if (modifier) then
                local modifierTable = {}
                modifierTable.ability = self.ability
                modifierTable.caster = self.auraOwner
                modifierTable.target = ally
                modifierTable.modifier_name = "modifier_catastrophe_demolisher_crimson_fanaticism_stacks"
                modifierTable.duration = self.ability.stacksDuration
                modifierTable.stacks = stacks
                modifierTable.max_stacks = self.ability.stacksCap
                GameMode:ApplyStackingBuff(modifierTable)
            end
        end
    end
end

LinkedModifiers["modifier_catastrophe_demolisher_crimson_fanaticism_aura_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_catastrophe_demolisher_crimson_fanaticism_taunt = class({
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
    IsTaunt = function(self)
        return true
    end
})

LinkedModifiers["modifier_catastrophe_demolisher_crimson_fanaticism_taunt"] = LUA_MODIFIER_MOTION_NONE

modifier_catastrophe_demolisher_crimson_fanaticism_stacks = class({
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

function modifier_catastrophe_demolisher_crimson_fanaticism_stacks:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_catastrophe_demolisher_crimson_fanaticism_stacks:GetAttackSpeedBonus()
    return self.ability.asPerStack * self:GetStackCount()
end

function modifier_catastrophe_demolisher_crimson_fanaticism_stacks:GetSpellHasteBonus()
    return self.ability.sphPerStack * self:GetStackCount()
end

LinkedModifiers["modifier_catastrophe_demolisher_crimson_fanaticism_stacks"] = LUA_MODIFIER_MOTION_NONE

catastrophe_demolisher_crimson_fanaticism = class({
    GetBehavior = function(self)
        if (self:GetSpecialValueFor("taunt_duration") > 0) then
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
        else
            return DOTA_ABILITY_BEHAVIOR_AURA
        end
    end,
    GetCooldown = function(self)
        return self:GetSpecialValueFor("taunt_cd")
    end,
    GetManaCost = function(self)
        return self:GetSpecialValueFor("taunt_manacost")
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_catastrophe_demolisher_crimson_fanaticism_aura"
    end,
    GetCastRange = function(self)
        return self:GetSpecialValueFor("aura_radius")
    end
})

function catastrophe_demolisher_crimson_fanaticism:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.caster = self:GetCaster()
    modifierTable.target = modifierTable.caster
    modifierTable.modifier_name = "modifier_catastrophe_demolisher_crimson_fanaticism_taunt"
    modifierTable.duration = self.tauntDuration
    GameMode:ApplyBuff(modifierTable)
    local pidx = ParticleManager:CreateParticle("particles/units/catastrophe_demolisher/crimson_fanaticism/crimson_fanaticism.vpcf", PATTACH_ABSORIGIN, modifierTable.caster)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    EmitSoundOn("skeleton_king_wraith_death_18", modifierTable.caster)
end

function catastrophe_demolisher_crimson_fanaticism:OnUpgrade()
    self.damageBonus = self:GetSpecialValueFor("damage_bonus") / 100
    self.spellDamageBonus = self:GetSpecialValueFor("spell_damage_bonus") / 100
    self.msBonus = self:GetSpecialValueFor("ms_bonus") / 100
    self.asPerStack = self:GetSpecialValueFor("as_per_stack")
    self.sphPerStack = self:GetSpecialValueFor("sph_per_stack") / 100
    self.stacksCap = self:GetSpecialValueFor("stacks_cap")
    self.stacksDuration = self:GetSpecialValueFor("stacks_duration")
    self.stacksNormalCount = self:GetSpecialValueFor("stacks_normal_count")
    self.stacksEliteCount = self:GetSpecialValueFor("stacks_elite_count")
    self.stacksBossCount = self:GetSpecialValueFor("stacks_boss_count")
    self.tauntDuration = self:GetSpecialValueFor("taunt_duration")
    self.armorBonus = self:GetSpecialValueFor("armor_bonus") / 100
    self.spellArmorBonus = self:GetSpecialValueFor("spell_armor_bonus") / 100
    self.auraRadius = self:GetSpecialValueFor("aura_radius")
end

--CLAYMORE OF DESTRUCTION--

modifier_catastrophe_demolisher_claymore_of_destruction_thinker = class({
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

function modifier_catastrophe_demolisher_claymore_of_destruction_thinker:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self:StartIntervalThink(self.ability.pathTick)
end

function modifier_catastrophe_demolisher_claymore_of_destruction_thinker:OnIntervalThink()
    if not IsServer() then
        return
    end
    local enemies = FindUnitsInLine(self.ability.casterTeam,
            self.ability.pathStartPosition,
            self.ability.pathEndPosition,
            nil,
            self.ability.width,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE)
    local damage = Units:GetHeroStrength(self.caster) * self.ability.damage
    for _, enemy in pairs(enemies) do
        local damageTable = {}
        damageTable.damage = damage
        damageTable.caster = self.caster
        damageTable.target = enemy
        damageTable.ability = self.ability
        damageTable.infernodmg = true
        damageTable.aoe = true
        GameMode:DamageUnit(damageTable)
    end
end

function modifier_catastrophe_demolisher_claymore_of_destruction_thinker:OnDestroy()
    if IsServer() then
        UTIL_Remove(self:GetParent())
    end
end

LinkedModifiers["modifier_catastrophe_demolisher_claymore_of_destruction_thinker"] = LUA_MODIFIER_MOTION_NONE

modifier_catastrophe_demolisher_claymore_of_destruction = class({
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

function modifier_catastrophe_demolisher_claymore_of_destruction:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_catastrophe_demolisher_claymore_of_destruction:GetHealthPercentBonus()
    return self.ability.maxHealthBonus
end

LinkedModifiers["modifier_catastrophe_demolisher_claymore_of_destruction"] = LUA_MODIFIER_MOTION_NONE

modifier_catastrophe_demolisher_claymore_of_destruction_debuff = class({
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
    end
})

function modifier_catastrophe_demolisher_claymore_of_destruction_debuff:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_catastrophe_demolisher_claymore_of_destruction_debuff:GetFireProtectionBonus()
    return self.ability.armorReduction
end

function modifier_catastrophe_demolisher_claymore_of_destruction_debuff:GetFrostProtectionBonus()
    return self.ability.armorReduction
end

function modifier_catastrophe_demolisher_claymore_of_destruction_debuff:GetEarthProtectionBonus()
    return self.ability.armorReduction
end

function modifier_catastrophe_demolisher_claymore_of_destruction_debuff:GetVoidProtectionBonus()
    return self.ability.armorReduction
end

function modifier_catastrophe_demolisher_claymore_of_destruction_debuff:GetHolyProtectionBonus()
    return self.ability.armorReduction
end

function modifier_catastrophe_demolisher_claymore_of_destruction_debuff:GetNatureProtectionBonus()
    return self.ability.armorReduction
end

function modifier_catastrophe_demolisher_claymore_of_destruction_debuff:GetInfernoProtectionBonus()
    return self.ability.armorReduction
end

LinkedModifiers["modifier_catastrophe_demolisher_claymore_of_destruction_debuff"] = LUA_MODIFIER_MOTION_NONE

catastrophe_demolisher_claymore_of_destruction = class({
    GetIntrinsicModifierName = function(self)
        return "modifier_catastrophe_demolisher_claymore_of_destruction"
    end,
    GetBehavior = function(self)
        if (self:GetSpecialValueFor("stun_duration") > 0) then
            return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_AUTOCAST
        else
            return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
        end
    end,
})

function catastrophe_demolisher_claymore_of_destruction:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.armorReduction = self:GetSpecialValueFor("armor_reduction") / 100
    self.armorReductionDuration = self:GetSpecialValueFor("armor_reduction_duration")
    self.range = self:GetSpecialValueFor("range")
    self.stunDuration = self:GetSpecialValueFor("stun_duration")
    self.pathDamage = self:GetSpecialValueFor("path_damage") / 100
    self.pathDuration = self:GetSpecialValueFor("path_duration")
    self.pathTick = self:GetSpecialValueFor("path_tick")
    self.maxHealthBonus = self:GetSpecialValueFor("max_health_bonus") / 100
    self.width = self:GetSpecialValueFor("width")
end

function catastrophe_demolisher_claymore_of_destruction:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local casterPosition = caster:GetAbsOrigin()
    local casterForwardVector = caster:GetForwardVector()
    self.pathStartPosition = casterPosition + casterForwardVector * 100
    self.pathEndPosition = casterPosition + casterForwardVector * self.range
    self.casterTeam = caster:GetTeamNumber()
    local particle = ParticleManager:CreateParticle("particles/units/catastrophe_demolisher/claymore_of_destruction/claymore_of_destruction.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, self.pathStartPosition)
    ParticleManager:SetParticleControl(particle, 1, self.pathEndPosition)
    ParticleManager:SetParticleControl(particle, 2, Vector(self.pathDuration, 0, 0))
    ParticleManager:SetParticleControl(particle, 4, casterPosition)
    Timers:CreateTimer(self.pathDuration, function()
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end)
    CreateModifierThinker(
            caster,
            self,
            "modifier_catastrophe_demolisher_claymore_of_destruction_thinker",
            {
                duration = self.pathDuration,
            },
            casterPosition,
            caster:GetTeamNumber(),
            false
    )
    local enemies = FindUnitsInLine(self.casterTeam,
            self.pathStartPosition,
            self.pathEndPosition,
            nil,
            self.width,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE)
    local damage = Units:GetHeroStrength(caster) * self.damage
    for _, enemy in pairs(enemies) do
        local damageTable = {}
        damageTable.damage = damage
        damageTable.caster = caster
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.infernodmg = true
        damageTable.aoe = true
        GameMode:DamageUnit(damageTable)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = enemy
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_catastrophe_demolisher_claymore_of_destruction_debuff"
        modifierTable.duration = self.armorReductionDuration
        GameMode:ApplyDebuff(modifierTable)
        if (self.stunDuration > 0 and self:GetAutoCastState()) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_stunned"
            modifierTable.duration = self.stunDuration
            GameMode:ApplyDebuff(modifierTable)
        end
    end
    EmitSoundOn("Hero_SkeletonKing.Hellfire_Blast", caster)
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_catastrophe_demolisher", MotionController)
end

if (IsServer() and not GameMode.CATASTROPHE_DEMOLISHER_INIT) then
    GameMode:RegisterCritDamageEventHandler(Dynamic_Wrap(modifier_catastrophe_demolisher_blood_oblation_toggle, 'OnCriticalDamage'))
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_catastrophe_demolisher_blood_oblation_toggle, 'OnPostTakeDamage'))
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_catastrophe_demolisher_essence_devouer_lifesteal_aura_buff, 'OnPostTakeDamage'))
    GameMode.CATASTROPHE_DEMOLISHER_INIT = true
end
