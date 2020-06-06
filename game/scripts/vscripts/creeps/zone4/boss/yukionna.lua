--HELPER
function RotateVectorAroundAngle( vec, angle )
    local x = vec[1]
    local y = vec[2]
    angle = angle * 0.01745
    local vec2 = Vector(0,0,0)
    vec2[1] = x * math.cos(angle) - y * math.sin(angle)
    vec2[2] = x * math.sin(angle) + y * math.cos(angle)
    return vec2
end
-------------------
--yukionna broken promise --passive only activate this if she is stunned/silence, apply undispellable stun to the hero stun or silence her for 7/9/11s
-------------------
yukionna_promise = class({
    GetAbilityTextureName = function(self)
        return "yukionna_promise"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_yukionna_promise"
    end,
})

modifier_yukionna_promise = class({
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
        return{ MODIFIER_EVENT_ON_DEATH,
                MODIFIER_EVENT_ON_ATTACK_LANDED
        }
    end
})

function modifier_yukionna_promise:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    --call cd_reduce immediately without timers give 0 so 0.5 s delay technically can be called on upgrade but lazy to fix
    Timers:CreateTimer(0.1,function()
    self.cd_reduce = self.ability:GetSpecialValueFor("cd_reduce")
    end)
end


---@param modifierTable MODIFIER_TABLE
function modifier_yukionna_promise:OnPostModifierApplied(modifierTable)
    local modifier = modifierTable.target:FindModifierByName("modifier_yukionna_promise")
    if modifier then
    local debuff = modifierTable.target:FindModifierByName(modifierTable.modifier_name)
        --vanilla modifier_stunned or modifier_silence somehow cant be checked state so we go with name check
        if (modifierTable.modifier_name == "modifier_silence" or modifierTable.modifier_name == "modifier_stunned") and modifierTable.caster ~= modifierTable.target then
            --solo
            local hero = modifierTable.caster
            local dp = modifierTable.target
            if HeroList:GetHeroCount() == 1 then
                modifierTable.ability = modifier:GetAbility()
                modifierTable.target = hero
                modifierTable.caster = dp
                modifierTable.modifier_name = "modifier_yukionna_promise_stun"
                modifierTable.duration = modifier:GetAbility():GetSpecialValueFor("stun")* 0.5
                GameMode:ApplyDebuff(modifierTable)
            else
                --party
                modifierTable.ability = modifier:GetAbility()
                modifierTable.target = hero
                modifierTable.caster = dp
                modifierTable.modifier_name = "modifier_yukionna_promise_stun"
                modifierTable.duration = modifier:GetAbility():GetSpecialValueFor("stun")
                GameMode:ApplyDebuff(modifierTable)
            end
            hero:EmitSound("Hero_DarkWillow.Ley.Stun")
        --other custom modifiers that have checkstate
        elseif( debuff.CheckState)  then
            local stateTable = debuff.CheckState(debuff)
            local isStun = (stateTable[MODIFIER_STATE_STUNNED] == true)
            local isSilence = (stateTable[MODIFIER_STATE_SILENCED] == true)
            if (isStun or isSilence) and modifierTable.caster ~= modifierTable.target  then
                local hero = modifierTable.caster
                local dp = modifierTable.target
                if HeroList:GetHeroCount() == 1 then
                    modifierTable.ability = modifier:GetAbility()
                    modifierTable.target = hero
                    modifierTable.caster = dp
                    modifierTable.modifier_name = "modifier_yukionna_promise_stun"
                    modifierTable.duration = modifier:GetAbility():GetSpecialValueFor("stun")* 0.5
                    GameMode:ApplyDebuff(modifierTable)
                else
                    modifierTable.ability = modifier:GetAbility()
                    modifierTable.target = hero
                    modifierTable.caster = dp
                    modifierTable.modifier_name = "modifier_yukionna_promise_stun"
                    modifierTable.duration = modifier:GetAbility():GetSpecialValueFor("stun")
                    GameMode:ApplyDebuff(modifierTable)
                end
                hero:EmitSound("Hero_DarkWillow.Ley.Stun")
            end
        end
    end
end

function modifier_yukionna_promise:OnDeath( params )
    if IsServer() then
        if params.unit == self.parent then
            local death_fx = "particles/units/heroes/hero_death_prophet/death_prophet_death.vpcf"
            self.destruction = ParticleManager:CreateParticle( death_fx, PATTACH_ABSORIGIN, self.parent )
            ParticleManager:ReleaseParticleIndex(self.destruction)
            self.parent:SetModelScale(0)
        end
    end
end

function modifier_yukionna_promise:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    if (keys.attacker == self.parent ) then

        local ability = self.parent:FindAbilityByName("yukionna_breath")
        if ability then
            local remaining_cooldown = ability:GetCooldownTimeRemaining()

            if remaining_cooldown > 0 then
                ability:EndCooldown()
                ability:StartCooldown(remaining_cooldown - self.cd_reduce)
            end
        end
    end
end


LinkLuaModifier("modifier_yukionna_promise", "creeps/zone4/boss/yukionna.lua", LUA_MODIFIER_MOTION_NONE)



modifier_yukionna_promise_stun = class({
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
    GetEffectName = function(self)
        return  "particles/units/heroes/hero_ancient_apparition/ancient_apparition_cold_feet_frozen.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end,
    GetTexture = function(self)
        return "winter_wyvern_cold_embrace"
    end,
})

function modifier_yukionna_promise_stun:OnCreated()
    if (not IsServer()) then
        return
    end
end

function modifier_yukionna_promise_stun:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] =true,
    }
    return state
end

--set 0
function modifier_yukionna_promise_stun:GetSpellDamageBonusMulti()
    return 0
end

function modifier_yukionna_promise_stun:GetAttackDamagePercentBonusMulti()
    return 0
end

function modifier_yukionna_promise_stun:GetHealingCausedPercentBonusMulti()
    return 0
end

function modifier_yukionna_promise_stun:GetHealthRegenerationPercentBonusMulti()
    return 0
end

function modifier_yukionna_promise_stun:OnDestroy()
    if not IsServer() then
        return
    end
    Units:ForceStatsCalculation(self:GetParent())
end


LinkLuaModifier("modifier_yukionna_promise_stun", "creeps/zone4/boss/yukionna.lua", LUA_MODIFIER_MOTION_NONE)


-------------------
--yukionna_snowstorm --evoke a snowstorm around her small damage  + pull every interval when in aoe
---------------------
modifier_yukionna_snowstorm_eye = class({
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
        return { MODIFIER_EVENT_ON_DEATH }
    end,
})

function modifier_yukionna_snowstorm_eye:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.damage = self.ability:GetSpecialValueFor("damage")
    self.range = self.ability:GetSpecialValueFor("range")
    self.tick = self.ability:GetSpecialValueFor("pull_tick")
    self.frostbite_trigger_range = self.ability:GetSpecialValueFor("frostbite_trigger_range")
    self.frostbite_duration = self.ability:GetSpecialValueFor("frostbite_duration")
    self:StartIntervalThink(self.tick) --1
    self.freezing_field_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
    self.caster:EmitSound("hero_Crystal.freezingField.wind")
    ParticleManager:SetParticleControlEnt(self.freezing_field_particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true )
    ParticleManager:SetParticleControl(self.freezing_field_particle, 1, Vector (2500, 0, 0))
end

function modifier_yukionna_snowstorm_eye:OnIntervalThink()
    if self.parent:IsAlive() then
        self.caster:RemoveModifierByName("modifier_yukionna_crushed")
        local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(),
                self.parent:GetAbsOrigin(),
                nil,
                self.range,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            local casterOrigin = self.parent:GetAbsOrigin()
            local enemyOrigin = enemy:GetAbsOrigin()
            local vector =  enemyOrigin - casterOrigin
            vector.z = 0
            local unit_vector = vector:Normalized()
            enemy:AddNewModifier(self:GetCaster(), self.ability, "modifier_generic_motion_controller",
                    {
                        distance		= self.ability:GetSpecialValueFor("pull_distance"),
                        direction_x 	= -unit_vector.x,
                        direction_y 	= -unit_vector.y,
                        direction_z 	= 0,
                        duration 		= self.ability:GetSpecialValueFor("pull_duration"),
                        bGroundStop 	= false,
                        bDecelerate 	= false,
                        bInterruptible 	= false,
                        bIgnoreTenacity	= false,
                        bDestroyTreesAlongPath	= true
                    })
            local damageTable = {}
            damageTable.caster = self.parent
            damageTable.target = enemy
            damageTable.ability = self.ability
            damageTable.damage = self.damage
            damageTable.frostdmg = true
            GameMode:DamageUnit(damageTable)
            if CalcDistanceBetweenEntityOBB(self.parent,enemy) < self.frostbite_trigger_range then
                local modifierTable = {}
                modifierTable.caster = self.parent
                modifierTable.target = enemy
                modifierTable.ability = self.ability
                modifierTable.modifier_name = "modifier_yukionna_frostbite"
                modifierTable.duration = self.frostbite_duration
                GameMode:ApplyDebuff(modifierTable)
            end
        end
    end
end


function modifier_yukionna_snowstorm_eye:OnDestroy()
    ParticleManager:DestroyParticle(self.freezing_field_particle, true)
    ParticleManager:ReleaseParticleIndex(self.freezing_field_particle)
    self.caster:StopSound("hero_Crystal.freezingField.wind")
end

function modifier_yukionna_snowstorm_eye:OnDeath( params ) --venge death = bubble pop
    if IsServer() then
        if params.unit == self.caster then

            self:Destroy()
        end
    end
end

LinkLuaModifier("modifier_generic_motion_controller", "generic/modifier_generic_motion_controller.lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_yukionna_snowstorm_eye", "creeps/zone4/boss/yukionna.lua", LUA_MODIFIER_MOTION_NONE)

yukionna_snowstorm = class({
    GetAbilityTextureName = function(self)
        return "yukionna_snowstorm"
    end,
})

function yukionna_snowstorm:OnSpellStart()
    if IsServer() then
        local duration = self:GetSpecialValueFor("duration")
        self.caster = self:GetCaster()
        self.caster:RemoveModifierByName("modifier_yukionna_crushed")
        --apply buff
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.caster
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_yukionna_snowstorm_eye"
        modifierTable.duration = duration
        GameMode:ApplyBuff(modifierTable)
    end
end

-------------------
--yukionna_breath --dk blue breathfire immortal --deal initial frost damage + apply sealing frostbite holyfrost tower debuff in a cone, chance to trigger on AA
-------------------

yukionna_breath = class({
    GetAbilityTextureName = function(self)
        return "yukionna_breath"
    end,
})

function yukionna_breath:OnSpellStart()
    -- Preventing projectiles getting stuck in one spot due to potential 0 length vector
    if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
        self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
    end

    --local target = self:GetCursorTarget()
    local target_point = self:GetCursorPosition()
    local speed = self:GetSpecialValueFor("projectile_speed")
    self.additional = self:GetSpecialValueFor("additional") * 0.01
    EmitSoundOn("Hero_DragonKnight.BreathFire", self:GetCaster())

    local projectile = {
        Ability = self,
        EffectName = "particles/econ/items/dragon_knight/dk_ti10_immortal/dk_ti10_breathe_fire.vpcf",
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        fDistance = self:GetSpecialValueFor("range"),
        fStartRadius = self:GetSpecialValueFor("start_radius"),
        fEndRadius = self:GetSpecialValueFor("end_radius"),
        Source = self:GetCaster(),
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = self:GetAbilityTargetTeam(),
        iUnitTargetType = self:GetAbilityTargetType(),
        bDeleteOnHit = false,
        vVelocity = (((target_point - self:GetCaster():GetAbsOrigin()) * Vector(1, 1, 0)):Normalized()) * speed,
        bProvidesVision = false,
    }

    ProjectileManager:CreateLinearProjectile(projectile)

end

function yukionna_breath:OnProjectileHit(target, location)
    if not target then
        return nil
    end

    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    local duration = self:GetSpecialValueFor("duration")
    if target:HasModifier("modifier_yukionna_frostbite") then
        local broken = self:GetSpecialValueFor("broken") * 0.5
        target:AddNewModifier(self.caster, self.ability, "modifier_yukionna_promise_stun", {duration = broken})
        local health = target:GetHealth()
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = health * self.additional
        damageTable.frostdmg = true
        GameMode:DamageUnit(damageTable)
        Aggro:Reset(caster)
    end
    if caster:IsAlive()then
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.frostdmg = true
        GameMode:DamageUnit(damageTable)
        caster:EmitSound("Hero_Crystal.Frostbite")
        local modifierTable = {}
        modifierTable.caster = caster
        modifierTable.target = target
        modifierTable.ability = self
        modifierTable.modifier_name = "modifier_yukionna_frostbite"
        modifierTable.duration = duration
        GameMode:ApplyDebuff(modifierTable)
    end
end



modifier_yukionna_frostbite = class({
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
})

function modifier_yukionna_frostbite:OnCreated()
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

function modifier_yukionna_frostbite:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
    }
    return state
end

function modifier_yukionna_frostbite:OnIntervalThink()
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

LinkLuaModifier("modifier_yukionna_frostbite", "creeps/zone4/boss/yukionna.lua", LUA_MODIFIER_MOTION_NONE)




------------------
--yukionna seiki drain -- channeling siphon %health + speed from a hero + omegaslow if solo/from hero(s) + stun those heroes if team, break + stun if too far
--------------------
modifier_yukionna_drain_channel = class({
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
})

function modifier_yukionna_drain_channel:OnCreated(keys)
    if not IsServer() then
        return
    end
end

function modifier_yukionna_drain_channel:OnDestroy()
    if IsServer() then
        local caster = self:GetParent()
        caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
    end
end

LinkLuaModifier("modifier_yukionna_drain_channel", "creeps/zone4/boss/yukionna.lua", LUA_MODIFIER_MOTION_NONE)

yukionna_drain = class({

    GetAbilityTextureName = function(self)
        return "yukionna_drain"
    end,
    GetChannelTime = function(self)
        return self:GetSpecialValueFor("channel_time")
    end
})

function yukionna_drain:IsRequireCastbar()
    return true
end

function yukionna_drain:FindTargetForDrain(caster)
    local range = self:GetSpecialValueFor("range")
    -- Find all nearby enemies
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            range,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local randomEnemy
    for _, enemy in pairs(enemies) do
        if (not TableContains(self.already_hit, enemy)) then
            table.insert(self.already_hit, enemy)
            randomEnemy = enemy
            break
        end
    end
    return randomEnemy
end

function yukionna_drain:Drain(target)
    if (not IsServer()) then
        return
    end
    if (target == nil) then
        return
    end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_yukionna_drain_debuff"
    modifierTable.duration = -1
    GameMode:ApplyDebuff(modifierTable)
end

function yukionna_drain:OnSpellStart()
    if IsServer() then
        self.caster = self:GetCaster()
        self.caster:EmitSound("Hero_DeathProphet.SpiritSiphon.Cast")
        self.caster.yukionna_drain_modifier = self.caster:AddNewModifier(self.caster, self, "modifier_yukionna_drain_channel", { Duration = -1 })
        self.already_hit = {}
        local number = self:GetSpecialValueFor("number")
        local counter = 0
        local target
        Timers:CreateTimer(0, function()
            if counter < number then
                target = self:FindTargetForDrain(self.caster)
                self:Drain(target)
                counter = counter + 1
                return 0
            end
        end)
        Timers:CreateTimer(0.2, function()
            if self.caster:HasModifier("modifier_yukionna_drain_channel") then
                self.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.4)
                return 2
            end
        end)
    end
end


function yukionna_drain:OnChannelFinish()
    if not IsServer() then
        return
    end
    if (self.caster.yukionna_drain_modifier ~= nil) then
        self.caster.yukionna_drain_modifier:Destroy()
    end
    --sound eating
    --self.caster:EmitSound("ursa_ursa_lasthit_08")
end

-----------------
--debuff
-----------------
modifier_yukionna_drain_debuff = class({
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
})


function modifier_yukionna_drain_debuff:OnCreated()
    if IsServer() then
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        self.ability = self:GetAbility()
        self.damage = self.ability:GetSpecialValueFor("base_damage") + self.parent:GetMaxHealth() * self.ability:GetSpecialValueFor("dmg_pct") *0.01
        self.burn  = self.ability:GetSpecialValueFor("base_damage") + self.parent:GetMaxMana() * self.ability:GetSpecialValueFor("dmg_pct") *0.01
        self.slow =  self.ability:GetSpecialValueFor("ms_reduce")  * (-0.01)
        self.tick = self.ability:GetSpecialValueFor("tick")
        local suck = "particles/units/heroes/hero_death_prophet/death_prophet_spiritsiphon.vpcf"
        self.nFX = ParticleManager:CreateParticle(suck, PATTACH_CUSTOMORIGIN_FOLLOW, self.caster )
        ParticleManager:SetParticleControlEnt(self.nFX, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.nFX, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(self.nFX, 5, Vector(8,0,0 ) )
        self.parent:EmitSound("Hero_DeathProphet.SpiritSiphon.Target")
        self.solo = 1
        if HeroList:GetHeroCount() > 1 then
            self.solo = 0
        end
        self:StartIntervalThink( self.tick )
        self:OnIntervalThink()
    end
end

function modifier_yukionna_drain_debuff:OnIntervalThink()
    local modifier = self.caster:FindModifierByName("modifier_yukionna_drain_channel")
    if modifier == nil or not self.parent:IsAlive() then
        self:Destroy()
        self.parent:StopSound("Hero_DeathProphet.SpiritSiphon.Target")
        ParticleManager:DestroyParticle(self.nFX, true)
        ParticleManager:ReleaseParticleIndex(self.nFX)
    else
        if self.solo ==0 then
            self.parent:AddNewModifier(self.caster, self.ability, "modifier_stunned", {duration = 1})
        end
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = self.parent
        damageTable.ability = self.ability
        damageTable.damage = self.damage * self.tick
        damageTable.infernodmg = true
        damageTable.voiddmg = true
        GameMode:DamageUnit(damageTable)
        self.parent:ReduceMana(self.burn * self.tick)
        local heal = self.damage + self.caster:GetMaxHealth()*0.01
        local healTable = {}
        healTable.caster = self.caster
        healTable.target = self.caster
        healTable.ability = self.ability
        healTable.heal = heal * self.tick
        GameMode:HealUnit(healTable)
    end
end

function modifier_yukionna_drain_debuff:GetMoveSpeedPercentBonusMulti()
    return 0
end

LinkLuaModifier( "modifier_yukionna_drain_debuff", "creeps/zone4/boss/yukionna.lua", LUA_MODIFIER_MOTION_NONE )

-------------------
--yukionna bewitching beauty --passive periodically apply debuff make a random hero walk toward her if any hero are too close they get essence drain for 3s.
-------------------
modifier_yukionna_beauty_debuff = class({
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
        return {MODIFIER_PROPERTY_MOVESPEED_LIMIT}
    end,
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_lich_gaze.vpcf"
    end
})

function modifier_yukionna_beauty_debuff:OnCreated()
    if not IsServer() then return end
    self.ability 			= self:GetAbility()
    self.caster				= self:GetCaster()
    self.parent				= self:GetParent()
    self.destination		= self.ability:GetSpecialValueFor("destination")
    self.distance 			= CalcDistanceBetweenEntityOBB(self:GetCaster(), self:GetParent()) * (self.destination / 100)
    self.mana_drain			= self.ability:GetSpecialValueFor("mana_drain")
    self.health_drain			= self.ability:GetSpecialValueFor("health_drain")
    self.interval			= self.ability:GetSpecialValueFor("tick")
    self.duration       = self.ability:GetSpecialValueFor("duration")
    self.max_mana		= self.parent:GetMaxMana()
    self.max_health     = self.parent:GetMaxHealth()
    self.health_per_interval = self.max_health * self.health_drain * 0.01
    self.threshold = self.ability:GetSpecialValueFor("threshold")
    self.mana_per_interval	= (self.max_mana * self.mana_drain * 0.01) --/ (self.duration / self.interval)

    -- Add the gaze particles
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_gaze.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 2, self.caster, PATTACH_POINT_FOLLOW, "attach_root", self.caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 3, self.caster, PATTACH_ABSORIGIN_FOLLOW, nil, self.caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 10, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetAbsOrigin(), true)
    self:AddParticle(self.particle, false, false, -1, false, false)
    Timers:CreateTimer(5,function ()
    ParticleManager:ReleaseParticleIndex(self.particle)end)
    if self.parent:IsAlive() then
        self.parent:EmitSound("Hero_Lich.SinisterGaze.Target")
    end
    self.parent:Interrupt()
    self.parent:MoveToNPC(self.caster)

    self:StartIntervalThink(self.interval)
end

function modifier_yukionna_beauty_debuff:OnIntervalThink()
    if self.parent:IsAlive() then
        self.mana = self.parent:GetMana()
        self.mana_pct = self.mana/self.max_mana * 100
        if self.mana_pct < self.threshold then
            local damageTable = {}
            damageTable.caster = self.caster
            damageTable.target = self.parent
            damageTable.ability = self.ability
            damageTable.damage = self.health_per_interval
            damageTable.puredmg = true
            GameMode:DamageUnit(damageTable)
        else
            self.parent:ReduceMana(self.mana_per_interval)
        end
    else
        self:Destroy()
    end
end

function modifier_yukionna_beauty_debuff:OnDestroy()
    if not IsServer() then return end
    self.parent:Interrupt()
end

function modifier_yukionna_beauty_debuff:CheckState()
    return {
        [MODIFIER_STATE_HEXED] = true,	-- Using this as substitute for Fear which isn't a provided state
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
    }
end

function modifier_yukionna_beauty_debuff:GetModifierMoveSpeed_Limit()
    if self.distance ~= nil then
        return self.distance / self.duration
    else return 550
    end
end

LinkLuaModifier( "modifier_yukionna_beauty_debuff", "creeps/zone4/boss/yukionna.lua", LUA_MODIFIER_MOTION_NONE )

yukionna_beauty = class({
    GetAbilityTextureName = function(self)
        return "yukionna_beauty"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_yukionna_beauty"
    end,
})

modifier_yukionna_beauty = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
})

function modifier_yukionna_beauty:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.caster = self.parent
    self.ability = self:GetAbility()
    Timers:CreateTimer(0.5,function()
        self.bewitch_interval = self.ability:GetSpecialValueFor("bewitch_interval")
        self.duration = self.ability:GetSpecialValueFor("duration")
        if HeroList:GetHeroCount() == 1 then
            self.duration = self.duration * 0.5
        end
        self.range = self.ability:GetSpecialValueFor("range")
        self:StartIntervalThink(self.bewitch_interval)
    end)
end

function modifier_yukionna_beauty:OnIntervalThink()
    if self.parent:IsAlive() then
        if RollPercentage(50) then
            local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
                    self.caster:GetAbsOrigin(),
                    nil,
                    self.range,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            if (#enemies > 0) then
                self.target = enemies[1]
            else
                return
            end
        else
            local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
                    self.caster:GetAbsOrigin(),
                    nil,
                    self.range,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_FARTHEST,
                    false)
            if (#enemies > 0) then
                self.target = enemies[1]
            else
                return
            end
        end
        if self.target then
            local modifierTable = {}
            modifierTable.ability = self.ability
            modifierTable.target = self.target
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_yukionna_beauty_debuff"
            modifierTable.duration = self.duration
            GameMode:ApplyDebuff(modifierTable)
            self.caster:EmitSound("Hero_Lich.SinisterGaze.Cast ")
        end
    end
end


LinkLuaModifier( "modifier_yukionna_beauty", "creeps/zone4/boss/yukionna.lua", LUA_MODIFIER_MOTION_NONE )


------------------
--yukionna_women of the snow--
------------------
yukionna_women = class({
    GetAbilityTextureName = function(self)
        return "yukionna_women"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_yukionna_women"
    end
})
LinkLuaModifier("modifier_yukionna_women", "creeps/zone4/boss/yukionna.lua", LUA_MODIFIER_MOTION_NONE)

function yukionna_women:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.frostbite_duration = self:GetSpecialValueFor("frostbite_duration")
    self.frostbite_radius = self:GetSpecialValueFor("frostbite_radius")
    self.reappear_range = self:GetSpecialValueFor("reappear_range")
end

function yukionna_women:Disappear()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local particle_nova = "particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf"
    local nova_pfx = ParticleManager:CreateParticle(particle_nova, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(nova_pfx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(nova_pfx, 1, Vector(self.frostbite_radius,2,self.frostbite_radius))
    ParticleManager:SetParticleControl(nova_pfx, 2, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(nova_pfx)
    local departing = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            self.frostbite_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)

    for _, enemy in pairs(departing) do
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = enemy
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_yukionna_frostbite"
        modifierTable.duration = self.frostbite_duration
        GameMode:ApplyDebuff(modifierTable)
    end
    Timers:CreateTimer(0.1, function()
    caster:AddNewModifier(caster, self, "modifier_invisible", {Duration = 3.5})
    caster:AddNewModifier(caster, self, "modifier_stunned", {Duration = 3})
    caster:AddNewModifier(caster, self, "modifier_invulnerable", {Duration = 3})
    end)
    if RollPercentage(50) then
        self.enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                self.reappear_range,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_FARTHEST,
                false)
    else
        self.enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                self.reappear_range,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
    end
    if (#self.enemies > 0) then
        self.target = self.enemies[1]
        Timers:CreateTimer(3, function()
            local forward = self.target:GetForwardVector()
            local random = RotateVectorAroundAngle(forward, math.random(0,360))
            local back =  random * 100 + self.target:GetAbsOrigin()
            FindClearSpaceForUnit(caster, back, true)
            Aggro:Reset(caster)
            local landing = FindUnitsInRadius(caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    self.frostbite_radius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)

            for _, enemy in pairs(landing) do
                local modifierTable = {}
                modifierTable.ability = self
                modifierTable.target = enemy
                modifierTable.caster = caster
                modifierTable.modifier_name = "modifier_yukionna_frostbite"
                modifierTable.duration = self.frostbite_duration
                GameMode:ApplyDebuff(modifierTable)
            end
        end)
    end
    local ability = caster:FindAbilityByName("yukionna_breath")
    if ability then
        local remaining_cooldown = ability:GetCooldownTimeRemaining()

        if remaining_cooldown > 0 then
            ability:EndCooldown()
        end
    end
    Timers:CreateTimer(3.1, function()

        local nova_pfx2 = ParticleManager:CreateParticle(particle_nova, PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(nova_pfx2, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(nova_pfx2, 1, Vector(self.frostbite_radius,2,self.frostbite_radius))
        ParticleManager:SetParticleControl(nova_pfx2, 2, caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(nova_pfx2)
        EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Crystal.CrystalNova", caster)
    end)
end

modifier_yukionna_women = class({
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

function modifier_yukionna_women:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.health_start_counting_point = 1
    Timers:CreateTimer(0.1,function() -- seem like difficulty fuck this up with max health manipulation or get 0 if call too fast so 0.1 delay
        self.health_per_infuse = self.ability:GetSpecialValueFor("health_per_infuse") * 0.01
        self.Max_Health = self.parent:GetMaxHealth()
        self.timer = self.ability:GetSpecialValueFor("timer")
        --reset health start counting point incase its a long fight or she heal back
        self:StartIntervalThink(self.timer)
    end)
end


function modifier_yukionna_women:OnTakeDamage(keys)
    if keys.unit == self.parent then
        self.health_loss = self.health_start_counting_point  - (self.parent:GetHealth()/self.Max_Health)
        if self.health_loss > self.health_per_infuse and self.parent:IsAlive() then
            self.ability:Disappear()
            self.health_start_counting_point = self.health_start_counting_point - self.health_per_infuse
        end
    end
end

function modifier_yukionna_women:OnIntervalThink()
    self.health_start_counting_point = math.min(self.parent:GetHealth()/self.Max_Health + self.health_per_infuse*0.5,1)
end

--------------------
--yukionna hug my child -- send tracking krobeling to hero(s) dealing physical dot and applying slow both grew exponentially (model sink deeper and deeper into ground ), krobeling can be killed by autoattack but killer will trigger broken promise stun
--------------------
yukionna_child = class({
    GetAbilityTextureName = function(self)
        return "yukionna_child"
    end,

})

function yukionna_child:OnUpgrade()
    if (not IsServer()) then
    end
    self.range = self:GetSpecialValueFor("range")
end

function yukionna_child:OnSpellStart()
    local caster = self:GetCaster()
    local summon_point = caster:GetAbsOrigin()
    local number = self:GetSpecialValueFor("number")
    for i=1,number,1 do
        local child = CreateUnitByName("npc_boss_yukionna_child", summon_point, true, caster, caster, caster:GetTeamNumber())
        child:AddNewModifier(caster, self, "modifier_kill", { duration = 30 })
        local modifierTable ={}
        modifierTable.ability = self
        modifierTable.target = child
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_yukionna_child_gravity"
        modifierTable.duration = -1
        GameMode:ApplyBuff(modifierTable)
    end
end

modifier_yukionna_child_gravity = class({
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
        return {MODIFIER_EVENT_ON_DEATH,
                MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,}
    end
})

function modifier_yukionna_child_gravity:CheckState()
    return {[MODIFIER_STATE_DISARMED] = true,
            --[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_FLYING] = true,
            }
end

function modifier_yukionna_child_gravity:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.damage_range = self.ability:GetSpecialValueFor("damage_range")
    self.speed = self.ability:GetSpecialValueFor("speed")
    self.counter = 1
    Timers:CreateTimer(1,function()
        self.range = self.ability:GetSpecialValueFor("range")
        local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(),
                self.parent:GetAbsOrigin(),
                nil,
                self.range,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        if (#enemies > 0) then
            self.target = enemies[1] --random one
            self.parent:MoveToNPC(self.target)
        else
            self.parent:MoveToNPC(self.caster)
        end
        self.base_damage = self.ability:GetSpecialValueFor("base_damage")
        self:StartIntervalThink(1.5)
        self:OnIntervalThink()
    end)
end

function modifier_yukionna_child_gravity:OnIntervalThink()
    if self.target:IsAlive() and CalcDistanceBetweenEntityOBB(self.target,self.parent) < self.damage_range then
        self.parent:MoveToNPC(self.target)
        local damage = self.base_damage * math.pow(self.counter,2)
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = self.target
        damageTable.ability = self.ability
        damageTable.damage = damage
        damageTable.physical = true
        GameMode:DamageUnit(damageTable)
        local warning = "particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova.vpcf"
        local start_particle = ParticleManager:CreateParticle(warning, PATTACH_ABSORIGIN, self.target)
        ParticleManager:ReleaseParticleIndex(start_particle)
        self.counter = self.counter + 1
        --too far? just maintain counter value
    elseif  self.target:IsAlive() then
        self.counter = self.counter
        self.parent:MoveToNPC(self.target)
    else--reset counter find new target
        self.counter = 1
        local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(),
                self.parent:GetAbsOrigin(),
                nil,
                self.range,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        if (#enemies > 0) then --find target?
            self.target = enemies[1] --random one
            self.parent:MoveToNPC(self.target)
        else --cant find? follow your mom
            self.parent:MoveToNPC(self.caster)
        end
    end
end


function modifier_yukionna_child_gravity:OnDeath( params ) --venge death = bubble pop
    if IsServer() then
        if params.unit == self.caster then
            self:Destroy()
            self.parent:ForceKill(false)
        end
    end
end

function modifier_yukionna_child_gravity:GetModifierMoveSpeed_AbsoluteMin()
    return self.speed
end

LinkLuaModifier( "modifier_yukionna_child_gravity", "creeps/zone4/boss/yukionna.lua", LUA_MODIFIER_MOTION_NONE )

---------------
--yukionna snow body
----------------
yukionna_body = class({
    GetAbilityTextureName = function(self)
        return "yukionna_body"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_yukionna_body"
    end,
})


modifier_yukionna_body = class({
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
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function yukionna_body:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.max_stacks = self:GetSpecialValueFor("max_stacks")
    self.dmg_reduction = self:GetSpecialValueFor("dmg_reduction") * 0.01
    self.duration = self:GetSpecialValueFor("duration")
end


function modifier_yukionna_body:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_yukionna_body:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    if keys.target == self.parent and not self.parent:HasModifier("modifier_yukionna_snowstorm_eye") then
        local modifierTable = {}
        modifierTable.ability = self:GetAbility()
        modifierTable.target =  self.parent
        modifierTable.caster =  self.parent
        modifierTable.modifier_name = "modifier_yukionna_crushed"
        modifierTable.duration = self.ability.duration
        modifierTable.stacks = 1
        modifierTable.max_stacks = self.ability.max_stacks
        GameMode:ApplyStackingDebuff(modifierTable)
    end
end

function modifier_yukionna_body:GetDamageReductionBonus()
    return self.ability.dmg_reduction
end

LinkLuaModifier("modifier_yukionna_body", "creeps/zone4/boss/yukionna.lua", LUA_MODIFIER_MOTION_NONE)

modifier_yukionna_crushed = class({
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
        return yukionna_body:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_dazzle/dazzle_armor_enemy_shield.vpcf"
    end,
    GetEffectAttachType =  function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end
})

function modifier_yukionna_crushed:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.amp = self.ability:GetSpecialValueFor("amp") *-0.01
end

function modifier_yukionna_crushed:OnRefresh()
    if (not IsServer()) then
        return
    end
    self:OnCreated()
end


function modifier_yukionna_crushed:GetDamageReductionBonus()
    return self.amp * self:GetStackCount()
end

LinkLuaModifier("modifier_yukionna_crushed", "creeps/zone4/boss/yukionna.lua", LUA_MODIFIER_MOTION_NONE)

--internal stuff
if (IsServer() and not GameMode.ZONE1_BOSS_YUKIONNA) then
    GameMode:RegisterPostApplyModifierEventHandler(Dynamic_Wrap(modifier_yukionna_promise, 'OnPostModifierApplied'))
    GameMode.ZONE1_BOSS_YUKIONNA = true
end
