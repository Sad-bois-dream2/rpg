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
-- crystal_sorceress_sheer_cold modifiers
modifier_crystal_sorceress_sheer_cold_aura = modifier_crystal_sorceress_sheer_cold_aura or class({
    IsHidden = function(self)
        return false
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
        return "modifier_crystal_sorceress_sheer_cold_aura_debuff"
    end,
    GetAuraDuration = function(self)
        return 0
    end
})

function modifier_crystal_sorceress_sheer_cold_aura:OnCreated()
    if(not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.radius = self.ability:GetSpecialValueFor("radius")

end

LinkedModifiers["modifier_crystal_sorceress_sheer_cold_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_sheer_cold_aura_debuff = modifier_crystal_sorceress_sheer_cold_aura_debuff or class({
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

LinkedModifiers["modifier_crystal_sorceress_sheer_cold_aura_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_crystal_sorceress_sheer_cold_aura_debuff_stacks = modifier_crystal_sorceress_sheer_cold_aura_debuff_stacks or class({
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

LinkedModifiers["modifier_crystal_sorceress_sheer_cold_aura_debuff_stacks"] = LUA_MODIFIER_MOTION_NONE

-- crystal_sorceress_sheer_cold
crystal_sorceress_sheer_cold = class({
    GetAbilityTextureName = function(self)
        return "crystal_sorceress_sheer_cold"
    end
})

function crystal_sorceress_sheer_cold:OnToggle()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    caster.crystal_sorceress_sheer_cold = caster.crystal_sorceress_sheer_cold or {}
    if (self:GetToggleState()) then
        caster.crystal_sorceress_sheer_cold.modifier = caster:AddNewModifier(caster, self, "modifier_crystal_sorceress_sheer_cold_aura", { Duration = -1 })
        self:EndCooldown()
        self:StartCooldown(self:GetCooldown(1))
        EmitSoundOn("Hero_Ancient_Apparition.IceVortexCast", caster)
    else
        if (caster.crystal_sorceress_sheer_cold.modifier ~= nil) then
            caster.crystal_sorceress_sheer_cold.modifier:Destroy()
        end
    end
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_crystal_sorceress", MotionController)
end