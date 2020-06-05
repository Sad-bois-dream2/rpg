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

function ursa_rend:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.abilityCooldown = self:GetCooldown(self:GetLevel() - 1)
    self.stun = self:GetSpecialValueFor("stun")
    self.armor_reduction_duration = self:GetSpecialValueFor("duration")
end

modifier_ursa_rend = class({
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
    end,
})

function modifier_ursa_rend:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

-- ursa dash apply rend
---@param damageTable DAMAGE_TABLE
function modifier_ursa_rend:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_ursa_rend")
    if (damageTable.damage > 0 and modifier and damageTable.ability and damageTable.physdmg == true and damageTable.attacker:IsAlive())  then
        local modifierTable = {}
        modifierTable.ability = modifier:GetAbility()
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_ursa_rend_armor"
        modifierTable.duration = modifier:GetAbility():GetSpecialValueFor("duration")
        GameMode:ApplyDebuff(modifierTable)
        modifierTable = {}
        modifierTable.ability = modifier:GetAbility()
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_stunned"
        modifierTable.duration = modifier:GetAbility():GetSpecialValueFor("stun")
        GameMode:ApplyDebuff(modifierTable)
        modifierTable = {}
        modifierTable.ability = modifier:GetAbility()
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_ursa_rend_armor_static"
        modifierTable.duration = modifier:GetAbility():GetSpecialValueFor("duration")
        modifierTable.stacks = 1
        modifierTable.max_stacks = 99999
        GameMode:ApplyStackingDebuff(modifierTable)
        damageTable.victim:EmitSound("Hero_Slardar.Bash")
    end
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
        self.ability:StartCooldown(self.ability.abilityCooldown)
    end
    if (keys.attacker == self.parent) then
        local modifierTable = {}
        modifierTable.ability = self:GetAbility()
        modifierTable.target = keys.target
        modifierTable.caster = keys.attacker
        modifierTable.modifier_name = "modifier_ursa_rend_armor_static"
        modifierTable.duration = self:GetAbility():GetSpecialValueFor("duration")
        modifierTable.stacks = 1
        modifierTable.max_stacks = 99999
        GameMode:ApplyStackingDebuff(modifierTable)
    end
end

function ursa_rend:ApplyRend(target, parent)
    -- "Rend first applies its armor debuff, bash, then Ursa's attack damage, and then the Rend damage."
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_stunned"
    modifierTable.duration = self.stun
    GameMode:ApplyDebuff(modifierTable)
end


modifier_ursa_rend_armor_static = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end,
    GetTexture = function(self)
        return ursa_rend:GetAbilityTextureName()
    end,
})

function modifier_ursa_rend_armor_static:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction") * -1
    self.armor_reduction_total = self.armor_reduction * (self:GetStackCount() + 1)
end


function modifier_ursa_rend_armor_static:OnRefresh()
    if not IsServer() then
        return
    end
    self:OnCreated()
end

function modifier_ursa_rend_armor_static:GetArmorBonus()
    return self.armor_reduction_total
end



LinkLuaModifier("modifier_ursa_rend_armor_static", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)


---------
--ursa dash
---------

-- ursa_dash modifiers

modifier_ursa_dash_motion = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetMotionControllerPriority = function(self)
        return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM
    end,
})

function modifier_ursa_dash_motion:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
    return state
end

function modifier_ursa_dash_motion:OnCreated(kv)
    if IsServer() then
        local ability = self:GetAbility()
        local ability_level = ability:GetLevel() - 1
        self.ability = ability
        self.caster = self:GetParent()
        self.start_location = self.caster:GetAbsOrigin()
        self.dash_speed = ability:GetLevelSpecialValueFor("dash_speed", ability_level)
        self.dash_range = ability:GetLevelSpecialValueFor("dash_range", ability_level)
        self.base_damage = ability:GetLevelSpecialValueFor("base_damage", ability_level)
        self.stun_radius = ability:GetLevelSpecialValueFor("stun_radius", ability_level)
        self.damagedEnemies = {}
        if (self:ApplyHorizontalMotionController() == false) then
            self:Destroy()
        end
        self:StartIntervalThink(0.1)
    end
end


function modifier_ursa_dash_motion:OnDestroy()
    if IsServer() then
        self.caster:RemoveHorizontalMotionController(self)
        self.caster:RemoveGesture(ACT_DOTA_ATTACK)
        ParticleManager:DestroyParticle(self.ability.particle, false)
        ParticleManager:ReleaseParticleIndex(self.ability.particle)
    end
end

function modifier_ursa_dash_motion:OnHorizontalMotionInterrupted()
    if IsServer() then
        self:Destroy()
    end
end

function modifier_ursa_dash_motion:UpdateHorizontalMotion(me, dt)
    if (IsServer()) then
        local current_location = self.caster:GetAbsOrigin()
        local expected_location = current_location + self.caster:GetForwardVector() * self.dash_speed * dt
        local isTraversable = GridNav:IsTraversable(expected_location)
        local isBlocked = GridNav:IsBlocked(expected_location)
        local isTreeNearby = GridNav:IsNearbyTree(expected_location, self.caster:GetHullRadius(), true)
        local traveled_distance = DistanceBetweenVectors(current_location, self.start_location)
        if (isTraversable and not isBlocked and not isTreeNearby and traveled_distance < self.dash_range ) then
            self.caster:SetAbsOrigin(expected_location)
            local particle_location = expected_location + Vector(0, 0, 100)
            ParticleManager:SetParticleControl(self.ability.particle, 0, particle_location)
            ParticleManager:SetParticleControl(self.ability.particle, 1, particle_location)
            local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
                    expected_location,
                    nil,
                    200,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            for _, enemy in pairs(enemies) do
                if (not TableContains(self.damagedEnemies, enemy)) then
                    if self.caster:IsAlive() then
                        local damageTable = {}
                        damageTable.caster = self.caster
                        damageTable.target = enemy
                        damageTable.ability = self.ability
                        damageTable.damage = self.base_damage
                        damageTable.physdmg = true
                        GameMode:DamageUnit(damageTable)
                        table.insert(self.damagedEnemies, enemy)
                    end
                end
            end
        elseif ( traveled_distance < self.dash_range) then
            expected_location = current_location - self.caster:GetForwardVector() * self.dash_speed * dt -- backward dash if blocked
            self.caster:SetAbsOrigin(expected_location)
            local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
                    expected_location,
                    nil,
                    200,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            for _, enemy in pairs(enemies) do
                if (not TableContains(self.damagedEnemies, enemy)) then
                    if self.caster:IsAlive() then
                        local damageTable = {}
                        damageTable.caster = self.caster
                        damageTable.target = enemy
                        damageTable.ability = self.ability
                        damageTable.damage = self.base_damage
                        damageTable.physdmg = true
                        GameMode:DamageUnit(damageTable)
                        table.insert(self.damagedEnemies, enemy)
                    end
                end
            end
        else
            self:Destroy()
        end
    end
end
LinkLuaModifier("modifier_ursa_dash_motion", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_HORIZONTAL)


-- ursa_dash
ursa_dash = class({
    GetAbilityTextureName = function(self)
        return "ursa_dash"
    end,
})

function ursa_dash:IsRequireCastbar()
    return true
end

function ursa_dash:IsInterruptible()
    return false
end


function ursa_dash:FindTargetForDash(caster)
    local range = self:GetSpecialValueFor("dash_range") * 1.5
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
    local keys = {}
    for k in pairs(enemies) do
        table.insert(keys, k)
    end
    if (#enemies > 0) then
        local dashTarget = enemies[keys[math.random(#keys)]] --pick one number = pick one enemy
        if (#enemies > 0) then
            return dashTarget
        else
            return nil
        end
    end
end

function ursa_dash:OnSpellStart(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        local location = caster:GetAbsOrigin()
        local number = self:GetSpecialValueFor("number")
        EmitSoundOn("ursa_ursa_overpower_01", caster)
        local enemy
        local vector
        local counter = 0
        GameMode:ApplyDebuff({ caster = caster, target = caster, ability = self, modifier_name = "modifier_silence", duration = 9 })
        Timers:CreateTimer(0, function()
            if counter < number then
                enemy = self:FindTargetForDash(caster)
                --if can go to enemy
                if enemy ~= nil then
                    location = caster:GetAbsOrigin()
                    vector = (enemy:GetAbsOrigin() - location):Normalized()
                else
                --if cant find dash randomly
                    local angleLeft = QAngle(0, (math.floor(360 / math.random(6))), 0)
                    location = caster:GetAbsOrigin()
                    vector = caster:GetForwardVector()
                    vector = RotatePosition(vector, angleLeft, caster:GetAbsOrigin())
                end
                caster:SetForwardVector(vector)
                caster:StartGesture(ACT_DOTA_ATTACK)
                self.particle = ParticleManager:CreateParticle("particles/units/npc_boss_ursa/ursa_dash/ursa_dash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
                ParticleManager:SetParticleControl(self.particle, 0, location + Vector(0, 0, 100))
                ParticleManager:SetParticleControl(self.particle, 1, location + Vector(0, 0, 100))
                caster:AddNewModifier(caster, self, "modifier_ursa_dash_motion", { Duration = 2 })
                counter = counter+1
                return 3
                end
            end)
    end
end


---------------------
-- ursa fury modifier
---------------------

modifier_ursa_fury = class({
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
        return ursa_fury:GetAbilityTextureName()
    end,
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_overpower.vpcf"
    end
})

function modifier_ursa_fury:OnCreated()
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.ability = self:GetAbility()
    self.duration = self.ability:GetSpecialValueFor("duration")
    self.attackspeed_bonus = self.ability:GetSpecialValueFor("attackspeed_bonus") * 0.01
    self.movespeed_bonus = self.ability:GetSpecialValueFor("movespeed_bonus") * 0.01
    self.ursa_overpower_buff_particle = "particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf"

    self.fury_fx = ParticleManager:CreateParticle(self.ursa_overpower_buff_particle, PATTACH_CUSTOMORIGIN, self.caster)
    ParticleManager:SetParticleControlEnt(self.fury_fx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_head", self.caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.fury_fx, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.fury_fx, 2, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.fury_fx, 3, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
end

function modifier_ursa_fury:OnDestroy()
    if (not IsServer()) then
        return
    end
    ParticleManager:DestroyParticle(self.fury_fx, false)
    ParticleManager:ReleaseParticleIndex(self.fury_fx)
end

--speed modifier
function modifier_ursa_fury:CheckState()
    --phase and haste
    return {
        [MODIFIER_STATE_UNSLOWABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
       --[MODIFIER_STATE_SILENCED] = true,
    }
end

function modifier_ursa_fury:GetAttackSpeedPercentBonus()
    return self.attackspeed_bonus
end

function modifier_ursa_fury:GetMoveSpeedPercentBonus()
    return self.movespeed_bonus
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

function ursa_roar:OnSpellStart()
    if IsServer() then
        if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
            self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
        end

        local target_point = self:GetCursorPosition()
        -- Ability properties
        local caster = self:GetCaster()
        -- Ability specials
        local travel_distance = self:GetSpecialValueFor("travel_distance")
        local start_radius = self:GetSpecialValueFor("start_radius")
        local end_radius = self:GetSpecialValueFor("end_radius")
        local projectile_speed = self:GetSpecialValueFor("projectile_speed")
        -- Play cast sound
        caster:EmitSound("Hero_Ursa.Enrage")
            --particle
            self.roar_particle = "particles/units/npc_boss_ursa/ursa_roar/ursa_roar.vpcf"
            local projectile =
            {
                Ability				= self,
                EffectName			= self.roar_particle,
                vSpawnOrigin		= caster:GetAbsOrigin(),
                fDistance			= travel_distance,
                fStartRadius		= start_radius,
                fEndRadius			= end_radius,
                Source				= caster,
                bHasFrontalCone		= true,
                bReplaceExisting	= false,
                iUnitTargetTeam		= self:GetAbilityTargetTeam(),
                iUnitTargetFlags	= nil,
                iUnitTargetType		= self:GetAbilityTargetType(),
                fExpireTime 		= GameRules:GetGameTime() + 10.0,
                bDeleteOnHit		= true,
                vVelocity			= (((target_point - self:GetCaster():GetAbsOrigin()) * Vector(1, 1, 0)):Normalized())* projectile_speed,
                bProvidesVision		= false,
                --ExtraData			= {damage = damage, stun = stun}
            }
        ProjectileManager:CreateLinearProjectile(projectile)
    end
end

function ursa_roar:OnProjectileHit_ExtraData(target)
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    local stun = self:GetSpecialValueFor("stun")
    if target and caster:IsAlive() then
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.puredmg = true
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
---------------------
-- ursa swift
---------------------
-- ability class

-- modifiers
modifier_ursa_swift = class({
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
end


function modifier_ursa_swift:OnAttackLanded(keys)
    --proc and remove teleport buff from ursa
    if (not IsServer()) then
        return
    end
    local caster = keys.attacker
    if (keys.attacker == self.parent and self.ability:IsCooldownReady()) then
        --only apply if attack is the caster and proc
        --roll for chance
        if RollPercentage(self.ability.chance) then
            self.ability:StartCooldown(self.ability.cooldown)
            if self.parent:HasModifier("modifier_ursa_hunt_buff_stats") then
                self.ability:SwiftEarth(caster)
                self.ability:ApplyFury(keys.attacker, self.parent)
            else
                --self.ability:ApplyPhase(self.parent)
                self.ability:SwiftEarth(caster)
                self.ability:Blink(caster)
                Timers:CreateTimer(0.1, function() self.ability:SwiftEarth(caster) end )
            end
        end
    end
end

LinkLuaModifier("modifier_ursa_swift", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

ursa_swift = class({
    GetAbilityTextureName = function(self)
        return "ursa_swift"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_ursa_swift"
    end,
})

function ursa_swift:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.chance = self:GetSpecialValueFor("chance")
    self.cooldown = self:GetCooldown(self:GetLevel() - 1)
    self.duration = self:GetSpecialValueFor("duration")
    self.radius = self:GetSpecialValueFor("radius")
    self.stun = self:GetSpecialValueFor("stun")
    self.stun_aoe = self:GetSpecialValueFor("stun_aoe")
    self.damage = self:GetSpecialValueFor("damage")
end

function ursa_swift:SwiftEarth(caster)
    -- "Blinking cause earth to split deal aoe damage stun at both location."
    if caster:IsAlive() then
        local swift_earth = ParticleManager:CreateParticle("particles/units/npc_boss_ursa/ursa_swift/ursa_swift.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(swift_earth, 1, Vector(225, 0, 0))
        Timers:CreateTimer(1.5, function()
            ParticleManager:DestroyParticle(swift_earth, false)
            ParticleManager:ReleaseParticleIndex(swift_earth)
        end)
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                self.stun_aoe,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)

        for _, enemy in pairs(enemies) do
            --Damage nearby enemies
            local damageTable = {}
            damageTable.caster = caster
            damageTable.target = enemy
            damageTable.ability = self
            damageTable.damage = self.damage
            damageTable.earthdmg = true
            GameMode:DamageUnit(damageTable)

            -- Apply the stun on them
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_stunned"
            modifierTable.duration = self.stun
            GameMode:ApplyDebuff(modifierTable)
        end
    end
end



function ursa_swift:ApplyFury(attacker, parent)
    -- "Fury proc instead of swift blink in hunt mode."
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = attacker
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_ursa_fury"
    modifierTable.duration = self.duration
    GameMode:ApplyBuff(modifierTable)
end

function ursa_swift:FindTargetForBlink(caster)
    if IsServer() then
        -- Find all nearby enemies
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                self.radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        local distanceToBoss = 0
        local latestDistance = 0
        local jumpTarget
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
        if (#enemies > 0) then
            return jumpTarget
        else
            return nil
        end
    end
end

function ursa_swift:Blink(caster)
    -- Teleport
    local target = self:FindTargetForBlink(caster)
    local sound_cast = "Hero_Antimage.Blink_out"
    if (target == nil) then
        return
    end
    local blink_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
    Timers:CreateTimer(1.5, function()
        ParticleManager:DestroyParticle(blink_pfx, false)
        ParticleManager:ReleaseParticleIndex(blink_pfx)
    end)
    caster:EmitSound(sound_cast)
    -- Blink
    local targetPosition = target:GetAbsOrigin()
    local vector = (targetPosition - caster:GetAbsOrigin())
    --local distance = vector:Length2D()
    local direction = vector:Normalized()
    local blink_point = targetPosition - (target:GetForwardVector() * 100)--+ direction * (distance -10 )
    caster:SetAbsOrigin(blink_point)
    Timers:CreateTimer(0.3, function()
        FindClearSpaceForUnit(caster, blink_point, true)
    end)
    sound_cast = "Hero_Antimage.Blink_in"
    caster:EmitSound(sound_cast)
    local blink_end_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_ABSORIGIN, caster)
    Timers:CreateTimer(1.5, function()
        ParticleManager:DestroyParticle(blink_end_pfx, false)
        ParticleManager:ReleaseParticleIndex(blink_end_pfx)
    end)
    Aggro:Reset(caster)
    Aggro:Add(target, caster, 100)
    caster:MoveToTargetToAttack(target)
    caster:SetForwardVector(direction)
    -- Disjoint projectiles
    ProjectileManager:ProjectileDodge(caster)
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

function ursa_slam:IsInterruptible()
    return true
end

function ursa_slam:OnSpellStart()
    if IsServer() then
        -- Ability properties

        self.caster = self:GetCaster()
        local sound_cast = "Hero_Ursa.Earthshock"
        local earthshock_particle = "particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_ti7.vpcf"
        local aoe_particle = "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf"
        -- Ability specials
        local radius = self:GetSpecialValueFor("radius")
        local damage = self:GetSpecialValueFor("damage")
        local slow_duration = self:GetSpecialValueFor("duration")

        -- Play cast sound
        EmitSoundOn(sound_cast, self.caster)

        -- Add appropriate particles
        local earthshock_particle_fx = ParticleManager:CreateParticle(earthshock_particle, PATTACH_ABSORIGIN, self.caster)
        ParticleManager:SetParticleControl(earthshock_particle_fx, 2, Vector(255, 125, 0))
        Timers:CreateTimer(5.0, function()
            ParticleManager:DestroyParticle(earthshock_particle_fx, false)
            ParticleManager:ReleaseParticleIndex(earthshock_particle_fx)
        end)
        local aoe_particle_fx = ParticleManager:CreateParticle(aoe_particle, PATTACH_ABSORIGIN, self.caster)
        ParticleManager:SetParticleControl(aoe_particle_fx, 2, Vector(radius, radius, 225))
        Timers:CreateTimer(3.0, function()
            ParticleManager:DestroyParticle(aoe_particle_fx, false)
            ParticleManager:ReleaseParticleIndex(aoe_particle_fx)
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
modifier_ursa_slam_slow = class({
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
        return ursa_slam:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_ursa/ursa_earthshock_modifier.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end
})

function modifier_ursa_slam_slow:GetAttackSpeedPercentBonusMulti()
    return self.as_slow_multi
end

function modifier_ursa_slam_slow:GetMoveSpeedPercentBonusMulti()
    return self.ms_slow_multi
end

function modifier_ursa_slam_slow:GetSpellHastePercentBonusMulti()
    return self.sph_slow_multi
end

function modifier_ursa_slam_slow:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.sph_slow = self.ability:GetSpecialValueFor("sph_slow") * -0.01
    self.as_slow = self.ability:GetSpecialValueFor("as_slow") * - 0.01
    self.ms_slow = self.ability:GetSpecialValueFor("ms_slow") * -0.01
    self.sph_slow_multi = self.sph_slow + 1
    self.as_slow_multi = self.as_slow + 1
    self.ms_slow_multi = self.ms_slow + 1
end


LinkLuaModifier("modifier_ursa_slam_slow", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

---------------------
-- ursa hunting prey
---------------------
-- modifiers
--just to make him blue
modifier_ursa_hunt_blue = class({
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
        return "particles/units/npc_boss_ursa/ursa_hunt/hunt_color.vpcf"
    end
})

function modifier_ursa_hunt_blue:OnCreated()
    if not IsServer() then
        return
    end
end
LinkLuaModifier("modifier_ursa_hunt_blue", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)
--real buff
modifier_ursa_hunt_buff_stats = class({
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
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end,

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

function modifier_ursa_hunt_buff_stats:GetDebuffResistanceBonus()
    return 1
end

LinkLuaModifier("modifier_ursa_hunt_buff_stats", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

modifier_ursa_hunt_random_taunt = class({
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
    end,
    GetTexture = function(self)
        return ursa_hunt:GetAbilityTextureName()
    end,
})

function modifier_ursa_hunt_random_taunt:IsTaunt()
    return true
end

function modifier_ursa_hunt_random_taunt:GetEffectName()
    return "particles/items2_fx/urn_of_shadows_damage.vpcf"
end

LinkLuaModifier("modifier_ursa_hunt_random_taunt", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

-- ability class
ursa_hunt = class({
    GetAbilityTextureName = function(self)
        return "ursa_hunt"
    end
})

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
        if (#enemies > 0) then
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
    modifierTable.modifier_name = "modifier_ursa_hunt_blue"
    modifierTable.duration = duration
    GameMode:ApplyBuff(modifierTable) --blue boi
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

-----------
--ursa jelly    --
-----------
-- ursa_jelly modifiers
modifier_ursa_jelly_channel = class({
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

function modifier_ursa_jelly_channel:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    if self.ability then
        self.caster = self:GetParent()
        --self.duration = self.ability:GetSpecialValueFor("duration")
        self.channel_time = self.ability:GetSpecialValueFor("channel_time")
        self.health_heal_pct = self.ability:GetSpecialValueFor("health_heal_pct") * 0.01
        self.tick = self.ability:GetSpecialValueFor("tick")
        self.max_stacks = math.floor(self.channel_time/ self.tick) + 1 --i print have found self.channel_time/ self.tick = 49.999999254942
        self:StartIntervalThink(self.tick)
        self:OnIntervalThink()
    else
        self:Destroy()
    end
end

--gain 1 stack every 0.1s channel total of 50 stacks
function modifier_ursa_jelly_channel:OnIntervalThink()
    local healTable = {}
    healTable.caster = self.caster
    healTable.target = self.caster
    healTable.ability = self.ability
    healTable.heal = self.caster:GetMaxHealth() * self.health_heal_pct /self.max_stacks
    GameMode:HealUnit(healTable)
    local healFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_POINT_FOLLOW, self.caster)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(healFX, false)
        ParticleManager:ReleaseParticleIndex(healFX)
    end)
    local modifierTable = {}
    modifierTable.ability = self.ability
    modifierTable.target = self.caster
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_ursa_jelly_buff"
    modifierTable.duration = -1 --self.duration
    modifierTable.stacks = 1
    modifierTable.max_stacks = self.max_stacks-- +1 to make it 50 idk why its 49 from 5/0.1 and still 49 after +1
    GameMode:ApplyStackingBuff(modifierTable)
end

function modifier_ursa_jelly_channel:OnDestroy()
    if IsServer() then
        local caster = self:GetParent()
        caster:RemoveGesture(ACT_DOTA_IDLE_RARE)
        Units:ForceStatsCalculation(caster)
    end
end

function modifier_ursa_jelly_channel:GetDamageReductionBonus()
    return 0.75
end

LinkLuaModifier("modifier_ursa_jelly_channel", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)


modifier_ursa_jelly_buff = class({
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
        return ursa_jelly:GetAbilityTextureName()
    end
})

function modifier_ursa_jelly_buff:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    local channel_time = self.ability:GetSpecialValueFor("channel_time")
    local max_health = self:GetParent():GetMaxHealth()
    local tick = self.ability:GetSpecialValueFor("tick")
    self.dmg_reduction = self.ability:GetSpecialValueFor("dmg_reduction") * 0.01 * (self:GetStackCount()+1) * tick /(channel_time)
    self.regen = (self.ability:GetSpecialValueFor("regen") * 0.01 * (self:GetStackCount())* tick /(channel_time) * max_health) + 1
end

function modifier_ursa_jelly_buff:OnRefresh(keys)
    if not IsServer() then
        return
    end
    self:OnCreated()
end

function modifier_ursa_jelly_buff:GetDamageReductionBonus()
    return self.dmg_reduction
end

function modifier_ursa_jelly_buff:GetHealthRegenerationBonus()
    return self.regen
end


LinkLuaModifier("modifier_ursa_jelly_buff", "creeps/zone1/boss/ursa.lua", LUA_MODIFIER_MOTION_NONE)

-- ursa_jelly
ursa_jelly = class({
    GetAbilityTextureName = function(self)
        return "ursa_jelly"
    end,
    GetChannelTime = function(self)
        return self:GetSpecialValueFor("channel_time")
    end
})

function ursa_jelly:IsRequireCastbar()
    return true
end

function ursa_jelly:OnSpellStart(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        caster.ursa_jelly_modifier = caster:AddNewModifier(caster, self, "modifier_ursa_jelly_channel", { Duration = -1 })
        Timers:CreateTimer(0.9, function()
            if (caster:HasModifier("modifier_ursa_jelly_channel")) then
                caster:StartGesture(ACT_DOTA_IDLE_RARE)
                local pidx = ParticleManager:CreateParticle("particles/econ/wards/smeevil/smeevil_ward/smeevil_ward_yellow_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
                Timers:CreateTimer(2.0, function()
                    ParticleManager:DestroyParticle(pidx, false)
                    ParticleManager:ReleaseParticleIndex(pidx)
                end)
                return 1
            end
        end)
        --sound tasting
        local i = math.random(2)
        if i==1 then
            caster:EmitSound("ursa_ursa_lasthit_0"..math.random(1,2))
        else
            caster:EmitSound("ursa_ursa_levelup_07")
        end
    end
end

function ursa_jelly:OnChannelFinish()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    if (caster.ursa_jelly_modifier ~= nil) then
        caster.ursa_jelly_modifier:Destroy()
    end
    --sound eating
    caster:EmitSound("ursa_ursa_lasthit_08")
end

-- Internal stuff

if (IsServer() and not GameMode.ZONE1_BOSS_URSA) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_ursa_rend, 'OnTakeDamage'))
    GameMode.ZONE1_BOSS_URSA= true
end