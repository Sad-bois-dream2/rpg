------------
--HELPER FUNCTION
-------------------
function IsUnitInProximity(start_point, end_point, target_position, ice_wall_radius)
    -- craete vector which makes up the ice wall
    local ice_wall = end_point - start_point
    -- create vector for target relative to start_point of the ice wall
    local target_vector = target_position - start_point

    local ice_wall_normalized = ice_wall:Normalized()
    -- create a dot vector of the normalized ice_wall vector
    local ice_wall_dot_vector = target_vector:Dot(ice_wall_normalized)
    -- here we will store the targeted enemies closest position
    local search_point
    -- if all the datapoints in the dot vector is below 0 then the target is outside our search hence closest point is start_point.
    if ice_wall_dot_vector <= 0 then
        search_point = start_point

        -- if all th datapoinst in the dot vector is above the max length of our search then there closest point is the end_point
    elseif ice_wall_dot_vector >= ice_wall:Length2D() then
        search_point = end_point

        -- if a datapoinst in the dot vector within range then the closest position is...
    else
        search_point = start_point + (ice_wall_normalized * ice_wall_dot_vector)
    end
    -- with all that setup we can now get the distance from our ice_wall! :D
    local distance = target_position - search_point
    -- Is the distance less then our "area of effect" radius? true/false
    return distance:Length2D() <= ice_wall_radius
end



---------------------
--venge_missile modifier
---------------------
venge_missile = class({
    GetAbilityTextureName = function(self)
        return "venge_missile"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_venge_missile"
    end,
})

function venge_missile:ExplodeFX(ele, target, radius)
    --visual
    local position = target:GetAbsOrigin()
    local particle = ParticleManager:CreateParticle(ele, PATTACH_POINT_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, position)
    ParticleManager:SetParticleControl(particle, 1, position)
    ParticleManager:SetParticleControl(particle, 2, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(particle)
end


function venge_missile:ApplyMoondaze(enemy, main_target, parent)
    self.duration = self:GetSpecialValueFor("duration")
    self.radius = self:GetSpecialValueFor("radius")
    local displacement = enemy:GetAbsOrigin() - main_target:GetAbsOrigin()
    local distance = displacement:Length2D()
    local splash_max = self:GetSpecialValueFor("splash_max")*0.01
    local splash_min = self:GetSpecialValueFor("splash_min")*0.01
    --slow use a stack counter
    local slow_max = self:GetSpecialValueFor("slow_max")
    local slow_min = self:GetSpecialValueFor("slow_min")
    local AA = parent:GetAttackDamage()
    local slope_damage = (splash_max -splash_min)/self.radius
    local slope_speed = (slow_max - slow_min)/self.radius
    --near radius max damage min slow
    if distance < 300 then
        distance = 0
    end
    local damage = AA * (splash_max - slope_damage* distance)
    local stacks = slow_min + slope_speed * distance
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = enemy
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_venge_missile_slow"
    modifierTable.duration = self.duration
    modifierTable.stacks = stacks
    modifierTable.max_stacks = 200
    GameMode:ApplyStackingDebuff(modifierTable)
    local damageTable = {}
    damageTable.caster = parent
    damageTable.target = enemy
    damageTable.ability = self
    damageTable.damage = damage
    damageTable.physdmg = true
    GameMode:DamageUnit(damageTable)
    if parent:HasModifier("modifier_venge_side_fire") then
        damageTable = {}
        damageTable.caster = parent
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.firedmg = true
        GameMode:DamageUnit(damageTable)
    end
    if parent:HasModifier("modifier_venge_side_frost") then
        damageTable = {}
        damageTable.caster = parent
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.frostdmg = true
        GameMode:DamageUnit(damageTable)
    end
    if parent:HasModifier("modifier_venge_side_earth") then
        damageTable = {}
        damageTable.caster = parent
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.earthdmg = true
        GameMode:DamageUnit(damageTable)
    end
    if parent:HasModifier("modifier_venge_side_void") then
        damageTable = {}
        damageTable.caster = parent
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.voiddmg = true
        GameMode:DamageUnit(damageTable)
    end
    if parent:HasModifier("modifier_venge_side_holy") then
        damageTable = {}
        damageTable.caster = parent
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.holydmg = true
        GameMode:DamageUnit(damageTable)
    end
    if parent:HasModifier("modifier_venge_side_nature") then
        damageTable = {}
        damageTable.caster = parent
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.naturedmg = true
        GameMode:DamageUnit(damageTable)
    end
    if parent:HasModifier("modifier_venge_side_inferno") then
        damageTable = {}
        damageTable.caster = parent
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.infernodmg = true
        GameMode:DamageUnit(damageTable)
    end
end

modifier_venge_missile = class({
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
    AllowIllusionDuplicate = function(self)
        return false
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_venge_missile:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    --if(IsServer()) then
        --Inventory:CreateItemOnGround(HeroList:GetHero(0), HeroList:GetHero(0):GetAbsOrigin(), "item_silver_ring")end
end

function modifier_venge_missile:OnAttackLanded(keys)
    --start cd
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.radius = self.ability:GetSpecialValueFor("radius")
    if (keys.attacker == self.parent) then

        -- Find all nearby enemies
        local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(),
                keys.target:GetAbsOrigin(),
                nil,
                self.radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)

        for _, enemy in pairs(enemies) do
            self.ability:ApplyMoondaze(enemy, keys.target, self.parent)
        end
        --local ele_phys ="particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_aoe.vpcf" -- i think players' eyes will bleed repeatedly seeing this shit
        --keys.target:EmitSound("Hero_KeeperOfTheLight.BlindingLight")
        --self.ability:ExplodeFX(ele_phys, keys.target, self.radius)
    end
end

LinkLuaModifier("modifier_venge_missile", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

modifier_venge_missile_slow = class({
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
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_drow_frost_arrow.vpcf"
    end,
    DeclareFunctions = function(self)
        return {MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE} -- increase by percentage
    end
})

function modifier_venge_missile_slow:OnCreated()
    if not IsServer() then
        return
    end
end

function modifier_venge_missile_slow:GetModifierTurnRate_Percentage() --% add to current turnrate -- tested this one add not subtract
    self.stacks = self:GetStackCount() -- 1% slow each stack
    self.turn_rate_slow = -self.stacks
    --if self.turn_rate_slow < -95 then -- max turn rate slow 95% -- seems like turn rate cant be 0 so prolly dont need this
        --self.turn_rate_slow = -95
    --end
    return self.turn_rate_slow
end

function modifier_venge_missile_slow:GetMoveSpeedPercentBonus()
    return self:GetStackCount()* -0.01
end

LinkLuaModifier("modifier_venge_missile_slow", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

--------------
--venge sky
---------------

modifier_venge_sky = class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return true
    end,
    DeclareFunctions = function(self)
        return {MODIFIER_PROPERTY_FIXED_DAY_VISION,
                MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
                MODIFIER_EVENT_ON_DEATH }
    end
})

function modifier_venge_sky:OnCreated()
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.ability = self:GetAbility()
    self.fixed_vision = self.ability:GetSpecialValueFor("fixed_vision")
    self:StartIntervalThink(29)
    self:OnIntervalThink()
end

function modifier_venge_sky:GetFixedDayVision()
    return self.fixed_vision
end

function modifier_venge_sky:GetFixedNightVision()
    return self.fixed_vision
end

function modifier_venge_sky:OnDeath(params)
    if (not IsServer()) then
        return
    end
    if params.unit == self.caster  then
        self:Destroy()
    end
end

function modifier_venge_sky:OnIntervalThink()
    self.game_mode = GameRules:GetGameModeEntity()
    GameRules:BeginTemporaryNight(30)
end


LinkLuaModifier("modifier_venge_sky", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

venge_sky = class({
    GetAbilityTextureName = function(self)
        return "venge_sky"
    end,
})

function venge_sky:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local caster_position = self:GetCaster():GetAbsOrigin()
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                30000,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_venge_sky"
            modifierTable.duration = -1
            GameMode:ApplyDebuff(modifierTable)
        end
        self:GetCaster():EmitSound("Hero_Nightstalker.Darkness.Team")
        local particle_moon = "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf"
        local particle_darkness = "particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf"
        local particle_darkness_fx = ParticleManager:CreateParticle(particle_darkness, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(particle_darkness_fx, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_darkness_fx, 1, caster:GetAbsOrigin())
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(particle_darkness_fx, false)
            ParticleManager:ReleaseParticleIndex(particle_darkness_fx)
        end)
        local particle_moon_fx = ParticleManager:CreateParticle(particle_moon, PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(particle_moon_fx, 0, Vector(caster_position.x, caster_position.y, caster_position.z + 400))
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(particle_moon_fx, false)
            ParticleManager:ReleaseParticleIndex(particle_moon_fx)
        end)
    end
end

------------
--venge side
------------
venge_side = class({
    GetAbilityTextureName = function(self)
        return "venge_side"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_venge_side"
    end
})


function venge_side:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.already_infused  = 0
    self.max_infuse = self:GetSpecialValueFor("max_infuse")
    self.infuse_modifier =
    {
        "modifier_venge_side_fire",
        "modifier_venge_side_frost",
        "modifier_venge_side_earth",
        "modifier_venge_side_void",
        "modifier_venge_side_holy",
        "modifier_venge_side_nature",
        "modifier_venge_side_inferno"

    }
end

function venge_side:InfuseFX(chosen)
    if chosen == "modifier_venge_side_fire" then
    self.nPreviewFX = ParticleManager:CreateParticle( "particles/econ/items/lina/lina_ti7/lina_spell_light_strike_array_ti7.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    elseif chosen == "modifier_venge_side_void" then
    self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/npc_boss_venge/venge_control/nevermore_wings_purple.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    elseif chosen == "modifier_venge_side_frost" then
    self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    elseif chosen == "modifier_venge_side_holy" then
    self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_chen/chen_holy_persuasion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    elseif chosen == "modifier_venge_side_earth" then
    self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    elseif chosen == "modifier_venge_side_nature" then
    self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/npc_boss_treant/treant_flux/flux_gather.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    elseif chosen == "modifier_venge_side_inferno" then
    self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/heroes/heroes_underlord/underlord_firestorm_pre.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    end
    ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
end

function venge_side:Infuse()
    if (not IsServer()) then
        return
    end
    if self.already_infused < self.max_infuse then
        local caster = self:GetCaster()
        local number = RandomInt(1, #self.infuse_modifier)
        local chosen = self.infuse_modifier[number]
        table.remove(self.infuse_modifier,number) -- dont pepeg and  infuse same ele
        self.already_infused = self.already_infused + 1
        self:InfuseFX(chosen)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = chosen
        modifierTable.duration = -1
        GameMode:ApplyBuff(modifierTable)
    end
end

modifier_venge_side = class({
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
        return { MODIFIER_EVENT_ON_TAKEDAMAGE }
    end
})

function modifier_venge_side:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.health_start_counting_point = 1
    Timers:CreateTimer(0.1,function() -- seem like difficulty fuck this up with max health manipulation or get 0 if call too fast so 0.1 delay
        self.health_per_infuse = self.ability:GetSpecialValueFor("health_per_infuse") * 0.01
        self.Max_Health = self.parent:GetMaxHealth()
    end)
end

function modifier_venge_side:OnTakeDamage(keys)
    if (not IsServer()) then
        return
    end
    --each time damage is taken, compare health loss proportion to health distance to next triggering point
    --so if health change 1 => 0.87 this will trigger infuse because 0.13> 0.12 and set new trigger point to 0.88, the 0.87 have 0.01 < 0.12 wont trigger next infusion
    --however if 1=>0.75 this will trigger 1 infuse 0.25 > 0.12 then 0.88-0.75=0.13 still > 0.12 another infuse > double infusiong in one damage instance
    if keys.unit == self.parent then
        self.health_loss = self.health_start_counting_point  - (self.parent:GetHealth()/self.Max_Health)
        --print(self.health_per_infuse)
        --print(self.health_loss)
        --print(self.health_start_counting_point)
        Timers:CreateTimer(0, function()
            if self.health_loss > self.health_per_infuse then -- loop to check if a big damage instance triggers more than one infusion
                self.ability:Infuse()
                self.health_start_counting_point = self.health_start_counting_point - self.health_per_infuse
                self.health_loss = self.health_start_counting_point  - (self.parent:GetHealth()/self.Max_Health)
                return 0.1
            end
        end)
    end
end

LinkLuaModifier("modifier_venge_side", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)


modifier_venge_side_fire = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    GetTexture = function(self)
        return venge_fall:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
    end
})

function modifier_venge_side_fire:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.as = self.ability:GetSpecialValueFor("fire_as") *0.01
    self.resist = self.ability:GetSpecialValueFor("resist") * 0.01
end

function modifier_venge_side_fire:GetFireProtectionBonus()
    return self.resist
end

function modifier_venge_side_fire:GetAttackSpeedPercentBonus()
    return self.as
end

LinkLuaModifier("modifier_venge_side_fire", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

modifier_venge_side_frost = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    GetTexture = function(self)
        return venge_tide:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH }
    end,

})

function modifier_venge_side_frost:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.resist = self.ability:GetSpecialValueFor("resist") * 0.01
    self.parent = self:GetParent()
    self.buff_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.buff_fx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(self.buff_fx, false, false, -1, false, false)
    Timers:CreateTimer(6,function()
        if not self.parent:HasModifier("modifier_venge_side_frost") then
            ParticleManager:DestroyParticle(self.buff_fx, false)
            ParticleManager:ReleaseParticleIndex(self.buff_fx)
        end
    end)
end

function modifier_venge_side_frost:GetFrostProtectionBonus()
    return self.resist
end
-- any damage preemptively instance apply slow
---@param damageTable DAMAGE_TABLE
function modifier_venge_side_frost:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_venge_side_frost")
    if (damageTable.damage > 0 and modifier ) then
        local modifierTable = {}
        modifierTable.ability = modifier:GetAbility()
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_venge_side_frost_slow"
        modifierTable.duration = 4  --modifier:GetAbility():GetSpecialValueFor("duration")
        GameMode:ApplyDebuff(modifierTable)
    end
end

function modifier_venge_side_frost:OnDeath(params)
    if (params.unit == self.parent) then
        ParticleManager:DestroyParticle(self.buff_fx, false)
        ParticleManager:ReleaseParticleIndex(self.buff_fx)
    end
end



LinkLuaModifier("modifier_venge_side_frost", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

modifier_venge_side_frost_slow = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    GetTexture = function(self)
        return venge_tide:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_slow.vpcf"
    end
})

function modifier_venge_side_frost_slow:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.slow = self.ability:GetSpecialValueFor("frost_slow") *-0.01
end

function modifier_venge_side_frost_slow:GetAttackSpeedPercentBonus()
    return self.slow
end

function modifier_venge_side_frost_slow:GetMoveSpeedPercentBonus()
    return self.slow
end

function modifier_venge_side_frost_slow:GetSpellHastePercentBonus()
    return self.slow
end
LinkLuaModifier("modifier_venge_side_frost_slow", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

modifier_venge_side_earth = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    GetTexture = function(self)
        return venge_quake:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH }
    end,
})

function modifier_venge_side_earth:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.dmg_reduction = self.ability:GetSpecialValueFor("earth_dmg_reduction") * 0.01
    self.resist = self.ability:GetSpecialValueFor("resist") * 0.01
    self.parent = self:GetParent()
    self.buff_fx = ParticleManager:CreateParticle("particles/units/npc_boss_venge/venge_side/sven_warcry_buff_brown.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControlEnt(self.buff_fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.buff_fx, 1, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(self.buff_fx, false, false, -1, false, false)
    Timers:CreateTimer(6,function()
        if not self.parent:HasModifier("modifier_venge_side_earth") then
            ParticleManager:DestroyParticle(self.buff_fx, false)
            ParticleManager:ReleaseParticleIndex(self.buff_fx)
        end
    end)
end

function modifier_venge_side_earth:GetEarthProtectionBonus()
    return self.resist
end

function modifier_venge_side_earth:GetDamageReductionBonus()
    return self.dmg_reduction
end

function modifier_venge_side_earth:OnDeath(params)
    if (params.unit == self.parent) then
        ParticleManager:DestroyParticle(self.buff_fx, false)
        ParticleManager:ReleaseParticleIndex(self.buff_fx)
    end
end

LinkLuaModifier("modifier_venge_side_earth", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

modifier_venge_side_void = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    GetTexture = function(self)
        return venge_mind_control:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH }
    end,
})

function modifier_venge_side_void:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.resist = self.ability:GetSpecialValueFor("resist") * 0.01
    self.parent = self:GetParent()
    local fx = "particles/units/npc_boss_venge/venge_side/invoker_apex_wex_orb_ring.vpcf"
    self.buff_fx = ParticleManager:CreateParticle(fx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.buff_fx, 0, self:GetParent(),PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.buff_fx, 3, self:GetParent(),PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
    Timers:CreateTimer(6,function()
        if not self.parent:HasModifier("modifier_venge_side_void") then
            ParticleManager:DestroyParticle(self.buff_fx, false)
            ParticleManager:ReleaseParticleIndex(self.buff_fx)
        end
    end)

end


function modifier_venge_side_void:GetVoidProtectionBonus()
    return self.resist
end

-- any damage instance apply manaburn after damage is taken
---@param damageTable DAMAGE_TABLE
function modifier_venge_side_void:OnPostTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_venge_side_void")
    if (damageTable.damage > 0 and modifier ) then
        local Max_Mana = damageTable.victim:GetMaxMana()
        local Mana = damageTable.victim:GetMana()
        local burn = Max_Mana * modifier:GetAbility():GetSpecialValueFor("void_mana_burn")*0.01
        if burn > Mana then
            burn = Mana
        end
        local damage = burn * modifier:GetAbility():GetSpecialValueFor("void_per_burn")*0.01
        damageTable.victim:ReduceMana(burn)
        damageTable.victim:EmitSound("Hero_Antimage.ManaBreak")
        local manaburn_pfx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/am_manaburn_basher_ti_5.vpcf", PATTACH_ABSORIGIN_FOLLOW, damageTable.victim)
        ParticleManager:SetParticleControl(manaburn_pfx, 0, damageTable.victim:GetAbsOrigin() )
        ParticleManager:ReleaseParticleIndex(manaburn_pfx)
        --deal another instance of damage
        damageTable.damage = damage
        damageTable.voiddmg = true
        GameMode:DamageUnit(damageTable)
    end
end
function modifier_venge_side_void:OnDeath(params)
    if (params.unit == self.parent) then
        ParticleManager:DestroyParticle(self.buff_fx, false)
        ParticleManager:ReleaseParticleIndex(self.buff_fx)
    end
end
LinkLuaModifier("modifier_venge_side_void", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

modifier_venge_side_holy = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH }
    end,
    GetTexture = function(self)
        return venge_moonify:GetAbilityTextureName()
    end,
})

function modifier_venge_side_holy:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.resist = self.ability:GetSpecialValueFor("resist") * 0.01
    self.particle_wings = "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf"
    self.particle_wings_fx = ParticleManager:CreateParticle(self.particle_wings, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.particle_wings_fx, 0, self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(self.particle_wings_fx, 5, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
    self:AddParticle(self.particle_wings_fx, false, false, -1, false, false)
    Timers:CreateTimer(6,function()
        if not self.parent:HasModifier("modifier_venge_side_holy") then
            ParticleManager:DestroyParticle(self.particle_wings_fx, false)
            ParticleManager:ReleaseParticleIndex(self.particle_wings_fx)
        end
    end)
end

function modifier_venge_side_holy:GetHolyProtectionBonus()
    return self.resist
end

-- any damage preemptively instance apply miss and fumble
---@param damageTable DAMAGE_TABLE
function modifier_venge_side_holy:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_venge_side_holy")
    if (damageTable.damage > 0 and modifier ) then
        local modifierTable = {}
        modifierTable.ability = modifier:GetAbility()
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_venge_side_holy_miss"
        modifierTable.duration = 4  --modifier:GetAbility():GetSpecialValueFor("duration")
        GameMode:ApplyDebuff(modifierTable)
    end
end

function modifier_venge_side_holy:OnDeath(params)
    if (params.unit == self.parent) then
        ParticleManager:DestroyParticle(self.particle_wings_fx, false)
        ParticleManager:ReleaseParticleIndex(self.particle_wings_fx)
    end
end

LinkLuaModifier("modifier_venge_side_holy", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

modifier_venge_side_holy_miss = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    DeclareFunctions = function(self)
        return {MODIFIER_PROPERTY_MISS_PERCENTAGE,
                MODIFIER_EVENT_ON_ABILITY_START}
    end,
    GetTexture = function(self)
        return venge_moonify:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_keeper_of_the_light/keeper_dazzling_debuff.vpcf"
    end,
})

function modifier_venge_side_holy_miss:OnCreated(params)
    if (not IsServer()) then
        return
    end
    self.miss_chance = self:GetAbility():GetSpecialValueFor("holy_miss")
    self.silence = self:GetAbility():GetSpecialValueFor("holy_silence")
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
end

function modifier_venge_side_holy_miss:GetModifierMiss_Percentage()
    return self.miss_chance
end

function modifier_venge_side_holy_miss:OnAbilityStart(keys)
    if (not IsServer()) then
        return
    end -- cancel spellcast with silence
    if keys.unit == self.parent and RollPercentage(self.miss_chance)  then
        local modifierTable = {}
        modifierTable.ability = self:GetAbility()
        modifierTable.target = self.parent
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_venge_side_holy_silence"
        modifierTable.duration = self.silence
        GameMode:ApplyDebuff(modifierTable)
    end
end

LinkLuaModifier("modifier_venge_side_holy_miss", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

modifier_venge_side_holy_silence = class({
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
        return "particles/units/heroes/hero_skywrath_mage/skywrath_mage_ancient_seal_debuff.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end,
    GetTexture = function(self)
        return venge_moonify:GetAbilityTextureName()
    end
})

function modifier_venge_side_holy_silence:CheckState()
    local state = { [MODIFIER_STATE_SILENCED] = true, }
    return state
end

LinkLuaModifier("modifier_venge_side_holy_silence", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

modifier_venge_side_nature = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    GetTexture = function(self)
        return venge_root:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH }
    end,
})

function modifier_venge_side_nature:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.resist = self.ability:GetSpecialValueFor("resist") * 0.01
    self.regen = self.ability:GetSpecialValueFor("nature_regen") * 0.01
    self.parent = self:GetParent()
    local Max_Health = self.parent:GetMaxHealth()
    self.regen_final = Max_Health * self.regen + 1
    local armor = "particles/units/heroes/hero_treant/treant_livingarmor.vpcf"
    self.healFX = ParticleManager:CreateParticle(armor, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControlEnt(self.healFX, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(self.healFX, false, false, -1, false, false)
    Timers:CreateTimer(6,function()
        if not self.parent:HasModifier("modifier_venge_side_nature") then
            ParticleManager:DestroyParticle(self.healFX , false)
            ParticleManager:ReleaseParticleIndex(self.healFX )
        end
    end)
end

function modifier_venge_side_nature:GetNatureProtectionBonus()
    return self.resist
end

function modifier_venge_side_nature:GetHealthRegenerationBonus()
    return self.regen_final
end

function modifier_venge_side_nature:OnDeath(params)
    if (params.unit == self.parent) then
        ParticleManager:DestroyParticle(self.healFX, false)
        ParticleManager:ReleaseParticleIndex(self.healFX)
    end
end

LinkLuaModifier("modifier_venge_side_nature", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)


modifier_venge_side_inferno = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    GetTexture = function(self)
        return venge_fel:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH }
    end,
})

function modifier_venge_side_inferno:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.resist = self.ability:GetSpecialValueFor("resist") * 0.01
    self.parent = self:GetParent()
    local necroflame = "particles/econ/items/necrolyte/necro_ti9_immortal/necro_ti9_immortal_loadout_steam.vpcf"
    self.fx = ParticleManager:CreateParticle(necroflame, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControlEnt(self.fx, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
    Timers:CreateTimer(6,function()
        if not self.parent:HasModifier("modifier_venge_side_inferno") then
            ParticleManager:DestroyParticle(self.fx, false)
            ParticleManager:ReleaseParticleIndex(self.fx)
        end
    end)
end

function modifier_venge_side_inferno:GetInfernoProtectionBonus()
    return self.resist
end

function modifier_venge_side_inferno:OnDeath(params)
    if (params.unit == self.parent) then
        ParticleManager:DestroyParticle(self.fx, false)
        ParticleManager:ReleaseParticleIndex(self.fx)
    end
end
-- any damage preemptively instance apply amp
---@param damageTable DAMAGE_TABLE
function modifier_venge_side_inferno:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_venge_side_inferno")
    if (damageTable.damage > 0 and modifier ) then
        local modifierTable = {}
        modifierTable.ability = modifier:GetAbility()
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_venge_side_inferno_amp"
        modifierTable.duration = 4  --modifier:GetAbility():GetSpecialValueFor("duration")
        modifierTable.stacks = 1
        modifierTable.max_stacks = 99999
        GameMode:ApplyStackingDebuff(modifierTable)
    end
end

LinkLuaModifier("modifier_venge_side_inferno", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

modifier_venge_side_inferno_amp = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    GetTexture = function(self)
        return venge_side:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_dazzle/dazzle_armor_enemy_shield.vpcf"
    end,
    GetEffectAttachType =  function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end
})

function modifier_venge_side_inferno_amp:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.amp = self.ability:GetSpecialValueFor("inferno_amp") *-0.01
    self.armor_reduce = self.ability:GetSpecialValueFor("inferno_armor_reduce")  * -1
end

function modifier_venge_side_inferno_amp:OnRefresh()
    if (not IsServer()) then
        return
    end
    self:OnCreated()
end



function modifier_venge_side_inferno_amp:GetDamageReductionBonus()
    return self.amp * self:GetStackCount()
end

function modifier_venge_side_inferno_amp:GetArmorBonus()
    return self.armor_reduce * self:GetStackCount()
end

LinkLuaModifier("modifier_venge_side_inferno_amp", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)


--------
--venge sky fall
---------
venge_fall = class({
    GetAbilityTextureName = function(self)
        return "venge_fall"
    end,
})
venge_fall.loop_interval = 0.03
LinkLuaModifier("modifier_venge_fall", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venge_fall_burn", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venge_fall_burn_effect", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venge_fall_aura", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

function venge_fall:IsRequireCastbar()
    return true
end

function venge_fall:IsInterruptible()
    return false
end


function venge_fall:OnAbilityPhaseStart()
    if IsServer() then
        EmitSoundOn("DOTA_Item.HeavensHalberd.Activate", self:GetCaster() )

        self.nPreviewFX = ParticleManager:CreateParticle( "particles/econ/items/lina/lina_ti7/lina_spell_light_strike_array_ti7.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    end

    return true
end

--createhero npc_boss_venge neutral
function venge_fall:OnSpellStart()
    if IsServer() then
        ParticleManager:DestroyParticle( self.nPreviewFX, false )
        ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
        local caster 			= self:GetCaster()
        local ability 			= self
        local radius = self:GetSpecialValueFor("range")
            caster:EmitSoundParams("vengefulspirit_vng_attack_08", 1.0, 4.2, 0)
        if not caster:HasModifier("modifier_venge_side_fire") then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = caster
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_venge_side_fire"
            modifierTable.duration = 5
            GameMode:ApplyBuff(modifierTable)
        end
        --find enemies
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            local target_point 		= enemy:GetAbsOrigin()
            local number_of_meteors =  self:GetSpecialValueFor("number")

            venge_fall:CastMeteor(caster, ability, target_point, number_of_meteors)

            if number_of_meteors > 1 then
                local fired_meteors = 1
                --local endTime = GameRules:GetGameTime() + 1
                Timers:CreateTimer({
                    endTime = 0.1,
                    callback = function()
                        fired_meteors = fired_meteors + 1
                        if not enemy:IsAlive() or not caster:IsAlive() then
                            return
                        end
                        target_point 		= enemy:GetAbsOrigin()
                        local new_target_point = target_point + Vector(math.random(-700, 700),math.random(-700, 700),0 )
                        venge_fall:CastMeteor(caster, ability, new_target_point, number_of_meteors)

                        if fired_meteors == number_of_meteors then
                            return
                        else
                            return 0.5
                        end
                    end
                })
            end
        end
    end
end

function venge_fall:CastMeteor(caster, ability, target_point, number_of_meteors)
    if IsServer() then
        local chaos_meteor_land_time = ability:GetSpecialValueFor("land_time")
        --self.R = math.random(255) --kv
        --self.G = math.random(255) --kv
        --self.B = math.random(255) --kv

        self.falling = CreateModifierThinker(
                caster,
                ability,
                "modifier_venge_fall",
                {
                    duration = chaos_meteor_land_time,
                    --R = self.R, G = self.G, B = self.B --kv
                },
                target_point,
                caster:GetTeamNumber(),
                false
        )
    end
end

modifier_venge_fall = class({})
function modifier_venge_fall:OnCreated(kv)
    if IsServer() then
        self.caster = self:GetCaster()
        self.ability = self:GetAbility()
        self.target_point = self:GetParent():GetAbsOrigin()
        self.caster_location 					= self.caster:GetAbsOrigin()
        self.caster_location_ground 			= self.caster:GetAbsOrigin()
        self.chaos_meteor_travel_distance 		= self.ability:GetSpecialValueFor("travel_distance")
        self.chaos_meteor_main_dmg				= self.ability:GetSpecialValueFor("main_damage")
        self.chaos_meteor_burn_dps				= self.ability:GetSpecialValueFor("burn_dps")
        self.chaos_meteor_travel_speed 			= self.ability:GetSpecialValueFor("travel_speed")
        self.chaos_meteor_burn_duration 		= self.ability:GetSpecialValueFor("burn_duration")
        self.chaos_meteor_burn_dps_inverval		= self.ability:GetSpecialValueFor("burn_dps_interval")
        self.chaos_meteor_damage_interval		= self.ability:GetSpecialValueFor("damage_interval")
        self.chaos_meteor_area_of_effect 		= self.ability:GetSpecialValueFor("area_of_effect")
        self.chaos_meteor_land_time 			= self.ability:GetSpecialValueFor("land_time")
        self.chaos_meteor_duration 				= self.chaos_meteor_travel_distance / self.chaos_meteor_travel_speed

        -- Play Chaos Meteor Sounds
        self.caster:EmitSoundParams("Hero_Invoker.ChaosMeteor.Cast",1.0, 0.2, 0)

        self.meteor_dummy = CreateModifierThinker(self.caster, self.ability, nil, {}, self.target_point, self.caster:GetTeamNumber(), false)
        self.meteor_dummy:EmitSoundParams("Hero_Invoker.ChaosMeteor.Loop",1.0, 0.2, 0)

        --need to random velocity here and use later to make a matching animation
        local direction = Vector(math.random(-100,100), math.random(-100,100), 0):Normalized()
        self.chaos_meteor_velocity 		        = direction * self.chaos_meteor_travel_speed

        -- Create start_point of the meteor 1000z up in the air! Meteors velocity is same while falling through the air as it is rolling on the ground.
        local chaos_meteor_fly_original_point = (self.target_point - (self.chaos_meteor_velocity * self.chaos_meteor_land_time)) + Vector(0, 0, 1000)
        --Create the particle effect consisting of the meteor falling from the sky and landing at the target point.
        self.chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/units/npc_boss_venge/venge_fall/venge_fall_fly.vpcf", PATTACH_ABSORIGIN, self.caster)--"particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf"
        ParticleManager:SetParticleControl(self.chaos_meteor_fly_particle_effect, 0, chaos_meteor_fly_original_point) --  constraint distance starting point
        ParticleManager:SetParticleControl(self.chaos_meteor_fly_particle_effect, 1, self.target_point) --constraint distance end point
        ParticleManager:SetParticleControl(self.chaos_meteor_fly_particle_effect, 2, Vector(self.chaos_meteor_land_time, 0, 0))
        --ParticleManager:SetParticleControl(self.chaos_meteor_fly_particle_effect, 60, Vector(kv.R, kv.G, kv.B)) --rainbow color
        --ParticleManager:SetParticleControl(self.chaos_meteor_fly_particle_effect, 61, Vector(1,0,0))

        --rolling for rainbow
        --Timers:CreateTimer(self.chaos_meteor_land_time, function()
            --self.chaos_meteor_projectile = ParticleManager:CreateParticle("particles/units/npc_boss_venge/venge_fall/invoker_chaos_meteor_rolling.vpcf", PATTACH_POINT, self.caster)
            --ParticleManager:SetParticleControl(self.chaos_meteor_projectile, 0, self.target_point) --origin location
            --ParticleManager:SetParticleControl(self.chaos_meteor_projectile, 1, self.chaos_meteor_velocity) -- velocity
            --ParticleManager:SetParticleControl(self.chaos_meteor_projectile, 4, Vector(self.chaos_meteor_duration,0,0)) --expire time
            --ParticleManager:SetParticleControl(self.chaos_meteor_projectile, 60, Vector(kv.R, kv.G, kv.B))
            --ParticleManager:SetParticleControl(self.chaos_meteor_projectile, 61, Vector(1,0,0))
            --ParticleManager:ReleaseParticleIndex(self.chaos_meteor_projectile)
        --end)
    end
end

function modifier_venge_fall:OnRemoved(kv)
    if IsServer() then
        self.meteor_dummy:EmitSoundParams("Hero_Invoker.ChaosMeteor.Impact",1.0, 0.2, 0)
        self.meteor_dummy:AddNewModifier(
                self.caster,
                self.ability,
                "modifier_venge_fall_aura",
                {
                    duration 				= -1,
                    chaos_meteor_duration 	= self.chaos_meteor_duration,
                    burn_duration 			= self.chaos_meteor_burn_duration,
                    main_dmg 				= self.chaos_meteor_main_dmg,
                    burn_dps 				= self.chaos_meteor_burn_dps,
                    burn_dps_inverval 		= self.chaos_meteor_burn_dps_inverval,
                    damage_interval 		= self.chaos_meteor_damage_interval,
                    area_of_effect 			= self.chaos_meteor_area_of_effect
                }
        )

        -- Meteor Projectile object
        local meteor_projectile_obj =
        {
            EffectName 					= "particles/units/npc_boss_venge/venge_fall/venge_fall.vpcf",--nil
            Ability 					= self.ability,
            vSpawnOrigin 				= self.target_point,
            fDistance 					= self.chaos_meteor_travel_distance,
            fStartRadius 				= self.chaos_meteor_area_of_effect,
            fEndRadius 					= self.chaos_meteor_area_of_effect,
            Source 						= self.chaos_meteor_dummy_unit,
            bHasFrontalCone 			= false,
            iMoveSpeed 					= self.chaos_meteor_travel_speed,
            bReplaceExisting 			= false,
            bProvidesVision 			= false,
            bDrawsOnMinimap 			= false,
            bVisibleToEnemies 			= true,
            iUnitTargetTeam 			= DOTA_UNIT_TARGET_NONE,
            iUnitTargetFlags 			= DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType 			= DOTA_UNIT_TARGET_NONE,
            --vVelocity			        = direction * self.chaos_meteor_travel_speed ,
            fExpireTime 				= GameRules:GetGameTime() + self.chaos_meteor_land_time + self.chaos_meteor_duration ,
            ExtraData 					= {
                meteor_dummy 			= self.meteor_dummy:entindex(),
            }
        }
        meteor_projectile_obj.vVelocity = self.chaos_meteor_velocity
        meteor_projectile_obj.vVelocity.z = 0
        ProjectileManager:CreateLinearProjectile(meteor_projectile_obj)

        -- Cleanup
        ParticleManager:DestroyParticle(self.chaos_meteor_fly_particle_effect, false)
        ParticleManager:ReleaseParticleIndex(self.chaos_meteor_fly_particle_effect)
        UTIL_Remove(self:GetParent())
    end
end

function venge_fall:OnProjectileThink_ExtraData(location, ExtraData)
    if IsServer() then
        EntIndexToHScript(ExtraData.meteor_dummy):SetAbsOrigin(location)
    end
end

function venge_fall:OnProjectileHit_ExtraData(target, location, ExtraData)
    if IsServer() then
        if target == nil then
            EntIndexToHScript(ExtraData.meteor_dummy):StopSound("Hero_Invoker.ChaosMeteor.Loop")
            EntIndexToHScript(ExtraData.meteor_dummy):RemoveSelf() -- this is equivalent to UTIL remove
        end
    end
end

--------------------------------------------------------------------------------------------------------------------
-- Chaos Meteor modifier - applies burn debuff and damage. also hides dummy unit from game
--------------------------------------------------------------------------------------------------------------------
modifier_venge_fall_aura = class({})
function modifier_venge_fall_aura:OnCreated(kv)
    if IsServer() then
        self.caster 				= self:GetCaster()
        self.ability 				= self:GetAbility()
        self.GetTeam 				= self:GetParent():GetTeam()
        self.chaos_meteor_duration 	= kv.chaos_meteor_duration
        self.damage_interval 		= kv.damage_interval
        self.main_dmg 				= kv.main_dmg
        self.burn_duration 			= kv.burn_duration
        self.burn_dps 				= kv.burn_dps
        self.burn_dps_inverval		= kv.burn_dps_inverval
        self.area_of_effect 		= kv.area_of_effect

        self.direction = (self:GetParent():GetAbsOrigin() - self.caster:GetAbsOrigin()):Normalized()
        self.direction.z = 0

        self.hit_table = {}

        self:StartIntervalThink(kv.damage_interval)
    end
end

function modifier_venge_fall_aura:OnIntervalThink()
    if IsServer() then
        local start_point 	= self:GetParent():GetAbsOrigin()
        local end_point 	= start_point - (self.direction * 500)
        for _,enemy in pairs(self.hit_table) do
            if enemy:IsNull() == false and enemy:HasModifier("modifier_venge_fall_burn") then
                -- Reusing old method for calculating distance vs a line
                if IsUnitInProximity(start_point, end_point, enemy:GetAbsOrigin(), 300) then
                    local burn_modifiers = enemy:FindAllModifiersByName("modifier_venge_fall_burn")
                    for _,modifier in pairs(burn_modifiers) do
                        modifier:ForceRefresh()
                    end

                    local burn_effect_modifier = enemy:FindModifierByName("modifier_venge_fall_burn_effect")
                    if burn_effect_modifier ~= nil then
                        burn_effect_modifier:ForceRefresh()
                    end
                end

            end
        end

        -- Find enemies close enought to be affected by the meteor
        local nearby_enemy_units = FindUnitsInRadius(
                self.GetTeam,
                self:GetParent():GetAbsOrigin(),
                nil,
                self.area_of_effect,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)

        for _,enemy in pairs(nearby_enemy_units) do
            if self.hit_table[enemy:GetName()] == nil then
                self.hit_table[enemy:GetName()] = enemy
            end

            if enemy ~= nil then
                -- Add burn debuff
                enemy:AddNewModifier(
                        self.caster,
                        self.ability,
                        "modifier_venge_fall_burn",
                        {
                            duration 			= self.burn_duration,
                            burn_dps 			= self.burn_dps,
                            burn_dps_inverval 	= self.burn_dps_inverval
                        }
                )

                enemy:AddNewModifier(
                        self.caster,
                        self.ability,
                        "modifier_venge_fall_burn_effect",
                        {
                            duration 			= self.burn_duration
                        }
                )

                -- Apply meteor main dmg
                if self.caster:IsAlive() then
                    local damageTable = {}
                    damageTable.ability 		= self.ability
                    damageTable.caster = self.caster
                    damageTable.target = enemy
                    damageTable.damage = self.main_dmg
                    damageTable.firedmg = true
                    GameMode:DamageUnit(damageTable)
                end
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------------------
-- Chaos Meteor burn modifier - applies burn damage per dps interval
--------------------------------------------------------------------------------------------------------------------
modifier_venge_fall_burn = class({
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
        return venge_fall:GetAbilityTextureName()
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
})


function modifier_venge_fall_burn:OnCreated(kv)
    if IsServer() then
        self.caster 			= self:GetCaster()
        self.parent 			= self:GetParent()
        self.ability 			= self:GetAbility()
        self.burn_dps_inverval 	= kv.burn_dps_inverval
        self.burn_dps 			= kv.burn_dps

        self:StartIntervalThink(self.burn_dps_inverval)
    end
end

function modifier_venge_fall_burn:OnIntervalThink()

    if IsServer() then
        if self.caster:IsAlive() then
            local damageTable = {}
            damageTable.ability = self.ability
            damageTable.caster = self.caster
            damageTable.target = self.parent
            damageTable.damage = self.burn_dps
            damageTable.firedmg = true
            GameMode:DamageUnit(damageTable)
            -- Apply meteor debuff burn dmg
        end
    end
end


--------------------------------------------------------------------------------------------------------------------
-- Chaos Meteor burn effect
--------------------------------------------------------------------------------------------------------------------
modifier_venge_fall_burn_effect = class({
    IsHidden = function(self)
        return true
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf"
    end,
})



--------------------
--venge umbra
----------------------
modifier_venge_mind_control_marked = class ({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    GetTexture = function(self)
        return venge_mind_control:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf"
    end,
    GetEffectAttachType = function(self)
        return  PATTACH_OVERHEAD_FOLLOW
    end
})

function modifier_venge_mind_control_marked:OnCreated( kv )
    if not IsServer() then
        return --self.mark = ParticleManager:CreateParticle( "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
    end
end


LinkLuaModifier( "modifier_venge_mind_control_marked", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE )
--make the boi black, remove all mana and give void bonus on AA somehow putting black status fx on main function doesnt work
modifier_venge_mind_control_black = class ({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    GetTexture = function(self)
        return venge_mind_control:GetAbilityTextureName()
    end,
    GetStatusEffectName = function(self)
        return "particles/units/npc_boss_luna/luna_cruelty/luna_cruelty.vpcf"
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_venge_mind_control_black:OnCreated( kv )
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    local blackhand = "particles/units/heroes/hero_razor/razor_static_link_debuff.vpcf"
    local aura = "particles/econ/courier/courier_hyeonmu_ambient/courier_hyeonmu_ambient_blue.vpcf"
    self.pfx = ParticleManager:CreateParticle( blackhand, PATTACH_POINT_FOLLOW, self:GetParent())
    self.afx = ParticleManager:CreateParticle( aura, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.afx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
end

function modifier_venge_mind_control_black:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    if keys.attacker == self.parent then
        local proc = self.ability:GetSpecialValueFor("proc")
        --print(proc)
        local Max_Health = keys.target:GetMaxHealth()
        local proc_final = proc * Max_Health * 0.01
        --print(proc_final)
        local damageTable = {}
        damageTable.caster = keys.attacker
        damageTable.target = keys.target
        damageTable.ability = self.ability
        damageTable.damage = proc_final
        damageTable.voiddmg = true
        GameMode:DamageUnit(damageTable)
        local bound = "particles/econ/items/spectre/spectre_transversant_soul/spectre_ti7_crimson_spectral_dagger_path_owner_impact.vpcf"
        local bound_fx = ParticleManager:CreateParticle(bound, PATTACH_POINT_FOLLOW, keys.target)
        ParticleManager:SetParticleControlEnt(bound_fx, 0, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), true)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(bound_fx, false)
            ParticleManager:ReleaseParticleIndex(bound_fx)
        end)
    end

end

function modifier_venge_mind_control_black:GetManaRegenerationPercentBonus()
    return -10
end

function modifier_venge_mind_control_black:OnDestroy()
    if not IsServer() then
        return
    end
    ParticleManager:DestroyParticle(self.pfx, false)
    ParticleManager:ReleaseParticleIndex(self.pfx)
    ParticleManager:DestroyParticle(self.afx, false)
    ParticleManager:ReleaseParticleIndex(self.afx)
end

LinkLuaModifier( "modifier_venge_mind_control_black", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE )

--attack own allies and speed
modifier_venge_mind_control = class ({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    GetTexture = function(self)
        return venge_mind_control:GetAbilityTextureName()
    end,
})


function modifier_venge_mind_control:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        self.ability = self:GetAbility()
        self.caster = self:GetCaster()
        if self.parent:GetForceAttackTarget() then
            self:Destroy()
            return
        end
        self.movespeed_bonus = self.ability:GetSpecialValueFor( "movespeed_bonus" )*0.01
        self.attackspeed_bonus = self.ability:GetSpecialValueFor( "attackspeed_bonus" )*0.01
        self.target_search_radius = self.ability:GetSpecialValueFor( "target_search_radius" )
        self.charm_duration = self.ability:GetSpecialValueFor( "charm_duration" )
        self.stun = self.ability:GetSpecialValueFor("stun")
        self.parent:Interrupt()
        self.parent:SetIdleAcquire( true )

        self.parent:AddNewModifier( self.caster, nil, "modifier_phased", { duration = -1 } ) -- no idea why this is needed but i tried remove it and spell doesnt work
        --price to pay
        self.parent:SetMana(0)
        --find closest ally
        local hAllies = FindUnitsInRadius( self.parent:GetTeamNumber(),
                self.parent:GetOrigin(),
                nil,
                self.target_search_radius,
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                FIND_CLOSEST,
                false )
        if #hAllies >0 then
            self.hDesiredTarget = hAllies[ 1 ]
            --print(hAllies[ 1 ]:GetUnitName())
            self.parent:SetForceAttackTargetAlly( self.hDesiredTarget )
            --mark the ally that is targeted by charmed boi
            local modifierTable = {}
            modifierTable.ability = self.ability
            modifierTable.target = self.hDesiredTarget
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_venge_mind_control_marked"
            modifierTable.duration = self.charm_duration
            GameMode:ApplyDebuff(modifierTable)

            self:StartIntervalThink( 0.5 )
        else -- no nearby ally to hit
            self:Destroy()
            --check if party or solo
            if HeroList:GetHeroCount() > 1 then
                local modifierTable = {}
                modifierTable.ability = self.ability
                modifierTable.target = self.parent
                modifierTable.caster = self.caster
                modifierTable.modifier_name = "modifier_stunned"
                modifierTable.duration = self.stun
                GameMode:ApplyDebuff(modifierTable)
                else
                local modifierTable = {}
                modifierTable.ability = self.ability
                modifierTable.target = self.parent
                modifierTable.caster = self.caster
                modifierTable.modifier_name = "modifier_stunned"
                modifierTable.duration = 3
                GameMode:ApplyDebuff(modifierTable)
            end
            return
        end
    end
end


function modifier_venge_mind_control:GetMoveSpeedPercentBonus()
    return self.movespeed_bonus
end

function modifier_venge_mind_control:GetAttackSpeedPercentBonus()
    return self.attackspeed_bonus
end

function modifier_venge_mind_control:OnIntervalThink()
    if IsServer() then
        if self.parent:GetForceAttackTarget() == nil then
            self.parent:SetForceAttackTargetAlly( self.hDesiredTarget )
        end

        if self.hDesiredTarget == nil or self.hDesiredTarget:IsAlive() == false or not self.caster:IsAlive() then
            self:Destroy()
            return
        end
    end
end

function modifier_venge_mind_control:OnDestroy()
    if IsServer() then
        self.parent:SetForceAttackTargetAlly( nil )

        self.parent:RemoveModifierByName( "modifier_phased" )
        self.parent:RemoveModifierByName( "modifier_venge_mind_control_black" )
        EmitSoundOn( "Hero_DarkWillow.Ley.Stun", self.parent )
    end
end


function modifier_venge_mind_control:CheckState()
    if IsServer()  then
        local state = { [MODIFIER_STATE_INVULNERABLE] = true,
                        [MODIFIER_STATE_OUT_OF_GAME] = true,
                        [MODIFIER_STATE_NO_HEALTH_BAR] = true,}
        return state
    end
end

LinkLuaModifier( "modifier_venge_mind_control", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE )

venge_mind_control = class({
    GetAbilityTextureName = function(self)
        return "venge_mind_control"
    end,
})

function venge_mind_control:IsRequireCastbar()
    return true
end

function venge_mind_control:IsInterruptible()
    return false
end


function venge_mind_control:OnAbilityPhaseStart()
    if IsServer() then
        EmitSoundOn("DOTA_Item.HeavensHalberd.Activate", self:GetCaster() )

        self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/npc_boss_venge/venge_control/nevermore_wings_purple.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    end
    return true
end

function venge_mind_control:OnSpellStart()
    if IsServer() then
        Timers:CreateTimer(3,function()
        ParticleManager:DestroyParticle( self.nPreviewFX, false )
        ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
        end)
        self.projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
        self.charm_duration = self:GetSpecialValueFor( "charm_duration" )
        self.caster = self:GetCaster()
        self.caster:EmitSoundParams("vengefulspirit_vng_kill_01", 1.0, 5.2, 0)
        if not self.caster:HasModifier("modifier_venge_side_void") then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = self.caster
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_venge_side_void"
            modifierTable.duration = 5
            GameMode:ApplyBuff(modifierTable)
        end
        GameMode:ApplyDebuff(modifierTable)
        local range = self:GetSpecialValueFor("range")
        local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
                self.caster:GetAbsOrigin(),
                nil,
                range,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        if (#enemies > 0) then
            self.target = enemies[1] --random one
        else
            return
        end
        local info = {
            Target = self.target,
            Source = self.caster,
            Ability = self,
            EffectName = "particles/units/npc_boss_venge/venge_control/chaos_knight_chaos_bolt_purple.vpcf",
            iMoveSpeed = self.projectile_speed,
            vSourceLoc = self.caster:GetOrigin(),
            bDodgeable = false,
            bProvidesVision = false,
            flExpireTime = GameRules:GetGameTime() + 10 --self.projectile_expire_time,
        }

        ProjectileManager:CreateTrackingProjectile( info )

        StopSoundOn( "DOTA_Item.HeavensHalberd.Activate", caster )
    end
end

function venge_mind_control:OnProjectileHit( hTarget, vLocation )
    if IsServer() then
        if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = hTarget
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_venge_mind_control_black"
            modifierTable.duration = self.charm_duration
            GameMode:ApplyDebuff(modifierTable)
            modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = hTarget
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_venge_mind_control"
            modifierTable.duration = self.charm_duration
            GameMode:ApplyDebuff(modifierTable)
            hTarget:EmitSound("Hero_Necrolyte.SpiritForm.Cast")
            Timers:CreateTimer(0.4, function()
                local hit = "particles/units/npc_boss_venge/venge_control/nevermore_loadout_purple.vpcf"
                local bound_fx = ParticleManager:CreateParticle(hit, PATTACH_POINT_FOLLOW,  hTarget)
                Timers:CreateTimer(2.0, function()
                    ParticleManager:DestroyParticle(bound_fx, false)
                    ParticleManager:ReleaseParticleIndex(bound_fx)
                end)
            end)
            if hTarget:HasModifier("modifier_venge_bubble") and self.caster:IsAlive() then
                hTarget:ForceKill(false)
            end
        end
    end
end

-----------------
--bubble
-------------------

modifier_venge_bubble = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_morphling_morph_target.vpcf"--
    end,
    GetTexture = function(self)
        return venge_tide:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH,
        }
    end,
})

function modifier_venge_bubble:OnCreated( kv )
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.bubble_tick = self.ability:GetSpecialValueFor( "bubble_tick" )
    local Max_Health = self.parent:GetMaxHealth()
    self.bubble_damage = self.ability:GetSpecialValueFor( "bubble_damage" ) * Max_Health * 0.01 * self.bubble_tick

    self.hBubble = CreateUnitByName( "npc_boss_venge_bubble", self.parent:GetAbsOrigin(), true, self.caster, self.caster, self.caster:GetTeamNumber() )
    local vector = self.parent:GetAbsOrigin()-self.caster:GetAbsOrigin()
    self.hBubble:SetForwardVector(vector)
    --self.hBubble:AddNewModifier( self:GetCaster(), self, "modifier_venge_bubble_passive", { duration = -1 })
    local modifierTable = {}
    modifierTable.ability = self.ability
    modifierTable.target = self.hBubble
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_venge_bubble_passive"
    modifierTable.duration = -1
    GameMode:ApplyBuff(modifierTable)
    self.drown = "Bubbles.Test"
    Timers:CreateTimer(0, function()
        if self.parent:HasModifier("modifier_venge_bubble") then
            self.parent:EmitSoundParams(self.drown, 1.0, 3.2, 0)
            return 4
        end
    end)

    self:StartIntervalThink( self.bubble_tick )

    --visual
    self.parent:StartGesture(ACT_DOTA_FLAIL)
end

function modifier_venge_bubble:OnIntervalThink()
    if self.caster:IsAlive() then
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target =  self.parent
        damageTable.ability = self.ability
        damageTable.damage = self.bubble_damage
        damageTable.frostdmg = true
        GameMode:DamageUnit(damageTable)
    end
    self.parent:StartGesture(ACT_DOTA_FLAIL) --in case it get removed by other skills for example moonify
    if not self.hBubble:IsAlive() then
        self.parent:RemoveGesture(ACT_DOTA_FLAIL)
        self:Destroy()
        self.parent:StopSound(self.drown)
    end
end

function modifier_venge_bubble:CheckState()
    local state = {}
    if IsServer()  then
        state[ MODIFIER_STATE_STUNNED]  = true
        state[ MODIFIER_STATE_ROOTED ] = true
        state[ MODIFIER_STATE_DISARMED] = true
        --state[ MODIFIER_STATE_OUT_OF_GAME ] = true
        --state[ MODIFIER_STATE_NO_HEALTH_BAR ] = true

    end

    return state
end

function modifier_venge_bubble:OnDestroy()
    if not IsServer() then
        return
    end
    if self.hBubble and self.hBubble:IsAlive() then
        self.hBubble:ForceKill( false )
    end
end
-- reduce these by 1000%
function modifier_venge_bubble:GetHealthRegenerationPercentBonus()
    return -10
end

function modifier_venge_bubble:GetHealingReceivedPercentBonus()
    return -10
end

function modifier_venge_bubble:GetSpellDamageBonus()
    return -10
end

function modifier_venge_bubble:GetAttackDamagePercentBonus()
    return -10
end

function modifier_venge_bubble:OnDeath( params ) --venge death = bubble pop
    if IsServer() then
        if params.unit == self.caster then
            self:Destroy()
        end
    end
end


LinkLuaModifier( "modifier_venge_bubble", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE )

modifier_venge_bubble_passive = class({
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
                 MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
                 MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
                 MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
                 MODIFIER_EVENT_ON_ATTACKED,
                 MODIFIER_PROPERTY_MODEL_SCALE,
                 MODIFIER_STATE_LOW_ATTACK_PRIORITY
        }
    end,
    GetStatusEffectName = function(self)
        return "particles/econ/events/ti7/fountain_regen_ti7_bubbles.vpcf"
    end,
})

function modifier_venge_bubble_passive:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
        Timers:CreateTimer(0, function()
            if self.parent:IsAlive() then
                self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_5)
                return 1
            end
        end)
        self.hit_count				= self:GetAbility():GetSpecialValueFor("hit_count")
        self.health_increments		= self.parent:GetMaxHealth() / self.hit_count
        self.nFXIndex = ParticleManager:CreateParticle( "particles/units/npc_boss_venge/venge_tide/venge_bubble.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
    end
end

function modifier_venge_bubble_passive:GetFireProtectionBonus()
    return 10
end

function modifier_venge_bubble_passive:GetFrostProtectionBonus()
    return 10
end

function modifier_venge_bubble_passive:GetEarthProtectionBonus()
    return 10
end

function modifier_venge_bubble_passive:GetVoidProtectionBonus()
    return 10
end

function modifier_venge_bubble_passive:GetHolyProtectionBonus()
    return 10
end

function modifier_venge_bubble_passive:GetNatureProtectionBonus()
    return 10
end

function modifier_venge_bubble_passive:GetInfernoProtectionBonus()
    return 10
end

function modifier_venge_bubble_passive:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_venge_bubble_passive:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_venge_bubble_passive:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_venge_bubble_passive:OnAttacked(keys)
    if not IsServer() then return end

    if keys.target == self.parent and (keys.attacker:IsRealHero() ) then
        -- Deal with enemy logic first

        if self.parent:GetTeam() ~= keys.attacker:GetTeam() then

            self.parent:SetHealth(self.parent:GetHealth() - self.health_increments)

            if self.parent:GetHealth() <= 0 then
                self.parent:Kill(nil, keys.attacker)
                -- This needs to be called to have the proper particle removal

            end
        end
    end
end

function modifier_venge_bubble_passive:GetModifierModelScale()
    return -40
end

function modifier_venge_bubble_passive:CheckState()
    local state = {}
    if IsServer()  then
        state[ MODIFIER_STATE_STUNNED]  = true
        state[ MODIFIER_STATE_ROOTED ] = true
        state[ MODIFIER_STATE_DISARMED] = true
        --state[ MODIFIER_STATE_NO_HEALTH_BAR ] = true
        state[ MODIFIER_STATE_BLIND ] = true
        state[ MODIFIER_STATE_NOT_ON_MINIMAP ] = true
        state[ MODIFIER_STATE_NO_UNIT_COLLISION ] = true
    end

    return state
end

function modifier_venge_bubble_passive:OnDeath( params )
    if IsServer() then
        if params.unit == self:GetParent() then
            ParticleManager:DestroyParticle(self.nFXIndex, false)
            ParticleManager:ReleaseParticleIndex(self.nFXIndex)

            self.pop = "particles/econ/taunts/snapfire/snapfire_taunt_bubble_pop.vpcf"
            self.pop_fx = ParticleManager:CreateParticle( self.pop, PATTACH_ABSORIGIN_FOLLOW, self.parent )
            Timers:CreateTimer(0.3, function()
                ParticleManager:DestroyParticle(self.pop_fx, false)
                ParticleManager:ReleaseParticleIndex(self.pop_fx)
            end)
        end
    end
end

LinkLuaModifier( "modifier_venge_bubble_passive", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE )


venge_tide = class({
    GetAbilityTextureName = function(self)
        return "venge_tide"
    end,
})

function venge_tide:IsRequireCastbar()
    return true
end

function venge_tide:IsInterruptible()
    return false
end


function venge_tide:OnAbilityPhaseStart()
    if IsServer() then
        EmitSoundOn("DOTA_Item.HeavensHalberd.Activate", self:GetCaster() )
        self:GetCaster():EmitSoundParams("vengefulspirit_vng_spawn_07", 1.0, 5.2, 0)
        self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    end

    return true
end

function venge_tide:ShootSet()
    if IsServer() then
        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
                self:GetCaster():GetAbsOrigin(),
                nil,
                self.cast_range,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do

            local vDir = enemy:GetAbsOrigin() - self:GetCaster():GetOrigin()
            vDir.z = 0.0
            vDir = vDir:Normalized()

            local info = {
                EffectName = "particles/units/heroes/hero_morphling/morphling_waveform.vpcf",
                Ability = self,
                vSpawnOrigin = self:GetCaster():GetOrigin(),
                fStartRadius = self.projectile_radius,
                fEndRadius = self.projectile_radius,
                vVelocity = vDir * self.projectile_speed,
                fDistance = self.cast_range,
                Source = self:GetCaster(),
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetType = DOTA_UNIT_TARGET_HERO ,
            }
            ProjectileManager:CreateLinearProjectile( info )
        end
    end
end
--------------------------------------------------------------------------------

function venge_tide:OnSpellStart()
    if IsServer() then
        ParticleManager:DestroyParticle( self.nPreviewFX, false )
        ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
        self.projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
        self.projectile_radius = self:GetSpecialValueFor( "projectile_radius" )
        self.cast_range = self:GetSpecialValueFor( "range" )
        local number = self:GetSpecialValueFor("number")
        local counter = 0
        local caster = self:GetCaster()
        if not caster:HasModifier("modifier_venge_side_frost") then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = caster
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_venge_side_frost"
            modifierTable.duration = 5
            GameMode:ApplyBuff(modifierTable)
        end
        Timers:CreateTimer(0, function()
            if counter < number then
                self:ShootSet()
                self:GetCaster():EmitSound("Hero_Morphling.Waveform")
                counter = counter + 1
                return 1.5
            end
        end)
    end
end

-------------------------------------------------------------------------------

function venge_tide:OnProjectileHit( hTarget, vLocation )
    if IsServer() then
        if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) then --and hTarget:IsRealHero()
            --hTarget:AddNewModifier( self:GetCaster(), self, "modifier_venge_bubble", { duration = -1 } )
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = hTarget
            modifierTable.caster = self:GetCaster()
            modifierTable.modifier_name = "modifier_venge_bubble"
            modifierTable.duration = -1
            GameMode:ApplyDebuff(modifierTable)
            --return true -- in case you want projectile to be gone on hit
        end
    end

    --return false
end

--------------------
--venge_moonify
--------------------

modifier_venge_moonify = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH,
                 MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
                 MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
                 MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
                 MODIFIER_PROPERTY_MODEL_SCALE,
                 MODIFIER_EVENT_ON_ATTACKED}
    end
})

function modifier_venge_moonify:OnCreated()
    self.ability	= self:GetAbility()
    self.caster		= self:GetCaster()
    self.parent		= self:GetParent()

    -- AbilitySpecials
    self.on_count						= self.ability:GetSpecialValueFor("on_count")
    self.radius							= self.ability:GetSpecialValueFor("radius")
    self.hit_count						= self.ability:GetSpecialValueFor("hit_count")
    self.off_duration					= self.ability:GetSpecialValueFor("off_duration")
    self.on_duration					= self.ability:GetSpecialValueFor("on_duration")
    self.off_duration_initial			= 0
    self.fixed_movement_speed			= self.ability:GetSpecialValueFor("fixed_movement_speed")

    if not IsServer() then return end

    -- Calculate health chunks that Ignis Fatuus will lose on getting attacked
    self.health_increments		= self.parent:GetMaxHealth() / self.hit_count

    -- Emit cast sounds
    self.parent:EmitSound("Hero_KeeperOfTheLight.Wisp.Cast")
    Timers:CreateTimer(1, function()
    self.parent:StopSound("Hero_KeeperOfTheLight.Wisp.Cast")
    end)
    self.parent:EmitSound("Hero_KeeperOfTheLight.Wisp.Spawn")
    self.parent:EmitSound("Hero_KeeperOfTheLight.Wisp.Aura")

    -- This gives Ignis Fatuus a visible model
    -- CP1 = Vector(radius, 1, 1)
    -- CP2 = Vector("hypnotize is on", 0, 0)
    -- CP3/4/5 = I don't know
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_dazzling.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius, 1, 1))
    ParticleManager:SetParticleControl(self.particle, 2, Vector(0, 0, 0))
    self:AddParticle(self.particle, false, false, -1, false, false)

    self.particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_dazzling_on.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.particle2, 2, Vector(0, 0, 0))
    self:AddParticle(self.particle2, false, false, -1, false, false)

    -- Destroy trees around cast point
    --GridNav:DestroyTreesAroundPoint( self.parent:GetOrigin(), self.radius, true )

    self.timer = 0
    self.pulses = 0
    self.is_on = false

    self:StartIntervalThink(0.1)
end


function modifier_venge_moonify:GetFireProtectionBonus()
    return 10
end

function modifier_venge_moonify:GetFrostProtectionBonus()
    return 10
end

function modifier_venge_moonify:GetEarthProtectionBonus()
    return 10
end

function modifier_venge_moonify:GetVoidProtectionBonus()
    return 10
end

function modifier_venge_moonify:GetHolyProtectionBonus()
    return 10
end

function modifier_venge_moonify:GetNatureProtectionBonus()
    return 10
end

function modifier_venge_moonify:GetInfernoProtectionBonus()
    return 10
end

function modifier_venge_moonify:OnIntervalThink()
    if not IsServer() then return end

    self.timer = self.timer + 0.1

    if not self.is_on and (self.pulses == 0 and self.timer >= self.off_duration_initial) or (self.pulses > 0 and self.timer >= self.off_duration)  then
        self.is_on 	= true
        self.pulses = self.pulses + 1

        self.parent:EmitSound("Hero_KeeperOfTheLight.Wisp.Active")
        ParticleManager:SetParticleControl(self.particle, 2, Vector(1, 0, 0))
        ParticleManager:SetParticleControl(self.particle2, 2, Vector(1, 0, 0))

        self.timer = 0
    elseif self.is_on then
        if self.timer >= self.on_duration then
            self.is_on = false
            ParticleManager:SetParticleControl(self.particle, 2, Vector(0, 0, 0))
            ParticleManager:SetParticleControl(self.particle2, 2, Vector(0, 0, 0))
            self.timer = 0
        else
            local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
                    self.parent:GetAbsOrigin(),
                    nil,
                    self.radius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)

            for _, enemy in pairs(enemies) do
                if not enemy:HasModifier("modifier_venge_moonify_aura") then
                    local modifierTable = {}
                    modifierTable.ability = self.ability
                    modifierTable.target = enemy
                    modifierTable.caster = self.parent
                    modifierTable.modifier_name = "modifier_venge_moonify_aura"
                    modifierTable.duration =  self.on_duration - self.timer
                    GameMode:ApplyDebuff(modifierTable)
                end
                enemy:FaceTowards(self.parent:GetAbsOrigin())
            end
        end
    end
end

function modifier_venge_moonify:OnRemoved()
    if not IsServer() then return end

    self.parent:EmitSound("Hero_KeeperOfTheLight.Wisp.Destroy")
    self.parent:StopSound("Hero_KeeperOfTheLight.Wisp.Aura")

    local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
            self.parent:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)

    -- Remove exisiting hypnotize modifiers on everyone if the wisp is destroyed during this
    for _, enemy in pairs(enemies) do
        local hypnotize_modifier = enemy:FindModifierByNameAndCaster("modifier_venge_moonify_aura", self.parent)

        if hypnotize_modifier then
            hypnotize_modifier:Destroy()
        end
    end

    self.parent:ForceKill(false)
end


function modifier_venge_moonify:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_venge_moonify:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_venge_moonify:GetAbsoluteNoDamagePure()
    return 1
end

-- Arbitrary size reduction to try and match vanila
function modifier_venge_moonify:GetModifierModelScale()
    return -40
end

function modifier_venge_moonify:OnAttacked(keys)
    if not IsServer() then return end

    if keys.target == self.parent and (keys.attacker:IsRealHero() ) then
        -- Deal with enemy logic first

        if self.parent:GetTeam() ~= keys.attacker:GetTeam() then

            self.parent:SetHealth(self.parent:GetHealth() - self.health_increments)

            if self.parent:GetHealth() <= 0 then
                self.parent:Kill(nil, keys.attacker)
                -- This needs to be called to have the proper particle removal
                self:Destroy()
            end
        end
    end
end
LinkLuaModifier( "modifier_venge_moonify", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE )
-------------------------------
-- WILL O WISP MODIFIER AURA --
-------------------------------
-- I guess this isn't technically an aura but w/e using vanilla descriptions
modifier_venge_moonify_aura = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    GetMotionControllerPriority = function(self)
        return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM
    end,
})

function modifier_venge_moonify_aura:GetStatusEffectName()
    return "particles/status_fx/status_effect_keeper_dazzle.vpcf"
end

function modifier_venge_moonify_aura:OnCreated()
    self.ability				= self:GetAbility()
    self.caster					= self:GetCaster()
    self.parent					= self:GetParent()
    self.damage                 = self.ability:GetSpecialValueFor("damage")

    -- AbilitySpecials
    self.fixed_movement_speed		= self.ability:GetSpecialValueFor("fixed_movement_speed")
    if not IsServer() then return end

    local vector = self.caster:GetAbsOrigin() - self.parent:GetAbsOrigin()
    self.parent:SetForwardVector(vector)
    self.parent:StartGesture(ACT_DOTA_FLAIL)

    if self:ApplyHorizontalMotionController() == false then
        self:Destroy()
        return
    end

end


function modifier_venge_moonify_aura:OnDestroy()
    if not IsServer() then return end

    self.parent:RemoveHorizontalMotionController( self )
    self.parent:RemoveGesture(ACT_DOTA_FLAIL)
end

-- Creeps don't turn to face the wisp zzzzzzzzzz
function modifier_venge_moonify_aura:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,	-- Using this as substitute for Sleep which isn't a provided state
        --[MODIFIER_STATE_DISARMED] = true,
        --[MODIFIER_STATE_SILENCED] = true,
        --[MODIFIER_STATE_MUTED] = true,
        --[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        --[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
end

function modifier_venge_moonify_aura:UpdateHorizontalMotion(me, dt) --28 ticks per 1s roughly 0.0357s
    if (IsServer()) then
        if self.caster:IsAlive() then
            local caster_location = self.caster:GetAbsOrigin()
            local current_location = self.parent:GetAbsOrigin()
            self.expected_location = current_location + self.parent:GetForwardVector() * self.fixed_movement_speed * dt
            local distance_to_caster = DistanceBetweenVectors(current_location, caster_location)
            if ( distance_to_caster > 350) and self.parent:HasModifier("modifier_venge_bubble") then
                self.expected_location = current_location + self.parent:GetForwardVector() * self.fixed_movement_speed * dt * 3
                self.parent:SetAbsOrigin(self.expected_location)
                local damageTable = {}
                damageTable.caster = self.caster
                damageTable.target = self.parent
                damageTable.ability = self.ability
                damageTable.damage = self.damage
                damageTable.holydmg = true
                GameMode:DamageUnit(damageTable)
            elseif ( distance_to_caster > 350 ) and not self.parent:HasModifier("modifier_venge_bubble") then --and not distance_to_caster< 250 --isTraversable and not isBlocked and not isTreeNearby and t
                self.parent:SetAbsOrigin(self.expected_location)
                local damageTable = {}
                damageTable.caster = self.caster
                damageTable.target = self.parent
                damageTable.ability = self.ability
                damageTable.damage = self.damage
                damageTable.holydmg = true
                GameMode:DamageUnit(damageTable)
            elseif ( distance_to_caster <= 350 and distance_to_caster > 100 and not self.parent:HasModifier("modifier_venge_bubble") ) then
                self.parent:SetAbsOrigin(self.expected_location)
                local damageTable = {}
                damageTable.caster = self.caster
                damageTable.target = self.parent
                damageTable.ability = self.ability
                damageTable.damage = self.damage*3
                damageTable.holydmg = true
                GameMode:DamageUnit(damageTable)
            elseif ( distance_to_caster > 90) and self.parent:HasModifier("modifier_venge_bubble") then
                self.expected_location = current_location + self.parent:GetForwardVector() * self.fixed_movement_speed * dt * 3
                self.parent:SetAbsOrigin(self.expected_location)
                local damageTable = {}
                damageTable.caster = self.caster
                damageTable.target = self.parent
                damageTable.ability = self.ability
                damageTable.damage = self.damage*3
                damageTable.holydmg = true
                GameMode:DamageUnit(damageTable)
                if distance_to_caster < 100 then
                    self:Destroy()
                    self.ability:MoonAbsorb(self.parent)
                end
            else
                self:Destroy()
                self.ability:MoonAbsorb(self.parent)
            end
        end
    end
end

function modifier_venge_moonify_aura:OnHorizontalMotionInterrupted()
    if IsServer() then
        self:Destroy()
        Timers:CreateTimer(0.1, function()
            FindClearSpaceForUnit(self.parent, self.expected_location, true)
        end)
    end
end

LinkLuaModifier( "modifier_venge_moonify_aura", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
------------------
--hide modifier
------------------
modifier_venge_moonify_hide = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    GetStatusEffectName = function(self)
        return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_dire.vpcf"
    end,

})

function modifier_venge_moonify_hide:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.off_duration			= self.ability:GetSpecialValueFor("off_duration")
    self.on_duration			= self.ability:GetSpecialValueFor("on_duration")
    self.on_count			= self.ability:GetSpecialValueFor("on_count")
    self.off_duration_initial = 0
    self.duration = self.off_duration_initial + (self.on_duration * self.on_count) + (self.off_duration * (self.on_count - 1))+0.5
    -- Issue: This thing actually has a slightly larger hitbox than the standard wisp -_-
    self.moon = CreateUnitByName("npc_dota_ignis_fatuus", self.parent:GetAbsOrigin(), true, self.caster, self.caster, self.caster:GetTeamNumber())
    self.rescue = self.ability:GetSpecialValueFor("rescue")
    --check on moon death if moon expired by itself or not, if it did, don't kill the parent on expiration
    self.expire = false

    --memorize if moon die or no sine unit are forgot by dota 3s after death
    self.alive = true
    -- Add the hypnotizing aura modifier
    local modifierTable = {}
    modifierTable.ability = self.ability
    modifierTable.target = self.moon
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_venge_moonify"
    modifierTable.duration =  self.duration
    GameMode:ApplyBuff(modifierTable)

    --set expire is true after duration passed + particle to show that boi is rescueable
    Timers:CreateTimer(self.duration, function()
        self.expire = true
        --particle
        if self.parent:HasModifier("modifier_venge_moonify_hide") then
            self.ppfx = ParticleManager:CreateParticle("particles/frostivus_herofx/juggernaut_omnislash_ascension.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
            Timers:CreateTimer(1.5, function()
                ParticleManager:DestroyParticle(self.ppfx, false)
                ParticleManager:ReleaseParticleIndex(self.ppfx)
            end)
        end
        --showing countdown
        local counter ="particles/units/npc_boss_venge/venge_moonify/countdown.vpcf"
        local tick = 1
        self.delay = 10
        --death if not rescued
        Timers:CreateTimer(0, function()
            if self.parent:IsAlive() and self.parent:HasModifier("modifier_venge_moonify_hide") then
                self.parent:EmitSound("Hero_DarkWillow.Ley.Count")
                self.delay = self.delay - tick
                --countdown particle
                if self.delay > 0 then
                    self.pidx = ParticleManager:CreateParticle(counter, PATTACH_OVERHEAD_FOLLOW, self.parent)
                    ParticleManager:SetParticleControl(self.pidx, 0, Vector(0, math.max(0, 0, 300)))
                    ParticleManager:SetParticleControl(self.pidx, 1, Vector(0, math.max(0, math.floor(self.delay)), 0))
                    Timers:CreateTimer(0.8, function()
                        ParticleManager:DestroyParticle(self.pidx, false)
                        ParticleManager:ReleaseParticleIndex(self.pidx)
                    end)
                end
                --kill that no friend boi
                if self.parent:HasModifier("modifier_venge_moonify_hide") and self.expire == true and self.alive == false and self.delay < 1 then
                    self.ability:MoonAbsorb(self.parent)
                end
                return 1
            end
        end)
    end)

    self:StartIntervalThink(0.3)

    --visual soul stealing
    -- load data
    local soul = "particles/units/heroes/hero_shadow_demon/shadow_demon_purge_v2_finale03_rubick.vpcf"
    self.soul = ParticleManager:CreateParticle(soul, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    Timers:CreateTimer(4, function()
        ParticleManager:DestroyParticle(self.soul, false)
        ParticleManager:ReleaseParticleIndex(self.soul)
    end)
    local projectile_name = "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf"
    local projectile_speed = 50 --self:GetSpecialValueFor("projectile_speed")

    -- Create Projectile
    local info = {
        Target = self.moon,
        Source = self.parent,
        Ability = self:GetAbility(),
        EffectName = projectile_name,
        iMoveSpeed = projectile_speed,
        vSourceLoc = self.parent:GetAbsOrigin(),                -- Optional (HOW)
        bDrawsOnMinimap = false,                          -- Optional
        bDodgeable = false,                                -- Optional
        bVisibleToEnemies = true,                         -- Optional
        bReplaceExisting = false,                         -- Optional
    }
    ProjectileManager:CreateTrackingProjectile(info)

end

function modifier_venge_moonify_hide:CheckState()
    local state = { [MODIFIER_STATE_INVULNERABLE] = true,
                    [MODIFIER_STATE_OUT_OF_GAME] = true,
                    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
                    [MODIFIER_STATE_STUNNED] = true,
                    [MODIFIER_STATE_FROZEN] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION]	= true}
    return state
end

function modifier_venge_moonify_hide:OnIntervalThink()
    --print(self.alive)
    --This IsAlive stuff can be called around 3s duration after moon died so we store the condition of moon.
    if self.alive == true then
        if not self.moon:IsAlive() and self.alive == true then
            self.alive = false
        end
    end
    --use the memorized data to check later
    if self.alive == false  then
        --check if moon get killed by other players and not expired by itself. if yes killed the moonified boi
        if self.expire == false then
            self.ability:MoonAbsorb(self.parent)
        --check if this debuff should be remove when rescued( literally get kissed at 200 range kekw)
        elseif self.expire == true then
            local allies = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
                    self:GetParent():GetAbsOrigin(),
                    nil,
                    self.rescue,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            if (#allies > 0) then
                self.parent:EmitSound("Hero_Grimstroke.DarkArtistry.PreCastPoint")
                local soulback ="particles/units/npc_boss_venge/venge_moonify/soul_back.vpcf"
                self.soulback = ParticleManager:CreateParticle(soulback, PATTACH_ABSORIGIN_FOLLOW, self.parent)
                Timers:CreateTimer(4, function()
                    ParticleManager:DestroyParticle(self.soulback, false)
                    ParticleManager:ReleaseParticleIndex(self.soulback)
                end)
                self:Destroy()
            end
        end
    end
end

LinkLuaModifier( "modifier_venge_moonify_hide", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_HORIZONTAL )


------------------
--active
------------------
venge_moonify = class({
    GetAbilityTextureName = function(self)
        return "venge_moonify"
    end,
})

function venge_moonify:IsRequireCastbar()
    return true
end

function venge_moonify:IsInterruptible()
    return false
end

function venge_moonify:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function venge_moonify:MoonAbsorb(target)
    if IsServer() then
        local death_fx ="particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_target_death.vpcf"
        self.nPreviewFX = ParticleManager:CreateParticle( death_fx, PATTACH_ABSORIGIN_FOLLOW, target )
        ParticleManager:SetParticleControlEnt(self.nPreviewFX, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.nPreviewFX, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
        target:SetModelScale(0)
        target:ForceKill(false)
        Timers:CreateTimer(5,function()
            target:SetModelScale(1)
        end)
    end
end
function venge_moonify:OnAbilityPhaseStart()
    if IsServer() then
        EmitSoundOn("DOTA_Item.HeavensHalberd.Activate", self:GetCaster() )

        self.nPreviewFX = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_holy_persuasion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    end

    return true
end


function venge_moonify:OnSpellStart()
    if not IsServer() then return end
    ParticleManager:DestroyParticle( self.nPreviewFX, false )
    ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
    self.caster		= self:GetCaster()
    if not self.caster:HasModifier("modifier_venge_side_holy") then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.caster
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_venge_side_holy"
        modifierTable.duration = 5
        GameMode:ApplyBuff(modifierTable)
    end
    self.position	= self:GetCursorPosition()
    self:GetCaster():EmitSoundParams("vengefulspirit_vng_attack_02", 1.0, 5.2, 0)
    -- AbilitySpecials
    self.on_count				= self:GetSpecialValueFor("on_count")
    self.radius					= self:GetSpecialValueFor("radius")
    self.hit_count				= self:GetSpecialValueFor("hit_count")
    self.off_duration			= self:GetSpecialValueFor("off_duration")
    self.on_duration			= self:GetSpecialValueFor("on_duration")
    self.off_duration_initial	= 0
    self.fixed_movement_speed	= self:GetSpecialValueFor("fixed_movement_speed")
    self.range                  = self:GetSpecialValueFor("range")
    -- Calculate total duration that the wisp will be present for using on and off durations
    -- The initial off duration + total amount of time it's on + total amount of time it's off minus one instance
    self.duration = self.off_duration_initial + (self.on_duration * self.on_count) + (self.off_duration * (self.on_count - 1))+0.5
    --if more than 1 enemy full version moonify
    if HeroList:GetHeroCount() > 1 then
        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
                self:GetCaster():GetAbsOrigin(),
                nil,
                self.range,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        if (#enemies > 0) then
            self.target = enemies[1] --random one
        else
            return
        end

        -- hide the moonified boi and make him invul
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.target
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_venge_moonify_hide"
        modifierTable.duration =  -1
        GameMode:ApplyDebuff(modifierTable)
        self.target:EmitSound("Hero_Grimstroke.InkCreature.Spawn")
    else -- solo version
        self.moon = CreateUnitByName("npc_dota_ignis_fatuus", self.caster:GetAbsOrigin(), true, self.caster, self.caster, self.caster:GetTeamNumber())
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.moon
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_venge_moonify"
        modifierTable.duration =  self.duration
        GameMode:ApplyBuff(modifierTable)
    end
end

---------------------
-- venge_quake
---------------------


-- Epicenter modifier
modifier_venge_quake_pulse = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_earth_spirit_petrify.vpcf"
    end,
})

function modifier_venge_quake_pulse:OnCreated()
    if IsServer() then
        -- Ability properties
        self.caster = self:GetCaster()
        self.ability = self:GetAbility()
        self.parent = self:GetParent()
        --self.sound_epicenter = "Ability.SandKing_Epicenter"
        self.aoe_particle = "particles/units/npc_boss_ursa/ursa_slam/ursa_slam_aoe.vpcf"
        self.crack = "particles/units/npc_boss_venge/venge_quake/elder_titan_echo_stomp_cracks_shake.vpcf"
        -- Ability specials
        self.pulse_count = self.ability:GetSpecialValueFor("pulse_count")
        self.damage = self.ability:GetSpecialValueFor("damage")
        self.slow_duration = self.ability:GetSpecialValueFor("slow_duration")
        self.base_radius = self.ability:GetSpecialValueFor("base_radius")
        self.pulse_radius_increase = self.ability:GetSpecialValueFor("pulse_radius_increase")
        self.max_pulse_radius = self.ability:GetSpecialValueFor("max_pulse_radius")
        self.epicenter_duration = self.ability:GetSpecialValueFor("epicenter_duration")
        self.projectile_speed = self.ability:GetSpecialValueFor("projectile_speed")
        self.range = self.ability:GetSpecialValueFor("range")
        -- Play epicenter sound
        --EmitSoundOn(self.sound_epicenter, self.caster)

        -- Assign radius and pulse count
        self.radius = self.base_radius
        self.pulses = 0

        -- Decide the distribution of pulses over the duration of the epicenter
        self.pulse_interval = self.epicenter_duration / self.pulse_count

        -- Start thinking
        self:StartIntervalThink(self.pulse_interval)
    end
end

function modifier_venge_quake_pulse:OnIntervalThink()
    if IsServer() then
        -- Increment pulse count
        self.pulses = self.pulses + 1
        EmitSoundOn("Hero_ElderTitan.EchoStomp", self.parent)

        -- Add particle
        self.aoe_particle_fx = ParticleManager:CreateParticle(self.aoe_particle, PATTACH_ABSORIGIN, self.parent)
        ParticleManager:SetParticleControl(self.aoe_particle_fx, 2, Vector(self.radius, self.radius,225))
        Timers:CreateTimer(3.0, function()
            ParticleManager:DestroyParticle(self.aoe_particle_fx, false)
            ParticleManager:ReleaseParticleIndex(self.aoe_particle_fx)
        end)
        self.crack_fx = ParticleManager:CreateParticle(self.crack, PATTACH_POINT, self.parent)
        Timers:CreateTimer(3.0, function()
            ParticleManager:DestroyParticle(self.crack_fx, false)
            ParticleManager:ReleaseParticleIndex(self.crack_fx)
        end)
        -- Find all nearby enemies in the damage radius
        local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
                self.parent:GetAbsOrigin(),
                nil,
                self.radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)

        for _,enemy in pairs(enemies) do
            if enemy ~= self.parent and self.caster:IsAlive() then
                --earthquake ground wave
                -- Deal damage
                local damageTable = {}
                damageTable.caster = self.caster
                damageTable.target = enemy
                damageTable.ability = self.ability
                damageTable.damage = self.damage
                damageTable.earthdmg = true
                GameMode:DamageUnit(damageTable)
                --ministun
                local modifierTable = {}
                modifierTable.ability = self.ability
                modifierTable.target = enemy
                modifierTable.caster = self.caster
                modifierTable.modifier_name = "modifier_stunned"
                modifierTable.duration = 0.3
                GameMode:ApplyBuff(modifierTable)
                -- Apply Epicenter slow
                modifierTable = {}
                modifierTable.ability = self.ability
                modifierTable.target = enemy
                modifierTable.caster = self.caster
                modifierTable.modifier_name = "modifier_venge_quake_slow"
                modifierTable.duration = self.slow_duration
                GameMode:ApplyBuff(modifierTable)

                --rock projectile

                local vDir = enemy:GetAbsOrigin() - self:GetParent():GetOrigin()
                vDir.z = 0.0
                vDir = vDir:Normalized()

                local info = {
                    EffectName = "particles/units/npc_boss_venge/venge_quake/big_rock.vpcf",
                    Ability = self.ability,
                    vSpawnOrigin = self:GetParent():GetOrigin(),
                    fStartRadius = 250,
                    fEndRadius = 250,
                    vVelocity = vDir * self.projectile_speed,
                    fDistance = self.range,
                    Source = self:GetCaster(),
                    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                    iUnitTargetType = DOTA_UNIT_TARGET_HERO ,
                }
                ProjectileManager:CreateLinearProjectile( info )
            end
        end
        -- Increase radius
        self.radius = self.radius + self.pulse_radius_increase

        -- If the new radius is above the maximum, set as the maximum instead
        if self.radius > self.max_pulse_radius then
            self.radius = self.max_pulse_radius
        end

        -- If there are no more pulses left, remove the modifier
        if self.pulses >= self.pulse_count then
            --StopSoundOn(self.sound_epicenter, self.caster)
            self:Destroy()
        end
    end
end
LinkLuaModifier("modifier_venge_quake_pulse", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

-- Epicenter Slow modifier
modifier_venge_quake_slow = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    GetTexture = function(self)
        return venge_quake:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_ursa/ursa_earthshock_modifier.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end
})

function modifier_venge_quake_slow:OnCreated()
    -- Ability properties
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()

    -- Ability specials
    self.slow = self.ability:GetSpecialValueFor("slow") * -0.01
end

function modifier_venge_quake_slow:GetAttackSpeedPercentBonus()
    return self.slow
end

function modifier_venge_quake_slow:GetMoveSpeedPercentBonus()
    return self.slow
end

function modifier_venge_quake_slow:GetSpellHastePercentBonus()
    return self.slow
end
LinkLuaModifier("modifier_venge_quake_slow", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)
venge_quake = class({
    GetAbilityTextureName = function(self)
        return "venge_quake"
    end,
})

function venge_quake:IsRequireCastbar()
    return true
end

function venge_quake:IsInterruptible()
    return false
end

function venge_quake:OnProjectileHit_ExtraData(target)
    if target then
        if not target:HasModifier("modifier_venge_quake_pulse") and self.caster:IsAlive() then
            local damageTable = {}
            damageTable.caster = self.caster
            damageTable.target = target
            damageTable.ability = self
            damageTable.damage = self.damage * 3
            damageTable.earthdmg = true
            GameMode:DamageUnit(damageTable)
        end
    end
end

function venge_quake:OnAbilityPhaseStart()
    if IsServer() then
        EmitSoundOn("DOTA_Item.HeavensHalberd.Activate", self:GetCaster() )

        self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    end
    return true
end


function venge_quake:OnSpellStart()
    if (not IsServer()) then
        return
    end
    ParticleManager:DestroyParticle( self.nPreviewFX, false )
    ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
    self.caster = self:GetCaster()
    self.damage = self:GetSpecialValueFor("damage")
    self.caster:EmitSoundParams("vengefulspirit_vng_ability_08", 1.0, 2.2, 0)
    if not self.caster:HasModifier("modifier_venge_side_earth") then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.caster
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_venge_side_earth"
        modifierTable.duration = 5
        GameMode:ApplyBuff(modifierTable)
    end
    local range = self:GetSpecialValueFor("range")
    self.epicenter_duration = self:GetSpecialValueFor("epicenter_duration")
    if HeroList:GetHeroCount() > 1 then
        local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
                self.caster:GetAbsOrigin(),
                nil,
                range,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        if (#enemies > 0) then
            self.target = enemies[1] --random one
        else
            return
        end
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.target
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_venge_quake_pulse"
        modifierTable.duration = self.epicenter_duration
        GameMode:ApplyDebuff(modifierTable)
    else
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.caster
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_venge_quake_pulse"
        modifierTable.duration = self.epicenter_duration
        GameMode:ApplyDebuff(modifierTable)
    end
end
---------------------
-- venge_root
---------------------

modifier_venge_root = class({
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
    GetEffectName = function(self)
        return "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle_body.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN
    end,
})

function modifier_venge_root:OnCreated()
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.dot = self:GetAbility():GetSpecialValueFor("dot")
    self.tick = 1 --self:GetAbility():GetSpecialValueFor("tick")
    self:StartIntervalThink(self.tick)
end

function modifier_venge_root:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }
    return state
end

function modifier_venge_root:OnIntervalThink()
    if self.caster:IsAlive() then
        local damageTable = {}
        damageTable.ability = self.ability
        damageTable.caster = self.caster
        damageTable.target = self.parent
        damageTable.damage = self.dot
        damageTable.naturedmg = true
        GameMode:DamageUnit(damageTable)
        local summon_point = self.parent:GetAbsOrigin() + 100 * self.parent:GetForwardVector()
        local treant = CreateUnitByName("npc_boss_treant_lesser_treant", summon_point, true, self.caster, self.caster, self.caster:GetTeam())
        treant:AddNewModifier(self.caster, self.ability, "modifier_kill", { duration = 30 })
        treant:AddNewModifier(self.caster, self.ability, "modifier_venge_root_ignore_aggro_buff", { duration = -1, target = self.parent})
        treant:EmitSound("Hero_Furion.TreantSpawn")
    end
end

LinkLuaModifier("modifier_venge_root", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)

modifier_venge_root_ignore_aggro_buff = class({
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
})

function modifier_venge_root_ignore_aggro_buff:OnCreated(keys)
    if not IsServer() then
        return
    end
    if (not keys or keys.target) then
        self:Destroy()
    end
    self.target = keys.target
end

function modifier_venge_root_ignore_aggro_buff:GetIgnoreAggroTarget()
    return self.target
end

LinkLuaModifier("modifier_venge_root_ignore_aggro_buff", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)
-- ability class
venge_root = class({
    GetAbilityTextureName = function(self)
        return "venge_root"
    end,
})

function venge_root:IsRequireCastbar()
    return true
end

function venge_root:IsInterruptible()
    return false
end

function venge_root:OnAbilityPhaseStart()
    if IsServer() then
        EmitSoundOn("DOTA_Item.HeavensHalberd.Activate", self:GetCaster() )
        self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/npc_boss_treant/treant_flux/flux_gather.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    end
    return true
end

function venge_root:OnSpellStart()
    if IsServer() then
        -- Ability properties
        Timers:CreateTimer(3, function()
            ParticleManager:DestroyParticle( self.nPreviewFX, false )
            ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
        end)
        local tree = "particles/units/heroes/hero_treant/treant_overgrowth_cast_tree.vpcf"
        self.fx = ParticleManager:CreateParticle( tree, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
        Timers:CreateTimer(3, function()
            ParticleManager:DestroyParticle( self.fx, false )
            ParticleManager:ReleaseParticleIndex(self.fx)
        end)
        self.caster = self:GetCaster()
        if not self.caster:HasModifier("modifier_venge_side_nature") then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = self.caster
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_venge_side_nature"
            modifierTable.duration = 5
            GameMode:ApplyBuff(modifierTable)
        end
        local sound_cast = "Hero_Treant.Overgrowth.Cast"
        -- Ability specials
        local radius = self:GetSpecialValueFor("range")
        local duration = self:GetSpecialValueFor("duration")

        -- Play cast sound
        self.caster:EmitSoundParams(sound_cast,1.0, 0.7, 0)
        -- Find all nearby enemies
        local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
                self.caster:GetAbsOrigin(),
                nil,
                radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)

        for _, enemy in pairs(enemies) do
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_venge_root"
            modifierTable.duration = duration
            GameMode:ApplyDebuff(modifierTable)
        end
    end
end

------------------
--venge fel
-------------------
--modifier
-- Damage amp modifier
modifier_venge_fel = class({
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
        return venge_fel:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf"
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
})

function modifier_venge_fel:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.damage = self.ability:GetSpecialValueFor("dot")
    --print(self.damage)
    self.amp = self.ability:GetSpecialValueFor("amp") * -0.01
    --print(self.amp)
    self.interval = 1
    self:StartIntervalThink(self.interval )
end

function modifier_venge_fel:GetDamageReductionBonus()
    return self.amp
end

function modifier_venge_fel:OnIntervalThink()
    if self.caster:IsAlive() then
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = self.parent
        damageTable.ability = self.ability
        damageTable.damage = self.damage
        damageTable.infernodmg = true
        GameMode:DamageUnit(damageTable)
    end
end

LinkLuaModifier("modifier_venge_fel", "creeps/zone1/boss/venge.lua", LUA_MODIFIER_MOTION_NONE)


--active
venge_fel = class({
    GetAbilityTextureName = function(self)
        return "venge_fel"
    end,
})

function venge_fel:IsRequireCastbar()
    return true
end

function venge_fel:IsInterruptible()
    return false
end

function venge_fel:OnAbilityPhaseStart()
    if IsServer() then
        EmitSoundOn("DOTA_Item.HeavensHalberd.Activate", self:GetCaster() )
        self:GetCaster():EmitSoundParams("vengefulspirit_vng_kill_07", 1.0, 5.2, 0)
        self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/heroes/heroes_underlord/underlord_firestorm_pre.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    end
    return true
end

function venge_fel:OnSpellStart()
    if IsServer() then
        ParticleManager:DestroyParticle( self.nPreviewFX, false )
        ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
        self.projectile_speed = self:GetSpecialValueFor("projectile_speed")
        self.duration = self:GetSpecialValueFor("duration")
        self.caster = self:GetCaster()
        if not self.caster:HasModifier("modifier_venge_side_inferno") then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = self.caster
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_venge_side_inferno"
            modifierTable.duration = 5
            GameMode:ApplyBuff(modifierTable)
        end

        local range = self:GetSpecialValueFor("range")
        local number = self:GetSpecialValueFor("number")
        local counter= 0
        Timers:CreateTimer(0,function()
            if counter < number then
                local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
                        self.caster:GetAbsOrigin(),
                        nil,
                        range,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false)
                if (#enemies > 0) then
                    self.target = enemies[1] --random one
                else
                    return
                end
                local info = {
                    Target = self.target,
                    Source = self.caster,
                    Ability = self,
                    EffectName = "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf",
                    iMoveSpeed = self.projectile_speed,
                    bDodgeable = true,
                }

                ProjectileManager:CreateTrackingProjectile( info )
                self.caster:EmitSoundParams("Hero_SkeletonKing.Hellfire_Blast", 1.0, 0.4, 0)
                counter = counter +1
                return 0.2
            end
        end)
        StopSoundOn( "DOTA_Item.HeavensHalberd.Activate", self:GetCaster() )
    end
end

function venge_fel:OnProjectileHit( hTarget, vLocation )
    if IsServer() then
        if hTarget then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = hTarget
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_venge_fel"
            modifierTable.duration = self.duration
            GameMode:ApplyDebuff(modifierTable)
            hTarget:EmitSound("Hero_SkeletonKing.Hellfire_BlastImpact")
        end
    end
end
if (IsServer() and not GameMode.ZONE1_BOSS_VENGE) then
    --GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_venge_bubble_passive, 'OnTakeDamage'))
    --GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_venge_moonify, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_venge_side_frost, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_venge_side_void, 'OnPostTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_venge_side_holy, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_venge_side_inferno, 'OnTakeDamage'))
    GameMode.ZONE1_BOSS_VENGE = true
end





