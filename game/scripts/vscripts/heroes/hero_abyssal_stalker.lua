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
    GetTexture = function(self)
        return abyssal_stalker_dance_of_darkness:GetAbilityTextureName()
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
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
        if(activeModifier) then
            proc = RollPercentage(self.ability.chanceActive)
        else
            proc = RollPercentage(self.ability.chance)
        end
        if(proc) then
            local modifierTable = {}
            modifierTable.ability = self.ability
            modifierTable.caster = self.caster
            modifierTable.target = self.caster
            modifierTable.modifier_name = "modifier_abyssal_stalker_dance_of_darkness_agi"
            modifierTable.duration = self.ability.stackDuration
            modifierTable.stacks = 1
            modifierTable.max_stacks = self.ability.maxStacks
            GameMode:ApplyStackingBuff(modifierTable)
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
    end,
    GetTexture = function(self)
        return abyssal_stalker_dance_of_darkness:GetAbilityTextureName()
    end,
})

LinkedModifiers["modifier_abyssal_stalker_dance_of_darkness_buff"] = LUA_MODIFIER_MOTION_NONE

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
    GetTexture = function(self)
        return abyssal_stalker_dance_of_darkness:GetAbilityTextureName()
    end,
})

function modifier_abyssal_stalker_dance_of_darkness_agi:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_abyssal_stalker_dance_of_darkness_agi:GetAgilityPercentBonus()
    return self:GetStackCount() * self.ability.agiPerStack
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
    self.agiPerStack = self:GetSpecialValueFor("agi_per_stack") / 100
    self.maxStacks = self:GetSpecialValueFor("max_stacks")
    self.stackDuration = self:GetSpecialValueFor("stack_duration")
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

modifier_abyssal_stalker_shadow_rush_instance = class({
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
        self:SetStackCount(math.min(self:GetStackCount() + 1, self.ability.maxShadows))
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
    if (not self.shadowsModifier) then
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
    if (strikes >= 0) then
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

modifier_abyssal_stalker_blade_of_abyss_crit = class({
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
        return abyssal_stalker_blade_of_abyss:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/abyssal_stalker/blade_of_abyss/blade_of_abyss_buff.vpcf"
    end
})

function modifier_abyssal_stalker_blade_of_abyss_crit:OnCreated()
    if(not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
end

function modifier_abyssal_stalker_blade_of_abyss_crit:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_abyssal_stalker_blade_of_abyss_crit")
    if (modifier and damageTable.damage > 0 and damageTable.physdmg and not damageTable.ability) then
        if damageTable.victim:GetForwardVector():Dot(damageTable.attacker:GetForwardVector()) >= 0 then
            damageTable.crit = modifier.ability.critBack
        else
            damageTable.crit = modifier.ability.crit
        end
        local victimPos = damageTable.victim:GetAbsOrigin()
        local coup_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, damageTable.victim)
        ParticleManager:SetParticleControlEnt(coup_pfx, 0, damageTable.victim, PATTACH_POINT_FOLLOW, "attach_hitloc", victimPos, true)
        ParticleManager:SetParticleControl(coup_pfx, 1, victimPos)
        ParticleManager:SetParticleControlOrientation(coup_pfx, 1, damageTable.attacker:GetForwardVector() * (-1), damageTable.attacker:GetRightVector(), damageTable.attacker:GetUpVector())
        Timers:CreateTimer(1, function()
            ParticleManager:DestroyParticle(coup_pfx, false)
            ParticleManager:ReleaseParticleIndex(coup_pfx)
        end)
        EmitSoundOn("Hero_PhantomAssassin.CoupDeGrace", damageTable.victim)
        modifier:Destroy()
        return damageTable
    end
end

LinkedModifiers["modifier_abyssal_stalker_blade_of_abyss_crit"] = LUA_MODIFIER_MOTION_NONE

abyssal_stalker_blade_of_abyss = class({
    GetAbilityTextureName = function(self)
        return "abyssal_stalker_blade_of_abyss"
    end,
})

function abyssal_stalker_blade_of_abyss:OnUpgrade()
    if(not IsServer()) then
        return
    end
    self.duration = self:GetSpecialValueFor("duration")
    self.crit = self:GetSpecialValueFor("damage") / 100
    self.critBack = self:GetSpecialValueFor("backstab_damage") / 100
end

function abyssal_stalker_blade_of_abyss:OnSpellStart()
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.caster = caster
    modifierTable.target = caster
    modifierTable.ability = self
    modifierTable.modifier_name = "modifier_abyssal_stalker_blade_of_abyss_crit"
    modifierTable.duration = self.duration
    GameMode:ApplyBuff(modifierTable)
    local modifierTable = {}
    modifierTable.caster = caster
    modifierTable.target = caster
    modifierTable.ability = self
    modifierTable.modifier_name = "modifier_rune_invis"
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

LinkedModifiers["modifier_abyssal_stalker_void_dust_buff"] = LUA_MODIFIER_MOTION_NONE

abyssal_stalker_void_dust = class({
    GetAbilityTextureName = function(self)
        return "abyssal_stalker_void_dust"
    end,
})

function abyssal_stalker_void_dust:OnUpgrade()
    self.protection = self:GetSpecialValueFor("magic_res") / 100
    self.resist = self:GetSpecialValueFor("status_res") / 100
    self.duration = self:GetSpecialValueFor("duration")
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
    local particle = ParticleManager:CreateParticle("particles/units/abyssal_stalker/void_dust/void_dust.vpcf", PATTACH_ABSORIGIN, modifierTable.caster)
    Timers:CreateTimer(1, function()
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end)
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
    GetTexture = function(self)
        return abyssal_stalker_gaze_of_abyss:GetAbilityTextureName()
    end,
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
abyssal_stalker_rend_thinker = class({
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
abyssal_stalker_rend_effect = class({
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

abyssal_stalker_rend = class({})

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

abyssal_stalker_toxify_thinker = class({
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
abyssal_stalker_toxify_effect = class({
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

abyssal_stalker_toxify = class({})

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

abyssal_stalker_overload_aura = class({
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

abyssal_stalker_overload_effect = class({
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

abyssal_stalker_ignition = class({
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

abyssal_stalker_overload = class({})

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

abyssal_stalker_frigid_form_aura = class({
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

abyssal_stalker_frigid_form_effect = class({
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

abyssal_stalker_flash_freeze = class({
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

abyssal_stalker_frigid_form = class({})

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
abyssal_stalker_silent_strike_effect = class({
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

abyssal_stalker_silent_strike_blind = class({
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

abyssal_stalker_cripple = class({
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

abyssal_stalker_silent_strike = class({})

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
abyssal_stalker_impale_effect = class({
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

abyssal_stalker_impale_maim = class({
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

abyssal_stalker_immobilize = class({
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

abyssal_stalker_impale = class({})

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
if (IsServer() and not GameMode.ABYSSAL_STALKER_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_abyssal_stalker_blade_of_abyss_crit, 'OnTakeDamage'))
    GameMode.ABYSSAL_STALKER_INIT = true
end

for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_abyssal_stalker", MotionController)
end