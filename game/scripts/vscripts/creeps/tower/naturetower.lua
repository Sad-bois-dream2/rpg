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

naturetower_felblight = class({
    GetAbilityTextureName = function(self)
        return "naturetower_felblight"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_naturetower_felblight"
    end,
})

modifier_naturetower_felblight = class({
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

function modifier_naturetower_felblight:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.parent:StartGesture(ACT_DOTA_IDLE)
    self:StartIntervalThink(5)
end

function modifier_naturetower_felblight:CheckState()
    return { [MODIFIER_STATE_STUNNED] = true,
    }
end

function naturetower_felblight:ShootLinear( caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
    if (not IsServer()) then
        return
    end
    Timers:CreateTimer(1.1, function()
        caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.8)
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

function naturetower_felblight:Launch(caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle,direction)
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
    self.wave = ParticleManager:CreateParticle("particles/units/naturetower/magnataur_shockwave_green.vpcf", PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(self.wave, 0, caster_loc) --origin location
    ParticleManager:SetParticleControl(self.wave, 1, projectile.vVelocity) -- velocity
    ParticleManager:SetParticleControl(self.wave, 60, Vector(75,255,-10))
    ParticleManager:SetParticleControl(self.wave, 61, Vector(1,0,0))
    ParticleManager:ReleaseParticleIndex(self.wave)
end



function naturetower_felblight:ShootOnTop( caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
    if (not IsServer()) then
        return
    end
    --print("set")
    Timers:CreateTimer(1.1, function()
        caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.8)
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

function modifier_naturetower_felblight:OnIntervalThink()
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
        local warning = "particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf"
        self.nova_particle = ParticleManager:CreateParticle(warning, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(self.nova_particle, 1, Vector(300,1,300))
        ParticleManager:ReleaseParticleIndex(self.nova_particle)
        if #enemies> 0 and RollPercentage(75) then
            --75% chance turn at a hero and send directly on top of heroes if it finds hero nearby.
            self.ability:ShootOnTop( caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
        else--25% chance turn randomly and send linear even found hero / it always sends linear if it doesn't find hero.
            self.ability:ShootLinear(caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
        end
    end
end


function naturetower_felblight:OnProjectileHit_ExtraData(target)
    if not target then
        return nil
    end

    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    local duration = self:GetSpecialValueFor("duration")
    if caster:IsAlive()then

        local modifierTable = {}
        modifierTable.caster = caster
        modifierTable.target = target
        modifierTable.ability = self
        modifierTable.modifier_name = "modifier_naturetower_felpoison"
        modifierTable.duration = duration
        modifierTable.stacks = 1
        modifierTable.max_stacks = 5
        GameMode:ApplyStackingDebuff(modifierTable)
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.naturedmg = true
        damageTable.infernodmg = true
        GameMode:DamageUnit(damageTable)
        target:EmitSound("Hero_Magnataur.ShockWave.Target")
        caster:EmitSound("hero_viper.viperStrikeImpact")
    end
end

function modifier_naturetower_felblight:OnDeath( params )
    if IsServer() then
        if params.unit == self.parent then
            self.parent:StartGestureWithPlaybackRate(ACT_DOTA_DIE, 0.5)
        end
    end
end


LinkLuaModifier("modifier_naturetower_felblight", "creeps/tower/naturetower.lua", LUA_MODIFIER_MOTION_NONE)


modifier_naturetower_felpoison = class({
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
        return "particles/units/heroes/hero_viper/viper_viper_strike_debuff.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end,
    GetTexture = function(self)
        return "viper_viper_strike"
    end
})

function modifier_naturetower_felpoison:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.stats = self.ability:GetSpecialValueFor("stats_decrease") * -0.01
    self.amp = self.ability:GetSpecialValueFor("amp")*-0.01
    self.slow = self.ability:GetSpecialValueFor("slow")*-0.01
    self.tick = self.ability:GetSpecialValueFor("tick")
    self.dot = self.ability:GetSpecialValueFor("dot")
    self:StartIntervalThink(self.tick)
end

function modifier_naturetower_felpoison:GetMoveSpeedPercentBonus()
    return self.slow * self:GetStackCount()
end

--rot from with in decrease stats
function modifier_naturetower_felpoison:GetStrengthPercentBonus() --max str reduciton that health still correct is 47% higher than this break health calcution idk why kek
    return self.stats* self:GetStackCount()
end

function modifier_naturetower_felpoison:GetAgilityPercentBonus()
    return self.stats * self:GetStackCount()
end

function modifier_naturetower_felpoison:GetIntellectPercentBonus()
    return self.stats * self:GetStackCount()
end

function modifier_naturetower_felpoison:GetPrimaryAttributePercentBonus()
    return self.stats* 0.5 * self:GetStackCount()
end

function modifier_naturetower_felpoison:GetDamageReductionBonus()
    return self.amp * self:GetStackCount()
end

function modifier_naturetower_felpoison:OnIntervalThink()
    if self.caster:IsAlive() then
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = self.parent
        damageTable.ability = self.ability
        damageTable.damage = self.dot * self:GetStackCount()
        damageTable.naturedmg = true
        GameMode:DamageUnit(damageTable)
    end
end

LinkLuaModifier("modifier_naturetower_felpoison", "creeps/tower/naturetower.lua", LUA_MODIFIER_MOTION_NONE)

