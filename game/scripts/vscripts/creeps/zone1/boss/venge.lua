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
--------
--venge moonfall
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
        caster:EmitSound("vengefulspirit_vng_attack_08")

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
                        target_point 		= enemy:GetAbsOrigin()
                        local new_target_point = target_point + Vector(math.random(-700, 700),math.random(-700, 700),0 )
                        venge_fall:CastMeteor(caster, ability, new_target_point, number_of_meteors)

                        if fired_meteors == number_of_meteors then
                            return
                        elseif fired_meteors == number_of_meteors - 1 then
                            return 0.5
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

        CreateModifierThinker(
                caster,
                ability,
                "modifier_venge_fall",
                {
                    duration = chaos_meteor_land_time
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
        --self.location_difference_normalized 	= (self.target_point - self.caster_location_ground):Normalized()
        self.chaos_meteor_land_time 			= self.ability:GetSpecialValueFor("land_time")
        --self.chaos_meteor_velocity 				= self.location_difference_normalized * self.chaos_meteor_travel_speed
        self.chaos_meteor_duration 				= self.chaos_meteor_travel_distance / self.chaos_meteor_travel_speed

        -- Play Chaos Meteor Sounds
        self.caster:EmitSoundParams("Hero_Invoker.ChaosMeteor.Cast",1.0, 0.2, 0)

        self.meteor_dummy = CreateModifierThinker(self.caster, self.ability, "modifier_venge_fall_thinker", {}, self.target_point, self.caster:GetTeamNumber(), false)
        self.meteor_dummy:EmitSoundParams("Hero_Invoker.ChaosMeteor.Loop",1.0, 0.2, 0)

        --need to random velocity here and use later to make a match animation
        local direction = Vector(math.random(-100,100), math.random(-100,100), 0):Normalized()
        self.chaos_meteor_velocity 		        = direction * self.chaos_meteor_travel_speed

        -- Create start_point of the meteor 1000z up in the air! Meteors velocity is same while falling through the air as it is rolling on the ground.
        local chaos_meteor_fly_original_point = (self.target_point - (self.chaos_meteor_velocity * self.chaos_meteor_land_time)) + Vector(0, 0, 1000)
        --Create the particle effect consisting of the meteor falling from the sky and landing at the target point.
        self.chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/units/npc_boss_venge/venge_fall/venge_fall_fly.vpcf", PATTACH_ABSORIGIN, self.caster)
        ParticleManager:SetParticleControl(self.chaos_meteor_fly_particle_effect, 0, chaos_meteor_fly_original_point)
        ParticleManager:SetParticleControl(self.chaos_meteor_fly_particle_effect, 1, self.target_point)
        ParticleManager:SetParticleControl(self.chaos_meteor_fly_particle_effect, 2, Vector(self.chaos_meteor_land_time, 0, 0))
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
            EffectName 					= "particles/units/npc_boss_venge/venge_fall/venge_fall.vpcf",--"particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
            --"particles/hero/invoker/chaosmeteor/imba_invoker_chaos_meteor.vpcf",
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
            EntIndexToHScript(ExtraData.meteor_dummy):RemoveSelf()
        end
    end
end
----------
--modifier for storing velocity
-----------
modifier_venge_fall_velocity = class({})

function modifier_venge_fall_velocity:OnCreated()
    if not IsServer() then
        return
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
    AllowIllusionDuplicate = function(self)
        return false
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


--------------------------------------------------------------------------------------------------------------------
-- Chaos Meteor burn effect
--------------------------------------------------------------------------------------------------------------------
modifier_venge_fall_burn_effect = class({})
function modifier_venge_fall_burn_effect:IsHidden() 		return true end
function modifier_venge_fall_burn_effect:GetEffectName() return "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf" end



--remove thinker
modifier_venge_fall_thinker = class({})

function modifier_venge_fall_thinker:OnDestroy()
    if not IsServer() then
        return
    end
    UTIL_Remove(self:GetParent())
end


--------
--venge umbra
----------
--local particle = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf"
--local sound_cast ="Hero_NyxAssassin.ManaBurn.Target"



--------------------
--venge mindcontrol
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
    end, --tried to make this boi black but cant idk why
})


function modifier_venge_mind_control:OnCreated( kv )
    if IsServer() then
        if self:GetParent():GetForceAttackTarget() then
            self:Destroy()
            return
        end
        self.movespeed_bonus = self:GetAbility():GetSpecialValueFor( "movespeed_bonus" )*0.01
        self.attackspeed_bonus = self:GetAbility():GetSpecialValueFor( "attackspeed_bonus" )*0.01
        self.target_search_radius = self:GetAbility():GetSpecialValueFor( "target_search_radius" )
        self.charm_duration = self:GetAbility():GetSpecialValueFor( "charm_duration" )
        self.stun = self:GetAbility():GetSpecialValueFor("stun")
        self:GetParent():Interrupt()
        self:GetParent():SetIdleAcquire( true )

        self:GetParent():AddNewModifier( self:GetCaster(), nil, "modifier_phased", { duration = -1 } )

        local hAllies = FindUnitsInRadius( self:GetParent():GetTeamNumber(),
                self:GetParent():GetOrigin(),
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
            self:GetParent():SetForceAttackTargetAlly( self.hDesiredTarget )

            local modifierTable = {}
            modifierTable.ability = self:GetAbility()
            modifierTable.target = self.hDesiredTarget
            modifierTable.caster = self:GetCaster()
            modifierTable.modifier_name = "modifier_venge_mind_control_marked"
            modifierTable.duration = self.charm_duration
            GameMode:ApplyDebuff(modifierTable)

            self:StartIntervalThink( 0.5 )
        else -- no nearby ally to hit
            self:Destroy()
            --check if party or solo
            if HeroList:GetHeroCount() > 1 then
                local modifierTable = {}
                modifierTable.ability = self:GetAbility()
                modifierTable.target = self:GetParent()
                modifierTable.caster = self:GetCaster()
                modifierTable.modifier_name = "modifier_stunned"
                modifierTable.duration = self.stun
                GameMode:ApplyDebuff(modifierTable)
                else
                local modifierTable = {}
                modifierTable.ability = self:GetAbility()
                modifierTable.target = self:GetParent()
                modifierTable.caster = self:GetCaster()
                modifierTable.modifier_name = "modifier_stunned"
                modifierTable.duration = 3
                GameMode:ApplyDebuff(modifierTable)
            end
            --local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
                    --self:GetCaster():GetAbsOrigin(),
                    --nil,
                    --30000,
                    --DOTA_UNIT_TARGET_TEAM_ENEMY,
                    --DOTA_UNIT_TARGET_HERO,
                    --DOTA_UNIT_TARGET_FLAG_NONE,
                    --FIND_ANY_ORDER,
                    --false)
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
        if self:GetParent():GetForceAttackTarget() == nil then
            self:GetParent():SetForceAttackTargetAlly( self.hDesiredTarget )
        end

        if self.hDesiredTarget == nil or self.hDesiredTarget:IsAlive() == false then
            self:Destroy()
            return
        end
    end
end

function modifier_venge_mind_control:OnDestroy()
    if IsServer() then
        self:GetParent():SetForceAttackTargetAlly( nil )

        self:GetParent():RemoveModifierByName( "modifier_phased" )
        self:GetParent():RemoveModifierByName( "modifier_venge_mind_control_black" )
        EmitSoundOn( "Hero_DarkWillow.Ley.Stun", self:GetParent() )
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

        self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_nevermore/nevermore_wings.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    end
    return true
end

function venge_mind_control:OnSpellStart()
    if IsServer() then
        ParticleManager:DestroyParticle( self.nPreviewFX, false )
        ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
        self.projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
        self.charm_duration = self:GetSpecialValueFor( "charm_duration" )
        self:GetCaster():EmitSound("vengefulspirit_vng_kill_01")
        local range = self:GetSpecialValueFor("range")
        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
                self:GetCaster():GetAbsOrigin(),
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
            Source = self:GetCaster(),
            Ability = self,
            EffectName = "particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf",
            iMoveSpeed = self.projectile_speed,
            vSourceLoc = self:GetCaster():GetOrigin(),
            bDodgeable = false,
            bProvidesVision = false,
            flExpireTime = GameRules:GetGameTime() + 10 --self.projectile_expire_time,
        }

        ProjectileManager:CreateTrackingProjectile( info )

        StopSoundOn( "DOTA_Item.HeavensHalberd.Activate", self:GetCaster() )
        EmitSoundOn( "Hero_ShadowDemon.Disruption", self:GetCaster() )
    end
end

function venge_mind_control:OnProjectileHit( hTarget, vLocation )
    if IsServer() then
        if hTarget ~= nil and ( not hTarget:IsInvulnerable() ) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = hTarget
            modifierTable.caster = self:GetCaster()
            modifierTable.modifier_name = "modifier_venge_mind_control"
            modifierTable.duration = self.charm_duration
            GameMode:ApplyDebuff(modifierTable)
            local hit = "particles/units/heroes/hero_nevermore/nevermore_loadout.vpcf"
            local bound_fx = ParticleManager:CreateParticle(hit, PATTACH_POINT_FOLLOW,  hTarget)
            Timers:CreateTimer(2.0, function()
                ParticleManager:DestroyParticle(bound_fx, false)
                ParticleManager:ReleaseParticleIndex(bound_fx)
            end)
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
        return "particles/econ/events/ti7/fountain_regen_ti7_bubbles.vpcf"
    end,
    GetTexture = function(self)
        return venge_tide:GetAbilityTextureName()
    end,

})

function modifier_venge_bubble:OnCreated( kv )
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.bubble_tick = self:GetAbility():GetSpecialValueFor( "bubble_tick" )
    local Max_Health = self:GetParent():GetMaxHealth()
    self.bubble_damage = self:GetAbility():GetSpecialValueFor( "bubble_damage" ) * Max_Health * 0.01

    self.hBubble = CreateUnitByName( "npc_boss_venge_bubble", self:GetParent():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber() )
    --self.hBubble:AddNewModifier( self:GetCaster(), self, "modifier_venge_bubble_passive", { duration = -1 })
    local modifierTable = {}
    modifierTable.ability = self:GetAbility()
    modifierTable.target = self.hBubble
    modifierTable.caster = self:GetCaster()
    modifierTable.modifier_name = "modifier_venge_bubble_passive"
    modifierTable.duration = -1
    GameMode:ApplyBuff(modifierTable)
    self.drown = "g.venge_bubble_drowning" --custom bubble sound doesnt work
    self.parent:EmitSound(self.drown)
    self:StartIntervalThink( self.bubble_tick )

    --visual
    self.parent:StartGesture(ACT_DOTA_FLAIL)
end

function modifier_venge_bubble:OnIntervalThink( )
    local damageTable = {}
    damageTable.caster = self:GetCaster()
    damageTable.target =  self:GetParent()
    damageTable.ability = self:GetAbility()
    damageTable.damage = self.bubble_damage
    damageTable.frostdmg = true
    GameMode:DamageUnit(damageTable)
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

function modifier_venge_bubble:GetHealthRegenerationPercentBonus()
    return -1
end

function modifier_venge_bubble:GetHealingReceivedPercentBonus()
    return -1
end

function modifier_venge_bubble:GetSpellDamageBonus()
    return -1
end

function modifier_venge_bubble:GetAttackDamagePercentBonus()
    return -1
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH,
                 MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
                 MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
                 MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
                 MODIFIER_EVENT_ON_ATTACKED}
    end
})

function modifier_venge_bubble_passive:OnCreated( kv )
    if IsServer() then
        self.parent = self:GetParent()
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
                self:Destroy()
            end
        end
    end
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
            Timers:CreateTimer(1, function()
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
        EmitSoundOn("vengefulspirit_vng_spawn_07", self:GetCaster())
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
        Timers:CreateTimer(0, function()
            if counter < number then
                self:ShootSet()
                self:GetCaster():EmitSound("Hero_Morphling.Waveform")
                counter = counter + 1
                return 1
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

--function modifier_venge_moonify_aura:GetEffectName()
    --return "particles/units/heroes/hero_keeper_of_the_light/keeper_dazzling_debuff.vpcf"
--end

-- Doesn't feel like this is working for some reason
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
        local caster_location = self.caster:GetAbsOrigin()
        local current_location = self.parent:GetAbsOrigin()
        self.expected_location = current_location + self.parent:GetForwardVector() * self.fixed_movement_speed * dt
        --local isTraversable = GridNav:IsTraversable(expected_location)
        --local isBlocked = GridNav:IsBlocked(expected_location)
        --local isTreeNearby = GridNav:IsNearbyTree(expected_location, self.parent:GetHullRadius(), true)
        --local traveled_distance = DistanceBetweenVectors(current_location, self.start_location)
        local distance_to_caster = DistanceBetweenVectors(current_location, caster_location)
        if ( distance_to_caster > 350 ) then --and not distance_to_caster< 250 --isTraversable and not isBlocked and not isTreeNearby and t
            self.parent:SetAbsOrigin(self.expected_location)
            local damageTable = {}
            damageTable.caster = self.caster
            damageTable.target = self.parent
            damageTable.ability = self.ability
            damageTable.damage = self.damage
            damageTable.earthdmg = true
            GameMode:DamageUnit(damageTable)
        elseif ( distance_to_caster <= 350 and distance_to_caster > 100 ) then
            self.parent:SetAbsOrigin(self.expected_location)
            local damageTable = {}
            damageTable.caster = self.caster
            damageTable.target = self.parent
            damageTable.ability = self.ability
            damageTable.damage = self.damage*3
            damageTable.earthdmg = true
            GameMode:DamageUnit(damageTable)
        else
            self:Destroy()
            self.parent:ForceKill(false)
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
        return "particles/status_fx/status_effect_earth_spirit_petrify.vpcf"
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
        self.ppfx = ParticleManager:CreateParticle("particles/frostivus_herofx/juggernaut_omnislash_ascension.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
        Timers:CreateTimer(1.5, function()
            ParticleManager:DestroyParticle(self.ppfx, false)
            ParticleManager:ReleaseParticleIndex(self.ppfx)
        end)
        --showing countdown
        local counter ="particles/units/heroes/hero_abaddon/abaddon_curse_counter_stack.vpcf"
        local tick = 1
        self.delay = 10
        --death if not rescued
        Timers:CreateTimer(0, function()
            if self.parent:IsAlive() and self.parent:HasModifier("modifier_venge_moonify_hide") then
                self.parent:EmitSound("Hero_DarkWillow.Ley.Count")
                self.delay = self.delay - tick
                --countdown particle
                self.pidx = ParticleManager:CreateParticle(counter, PATTACH_OVERHEAD_FOLLOW, self.parent)
                ParticleManager:SetParticleControl(self.pidx, 0, Vector(0, math.max(0, 0, 300)))
                ParticleManager:SetParticleControl(self.pidx, 1, Vector(0, math.max(0, math.floor(self.delay)), 0))
                Timers:CreateTimer(0.8, function()
                    ParticleManager:DestroyParticle(self.pidx, false)
                    ParticleManager:ReleaseParticleIndex(self.pidx)
                end)
                --kill that no friend boi
                if self.parent:HasModifier("modifier_venge_moonify_hide") and self.expire == true and self.alive == false and self.delay < 1 then
                    self.parent:ForceKill(false)
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
            self.parent:EmitSound("Hero_EarthSpirit.StoneRemnant.Destroy ")
            self.parent:ForceKill(false)
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

function venge_mind_control:IsRequireCastbar()
    return true
end

function venge_mind_control:IsInterruptible()
    return false
end

function venge_moonify:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function venge_moonify:OnAbilityPhaseStart()
    if IsServer() then
        EmitSoundOn("DOTA_Item.HeavensHalberd.Activate", self:GetCaster() )

        self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_chen/chen_holy_persuasion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    end

    return true
end


function venge_moonify:OnSpellStart()
    if not IsServer() then return end
    ParticleManager:DestroyParticle( self.nPreviewFX, false )
    ParticleManager:ReleaseParticleIndex(self.nPreviewFX)
    self.caster		= self:GetCaster()

    self.position	= self:GetCursorPosition()
    self:GetCaster():EmitSound("vengefulspirit_vng_attack_02")
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
end

--if (IsServer() and not GameMode.ZONE1_BOSS_VENGE) then
    --GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_venge_bubble_passive, 'OnTakeDamage'))
    --GameMode.ZONE1_BOSS_VENGE = true
--end





