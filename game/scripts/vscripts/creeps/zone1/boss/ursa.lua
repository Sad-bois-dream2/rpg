---------------------
--ursa rend modifier
---------------------
ursa_rend = class({
    GetAbilityTextureName = function(self)
        return "ursa_rend"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_ursa_rend"
    end,
})

modifier_ursa_rend = modifier_ursa_rend or class({
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

function modifier_ursa_rend:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

LinkLuaModifier("modifier_ursa_rend", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_ursa_rend:OnAttackLanded(keys)
    --start cd
    if not IsServer() then
        return
    end
    if (keys.attacker == self.parent and self.ability:IsCooldownReady()) then
        keys.target:EmitSound("Hero_Slardar.Bash")
        self.parent:EmitSound("ursa_ursa_overpower_05")
        self.ability:ApplyRend(keys.target, self.parent)
        local abilityCooldown = self.ability:GetCooldown(self.ability:GetLevel())
        self.ability:StartCooldown(abilityCooldown)
    end
end

function ursa_rend:ApplyRend(target, parent)
    -- "Rend first applies its armor debuff, bash, then Ursa's attack damage, and then the Rend damage."
    self.armor_reduction_duration = self.armor_reduction_duration or self:GetSpecialValueFor("duration")
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_ursa_rend_armor"
    modifierTable.duration = self.armor_reduction_duration
    GameMode:ApplyDebuff(modifierTable)
    self.stun = self.stun or self:GetSpecialValueFor("stun")
    modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_stunned"
    modifierTable.duration = self.stun
    GameMode:ApplyDebuff(modifierTable)
    --fury swipe particle
    --local ursa_rend_armor_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
    --ParticleManager:SetParticleControlEnt(ursa_rend_armor_fx, 0, target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    --Timers:CreateTimer(self.armor_reduction_duration, function()
        --ParticleManager:DestroyParticle(ursa_rend_armor_fx, false)
        --ParticleManager:ReleaseParticleIndex(ursa_rend_armor_fx)
    --end)

end

modifier_ursa_rend_armor = modifier_ursa_rend_armor or class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end

})


function modifier_ursa_rend_armor:OnCreated()
    if not IsServer() then
        return
    end
    self.armor_reduction_percentage = 0
    local modifier = self:GetCaster():FindModifierByName("modifier_ursa_rend")
    if (modifier) then
        self.armor_reduction_percentage = modifier.ability:GetSpecialValueFor("armor_reduction_percentage") * -0.01
    end

end

function modifier_ursa_rend_armor:GetArmorPercentBonus()
    return self.armor_reduction_percentage
end



LinkLuaModifier("modifier_ursa_rend_armor", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

---------------------
-- ursa fury modifier
---------------------

modifier_ursa_fury = modifier_ursa_fury or class({
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

function modifier_ursa_fury:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ursa_fury:GetStatusEffectName()
    return "particles/status_fx/status_effect_overpower.vpcf"
end

function modifier_ursa_fury:OnCreated()
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.ability = self:GetAbility()
    self.duration = self.ability:GetSpecialValueFor("duration")
    self.attackspeed_bonus = self.ability:GetSpecialValueFor("attackspeed_bonus")
    self.movespeed_bonus = self.ability:GetSpecialValueFor("movespeed_bonus")*0.01
    self.ursa_overpower_buff_particle = "particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf"

    local ursa_overpower_buff_particle_fx = ParticleManager:CreateParticle(self.ursa_overpower_buff_particle, PATTACH_CUSTOMORIGIN, self.caster)
    ParticleManager:SetParticleControlEnt(ursa_overpower_buff_particle_fx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_head", self.caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(ursa_overpower_buff_particle_fx, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(ursa_overpower_buff_particle_fx, 2, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(ursa_overpower_buff_particle_fx, 3, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
    self:AddParticle(ursa_overpower_buff_particle_fx, false, false, -1, false, false)
end


--speed modifier
function modifier_ursa_fury:CheckState()
    --phase and haste
    return {
        [MODIFIER_STATE_UNSLOWABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
end

function modifier_ursa_fury:GetAttackSpeedPercentBonus()
    return self.attackspeed_bonus
end

function modifier_ursa_fury:GetMoveSpeedPercentBonus()
    return self.movespeed_bonus
end

function modifier_ursa_fury:GetModifierMoveSpeed_Limit()
    return 1
end

LinkLuaModifier("modifier_ursa_fury", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

-- ability class
ursa_fury = class({
    GetAbilityTextureName = function(self)
        return "ursa_fury"
    end,
})

function ursa_fury:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    caster:EmitSound("Hero_Ursa.Overpower")
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_ursa_fury"
    modifierTable.duration = duration
    GameMode:ApplyBuff(modifierTable) -- apply fury
end

---------------------
-- ursa roar
---------------------

-- ability class
ursa_roar = class({
    GetAbilityTextureName = function(self)
        return "ursa_roar"
    end,
})

function ursa_roar:IsRequireCastbar()
    return true
end

function ursa_roar:OnSpellStart()
    if IsServer() then
        -- Ability properties
        local caster = self:GetCaster()
        -- Ability specials
        local radius = self:GetSpecialValueFor("radius")
        local stun_duration = self:GetSpecialValueFor("stun")

        -- Play cast sound
        caster:EmitSound("Hero_Ursa.Enrage")
       -- Find all nearby enemies
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
            -- Apply the three debuffs on them
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_stunned"
            modifierTable.duration = stun_duration
            GameMode:ApplyDebuff(modifierTable)
        end
    end
end

---------------------
-- ursa swift
---------------------
-- ability class
ursa_swift = class({
    GetAbilityTextureName = function(self)
        return "ursa_swift"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_ursa_swift"
    end,
})


-- modifiers
modifier_ursa_swift = modifier_ursa_swift or class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})
function modifier_ursa_swift:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.chance = self.ability:GetSpecialValueFor("chance")
end


LinkLuaModifier("modifier_ursa_swift", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

--modifier_ursa_swift_phase = modifier_ursa_swift_phase or class({
   -- IsDebuff = function(self)
   --     return false
   -- end,
   -- IsHidden = function(self)
   --     return true
   -- end,
   -- IsPurgable = function(self)
   --     return false
   -- end,
   -- RemoveOnDeath = function(self)
   --     return true
   -- end,
   -- AllowIllusionDuplicate = function(self)
   --     return false
   -- end,
   -- DeclareFunctions = function(self)
   --     return { MODIFIER_EVENT_ON_ATTACK_LANDED }
   -- end
--})

--function modifier_ursa_swift_phase:OnCreated()
    --if (not IsServer()) then
        --return
    --end
    --self.parent = self:GetParent()
    --self.ability = self:GetAbility()
--end

--LinkLuaModifier("modifier_ursa_swift_phase", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

--function ursa_swift:ApplyPhase(parent)
   -- --  flying after blink. no phase
   -- local modifierTable = {}
   -- modifierTable.ability = self
   -- modifierTable.target = parent
   -- modifierTable.caster = parent
   -- modifierTable.modifier_name = "modifier_ursa_swift_phase"
   -- modifierTable.duration = 10
   -- GameMode:ApplyBuff(modifierTable)

--end

--function modifier_ursa_swift_phase:CheckState()
    --fly no phase
    --return {
        --[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        --[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
    --}
--end

function ursa_swift:ApplyFury(attacker, parent)
    -- "Fury proc instead of swift blink in hunt mode."
    local duration = self:GetSpecialValueFor("duration")
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = attacker
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_ursa_fury"
    modifierTable.duration = duration
    GameMode:ApplyBuff(modifierTable)
end

function ursa_swift:FindTargetForBlink(caster)
    if IsServer() then
    local radius = self:GetSpecialValueFor("radius")
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
    local distanceToBoss = 0
    local latestDistance = 0
    local jumpTarget = caster--?????
    local casterPos = caster:GetAbsOrigin()
    for _, enemy in pairs(enemies) do
        -- find the farthest hero from the heroes in range
        distanceToBoss = (casterPos - enemy:GetAbsOrigin()):Length()
        if distanceToBoss >= latestDistance then
            -- if new distance to boss higher than the max one replace the farthest hero
            jumpTarget = enemy
            latestDistance = distanceToBoss
        end
    end
        if(#enemies > 0) then
            return jumpTarget
        else
            return nil
        end
    end
end

function ursa_swift:Blink()
    -- Teleport
    local caster = self:GetCaster()
    local target = self:FindTargetForBlink(caster)
    local sound_cast = "Hero_Antimage.Blink_out"
    if (target==nil) then
        return
    end
    caster:EmitSound(sound_cast)

    -- Blink
    local targetPosition = target:GetAbsOrigin()
    local vector = (targetPosition - caster:GetAbsOrigin())
    --local distance = vector:Length2D()
    local direction = vector:Normalized()
    local blink_point = targetPosition - (target:GetForwardVector()*100)--+ direction * (distance -10 )
    caster:SetAbsOrigin(blink_point)
    Timers:CreateTimer(0.3, function()
        FindClearSpaceForUnit(caster, blink_point, true)
    end)
    sound_cast = "Hero_Antimage.Blink_in"
    caster:EmitSound(sound_cast)
    Aggro:Reset(caster)
    Aggro:Add(target, caster, 100)
    caster:MoveToTargetToAttack(target)
    caster:PerformAttack(target, true, true, true, true, false, false, false)
    caster:SetForwardVector(direction)

    -- Disjoint projectiles
    ProjectileManager:ProjectileDodge(caster)

end

function modifier_ursa_swift:OnAttackLanded(keys)
    --proc and remove teleport buff from ursa
    if (not IsServer()) then
        return
    end
    local abilityCooldown = self.ability:GetCooldown(self.ability:GetLevel())
    if (keys.attacker == self.parent and self.ability:IsCooldownReady()) then
        --only apply if attack is the caster and proc
        --roll for chance
        if RollPercentage(self.chance) then
            self.ability:StartCooldown(abilityCooldown)
            if self.parent:HasModifier("modifier_ursa_hunt_buff_stats") then
                self.ability:ApplyFury(keys.attacker, self.parent)
            else
                --self.ability:ApplyPhase(self.parent)
                self.ability:Blink()
            end

        end
    end
end
---------------------
-- ursa slam
---------------------

-- ability class
ursa_slam = class({
    GetAbilityTextureName = function(self)
        return "ursa_slam"
    end,
})

function ursa_slam:IsRequireCastbar()
    return true
end

function ursa_slam:OnSpellStart()
    if IsServer() then
        -- Ability properties

        self.caster = self:GetCaster()
        local sound_cast = "Hero_Ursa.Earthshock"
        local earthshock_particle = "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf"
        local particle_hit = "particles/units/heroes/hero_slardar/slardar_crush_entity.vpcf"
        -- Ability specials
        local radius = self:GetSpecialValueFor("radius")
        local damage = self:GetSpecialValueFor("damage")
        local slow_duration = self:GetSpecialValueFor("duration")

        -- Play cast sound
        EmitSoundOn(sound_cast, self.caster)

        -- Add appropriate particles
        local earthshock_particle_fx = ParticleManager:CreateParticle(earthshock_particle, PATTACH_ABSORIGIN, self.caster)
        ParticleManager:SetParticleControl(earthshock_particle_fx, 0, self.caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(earthshock_particle_fx, 1, Vector(1,1,1))
        Timers:CreateTimer(6.0, function()
            ParticleManager:DestroyParticle(earthshock_particle_fx, false)
            ParticleManager:ReleaseParticleIndex(earthshock_particle_fx)
        end)

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
            -- Apply hit earthshock particles on enemies hit
            local particle_hit_fx = ParticleManager:CreateParticle(particle_hit, PATTACH_ABSORIGIN, enemy)
            ParticleManager:SetParticleControl(particle_hit_fx, 0, enemy:GetAbsOrigin())
            Timers:CreateTimer(1.0, function()
                ParticleManager:DestroyParticle(particle_hit_fx, false)
                ParticleManager:ReleaseParticleIndex(particle_hit_fx)
            end)
            --Damage nearby enemies
            local damageTable = {}
            damageTable.caster = self.caster
            damageTable.target = enemy
            damageTable.ability = self -- can be nil
            damageTable.damage = damage
            damageTable.earthdmg = true
            GameMode:DamageUnit(damageTable)

            -- Apply the three debuffs on them
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_ursa_slam_slow"
            modifierTable.duration = slow_duration
            GameMode:ApplyDebuff(modifierTable)
        end
    end
end


-- Slow modifier
modifier_ursa_slam_slow = modifier_ursa_slam_slow or class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTextureName = function(self)
        return "ursa_slam"
    end,
})

function modifier_ursa_slam_slow:GetAttackSpeedPercentBonus()
    return self.as_slow
end

function modifier_ursa_slam_slow:GetMoveSpeedPercentBonus()
    return self.ms_slow
end

function modifier_ursa_slam_slow:GetSpellHasteBonus()
    return self.sph_slow
end

function modifier_ursa_slam_slow:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.sph_slow = self.ability:GetSpecialValueFor("sph_slow") *-0.01
    self.as_slow = self.ability:GetSpecialValueFor("as_slow") *-0.01
    self.ms_slow = self.ability:GetSpecialValueFor("ms_slow") *-0.01
end

function modifier_ursa_slam_slow:GetStatusEffectName()
    return "particles/units/heroes/hero_ursa/ursa_earthshock_modifier.vpcf"
end

LinkLuaModifier("modifier_ursa_slam_slow", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

---------------------
-- ursa hunting prey
---------------------
-- modifiers
modifier_ursa_hunt_buff_stats = modifier_ursa_hunt_buff_stats or class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH }
    end
})

function modifier_ursa_hunt_buff_stats:GetAttackDamagePercentBonus()
    return self.damage_increase_outgoing_pct or 0
end

function modifier_ursa_hunt_buff_stats:GetDamageReductionBonus()
    return self.damage_increase_incoming_pct or 0
end

function modifier_ursa_hunt_buff_stats:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.health_heal_pct = self.ability:GetSpecialValueFor("health_heal_pct") / 100
    self.damage_increase_outgoing_pct = self.ability:GetSpecialValueFor("damage_increase_outgoing_pct") / 100
    self.damage_increase_incoming_pct = self.ability:GetSpecialValueFor("damage_increase_incoming_pct") * -0.01
end

function modifier_ursa_hunt_buff_stats:OnDeath(params)
    if (params.attacker == self.parent) then
        local healTable = {}
        healTable.caster = self.parent
        healTable.target = self.parent
        healTable.ability = self.ability
        healTable.heal = params.attacker:GetMaxHealth() * self.health_heal_pct
        GameMode:HealUnit(healTable)
        local healFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_POINT_FOLLOW, self.parent)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(healFX, false)
            ParticleManager:ReleaseParticleIndex(healFX)
        end)
    end
end

LinkLuaModifier("modifier_ursa_hunt_buff_stats", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

modifier_ursa_hunt_random_taunt = modifier_ursa_hunt_random_taunt or class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true -- ?
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end
})

function modifier_ursa_hunt_random_taunt:IsTaunt()
    return true
end

LinkLuaModifier("modifier_ursa_hunt_random_taunt", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

-- ability class
ursa_hunt = class({
    GetAbilityTextureName = function(self)
        return "ursa_hunt"
    end
})

function modifier_ursa_hunt_random_taunt:GetEffectName()
    return "particles/items2_fx/urn_of_shadows_damage.vpcf"
end

function modifier_ursa_hunt_buff_stats:GetStatusEffectName()
    return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function ursa_hunt:FindTauntTarget(caster)
    local radius = self:GetSpecialValueFor("radius")
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
        local tauntTarget = enemies[keys[math.random(#keys)]] --pick one number = pick one enemy
        if(#enemies > 0) then
            return tauntTarget
        else
            return nil
        end
    end
end

function ursa_hunt:OnSpellStart()
    local caster = self:GetCaster() --bloodrage caster
    local duration = self:GetSpecialValueFor("duration")
    local tauntTarget = self:FindTauntTarget(caster)
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = tauntTarget
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_ursa_hunt_random_taunt"
    modifierTable.duration = duration
    GameMode:ApplyDebuff(modifierTable) --apply taunt buff
    modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_ursa_hunt_buff_stats"
    modifierTable.duration = duration
    GameMode:ApplyBuff(modifierTable) -- apply bloodrage
    tauntTarget:EmitSound("hero_bloodseeker.bloodRage")
    caster:EmitSound("ursa_ursa_overpower_03")
end


