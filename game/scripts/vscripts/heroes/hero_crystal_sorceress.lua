local LinkedModifiers = {}

-- crystal_sorceress_frost_comet
crystal_sorceress_frost_comet = class({
    GetAbilityTextureName = function(self)
        return "crystal_sorceress_frost_comet"
    end,
    IsRequireCastbar = function(self)
        return true
    end
})

function crystal_sorceress_frost_comet:OnAbilityPhaseStart()
    if (not IsServer()) then
        return true
    end
    self.caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    local casterPosition = self.caster:GetAbsOrigin()
    local targetPosition = self.target:GetAbsOrigin()
    local direction = (targetPosition - casterPosition):Normalized()
    self.orbPosition = casterPosition + (direction * 100) + Vector(0, 0, 200)
    local lifeDuration = 2 * Units:GetSpellHaste(self.caster)
    self.pidx = ParticleManager:CreateParticle("particles/units/crystal_sorceress/frost_comet/crystal_sorceress_frost_comet_cast.vpcf", PATTACH_POINT, self.caster)
    ParticleManager:SetParticleControl(self.pidx, 0, self.orbPosition)
    ParticleManager:SetParticleControl(self.pidx, 1, Vector(0, lifeDuration, 0))
    EmitSoundOnLocationWithCaster(self.orbPosition, "Hero_Ancient_Apparition.ColdFeetCast", self.caster)
    Timers:CreateTimer(lifeDuration, function()
        if (self.pidx) then
            ParticleManager:DestroyParticle(self.pidx, false)
            ParticleManager:ReleaseParticleIndex(self.pidx)
        end
        StopSoundOn("Hero_Ancient_Apparition.ColdFeetCast", self.caster)
    end, self)
    return true
end

function crystal_sorceress_frost_comet:OnAbilityPhaseInterrupted()
    if (not IsServer()) then
        return
    end
    ParticleManager:DestroyParticle(self.pidx, true)
    ParticleManager:ReleaseParticleIndex(self.pidx)
end

function crystal_sorceress_frost_comet:OnProjectileHit()
    if (not IsServer()) then
        return
    end
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
    EmitSoundOn("Hero_Ancient_Apparition.ChillingTouch.Target", self.target)
    local procChance = self:GetSpecialValueFor("proc_chance")
    if (RollPercentage(procChance)) then
        local pidx = ParticleManager:CreateParticle("particles/units/crystal_sorceress/frost_comet/crystal_sorceress_frost_comet_hit_b.vpcf", PATTACH_ABSORIGIN, self.target)
        Timers:CreateTimer(2.0, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
        local enemies = FindUnitsInRadius(self.caster:GetTeam(),
                self.target:GetAbsOrigin(),
                nil,
                self:GetSpecialValueFor("proc_aoe"),
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        local damage = Units:GetHeroIntellect(self.caster) * self:GetSpecialValueFor("proc_damage") * 0.01
        for _, enemy in pairs(enemies) do
            local damageTable = {}
            damageTable.caster = self.caster
            damageTable.target = enemy
            damageTable.ability = self
            damageTable.damage = damage
            damageTable.frostdmg = true
            GameMode:DamageUnit(damageTable)
            local pidx = ParticleManager:CreateParticle("particles/units/crystal_sorceress/frost_comet/crystal_sorceress_frost_comet_hit_smoke.vpcf", PATTACH_POINT, enemy)
            ParticleManager:SetParticleControlEnt(pidx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
            Timers:CreateTimer(1.0, function()
                ParticleManager:DestroyParticle(pidx, false)
                ParticleManager:ReleaseParticleIndex(pidx)
            end)
        end
        return
    end
    local damageTable = {}
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self
    damageTable.damage = Units:GetHeroIntellect(self.caster) * self:GetSpecialValueFor("damage") * 0.01
    damageTable.frostdmg = true
    GameMode:DamageUnit(damageTable)
end

function crystal_sorceress_frost_comet:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local projectile = {
        Target = self.target,
        Ability = self,
        vSourceLoc = self.orbPosition,
        EffectName = "particles/units/crystal_sorceress/frost_comet/crystal_sorceress_frost_comet.vpcf",
        bDodgable = false,
        bProvidesVision = false,
        iMoveSpeed = 800
    }
    ProjectileManager:CreateTrackingProjectile(projectile)
    EmitSoundOn("Hero_Ancient_Apparition.ChillingTouch.Cast", self.caster)
end
-- crystal_sorceress_deep_freeze modifiers
modifier_crystal_sorceress_deep_freeze_aura = class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.radius or 0
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
        return "modifier_crystal_sorceress_deep_freeze_aura_debuff"
    end,
    GetAuraDuration = function(self)
        return 0
    end,
    GetEffectName = function(self)
        return "particles/units/crystal_sorceress/deep_freeze/deep_freeze.vpcf"
    end
})

function modifier_crystal_sorceress_deep_freeze_aura:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.radius = self.ability:GetSpecialValueFor("radius")
    self.mana = self.ability:GetSpecialValueFor("mana") / 100
    local tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
end

function modifier_crystal_sorceress_deep_freeze_aura:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local newMana = math.max(0, self.caster:GetMana() - (self.caster:GetMaxMana() * self.mana))
    self.caster:SetMana(newMana)
    if (newMana < 1) then
        self.ability:ToggleAbility()
        self:Destroy()
    end
end
LinkedModifiers["modifier_crystal_sorceress_deep_freeze_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_deep_freeze_aura_debuff = class({
    IsDebuff = function(self)
        return true
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

function modifier_crystal_sorceress_deep_freeze_aura_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetAuraOwner()
    self.target = self:GetParent()
    self.slowPerStack = self.ability:GetSpecialValueFor("slow_per_stack") / 100
    self.damagePerStack = self.ability:GetSpecialValueFor("damage_per_stack") / 100
    self.maxSlow = self.ability:GetSpecialValueFor("max_slow") / 100
    self.maxDamage = self.ability:GetSpecialValueFor("max_damage") / 100
    self.maxStacks = self.ability:GetSpecialValueFor("max_stacks")
    self.stunChance = self.ability:GetSpecialValueFor("stun_chance")
    self.stunDuration = self.ability:GetSpecialValueFor("stun_duration")
    self.stunCooldown = self.ability:GetSpecialValueFor("stun_cd")
    self.tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(self.tick)
end

function modifier_crystal_sorceress_deep_freeze_aura_debuff:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local modifierTable = {}
    modifierTable.ability = self.ability
    modifierTable.caster = self.caster
    modifierTable.target = self.target
    modifierTable.modifier_name = "modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks"
    modifierTable.modifier_params = {
        slowPerStack = self.slowPerStack,
        damagePerStack = self.damagePerStack,
        maxSlow = self.maxSlow,
        maxDamage = self.maxDamage
    }
    if (self.ability:GetLevel() > 3) then
        modifierTable.modifier_params.stunChance = self.stunChance
        modifierTable.modifier_params.stunDuration = self.stunDuration
        modifierTable.modifier_params.stunCooldown = self.stunCooldown
        modifierTable.modifier_params.tick = self.tick
    end
    modifierTable.duration = 1
    modifierTable.stacks = 1
    modifierTable.max_stacks = self.maxStacks
    GameMode:ApplyStackingDebuff(modifierTable)
end

LinkedModifiers["modifier_crystal_sorceress_deep_freeze_aura_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks = class({
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
        return crystal_sorceress_deep_freeze:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/crystal_sorceress/deep_freeze/deep_freeze_debuff.vpcf"
    end
})

function modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    if (not keys) then
        self:Destroy()
    end
    self.slowPerStack = keys.slowPerStack
    self.damagePerStack = keys.damagePerStack
    self.maxSlow = keys.maxSlow
    self.maxDamage = keys.maxDamage
    if (keys.stunChance) then
        self.stunChance = keys.stunChance
        self.stunDuration = keys.stunDuration
        self.stunCooldown = keys.stunCooldown
        self.tick = keys.tick
        self.ability = self:GetAbility()
        self.caster = self:GetCaster()
        self.target = self:GetParent()
        self:StartIntervalThink(self.tick)
    end
end

function modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    if (RollPercentage(self.stunChance) and not self.target:HasModifier("modifier_crystal_sorceress_deep_freeze_stun_cd")) then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.caster = self.caster
        modifierTable.target = self.target
        modifierTable.modifier_name = "modifier_crystal_sorceress_deep_freeze_stun_cd"
        modifierTable.duration = self.stunCooldown
        GameMode:ApplyDebuff(modifierTable)
        modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.caster = self.caster
        modifierTable.target = self.target
        modifierTable.modifier_name = "modifier_crystal_sorceress_deep_freeze_stun"
        modifierTable.duration = self.stunDuration
        GameMode:ApplyDebuff(modifierTable)
        EmitSoundOnLocationWithCaster(self.target:GetAbsOrigin(), "hero_Crystal.frostbite", self.target)
    end
end

function modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks:GetMoveSpeedPercentBonus()
    return math.min(-self:GetStackCount() * self.slowPerStack, self.maxSlow)
end

---@param damageTable DAMAGE_TABLE
function modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks")
    if (modifier and damageTable.damage > 0 and damageTable.frostdmg) then
        damageTable.damage = damageTable.damage * (1 + math.min(modifier:GetStackCount() * modifier.damagePerStack, modifier.maxDamage))
        return damageTable
    end
end

LinkedModifiers["modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_deep_freeze_stun = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    IsStunDebuff = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return crystal_sorceress_deep_freeze:GetAbilityTextureName()
    end,
    CheckState = function(self)
        return {
            [MODIFIER_STATE_STUNNED] = true,
            [MODIFIER_STATE_FROZEN] = true
        }
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
    end
})

LinkedModifiers["modifier_crystal_sorceress_deep_freeze_stun"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_deep_freeze_stun_cd = class({
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
        return crystal_sorceress_deep_freeze:GetAbilityTextureName()
    end
})

LinkedModifiers["modifier_crystal_sorceress_deep_freeze_stun_cd"] = LUA_MODIFIER_MOTION_NONE

-- crystal_sorceress_deep_freeze
crystal_sorceress_deep_freeze = class({
    GetAbilityTextureName = function(self)
        return "crystal_sorceress_deep_freeze"
    end
})

function crystal_sorceress_deep_freeze:OnToggle()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    caster.crystal_sorceress_deep_freeze = caster.crystal_sorceress_deep_freeze or {}
    if (self:GetToggleState()) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_crystal_sorceress_deep_freeze_aura"
        modifierTable.duration = -1
        caster.crystal_sorceress_deep_freeze.modifier = GameMode:ApplyBuff(modifierTable)
        self:EndCooldown()
        self:StartCooldown(self:GetCooldown(1))
        EmitSoundOn("Hero_Ancient_Apparition.IceVortexCast", caster)
    else
        if (caster.crystal_sorceress_deep_freeze.modifier ~= nil) then
            caster.crystal_sorceress_deep_freeze.modifier:Destroy()
        end
    end
end
-- crystal_sorceress_glacier_rush modifiers
modifier_crystal_sorceress_glacier_rush = class({
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
        return crystal_sorceress_glacier_rush:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_TOOLTIP }
    end
})

function modifier_crystal_sorceress_glacier_rush:OnTooltip()
    return self.critChancePerStack * self:GetStackCount() * 100
end

function modifier_crystal_sorceress_glacier_rush:OnCreated()
    self.ability = self:GetAbility()
    self.critChancePerStack = self.ability:GetSpecialValueFor("stack_crit") / 100
end

function modifier_crystal_sorceress_glacier_rush:GetCriticalChanceBonus()
    return self.critChancePerStack * self:GetStackCount()
end

LinkedModifiers["modifier_crystal_sorceress_glacier_rush"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_glacier_rush_stun = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    IsStunDebuff = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return crystal_sorceress_glacier_rush:GetAbilityTextureName()
    end,
    CheckState = function(self)
        return {
            [MODIFIER_STATE_STUNNED] = true,
            [MODIFIER_STATE_FROZEN] = true
        }
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
    end
})

LinkedModifiers["modifier_crystal_sorceress_glacier_rush_stun"] = LUA_MODIFIER_MOTION_NONE

-- crystal_sorceress_glacier_rush
crystal_sorceress_glacier_rush = class({
    GetAbilityTextureName = function(self)
        return "crystal_sorceress_glacier_rush"
    end
})

function crystal_sorceress_glacier_rush:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local casterPosition = caster:GetAbsOrigin()
    local targetPosition = self:GetCursorPosition()
    local direction = (targetPosition - casterPosition):Normalized()
    local width = self:GetSpecialValueFor("width")
    local range = self:GetSpecialValueFor("range")
    local lifeDuration = 2
    targetPosition = casterPosition + (direction * range)
    EmitSoundOn("Hero_Jakiro.IcePath", caster)
    local pidx = ParticleManager:CreateParticle("particles/econ/items/jakiro/jakiro_ti7_immortal_head/jakiro_ti7_immortal_head_ice_path_b.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx, 1, targetPosition)
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifeDuration, 0, 0))
    local pidx2 = ParticleManager:CreateParticle("particles/econ/items/jakiro/jakiro_ti7_immortal_head/jakiro_ti7_immortal_head_ice_path.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx2, 1, targetPosition)
    ParticleManager:SetParticleControl(pidx2, 2, Vector(lifeDuration, 0, 0))
    Timers:CreateTimer(lifeDuration, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
        ParticleManager:DestroyParticle(pidx2, false)
        ParticleManager:ReleaseParticleIndex(pidx2)
        StopSoundOn("Hero_Jakiro.IcePath", caster)
    end)
    local enemies = FindUnitsInLine(caster:GetTeam(),
            casterPosition,
            targetPosition,
            caster,
            width,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE)
    local damage = self:GetSpecialValueFor("damage") * Units:GetHeroIntellect(caster) * 0.01
    local stunDuration = self:GetSpecialValueFor("stun_duration")
    for _, enemy in pairs(enemies) do
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.frostdmg = true
        GameMode:DamageUnit(damageTable)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.caster = caster
        modifierTable.target = enemy
        modifierTable.modifier_name = "modifier_crystal_sorceress_glacier_rush_stun"
        modifierTable.duration = stunDuration
        GameMode:ApplyDebuff(modifierTable)
    end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.caster = caster
    modifierTable.target = caster
    modifierTable.modifier_name = "modifier_crystal_sorceress_glacier_rush"
    modifierTable.duration = self:GetSpecialValueFor("stacks_duration")
    modifierTable.stacks = #enemies
    modifierTable.max_stacks = self:GetSpecialValueFor("max_stacks")
    GameMode:ApplyStackingBuff(modifierTable)
end

modifier_crystal_sorceress_freezing_destruction_stun = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    IsStunDebuff = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return crystal_sorceress_freezing_destruction:GetAbilityTextureName()
    end,
    CheckState = function(self)
        return {
            [MODIFIER_STATE_STUNNED] = true,
            [MODIFIER_STATE_FROZEN] = true
        }
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
    end
})

LinkedModifiers["modifier_crystal_sorceress_freezing_destruction_stun"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_freezing_destruction = class({
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

function modifier_crystal_sorceress_freezing_destruction:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.bonusCritDamage = self.ability:GetSpecialValueFor("crit_dmg") * 0.01
end

function modifier_crystal_sorceress_freezing_destruction:OnCreated()
    return self.bonusCritDamage
end

function modifier_crystal_sorceress_freezing_destruction:OnPostTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_crystal_sorceress_freezing_destruction")
    if (modifier and damageTable.ability and damageTable.ability == modifier.ability) then
        modifier:Destroy()
    end
end

LinkedModifiers["modifier_crystal_sorceress_freezing_destruction"] = LUA_MODIFIER_MOTION_NONE

-- crystal_sorceress_freezing_destruction
crystal_sorceress_freezing_destruction = class({
    GetAbilityTextureName = function(self)
        return "crystal_sorceress_freezing_destruction"
    end,
    IsRequireCastbar = function(self)
        return true
    end
})

function crystal_sorceress_freezing_destruction:OnAbilityPhaseStart()
    if (not IsServer()) then
        return true
    end
    self.caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    EmitSoundOn("hero_Crystal.freezingField.wind", self.caster)
    self.pidx = ParticleManager:CreateParticle("particles/units/crystal_sorceress/freezing_destruction/freezing_destruction_cast.vpcf", PATTACH_ABSORIGIN, self.caster)
    ParticleManager:SetParticleControlEnt(self.pidx, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_staff1", self.caster:GetAbsOrigin(), true)
    return true
end

function crystal_sorceress_freezing_destruction:OnSpellStart()
    if (not IsServer()) then
        return
    end
    StopSoundOn("hero_Crystal.freezingField.wind", self.caster)
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.caster = self.caster
    modifierTable.target = self.target
    modifierTable.modifier_name = "modifier_crystal_sorceress_freezing_destruction_stun"
    modifierTable.duration = self:GetSpecialValueFor("stun_duration")
    GameMode:ApplyDebuff(modifierTable)
    EmitSoundOn("Hero_Ancient_Apparition.ColdFeetCast", self.target)
    local meteors = self:GetSpecialValueFor("meteors")
    local angleBetweenMeteors = 360 / meteors
    local distanceFromCenter = 200
    local targetPosition = self.target:GetAbsOrigin()
    local currentAngle = angleBetweenMeteors
    local particlesTable = {}
    local landTime = 0
    local meteorSpeed = 1250
    for i = 1, meteors do
        local angleInRadians = math.rad(currentAngle)
        local landPoint = Vector(targetPosition[1] + distanceFromCenter * math.cos(angleInRadians), targetPosition[2] + distanceFromCenter * math.sin(angleInRadians), targetPosition[3])
        local lengthVector = (landPoint - targetPosition)
        local direction = lengthVector:Normalized()
        local spawnPoint = landPoint + (direction * 800) + Vector(0, 0, 700)
        landTime = (landPoint - spawnPoint):Length() / meteorSpeed
        local pidx = ParticleManager:CreateParticle("particles/units/crystal_sorceress/freezing_destruction/freezing_destruction_projectile.vpcf", PATTACH_ABSORIGIN, self.caster)
        ParticleManager:SetParticleControl(pidx, 0, spawnPoint)
        ParticleManager:SetParticleControl(pidx, 1, landPoint)
        ParticleManager:SetParticleControl(pidx, 5, Vector(landTime, 0, 0))
        table.insert(particlesTable, { id = pidx, point = landPoint })
        currentAngle = currentAngle + angleBetweenMeteors
    end
    Timers:CreateTimer(landTime, function()
        local anotherParticleTable = {}
        local casterTeam = self.caster:GetTeam()
        local damageAoe = self:GetSpecialValueFor("damage_aoe")
        local damage = Units:GetHeroIntellect(self.caster) * self:GetSpecialValueFor("damage") * 0.01
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.caster = self.caster
        modifierTable.target = self.caster
        modifierTable.modifier_name = "modifier_crystal_sorceress_freezing_destruction"
        modifierTable.duration = -1
        local modifier = GameMode:ApplyBuff(modifierTable)
        for _, particleInfo in pairs(particlesTable) do
            ParticleManager:DestroyParticle(particleInfo.id, true)
            ParticleManager:ReleaseParticleIndex(particleInfo.id)
            local pidx = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf", PATTACH_ABSORIGIN, self.caster)
            ParticleManager:SetParticleControl(pidx, 0, particleInfo.point)
            local enemies = FindUnitsInRadius(casterTeam,
                    particleInfo.point,
                    nil,
                    damageAoe,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            for _, enemy in pairs(enemies) do
                local damageTable = {}
                damageTable.caster = self.caster
                damageTable.target = enemy
                damageTable.ability = self
                damageTable.damage = damage
                damageTable.frostdmg = true
                GameMode:DamageUnit(damageTable)
            end
            table.insert(anotherParticleTable, pidx)
        end
        modifier:Destroy()
        EmitSoundOn("Hero_Crystal.CrystalNova", self.target)
        Timers:CreateTimer(2, function()
            for _, pidx in pairs(anotherParticleTable) do
                ParticleManager:DestroyParticle(pidx, true)
                ParticleManager:ReleaseParticleIndex(pidx)
            end
        end, self)
    end, self)
end

function crystal_sorceress_freezing_destruction:OnAbilityPhaseInterrupted()
    if (not IsServer()) then
        return
    end
    StopSoundOn("hero_Crystal.freezingField.wind", self.caster)
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_crystal_sorceress", MotionController)
end

if (IsServer() and not GameMode.CRYSTAL_SORCERESS_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_crystal_sorceress_deep_freeze_aura_debuff_stacks, 'OnTakeDamage'))
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_crystal_sorceress_freezing_destruction, 'OnPostTakeDamage'))
    GameMode.CRYSTAL_SORCERESS_INIT = true
end