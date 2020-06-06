--stationary elite/miniboss tower

function RotateVectorAroundAngle( vec, angle )
    local x = vec[1]
    local y = vec[2]
    angle = angle * 0.01745
    local vec2 = Vector(0,0,0)
    vec2[1] = x * math.cos(angle) - y * math.sin(angle)
    vec2[2] = x * math.sin(angle) + y * math.cos(angle)
    return vec2
end

holytower_holyfrost = class({
    GetAbilityTextureName = function(self)
        return "holytower_holyfrost"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_holytower_holyfrost"
    end,
})

modifier_holytower_holyfrost = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH,
        }
    end,

})

function modifier_holytower_holyfrost:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.parent:StartGesture(ACT_DOTA_CUSTOM_TOWER_IDLE)
    local mouth_fx = "particles/econ/world/towers/ti10_radiant_tower/ti10_radiant_tower_ambient.vpcf"
    self.nPreviewFX = ParticleManager:CreateParticle( mouth_fx, PATTACH_ABSORIGIN_FOLLOW, self.parent )
    ParticleManager:SetParticleControlEnt(self.nPreviewFX, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_mouth", self.parent:GetAbsOrigin(), true)
    self:StartIntervalThink(5)
end

function modifier_holytower_holyfrost:CheckState()
    return { [MODIFIER_STATE_STUNNED] = true,
    }
end

function holytower_holyfrost:ShootLinear( caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
    if (not IsServer()) then
        return
    end
    Timers:CreateTimer(1.1, function()
        caster:StartGestureWithPlaybackRate(ACT_DOTA_CUSTOM_TOWER_ATTACK, 0.8)
    end)
    --print("linear")
    local angleLeft
    local direction = caster:GetForwardVector()
    local direction_face
    --turning
    angleLeft =  math.random(-30,30)
    direction_face = RotateVectorAroundAngle(direction, angleLeft)
    caster:SetForwardVector(direction_face)
    Timers:CreateTimer(2.0,function()
        Timers:CreateTimer(0.5, function()
            caster:RemoveGesture(ACT_DOTA_CUSTOM_TOWER_ATTACK)
        end)
        --linear
        for  i =  0, 4, 1 do
            --particle
            angleLeft =  i * (90 /4) -45
            direction = RotateVectorAroundAngle(direction_face, angleLeft)
            self:Launch(caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle,direction)

        end
        -- Play cast sound
        caster:EmitSound("Hero_Magnataur.ShockWave.Particle")
    end)
end

function holytower_holyfrost:Launch(caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle,direction)
    local projectile =
    {
        Ability				= self,
        EffectName			= arrow_particle,
        vSpawnOrigin		= caster_loc,
        fDistance			= travel_distance,
        fStartRadius		= start_radius,
        fEndRadius			= end_radius,
        Source				= caster,
        bHasFrontalCone		= false,
        bReplaceExisting	= false,
        iUnitTargetTeam		= self:GetAbilityTargetTeam(),
        iUnitTargetFlags	= nil,
        iUnitTargetType		= self:GetAbilityTargetType(),
        fExpireTime 		= GameRules:GetGameTime() + 10.0,
        bDeleteOnHit		= true,
        vVelocity			= Vector(direction.x,direction.y,0) * projectile_speed,
        bProvidesVision		= false,
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    self.wave = ParticleManager:CreateParticle("particles/units/holytower/magnataur_shockwave_blue.vpcf", PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(self.wave, 0, caster_loc) --origin location
    ParticleManager:SetParticleControl(self.wave, 1, projectile.vVelocity) -- velocity
    ParticleManager:SetParticleControl(self.wave, 60, Vector(0,0,255))
    ParticleManager:SetParticleControl(self.wave, 61, Vector(1,0,0))
    ParticleManager:ReleaseParticleIndex(self.wave)
end



function holytower_holyfrost:ShootOnTop( caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
    if (not IsServer()) then
        return
    end
    --print("set")
    Timers:CreateTimer(1.1, function()
        caster:StartGestureWithPlaybackRate(ACT_DOTA_CUSTOM_TOWER_ATTACK, 0.8)
    end)
    Timers:CreateTimer(2.0, function()
        Timers:CreateTimer(0.5, function()
            caster:RemoveGesture(ACT_DOTA_CUSTOM_TOWER_ATTACK)
        end)
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                2000,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        --print(#enemies)
        local enemypos = enemies[1]:GetAbsOrigin()
        local direction_face = (enemypos-caster_loc):Normalized()
        caster:SetForwardVector(direction_face)
        for _, enemy in pairs(enemies) do
            local enemy_loc = enemy:GetAbsOrigin()
            local direction_to_enemy
            local direction
            local distance = enemy_loc - caster_loc
            direction_to_enemy = distance:Normalized()
            local angleLeft
            if #enemies < 2 then --shoot 5 if 1
                for  i =  0, 4, 1 do
                    angleLeft =  i * (90 /4) -45
                    direction = RotateVectorAroundAngle(direction_to_enemy, angleLeft)
                    self:Launch(caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle,direction)
                end
            elseif #enemies < 4 then --shoot 3 if 2-3
                for  i =  0, 2, 1 do
                    angleLeft =  i * (60 /2) -30
                    direction = RotateVectorAroundAngle(direction_to_enemy, angleLeft)
                    self:Launch(caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle,direction)
                end
            else --shoot 2 if 4 -5
                for i = 0,1,1 do
                    angleLeft =  i * 15 * math.random(-1,1)
                    direction = RotateVectorAroundAngle(direction_to_enemy, angleLeft)
                    self:Launch(caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle,direction)
                end
            end
        end

        -- Play cast sound
        caster:EmitSound("Hero_Magnataur.ShockWave.Particle")
    end)
end

function modifier_holytower_holyfrost:OnIntervalThink()
    local caster = self:GetParent()
    local caster_loc = caster:GetAbsOrigin()
    -- Ability specials
    local travel_distance = self.ability:GetSpecialValueFor("range")
    local start_radius = self.ability:GetSpecialValueFor("radius")
    local end_radius = self.ability:GetSpecialValueFor("radius")
    local projectile_speed = self.ability:GetSpecialValueFor("projectile_speed")
    local arrow_particle = nil --"particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf"
    caster:EmitSound("Hero_Magnataur.ShockWave.Cast")
    if caster:IsAlive() then
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                2000,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        --print(#enemies)
        local warning = "particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova.vpcf"
        local start_particle = ParticleManager:CreateParticle(warning, PATTACH_ABSORIGIN, caster)
        ParticleManager:ReleaseParticleIndex(start_particle)
        if #enemies> 0 and RollPercentage(75) then
            --75% chance turn at a hero and send directly on top of heroes if it finds hero nearby
            self.ability:ShootOnTop( caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
        else--25% chance turn randomly and send linear even found hero / it always sends linear if it doesn't find hero
            self.ability:ShootLinear(caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
        end
    end
end

function holytower_holyfrost:OnProjectileHit_ExtraData(target)
    if not target then
        return nil
    end

    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    local duration = self:GetSpecialValueFor("duration")
    if caster:IsAlive()then
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.frostdmg = true
        damageTable.holydmg = true
        GameMode:DamageUnit(damageTable)
        target:EmitSound("Hero_Magnataur.ShockWave.Target")
        caster:EmitSound("Hero_Crystal.Frostbite")
        local modifierTable = {}
        modifierTable.caster = caster
        modifierTable.target = target
        modifierTable.ability = self
        modifierTable.modifier_name = "modifier_holytower_frostbite"
        modifierTable.duration = duration
        GameMode:ApplyDebuff(modifierTable)
    end
end

function modifier_holytower_holyfrost:OnDeath( params )
    if IsServer() then
        if params.unit == self.parent then
            local death_fx = "particles/econ/world/towers/ti10_radiant_tower/ti10_radiant_tower_destruction.vpcf"
            self.destruction = ParticleManager:CreateParticle( death_fx, PATTACH_ABSORIGIN_FOLLOW, self.parent )
            ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
            ParticleManager:ReleaseParticleIndex(self.destruction)
            self.parent:SetModelScale(0)
        end
    end
end

LinkLuaModifier("modifier_holytower_holyfrost", "creeps/tower/holytower.lua", LUA_MODIFIER_MOTION_NONE)


modifier_holytower_frostbite = class({
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
    GetEffectName = function(self)
        return  "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end,
    GetTexture = function(self)
        return "crystal_maiden_frostbite"
    end,
    DeclareFunctions = function(self)
        return {MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE} -- increase by percentage
    end
})

function modifier_holytower_frostbite:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.dot = self.ability:GetSpecialValueFor("dot")
    self.tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(self.tick)
end

function modifier_holytower_frostbite:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_FROZEN] =true,
    }
    return state
end

function modifier_holytower_frostbite:GetModifierTurnRate_Percentage() --% add to current turnrate -- tested this one add not subtract
    return -100
end
--set 0
function modifier_holytower_frostbite:GetSpellDamageBonusMulti()
    return 0
end

function modifier_holytower_frostbite:GetAttackDamagePercentBonusMulti()
    return 0
end

function modifier_holytower_frostbite:GetHealingCausedPercentBonusMulti()
    return 0
end

function modifier_holytower_frostbite:OnIntervalThink()
    if self.caster:IsAlive() then
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = self.parent
        damageTable.ability = self.ability
        damageTable.damage = self.dot
        damageTable.frostdmg = true
        GameMode:DamageUnit(damageTable)
    end
end

LinkLuaModifier("modifier_holytower_frostbite", "creeps/tower/holytower.lua", LUA_MODIFIER_MOTION_NONE)
