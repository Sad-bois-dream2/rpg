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
    self.cd_reduce = self.ability:GetSpecialValueFor("cd_reduce")
end


---@param modifierTable MODIFIER_TABLE
function modifier_yukionna_promise:OnPostModifierApplied(modifierTable)
    local modifier = modifierTable.target:FindModifierByName("modifier_yukionna_promise")
    if modifier then
    local debuff = modifierTable.target:FindModifierByName(modifierTable.modifier_name)
    if( debuff.CheckState) then
        local stateTable = debuff.CheckState(debuff)
        local isStun = (stateTable[MODIFIER_STATE_STUNNED] == true)
        local isSilence = (stateTable[MODIFIER_STATE_SILENCED] == true)
        if (isStun or isSilence) then
            local hero = modifierTable.caster
            local dp = modifierTable.target
            modifierTable.ability = modifier:GetAbility()
            modifierTable.target = hero
            modifierTable.caster = dp
            modifierTable.modifier_name = "modifier_yukionna_promise_stun"
            modifierTable.duration = modifier:GetAbility():GetSpecialValueFor("stun")
            GameMode:ApplyDebuff(modifierTable)
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
    if (keys.attacker == self.parent and RollPercentage(100)) then

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

--reduce these by 1000%
function modifier_yukionna_promise_stun:GetSpellDamageBonus()
    return -10
end

function modifier_yukionna_promise_stun:GetAttackDamagePercentBonus()
    return -10
end

function modifier_yukionna_promise_stun:GetHealingCausedPercentBonus()
    return -10 -- finalHeal = heal * this
end

function modifier_helltower_hellchain:GetHealthRegenerationPercentBonus()
    return -10
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
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
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
    self.tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(self.tick) --1
end

function modifier_yukionna_snowstorm_eye:OnIntervalThink()
    if self.parent:IsAlive() then
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
                        distance		= self.ability:GetSpecialValueFor("pull_distance"), --300
                        direction_x 	= -unit_vector.x,
                        direction_y 	= -unit_vector.y,
                        direction_z 	= 0,
                        duration 		= self.ability:GetSpecialValueFor("pull_duration"), --0.5
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
        --apply buff
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.caster
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_yukionna_snowstorm_eye"
        modifierTable.duration = duration
        GameMode:ApplyBuff(modifierTable)
        self.freezing_field_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
        self.caster:EmitSound("hero_Crystal.freezingField.wind")
        ParticleManager:SetParticleControlEnt(self.freezing_field_particle, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true )
        ParticleManager:SetParticleControl(self.freezing_field_particle, 1, Vector (2500, 0, 0))
        Timers:CreateTimer(duration, function()
            ParticleManager:DestroyParticle(self.freezing_field_particle, true)
            ParticleManager:ReleaseParticleIndex(self.freezing_field_particle)
        end)
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
        target:AddNewModifier(self.caster, self.ability, "modifier_yukionna_promise_stun", {duration = 10})
        local health = target:GetHealth()
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = health * 0.5
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
        ParticleManager:SetParticleControl(self.nFX, 5, Vector(10,0,0 ) )
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

--function modifier_yukionna_drain_debuff:OnDestroy()
    --if IsServer() then
        --self:GetParent():StopSound("Hero_DeathProphet.SpiritSiphon.Target")
        --ParticleManager:ReleaseParticleIndex(self.nFX)
        --ParticleManager:DestroyParticle(self.nFX, false)
    --end
--end

function modifier_yukionna_drain_debuff:GetMoveSpeedPercentBonus()
    if self.solo == 1 then
        return self.slow
    else return 0
    end
end

LinkLuaModifier( "modifier_yukionna_drain_debuff", "creeps/zone4/boss/yukionna.lua", LUA_MODIFIER_MOTION_NONE )

-------------------
--yukionna bewitching beauty --passive periodically apply debuff make a random hero walk toward her if any hero are too close they get essence drain for 3s.
-------------------

------------------
--yukionna women of the snow--summon several ghosts of herself ghosts has very high AA but low ms
------------------

--------------------
--yukionna hug my child -- send tracking krobeling to hero(s) dealing physical dot and applying slow both grew exponentially (model sink deeper and deeper into ground ), krobeling can be killed by autoattack but killer will trigger broken promise stun
--------------------
--from lore: On the night of a blizzard, as the Yuki-onna would be standing there hugging a child (yukinko), it would ask people passing by to hug the child as well. When one hugs the child, the child would become heavier and heavier until one would become covered with snow and freeze to death. It has also been told that if one refuses, one would be shoved down into a snowy valley.

--internal stuff
if (IsServer() and not GameMode.ZONE1_BOSS_YUKIONNA) then
    GameMode:RegisterPostApplyModifierEventHandler(Dynamic_Wrap(modifier_yukionna_promise, 'OnPostModifierApplied'))
    GameMode.ZONE1_BOSS_YUKIONNA = true
end
