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

earthtower_tectonic = class({
    GetAbilityTextureName = function(self)
        return "earthtower_tectonic"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_earthtower_tectonic"
    end,
})

modifier_earthtower_tectonic = class({
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

function modifier_earthtower_tectonic:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.parent:StartGesture(ACT_DOTA_IDLE_RARE)
    self:StartIntervalThink(5)
end

function modifier_earthtower_tectonic:CheckState()
    return { [MODIFIER_STATE_STUNNED] = true,
    }
end

function earthtower_tectonic:ShootLinear( caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
    if (not IsServer()) then
        return
    end
    Timers:CreateTimer(1.1, function()
        caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.5)
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
            caster:RemoveGesture(ACT_DOTA_ATTACK)
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

function earthtower_tectonic:Launch(caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle,direction)
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
    self.wave = ParticleManager:CreateParticle("particles/units/earthtower/magnataur_shockwave_brown.vpcf", PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(self.wave, 0, caster_loc) --origin location
    ParticleManager:SetParticleControl(self.wave, 1, projectile.vVelocity) -- velocity
    ParticleManager:SetParticleControl(self.wave, 60, Vector(150,90,0))
    ParticleManager:SetParticleControl(self.wave, 61, Vector(1,0,0))
    ParticleManager:ReleaseParticleIndex(self.wave)
end



function earthtower_tectonic:ShootOnTop( caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
    if (not IsServer()) then
        return
    end
    --print("set")
    Timers:CreateTimer(1.1, function()
        caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.5)
    end)
    Timers:CreateTimer(2.0, function()
        Timers:CreateTimer(0.5, function()
            caster:RemoveGesture(ACT_DOTA_ATTACK)
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

function modifier_earthtower_tectonic:OnIntervalThink()
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
        local warning = "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf"
        self.nova_particle = ParticleManager:CreateParticle(warning, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(self.nova_particle, 1, Vector(300,300,300))
        ParticleManager:ReleaseParticleIndex(self.nova_particle)
        if #enemies> 0 and RollPercentage(75) then
            --75% chance turn at a hero and send directly on top of heroes if it finds hero nearby
            self.ability:ShootOnTop( caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
        else--25% chance turn randomly and send linear even found hero / it always sends linear if it doesn't find hero
            self.ability:ShootLinear(caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
        end
    end
end


function earthtower_tectonic:OnProjectileHit_ExtraData(hTarget, vLocation)
    if not hTarget then
        return nil
    end

    local caster = self:GetCaster()

    if caster:IsAlive()then
        local damage = self:GetSpecialValueFor("damage")
        local duration = self:GetSpecialValueFor("duration")
        local blocker_radius = self:GetSpecialValueFor( "blocker_radius" )
        local blocker_duration = self:GetSpecialValueFor( "blocker_duration" )
        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), self:GetCaster(), blocker_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO , DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
        for _,enemy in pairs( enemies ) do
            if enemy ~= nil and enemy:IsInvulnerable() == false and enemy:IsMagicImmune() == false then
                local kv =
                {
                    center_x = hTarget:GetOrigin().x,
                    center_y = hTarget:GetOrigin().y,
                    center_z = hTarget:GetOrigin().z,
                    should_stun = true,
                    duration = 0.25,
                    knockback_duration = 0.25,
                    knockback_distance = 250,
                    knockback_height = 125,
                }
                enemy:AddNewModifier( self:GetCaster(), self, "modifier_knockback", kv )
            end
        end
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = hTarget
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.earthdmg = true
        damageTable.physdmg = true
        GameMode:DamageUnit(damageTable)
        hTarget:EmitSound("Hero_Magnataur.ShockWave.Target")
        caster:EmitSound("Hero_EarthShaker.Fissure")

        --stunned
        local modifierTable = {}
        modifierTable.caster = caster
        modifierTable.target = hTarget
        modifierTable.ability = self
        modifierTable.modifier_name = "modifier_earthtower_stun"
        modifierTable.duration = duration
        GameMode:ApplyDebuff(modifierTable)
        --fissure


        local vFromCaster = vLocation - self:GetCaster():GetOrigin()
        vFromCaster = vFromCaster:Normalized()
        local vToCasterPerp  = Vector( -vFromCaster.y, vFromCaster.x, 0 )

        local vLoc1 = vLocation + vFromCaster * 200
        local vLoc2 = vLocation + vFromCaster * 200 + vToCasterPerp * 65
        local vLoc3 = vLocation + vFromCaster * 200 + vToCasterPerp * -65
        local vLoc4 = vLocation + vFromCaster * 200 + vToCasterPerp * 130
        local vLoc5 = vLocation + vFromCaster * 200 + vToCasterPerp * -130
        local vLoc6 = vLocation + vFromCaster * 200 + vToCasterPerp * 195
        local vLoc7 = vLocation + vFromCaster * 200 + vToCasterPerp * -195 --i cant make for loop remove thinker correctly it only removes the last one so this kekw

        local hThinker = CreateModifierThinker( self:GetCaster(), self, "modifier_earthshaker_fissure", {}, vLoc1, self:GetCaster():GetTeamNumber(), true )
        local hThinker2 = CreateModifierThinker( self:GetCaster(), self, "modifier_earthshaker_fissure", {}, vLoc2, self:GetCaster():GetTeamNumber(), true )
        local hThinker3 = CreateModifierThinker( self:GetCaster(), self, "modifier_earthshaker_fissure", {}, vLoc3, self:GetCaster():GetTeamNumber(), true )
        local hThinker4 = CreateModifierThinker( self:GetCaster(), self, "modifier_earthshaker_fissure", {}, vLoc4, self:GetCaster():GetTeamNumber(), true )
        local hThinker5 = CreateModifierThinker( self:GetCaster(), self, "modifier_earthshaker_fissure", {}, vLoc5, self:GetCaster():GetTeamNumber(), true )
        local hThinker6 = CreateModifierThinker( self:GetCaster(), self, "modifier_earthshaker_fissure", {}, vLoc6, self:GetCaster():GetTeamNumber(), true )
        local hThinker7 = CreateModifierThinker( self:GetCaster(), self, "modifier_earthshaker_fissure", {}, vLoc7, self:GetCaster():GetTeamNumber(), true )

        local effect_cast = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_ti9/earthshaker_fissure_ti9_lvl2.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl( effect_cast, 0, vLoc6 )
        ParticleManager:SetParticleControl( effect_cast, 1, vLoc7 )
        ParticleManager:SetParticleControl( effect_cast, 2, Vector( blocker_duration, 0, 0 ) )
        ParticleManager:ReleaseParticleIndex( effect_cast )
        Timers:CreateTimer(blocker_duration,function()
            ParticleManager:DestroyParticle(effect_cast, false)
        end)
        if hThinker ~= nil then
            hThinker:SetHullRadius( 65 )
            Timers:CreateTimer(blocker_duration,function()
                hThinker:RemoveSelf()
            end)
        end
        if hThinker2 ~= nil then
            hThinker2:SetHullRadius( 65 )
            Timers:CreateTimer(blocker_duration,function()
                hThinker2:RemoveSelf()
            end)
        end
        if hThinker3 ~= nil then
            hThinker3:SetHullRadius( 65 )
            Timers:CreateTimer(blocker_duration,function()
                hThinker3:RemoveSelf()
            end)
        end
        if hThinker4 ~= nil then
            hThinker4:SetHullRadius( 65 )
            Timers:CreateTimer(blocker_duration,function()
                hThinker4:RemoveSelf()
            end)
        end
        if hThinker5 ~= nil then
            hThinker5:SetHullRadius( 65 )
            Timers:CreateTimer(blocker_duration,function()
                hThinker5:RemoveSelf()
            end)
        end
        if hThinker6 ~= nil then
            hThinker6:SetHullRadius( 65 )
            Timers:CreateTimer(blocker_duration,function()
                hThinker6:RemoveSelf()
            end)
        end
        if hThinker7 ~= nil then
            hThinker7:SetHullRadius( 65 )
            Timers:CreateTimer(blocker_duration,function()
                hThinker7:RemoveSelf()
            end)
        end
    end
end

function modifier_earthtower_tectonic:OnDeath( params )
    if IsServer() then
        if params.unit == self.parent then
            self.parent:StartGesture(ACT_DOTA_DIE)
        end
    end
end



LinkLuaModifier("modifier_earthtower_tectonic", "creeps/tower/earthtower.lua", LUA_MODIFIER_MOTION_NONE)


modifier_earthtower_stun = class({
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
    GetTexture = function(self)
        return "earthshaker_fissure"
    end,
    GetEffectName = function(self)
        return "particles/generic_gameplay/generic_stunned.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end,
})

function modifier_earthtower_stun:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }
    return state
end


LinkLuaModifier("modifier_earthtower_stun", "creeps/tower/earthtower.lua", LUA_MODIFIER_MOTION_NONE)