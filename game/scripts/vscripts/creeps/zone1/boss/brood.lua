---------------
--HELPER FUNCTION
-----------------
function IsSpiderling(unit)
    if unit:GetUnitName() == "npc_boss_brood_spiderling" then
        return true
    else
        return false
    end
end

function IsMother(unit)
    if unit:GetUnitName() == "npc_boss_brood" then
        return true
    else
        return false
    end
end

function IsToxinStunned(unit)
    if unit:HasModifier("modifier_brood_toxin_stunned") then
        return true
    else
        return false
    end
end

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

function brood_toxin:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.duration = self:GetSpecialValueFor("duration")
    self.max_stacks = self:GetSpecialValueFor("max_stacks")
end

function brood_toxin:ApplyToxin(target, parent)
    if (not IsServer()) then
        return
    end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_brood_toxin_slow"
    modifierTable.duration = self.duration
    modifierTable.stacks = 1
    modifierTable.max_stacks = self.max_stacks
    GameMode:ApplyStackingDebuff(modifierTable)
end

modifier_brood_toxin = class({
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

function modifier_brood_toxin:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_brood_toxin:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    --local immune = keys.target:FindModifierByName("modifier_brood_toxin_immunity")
    local stun = keys.target:FindModifierByName("modifier_brood_toxin_stunned")
    --check oneshot
    if (keys.attacker:HasModifier("modifier_brood_comes_mother") and keys.attacker == self.parent and stun ~= nil and IsSpiderling(keys.attacker) == false and IsMother(keys.attacker) == true) then
        --taunting
        self.parent:EmitSound("broodmother_broo_ability_incap_0"..math.random(2,4))
        local death = "particles/econ/items/terrorblade/terrorblade_horns_arcana/terrorblade_arcana_enemy_death.vpcf"
        local particle_cast_fx = ParticleManager:CreateParticle(death, PATTACH_ABSORIGIN, keys.target)
        ParticleManager:SetParticleControlEnt(particle_cast_fx, 0, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle_cast_fx, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), true)
        Timers:CreateTimer(5.0, function()
            ParticleManager:DestroyParticle(particle_cast_fx, false)
            ParticleManager:ReleaseParticleIndex(particle_cast_fx)
        end)
        keys.target:ForceKill(false)
        --apply stack
    elseif (keys.attacker == self.parent and stun == nil) then
        --and immune == nil
        self.ability:ApplyToxin(keys.target, self.parent)
        local particle_cast_fx = ParticleManager:CreateParticle("particles/units/npc_boss_brood/brood_toxin/brood_toxin.vpcf", PATTACH_ABSORIGIN, keys.target)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(particle_cast_fx, false)
            ParticleManager:ReleaseParticleIndex(particle_cast_fx)
        end)
    end
end

-- brood spit damage instance apply spider toxin
---@param damageTable DAMAGE_TABLE
function modifier_brood_toxin:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_brood_toxin")
    if (damageTable.damage > 0 and modifier and damageTable.ability and damageTable.naturedmg == true) and damageTable.attacker:IsAlive() then
        local slowmod = damageTable.victim:FindModifierByName("modifier_brood_toxin_slow")
        local stunmod = damageTable.victim:FindModifierByName("modifier_brood_toxin_stunned")
        --if no stun and (no toxin slow or lower than max stack) add stack
        if (slowmod == nil or (slowmod:GetStackCount() < modifier:GetAbility():GetSpecialValueFor("max_stacks"))) and stunmod ==nil then
            local modifierTable = {}
            modifierTable.ability = modifier:GetAbility()
            modifierTable.target = damageTable.victim
            modifierTable.caster = damageTable.attacker
            modifierTable.modifier_name = "modifier_brood_toxin_slow"
            modifierTable.duration = modifier:GetAbility():GetSpecialValueFor("duration")
            modifierTable.stacks = 1
            modifierTable.max_stacks = modifier:GetAbility():GetSpecialValueFor("max_stacks")
            GameMode:ApplyStackingDebuff(modifierTable)
            --if already stun do nothing
        elseif slowmod == nil and stunmod  ~= nil then
            return
            -- if toxin slow max > stun
        elseif slowmod:GetStackCount() == modifier:GetAbility():GetSpecialValueFor("max_stacks") then
            local stun_duration = modifier:GetAbility():GetSpecialValueFor("stun")
            local modifierTable = {}
            modifierTable.ability = modifier:GetAbility()
            modifierTable.target = damageTable.victim
            modifierTable.caster = damageTable.attacker
            modifierTable.modifier_name = "modifier_brood_toxin_stunned"
            modifierTable.duration = stun_duration
            GameMode:ApplyDebuff(modifierTable)
            damageTable.victim:EmitSound("Hero_Slardar.Bash")
            damageTable.victim:FindModifierByName("modifier_brood_toxin_slow"):Destroy()
        end
    end
end

LinkLuaModifier("modifier_brood_toxin", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

modifier_brood_toxin_slow = class({
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
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_poison_venomancer.vpcf"
    end
})

function modifier_brood_toxin_slow:OnCreated()
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.ability = self:GetAbility()
    self.base_slow = self.ability:GetSpecialValueFor("base_slow") * -0.01
    --not fixing +1 in this because it cant get to 21 stacks at 20 stacks it become stun
    self.slow = self.ability:GetSpecialValueFor("stack_slow") * -0.01 * (self:GetStackCount() + 1) + self.base_slow
    self.slowmulti = self.slow + 1
    self.stun = self.ability:GetSpecialValueFor("stun")
    self.max_stacks = self.ability:GetSpecialValueFor("max_stacks")
end

function modifier_brood_toxin_slow:OnRefresh()
    if (not IsServer()) then
        return
    end
    if self:GetStackCount() == self.max_stacks then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.target = self.target
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_brood_toxin_stunned"
        modifierTable.duration = self.stun
        GameMode:ApplyDebuff(modifierTable)
        self.target:EmitSound("Hero_Slardar.Bash")
        self:Destroy()
    else
        self:OnCreated()
    end
end

function modifier_brood_toxin_slow:GetMoveSpeedPercentBonusMulti()
    return self.slowmulti
end

function modifier_brood_toxin_slow:GetAttackSpeedPercentBonusMulti()
    return self.slowmulti
end

function modifier_brood_toxin_slow:GetSpellHastePercentBonusMulti()
    return self.slowmulti
end

LinkLuaModifier("modifier_brood_toxin_slow", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

--special stun for one hit kill check
modifier_brood_toxin_stunned = class({
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
        return "particles/generic_gameplay/generic_stunned.vpcf"
    end,
    GetTexture = function(self)
        return brood_toxin:GetAbilityTextureName()
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_PROVIDES_FOW_POSITION }
    end
})

function modifier_brood_toxin_stunned:OnCreated()
    if not IsServer() then
        return
    end
end

function modifier_brood_toxin_stunned:CheckState()
    return { [MODIFIER_STATE_STUNNED] = true,
             [MODIFIER_STATE_FROZEN] = true, }
end

function modifier_brood_toxin_stunned:GetModifierProvidesFOWVision()
    return 1
end


LinkLuaModifier("modifier_brood_toxin_stunned", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)



---------------------
-- brood comes
---------------------
--mother of spider modifier for toxin, smart mother and angry
modifier_brood_comes_mother = class({
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
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_brood_comes_mother:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.duration = self.ability:GetSpecialValueFor("stack_duration")
    self.max_stacks = self.ability:GetSpecialValueFor("max_stacks")
    self.damage = self.ability:GetSpecialValueFor("self_damage")
    self:StartIntervalThink(1.0)
end

--she won't get block by her babies
function modifier_brood_comes_mother:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
end

--angry stack gain
function modifier_brood_comes_mother:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    if (keys.attacker:HasModifier("modifier_brood_comes_mother") )then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.target = keys.attacker
        modifierTable.caster = keys.attacker
        modifierTable.modifier_name = "modifier_brood_angry_stack"
        modifierTable.duration = self.duration
        modifierTable.stacks = 1
        modifierTable.max_stacks = self.max_stacks
        GameMode:ApplyStackingBuff(modifierTable)
    end
end

--smart mother tries to find enemy to charge in and oneshot
function modifier_brood_comes_mother:OnIntervalThink()
    local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(),
            self.parent:GetAbsOrigin(),
            nil,
            1500,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        -- check if there is a stunned player
        if IsToxinStunned(enemy) == true then
            local modifierTable = {}
            modifierTable.ability = self:GetAbility()
            modifierTable.target = self.parent
            modifierTable.caster = self.parent
            modifierTable.modifier_name = "modifier_brood_comes_charge"
            modifierTable.duration = 5
            modifierTable.modifier_params = { target = enemy }
            GameMode:ApplyBuff(modifierTable)
            self.parent:EmitSound("broodmother_broo_cast_0"..math.random(2,3))
            self.parent:MoveToTargetToAttack(enemy)
            self.parent:PerformAttack(enemy, true, true, true, true, false, false, false)
        end
    end
end

LinkLuaModifier("modifier_brood_comes_mother", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

--random taunt modifier
modifier_brood_comes_random_taunt = class({
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
    GetTextureName = function(self)
        return "brood_comes"
    end,
})

function modifier_brood_comes_random_taunt:OnCreated()
    if (not IsServer()) then
        return
    end
end

function modifier_brood_comes_random_taunt:IsTaunt()
    return true
end

function modifier_brood_comes_random_taunt:GetEffectName()
    return "particles/items2_fx/urn_of_shadows_damage.vpcf"
end

LinkLuaModifier("modifier_brood_comes_random_taunt", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

--charge ms bonus and getignoreaggrotarget(focus target) modifier
modifier_brood_comes_charge = class({
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
    GetTextureName = function(self)
        return "brood_comes"
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_weaver/weaver_shukuchi.vpcf"
    end,
    DeclareFunctions = function(self)
        return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN}
    end
})

function modifier_brood_comes_charge:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.charge_speed = self:GetAbility():GetSpecialValueFor("charge_speed")
    if (not keys or keys.target) then
        self:Destroy()
    end
    if keys.target == nil then
        return
    end
    self.target = keys.target
end

function modifier_brood_comes_charge:GetIgnoreAggroTarget()
    return self.target
end

function modifier_brood_comes_charge:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_brood_comes_charge:GetModifierMoveSpeed_AbsoluteMin()
    return self.charge_speed
end

LinkLuaModifier("modifier_brood_comes_charge", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

--ability class and active spell cast

brood_comes = class({
    GetAbilityTextureName = function(self)
        return "brood_comes"
    end,
})

function brood_comes:FindTauntTarget(caster)
    self.range = self:GetSpecialValueFor("range")
    -- Find all nearby enemies
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            self.range,
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

function brood_comes:OnSpellStart()
    if (not IsServer()) then
        return
    end
    self.range = self:GetSpecialValueFor("range")
    self.number = self:GetSpecialValueFor("number")
    self.duration = self:GetSpecialValueFor("duration")
    self.radius = self:GetSpecialValueFor("radius")
    --apply mother buff
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_brood_comes_mother"
    modifierTable.duration = -1
    GameMode:ApplyBuff(modifierTable)
    caster:EmitSound("broodmother_broo_move_09")
    --taunt random target
    local tauntTarget = self:FindTauntTarget(caster)
    if (tauntTarget == nil) then
        return
    end
    local duration = self:GetSpecialValueFor("duration")
    modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = tauntTarget
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_brood_comes_random_taunt"
    modifierTable.duration = duration
    GameMode:ApplyDebuff(modifierTable) --apply taunt buff
    --spawn spider horde
    local angleLeft = 0
    local summon_origin = tauntTarget:GetAbsOrigin()
    local summon_point_base = tauntTarget:GetAbsOrigin() + self.radius * tauntTarget:GetForwardVector()
    local summon_point
    for i = 0, self.number - 1, 1 do
        angleLeft = QAngle(0, i * (math.floor(360 / self.number)), 0)
        summon_point = RotatePosition(summon_origin, angleLeft, summon_point_base)
        local spider = CreateUnitByName("npc_boss_brood_spiderling", summon_point, true, caster, caster, caster:GetTeamNumber())
        spider:AddNewModifier(caster, self.ability, "modifier_kill", { duration = 30 })
        --find all spiders to charge
        local alltrash = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                2000,
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, charger in pairs(alltrash) do
            --spider horde charge!
            if IsSpiderling(charger) == true then
                modifierTable = {}
                modifierTable.ability = self
                modifierTable.target = charger
                modifierTable.caster = caster
                modifierTable.modifier_params = { target = tauntTarget }
                modifierTable.modifier_name = "modifier_brood_comes_charge"
                modifierTable.duration = duration
                GameMode:ApplyBuff(modifierTable)

            end
        end
    end
    --mother charge!
    modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_params = { target = tauntTarget }
    modifierTable.modifier_name = "modifier_brood_comes_charge"
    modifierTable.duration = duration
    GameMode:ApplyBuff(modifierTable)
end

--------------------
--brood cocoons
---------------------
-- modifier
modifier_brood_cocoons = class({
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
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_earth_spirit_petrify.vpcf"
    end,

})

function modifier_brood_cocoons:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.caster = self:GetCaster()
    self.interval = self:GetAbility():GetSpecialValueFor("interval")
    self:StartIntervalThink(self.interval)
end

function modifier_brood_cocoons:CheckState()
    local state = { [MODIFIER_STATE_INVULNERABLE] = true,
                    [MODIFIER_STATE_OUT_OF_GAME] = true,
                    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
                    [MODIFIER_STATE_STUNNED] = true,
                    [MODIFIER_STATE_FROZEN] = true, }
    return state
end

function modifier_brood_cocoons:OnIntervalThink()
    local summon_point = self.parent:GetAbsOrigin() + 100 * self.parent:GetForwardVector()
    local spider = CreateUnitByName("npc_boss_brood_spiderling", summon_point, true, self.caster, self.caster, self.caster:GetTeam())
    spider:AddNewModifier(self.caster, self.ability, "modifier_kill", { duration = 30 })
    spider:EmitSound("Hero_Broodmother.SpawnSpiderlings")
end

LinkLuaModifier("modifier_brood_cocoons", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

--active
brood_cocoons = class({
    GetAbilityTextureName = function(self)
        return "brood_cocoons"
    end,

})

function brood_cocoons:FindTargetForBanish(caster)
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
    local keys = {}
    for k in pairs(enemies) do
        table.insert(keys, k)
    end
    if (#enemies > 0) then
        local banishTarget = enemies[keys[math.random(#keys)]] --pick one number = pick one enemy
        if (#enemies > 0) then
            return banishTarget
        else
            return nil
        end
    end
end

function brood_cocoons:Banish(target)
    if (not IsServer()) then
        return
    end
    if (target == nil) then
        return
    end
    --apply banish debuff banish until rescue by channeling at melee range for some time if not saved for 30s = ded ==> lazy
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_brood_cocoons"
    modifierTable.duration = self.duration
    GameMode:ApplyDebuff(modifierTable)
    local cocoon_fx = ParticleManager:CreateParticle("particles/units/npc_boss_brood/brood_cocoons/brood_web.vpcf",PATTACH_ABSORIGIN, target)
    Timers:CreateTimer(self.duration, function()
        ParticleManager:DestroyParticle(cocoon_fx, false)
        ParticleManager:ReleaseParticleIndex(cocoon_fx)
    end)
    target:EmitSound("Hero_Broodmother.SpawnSpiderlingsCast")
end

function brood_cocoons:OnSpellStart()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    local number = self:GetSpecialValueFor("number")
    self.duration = self:GetSpecialValueFor("duration")
    local counter = 0
    local target
    Timers:CreateTimer(0, function()
        if counter < number then
            target = self:FindTargetForBanish(self.caster)
            self:Banish(target)
            counter = counter + 1
            return 0.1
        end
    end)
    self.caster:EmitSound("broodmother_broo_move_09")
end

---------------------
-- brood kiss
---------------------
--modifier
modifier_brood_kiss = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_poison_viper.vpcf"
    end
})

function modifier_brood_kiss:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.delay = self:GetAbility():GetSpecialValueFor("timer")
    self.pidx = ParticleManager:CreateParticle("particles/units/npc_boss_brood/brood_kiss/brood_kiss.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.pidx, 2, Vector(0, math.max(0, math.floor(self.delay)), 0))
    ParticleManager:SetParticleControl(self.pidx, 3, Vector(255, 0, 0))
    self:StartIntervalThink(1)
end

function modifier_brood_kiss:OnDestroy()
    if (not IsServer()) then
        return
    end
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
end

function modifier_brood_kiss:OnIntervalThink()
    local tick = 1
    self.delay = self.delay - tick
    self.parent:EmitSound("Hero_DarkWillow.Ley.Count")
    ParticleManager:SetParticleControl(self.pidx, 2, Vector(0, math.max(0, math.floor(self.delay)), 0))
    if (self.delay < 1) then
        self.parent:ForceKill(false)
    end
end

LinkLuaModifier("modifier_brood_kiss", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

--active
brood_kiss = class({
    GetAbilityTextureName = function(self)
        return "brood_kiss"
    end,
})

function brood_kiss:FindTargetForBlink(caster)
    if (not IsServer()) then
        return
    end
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
        local blinkTarget = enemies[keys[math.random(#keys)]] --pick one number = pick one enemy
        if (#enemies > 0) then
            return blinkTarget
        else
            return nil
        end
    end
end

function brood_kiss:BlinkKiss(target)
    if (not IsServer()) then
        return
    end
    if (target == nil) then
        return
    end
    --set parameter
    local caster = self:GetCaster()
    local timer = self:GetSpecialValueFor("timer")
    local stun_duration = self:GetSpecialValueFor("stun")
    local sound_cast = "Hero_Antimage.Blink_out"
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
    Aggro:Reset(caster)
    Aggro:Add(target, caster, 100)
    caster:MoveToTargetToAttack(target)
    caster:SetForwardVector(direction)

    --Kiss<3
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_brood_kiss"
    modifierTable.duration = timer
    GameMode:ApplyDebuff(modifierTable)
    -- Disjoint projectiles
    ProjectileManager:ProjectileDodge(caster)

    --stun
    modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_stunned"
    modifierTable.duration = stun_duration
    GameMode:ApplyDebuff(modifierTable)
    target:EmitSound("hero_viper.viperStrike")
end

function brood_kiss:IsRequireCastbar()
    return true
end

function brood_kiss:IsInterruptible()
    return true
end


function brood_kiss:OnAbilityPhaseStart()
    if IsServer() then
        local particle_cast = "particles/units/heroes/hero_spirit_breaker/spirit_breaker_haste_owner_flash.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self:GetCaster())
        Timers:CreateTimer(3.0, function()
            ParticleManager:DestroyParticle(effect_cast, false)
            ParticleManager:ReleaseParticleIndex(effect_cast)
        end)
    end
    return true
end

function brood_kiss:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    caster:EmitSound("broodmother_broo_kill_12")
    local target = self:FindTargetForBlink(caster)
    self:BlinkKiss(target)
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
    return self:GetSpecialValueFor("impact_radius")
end

function brood_spit:OnProjectileHit(target, location)
    if (not IsServer()) then
        return
    end
    if not target then
        return
    end

    -- load data
    local damage = self:GetSpecialValueFor("damage_per_impact")
    local duration = self:GetSpecialValueFor("burn_ground_duration")
    local impact_radius = self:GetSpecialValueFor("impact_radius")
    --local linger = self:GetSpecialValueFor("burn_linger_duration")
    -- precache damage
    if self.caster:IsAlive() then
        local enemies = FindUnitsInRadius(
                self.caster:GetTeamNumber(), -- int, your team number
                location, -- point, center point
                nil, -- handle, cacheUnit. (not known)
                impact_radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER, --int, order filter
                false  -- bool, can grow cache
        )

        for _, enemy in pairs(enemies) do
            local damageTable = {}
            damageTable.caster = self.caster
            damageTable.target = enemy
            damageTable.ability = self -- can be nil
            damageTable.damage = damage
            damageTable.naturedmg = true
            GameMode:DamageUnit(damageTable)
            --local modifierTable = {}
            --modifierTable.ability = self
            --modifierTable.target = enemy
            --modifierTable.caster = self.caster
            --modifierTable.modifier_name = "modifier_brood_spit_burn_slow"
            --modifierTable.duration = linger
            --GameMode:ApplyDebuff(modifierTable)

        end

        -- start aura on thinker
        local mod = target:AddNewModifier(
                self.caster, -- player source
                self, -- ability source
                "modifier_brood_spit_thinker", -- modifier name
                { duration = duration,
                } -- kv
        )

        self:PlayEffects(location)
    end
end

function brood_spit:PlayEffects(loc)
    if (not IsServer()) then
        return
    end
    -- Get Resources
    local particle_cast = "particles/econ/items/viper/viper_immortal_tail_ti8/viper_immortal_ti8_nethertoxin.vpcf"
    local sound_location = "Hero_Viper.NetherToxin"
    local duration = self:GetSpecialValueFor("burn_ground_duration")
    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(effect_cast, 0, loc)
    ParticleManager:SetParticleControl(effect_cast, 1, loc)
    Timers:CreateTimer(duration, function()
        ParticleManager:DestroyParticle(effect_cast, false)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end)

    -- Create Sound
    EmitSoundOnLocationWithCaster(loc, sound_location, self:GetCaster())
end

modifier_brood_spit = class({
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



-- Initializations
function modifier_brood_spit:OnCreated(kv)
    if not IsServer() then
        return
    end
    -- references
    self.caster = self:GetAbility():GetCaster()
    self.min_range = self:GetAbility():GetSpecialValueFor("min_range")
    self.max_range = self:GetAbility():GetSpecialValueFor("max_range")
    self.range = self.max_range - self.min_range

    self.min_travel = self:GetAbility():GetSpecialValueFor("min_lob_travel_time")
    self.max_travel = self:GetAbility():GetSpecialValueFor("max_lob_travel_time")
    self.travel_range = self.max_travel - self.min_travel
    local projectile_count = self:GetAbility():GetSpecialValueFor("projectile_count")
    local interval = self:GetAbility():GetSpecialValueFor("duration") / projectile_count + 0.01 -- so it only have 8 projectiles instead of 9
    -- Start interval
    self:StartIntervalThink(interval)
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
        local projectile_landing_point = enemy:GetAbsOrigin() --+ some random accuracy error?
        local origin = self:GetParent():GetOrigin()
        local vec = projectile_landing_point - origin
        local direction = vec
        direction.z = 0
        direction = direction:Normalized()

        if vec:Length2D() < self.min_range then
            vec = direction * self.min_range -- minimum range
            --elseif vec:Length2D()>self.max_range then
            --vec = direction * self.max_range --if farther than 3000 set to 3000
        end

        self.target = GetGroundPosition(origin + vec, nil)
        self.vector = vec
        self.travel_time = (vec:Length2D() - self.min_range) / self.range * self.travel_range + self.min_travel
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
        local projectile_speed = self:GetAbility():GetSpecialValueFor("projectile_speed") -- not using this but just in case something dont work this can call projectile speed


        -- precache projectile
        self.info = {
            Target = thinker,
            Source = self:GetCaster(),
            Ability = self:GetAbility(),

            EffectName = "particles/units/npc_boss_brood/brood_spit/brood_spit_proj.vpcf",
            iMoveSpeed = self.vector:Length2D() / self.travel_time,
            bDodgeable = false, -- Optional

            vSourceLoc = self:GetCaster():GetOrigin(), -- Optional (HOW)

            bDrawsOnMinimap = false, -- Optional
            bVisibleToEnemies = true, -- Optional
        }

        -- launch projectile
        ProjectileManager:CreateTrackingProjectile(self.info)

    end

    -- play sound
    EmitSoundOn("Hero_Viper.Nethertoxin.Cast", self:GetParent())
end

modifier_brood_spit_burn_slow = class({
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
function modifier_brood_spit_burn_slow:OnCreated(kv)
    -- references
    if (not IsServer()) then
        return
    end

    local interval = self:GetAbility():GetSpecialValueFor("burn_interval")
    self.slow = self:GetAbility():GetSpecialValueFor("slow") * -0.01
    self.slowmulti = self.slow +1
    -- Start interval
    self:StartIntervalThink(interval)
    self:OnIntervalThink()
end

LinkLuaModifier("modifier_brood_spit_burn_slow", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)


--------------------------------------------------------------------------------
-- Modifier Effects

function modifier_brood_spit_burn_slow:GetMoveSpeedPercentBonusMulti()
    return self.slowmulti
end

function modifier_brood_spit_burn_slow:GetAttackSpeedPercentBonusMulti()
    return self.slowmulti
end

function modifier_brood_spit_burn_slow:GetSpellHastePercentBonusMulti()
    return self.slowmulti
end


--------------------------------------------------------------------------------
-- Interval Effects
function modifier_brood_spit_burn_slow:OnIntervalThink()
    local dps = self:GetAbility():GetSpecialValueFor("burn_damage")
    local parent = self:GetParent()
    local caster = self:GetCaster()
    -- apply damage
    if caster:IsAlive() then
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = parent
        damageTable.ability = self:GetAbility()
        damageTable.damage = dps
        damageTable.naturedmg = true
        GameMode:DamageUnit(damageTable)
    end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_brood_spit_burn_slow:GetEffectName()
    return "particles/units/heroes/hero_broodmother/broodmother_poison_debuff.vpcf"
end

function modifier_brood_spit_burn_slow:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


modifier_brood_spit_thinker = class({})

function modifier_brood_spit_thinker:OnCreated(kv)
    if (not IsServer()) then
        return
    end
    -- references
    self.max_travel = self:GetAbility():GetSpecialValueFor("max_lob_travel_time")
    self.radius = self:GetAbility():GetSpecialValueFor("impact_radius")
    self.linger = self:GetAbility():GetSpecialValueFor("burn_linger_duration")

    if not IsServer() then
        return
    end

    -- dont start aura right off
    self.start = false

    -- create aoe finder particle
    self:PlayEffects(kv.travel_time)
end

LinkLuaModifier("modifier_brood_spit_thinker", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_brood_spit_thinker:OnRefresh(kv)
    if (not IsServer()) then
        return
    end
    -- references
    self.max_travel = self:GetAbility():GetSpecialValueFor("max_lob_travel_time")
    self.radius = self:GetAbility():GetSpecialValueFor("impact_radius")
    self.linger = self:GetAbility():GetSpecialValueFor("burn_linger_duration")

    if not IsServer() then
        return
    end

    -- start aura
    self.start = true

    -- stop aoe finder particle
    self:StopEffects()
end

function modifier_brood_spit_thinker:OnRemoved()
end

function modifier_brood_spit_thinker:OnDestroy()
    if not IsServer() then
        return
    end
    UTIL_Remove(self:GetParent())
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

function modifier_brood_spit_thinker:PlayEffects(time)
    if (not IsServer()) then
        return
    end
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_calldown.vpcf"

    -- Create Particle
    self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(self.effect_cast, 0, self:GetParent():GetOrigin())
    ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self.radius, 0, -self.radius * (self.max_travel / time)))
    ParticleManager:SetParticleControl(self.effect_cast, 2, Vector(time, 0, 0))
end

function modifier_brood_spit_thinker:StopEffects()
    ParticleManager:DestroyParticle(self.effect_cast, true)
    ParticleManager:ReleaseParticleIndex(self.effect_cast)
end


----------------
-- brood hunger
----------------

modifier_brood_hunger = class({
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

function modifier_brood_hunger:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    local duration = self.ability:GetSpecialValueFor("duration")
    --particle
    self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_hunger_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControlEnt(self.pfx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_thorax", self.parent:GetAbsOrigin(), true)
    Timers:CreateTimer(duration, function()
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
    end)
end

---@param damageTable DAMAGE_TABLE
function modifier_brood_hunger:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_brood_hunger")
    if (damageTable.damage > 0 and modifier and not damageTable.ability and damageTable.physdmg) then
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

LinkLuaModifier("modifier_brood_hunger", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

brood_hunger = class({
    GetAbilityTextureName = function(self)
        return "brood_hunger"
    end,
})

function brood_hunger:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_brood_hunger"
    modifierTable.duration = duration
    GameMode:ApplyBuff(modifierTable) --
    caster:EmitSound("Hero_Broodmother.InsatiableHunger")
end

---------------------
-- brood web
---------------------
--modifier
--------
--BUFF AURA
----------
modifier_brood_web_aura = class({})

function modifier_brood_web_aura:OnCreated()
    if IsServer() then
        if not self:GetAbility() then
            self:Destroy()
        end
    end

    -- Ability properties
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()

    -- Ability specials
    self.radius = self.ability:GetSpecialValueFor("radius")

    if IsServer() then
        self:GetParent():EmitSound("Hero_Broodmother.WebLoop")
    end
end

function modifier_brood_web_aura:IsAura()
    return true
end
function modifier_brood_web_aura:GetAuraDuration()
    return 0.1
end
function modifier_brood_web_aura:GetAuraRadius()
    return self.radius
end
function modifier_brood_web_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
end
function modifier_brood_web_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_brood_web_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_brood_web_aura:GetModifierAura()
    return "modifier_brood_web"
end

function modifier_brood_web_aura:IsHidden()
    return true
end
function modifier_brood_web_aura:IsPurgable()
    return false
end
function modifier_brood_web_aura:IsPurgeException()
    return false
end
function modifier_brood_web_aura:RemoveOnDeath()
    return true
end

function modifier_brood_web_aura:GetAuraEntityReject(hTarget)
    if not IsServer() then
        return
    end

    if hTarget == self:GetCaster() or IsSpiderling(hTarget) == true then
        return false
    end

    return true
end

function modifier_brood_web_aura:CheckState()
    return {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_brood_web_aura:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
    }
end

function modifier_brood_web_aura:OnDeath(params)
    if not IsServer() then
        return
    end

    if params.unit == self:GetParent() then
        self:GetParent():StopSound("Hero_Broodmother.WebLoop")
        UTIL_Remove(self:GetParent())
    end
end
LinkLuaModifier("modifier_brood_web_aura", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)
--------------------------------
-- SPIN WEB FRIENDLY MODIFIER --
--------------------------------

modifier_brood_web = class({
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
        return brood_web:GetAbilityTextureName()
    end,
})

function modifier_brood_web:OnCreated()
    self.ability = self:GetAbility()
    if IsServer() then
        if not self:GetAbility() then
            self:Destroy()
        end
    end

    -- Ability properties
    self.caster = self:GetCaster()
    self.parent = self:GetParent()

    -- Ability specials
    self.as_bonus = self.ability:GetSpecialValueFor("as_bonus") * 0.01
    self.ms_bonus = self.ability:GetSpecialValueFor("ms_bonus") * 0.01

end

function modifier_brood_web:GetAttackSpeedPercentBonus()
    return self.as_bonus
end

function modifier_brood_web:GetMoveSpeedPercentBonus()
    return self.ms_bonus
end
LinkLuaModifier("modifier_brood_web", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

-------------
--DEBUFF AURA
--------------
modifier_brood_web_aura_enemy = class({})

function modifier_brood_web_aura_enemy:OnCreated()
    self.ability = self:GetAbility()
    if not IsServer() then
        return
    end

    --if IsServer() then
        --if not self:GetAbility() then
            --self:Destroy()
        --end
    --end

    -- Ability properties
    self.caster = self:GetCaster()

    -- Ability specials
    self.radius = self.ability:GetSpecialValueFor("radius")
end

function modifier_brood_web_aura_enemy:IsAura()
    return true
end
function modifier_brood_web_aura_enemy:GetAuraDuration()
    return 0.1
end
function modifier_brood_web_aura_enemy:GetAuraRadius()
    return self.radius
end
function modifier_brood_web_aura_enemy:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end
function modifier_brood_web_aura_enemy:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_brood_web_aura_enemy:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_brood_web_aura_enemy:GetModifierAura()
    return "modifier_brood_web_enemy"
end

function modifier_brood_web_aura_enemy:IsHidden()
    return true
end
function modifier_brood_web_aura_enemy:IsPurgable()
    return false
end
function modifier_brood_web_aura_enemy:IsPurgeException()
    return false
end
function modifier_brood_web_aura_enemy:RemoveOnDeath()
    return true
end
LinkLuaModifier("modifier_brood_web_aura_enemy", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)
-----------------------------
-- SPIN WEB ENEMY MODIFIER --
-----------------------------
modifier_brood_web_enemy = class({
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
        return brood_web:GetAbilityTextureName()
    end,
})

function modifier_brood_web_enemy:OnCreated()

    if (not IsServer()) then
        return
    end
    --if (not self.ability or self.ability:IsNull()) then -- this cause web to completely stop working
        -- creation at the moment of brood death probably
        --self:Destroy()
    --end
    -- Ability properties
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.caster = self.ability:GetCaster()
    self.casterTeam = self.caster:GetTeam()
    -- Ability specials
    self.ms_slow = self.ability:GetSpecialValueFor("ms_slow") * -0.01
    self.ms_slow_multi = self.ms_slow + 1
    self.interval = self.ability:GetSpecialValueFor("spawn_interval")

    --spawn spiderling on enemy in web
    self:StartIntervalThink(self.interval)
end

function modifier_brood_web_enemy:GetMoveSpeedPercentBonusMulti()
    return self.ms_slow_multi
end

function modifier_brood_web_enemy:OnIntervalThink()
    if (self.parent and not self.parent:IsNull() ) then
        local summon_point = self.parent:GetAbsOrigin()
        local webspider = CreateUnitByName("npc_boss_brood_spiderling", summon_point, true, self.caster, self.caster, self.casterTeam)
        FindClearSpaceForUnit(webspider, summon_point, true)
        webspider:AddNewModifier(self.parent, self.ability, "modifier_kill", { duration = 30 })
        --on spawn
        if self.caster:IsAlive() then
            webspider:EmitSound("broodmother_broo_ability_spawn_04")
        end
    end
end

LinkLuaModifier("modifier_brood_web_enemy", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)
-----------
--active
-------------
brood_web = class({
    GetAbilityTextureName = function(self)
        return "brood_web"
    end,
})

function brood_web:FindTargetForWebCenter(caster)
    if (not IsServer()) then
        return
    end
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
        local webTarget = enemies[keys[math.random(#keys)]] --pick one number = pick one enemy
        return webTarget
    else
        return nil

    end
end

function brood_web:FindTargetForWeb(caster)
    --random with already hit removal
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
                table.insert(self.already_hit, enemy)
                randomEnemy = enemy
                break
            end
        end
        return randomEnemy
    end
end

function brood_web:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    caster:EmitSound("Hero_Broodmother.SpinWebCast")
    local summon_point = caster:GetAbsOrigin()
    local number = self:GetSpecialValueFor("number")
    self.already_hit = {}
    local counter = 0
    Timers:CreateTimer(0, function()
        if counter < number then
            local target = self:FindTargetForWeb(caster)
            -- in case there are no enemy spawn web randomly around caster
            if target == nil then
                local target_point = caster:GetAbsOrigin() + caster:GetForwardVector() * math.random(6, 9) * 100
                local angleLeft = QAngle(0, (math.floor(360 / math.random(6))), 0)
                summon_point = RotatePosition(target_point, angleLeft, caster:GetAbsOrigin())
                local web = CreateUnitByName("npc_dota_broodmother_web", summon_point, false, caster, caster, caster:GetTeamNumber())
                web:AddNewModifier(caster, self, "modifier_brood_web_aura", {})
                web:AddNewModifier(caster, self, 'modifier_brood_web_aura_enemy', {})
                web:AddNewModifier(caster, self, "modifier_kill", { duration = 30 })
                counter = counter + 1
            else
                summon_point = target:GetAbsOrigin()
                local web = CreateUnitByName("npc_dota_broodmother_web", summon_point, false, caster, caster, caster:GetTeamNumber())
                web:AddNewModifier(caster, self, "modifier_brood_web_aura", {})
                web:AddNewModifier(caster, self, 'modifier_brood_web_aura_enemy', {})
                web:AddNewModifier(caster, self, "modifier_kill", { duration = 30 })
                counter = counter + 1
            end
            return 0.1
        end
    end)
    caster:EmitSound("broodmother_broo_ability_spin_01")
end

--------------
--brood angry
----------------

brood_angry = class({
    GetAbilityTextureName = function(self)
        return "brood_angry"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_brood_angry"
    end
})

-- Aura modifier
modifier_brood_angry  = class({
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return 3000 --self.radius or 0
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
    IsAura = function(self)
        return true
    end,
    IsHidden = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_brood_angry_buff" --  The name of the secondary modifier that will be applied by this modifier (if it is an aura).
    end,
    GetTexture = function(self)
        return brood_angry:GetAbilityTextureName()
    end
})

function modifier_brood_angry:GetAuraEntityReject(hTarget)
    if IsMother(hTarget) == true or IsSpiderling(hTarget) == true then
        return false
    else
        return true
    end
end

function modifier_brood_angry:OnCreated()
    -- Ability properties
    self.caster = self:GetParent()
    self.ability = self:GetAbility()

    -- Ability specials
    self.radius = self.ability:GetSpecialValueFor("radius")
end


LinkLuaModifier("modifier_brood_angry", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

-- Aura buff modifier
modifier_brood_angry_buff = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH }
    end
})

function modifier_brood_angry_buff:OnCreated()
    -- Ability properties
    self.caster = self:GetAuraOwner()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    -- Ability specials
    self.radius = self.ability:GetSpecialValueFor("radius")
    self.duration = self.ability:GetSpecialValueFor("duration")
    self.max_stacks = self.ability:GetSpecialValueFor("max_stacks")
end

function modifier_brood_angry_buff:OnDeath(params) --doesnt work
    if (params.unit == self.parent) then
        local brood = self:GetAuraOwner()
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.target = brood
        modifierTable.caster = brood
        modifierTable.modifier_name = "modifier_brood_angry_stack"
        modifierTable.duration = self.duration
        modifierTable.stacks = 1
        modifierTable.max_stacks = self.max_stacks
        GameMode:ApplyStackingBuff(modifierTable)
    end
end

LinkLuaModifier("modifier_brood_angry_buff", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

modifier_brood_angry_stack = class({
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
        return brood_angry:GetAbilityTextureName()
    end,
})

function modifier_brood_angry_stack:OnCreated()
    if not IsServer() then
        return
    end
    --parameter
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.damage = self.ability:GetSpecialValueFor("self_damage")
    self.cd_reduce = self.ability:GetSpecialValueFor("cd_reduce")
    self.as_bonus= self.ability:GetSpecialValueFor("as_bonus")
    self.dmg_reduction= self.ability:GetSpecialValueFor("dmg_reduction")
    --self DAMAGE
    local Health = self.parent:GetHealth()
    local damage = Health * self.damage *0.01
    local damageTable = {}
    damageTable.caster = self.parent
    damageTable.target = self.parent
    damageTable.ability = self.ability
    damageTable.damage = damage
    damageTable.puredmg = true
    GameMode:DamageUnit(damageTable)
    --cd_reduce
    for abilities = 0, 9 do
        local ability = self.parent:GetAbilityByIndex(abilities)

        if ability and ability ~= self then
            local remaining_cooldown = ability:GetCooldownTimeRemaining()

            if remaining_cooldown > 0 then
                ability:EndCooldown()
                ability:StartCooldown(remaining_cooldown - self.cd_reduce)--(math.max(remaining_cooldown - self.cd_reduce, 0))
            end
        end
    end

    --sound
    if RollPercentage(8) then
        self.parent:EmitSound("broodmother_broo_attack_11")
    end
    --particle
    local healFX = ParticleManager:CreateParticle("particles/units/npc_boss_brood/brood_angry/anger_stack_gain.vpcf", PATTACH_POINT_FOLLOW, self.parent)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(healFX, false)
        ParticleManager:ReleaseParticleIndex(healFX)
    end)
end

function modifier_brood_angry_stack:OnRefresh()
    if (not IsServer()) then
        return
    end
    self:OnCreated()
end

function modifier_brood_angry_stack:GetAttackSpeedPercentBonus()
    self.as_bonus_final= self.as_bonus * 0.01 * self:GetStackCount()
    return self.as_bonus_final
end

function modifier_brood_angry_stack:GetDamageReductionBonus()
    self.dmg_reduction_final= self.dmg_reduction * 0.01 * self:GetStackCount()
    return self.dmg_reduction_final
end

LinkLuaModifier("modifier_brood_angry_stack", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

--internal stuff
if (IsServer() and not GameMode.ZONE1_BOSS_BROOD) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_brood_toxin, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_brood_hunger, 'OnTakeDamage'))
    GameMode.ZONE1_BOSS_BROOD = true
end