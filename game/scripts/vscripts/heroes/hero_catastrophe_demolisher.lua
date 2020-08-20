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
    if(not IsServer()) then
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
    if(not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_catastrophe_demolisher_curse_of_doom_aura_debuff:GetInfernoProtectionBonus()
    return self.ability.infernoRes
end

LinkedModifiers["modifier_catastrophe_demolisher_curse_of_doom_aura_debuff"] = LUA_MODIFIER_MOTION_NONE

catastrophe_demolisher_curse_of_doom = catastrophe_demolisher_curse_of_doom or class({
    GetAOERadius = function(self)
        return self.aoe
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_catastrophe_demolisher_curse_of_doom_aura"
    end
})

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
        if(self.threat > 0) then
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

catastrophe_demolisher_flaming_blast_stack = catastrophe_demolisher_flaming_blast_stack or class({
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
})

function catastrophe_demolisher_flaming_blast_stack:GetAttackPercentDamageBonus()
    local stacks = self:GetStackCount()
    local damage_per_stack = self:GetAbility():GetSpecialValueFor("damage_per_stack")
    return stacks * damage_per_stack
end

LinkedModifiers["catastrophe_demolisher_flaming_blast_stack"] = LUA_MODIFIER_MOTION_NONE

catastrophe_demolisher_flaming_blast = catastrophe_demolisher_flaming_blast or class({})

function catastrophe_demolisher_flaming_blast:OnSpellStart()
    local caster = self:GetCaster()
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            600,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for k, unit in pairs(units) do
        local info = {
            Target = unit,
            Source = caster,
            Ability = self,
            EffectName = "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf",
            iMoveSpeed = 800,
            vSourceLoc = caster:GetAbsOrigin(),
            bDrawsOnMinimap = false,
            bDodgeable = true,
            bIsAttack = false,
            bVisibleToEnemies = true,
            bReplaceExisting = false,
            flExpireTime = GameRules:GetGameTime() + 10,
            bProvidesVision = true,
            iVisionRadius = 400,
            iVisionTeamNumber = caster:GetTeamNumber()
        }
        projectile = ProjectileManager:CreateTrackingProjectile(info)
    end
end

function catastrophe_demolisher_flaming_blast:OnProjectileHit(hTarget, vLocation)
    local damage = self:GetCaster():GetMaxHealth() * self:GetSpecialValueFor("flame_damage") / 100
    local damageTable = {}
    damageTable.damage = damage
    damageTable.caster = self:GetCaster()
    damageTable.ability = self
    damageTable.target = hTarget
    damageTable.firedmg = true
    GameMode:DamageUnit(damageTable)
    local stacks_per_hit = 1
    if Enemies:IsBoss(target) then
        stacks_per_hit = 5
    elseif Enemies:IsElite(target) then
    end
    local modifierTable = {}
    modifierTable.caster = self:GetCaster()
    modifierTable.target = self:GetCaster()
    modifierTable.ability = self
    modifierTable.modifier_name = "catastrophe_demolisher_flaming_blast_stack"
    modifierTable.duration = 15
    modifierTable.max_stacks = 10
    modifierTable.stacks = stacks_per_hit
    GameMode:ApplyStackingBuff(modifierTable)
end

--BLOOD OBLATION--

catastrophe_demolisher_blood_oblation_effect = catastrophe_demolisher_blood_oblation_effect or class({
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
})

catastrophe_demolisher_blood_oblation_strength = catastrophe_demolisher_blood_oblation_strength or class({
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
})

function catastrophe_demolisher_blood_oblation_effect:OnCriticalDamage(damageTable)
    if not damageTable.ability and damageTable.physdmg then
        local modifierTable = {}
        modifierTable.ability = self:GetAbility()
        modifierTable.caster = self:GetCaster()
        modifierTable.target = self:GetCaster()
        modifierTable.modifier_name = "catastrophe_demolisher_blood_oblation_strength"
        modifierTable.duration = 15
        modifierTable.max_stacks = 10
        modifierTable.stacks = 1
        GameMode:ApplyStackingBuff(modifierTable)
    end
end

function catastrophe_demolisher_blood_oblation_effect:GetArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor_loss")
end

function catastrophe_demolisher_blood_oblation_effect:GetCriticalDamageBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_crit_damage")
end

function catastrophe_demolisher_blood_oblation_effect:GetCriticalChanceBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_crit_chance")
end

if IsServer() then
    GameMode:RegisterCritDamageEventHandler(Dynamic_Wrap(catastrophe_demolisher_blood_oblation_effect, 'OnCriticalDamage'))
end

function catastrophe_demolisher_blood_oblation_strength:GetStrengthPercentBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_strength") * self:GetStackCount()
end

LinkedModifiers["catastrophe_demolisher_blood_oblation_effect"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["catastrophe_demolisher_blood_oblation_strength"] = LUA_MODIFIER_MOTION_NONE

catastrophe_demolisher_blood_oblation = catastrophe_demolisher_blood_oblation or class({})

function catastrophe_demolisher_blood_oblation:OnSpellStart()
    local modifierTable = {}
    modifierTable.caster = self:GetCaster()
    modifierTable.target = self:GetCaster()
    modifierTable.ability = self
    modifierTable.modifier_name = "catastrophe_demolisher_blood_oblation_effect"
    modifierTable.duration = 15
    GameMode:ApplyBuff(modifierTable)
end

--ESSENCE DEVOURER--
catastrophe_demolisher_essence_devouer_aura = catastrophe_demolisher_essence_devouer_aura or class({
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
        return "catastrophe_demolisher_essence_devouer_effect"
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

catastrophe_demolisher_essence_devouer_effect = catastrophe_demolisher_essence_devouer_effect or class({
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

function catastrophe_demolisher_blood_oblation_effect:GetHealthRegenerationBonus()
    local perc = self:GetAbility():GetSpecialValueFor("hp_regen") / 100
    local regen = self:GetParent():GetMaxHealth() * perc
    return regen
end

if IsServer() then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(catastrophe_demolisher_essence_devouer_effect, 'OnTakeDamage'))
end

---@param damageTable DAMAGE_TABLE
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

LinkedModifiers["catastrophe_demolisher_essence_devouer_aura"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["catastrophe_demolisher_essence_devouer_effect"] = LUA_MODIFIER_MOTION_NONE

catastrophe_demolisher_essence_devouer = catastrophe_demolisher_essence_devouer or class({})

function catastrophe_demolisher_essence_devouer:GetIntrinsicModifierName()
    return "catastrophe_demolisher_essence_devouer_aura"
end

--CRIMSON FANATICISM--
catastrophe_demolisher_crimson_fanaticism_aura = catastrophe_demolisher_crimson_fanaticism_aura or class({
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

catastrophe_demolisher_crimson_fanaticism_effect = catastrophe_demolisher_crimson_fanaticism_effect or class({
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

catastrophe_demolisher_crimson_fanaticism_buff = catastrophe_demolisher_crimson_fanaticism_buff or class({
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

catastrophe_demolisher_crimson_fanaticism = catastrophe_demolisher_crimson_fanaticism or class({})

function catastrophe_demolisher_crimson_fanaticism:GetIntrinsicModifierName()
    return "catastrophe_demolisher_essence_devouer_aura"
end

--CLAYMORE OF DESTRUCTION--

catastrophe_demolisher_claymore_of_destruction_effect = catastrophe_demolisher_claymore_of_destruction_effect or class({
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

catastrophe_demolisher_claymore_of_destruction = catastrophe_demolisher_claymore_of_destruction or class({
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
