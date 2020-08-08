local LinkedModifiers = {}

--DANCE OF DARKNESS--
abyssal_stalker_dance_of_darkness_evade = abyssal_stalker_dance_of_darkness_evade or class({
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
        return abyssal_stalker_dance_of_darkness:GetAbilityTextureName()
    end,
})
abyssal_stalker_dance_of_darkness_agi = abyssal_stalker_dance_of_darkness_agi or class({
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
        return abyssal_stalker_dance_of_darkness:GetAbilityTextureName()
    end,
})

function abyssal_stalker_dance_of_darkness_evade:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_FAIL,
             MODIFIER_PROPERTY_EVASION_CONSTANT, }
end

function abyssal_stalker_dance_of_darkness_evade:GetModifierEvasion_Constant()
    return self:GetSpecialValueFor("evasion")
end
function abyssal_stalker_dance_of_darkness_evade:OnAttackFail(event)
    local caster = self:GetCaster()
    if not IsServer() then
        return
    end
    if not event.target == caster then
        return
    end
    local modifier = abyssal_stalker_dance_of_darkness_agi
    local stacks = self:GetStackCount()
    local maxStacks = 15

    if caster:HasModifier("modifier") then
        caster:SetModifierStackCount("modifier", caster, math.min(stacks + 1, maxStacks))
        caster:FindModifierByName("modifier"):SetDuration(4, true)
    else
        local modifierTable = {}
        modifierTable.ability = self:GetAbility()
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier"
        modifierTable.duration = 4
        GameMode:ApplyBuff(modifierTable)
    end
end

function abyssal_stalker_dance_of_darkness_agi:GetAgilityBonus()
    local agiPerStack = self:GetAbility():GetSpecialValueFor("agi_per_stack")
    return agiPerStack * self:GetStackCount()
end

LinkedModifiers["abyssal_stalker_dance_of_darkness_evade"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_dance_of_darkness_agi"] = LUA_MODIFIER_MOTION_NONE

abyssal_stalker_dance_of_darkness = abyssal_stalker_dance_of_darkness or class({})

function abyssal_stalker_dance_of_darkness:OnSpellStart()
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "abyssal_stalker_dance_of_darkness_evade"
    modifierTable.duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyBuff(modifierTable)
end

--SHADOW RUSH--

modifier_abyssal_stalker_shadow_rush_instance = modifier_abyssal_stalker_shadow_rush_instance or class({
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
    GetTexture = function(self)
        return abyssal_stalker_shadow_rush:GetAbilityTextureName()
    end
})

function modifier_abyssal_stalker_shadow_rush_instance:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    self:StartIntervalThink(0.1)
end

function modifier_abyssal_stalker_shadow_rush_instance:OnIntervalThink()
    if not IsServer() then
        return
    end
    if self:GetStackCount() > 0 then
        local damage = Units:GetAttackDamage(self.caster) * self.ability.damage
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = self.ability.target
        damageTable.ability = self.ability
        damageTable.damage = damage
        damageTable.voiddmg = true
        GameMode:DamageUnit(damageTable)
        self:DecrementStackCount()
    else
        self:Destroy()
    end
end

LinkedModifiers["modifier_abyssal_stalker_shadow_rush_instance"] = LUA_MODIFIER_MOTION_NONE

modifier_abyssal_stalker_shadow_rush_shadows = modifier_abyssal_stalker_shadow_rush_shadows or class({
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
        self:SetStackCount(math.min(self:GetStackCount() + 1, self.ability.maxShadows))
    end
end

LinkedModifiers["modifier_abyssal_stalker_shadow_rush_shadows"] = LUA_MODIFIER_MOTION_NONE

abyssal_stalker_shadow_rush = abyssal_stalker_shadow_rush or class({
    GetAbilityTextureName = function(self)
        return "phantom_assassin_phantom_strike"
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
    if(not self.shadowsModifier) then
        self.shadowsModifier = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
    end
end

function abyssal_stalker_shadow_rush:OnSpellStart()
    local caster = self:GetCaster()
    local target = false
    if not self:GetCursorTargetingNothing() then
        target = self:GetCursorTarget()
    end
    local blinkStartPos = caster:GetAbsOrigin()
    local blink = ParticleManager:CreateParticle("particles/units/abyssal_stalker/shadow_rush/shadow_rush.vpcf", PATTACH_ABSORIGIN, caster)
    FindClearSpaceForUnit(caster, target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(blink, 0, blinkStartPos)
    local blinkEndPos = caster:GetAbsOrigin()
    ParticleManager:SetParticleControl(blink, 1, blinkEndPos)
    ParticleManager:SetParticleControl(blink, 2, blinkEndPos)
    ParticleManager:SetParticleControl(blink, 3, blinkEndPos)
    ParticleManager:ReleaseParticleIndex(blink)
    Timers:CreateTimer(1, function()
        ParticleManager:DestroyParticle(blink, false)
        ParticleManager:ReleaseParticleIndex(blink)
    end)
    self.target = target
    local totalShadows = self.shadowsModifier:GetStackCount()
    local strikes = math.min(self.instances, totalShadows)
    if(strikes >= 0) then
        self.shadowsModifier:SetStackCount(math.min(0, totalShadows - strikes))
    else
        return
    end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.caster = caster
    modifierTable.target = caster
    modifierTable.modifier_name = "modifier_abyssal_stalker_shadow_rush_instance"
    modifierTable.duration = -1
    modifierTable.stacks = strikes
    modifierTable.max_stacks = 99999
    GameMode:ApplyStackingBuff(modifierTable)
end

--ABYSSAL STRIKE--

abyssal_stalker_blade_of_abyss_crit = abyssal_stalker_blade_of_abyss_crit or class({
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
        return abyssal_stalker_blade_of_abyss:GetAbilityTextureName()
    end,
})

function abyssal_stalker_blade_of_abyss_crit:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function abyssal_stalker_blade_of_abyss_crit:OnAttackStart(event)
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local damage = self:GetAbility():GetSpecialValueFor("damage")
    local backstab_damage = self:GetAbility():GetSpecialValueFor("backstab_damage")
    if event.attacker == caster then
        if event.target:GetForwardVector():Dot(caster:GetForwardVector()) >= 0 then
            self:SetStackCount(backstab_damage)
        else
            self:SetStackCount(damage)
        end
    end
end

function abyssal_stalker_blade_of_abyss_crit:OnAttackLanded(event)
    if not IsServer() then
        return
    end
    if event.attacker == self:GetCaster() and event.target ~= self:GetCaster() then
        self:Destroy()
    end
end

LinkedModifiers["abyssal_stalker_blade_of_abyss_crit"] = LUA_MODIFIER_MOTION_NONE

abyssal_stalker_blade_of_abyss = abyssal_stalker_blade_of_abyss or class({})

function abyssal_stalker_blade_of_abyss:OnSpellStart()
    local modifierTable = {}
    modifierTable.caster = self:GetCaster()
    modifierTable.target = self:GetCaster()
    modifierTable.ability = self
    modifierTable.modifier_name = "abyssal_stalker_blade_of_abyss_crit"
    modifierTable.duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyBuff(modifierTable)
    local modifierTable = {}
    modifierTable.caster = self:GetCaster()
    modifierTable.target = self:GetCaster()
    modifierTable.ability = self
    modifierTable.modifier_name = "modifier_rune_invis"
    modifierTable.duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyBuff(modifierTable)
end

--VOID DUST--
abyssal_stalker_void_dust_buff = abyssal_stalker_void_dust_buff or class({
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
})

function abyssal_stalker_void_dust_buff:GetFireProtectionBonus()
    return self:GetAbility().protection
end
function abyssal_stalker_void_dust_buff:GetFrostProtectionBonus()
    return self:GetAbility().protection
end
function abyssal_stalker_void_dust_buff:GetEarthProtectionBonus()
    return self:GetAbility().protection
end
function abyssal_stalker_void_dust_buff:GetVoidProtectionBonus()
    return self:GetAbility().protection
end
function abyssal_stalker_void_dust_buff:GetHolyProtectionBonus()
    return self:GetAbility().protection
end
function abyssal_stalker_void_dust_buff:GetNatureProtectionBonus()
    return self:GetAbility().protection
end
function abyssal_stalker_void_dust_buff:GetInfernoProtectionBonus()
    return self:GetAbility().protection
end

LinkedModifiers["abyssal_stalker_void_dust_buff"] = LUA_MODIFIER_MOTION_NONE

abyssal_stalker_void_dust = abyssal_stalker_void_dust or class({})
function abyssal_stalker_void_dust:OnUpgrade()
    self.protection = self:GetSpecialValueFor("magic_res") / 100
end
function abyssal_stalker_void_dust:OnSpellStart()
    local modifierTable = {}
    modifierTable.caster = self:GetCaster()
    modifierTable.target = self:GetCaster()
    modifierTable.ability = self
    modifierTable.modifier_name = "abyssal_stalker_void_dust_buff"
    modifierTable.duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyBuff(modifierTable)
end

--GAZE OF ABYSS--
abyssal_stalker_gaze_of_abyss_effect = abyssal_stalker_gaze_of_abyss_effect or class({
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
        return abyssal_stalker_gaze_of_abyss:GetAbilityTextureName()
    end,
})

abyssal_stalker_gaze_of_abyss_buff = abyssal_stalker_gaze_of_abyss_buff or class({
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
        return abyssal_stalker_gaze_of_abyss:GetAbilityTextureName()
    end,
})

LinkedModifiers["abyssal_stalker_gaze_of_abyss_effect"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_gaze_of_abyss_buff"] = LUA_MODIFIER_MOTION_NONE

function abyssal_stalker_gaze_of_abyss_effect:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function abyssal_stalker_gaze_of_abyss_effect:OnTakeDamage(event)
    if not IsServer() then
        return
    end
    if event.unit == self:GetParent() and event.attacker == self:GetCaster() then
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = self:GetCaster()
        modifierTable.ability = self:GetAbility()
        modifierTable.modifier_name = "abyssal_stalker_gaze_of_abyss_buff"
        modifierTable.duration = 10
        GameMode:ApplyBuff(modifierTable)
    end
end

function abyssal_stalker_gaze_of_abyss_buff:GetCriticalDamageBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_crit_damage")
end
function abyssal_stalker_gaze_of_abyss_buff:GetAttackDamagePercentBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end


------------------------------------------
--ABILITIES END, TALENTS START
------------------------------------------

--REND AND REDMIST--
abyssal_stalker_rend_thinker = abyssal_stalker_rend_thinker or class({
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
        return abyssal_stalker_rend:GetAbilityTextureName()
    end,
})
abyssal_stalker_rend_effect = abyssal_stalker_rend_effect or class({
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
        return abyssal_stalker_rend:GetAbilityTextureName()
    end,
})
LinkedModifiers["abyssal_stalker_rend_thinker"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_rend_effect"] = LUA_MODIFIER_MOTION_NONE

function abyssal_stalker_rend_thinker:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function abyssal_stalker_rend_thinker:OnTakeDamage(event)
    if not IsServer() then
        return
    end
    if event.unit ~= self:GetCaster() and event.attacker == self:GetCaster() and event.unit == self:GetParent() then
        local maxStacks = 1
        if (TalentTree:GetHeroTalentLevel(self:GetCaster(), 34) > 0) then
            maxStacks = 8
        end
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = event.unit
        modifierTable.ability = self:GetAbility()
        modifierTable.modifier_name = "abyssal_stalker_rend_effect"
        modifierTable.duration = 10
        modifierTable.stacks = 1
        modifierTable.max_stacks = maxStacks
        GameMode:ApplyStackingDebuff(modifierTable)
    end
end

function abyssal_stalker_rend_effect:OnCreated()
    if not IsServer() then
        return
    end
    self:StartIntervalThink(0.5)
end

function abyssal_stalker_rend_effect:OnIntervalThink()
    if not IsServer() then
        return
    end
    if self:GetStackCount() ~= 0 then
        local damageTable = {}
        damageTable.caster = self:GetCaster()
        damageTable.target = self:GetParent()
        damageTable.ability = self:GetAbility()
        damageTable.damage = 10000
        damageTable.voiddmg = true
        GameMode:DamageUnit(damageTable)
    end
end

abyssal_stalker_rend = abyssal_stalker_rend or class({})

function abyssal_stalker_rend:OnSpellStart()
    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
            self:GetCaster():GetAbsOrigin(),
            nil,
            600,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for key, unit in pairs(units) do
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = unit
        modifierTable.ability = self
        modifierTable.modifier_name = "abyssal_stalker_rend_thinker"
        modifierTable.duration = 15
        GameMode:ApplyDebuff(modifierTable)
    end
end

--TOXIFY AND TOXIC STRIKES--

abyssal_stalker_toxify_thinker = abyssal_stalker_toxify_thinker or class({
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
        return abyssal_stalker_toxify:GetAbilityTextureName()
    end,
})
abyssal_stalker_toxify_effect = abyssal_stalker_toxify_effect or class({
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
        return abyssal_stalker_toxify:GetAbilityTextureName()
    end,
})
LinkedModifiers["abyssal_stalker_toxify_thinker"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_toxify_effect"] = LUA_MODIFIER_MOTION_NONE

function abyssal_stalker_toxify_thinker:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function abyssal_stalker_toxify_thinker:OnTakeDamage(event)
    if not IsServer() then
        return
    end
    if event.unit ~= self:GetCaster() and event.attacker == self:GetCaster() and event.unit == self:GetParent() then
        local maxStacks = 1
        if (TalentTree:GetHeroTalentLevel(self:GetCaster(), 35) > 0) then
            maxStacks = 8
        end
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = event.unit
        modifierTable.ability = self:GetAbility()
        modifierTable.modifier_name = "abyssal_stalker_toxify_effect"
        modifierTable.duration = 10
        modifierTable.stacks = 1
        modifierTable.max_stacks = maxStacks
        GameMode:ApplyStackingDebuff(modifierTable)
    end
end

function abyssal_stalker_toxify_effect:OnCreated()
    if not IsServer() then
        return
    end
    self:StartIntervalThink(0.5)
end

function abyssal_stalker_toxify_effect:OnIntervalThink()
    if not IsServer() then
        return
    end
    if self:GetStackCount() ~= 0 then
        local damageTable = {}
        damageTable.caster = self:GetCaster()
        damageTable.target = self:GetParent()
        damageTable.ability = self:GetAbility()
        damageTable.damage = 10000
        damageTable.voiddmg = true
        GameMode:DamageUnit(damageTable)
    end
end

abyssal_stalker_toxify = abyssal_stalker_toxify or class({})

function abyssal_stalker_toxify:OnSpellStart()
    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
            self:GetCaster():GetAbsOrigin(),
            nil,
            600,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for key, unit in pairs(units) do
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = unit
        modifierTable.ability = self
        modifierTable.modifier_name = "abyssal_stalker_toxify_thinker"
        modifierTable.duration = 15
        GameMode:ApplyDebuff(modifierTable)
    end
end

--OVERLOAD  AND IGNITION--

abyssal_stalker_overload_aura = abyssal_stalker_overload_aura or class({
    IsAura = function(self)
        return true
    end,
    GetAuraRadius = function(self)
        return 800
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "abyssal_stalker_overload_effect"
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
    GetTexture = function(self)
        return abyssal_stalker_overload:GetAbilityTextureName()
    end,
})

abyssal_stalker_overload_effect = abyssal_stalker_overload_effect or class({
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
        return abyssal_stalker_overload:GetAbilityTextureName()
    end,
})

abyssal_stalker_ignition = abyssal_stalker_ignition or class({
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
})

LinkedModifiers["abyssal_stalker_overload_aura"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_overload_effect"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_ignition"] = LUA_MODIFIER_MOTION_NONE

function abyssal_stalker_overload_effect:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function abyssal_stalker_overload_effect:GetFireProtectionBonus()
    return -0.3
end
function abyssal_stalker_overload_effect:GetFrostProtectionBonus()
    return -0.3
end
function abyssal_stalker_overload_effect:GetEarthProtectionBonus()
    return -0.3
end
function abyssal_stalker_overload_effect:GetHolyProtectionBonus()
    return -0.3
end
function abyssal_stalker_overload_effect:GetVoidProtectionBonus()
    return -0.3
end
function abyssal_stalker_overload_effect:GetInfernoProtectionBonus()
    return -0.3
end
function abyssal_stalker_overload_effect:GetNatureProtectionBonus()
    return -0.3
end

function abyssal_stalker_overload_effect:OnTakeDamage(event)
    if not IsServer() then
        return
    end
    if event.unit == self:GetParent() and event.unit ~= self:GetCaster() and event.attacker == self:GetCaster() then
        if (TalentTree:GetHeroTalentLevel(self:GetCaster(), 36) > 0) then
            local modifierTable = {}
            modifierTable.caster = self:GetCaster()
            modifierTable.target = event.unit
            modifierTable.ability = self:GetAbility()
            modifierTable.modifier_name = "abyssal_stalker_ignition"
            modifierTable.duration = 6
            GameMode:ApplyDebuff(modifierTable)
        end
    end
end

function abyssal_stalker_ignition:OnCreated()
    if not IsServer() then
        return
    end
    self:StartIntervalThink(0.5)
end

function abyssal_stalker_ignition:OnIntervalThink()
    local damageTable = {}
    damageTable.caster = self:GetCaster()
    damageTable.target = self:GetParent()
    damageTable.ability = self:GetAbility()
    damageTable.damage = 100000
    damageTable.voiddmg = true
    damageTable.firedamage = true
    GameMode:DamageUnit(damageTable)
end

abyssal_stalker_overload = abyssal_stalker_overload or class({})

function abyssal_stalker_overload:OnToggle()
    local caster = self:GetCaster()
    if self:GetToggleState() == true and not caster:HasModifier("abyssal_stalker_overload_aura") then
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = self:GetCaster()
        modifierTable.ability = self
        modifierTable.modifier_name = "abyssal_stalker_overload_aura"
        modifierTable.duration = -1
        GameMode:ApplyDebuff(modifierTable)
    end
    if self:GetToggleState() == false then
        caster:RemoveModifierByName("abyssal_stalker_overload_aura")
    end
end

--FRIGID FORM AND FLASH FREEZE--

abyssal_stalker_frigid_form_aura = abyssal_stalker_frigid_form_aura or class({
    IsAura = function(self)
        return true
    end,
    GetAuraRadius = function(self)
        return 800
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "abyssal_stalker_frigid_form_effect"
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
    GetTexture = function(self)
        return abyssal_stalker_frigid_form:GetAbilityTextureName()
    end,
})

abyssal_stalker_frigid_form_effect = abyssal_stalker_frigid_form_effect or class({
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
        return abyssal_stalker_frigid_form:GetAbilityTextureName()
    end,
})

abyssal_stalker_flash_freeze = abyssal_stalker_flash_freeze or class({
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
})

LinkedModifiers["abyssal_stalker_frigid_form_aura"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_frigid_form_effect"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_flash_freeze"] = LUA_MODIFIER_MOTION_NONE

function abyssal_stalker_frigid_form_effect:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function abyssal_stalker_frigid_form_effect:GetAttackSpeedBonus()
    return -100
end
function abyssal_stalker_frigid_form_effect:GetMoveSpeedBonus()
    return -100
end

function abyssal_stalker_frigid_form_effect:OnTakeDamage(event)
    if not IsServer() then
        return
    end
    if event.unit == self:GetParent() and event.unit ~= self:GetCaster() and event.attacker == self:GetCaster() then
        if (TalentTree:GetHeroTalentLevel(self:GetCaster(), 37) > 0) and (30 >= RandomFloat(1, 100)) then
            local modifierTable = {}
            modifierTable.caster = self:GetCaster()
            modifierTable.target = event.unit
            modifierTable.ability = self:GetAbility()
            modifierTable.modifier_name = "abyssal_stalker_flash_freeze"
            modifierTable.duration = 1.5
            GameMode:ApplyDebuff(modifierTable)
        end
    end
end

function abyssal_stalker_flash_freeze:CheckStates()
    return { [MODIFIER_STATE_FROZEN] = true, }
end

abyssal_stalker_frigid_form = abyssal_stalker_frigid_form or class({})

function abyssal_stalker_frigid_form:OnToggle()
    local caster = self:GetCaster()
    if self:GetToggleState() == true and not caster:HasModifier("abyssal_stalker_frigid_form_aura") then
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = self:GetCaster()
        modifierTable.ability = self
        modifierTable.modifier_name = "abyssal_stalker_frigid_form_aura"
        modifierTable.duration = -1
        GameMode:ApplyDebuff(modifierTable)
    end
    if self:GetToggleState() == false then
        caster:RemoveModifierByName("abyssal_stalker_frigid_form_aura")
    end
end

--SILENT STRIKE AND CRIPPLE--
abyssal_stalker_silent_strike_effect = abyssal_stalker_silent_strike_effect or class({
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
        return abyssal_stalker_silent_strike:GetAbilityTextureName()
    end,
})

abyssal_stalker_silent_strike_blind = abyssal_stalker_silent_strike_blind or class({
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
        return abyssal_stalker_silent_strike:GetAbilityTextureName()
    end,
})

abyssal_stalker_cripple = abyssal_stalker_cripple or class({
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
})

LinkedModifiers["abyssal_stalker_silent_strike_effect"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_silent_strike_blind"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_cripple"] = LUA_MODIFIER_MOTION_NONE

function abyssal_stalker_silent_strike_effect:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function abyssal_stalker_silent_strike_effect:OnTakeDamage(event)
    if not IsServer() then
        return
    end
    if event.unit ~= self:GetCaster() and event.unit == self:GetParent() and event.attacker == self:GetCaster() then
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = self:GetParent()
        modifierTable.ability = self:GetAbility()
        modifierTable.modifier_name = "abyssal_stalker_silent_strike_blind"
        modifierTable.duration = 5
        GameMode:ApplyDebuff(modifierTable)
    end
end

function abyssal_stalker_silent_strike_blind:DeclareFunctions()
    return { MODIFIER_PROPERTY_MISS_PERCENTAGE }
end
function abyssal_stalker_silent_strike_blind:GetModifierMiss_Percentage()
    return 100
end

function abyssal_stalker_silent_strike_blind:OnDestroy()
    if not IsServer() then
        return
    end
    if (TalentTree:GetHeroTalentLevel(self:GetCaster(), 38) > 0) then
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = self:GetParent()
        modifierTable.ability = self:GetAbility()
        modifierTable.modifier_name = "abyssal_stalker_cripple"
        modifierTable.duration = 5
        GameMode:ApplyDebuff(modifierTable)
    end
end

function abyssal_stalker_cripple:CheckStates()
    return { [MODIFIER_STATE_DISARMED] = true, }
end

abyssal_stalker_silent_strike = abyssal_stalker_silent_strike or class({})

function abyssal_stalker_silent_strike:OnSpellStart()
    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
            self:GetCaster():GetAbsOrigin(),
            nil,
            600,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for key, unit in pairs(units) do
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = unit
        modifierTable.ability = self
        modifierTable.modifier_name = "abyssal_stalker_silent_strike_effect"
        modifierTable.duration = 10
        GameMode:ApplyDebuff(modifierTable)
    end
end

--IMPALE AND IMMOBILIZE--
abyssal_stalker_impale_effect = abyssal_stalker_impale_effect or class({
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
        return abyssal_stalker_impale:GetAbilityTextureName()
    end,
})

abyssal_stalker_impale_maim = abyssal_stalker_impale_maim or class({
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
        return abyssal_stalker_impale:GetAbilityTextureName()
    end,
})

abyssal_stalker_immobilize = abyssal_stalker_immobilize or class({
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
})

LinkedModifiers["abyssal_stalker_impale_effect"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_impale_maim"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_immobilize"] = LUA_MODIFIER_MOTION_NONE

function abyssal_stalker_impale_effect:DeclareFunctions()
    return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function abyssal_stalker_impale_effect:OnTakeDamage(event)
    if not IsServer() then
        return
    end
    if event.unit ~= self:GetCaster() and event.unit == self:GetParent() and event.attacker == self:GetCaster() then
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = self:GetParent()
        modifierTable.ability = self:GetAbility()
        modifierTable.modifier_name = "abyssal_stalker_impale_maim"
        modifierTable.duration = 5
        GameMode:ApplyDebuff(modifierTable)
    end
end

function abyssal_stalker_impale_maim:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ORDER }
end
function abyssal_stalker_impale_maim:OnOrder(event)
    if not IsServer() then
        return
    end
    if event.unit == self:GetParent() then
        local damageTable = {}
        damageTable.caster = self:GetCaster()
        damageTable.target = self:GetParent()
        damageTable.ability = self:GetAbility()
        damageTable.damage = 100000
        damageTable.voiddmg = true
        GameMode:DamageUnit(damageTable)
    end
end

function abyssal_stalker_impale_maim:OnDestroy()
    if not IsServer() then
        return
    end
    if (TalentTree:GetHeroTalentLevel(self:GetCaster(), 39) > 0) then
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = self:GetParent()
        modifierTable.ability = self:GetAbility()
        modifierTable.modifier_name = "abyssal_stalker_immobilize"
        modifierTable.duration = 5
        GameMode:ApplyDebuff(modifierTable)
    end
end

function abyssal_stalker_immobilize:CheckStates()
    return { [MODIFIER_STATE_ROOTED] = true, }
end

function abyssal_stalker_immobilize:OnCreated()
    if not IsServer() then
        return
    end
    self:StartIntervalThink(0.5)
end

function abyssal_stalker_immobilize:OnIntervalThink()
    if not IsServer() then
        return
    end
    local damageTable = {}
    damageTable.caster = self:GetCaster()
    damageTable.target = self:GetParent()
    damageTable.ability = self:GetAbility()
    damageTable.damage = 100000
    damageTable.naturedmg = true
    GameMode:DamageUnit(damageTable)
end

abyssal_stalker_impale = abyssal_stalker_impale or class({})

function abyssal_stalker_impale:OnSpellStart()
    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
            self:GetCaster():GetAbsOrigin(),
            nil,
            600,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for key, unit in pairs(units) do
        local modifierTable = {}
        modifierTable.caster = self:GetCaster()
        modifierTable.target = unit
        modifierTable.ability = self
        modifierTable.modifier_name = "abyssal_stalker_impale_effect"
        modifierTable.duration = 10
        GameMode:ApplyDebuff(modifierTable)
    end
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_abyssal_stalker", MotionController)
end