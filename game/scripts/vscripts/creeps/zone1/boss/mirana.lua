---------------
--HELPER FUNCTION
-----------------
function IsLuna(unit)
    if unit:GetUnitName() == "npc_boss_luna" then
        return true
    else
        return false
    end
end

function RotateVectorAroundAngle( vec, angle )
    local x = vec[1]
    local y = vec[2]
    angle = angle * 0.01745
    local vec2 = Vector(0,0,0)
    vec2[1] = x * math.cos(angle) - y * math.sin(angle)
    vec2[2] = x * math.sin(angle) + y * math.cos(angle)
    return vec2
end
--------------
--mirana shard
---------------
mirana_shard = class({
    GetAbilityTextureName = function(self)
        return "mirana_shard"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_mirana_shard"
    end,
})

modifier_mirana_shard = class({
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
        return true
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_mirana_shard:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_mirana_shard:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    if (keys.attacker == self.parent) and keys.attacker:IsAlive() then
        self.mana_burn = self:GetAbility():GetSpecialValueFor("mana_burn") * 0.01
        self.void_per_burn = self:GetAbility():GetSpecialValueFor("void_per_burn") *0.01
        local Max_mana = keys.target:GetMaxMana()
        local burn = Max_mana * self.mana_burn

        local Mana = keys.target:GetMana()
        --if burn more than current mana burn equal to current mana
        if burn > Mana then
            burn = Mana
        end
        local damage = burn * self.void_per_burn
        keys.target:ReduceMana(burn)
        keys.target:EmitSound("Hero_Antimage.ManaBreak")
        local manaburn_pfx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/am_manaburn_basher_ti_5.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
        ParticleManager:SetParticleControl(manaburn_pfx, 0, keys.target:GetAbsOrigin() )
        ParticleManager:ReleaseParticleIndex(manaburn_pfx)

        local damageTable= {}
        damageTable.caster = keys.attacker
        damageTable.target = keys.target
        damageTable.ability = self.ability
        damageTable.damage = damage
        damageTable.voiddmg = true
        GameMode:DamageUnit(damageTable)
    end
end

LinkLuaModifier("modifier_mirana_shard", "creeps/zone1/boss/mirana.lua", LUA_MODIFIER_MOTION_NONE)

--------------
--mirana sky
---------------

modifier_mirana_sky = class({
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

function modifier_mirana_sky:OnCreated()
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

function modifier_mirana_sky:GetFixedDayVision()
    return self.fixed_vision
end

function modifier_mirana_sky:GetFixedNightVision()
    return self.fixed_vision
end

function modifier_mirana_sky:OnDeath(params)
    if (not IsServer()) then
        return
    end
    if params.unit == self.caster  then
        self:Destroy()
    end
end

function modifier_mirana_sky:OnIntervalThink()
    self.game_mode = GameRules:GetGameModeEntity()
    GameRules:BeginTemporaryNight(30)
end


LinkLuaModifier("modifier_mirana_sky", "creeps/zone1/boss/mirana.lua", LUA_MODIFIER_MOTION_NONE)

mirana_sky = class({
    GetAbilityTextureName = function(self)
        return "mirana_sky"
    end,
})

function mirana_sky:OnSpellStart()
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
            modifierTable.modifier_name = "modifier_mirana_sky"
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

--------------
--mirana blessing
---------------
mirana_blessing = class({
    GetAbilityTextureName = function(self)
        return "mirana_blessing"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_mirana_blessing"
    end,
})

modifier_mirana_blessing = class({
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
        return { MODIFIER_EVENT_ON_DEATH }
    end,
})

function modifier_mirana_blessing:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.luna_far = nil
    Timers:CreateTimer(0, function()
        if self.luna_far == nil then
            self.luna_far = self.ability:FindLuna(self.parent, 25000)
            return 0.1
        end
    end)
    self:StartIntervalThink(0.5)
end

function mirana_blessing:FindLuna(parent, range)
    local allies = FindUnitsInRadius(parent:GetTeamNumber(),
            parent:GetAbsOrigin(),
            nil,
            range,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local luna = allies[1]
    if IsLuna(luna) == true then
        return luna
    else return nil
    end
end

function modifier_mirana_blessing:OnIntervalThink()
    self.luna = self.ability:FindLuna(self.parent, 2000)
    if self.luna == nil then
        return
    else
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.target = self.luna
        modifierTable.caster = self.parent
        modifierTable.modifier_name = "modifier_mirana_blessing_buff"
        modifierTable.duration = 5
        GameMode:ApplyBuff(modifierTable)
        modifierTable.ability = self.ability
        modifierTable.target = self.parent
        modifierTable.caster = self.parent
        modifierTable.modifier_name = "modifier_mirana_blessing_buff"
        modifierTable.duration = 5
        GameMode:ApplyBuff(modifierTable)
    end
end

function modifier_mirana_blessing:OnDeath(params)
    if (params.unit == self.parent) or params.unit == self.luna_far then
        self.parent:RemoveModifierByName("modifier_mirana_blessing_buff ")
        self.parent:RemoveModifierByName("modifier_mirana_blessing")
        self.luna_far:RemoveModifierByName("modifier_mirana_blessing_buff ")
    end
end

LinkLuaModifier("modifier_mirana_blessing", "creeps/zone1/boss/mirana.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mirana_blessing_buff = class({
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
        return mirana_blessing:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/econ/courier/courier_hyeonmu_ambient/courier_hyeonmu_ambient_blue_plus.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end,

})

function modifier_mirana_blessing_buff:OnCreated()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.dmg_reduction_final = self.ability:GetSpecialValueFor("dmg_reduction") * 0.01
    self.as_bonus_final = self.ability:GetSpecialValueFor("as_bonus") * 0.01
end

function modifier_mirana_blessing_buff:GetDamageReductionBonus()
    return self.dmg_reduction_final
end

function modifier_mirana_blessing_buff:GetAttackSpeedPercentBonus()
    return self.as_bonus_final
end



LinkLuaModifier("modifier_mirana_blessing_buff", "creeps/zone1/boss/mirana.lua", LUA_MODIFIER_MOTION_NONE)

--------------
--mirana holy
---------------
modifier_mirana_holy = class({
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

function modifier_mirana_holy:OnCreated()
    if (not IsServer()) then
        return
    end
    local particle_moon = "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf"
    local caster = self:GetCaster()
    local caster_position = self:GetCaster():GetAbsOrigin()
    local counter = 0
    local number = self:GetAbility():GetSpecialValueFor("number")
    caster:EmitSound("mirana_mir_attack_0"..math.random(2,4))
    Timers:CreateTimer(0.2, function()
        if counter < number and self ~= nil then
            caster:StartGestureWithPlaybackRate	(ACT_DOTA_ATTACK, 0.85)
            local particle_moon_fx = ParticleManager:CreateParticle(particle_moon, PATTACH_ABSORIGIN, caster)
            ParticleManager:SetParticleControl(particle_moon_fx, 0, Vector(caster_position.x, caster_position.y, caster_position.z + 400))
                Timers:CreateTimer(1.0, function()
                    ParticleManager:DestroyParticle(particle_moon_fx, false)
                    ParticleManager:ReleaseParticleIndex(particle_moon_fx)
                 end)
            counter = counter +1
            return 1
        end
    end)
end

function modifier_mirana_holy:OnDestroy()
    if IsServer() then
        local caster = self:GetCaster()
        caster:RemoveGesture(ACT_DOTA_ATTACK)
    end
end

function modifier_mirana_holy:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_SILENCED] = true
    }
    return state
end

LinkLuaModifier("modifier_mirana_holy", "creeps/zone1/boss/mirana.lua", LUA_MODIFIER_MOTION_NONE)

mirana_holy = class({
    GetAbilityTextureName = function(self)
        return "mirana_holy"
    end,
})

function mirana_holy:IsRequireCastbar()
    return true
end

function mirana_holy:IsInterruptible()
    return false
end

function mirana_holy:ShootSet(range, caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed)
    if (not IsServer()) then
        return
    end
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            range,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO ,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        --particle
        self.arrow_particle = "particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf"
        local enemy_loc = enemy:GetAbsOrigin()
        local distance = enemy_loc - caster_loc
        local direction = distance:Normalized()
        local projectile =
        {
            Ability				= self,
            EffectName			= self.arrow_particle,
            vSpawnOrigin		= caster:GetAbsOrigin(),
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


    end
    -- Play cast sound
    caster:EmitSound("Hero_Mirana.ArrowCast")
end

function mirana_holy:OnAbilityPhaseStart()
    if IsServer() then
        local caster = self:GetCaster()
        local caster_position = caster:GetAbsOrigin()
        local particle_moon = "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf"
        local particle_moon_fx = ParticleManager:CreateParticle(particle_moon, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_moon_fx, 0, Vector(caster_position.x, caster_position.y, caster_position.z + 400))
        Timers:CreateTimer(2, function()
            ParticleManager:DestroyParticle(particle_moon_fx, false)
            ParticleManager:ReleaseParticleIndex(particle_moon_fx)
        end)
    end

    return true
end



function mirana_holy:OnSpellStart()
    if IsServer() then
        -- Ability properties
        local caster = self:GetCaster()
        local caster_loc = caster:GetAbsOrigin()
        -- Ability specials
        local travel_distance = self:GetSpecialValueFor("range")
        local start_radius = self:GetSpecialValueFor("radius")
        local end_radius = self:GetSpecialValueFor("radius")
        local projectile_speed = self:GetSpecialValueFor("projectile_speed")
        local range = self:GetSpecialValueFor("range")
        local number = self:GetSpecialValueFor("number")
        local counter = 0
        --root and disarm
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_mirana_holy"
        modifierTable.duration = number-0.5
        GameMode:ApplyBuff(modifierTable)
        --arrow once every 1 s
        Timers:CreateTimer(0, function()
            --add counter each set of arrows
            if counter < number and caster:HasModifier("modifier_mirana_holy") then
                self:ShootSet(range, caster, caster_loc, travel_distance, start_radius, end_radius, projectile_speed)
                counter = counter + 1
                return 1
            end
        end)
    end
end

function mirana_holy:OnProjectileHit_ExtraData(target)
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    local stun = self:GetSpecialValueFor("stun")
    if target and caster:IsAlive() then
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.holydmg = true
        GameMode:DamageUnit(damageTable)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = target
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_stunned"
        modifierTable.duration = stun
        GameMode:ApplyDebuff(modifierTable)
    end
end

--------------
--mirana under
---------------
-- modifier
modifier_mirana_under_silence = class({
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
        return mirana_under:GetAbilityTextureName()
    end
})

function modifier_mirana_under_silence:CheckState()
    local state = { [MODIFIER_STATE_SILENCED] = true, }
    return state
end

LinkLuaModifier("modifier_mirana_under_silence", "creeps/zone1/boss/mirana.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mirana_under = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return true
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

})

function modifier_mirana_under:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.interval = self:GetAbility():GetSpecialValueFor("interval") --4
    self.silence = self:GetAbility():GetSpecialValueFor("silence") --3
    --other instances
    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_mirana_under:OnIntervalThink()
    local modifierTable = {}
    modifierTable.ability = self.ability
    modifierTable.target = self.parent
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_mirana_under_silence"
    modifierTable.duration = self.silence
    GameMode:ApplyDebuff(modifierTable)
    local particle_ray = "particles/units/heroes/hero_mirana/mirana_moonlight_ray.vpcf"
    local ray_fx = ParticleManager:CreateParticle(particle_ray, PATTACH_POINT_FOLLOW, self.parent)
    Timers:CreateTimer(3.0, function()
        ParticleManager:DestroyParticle(ray_fx, false)
        ParticleManager:ReleaseParticleIndex(ray_fx)
    end)
end

LinkLuaModifier("modifier_mirana_under", "creeps/zone1/boss/mirana.lua", LUA_MODIFIER_MOTION_NONE)

mirana_under = class({
    GetAbilityTextureName = function(self)
        return "mirana_under"
    end,
})

function mirana_under:IsRequireCastbar()
    return true
end

function mirana_under:IsInterruptible()
    return false
end

function mirana_under:OnAbilityPhaseStart()
    if IsServer() then
        local caster = self:GetCaster()
        local wax = "particles/econ/items/luna/luna_lucent_ti5/luna_eclipse_cast_moonfall.vpcf"
        local wax_fx = ParticleManager:CreateParticle(wax, PATTACH_POINT_FOLLOW, caster)
        ParticleManager:SetParticleControl(wax_fx, 1, Vector(300, 0, 0))--self.radius
        Timers:CreateTimer(5, function()
            ParticleManager:DestroyParticle(wax_fx, false)
            ParticleManager:ReleaseParticleIndex(wax_fx)
        end)
    end

    return true
end

function mirana_under:FindTargetForSilence(caster) --random with already hit removal
    if IsServer() then
        local radius = self:GetSpecialValueFor("range")
        -- Find all nearby enemies
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        local randomEnemy
        for _, enemy in pairs(enemies) do
            if not enemy:HasModifier("modifier_mirana_under") then
                randomEnemy = enemy
                break
            end
        end
        return randomEnemy
    end
end

function mirana_under:Silence(target)
    if (not IsServer()) then
        return
    end
    if (target == nil) then
        return
    end
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_mirana_under"
    modifierTable.duration = self.duration
    GameMode:ApplyDebuff(modifierTable)
    target:EmitSound("Hero_SkywrathMage.AncientSeal.Target")
end

function mirana_under:StarShower(caster, pos, lifetimeinticks, tickdelay, movement,aoe, damage  )
    if not caster:IsNull() then
        local offset_start = math.random(0,359)
        local strikepos = pos
        --each set of stars have different pattern
        local responses =
        {
            "outercircle_innercircle",
            "spiral_in_random",
            "spiral_out_random",
            "from_out_inwards",
            "random",
            "circleoutin",
            "forwardandcircle",
            "forwardrandom"

        }
        local aoetype = responses[RandomInt(1, #responses)]
        local path_direction
        print(aoetype)
        -- boss aoe random
        if aoetype == "outercircle_innercircle" then
            local radius = 900
            for i=1, lifetimeinticks do
                Timers:CreateTimer(tickdelay*(i-1), function()
                    if i > lifetimeinticks / 2 then
                        radius = 450
                    end
                    strikepos = pos + Vector(radius*math.cos(math.rad(offset_start+2*i*360/lifetimeinticks)), radius*math.sin(math.rad(offset_start+2*i*360/lifetimeinticks)), 0)
                    self:ShowerAoe(caster, aoe, strikepos, damage)
                end)
            end
        elseif aoetype == "spiral_in_random" then
            for i=1, lifetimeinticks do
                Timers:CreateTimer(tickdelay*(lifetimeinticks-i), function()
                    strikepos = strikepos + Vector((lifetimeinticks-i)*movement*math.cos(math.rad(offset_start+i*20)), (lifetimeinticks-i)*movement*math.sin(math.rad(offset_start+i*20)), 0)
                    self:ShowerAoe(caster, aoe, strikepos, damage)
                end)
            end
        elseif aoetype == "spiral_out_random" then
            for i=1, lifetimeinticks do
                Timers:CreateTimer(tickdelay*(i-1), function()
                    strikepos = strikepos + Vector(i*movement*math.cos(math.rad(offset_start+i*20)), i*movement*math.sin(math.rad(offset_start+i*20)), 0)
                    self:ShowerAoe(caster, aoe, strikepos, damage)
                end)
            end
        elseif aoetype == "from_out_inwards" then
            strikepos = pos + Vector(1500*math.cos(math.rad(offset_start)), 1500*math.sin(math.rad(offset_start)), 0)
            local direction = (pos - strikepos):Normalized()
            for i=1, lifetimeinticks do
                Timers:CreateTimer(tickdelay*(i-1), function()
                    strikepos = strikepos + i*movement*direction
                    self:ShowerAoe(caster, aoe, strikepos, damage)
                end)
            end
        elseif aoetype == "random" then
            strikepos = pos + Vector(math.random(150,200)*math.cos(math.rad(offset_start)), math.random(150,200)*math.sin(math.rad(offset_start)), 0)
            path_direction = Vector(0,0,0) + RandomVector(1)
            for i=1, lifetimeinticks do
                Timers:CreateTimer(tickdelay*(i-1), function()
                    strikepos = strikepos + movement*path_direction
                    self:ShowerAoe(caster, aoe, strikepos, damage)
                end)
            end
        elseif aoetype == "circleoutin" then
            local distance = 0
            local distance_per_tick = 400
            local angle = 0
            local angle_per_tick = 15
            path_direction = Vector(0,0,0) + RandomVector(1)
            for i=1, lifetimeinticks do
                Timers:CreateTimer(tickdelay*(i-1), function()
                    distance = distance + distance_per_tick
                    angle = angle + angle_per_tick
                    if i == math.floor(lifetimeinticks / 2) then
                        distance_per_tick = -1 * distance_per_tick
                    end
                    strikepos = pos + RotateVectorAroundAngle(Vector(1,0,0), angle) * distance
                    self:ShowerAoe(caster, aoe, strikepos, damage)
                end)
            end
        elseif aoetype == "forwardandcircle" then
            local startpos = pos - caster:GetForwardVector() * 2000
            local radius = 650
            local angle = 0
            local angle_per_tick = 25
            local forward_per_tick = 300
            path_direction = (pos - startpos):Normalized()
            for i=1, lifetimeinticks do
                Timers:CreateTimer(tickdelay*(i-1), function()
                    angle = angle + angle_per_tick
                    strikepos = startpos + RotateVectorAroundAngle(Vector(1,0,0), angle) * radius + path_direction * i * forward_per_tick
                    self:ShowerAoe(caster, aoe, strikepos, damage)
                end)
            end
        elseif aoetype == "forwardrandom" then
            path_direction = Vector(0,0,0) + RandomVector(1)
            local angle_max = 25
            movement = 450
            for i=1, lifetimeinticks do
                Timers:CreateTimer(tickdelay*(i-1), function()
                    strikepos = strikepos + movement*path_direction
                    path_direction = RotateVectorAroundAngle(path_direction, math.random(-angle_max, angle_max))
                    angle_max = angle_max + 3
                    self:ShowerAoe(caster, aoe, strikepos, damage)
                end)
            end
        end
    end
end

function mirana_under:ShowerAoe(caster, aoe, strikepos, damage)
    if not caster:IsNull() then
        local particle_starfall_fx = ParticleManager:CreateParticle( "particles/econ/items/mirana/mirana_starstorm_bow/mirana_starstorm_starfall_attack.vpcf",  PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(particle_starfall_fx, 0, strikepos)
        ParticleManager:SetParticleControl(particle_starfall_fx, 1, strikepos)
        ParticleManager:SetParticleControl(particle_starfall_fx, 3, strikepos)
        Timers:CreateTimer(2.0, function()
            ParticleManager:DestroyParticle(particle_starfall_fx, false)
            ParticleManager:ReleaseParticleIndex(particle_starfall_fx)
        end)
        Timers:CreateTimer(0.57, function()
            local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
                    strikepos,
                    nil,
                    aoe,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO ,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            for _, enemy in pairs(enemies) do
                if caster:IsAlive() then
                    local damageTable = {}
                    damageTable.caster = caster
                    damageTable.target = enemy
                    damageTable.ability = self
                    damageTable.damage = damage
                    damageTable.voiddmg = true
                    damageTable.naturedmg = true
                    GameMode:DamageUnit(damageTable)
                    local modifierTable = {}
                    modifierTable.ability = self
                    modifierTable.target = enemy
                    modifierTable.caster = caster
                    modifierTable.modifier_name = "modifier_stunned"
                    modifierTable.duration = 0.1 --stun
                    GameMode:ApplyDebuff(modifierTable)
                    modifierTable = {}
                    modifierTable.ability = self
                    modifierTable.target = enemy
                    modifierTable.caster = caster
                    modifierTable.modifier_name = "modifier_mirana_under_silence"
                    modifierTable.duration = 3 --silence
                    GameMode:ApplyDebuff(modifierTable)
                    local particle_ray = "particles/units/heroes/hero_mirana/mirana_moonlight_ray.vpcf"
                    local ray_fx = ParticleManager:CreateParticle(particle_ray, PATTACH_POINT_FOLLOW, enemy)
                    Timers:CreateTimer(3.0, function()
                        ParticleManager:DestroyParticle(ray_fx, false)
                        ParticleManager:ReleaseParticleIndex(ray_fx)
                    end)
                end
            end
            local particle_cast = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock.vpcf"
            local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, caster)
            ParticleManager:SetParticleControl( effect_cast, 0, strikepos)
            ParticleManager:SetParticleControl( effect_cast, 1, Vector( aoe, aoe, aoe ) )
            Timers:CreateTimer(1.0, function()
                ParticleManager:DestroyParticle(effect_cast, false)
                ParticleManager:ReleaseParticleIndex(effect_cast)
            end)
        end)
    end
end

function mirana_under:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local target =  self:FindTargetForSilence(caster)
    self.duration = self:GetSpecialValueFor("seal_duration")
    local number = self:GetSpecialValueFor("number_targets")
    --silence
    local counter = 0
    Timers:CreateTimer(0, function()
        if counter < number then
            self:Silence(target)
            target = self:FindTargetForSilence(caster)
            counter = counter +1
            return 0.1
        end
    end)
    --random weak star aligned  with ministun
    local pos = caster:GetAbsOrigin()
    local lifetimeinticks = 15
    local tickdelay = 1
    local movement = 200
    local aoe = 300
    local counter2 = 0
    local number2 = self:GetSpecialValueFor("number_of_starfall_set")
    local damage = self:GetSpecialValueFor("damage")
    EmitSoundOn("mirana_mir_levelup_02", caster)
    Timers:CreateTimer(0, function()
        if counter2 < number2 then
            self:StarShower(caster, pos, lifetimeinticks, tickdelay, movement,aoe, damage  )
            counter2 = counter2 +1
            return 0.5
        end
    end)
end

--------------
--mirana_aligned
---------------

-- mirana_aligned modifiers
modifier_mirana_aligned_channel = class({
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

function modifier_mirana_aligned_channel:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    if self.ability then
        self.caster = self:GetParent()
        self.channel_time = self.ability:GetSpecialValueFor("channel_time")
        self.tick = self.ability:GetSpecialValueFor("tick")
        self.max_stacks = math.ceil(self.channel_time/ self.tick) --i print have found self.channel_time/ self.tick = 49.999999254942
        self:StartIntervalThink(self.tick)
        self:OnIntervalThink()
    else
        self:Destroy()
    end
end

--gain 1 stack every 0.1s channel total of 50 stacks
function modifier_mirana_aligned_channel:OnIntervalThink()
    local healFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal_blue.vpcf", PATTACH_POINT_FOLLOW, self.caster)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(healFX, false)
        ParticleManager:ReleaseParticleIndex(healFX)
    end)
    local modifierTable = {}
    modifierTable.ability = self.ability
    modifierTable.target = self.caster
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_mirana_aligned_buff"
    modifierTable.duration = -1 --self.duration
    modifierTable.stacks = 1
    modifierTable.max_stacks = self.max_stacks
    GameMode:ApplyStackingBuff(modifierTable)
end

function modifier_mirana_aligned_channel:OnDestroy()
    if IsServer() then
        local caster = self:GetParent()
        caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
    end
end

LinkLuaModifier("modifier_mirana_aligned_channel", "creeps/zone1/boss/mirana.lua", LUA_MODIFIER_MOTION_NONE)


modifier_mirana_aligned_buff = class({
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
})

function modifier_mirana_aligned_buff:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_mirana_aligned_buff:OnRefresh(keys)
    if not IsServer() then
        return
    end
    self:OnCreated()
end

LinkLuaModifier("modifier_mirana_aligned_buff", "creeps/zone1/boss/mirana.lua", LUA_MODIFIER_MOTION_NONE)

-- mirana_aligned
mirana_aligned = class({
    GetAbilityTextureName = function(self)
        return "mirana_aligned"
    end,
    GetChannelTime = function(self)
        return self:GetSpecialValueFor("channel_time")
    end
})

function mirana_aligned:IsRequireCastbar()
    return true
end

function mirana_aligned:FindAlignedTarget(caster)
    local radius = self:GetSpecialValueFor("range")
    -- Find all nearby enemies
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local keys = {}
    for k in pairs(enemies) do
        table.insert(keys, k)
    end
    if (#enemies > 0) then
        local AlignedTarget = enemies[keys[math.random(#keys)]] --pick one number = pick one enemy
        if (#enemies > 0) then
            return AlignedTarget
        else
            return nil
        end
    end
end

function mirana_aligned:StarsAlignFX(target)
    local particle_starfall_fx = ParticleManager:CreateParticle("particles/econ/items/mirana/mirana_starstorm_bow/mirana_starstorm_starfall_attack.vpcf",  PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle_starfall_fx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_starfall_fx, 1, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_starfall_fx, 3, target:GetAbsOrigin())
    Timers:CreateTimer(2.0, function()
        ParticleManager:DestroyParticle(particle_starfall_fx, false)
        ParticleManager:ReleaseParticleIndex(particle_starfall_fx)
    end)
    Timers:CreateTimer(0.57,function()
        EmitSoundOn("Hero_Luna.Eclipse.Cast", target)
        local particle_cast = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock.vpcf"
        local shockwave = "particles/econ/items/outworld_devourer/od_ti8/od_ti8_santies_eclipse_area_shockwave.vpcf"
        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
        local fx =  ParticleManager:CreateParticle( shockwave, PATTACH_ABSORIGIN_FOLLOW, target )
        ParticleManager:SetParticleControl( effect_cast, 1, Vector( 300, 300, 300 ) )
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(effect_cast, false)
            ParticleManager:ReleaseParticleIndex(effect_cast)
            ParticleManager:DestroyParticle(fx, false)
            ParticleManager:ReleaseParticleIndex(fx)
        end)
    end)

end

function mirana_aligned:OnSpellStart(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        local caster_position = self:GetCaster():GetAbsOrigin()

        local particle_moon = "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf"
        caster:EmitSound("mirana_mir_attack_05")
        caster.mirana_aligned_modifier = caster:AddNewModifier(caster, self, "modifier_mirana_aligned_channel", { Duration = -1 })
        Timers:CreateTimer(0.2, function()
            --if (caster:HasModifier("modifier_mirana_aligned_channel")) then
                caster:StartGestureWithPlaybackRate	(ACT_DOTA_CAST_ABILITY_1, 0.15)
                local particle_moon_fx = ParticleManager:CreateParticle(particle_moon, PATTACH_ABSORIGIN, self:GetCaster())
                ParticleManager:SetParticleControl(particle_moon_fx, 0, Vector(caster_position.x, caster_position.y, caster_position.z + 400))
                Timers:CreateTimer(5.0, function()
                    ParticleManager:DestroyParticle(particle_moon_fx, false)
                    ParticleManager:ReleaseParticleIndex(particle_moon_fx)
                end)
        end)
    end
end

function mirana_aligned:OnChannelFinish()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    if (caster.mirana_aligned_modifier ~= nil) then
        caster.mirana_aligned_modifier:Destroy()
    end
    --sound star falling
    local target = self:FindAlignedTarget(caster)
    local expo_power = (caster:FindModifierByName("modifier_mirana_aligned_buff"):GetStackCount())/10
    caster:EmitSound("mirana_mir_ability_star_0"..math.random(1,3))
    local expo = self:GetSpecialValueFor("expo")
    local base_damage = self:GetSpecialValueFor("base_damage")
    local damage = base_damage * math.pow(expo, expo_power)
    local radius = self:GetSpecialValueFor("radius")
    if target:IsAlive() then
        self:StarsAlignFX(target)
        -- Find all nearby enemies
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                target:GetAbsOrigin(),
                nil,
                radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO ,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            --Damage nearby enemies
            Timers:CreateTimer(0.57,function()
                local damageTable = {}
                damageTable.caster = caster
                damageTable.target = enemy
                damageTable.ability = self
                damageTable.damage = damage
                damageTable.naturedmg = true
                damageTable.voiddmg = true
                GameMode:DamageUnit(damageTable)
            end)
        end
        --taunting if max charge
        Timers:CreateTimer(1, function()
            if expo_power == 5 then
                caster:EmitSound("mirana_mir_kill_0"..math.random(1,11))
            end
        end)
    end
    caster:RemoveModifierByName("modifier_mirana_aligned_buff")
end


--------------
--mirana guile
---------------

modifier_mirana_guile = class({
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
    GetEffectName = function(self)
        return "particles/units/npc_boss_mirana/mirana_guile/moon_chain_debuff.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end
})

function modifier_mirana_guile:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
end

function modifier_mirana_guile:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }
    return state
end

LinkLuaModifier("modifier_mirana_guile", "creeps/zone1/boss/mirana.lua", LUA_MODIFIER_MOTION_NONE)

mirana_guile = class({
    GetAbilityTextureName = function(self)
        return "mirana_guile"
    end,
})

function  mirana_guile:ApplyChains(target, caster)
    target:EmitSound("Hero_EmberSpirit.SearingChains.Target")
    local impact_pfx = ParticleManager:CreateParticle("particles/units/npc_boss_mirana/mirana_guile/moon_chain_cast.vpcf", PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControl(impact_pfx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(impact_pfx, 1, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(impact_pfx)
    local modifierTable = {}
    modifierTable.caster = caster
    modifierTable.target = target
    modifierTable.ability = self
    modifierTable.modifier_name = "modifier_mirana_guile"
    modifierTable.duration = self.duration
    GameMode:ApplyDebuff(modifierTable)
end

function mirana_guile:FindTargetForRoot(caster) --random with already hit removal
    if IsServer() then
        local radius = self:GetSpecialValueFor("range")
        -- Find all nearby enemies
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        local randomEnemy
        for _, enemy in pairs(enemies) do
            if (not TableContains(self.already_hit, enemy)) then
                randomEnemy = enemy
                break
            end
        end
        return randomEnemy
    end
end

function  mirana_guile:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    self.duration = self:GetSpecialValueFor("root")
    --root them
    self.already_hit ={}
    self:ApplyChains(target, caster)
    target:AddNewModifier(caster, self, "modifier_stunned", {duration = 0.1})
    table.insert(self.already_hit, target)
    local target2 = self:FindTargetForRoot(caster)
    if target2 == nil then
        return
    else
        target:EmitSound("Hero_VengefulSpirit.NetherSwap")
        self:ApplyChains(target2, caster)
        target2:AddNewModifier(caster, self, "modifier_stunned", {duration = 0.1})
        target2:EmitSound("Hero_VengefulSpirit.NetherSwap")
        local target_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN, target)
        ParticleManager:SetParticleControlEnt(target_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(target_pfx, 1, target2, PATTACH_POINT_FOLLOW, "attach_hitloc", target2:GetAbsOrigin(), true)
        local target2_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN, target2)
        ParticleManager:SetParticleControlEnt(target2_pfx, 0, target2, PATTACH_POINT_FOLLOW, "attach_hitloc", target2:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(target2_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        --swap position
        local target_loc = target:GetAbsOrigin()
        local target2_loc = target2:GetAbsOrigin()
        FindClearSpaceForUnit(target, target2_loc, true)
        FindClearSpaceForUnit(target2, target_loc, true)
        --local tree_radius = self:GetSpecialValueFor("tree_radius") --200
        -- Destroy trees around start and end areas -- ill leave it here just in case ppl get struck
        --GridNav:DestroyTreesAroundPoint(caster_loc, tree_radius, false)
        --GridNav:DestroyTreesAroundPoint(target_loc, tree_radius, false)
        --swap aggro
        local high_aggro = Aggro:Get(target, caster)
        local random_aggro = Aggro:Get(target2, caster)
        Aggro:Reset(caster)
        Aggro:Add(target, caster, random_aggro)
        Aggro:Add(target2, caster, high_aggro)
        caster:FindModifierByName("modifier_mirana_bound")
    end
end

--------------
--mirana bound
---------------
mirana_bound = class({
    GetAbilityTextureName = function(self)
        return "mirana_bound"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_mirana_bound"
    end,
})

modifier_mirana_bound = class({
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
        return { MODIFIER_EVENT_ON_DEATH }
    end
})

function modifier_mirana_bound:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    --apply buff to mirana but set inactive state
    local modifierTable = {}
    modifierTable.ability = self.ability
    modifierTable.target = self.parent
    modifierTable.caster = self.parent
    modifierTable.modifier_name = "modifier_mirana_bound_buff"
    modifierTable.duration = -1
    modifierTable.stacks = 1
    modifierTable.max_stacks = 2
    GameMode:ApplyStackingBuff(modifierTable)
    self.luna = nil
    Timers:CreateTimer(0, function()
        if self.luna == nil then
            self.luna = self.ability:FindLuna(self.parent, 25000)
            return 0.1
        end
    end)
    local bound = "particles/econ/items/spectre/spectre_transversant_soul/spectre_transversant_spectral_dagger_path_owner_impact.vpcf"
    local bound_fx = ParticleManager:CreateParticle(bound, PATTACH_POINT_FOLLOW, self.parent)
    ParticleManager:SetParticleControlEnt(bound_fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(bound_fx, false)
        ParticleManager:ReleaseParticleIndex(bound_fx)
    end)
end

function mirana_bound:FindLuna(parent, range)
    local allies = FindUnitsInRadius(parent:GetTeamNumber(),
            parent:GetAbsOrigin(),
            nil,
            range,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, ally in pairs(allies) do
        if IsLuna(ally) == true then
            local Luna = ally
            return Luna
        else return nil
        end
    end
end

function modifier_mirana_bound:OnDeath(params)
    local stack = self.parent:FindModifierByName("modifier_mirana_bound_buff"):GetStackCount()
    if (params.unit == self.parent and stack == 1 ) then
        if self.luna ~= nil then
            self.luna:FindModifierByName("modifier_luna_bound_buff"):SetStackCount(2)
            self.luna:EmitSound("Item.MoonShard.Consume")
        end
        local bound = "particles/econ/items/spectre/spectre_transversant_soul/spectre_transversant_spectral_dagger_path_owner_impact.vpcf"
        local bound_fx = ParticleManager:CreateParticle(bound, PATTACH_POINT_FOLLOW, self.parent)
        ParticleManager:SetParticleControlEnt(bound_fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(bound_fx, false)
            ParticleManager:ReleaseParticleIndex(bound_fx)
        end)
    end
end

LinkLuaModifier("modifier_mirana_bound", "creeps/zone1/boss/mirana.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mirana_bound_buff = class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return mirana_bound:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_mirana_bound_buff:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.active = false
    self.lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal")
end

---@param damageTable DAMAGE_TABLE
function modifier_mirana_bound_buff:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_mirana_bound_buff")
    local stack = 1
    if modifier ~= nil then
        stack = modifier:GetStackCount()
    end
    if (damageTable.damage > 0 and stack >1 and not damageTable.ability and damageTable.physdmg ) then
        --lifesteal
        local healFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_POINT_FOLLOW, damageTable.attacker)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(healFX, false)
            ParticleManager:ReleaseParticleIndex(healFX)
        end)
        local healTable = {}
        healTable.caster = damageTable.attacker
        healTable.target = damageTable.attacker
        healTable.ability = modifier:GetAbility()
        healTable.heal = damageTable.damage * modifier:GetAbility():GetSpecialValueFor("lifesteal") * 0.01
        GameMode:HealUnit(healTable)
    end
end


function modifier_mirana_bound_buff:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    if (keys.attacker == self.parent) and self:GetStackCount() > 1 and keys.attacker:IsAlive() then
        Timers:CreateTimer(0.1,function()
            local radius = self:GetAbility():GetSpecialValueFor("radius")
            local Max_mana = keys.target:GetMaxMana()
            local Mana = keys.target:GetMana()
            local damage = self:GetAbility():GetSpecialValueFor("explode_per_mana") * (Max_mana - Mana)
            if Mana < Max_mana then
                local void_pfx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/antimage_manavoid_ti_5.vpcf", PATTACH_POINT_FOLLOW, keys.target)
                ParticleManager:SetParticleControlEnt(void_pfx, 0, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetOrigin(), true)
                ParticleManager:SetParticleControl(void_pfx, 1, Vector(radius,0,0))
                ParticleManager:ReleaseParticleIndex(void_pfx)
                keys.attacker:EmitSoundParams("Hero_Antimage.ManaVoidCast", 1.0, 0.2, 0) --name pitch volume(81 for base) delay
                keys.target:EmitSoundParams("Hero_Antimage.ManaVoid", 1.0, 0.2, 0)
                -- Find all nearby enemies
                local enemies = FindUnitsInRadius(keys.attacker:GetTeamNumber(),
                        keys.target:GetAbsOrigin(),
                        nil,
                        radius,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false)
                for _, enemy in pairs(enemies) do
                    local damageTable= {}
                    damageTable.caster = keys.attacker
                    damageTable.target = enemy
                    damageTable.ability = self.ability
                    damageTable.damage = damage
                    damageTable.voiddmg = true
                    GameMode:DamageUnit(damageTable)
                end
            end
        end)
    end
end

LinkLuaModifier("modifier_mirana_bound_buff", "creeps/zone1/boss/mirana.lua", LUA_MODIFIER_MOTION_NONE)

--internal stuff
if (IsServer() and not GameMode.ZONE1_BOSS_MIRANA) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_mirana_bound_buff, 'OnTakeDamage'))
    GameMode.ZONE1_BOSS_MIRANA = true
end