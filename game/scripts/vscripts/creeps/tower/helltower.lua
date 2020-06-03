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

helltower_hellfire = class({
    GetAbilityTextureName = function(self)
        return "helltower_hellfire"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_helltower_hellfire"
    end,
})

modifier_helltower_hellfire = class({
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

function modifier_helltower_hellfire:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.parent:StartGesture(ACT_DOTA_CUSTOM_TOWER_IDLE)
    local mouth_fx = "particles/econ/world/towers/ti10_dire_tower/ti10_dire_tower_ambient.vpcf"
    self.nPreviewFX = ParticleManager:CreateParticle( mouth_fx, PATTACH_ABSORIGIN_FOLLOW, self.parent )
    ParticleManager:SetParticleControlEnt(self.nPreviewFX, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_mouth", self.parent:GetAbsOrigin(), true)
    self:StartIntervalThink(5)
end

function modifier_helltower_hellfire:CheckState()
    return { [MODIFIER_STATE_STUNNED] = true,
            }
end

function helltower_hellfire:ShootLinear( caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
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

function helltower_hellfire:Launch(caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle,direction)
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
    self.wave = ParticleManager:CreateParticle("particles/units/helltower/magnataur_shockwave_red.vpcf", PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(self.wave, 0, caster_loc) --origin location
    ParticleManager:SetParticleControl(self.wave, 1, projectile.vVelocity) -- velocity
    ParticleManager:SetParticleControl(self.wave, 60, Vector(150,5,5))
    ParticleManager:SetParticleControl(self.wave, 61, Vector(1,0,0))
    ParticleManager:ReleaseParticleIndex(self.wave)
end



function helltower_hellfire:ShootOnTop( caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
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

function modifier_helltower_hellfire:OnIntervalThink()
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
        local warning = "particles/units/helltower/lina_spell_light_strike_array_no_black.vpcf"
        local start_particle = ParticleManager:CreateParticle(warning, PATTACH_ABSORIGIN, caster)
        Timers:CreateTimer(1.0,function()
        ParticleManager:DestroyParticle(start_particle, false)
        ParticleManager:ReleaseParticleIndex(start_particle)
        end)
        if #enemies> 0 and RollPercentage(75) then
            --75% chance turn at a hero and send directly on top of heroes if it finds hero nearby
            self.ability:ShootOnTop( caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
        else--25% chance turn randomly and send linear even found hero / it always sends linear if it doesn't find hero
            self.ability:ShootLinear(caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed, arrow_particle)
        end
    end
end


function helltower_hellfire:OnProjectileHit_ExtraData(target)
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
        damageTable.voiddmg = true
        damageTable.firedmg = true
        GameMode:DamageUnit(damageTable)
        target:EmitSound("Hero_Magnataur.ShockWave.Target")
        caster:EmitSound("Hero_EmberSpirit.SearingChains.Target")
        local modifierTable = {}
        modifierTable.caster = caster
        modifierTable.target = target
        modifierTable.ability = self
        modifierTable.modifier_name = "modifier_helltower_hellchain"
        modifierTable.duration = duration
        GameMode:ApplyDebuff(modifierTable)
    end
end

function modifier_helltower_hellfire:OnDeath( params )
    if IsServer() then
        if params.unit == self.parent then
            local death_fx = "particles/econ/world/towers/ti10_dire_tower/ti10_dire_tower_destruction.vpcf"
            self.destruction = ParticleManager:CreateParticle( death_fx, PATTACH_ABSORIGIN_FOLLOW, self.parent )
            ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
            ParticleManager:ReleaseParticleIndex(self.destruction)
            self.parent:SetModelScale(0)
        end
    end
end



LinkLuaModifier("modifier_helltower_hellfire", "creeps/tower/helltower.lua", LUA_MODIFIER_MOTION_NONE)


modifier_helltower_hellchain = class({
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
        return "particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_debuff.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end,
    GetTexture = function(self)
        return "ember_spirit_searing_chains"
    end
})

function modifier_helltower_hellchain:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.dot = self.ability:GetSpecialValueFor("dot")
    self.mana_burn = self.ability:GetSpecialValueFor("mana_burn") * 0.01
    self.slow = self.ability:GetSpecialValueFor("slow") * -0.01
    self.tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(self.tick)
end

function modifier_helltower_hellchain:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
    }
    return state
end

function modifier_helltower_hellchain:GetSpellHastePercentBonus()
    return self.slow
end

function modifier_helltower_hellchain:GetAttackSpeedPercentBonus()
    return self.slow
end
--reduce these by 1000%
function modifier_helltower_hellchain:GetHealthRegenerationPercentBonus()
    return -10
end

function modifier_helltower_hellchain:GetHealingReceivedPercentBonus()
    return -10 -- finalHeal = heal * this
end

function modifier_helltower_hellchain:OnIntervalThink()
    if self.caster:IsAlive() then
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = self.parent
        damageTable.ability = self.ability
        damageTable.damage = self.dot
        damageTable.firedmg = true
        GameMode:DamageUnit(damageTable)
        local Max_mana = self.parent:GetMaxMana()
        local burn = Max_mana * self.mana_burn
        self.parent:ReduceMana(burn)
    end
end

LinkLuaModifier("modifier_helltower_hellchain", "creeps/tower/helltower.lua", LUA_MODIFIER_MOTION_NONE)

