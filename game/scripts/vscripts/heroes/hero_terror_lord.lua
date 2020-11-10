local LinkedModifiers = {}

-- terror_lord_malicious_flames
modifier_terror_lord_malicious_flames_thinker = class({
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
})

function modifier_terror_lord_malicious_flames_thinker:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.thinker = self:GetParent()
    self.position = self.thinker:GetAbsOrigin()
    self:StartIntervalThink(self.ability.additionalWavesTick)
end

function modifier_terror_lord_malicious_flames_thinker:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.caster:SetCursorPosition(self.position)
    self.ability:OnSpellStart(true)
end

function modifier_terror_lord_malicious_flames_thinker:OnDestroy()
    UTIL_Remove(self.thinker)
end

LinkedModifiers["modifier_terror_lord_malicious_flames_thinker"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_malicious_flames = class({
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

function modifier_terror_lord_malicious_flames:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
end

function modifier_terror_lord_malicious_flames:GetAggroCausedBonus()
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

LinkedModifiers["modifier_terror_lord_malicious_flames"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_malicious_flames_dot = class({
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
        return "particles/units/terror_lord/malicious_flames/malicious_flames_debuff.vpcf"
    end
})

function modifier_terror_lord_malicious_flames_dot:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.damageTable = {
        caster = self:GetCaster(),
        target = self:GetParent(),
        ability = self.ability,
        damage = self.damage,
        infernodmg = true,
        dot = true
    }
    self.casterTeam = self.damageTable.caster:GetTeamNumber()
    self:OnIntervalThink()
    self:StartIntervalThink(self.ability.tick)
end

function modifier_terror_lord_malicious_flames_dot:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.damageTable.damage = Units:GetHeroStrength(self.damageTable.caster) * self.ability.dotDamage
    GameMode:DamageUnit(self.damageTable)
    if (self.ability.spreadRadius > 0) then
        local enemies = FindUnitsInRadius(self.casterTeam,
                self.damageTable.target:GetAbsOrigin(),
                nil,
                self.ability.spreadRadius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            if (not enemy:HasModifier("modifier_terror_lord_malicious_flames_dot")) then
                self.ability.modifierTable.target = enemy
                GameMode:ApplyDebuff(self.ability.modifierTable)
            end
        end
    end
end

LinkedModifiers["modifier_terror_lord_malicious_flames_dot"] = LUA_MODIFIER_MOTION_NONE

terror_lord_malicious_flames = class({
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("radius")
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_terror_lord_malicious_flames"
    end,
})

function terror_lord_malicious_flames:OnSpellStart(secondCast)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local casterTeam = caster:GetTeamNumber()
    self.modifierTable = {
        ability = self,
        target = nil,
        caster = caster,
        modifier_name = "modifier_terror_lord_malicious_flames_dot",
        duration = self.duration
    }
    local damageTable = {
        caster = caster,
        target = nil,
        ability = self,
        damage = self.damage * Units:GetHeroStrength(caster),
        infernodmg = true,
        aoe = true
    }
    local targetPosition = self:GetCursorPosition()
    local enemies = FindUnitsInRadius(casterTeam,
            targetPosition,
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        self.modifierTable.target = enemy
        damageTable.target = enemy
        GameMode:ApplyDebuff(self.modifierTable)
        GameMode:DamageFilter(damageTable)
    end
    local pfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(pfx, 0, targetPosition)
    ParticleManager:SetParticleControl(pfx, 4, Vector(self.radius, 1, 1))
    ParticleManager:SetParticleControl(pfx, 5, Vector(0, 0, 0))
    ParticleManager:ReleaseParticleIndex(pfx)
    EmitSoundOnLocationWithCaster(targetPosition, "Hero_AbyssalUnderlord.Firestorm", caster)
    if (self.additionalWaves > 0 and not secondCast) then
        CreateModifierThinker(
                caster,
                self,
                "modifier_terror_lord_malicious_flames_thinker",
                {
                    duration = self.additionalWaves * self.additionalWavesTick,
                },
                targetPosition,
                casterTeam,
                false
        )
    end
end

function terror_lord_malicious_flames:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.dotDamage = self:GetSpecialValueFor("dot_damage") / 100
    self.tick = self:GetSpecialValueFor("tick")
    self.radius = self:GetSpecialValueFor("radius")
    self.duration = self:GetSpecialValueFor("duration")
    self.spreadRadius = self:GetSpecialValueFor("spread_radius")
    self.cdrFlatPerDamage = self:GetSpecialValueFor("cdr_flat_per_damage")
    self.primalBuffPerArmorAggro = self:GetSpecialValueFor("primal_buff_per_armor_aggro") / 100
    self.primalBuffPerEleArmorAggro = self:GetSpecialValueFor("primal_buff_per_ele_armor_aggro") / 100
    self.primalBuffPerMaxHpAggro = self:GetSpecialValueFor("primal_buff_per_max_hp_aggro") / 100
    self.additionalWaves = self:GetSpecialValueFor("additional_waves")
    self.additionalWavesTick = self:GetSpecialValueFor("additional_waves_tick")
end

-- terror_lord_mighty_defiance
modifier_terror_lord_mighty_defiance = class({
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
        return terror_lord_mighty_defiance:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/terror_lord/mighty_defiance/mighty_defiance.vpcf"
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_START }
    end
})

function modifier_terror_lord_mighty_defiance:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
    self.duration = self.ability:GetSpecialValueFor("duration")
    self.bonus_as = self.ability:GetSpecialValueFor("bonus_as") / 100
    self.bonus_sph = self.ability:GetSpecialValueFor("bonus_sph") / 100
    self.bonus_ms = self.ability:GetSpecialValueFor("bonus_ms") / 100
    self.bonus_dmg = self.ability:GetSpecialValueFor("bonus_dmg") * -0.01
end

function modifier_terror_lord_mighty_defiance:OnAttackStart(keys)
    if not IsServer() then
        return
    end
    if (keys.target == self.caster and keys.attacker:GetTeamNumber() ~= self.caster:GetTeamNumber()) then
        local modifierTable = {}
        modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.target = keys.attacker
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_terror_lord_mighty_defiance_debuff"
        modifierTable.modifier_params = { bonus_as = self.bonus_as, bonus_sph = self.bonus_sph, bonus_ms = self.bonus_ms, bonus_dmg = self.bonus_dmg }
        modifierTable.duration = self.duration
        GameMode:ApplyDebuff(modifierTable)
    end
end

function modifier_terror_lord_mighty_defiance:IsTaunt()
    return true
end

LinkedModifiers["modifier_terror_lord_mighty_defiance"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_mighty_defiance_debuff = class({
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
        return terror_lord_mighty_defiance:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_START }
    end
})

function modifier_terror_lord_mighty_defiance_debuff:GetDamageReductionBonus()
    return self.bonus_dmg or 0
end

function modifier_terror_lord_mighty_defiance_debuff:GetMoveSpeedPercentBonus()
    return self.bonus_ms or 0
end

function modifier_terror_lord_mighty_defiance_debuff:GetSpellHasteBonus()
    return self.bonus_sph or 0
end

function modifier_terror_lord_mighty_defiance_debuff:GetAttackSpeedPercentBonus()
    return self.bonus_as or 0
end

function modifier_terror_lord_mighty_defiance_debuff:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.caster = self:GetParent()
end

function modifier_terror_lord_mighty_defiance_debuff:OnAttackStart(keys)
    if not IsServer() then
        return
    end
    if (keys.attacker == self.caster and keys.target ~= nil and not keys.target:IsNull() and not keys.target:HasModifier("modifier_terror_lord_mighty_defiance")) then
        self:Destroy()
    end
end

LinkedModifiers["modifier_terror_lord_mighty_defiance_debuff"] = LUA_MODIFIER_MOTION_NONE

-- terror_lord_mighty_defiance
terror_lord_mighty_defiance = class({
    GetAbilityTextureName = function(self)
        return "terror_lord_mighty_defiance"
    end
})

function terror_lord_mighty_defiance:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    caster:EmitSound("abyssal_underlord_abys_atrophyaura_02")
    local modifierTable = {}
    modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_terror_lord_mighty_defiance"
    modifierTable.duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyBuff(modifierTable)
end
-- terror_lord_destructive_stomp modifiers
modifier_terror_lord_destructive_stomp_thinker = class({
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

function modifier_terror_lord_destructive_stomp_thinker:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.radius = self.ability:GetSpecialValueFor("radius")
    self.damage = self.ability:GetSpecialValueFor("damage") / 100
    self.parent = self:GetParent()
    self.position = self.parent:GetAbsOrigin()
    local tick = self.ability:GetSpecialValueFor("tick")
    local stunDuration = self.ability:GetSpecialValueFor("stun_duration")
    self:StartIntervalThink(tick)
    local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
            self.position,
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.target = enemy
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_stunned"
        modifierTable.duration = stunDuration
        GameMode:ApplyDebuff(modifierTable)
    end
end

function modifier_terror_lord_destructive_stomp_thinker:OnDestroy()
    if not IsServer() then
        return
    end
    UTIL_Remove(self.parent)
end

function modifier_terror_lord_destructive_stomp_thinker:OnIntervalThink()
    if not IsServer() then
        return
    end
    local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
            self.position,
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
        damageTable.ability = self.ability
        damageTable.damage = self.damage * Units:GetHeroPrimaryAttribute(self.caster)
        damageTable.infernodmg = true
        damageTable.aoe = true
        GameMode:DamageUnit(damageTable)
    end
end

LinkedModifiers["modifier_terror_lord_destructive_stomp_thinker"] = LUA_MODIFIER_MOTION_NONE

-- terror_lord_destructive_stomp
terror_lord_destructive_stomp = class({
    GetAbilityTextureName = function(self)
        return "terror_lord_destructive_stomp"
    end
})

function terror_lord_destructive_stomp:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/destructive_stomp/destructive_stomp.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx, 2, Vector(0, 255, 0))
    Timers:CreateTimer(duration, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    CreateModifierThinker(
            caster,
            self,
            "modifier_terror_lord_destructive_stomp_thinker",
            {
                duration = duration
            },
            caster:GetAbsOrigin(),
            caster:GetTeamNumber(),
            false
    )
    EmitSoundOn("Hero_Centaur.HoofStomp", caster)
end

-- terror_lord_horror_genesis modifiers
modifier_terror_lord_horror_genesis_thinker = class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.ability.radius or 0
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
        return "modifier_terror_lord_horror_genesis_thinker_debuff"
    end
})

function modifier_terror_lord_horror_genesis_thinker:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.hero = self.ability:GetCaster()
    self.thinker = self:GetParent()
    self.thinker.hero_ability = self.ability
    local tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
end

function modifier_terror_lord_horror_genesis_thinker:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local distance = (self.hero:GetAbsOrigin() - self.thinker:GetAbsOrigin()):Length()
    if (distance > self.ability.radius) then
        if (self.aura_modifier) then
            self.aura_modifier:Destroy()
        end
    else
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.target = self.hero
        modifierTable.caster = self.hero
        modifierTable.modifier_name = "modifier_terror_lord_horror_genesis_thinker_buff"
        modifierTable.duration = -1
        self.aura_modifier = GameMode:ApplyBuff(modifierTable)
    end
end

function modifier_terror_lord_horror_genesis_thinker:OnDestroy()
    if (not IsServer()) then
        return
    end
    local modifier = self.hero:FindModifierByName("modifier_terror_lord_horror_genesis_thinker_buff")
    if (modifier) then
        modifier:Destroy()
    end
    UTIL_Remove(self.thinker)
end

LinkedModifiers["modifier_terror_lord_horror_genesis_thinker"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_horror_genesis_thinker_debuff = class({
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
    GetTexture = function(self)
        return terror_lord_horror_genesis:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/terror_lord/horror_genesis/horror_genesis_debuff.vpcf"
    end
})

function modifier_terror_lord_horror_genesis_thinker_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    local auraOwner = self:GetAuraOwner()
    self.ability = auraOwner.hero_ability
    self.aa_reduction = self.ability:GetSpecialValueFor("aa_reduction") * -0.01
    self.spelldmg_reduction = self.ability:GetSpecialValueFor("spelldmg_reduction") * -0.01
    self.armor_reduction = self.ability:GetSpecialValueFor("armor_reduction") * -0.01
    self.elementarmor_reduction = self.ability:GetSpecialValueFor("elementarmor_reduction") * -0.01
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetAttackDamagePercentBonus()
    return self.aa_reduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetSpellDamageBonus()
    return self.spelldmg_reduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetArmorPercentBonus()
    return self.armor_reduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetFireProtectionBonus()
    return self.elementarmor_reduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetFrostProtectionBonus()
    return self.elementarmor_reduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetEarthProtectionBonus()
    return self.elementarmor_reduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetVoidProtectionBonus()
    return self.elementarmor_reduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetHolyProtectionBonus()
    return self.elementarmor_reduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetNatureProtectionBonus()
    return self.elementarmor_reduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetInfernoProtectionBonus()
    return self.elementarmor_reduction or 0
end

LinkedModifiers["modifier_terror_lord_horror_genesis_thinker_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_horror_genesis_thinker_buff = class({
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
        return terror_lord_horror_genesis:GetAbilityTextureName()
    end
})

function modifier_terror_lord_horror_genesis_thinker_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.primary_bonus = self.ability:GetSpecialValueFor("primary_bonus")
end

function modifier_terror_lord_horror_genesis_thinker_buff:GetPrimaryAttributeBonus()
    return self.primary_bonus or 0
end

LinkedModifiers["modifier_terror_lord_horror_genesis_thinker_buff"] = LUA_MODIFIER_MOTION_NONE

-- terror_lord_horror_genesis
terror_lord_horror_genesis = class({})

function terror_lord_horror_genesis:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    self.radius = self:GetSpecialValueFor("radius")
    local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/horror_genesis/horror_genesis.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx, 1, Vector(self.radius, 22, 1))
    ParticleManager:SetParticleControl(pidx, 2, Vector(duration, 0, 0))
    Timers:CreateTimer(duration, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    CreateModifierThinker(
            caster,
            self,
            "modifier_terror_lord_horror_genesis_thinker",
            {
                duration = duration
            },
            caster:GetAbsOrigin(),
            caster:GetTeamNumber(),
            false
    )
    EmitSoundOn("Hero_AbyssalUnderlord.Firestorm.Cast", caster)
end

function terror_lord_horror_genesis:IsRequireCastbar()
    return true
end


-- terror_lord_ruthless_predator
modifier_terror_lord_ruthless_predator = class({
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
})

function modifier_terror_lord_ruthless_predator:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/ruthless_predator/ruthless_predator_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
    ParticleManager:SetParticleControlEnt(pidx, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
    self:AddParticle(pidx, true, false, 1, true, false)
end

LinkedModifiers["modifier_terror_lord_ruthless_predator"] = LUA_MODIFIER_MOTION_NONE

terror_lord_ruthless_predator = class({
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("radius")
    end,
    GetBehavior = function(self)
        if (self:GetSpecialValueFor("duration") > 0) then
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
        end
        return DOTA_ABILITY_BEHAVIOR_AURA + DOTA_ABILITY_BEHAVIOR_PASSIVE
    end,
    GetIntrinsicModifierName = function()
        return "modifier_terror_lord_ruthless_predator"
    end,
    GetCooldown = function(self)
        return self:GetSpecialValueFor("active_cooldown")
    end
})

function terror_lord_ruthless_predator:OnUpgrade()
    self.regenerationReduction = self:GetSpecialValueFor("regeneration_reduction") / 100
    self.minStacks = self:GetSpecialValueFor("min_stacks")
    self.stacksPerNormal = self:GetSpecialValueFor("stacks_per_normal")
    self.stacksPerElite = self:GetSpecialValueFor("stacks_per_elite")
    self.stacksPerBoss = self:GetSpecialValueFor("stacks_per_boss")
    self.bonusHealthRegenerationPernemy = self:GetSpecialValueFor("bonus_health_regeneration_per_enemy") / 100
    self.bonusManaRegenerationPernemy = self:GetSpecialValueFor("bonus_mana_regeneration_per_enemy") / 100
    self.radius = self:GetSpecialValueFor("radius")
    self.tick = self:GetSpecialValueFor("tick")
    self.minStacksActive = self:GetSpecialValueFor("min_stacks_active")
    self.abilityCooldown = self:GetSpecialValueFor("ability_cooldown")
    self.duration = self:GetSpecialValueFor("duration")
end

function terror_lord_ruthless_predator:OnSpellStart()
    if (not IsServer()) then
        return
    end

end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_terror_lord", MotionController)
end

if (IsServer() and not GameMode.TERROR_LORD_INIT) then
    GameMode.TERROR_LORD_INIT = true
end