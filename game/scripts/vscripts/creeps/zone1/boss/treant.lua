
---------------------
-- treant hook
---------------------
modifier_treant_hook_motion = class({
    IsDebuff = function(self)
        return true
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
    GetMotionControllerPriority = function(self)
        return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM
    end,
})

function modifier_treant_hook_motion:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
    return state
end

function modifier_treant_hook_motion:OnCreated()
    if IsServer() then
        local ability = self:GetAbility()
        --local ability_level = ability:GetLevel() - 1
        self.ability = ability
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        self.start_location = self.parent:GetAbsOrigin()
        self.dash_speed = ability:GetSpecialValueFor("projectile_speed")
        self.dash_range = ability:GetSpecialValueFor("range")
        self.stun = ability:GetSpecialValueFor("stun")
        self.taunt = ability:GetSpecialValueFor("taunt")
        self.parent:StartGesture(ACT_DOTA_FLAIL)
        if (self:ApplyHorizontalMotionController() == false) then
            self:Destroy()
        end
    end
end

function modifier_treant_hook_motion:OnDestroy()
    if IsServer() then
        self.parent:RemoveHorizontalMotionController(self)
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.caster = self.caster
        modifierTable.target = self.parent
        modifierTable.modifier_name = "modifier_stunned"
        modifierTable.duration = self.stun
        GameMode:ApplyDebuff(modifierTable)
        modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.caster = self.caster
        modifierTable.target = self.parent
        modifierTable.modifier_name = "modifier_treant_hook_taunt"
        modifierTable.duration = self.taunt
        GameMode:ApplyDebuff(modifierTable)
        self.parent:RemoveGesture(ACT_DOTA_FLAIL)
    end
end

function modifier_treant_hook_motion:OnHorizontalMotionInterrupted()
    if IsServer() then
        self:Destroy()
        Timers:CreateTimer(0.3, function()
            FindClearSpaceForUnit(self.parent, self.expected_location, true)
        end)
    end
end

function modifier_treant_hook_motion:UpdateHorizontalMotion(me, dt)
    if (IsServer()) then
        local caster_location = self.caster:GetAbsOrigin()
        local current_location = self.parent:GetAbsOrigin()
        self.expected_location = current_location + self.parent:GetForwardVector() * self.dash_speed * dt
        --local isTraversable = GridNav:IsTraversable(expected_location)
        --local isBlocked = GridNav:IsBlocked(expected_location)
        --local isTreeNearby = GridNav:IsNearbyTree(expected_location, self.parent:GetHullRadius(), true)
        local traveled_distance = DistanceBetweenVectors(current_location, self.start_location)
        local distance_to_caster = DistanceBetweenVectors(current_location, caster_location)
        if (traveled_distance < self.dash_range and distance_to_caster > 200 ) then --and not distance_to_caster< 250 --isTraversable and not isBlocked and not isTreeNearby and t
            self.parent:SetAbsOrigin(self.expected_location)
            self.parent:EmitSound("Hero_DarkWillow.Bramble.Spawn")--vine spawn sound
            local vine = "particles/units/heroes/hero_treant/treant_bramble_root.vpcf"
            local pidx = ParticleManager:CreateParticle(vine, PATTACH_ABSORIGIN, self.parent)
            Timers:CreateTimer(2, function()
                ParticleManager:DestroyParticle(pidx, false)
                ParticleManager:ReleaseParticleIndex(pidx)
            end)
        else
            self:Destroy()
        end
    end
end
LinkLuaModifier("modifier_treant_hook_motion", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_HORIZONTAL)


modifier_treant_hook_taunt = class({
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
    end
})

function modifier_treant_hook_taunt:IsTaunt()
    return true
end

function modifier_treant_hook_taunt:GetEffectName()
    return "particles/items2_fx/urn_of_shadows_damage.vpcf"
end

LinkLuaModifier("modifier_treant_hook_taunt", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_NONE)

treant_hook = class({
    GetAbilityTextureName = function(self)
        return "treant_hook"
    end,
})

function treant_hook:FindTargetForHook(caster)
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
        local hookTarget = nil
        local casterPos = caster:GetAbsOrigin()
        for _, enemy in pairs(enemies) do
            -- find the farthest hero from the heroes in range
            distanceToBoss = (casterPos - enemy:GetAbsOrigin()):Length()
            if distanceToBoss >= latestDistance then
                -- if new distance to boss higher than the max one replace the farthest hero
                hookTarget = enemy
                latestDistance = distanceToBoss
            end
        end
        if (#enemies > 0) then
            return hookTarget
        else
            return nil
        end
    end
end

function treant_hook:OnSpellStart()
    if IsServer() then
        -- Ability properties
        local caster = self:GetCaster()
        -- Ability specials
        local projectile_speed = self:GetSpecialValueFor("projectile_speed")
        self.radius = self:GetSpecialValueFor("range")
        local target = self:FindTargetForHook(caster)
        local vine_dummy = CreateModifierThinker(self:GetCaster(), self, nil, {}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
        vine_dummy:EmitSoundParams("Hero_DarkWillow.Bramble.Spawn",1.0, 0.7, 0)

        local info =
        {
            Target = target,
            Source = caster,
            Ability = self,
            EffectName = nil,
            iMoveSpeed = projectile_speed,
            vSourceLoc= caster:GetAbsOrigin(),                -- Optional (HOW)
            bDrawsOnMinimap = false,                          -- Optional
            bDodgeable = true,                                -- Optional
            bIsAttack = false,                                -- Optional
            bVisibleToEnemies = true,                         -- Optional
            bReplaceExisting = false,                         -- Optional
            flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
            bProvidesVision = true,                           -- Optional
            iVisionRadius = 400,                              -- Optional
            iVisionTeamNumber = caster:GetTeamNumber(),        -- Optional
            ExtraData			=
            {
                vine_dummy	= vine_dummy:entindex(),
            }
        }
        projectile = ProjectileManager:CreateTrackingProjectile(info)
        caster:EmitSound("Hero_Treant.NaturesGrasp.Cast") --casting sound
    end
end

-- Make the travel sound follow the vine
function treant_hook:OnProjectileThink_ExtraData(location, data)
    if not IsServer() then return end
    if data.vine_dummy then
        EntIndexToHScript(data.vine_dummy):SetAbsOrigin(location)
        local vine = "particles/units/heroes/hero_treant/treant_bramble_root.vpcf"
        local pidx = ParticleManager:CreateParticle(vine, PATTACH_ABSORIGIN, EntIndexToHScript(data.vine_dummy))
        Timers:CreateTimer(2, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
    end
end


function treant_hook:OnProjectileHit(target,data)
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    if target and caster:IsAlive() then
        local vector = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized()
        local damageTable = {}
        damageTable.ability = self
        damageTable.caster = caster
        damageTable.target = target
        damageTable.damage = damage
        damageTable.naturedmg = true
        GameMode:DamageUnit(damageTable)
        target:SetForwardVector(vector)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.caster = caster
        modifierTable.target = target
        modifierTable.modifier_name = "modifier_treant_hook_motion"
        modifierTable.duration = 3
        GameMode:ApplyDebuff(modifierTable)

        caster:EmitSound("treant_treant_attack_09") --come here
    elseif data.vine_dummy then
        EntIndexToHScript(data.vine_dummy):RemoveSelf() --this is UTIL remove
    end
end

----------------
-- treant flux
----------------
--flux source buff on treant
modifier_treant_flux_eye = class({
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

function modifier_treant_flux_eye:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.damage = self.ability:GetSpecialValueFor("damage")
    self.radius = self.ability:GetSpecialValueFor("radius")
    self.slow = self.ability:GetSpecialValueFor("self_ms_slow") * -0.01
    --gather particle
    Timers:CreateTimer(2.5, function()
        self.parent:EmitSound("Hero_Oracle.FortunesEnd.Channel")
        self.ppfx = ParticleManager:CreateParticle("particles/units/npc_boss_treant/treant_flux/flux_gather.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
        Timers:CreateTimer(1.5, function()
            ParticleManager:DestroyParticle(self.ppfx, false)
            ParticleManager:ReleaseParticleIndex(self.ppfx)
        end)
    end)
    self:StartIntervalThink(4.0)
end

function modifier_treant_flux_eye:GetMoveSpeedPercentBonus()
    return self.slow
end

function modifier_treant_flux_eye:OnIntervalThink()  --StartIntervalThink will only be called on server, so OnIntervalThink method doesn't have to call IsServer again.
    -- damage
    local counter = 0
    Timers:CreateTimer(0, function()
        if counter < 10 and self.parent:IsAlive() then
            local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(),
            self.parent:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
            for _, enemy in pairs(enemies) do
            local damageTable = {}
            damageTable.caster = self.parent
            damageTable.target = enemy
            damageTable.ability = self.ability
            damageTable.damage = self.damage
            damageTable.puredmg = true
            GameMode:DamageUnit(damageTable)
            end
            counter = counter +1
            return 0.1
        end
    end)
    --particle on explosion
    self.pfx = ParticleManager:CreateParticle("particles/units/npc_boss_treant/treant_flux/flux_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.pfx, 2, Vector(self.radius, 0, 0))
    self.parent:EmitSound("Hero_Oracle.FortunesEnd.Attack")
    Timers:CreateTimer(1.5, function()
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
    end)
    Timers:CreateTimer(2.5, function()
        self.parent:EmitSound("Hero_Oracle.FortunesEnd.Channel")
        self.ppfx = ParticleManager:CreateParticle("particles/units/npc_boss_treant/treant_flux/flux_gather.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
        Timers:CreateTimer(1.5, function()
            ParticleManager:DestroyParticle(self.ppfx, false)
            ParticleManager:ReleaseParticleIndex(self.ppfx)
        end)
    end)
end

-- treant flux generate additional flux on damage
---@param damageTable DAMAGE_TABLE
function modifier_treant_flux_eye:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_treant_flux_eye")
    if (damageTable.damage > 0 and modifier and damageTable.ability and damageTable.puredmg == true and damageTable.attacker:IsAlive() ) then
        local modifierTable = {}
        modifierTable.ability = modifier:GetAbility()
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_treant_flux_eye_enemy"
        modifierTable.duration = 1.5
        modifierTable.modifier_params = {attacker = damageTable.attacker:GetEntityIndex()}
        GameMode:ApplyDebuff(modifierTable)
    end
end

LinkLuaModifier("modifier_treant_flux_eye", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_NONE)

--flux source debuff on enemy
modifier_treant_flux_eye_enemy = class({
    IsDebuff = function(self)
        return true
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
})

--deal damage to his allies around himself
function modifier_treant_flux_eye_enemy:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    if (not keys or not keys.attacker) then
        self:Destroy()
    end
    self.parent = self:GetParent()
    self.parent:EmitSound("Hero_Oracle.FortunesEnd.Target")
    keys.attacker = EntIndexToHScript(keys.attacker)
    local modifier = keys.attacker:FindModifierByName("modifier_treant_flux_eye")
    self.ability = modifier:GetAbility()
    self.damage = modifier:GetAbility():GetSpecialValueFor("damage")
    self.radius = modifier:GetAbility():GetSpecialValueFor("radius")

    --explode immediately
    local counter = 0
    Timers:CreateTimer(0, function()
        if counter < 10 then
            local allies = FindUnitsInRadius(self.parent:GetTeamNumber(),
                    self.parent:GetAbsOrigin(),
                    nil,
                    self.radius,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            for _, ally in pairs(allies) do
                --flux wont damage flux source
                if ally ~= self.parent then
                    local damageTable = {}
                    damageTable.caster = keys.attacker
                    damageTable.target = ally
                    damageTable.ability = self.ability
                    damageTable.damage = self.damage
                    damageTable.puredmg = true
                    GameMode:DamageUnit(damageTable)
                end
            end
            counter = counter +1
            return 0.1
        end
    end)
    --particle on explosion
    self.pfx = ParticleManager:CreateParticle("particles/units/npc_boss_treant/treant_flux/flux_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.pfx, 2, Vector(self.radius, 0, 0))
    Timers:CreateTimer(1.5, function()
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
    end)
end
LinkLuaModifier("modifier_treant_flux_eye_enemy", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_NONE)

treant_flux = class({
    GetAbilityTextureName = function(self)
        return "treant_flux"
    end,
})

function treant_flux:OnSpellStart()
    if IsServer() then
        local duration = self:GetSpecialValueFor("total_time")
        self.caster = self:GetCaster()
        --apply buff
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.caster
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_treant_flux_eye"
        modifierTable.duration = duration + 1
        GameMode:ApplyBuff(modifierTable)
        self.caster:EmitSound("treant_treant_move_07")
    end
end

---------------------
-- treant storm
---------------------
--eye of leaf storm modifier on treant
modifier_treant_storm_eye = class({
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
    GetEffectName = function(self)
        return "particles/units/npc_boss_treant/treant_storm/wind.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end
})

function modifier_treant_storm_eye:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.base_damage = self.ability:GetSpecialValueFor("min_damage")
    self.increment = self.ability:GetSpecialValueFor("increment_damage")
    self.min_damage_range = self.ability:GetSpecialValueFor("min_damage_range")
    self.range = self.ability:GetSpecialValueFor("range")
    --local duration = self.ability:GetSpecialValueFor("duration") --5
    self.tick = self.ability:GetSpecialValueFor("tick")
    self.parent:EmitSound("Ability.Windrun")
    self:StartIntervalThink(self.tick)
end

function modifier_treant_storm_eye:OnIntervalThink()
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
            local distance = vector:Length2D()
            if distance < self.min_damage_range then
                distance = self.min_damage_range end
            local damage = (self.base_damage + self.increment * (distance - self.min_damage_range)) * self.tick
            local damageTable = {}
            damageTable.caster = self.parent
            damageTable.target = enemy
            damageTable.ability = self.ability
            damageTable.damage = damage
            damageTable.naturedmg = true
            GameMode:DamageUnit(damageTable)
            --particle on hit
            self.pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_tiny/tiny_grow_cleave.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
            Timers:CreateTimer(1.0, function()
                ParticleManager:DestroyParticle(self.pfx, false)
                ParticleManager:ReleaseParticleIndex(self.pfx)
            end)
            enemy:EmitSound("Hero_Furion.TreantFootsteps")
        end
    end
end

LinkLuaModifier("modifier_treant_storm_eye", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_NONE)

treant_storm = class({
    GetAbilityTextureName = function(self)
        return "treant_storm"
    end,
})

function treant_storm:OnSpellStart()
    if IsServer() then
        local duration = self:GetSpecialValueFor("duration")
        self.caster = self:GetCaster()
        --apply buff
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.caster
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_treant_storm_eye"
        modifierTable.duration = duration
        GameMode:ApplyBuff(modifierTable)
        self.caster:EmitSound("treant_treant_ability_naturesguise_04")
    end
end


----------------
-- treant_seed
---------------
--debuff
modifier_treant_seed = class({
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

})

function modifier_treant_seed:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.interval = self:GetAbility():GetSpecialValueFor("tick")
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    self.slow = self:GetAbility():GetSpecialValueFor("slow")*-0.01
    self.slowmulti = self.slow + 1
    self.mana_drain = self:GetAbility():GetSpecialValueFor("mana_drain")*0.01
    self:StartIntervalThink(self.interval)
end

function modifier_treant_seed:GetAttackSpeedPercentBonusMulti()
    return self.slowmulti
end

function modifier_treant_seed:GetMoveSpeedPercentBonusMulti()
    return self.slowmulti
end

function modifier_treant_seed:GetSpellHastePercentBonusMulti()
    return self.slowmulti
end

function modifier_treant_seed:OnIntervalThink()
    if self.caster:IsAlive() then
        --damage
        local damageTable= {}
        damageTable.caster = self.caster
        damageTable.target = self.parent
        damageTable.ability = self.ability
        damageTable.damage = self.damage
        damageTable.naturedmg = true
        GameMode:DamageUnit(damageTable)
        self.parent:EmitSound("Hero_Treant.LeechSeed.Tick ")
        --mana drain
        local Max_mana = self.parent:GetMaxMana()
        local burn = Max_mana * self.mana_drain
        self.parent:ReduceMana(burn)
        --particle
        self.damage_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_leech_seed_damage_pulse.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
        ParticleManager:ReleaseParticleIndex(self.damage_particle)
        self.damage_particle = nil
    end
end

LinkLuaModifier("modifier_treant_seed", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_NONE)

--active
treant_seed = class({
    GetAbilityTextureName = function(self)
        return "treant_seed"
    end,
})

function treant_seed:FindTargetForSeed(caster)
    -- Find all nearby enemies
    if IsServer() then
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                self.range,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        local distanceToBoss = 0
        local latestDistance = 0
        local seedTarget = nil
        local casterPos = caster:GetAbsOrigin()
        for _, enemy in pairs(enemies) do
            if (not TableContains(self.already_hit, enemy)) then
                -- find the farthest hero from the heroes in range but are not already hit
                distanceToBoss = (casterPos - enemy:GetAbsOrigin()):Length()
                if distanceToBoss >= latestDistance then
                    -- if new distance to boss higher than the max one replace the farthest hero
                    seedTarget = enemy
                    latestDistance = distanceToBoss
                end
            end
        end
        if (#enemies > 0) then
            table.insert(self.already_hit, seedTarget)
            return seedTarget
        else
            return nil
        end
    end
end


function treant_seed:Seed(target)
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
    modifierTable.modifier_name = "modifier_treant_seed"
    modifierTable.duration = self.duration
    GameMode:ApplyDebuff(modifierTable)
    target:EmitSound("Hero_Treant.LeechSeed.Target")
end

function treant_seed:OnSpellStart()
    if (not IsServer()) then
        return
    end
    self.range = self:GetSpecialValueFor("range")
    self.caster = self:GetCaster()
    local number = self:GetSpecialValueFor("number")
    self.duration = self:GetSpecialValueFor("duration")
    local counter = 0
    local target
    self.already_hit = {}
    self.caster:EmitSound("Hero_Treant.LeechSeed.Cast")
    Timers:CreateTimer(0, function()
        if counter < number then
            target = self:FindTargetForSeed(self.caster)
            self:Seed(target)
            counter = counter + 1
            return 0.1
        end
    end)
    self.caster:EmitSound("treant_treant_ability_leechseed_0"..math.random(1,6))
    local seed_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_leech_seed.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(seed_particle, 1, self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack1")))
end

---------------------
-- treant one
---------------------
treant_one = class({
    GetAbilityTextureName = function(self)
        return "treant_one"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_treant_one"
    end,
})

function treant_one:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.chance = self:GetSpecialValueFor("chance")
    self.duration = self:GetSpecialValueFor("duration")
end

modifier_treant_one = class({
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
})

function modifier_treant_one:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

-- root retaliation
---@param damageTable DAMAGE_TABLE
function modifier_treant_one:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_treant_one")
    local rootmod = damageTable.attacker:FindModifierByName("modifier_treant_one_root")
    local rootimmunity = damageTable.attacker:FindModifierByName("modifier_treant_one_immunity")
    if (damageTable.damage > 0 and damageTable.victim:IsAlive() and rootmod == nil and rootimmunity ==nil and modifier and RollPercentage(modifier:GetAbility():GetSpecialValueFor("chance"))) then
        local modifierTable = {}
        modifierTable.ability = modifier:GetAbility()
        modifierTable.target = damageTable.attacker
        modifierTable.caster = damageTable.victim
        modifierTable.modifier_name = "modifier_treant_one_root"
        modifierTable.duration = modifier:GetAbility():GetSpecialValueFor("duration")
        modifierTable.modifier_params = {caster = damageTable.victim:GetEntityIndex()}
        GameMode:ApplyDebuff(modifierTable)
        modifierTable = {}
        modifierTable.ability = modifier:GetAbility()
        modifierTable.target = damageTable.attacker
        modifierTable.caster = damageTable.victim
        modifierTable.modifier_name = "modifier_treant_one_immunity"
        modifierTable.duration = 10
        GameMode:ApplyDebuff(modifierTable)
    elseif (damageTable.damage > 0 and modifier and rootmod ~= nil and damageTable.victim:IsAlive() and RollPercentage(modifier:GetAbility():GetSpecialValueFor("chance"))) then
        -- Find all nearby enemies
        local alreadyroot = 0
        local enemies = FindUnitsInRadius(damageTable.attacker:GetTeamNumber(),
                damageTable.victim:GetAbsOrigin(),
                nil,
                modifier:GetAbility():GetSpecialValueFor("range"),
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        if (#enemies > 0) then
            for i=1,#enemies,1 do
                local rootTarget = enemies[i]
                if not rootTarget:HasModifier("modifier_treant_one_immunity") and alreadyroot == 0 then
                    local modifierTable = {}
                    modifierTable.ability = modifier:GetAbility()
                    modifierTable.target = rootTarget
                    modifierTable.caster = damageTable.victim
                    modifierTable.modifier_name = "modifier_treant_one_root"
                    modifierTable.duration = modifier:GetAbility():GetSpecialValueFor("duration")
                    modifierTable.modifier_params = {caster = damageTable.victim:GetEntityIndex()}
                    GameMode:ApplyDebuff(modifierTable)
                    modifierTable = {}
                    modifierTable.ability = modifier:GetAbility()
                    modifierTable.target = rootTarget
                    modifierTable.caster = damageTable.victim
                    modifierTable.modifier_name = "modifier_treant_one_immunity"
                    modifierTable.duration = 10
                    GameMode:ApplyDebuff(modifierTable)
                    alreadyroot = 1
                end
            end
        else
            return
        end
    end
end

LinkLuaModifier("modifier_treant_one", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_NONE)

modifier_treant_one_root = class({
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

function modifier_treant_one_root:OnCreated(keys)
    if not IsServer() then
        return
    end
    if (not keys or not keys.caster) then
        self:Destroy()
    end
    self.caster = EntIndexToHScript(keys.caster)
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.dot = self:GetAbility():GetSpecialValueFor("dot")
    self.tick = self:GetAbility():GetSpecialValueFor("tick")
    self:StartIntervalThink(self.tick)
    self.parent:EmitSound("Hero_Treant.Overgrowth.Cast")
end

function modifier_treant_one_root:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }
    return state
end

function modifier_treant_one_root:OnIntervalThink()
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
        treant:AddNewModifier(self.caster, self.ability, "modifier_treant_one_ignore_aggro_buff", { duration = -1, target = self.parent})
        treant:EmitSound("Hero_Furion.TreantSpawn")
    end
end

LinkLuaModifier("modifier_treant_one_root", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_NONE)

modifier_treant_one_immunity = class({
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
})

LinkLuaModifier("modifier_treant_one_immunity", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_NONE)

modifier_treant_one_ignore_aggro_buff = class({
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

function modifier_treant_one_ignore_aggro_buff:OnCreated(keys)
    if not IsServer() then
        return
    end
    if (not keys or keys.target) then
        self:Destroy()
    end
    self.target = keys.target
end

function modifier_treant_one_ignore_aggro_buff:GetIgnoreAggroTarget()
    return self.target
end

LinkLuaModifier("modifier_treant_one_ignore_aggro_buff", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_NONE)

---------------------
-- treant ingrain
---------------------
treant_ingrain = class({
    GetAbilityTextureName = function(self)
        return "treant_ingrain"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_treant_ingrain"
    end,
})

--function treant_ingrain:OnUpgrade()
    --if (not IsServer()) then
        --return
    --end
    --self.dmg_reduction = self:GetSpecialValueFor("dmg_reduction")
    --self.regen = self:GetSpecialValueFor("regen")
    --self.as_reduce = self:GetSpecialValueFor("as_reduce")
--end

modifier_treant_ingrain = class({
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

function modifier_treant_ingrain:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.parent_loc_old = self:GetParent():GetAbsOrigin()
    local Max_Health = self.parent:GetMaxHealth()
    self.regen_final = Max_Health * self.ability:GetSpecialValueFor("regen") * 0.01  + 1 --idk why need +1 when +1 print get +6 but on ui+5 = correct for 0.5%*1000
    self.dmg_reduction_final = self.ability:GetSpecialValueFor("dmg_reduction") * 0.01
    self.as_reduce_final = self.ability:GetSpecialValueFor("as_reduce") * -0.01
    self.active = true
    self:StartIntervalThink(0.1)

end

function modifier_treant_ingrain:OnIntervalThink()
    self.parent_loc_new = self:GetParent():GetAbsOrigin()
    local vector = self.parent_loc_new - self.parent_loc_old
    local distance = vector:Length2D()
    if distance == 0 then
        self.active = true
        --tried to set particle that get destroyed every 0.1s but it stacks up and looks ugly
        local armor = "particles/units/heroes/hero_treant/treant_livingarmor.vpcf"
        local healFX = ParticleManager:CreateParticle(armor, PATTACH_ABSORIGIN_FOLLOW, self.parent)
        ParticleManager:SetParticleControlEnt(healFX, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
        self:AddParticle(healFX, false, false, -1, false, false)
        Timers:CreateTimer(0.1, function()
            ParticleManager:DestroyParticle(healFX, false)
            ParticleManager:ReleaseParticleIndex(healFX)
        end)
    else
        self.active = false
    end
    self.parent_loc_old = self.parent_loc_new
end

function modifier_treant_ingrain:GetDamageReductionBonus()
    if IsServer() then
    if self.active == true then
    return self.dmg_reduction_final
    else return 0
    end end
end

function modifier_treant_ingrain:GetHealthRegenerationBonus()
    if IsServer() then
    if self.active == true then
        return self.regen_final
    else return 0
    end end
end

function modifier_treant_ingrain:GetAttackSpeedPercentBonus()
    if IsServer() then
    if self.active == true then
        return self.as_reduce_final
    else return 0
    end end
end

LinkLuaModifier("modifier_treant_ingrain", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_NONE)

---------------------
-- treant_regrowth
---------------------
-- treant_regrowth modifiers
modifier_treant_regrowth_channel = class({
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

function modifier_treant_regrowth_channel:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    if self.ability then
        self.caster = self:GetParent()
        self.channel_time = self.ability:GetSpecialValueFor("channel_time")
        self.health_heal_pct = self.ability:GetSpecialValueFor("health_heal_pct") * 0.01
        self.tick = self.ability:GetSpecialValueFor("tick")
        self.max_stacks = math.floor(self.channel_time/ self.tick) + 1 --29.999999254942 to be exact so need +1

        self:StartIntervalThink(self.tick)
        self:OnIntervalThink()
    else
        self:Destroy()
    end
end

--gain 1 stack heal every 0.1s channel total of 30 stacks
function modifier_treant_regrowth_channel:OnIntervalThink()
    local healTable = {}
    healTable.caster = self.caster
    healTable.target = self.caster
    healTable.ability = self.ability
    healTable.heal = self.caster:GetMaxHealth() * self.health_heal_pct /self.max_stacks
    GameMode:HealUnit(healTable)
end

function modifier_treant_regrowth_channel:OnDestroy()
    if IsServer() then
        local caster = self:GetParent()
        caster:RemoveGesture(ACT_DOTA_TELEPORT)
    end
end

LinkLuaModifier("modifier_treant_regrowth_channel", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_NONE)

-- treant_regrowth
treant_regrowth = class({
    GetAbilityTextureName = function(self)
        return "treant_regrowth"
    end,
    GetChannelTime = function(self)
        return self:GetSpecialValueFor("channel_time")
    end
})

function treant_regrowth:IsRequireCastbar()
    return true
end

function treant_regrowth:OnSpellStart(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        caster.treant_regrowth_modifier = caster:AddNewModifier(caster, self, "modifier_treant_regrowth_channel", { Duration = -1 })
        caster:EmitSound("Hero_Furion.Teleport_Grow")
        caster:StartGesture(ACT_DOTA_TELEPORT)
        Timers:CreateTimer(0.9, function()
            if (caster:HasModifier("modifier_treant_regrowth_channel")) then
                caster:StartGesture(ACT_DOTA_TELEPORT)
                return 1
            end
        end)
    end
end

function treant_regrowth:OnChannelFinish()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    if (caster.treant_regrowth_modifier ~= nil) then
        caster.treant_regrowth_modifier:Destroy()
    end
    caster:EmitSound("Hero_Furion.Teleport_Appear")
end

----------------
-- treant_beam
----------------

-- ability class
treant_beam = class({
    GetAbilityTextureName = function(self)
        return "treant_beam"
    end,
})

function treant_beam:IsRequireCastbar()
    return true
end

function treant_beam:IsInterruptible()
    return false
end


function treant_beam:OnAbilityPhaseStart()
    if IsServer() then
        local caster = self:GetCaster()
        -- Particle and play cast sound try to match delay
        Timers:CreateTimer(1.0, function()
            local gather_fx = "particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_channel_ti6.vpcf"
            local charge = ParticleManager:CreateParticle(gather_fx,PATTACH_ABSORIGIN, caster)
            ParticleManager:SetParticleControlEnt(charge, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(charge, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
            Timers:CreateTimer(1.0, function()
                ParticleManager:DestroyParticle(charge, false)
                ParticleManager:ReleaseParticleIndex(charge)
            end)
        end)
        Timers:CreateTimer(0.3, function()
            caster:EmitSound("Hero_Invoker.SunStrike.Charge")
            local sun = "particles/units/npc_boss_treant/treant_beam/sun_charge.vpcf"
            local charge2 = ParticleManager:CreateParticle(sun,PATTACH_POINT, caster)
            ParticleManager:SetParticleControl(charge2, 0, caster:GetAbsOrigin())
            ParticleManager:SetParticleControl(charge2, 1, Vector(175,0, 0))
            Timers:CreateTimer(1.7, function()
                ParticleManager:DestroyParticle(charge2, false)
                ParticleManager:ReleaseParticleIndex(charge2)
            end)
        end)
    end
    return true
end



function treant_beam:OnSpellStart()
    if IsServer() then
        -- Ability properties
        local caster = self:GetCaster()
        local caster_loc = caster:GetAbsOrigin()
        -- Ability specials
        local travel_distance = self:GetSpecialValueFor("travel_distance")
        local start_radius = self:GetSpecialValueFor("start_radius")
        local end_radius = self:GetSpecialValueFor("end_radius")
        local projectile_speed = self:GetSpecialValueFor("projectile_speed")
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
        for _, enemy in pairs(enemies) do
            --particle
            self.beam_particle = "particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_ti6.vpcf"
            local enemy_loc = enemy:GetAbsOrigin()
            local distance = enemy_loc - caster_loc
            local direction = distance:Normalized()
            local projectile =
            {
                Ability				= self,
                EffectName			= self.beam_particle,
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
                --ExtraData			= {damage = damage, stun = stun}
            }
            caster:EmitSound("Hero_Furion.WrathOfNature_Damage")
            ProjectileManager:CreateLinearProjectile(projectile)
        end
    end
end

function treant_beam:OnProjectileHit_ExtraData(target)
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    if target and caster:IsAlive()then
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.naturedmg = true
        damageTable.firedmg = true
        GameMode:DamageUnit(damageTable)
    end
end

------------------
--treant entangling root --for lesser treant
------------------

modifier_treant_root = class({
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

function modifier_treant_root:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_treant_root:OnAttackLanded(keys)
    --start cd
    if not IsServer() then
        return
    end
    if (keys.attacker == self.parent) then
        self.ability:ApplyRoot(keys.target, self.parent)
    end
end

LinkLuaModifier("modifier_treant_root", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_NONE)

modifier_treant_root_debuff = class({
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
        return "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle_body.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN
    end,
})

function modifier_treant_root_debuff:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_treant_root_debuff:OnRefresh()
    self:OnCreated()
end

function modifier_treant_root_debuff:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }
    return state
end

LinkLuaModifier("modifier_treant_root_debuff", "creeps/zone1/boss/treant.lua", LUA_MODIFIER_MOTION_NONE)

treant_root = class({
    GetAbilityTextureName = function(self)
        return "treant_root"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_treant_root"
    end,
})

function treant_root:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.duration = self:GetSpecialValueFor("duration")
end

function treant_root:ApplyRoot(target, parent)
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_treant_root_debuff"
    modifierTable.duration = self.duration
    GameMode:ApplyDebuff(modifierTable)
end

--internal stuff
if (IsServer() and not GameMode.ZONE1_BOSS_TREANT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_treant_flux_eye, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_treant_one, 'OnTakeDamage'))
    GameMode.ZONE1_BOSS_TREANT = true
end