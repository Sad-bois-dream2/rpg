---------------------
-- brood toxin
---------------------

brood_toxin = class({
    GetAbilityTextureName = function(self)
        return "brood_toxin"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_brood_toxin"
    end,
})

--target:EmitSound("Hero_Slardar.Bash")


---------------------
-- brood comes
---------------------
brood_comes = class({
    GetAbilityTextureName = function(self)
        return "brood_comes"
    end,

})

function brood_comes:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()

    caster:EmitSound("broodmother_broo_move_09")

end


---------------------
-- brood cocoons
---------------------

brood_cocoons = class({
    GetAbilityTextureName = function(self)
        return "brood_cocoons"
    end,

})

function brood_cocoons:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local brood_cocoons_fx = ParticleManager:CreateParticle("particles/items5_fx/spider_legs_buff_webs.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
    caster:EmitSound("Hero_Broodmother.SpawnSpiderlingsCast")

end



---------------------
-- brood kiss
---------------------
brood_kiss = class({
    GetAbilityTextureName = function(self)
        return "brood_kiss"
    end,

})

function brood_kiss:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    caster:EmitSound("broodmother_broo_kill_12")
end

----------------
-- brood spit
---------------

brood_spit = class({
    GetAbilityTextureName = function(self)
        return "brood_spit"
    end,
})


function brood_spit:OnSpellStart()
    if (not IsServer()) then
        return
    end
    -- unit identifier
    self.caster = self:GetCaster()

    -- load data
    local duration = self:GetSpecialValueFor("duration")

    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = self.caster
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_brood_spit"
    modifierTable.duration = duration
    GameMode:ApplyBuff(modifierTable)
end

function brood_spit:GetAOERadius()
    return self:GetSpecialValueFor( "impact_radius" )
end

function brood_spit:OnProjectileHit( target, location )
    if (not IsServer()) then
        return
    end
    if not target then return end

    -- load data
    local damage = self:GetSpecialValueFor( "damage_per_impact" )
    local duration = self:GetSpecialValueFor( "burn_ground_duration" )
    local impact_radius = self:GetSpecialValueFor( "impact_radius" )
    local linger = self:GetSpecialValueFor("burn_linger_duration")
    -- precache damage

    local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),	-- int, your team number
            location,	-- point, center point
            nil,	-- handle, cacheUnit. (not known)
            impact_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,--int, order filter
            false	-- bool, can grow cache
    )

    for _,enemy in pairs(enemies) do
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = enemy
        damageTable.ability = self -- can be nil
        damageTable.damage = damage
        damageTable.naturedmg = true
        GameMode:DamageUnit(damageTable)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = enemy
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_brood_spit_burn_slow"
        modifierTable.duration = linger
        GameMode:ApplyDebuff(modifierTable)

    end

    -- start aura on thinker
    local mod = target:AddNewModifier(
            self:GetCaster(), -- player source
            self, -- ability source
            "modifier_brood_spit_thinker", -- modifier name
            { duration = duration, slow = 1,
            } -- kv
    )

    self:PlayEffects( location )
end


function brood_spit:PlayEffects( loc )
    if (not IsServer()) then
        return
    end
    -- Get Resources
    local particle_cast = "particles/units/npc_boss_brood/brood_spit_ground.vpcf"
    local sound_location = "Hero_Viper.NetherToxin"
    local duration = self:GetSpecialValueFor( "burn_ground_duration" )
    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
    ParticleManager:SetParticleControl( effect_cast, 0, loc )
    ParticleManager:SetParticleControl( effect_cast, 1, loc )
    Timers:CreateTimer(duration, function()
        ParticleManager:DestroyParticle(effect_cast, false)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end)

    -- Create Sound
    EmitSoundOnLocationWithCaster( loc, sound_location, self:GetCaster() )
end


modifier_brood_spit = modifier_brood_spit or class({

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
        return brood_spit:GetAbilityTextureName()
    end,
})



-- Initializations
function modifier_brood_spit:OnCreated( kv )
    if not IsServer() then return end
    -- references
    self.caster = self:GetAbility():GetCaster()
    self.min_range = self:GetAbility():GetSpecialValueFor( "min_range" )
    self.max_range = self:GetAbility():GetSpecialValueFor( "max_range" )
    self.range = self.max_range-self.min_range

    self.min_travel = self:GetAbility():GetSpecialValueFor( "min_lob_travel_time" )
    self.max_travel = self:GetAbility():GetSpecialValueFor( "max_lob_travel_time" )
    self.travel_range = self.max_travel-self.min_travel
    local projectile_count = self:GetAbility():GetSpecialValueFor( "projectile_count" )
    local interval = self:GetAbility():GetSpecialValueFor("duration")  / projectile_count + 0.01 -- so it only have 8 projectiles instead of 9
    -- Start interval
    self:StartIntervalThink( interval )
    self:OnIntervalThink()
end

LinkLuaModifier("modifier_brood_spit", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

-- Status Effects
function modifier_brood_spit:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

-- Interval Effects
function modifier_brood_spit:OnIntervalThink()
    self:CreateBlob()
end

function modifier_brood_spit:CreateBlob()
    if (not IsServer()) then
        return
    end
    local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
            self.caster:GetAbsOrigin(),
            nil,
            self.range,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        local projectile_landing_point =  enemy:GetAbsOrigin() --+ some random accuracy error?
        local origin = self:GetParent():GetOrigin()
        local vec = projectile_landing_point - origin
        local direction = vec
        direction.z = 0
        direction = direction:Normalized()

        if vec:Length2D()<self.min_range then
            vec = direction * self.min_range -- minimum range
        --elseif vec:Length2D()>self.max_range then
            --vec = direction * self.max_range --if farther than 3000 set to 3000
        end

        self.target = GetGroundPosition( origin + vec, nil )
        self.vector = vec
        self.travel_time = (vec:Length2D()-self.min_range)/self.range * self.travel_range + self.min_travel
        -- create target thinker
        local thinker = CreateModifierThinker(
                self:GetParent(), -- player source --brood
                self:GetAbility(), -- ability source
                "modifier_brood_spit_thinker", -- modifier name
                { travel_time = self.travel_time }, -- kv for landing indicator
                self.target,
                self:GetParent():GetTeamNumber(),
                false)
        -- load data
        --local projectile_speed = self:GetAbility():GetSpecialValueFor( "projectile_speed" ) -- not using this but just in case something dont work this can call projectile speed


        -- precache projectile
        self.info = {
            Target = thinker,
            Source = self:GetCaster(),
            Ability = self:GetAbility(),

            EffectName = "particles/units/npc_boss_brood/brood_spit_projectile.vpcf",
            iMoveSpeed = self.vector:Length2D() / self.travel_time,
            bDodgeable = false,                           -- Optional

            vSourceLoc = self:GetCaster():GetOrigin(),                -- Optional (HOW)

            bDrawsOnMinimap = false,                          -- Optional
            bVisibleToEnemies = true,                         -- Optional
        }

        -- launch projectile
        ProjectileManager:CreateTrackingProjectile( self.info )

    end

    -- play sound
    EmitSoundOn( "Hero_Viper.Nethertoxin.Cast", self:GetParent() )
end


modifier_brood_spit_burn_slow = modifier_brood_spit_burn_slow or class({

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
        return brood_spit:GetAbilityTextureName()
    end,
})


-- Initializations
function modifier_brood_spit_burn_slow:OnCreated( kv )
    -- references
    if (not IsServer()) then
        return
    end

    local interval = self:GetAbility():GetSpecialValueFor( "burn_interval" )
    self.slow = self:GetAbility():GetSpecialValueFor( "slow" ) * -0.01
    -- Start interval
    self:StartIntervalThink( interval )
    self:OnIntervalThink()
end

LinkLuaModifier("modifier_brood_spit_burn_slow", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)


function modifier_brood_spit_burn_slow:OnRefresh( kv )

end

function modifier_brood_spit_burn_slow:OnRemoved()
end

function modifier_brood_spit_burn_slow:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects

function modifier_brood_spit_burn_slow:GetMoveSpeedPercentBonus()
    return self.slow
end

function modifier_brood_spit_burn_slow:GetAttackSpeedPercentBonus()
    return self.slow
end

function modifier_brood_spit_burn_slow:GetSpellHasteBonus()
    return self.slow
end


--------------------------------------------------------------------------------
-- Interval Effects
function modifier_brood_spit_burn_slow:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local dps = self:GetAbility():GetSpecialValueFor("burn_damage")
    local parent            = self:GetParent()
    local caster            = self:GetCaster()
    -- apply damage
    local damageTable = {}
    damageTable.caster = caster
    damageTable.target = parent
    damageTable.ability = nil
    damageTable.damage = dps
    damageTable.naturedmg = true
    GameMode:DamageUnit(damageTable)

    -- play overhead
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_brood_spit_burn_slow:GetEffectName()
    return "particles/units/heroes/hero_broodmother/broodmother_poison_debuff.vpcf"
end

function modifier_brood_spit_burn_slow:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_brood_spit_burn_slow:GetStatusEffectName()
    return "particles/status_fx/status_effect_poison_viper.vpcf"
end

modifier_brood_spit_thinker = class({})


function modifier_brood_spit_thinker:OnCreated( kv )
    if (not IsServer()) then
        return
    end
    -- references
    self.max_travel = self:GetAbility():GetSpecialValueFor( "max_lob_travel_time" )
    self.radius = self:GetAbility():GetSpecialValueFor( "impact_radius" )
    self.linger = self:GetAbility():GetSpecialValueFor( "burn_linger_duration" )

    if not IsServer() then return end

    -- dont start aura right off
    self.start = false

    -- create aoe finder particle
    self:PlayEffects( kv.travel_time )
end

LinkLuaModifier("modifier_brood_spit_thinker", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_brood_spit_thinker:OnRefresh( kv )
    if (not IsServer()) then
        return
    end
    -- references
    self.max_travel = self:GetAbility():GetSpecialValueFor( "max_lob_travel_time" )
    self.radius = self:GetAbility():GetSpecialValueFor( "impact_radius" )
    self.linger = self:GetAbility():GetSpecialValueFor( "burn_linger_duration" )

    if not IsServer() then return end

    -- start aura
    self.start = true

    -- stop aoe finder particle
    self:StopEffects()
end

function modifier_brood_spit_thinker:OnRemoved()
end

function modifier_brood_spit_thinker:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Aura Effects
function modifier_brood_spit_thinker:IsAura()
    return self.start
end

function modifier_brood_spit_thinker:GetModifierAura()
    return "modifier_brood_spit_burn_slow"
end

function modifier_brood_spit_thinker:GetAuraRadius()
    return self.radius
end

function modifier_brood_spit_thinker:GetAuraDuration()
    return self.linger
end

function modifier_brood_spit_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_brood_spit_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_brood_spit_thinker:PlayEffects( time )
    if (not IsServer()) then
        return
    end
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf"

    -- Create Particle
    self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl( self.effect_cast, 0, self:GetParent():GetOrigin() )
    ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, 0, -self.radius*(self.max_travel/time) ) )
    ParticleManager:SetParticleControl( self.effect_cast, 2, Vector( time, 0, 0 ) )
end

function modifier_brood_spit_thinker:StopEffects()
    ParticleManager:DestroyParticle( self.effect_cast, true )
    ParticleManager:ReleaseParticleIndex( self.effect_cast )
end

----------------
-- brood hunger
----------------
brood_hunger = class({
    GetAbilityTextureName = function(self)
        return "brood_hunger"
    end,

})

function brood_kiss:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    caster:EmitSound("Hero_Broodmother.InsatiableHunger")
end

---------------------
-- brood web
---------------------
brood_web = class({
    GetAbilityTextureName = function(self)
        return "brood_web"
    end,

})

function brood_web:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    caster:EmitSound("broodmother_broo_move_09")
    caster:EmitSound("Hero_Broodmother.SpinWebCast")
    caster:EmitSound("broodmother_broo_ability_spin_01")
    --on spawn
    caster:EmitSound("broodmother_broo_ability_spawn_04")
end
