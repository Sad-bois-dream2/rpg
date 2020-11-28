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

function modifier_terror_lord_malicious_flames:GetAggroCausedPercentBonus()
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
    IsDebuff = function()
        return true
    end,
    IsHidden = function()
        return false
    end,
    IsPurgable = function()
        return true
    end,
    RemoveOnDeath = function()
        return true
    end,
    AllowIllusionDuplicate = function()
        return false
    end,
    GetEffectName = function()
        return "particles/units/terror_lord/malicious_flames/malicious_flames_debuff.vpcf"
    end,
    GetAttributes = function()
        return MODIFIER_ATTRIBUTE_MULTIPLE
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
            self.ability.modifierTable.target = enemy
            GameMode:ApplyNPCBasedDebuff(self.ability.modifierTable)
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
        GameMode:ApplyNPCBasedDebuff(self.modifierTable)
        GameMode:DamageUnit(damageTable)
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

-- terror_lord_destructive_stomp
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
    end,
    IsAuraActiveOnDeath = function(self)
        return false
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
        return "modifier_terror_lord_destructive_stomp_thinker_debuff"
    end,
    GetAuraDuration = function(self)
        return 0
    end,
})

function modifier_terror_lord_destructive_stomp_thinker:GetAuraRadius()
    if (self.ability.dotSlow ~= 0) then
        return self.ability.radius
    end
    return 0
end

function modifier_terror_lord_destructive_stomp_thinker:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.casterPos = self.caster:GetAbsOrigin()
    self.casterTeam = self.caster:GetTeamNumber()
    self.thinker = self:GetParent()
    self.position = self.thinker:GetAbsOrigin()
    self.damageTable = {
        caster = self.caster,
        target = nil,
        ability = self.ability,
        damage = self.ability.dotDamage * Units:GetHeroStrength(self.caster),
        infernodmg = true,
        aoe = true,
        dot = true
    }
    self:OnIntervalThink()
    self:StartIntervalThink(self.ability.dotTick)
    local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/destructive_stomp/destructive_stomp_flames.vpcf", PATTACH_ABSORIGIN, self.thinker)
    ParticleManager:SetParticleControl(pidx, 1, Vector(self.ability.radius, 0, 0))
    ParticleManager:SetParticleControl(pidx, 2, Vector(210, 255, 138))
    ParticleManager:SetParticleControl(pidx, 4, Vector(self.ability.dotDuration, 0, 0))
    self:AddParticle(pidx, true, false, 1, true, false)
end

function modifier_terror_lord_destructive_stomp_thinker:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local enemies = FindUnitsInRadius(self.casterTeam,
            self.position,
            nil,
            self.ability.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        self.damageTable.target = enemy
        GameMode:DamageUnit(self.damageTable)
    end
end

function modifier_terror_lord_destructive_stomp_thinker:OnDestroy()
    if (not IsServer()) then
        return
    end
    UTIL_Remove(self.thinker)
end

LinkedModifiers["modifier_terror_lord_destructive_stomp_thinker"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_destructive_stomp_thinker_debuff = class({
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

function modifier_terror_lord_destructive_stomp_thinker_debuff:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_terror_lord_destructive_stomp_thinker_debuff:GetMoveSpeedPercentBonus()
    return self.ability.dotSlow or 0
end

LinkedModifiers["modifier_terror_lord_destructive_stomp_thinker_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_destructive_stomp = class({
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

function modifier_terror_lord_destructive_stomp:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.ability:OnUpgrade()
end

function modifier_terror_lord_destructive_stomp:GetStrengthPercentBonus()
    return self.ability.bonusStrength or 0
end

LinkedModifiers["modifier_terror_lord_destructive_stomp"] = LUA_MODIFIER_MOTION_NONE

terror_lord_destructive_stomp = class({
    GetCastRange = function(self)
        return self:GetSpecialValueFor("radius")
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_terror_lord_destructive_stomp"
    end
})

function terror_lord_destructive_stomp:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local casterPos = caster:GetAbsOrigin()
    local casterTeam = caster:GetTeamNumber()
    local damageTable = {
        caster = self.caster,
        target = nil,
        ability = self.ability,
        damage = Units:GetHeroStrength(caster) * self.damage,
        infernodmg = true,
        aoe = true
    }
    local stunModifier = {
        ability = self,
        caster = caster,
        target = nil,
        modifier_name = "modifier_stunned",
        duration = self.stunDuration
    }
    local enemies = FindUnitsInRadius(casterTeam,
            casterPos,
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    if (self:GetAutoCastState()) then
        for _, enemy in pairs(enemies) do
            damageTable.target = enemy
            stunModifier.target = enemy
            GameMode:DamageUnit(damageTable)
            GameMode:ApplyDebuff(stunModifier)
        end
    else
        for _, enemy in pairs(enemies) do
            damageTable.target = enemy
            GameMode:DamageUnit(damageTable)
        end
    end
    local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/destructive_stomp/destructive_stomp.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx, 1, Vector(self.radius, 0, 0))
    if (self.dotDuration > 0) then
        CreateModifierThinker(
                caster,
                self,
                "modifier_terror_lord_destructive_stomp_thinker",
                {
                    duration = self.dotDuration
                },
                casterPos,
                casterTeam,
                false
        )
        ParticleManager:SetParticleControl(pidx, 4, Vector(0, 0, 0))
    end
    ParticleManager:ReleaseParticleIndex(pidx)
    EmitSoundOn("Hero_Centaur.HoofStomp", caster)
end

function terror_lord_destructive_stomp:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.dotDamage = self:GetSpecialValueFor("dot_damage") / 100
    self.dotTick = self:GetSpecialValueFor("dot_tick")
    self.dotDuration = self:GetSpecialValueFor("dot_duration")
    self.dotSlow = self:GetSpecialValueFor("dot_slow") / -100
    self.radius = self:GetSpecialValueFor("radius")
    self.stunDuration = self:GetSpecialValueFor("stun_duration")
    self.bonusStrength = self:GetSpecialValueFor("bonus_strength") / 100
end

-- terror_lord_horror_genesis
modifier_terror_lord_horror_genesis_thinker = class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
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

function modifier_terror_lord_horror_genesis_thinker:GetAuraRadius()
    if (self.ability.armorReduction < 0) then
        return self.ability.radius
    end
    return 0
end

function modifier_terror_lord_horror_genesis_thinker:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.thinker = self:GetParent()
    self.position = self.thinker:GetAbsOrigin()
    local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/horror_genesis/horror_genesis.vpcf", PATTACH_ABSORIGIN, self.thinker)
    ParticleManager:SetParticleControl(pidx, 1, Vector(self.ability.radius, 22, 1))
    ParticleManager:SetParticleControl(pidx, 2, Vector(self.ability.duration, 0, 0))
    self:AddParticle(pidx, true, false, 1, true, false)
    if (self.ability.bonusPrimaryPct > 0) then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.caster = self.thinker
        modifierTable.target = self.thinker
        modifierTable.modifier_name = "modifier_terror_lord_horror_genesis_thinker_ally_aura"
        modifierTable.duration = -1
        GameMode:ApplyBuff(modifierTable)
    end
    self.damageTable = {
        damage = 0,
        caster = self.ability:GetCaster(),
        target = nil,
        ability = self.ability,
        infernodmg = true,
        aoe = true
    }
    self.casterTeam = self.damageTable.caster:GetTeamNumber()
    self:StartIntervalThink(self.ability.dotTick)
end

function modifier_terror_lord_horror_genesis_thinker:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.damageTable.damage = Units:GetHeroStrength(self.damageTable.caster) * self.ability.dotDamage
    local enemies = FindUnitsInRadius(self.casterTeam,
            self.position,
            nil,
            self.ability.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        self.damageTable.target = enemy
        GameMode:DamageUnit(self.damageTable)
    end
end

function modifier_terror_lord_horror_genesis_thinker:OnDestroy()
    if (not IsServer()) then
        return
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
    GetEffectName = function(self)
        return "particles/units/terror_lord/horror_genesis/horror_genesis_debuff.vpcf"
    end
})

function modifier_terror_lord_horror_genesis_thinker_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetArmorPercentBonus()
    return self.ability.armorReduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetFireProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetFrostProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetEarthProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetVoidProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetHolyProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetNatureProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetInfernoProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

function modifier_terror_lord_horror_genesis_thinker_debuff:GetMoveSpeedPercentBonus()
    return self.ability.slow or 0
end

LinkedModifiers["modifier_terror_lord_horror_genesis_thinker_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_horror_genesis_thinker_ally_aura = class({
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
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_terror_lord_horror_genesis_thinker_buff"
    end
})

function modifier_terror_lord_horror_genesis_thinker_ally_aura:GetAuraEntityReject(npc)
    if (self.ability.bonusPrimaryAlly > 0 or self.caster == npc) then
        return false
    end
    return true
end

function modifier_terror_lord_horror_genesis_thinker_ally_aura:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
end

LinkedModifiers["modifier_terror_lord_horror_genesis_thinker_ally_aura"] = LUA_MODIFIER_MOTION_NONE

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
    end
})

function modifier_terror_lord_horror_genesis_thinker_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_terror_lord_horror_genesis_thinker_buff:GetPrimaryAttributePercentBonus()
    return self.ability.bonusPrimaryPct or 0
end

LinkedModifiers["modifier_terror_lord_horror_genesis_thinker_buff"] = LUA_MODIFIER_MOTION_NONE

terror_lord_horror_genesis = class({
    GetCastRange = function(self)
        return self:GetSpecialValueFor("radius")
    end
})

function terror_lord_horror_genesis:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    CreateModifierThinker(
            caster,
            self,
            "modifier_terror_lord_horror_genesis_thinker",
            {
                duration = self.duration + 0.01
            },
            caster:GetAbsOrigin(),
            caster:GetTeamNumber(),
            false
    )
    EmitSoundOn("Hero_AbyssalUnderlord.Firestorm.Cast", caster)
end

function terror_lord_horror_genesis:OnUpgrade()
    self.dotDamage = self:GetSpecialValueFor("dot_damage") / 100
    self.armorReduction = self:GetSpecialValueFor("armor_reduction") / -100
    self.eleArmorReduction = self:GetSpecialValueFor("elearmor_reduction") / -100
    self.duration = self:GetSpecialValueFor("duration")
    self.radius = self:GetSpecialValueFor("radius")
    self.slow = self:GetSpecialValueFor("slow") / -100
    self.bonusPrimaryPct = self:GetSpecialValueFor("bonus_primary_pct") / 100
    self.bonusPrimaryAlly = self:GetSpecialValueFor("bonus_primary_ally")
    self.dotTick = self:GetSpecialValueFor("dot_tick")
end

-- terror_lord_ruthless_predator
modifier_terror_lord_ruthless_predator_aura = class({
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
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_terror_lord_ruthless_predator_aura_buff"
    end,
    GetEffectName = function()
        return "particles/units/terror_lord/ruthless_predator/ruthless_predator_aura.vpcf"
    end
})

function modifier_terror_lord_ruthless_predator_aura:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_terror_lord_ruthless_predator_aura:GetAuraEntityReject(npc)
    return npc:HasModifier("modifier_terror_lord_ruthless_predator_aura")
end

LinkedModifiers["modifier_terror_lord_ruthless_predator_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_ruthless_predator_aura_buff = class({
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

function modifier_terror_lord_ruthless_predator_aura_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ownerModifier = self:GetAbility():GetCaster():FindModifierByName("modifier_terror_lord_ruthless_predator")
end

function modifier_terror_lord_ruthless_predator_aura_buff:GetHealthRegenerationPercentBonus()
    if (self.ownerModifier and self.ownerModifier.GetHealthRegenerationPercentBonus) then
        return self.ownerModifier:GetHealthRegenerationPercentBonus()
    end
    return 0
end

LinkedModifiers["modifier_terror_lord_ruthless_predator_aura_buff"] = LUA_MODIFIER_MOTION_NONE

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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_TOOLTIP }
    end
})

function modifier_terror_lord_ruthless_predator:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.casterTeam = self.caster:GetTeamNumber()
    self.particlesTable = {}
    self.ability:OnUpgrade()
    self:OnRefresh()
end

function modifier_terror_lord_ruthless_predator:OnRefresh()
    if (not IsServer()) then
        return
    end
    self:StartIntervalThink(self.ability.tick)
end

function modifier_terror_lord_ruthless_predator:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local enemies = FindUnitsInRadius(
            self.casterTeam,
            self.caster:GetAbsOrigin(),
            nil,
            self.ability.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local damageTable = {
        caster = self.caster,
        target = nil,
        ability = self.ability,
        damage = Units:GetHeroStrength(self.caster) * self.ability.damage,
        infernodmg = true,
        aoe = true
    }
    local stacks = 0
    for _, pidx in pairs(self.particlesTable) do
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end
    self.particlesTable = {}
    local isAutocastEnabled = self.ability:GetAutoCastState()
    for _, enemy in pairs(enemies) do
        local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/ruthless_predator/ruthless_predator_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
        ParticleManager:SetParticleControlEnt(pidx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
        table.insert(self.particlesTable, pidx)
        if (isAutocastEnabled) then
            damageTable.target = enemy
            GameMode:DamageUnit(damageTable)
        end
        if Enemies:IsBoss(enemy) then
            stacks = stacks + self.ability.stacksPerBoss
        elseif Enemies:IsElite(enemy) then
            stacks = stacks + self.ability.stacksPerElite
        else
            stacks = stacks + self.ability.stacksPerNormal
        end
    end
    self:SetStackCount(stacks + self.ability.minStacks)
end

function modifier_terror_lord_ruthless_predator:GetHealthRegenerationPercentBonus()
    return math.min(self.ability.bonusHealthRegenerationPerEnemy * self:GetStackCount(), self.ability.bonusHealthRegenerationMax)
end

function modifier_terror_lord_ruthless_predator:OnTooltip()
    local ability = self:GetAbility()
    return math.min(ability:GetSpecialValueFor("bonus_health_regeneration_per_enemy") * self:GetStackCount(), ability:GetSpecialValueFor("bonus_health_regeneration_max"))
end

LinkedModifiers["modifier_terror_lord_ruthless_predator"] = LUA_MODIFIER_MOTION_NONE

terror_lord_ruthless_predator = class({
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("radius")
    end,
    GetBehavior = function(self)
        if (self:GetSpecialValueFor("active_duration") > 0) then
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_AUTOCAST
        end
        return self.BaseClass.GetBehavior(self)
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
    self.bonusHealthRegenerationPerEnemy = self:GetSpecialValueFor("bonus_health_regeneration_per_enemy") / 100
    self.bonusHealthRegenerationMax = self:GetSpecialValueFor("bonus_health_regeneration_max") / 100
    self.radius = self:GetSpecialValueFor("radius")
    self.tick = self:GetSpecialValueFor("tick")
    self.activeDuration = self:GetSpecialValueFor("active_duration")
    self.damage = self:GetSpecialValueFor("damage") / 100
end

function terror_lord_ruthless_predator:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local modifierTable = {
        ability = self,
        target = caster,
        caster = caster,
        modifier_name = "modifier_terror_lord_ruthless_predator_aura",
        duration = self.activeDuration
    }
    GameMode:ApplyBuff(modifierTable)
    EmitSoundOn("Hero_AbyssalUnderlord.Firestorm.Start", caster)
end

-- terror_lord_inferno_impulse
modifier_terror_lord_inferno_impulse_buff = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_TOOLTIP }
    end
})

function modifier_terror_lord_inferno_impulse_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.casterPosition = self.caster:GetAbsOrigin()
    self.casterTeam = self.caster:GetTeamNumber()
    local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/inferno_impulse/inferno_impulse_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
    ParticleManager:SetParticleControlEnt(pidx, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.casterPosition, true)
    self:AddParticle(pidx, true, false, 1, true, false)
end

function modifier_terror_lord_inferno_impulse_buff:OnDestroy()
    if (not IsServer()) then
        return
    end
    if (self.ability.damage > 0) then
        local casterPosition = self.caster:GetAbsOrigin()
        local enemies = FindUnitsInRadius(self.casterTeam,
                casterPosition,
                nil,
                self.ability.radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        local damageTable = {
            caster = self.caster,
            target = nil,
            ability = self.ability,
            damage = Units:GetHeroStrength(self.caster) * self.ability.damage,
            infernodmg = true,
            aoe = true
        }
        for _, enemy in pairs(enemies) do
            damageTable.target = enemy
            local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/inferno_impulse/inferno_impulse_damage_rope.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
            ParticleManager:SetParticleControlEnt(pidx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", casterPosition, true)
            ParticleManager:SetParticleControlEnt(pidx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(pidx)
            GameMode:DamageUnit(damageTable)
        end
    end
end

function modifier_terror_lord_inferno_impulse_buff:OnTooltip()
    return self:GetStackCount()
end

function modifier_terror_lord_inferno_impulse_buff:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_terror_lord_inferno_impulse_buff")
    if (not modifier) then
        return damageTable
    end
    local shieldCapacity = modifier:GetStackCount()
    local shieldAfterBlock = shieldCapacity - damageTable.damage
    if (shieldAfterBlock > 0) then
        modifier:SetStackCount(shieldAfterBlock)
        damageTable.damage = 0
    else
        damageTable.damage = damageTable.damage - shieldCapacity
        modifier:Destroy()
    end
    return damageTable
end

LinkedModifiers["modifier_terror_lord_inferno_impulse_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_inferno_impulse_debuff = class({
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

function modifier_terror_lord_inferno_impulse_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_terror_lord_inferno_impulse_debuff:GetArmorPercentBonus()
    return self.ability.armorReduction or 0
end

function modifier_terror_lord_inferno_impulse_debuff:GetFireProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

function modifier_terror_lord_inferno_impulse_debuff:GetFrostProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

function modifier_terror_lord_inferno_impulse_debuff:GetEarthProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

function modifier_terror_lord_inferno_impulse_debuff:GetVoidProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

function modifier_terror_lord_inferno_impulse_debuff:GetHolyProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

function modifier_terror_lord_inferno_impulse_debuff:GetNatureProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

function modifier_terror_lord_inferno_impulse_debuff:GetInfernoProtectionBonus()
    return self.ability.eleArmorReduction or 0
end

LinkedModifiers["modifier_terror_lord_inferno_impulse_debuff"] = LUA_MODIFIER_MOTION_NONE

terror_lord_inferno_impulse = class({
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("radius")
    end
})

function terror_lord_inferno_impulse:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local modifierTable = {
        caster = caster,
        target = caster,
        ability = self,
        modifier_name = "modifier_terror_lord_inferno_impulse_buff",
        duration = self.shieldDuration
    }
    local shieldModifier = GameMode:ApplyBuff(modifierTable)
    local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/inferno_impulse/inferno_impulse.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx, 1, Vector(self.radius, 0, 0))
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local modifierTable = {
        caster = caster,
        target = nil,
        ability = self,
        modifier_name = "modifier_terror_lord_inferno_impulse_debuff",
        duration = self.armorDuration
    }
    for _, enemy in pairs(enemies) do
        modifierTable.target = enemy
        GameMode:ApplyDebuff(modifierTable)
    end
    local capacity = self.shield * caster:GetMaxHealth()
    if (self.shieldBonusPerEnemy > 0) then
        capacity = capacity * (1 + (#enemies * self.shieldBonusPerEnemy))
    end
    if (shieldModifier) then
        shieldModifier:SetStackCount(capacity)
    end
end

function terror_lord_inferno_impulse:OnUpgrade()
    self.shield = self:GetSpecialValueFor("shield") / 100
    self.shieldDuration = self:GetSpecialValueFor("shield_duration")
    self.shieldBonusPerEnemy = self:GetSpecialValueFor("shield_bonus_per_enemy") / 100
    self.armorReduction = self:GetSpecialValueFor("armor_reduction") / -100
    self.eleArmorReduction = self:GetSpecialValueFor("ele_armor_reduction") / -100
    self.armorDuration = self:GetSpecialValueFor("armor_duration")
    self.radius = self:GetSpecialValueFor("radius")
    self.damage = self:GetSpecialValueFor("damage") / 100
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_terror_lord", MotionController)
end

if (IsServer() and not GameMode.TERROR_LORD_INIT) then
    GameMode.TERROR_LORD_INIT = true
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_terror_lord_inferno_impulse_buff, 'OnTakeDamage'))
end