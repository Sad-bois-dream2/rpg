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

-- crystal_sorceress_sheer_cold
crystal_sorceress_sheer_cold = class({
    GetAbilityTextureName = function(self)
        return "crystal_sorceress_sheer_cold"
    end
})

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_crystal_sorceress", MotionController)
end