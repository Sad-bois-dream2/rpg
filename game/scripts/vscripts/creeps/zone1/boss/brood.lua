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

modifier_brood_toxin = modifier_brood_toxin or class({
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
    if (keys.attacker:HasModifier("modifier_brood_comes_mother") and keys.attacker == self.parent and stun ~= nil) then
        keys.target:ForceKill(false)
        --taunting
        local i = math.random(2)
        if i == 1 then
            self.parent:EmitSound("broodmother_broo_ability_incap_02")
        else
            self.parent:EmitSound("broodmother_broo_ability_incap_04")
        end
        --particle
        local particle_cast_fx = ParticleManager:CreateParticle("particles/units/npc_boss_brood/brood_toxin/brood_toxin.vpcf", PATTACH_ABSORIGIN, keys.target)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(particle_cast_fx, false)
            ParticleManager:ReleaseParticleIndex(particle_cast_fx)
        end)
        --apply stack
    elseif (keys.attacker == self.parent and stun == nil) then
        --and immune == nil
        self.ability:ApplyToxin(keys.target, self.parent)
    end
end

-- brood spit damage instance apply spider toxin
---@param damageTable DAMAGE_TABLE
function modifier_brood_toxin:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_brood_toxin")
    if (damageTable.damage > 0 and modifier and damageTable.ability and damageTable.ability == modifier.ability) then
        local slowmod = damageTable.victim:FindModifierByName("modifier_brood_toxin_slow")
        local stun_duration = slowmod.stun
        --if no toxin slow apply it
        if slowmod == nil then
            local modifierTable = {}
            modifierTable.ability = modifier:GetAbility()
            modifierTable.target = damageTable.victim
            modifierTable.caster = damageTable.attacker
            modifierTable.modifier_name = "modifier_brood_toxin_slow"
            modifierTable.duration = modifier.duration
            modifierTable.stacks = 1
            modifierTable.max_stacks = modifier.max_stacks
            GameMode:ApplyStackingDebuff(modifierTable)
            -- if toxin slow max > stun
        elseif slowmod:GetStackCount() == slowmod.max_stacks then
            local modifierTable = {}
            modifierTable.ability = modifier:GetAbility()
            modifierTable.target = damageTable.victim
            modifierTable.caster = damageTable.attacker
            modifierTable.modifier_name = "modifier_brood_toxin_stunned"
            modifierTable.duration = stun_duration
            GameMode:ApplyDebuff(modifierTable)
            damageTable.victim:EmitSound("Hero_Slardar.Bash")
            damageTable.victim:FindModifierByName("modifier_brood_toxin_slow"):Destroy()
        else
            -- else add stack
            damageTable.victim:FindModifierByName("modifier_brood_toxin_slow"):OnRefresh()
        end
    end
end

LinkLuaModifier("modifier_brood_toxin", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

modifier_brood_toxin_slow = modifier_brood_toxin_slow or class({
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
    self.base_slow = self:GetAbility():GetSpecialValueFor("base_slow") * -0.01
    self.slow = self:GetAbility():GetSpecialValueFor("stack_slow") * -0.01 * (self:GetStackCount() + 1) + self.base_slow
    self.stun = self:GetAbility():GetSpecialValueFor("stun")
    self.max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks")
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

function modifier_brood_toxin_slow:GetMoveSpeedPercentBonus()
    return self.slow
end

function modifier_brood_toxin_slow:GetAttackSpeedPercentBonus()
    return self.slow
end

function modifier_brood_toxin_slow:GetSpellHasteBonus()
    return self.slow
end

LinkLuaModifier("modifier_brood_toxin_slow", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

--special stun for one hit kill check
modifier_brood_toxin_stunned = modifier_brood_toxin_stunned or class({
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
    end
})

function modifier_brood_toxin_stunned:OnCreated()
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.ability = self:GetAbility()
    --self.immunity = self:GetAbility():GetSpecialValueFor("immunity")
end

function modifier_brood_toxin_stunned:CheckState()
    return { [MODIFIER_STATE_STUNNED] = true }
end

function modifier_brood_toxin_stunned:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_PROVIDES_FOW_POSITION }

    return funcs
end

function modifier_brood_toxin_stunned:GetModifierProvidesFOWVision()
    return 1
end

--function modifier_brood_toxin_stunned:OnDestroy()
--if not IsServer() then
--return
--end
--local modifierTable = {}
--modifierTable.ability = self.ability
--modifierTable.target = self.target
--modifierTable.caster = self.caster
--modifierTable.modifier_name = "modifier_brood_toxin_immunity"
--modifierTable.duration = self.immunity
--GameMode:ApplyDebuff(modifierTable)
--end

LinkLuaModifier("modifier_brood_toxin_stunned", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

--modifier_brood_toxin_immunity = modifier_brood_toxin_immunity or class({
--IsDebuff = function(self)
--return true
--end,
--IsHidden = function(self)
--return false
--end,
--IsPurgable = function(self)
--return false
--end,
--GetTexture = function(self)
--return brood_toxin:GetAbilityTextureName()
--end
--})

--function modifier_brood_toxin_immunity:OnCreated()
--if not IsServer() then
--return
--end
--self.caster = self:GetParent()
--self.target = self:GetParent()
--end

--LinkLuaModifier("modifier_brood_toxin_immunity", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)


---------------------
-- brood comes
---------------------
--mother of spider modifier
modifier_brood_comes_mother = modifier_brood_comes_mother or class({
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
})

function modifier_brood_comes_mother:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self:StartIntervalThink(1.0)
end

--smart mother tries to find enemy to charge in and oneshot
function modifier_brood_comes_mother:OnIntervalThink()
    if (not IsServer()) then
        return
    end
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
            modifierTable.duration = 3
            modifierTable.modifier_params = { target = enemy }
            GameMode:ApplyBuff(modifierTable)
            local i = math.random(2)
            if i == 1 then
                self.parent:EmitSound("broodmother_broo_ability_hunger_05")
            else
                self.parent:EmitSound("broodmother_broo_cast_02")
            end
        end
    end
end

LinkLuaModifier("modifier_brood_comes_mother", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

--random taunt modifier
modifier_brood_comes_random_taunt = modifier_brood_comes_random_taunt or class({
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
modifier_brood_comes_charge = modifier_brood_comes_charge or class({
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
})

function modifier_brood_comes_charge:OnCreated(keys)
    if (not IsServer()) then
        return
    end
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
    --phase and haste
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
end

function modifier_brood_comes_charge:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN
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
    local summon_origin = tauntTarget:GetAbsOrigin() + self.radius * tauntTarget:GetForwardVector()
    local summon_point = tauntTarget:GetAbsOrigin() + self.radius * tauntTarget:GetForwardVector()
    for i = 0, self.number - 1, 1 do
        angleLeft = QAngle(0, i * (math.floor(360 / self.number)), 0)
        summon_point = RotatePosition(tauntTarget:GetAbsOrigin(), angleLeft, summon_origin)
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
            if IsSpiderling(charger) then
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
modifier_brood_cocoons = modifier_brood_cocoons or class({
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
    GetEffectName = function(self)
        return "particles/units/npc_boss_brood/brood_cocoons/brood_web.vpcf"
    end
})

function modifier_brood_cocoons:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.parent:NoHealthBar()
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
    if (not IsServer()) then
        return
    end
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
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    --apply banish debuff banish until rescue by channeling at melee range for some time if not saved for 30s = ded ==> lazy
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_brood_cocoons"
    modifierTable.duration = duration
    GameMode:ApplyDebuff(modifierTable)
end

function brood_cocoons:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local number = self:GetSpecialValueFor("number")
    local counter = 0
    local target
    Timers:CreateTimer(0, function()
        if counter < number then
            target = self:FindTargetForBanish(caster)
            self:Banish(target)
            counter = counter + 1
            return 0.1
        end
    end)
    caster:EmitSound("broodmother_broo_move_09")
    caster:EmitSound("Hero_Broodmother.SpawnSpiderlingsCast")
end

---------------------
-- brood kiss
---------------------
--modifier
modifier_brood_kiss = modifier_brood_kiss or class({
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
        return "particles/units/npc_boss_brood/brood_kiss/brood_kiss.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end,
    ShouldUseOverheadOffset = function(self)
        return true
    end
})

function modifier_brood_kiss:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.timer = self:GetAbility():GetSpecialValueFor("timer")
    self:StartIntervalThink(self.timer)
end

function modifier_brood_kiss:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.parent:ForceKill(false)
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
    caster:PerformAttack(target, true, true, true, true, false, false, false)
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

function brood_kiss:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    caster:EmitSound("broodmother_broo_kill_12")
    local target = self:FindTargetForBlink(caster)
    self:BlinkKiss(target)
    --particle
    local particle_cast = "particles/units/heroes/hero_spirit_breaker/spirit_breaker_haste_owner_flash.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self:GetCaster())
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(effect_cast, false)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end)
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
    local linger = self:GetSpecialValueFor("burn_linger_duration")
    -- precache damage

    local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(), -- int, your team number
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
            { duration = duration,
            } -- kv
    )

    self:PlayEffects(location)
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

            EffectName = "particles/units/npc_boss_brood/brood_spit_projectile.vpcf",
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
function modifier_brood_spit_burn_slow:OnCreated(kv)
    -- references
    if (not IsServer()) then
        return
    end

    local interval = self:GetAbility():GetSpecialValueFor("burn_interval")
    self.slow = self:GetAbility():GetSpecialValueFor("slow") * -0.01
    -- Start interval
    self:StartIntervalThink(interval)
    self:OnIntervalThink()
end

LinkLuaModifier("modifier_brood_spit_burn_slow", "creeps/zone1/boss/brood.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_brood_spit_burn_slow:OnRefresh(kv)

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
    local parent = self:GetParent()
    local caster = self:GetCaster()
    -- apply damage
    local damageTable = {}
    damageTable.caster = caster
    damageTable.target = parent
    damageTable.ability = nil
    damageTable.damage = dps
    damageTable.naturedmg = true
    GameMode:DamageUnit(damageTable)
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

modifier_brood_hunger = modifier_brood_hunger or class({
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
    --particle
    self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_hunger_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControlEnt(self.pfx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_thorax", self.parent:GetAbsOrigin(), true)
    Timers:CreateTimer(2.0, function()
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
modifier_brood_web_aura = modifier_brood_web_aura or class({})

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

    if hTarget == self:GetCaster() or IsSpiderling(hTarget) then
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

modifier_brood_web = modifier_brood_web or class({
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
    if IsServer() then
        if not self:GetAbility() then
            self:Destroy()
        end
    end

    -- Ability properties
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
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
modifier_brood_web_aura_enemy = modifier_brood_web_aura_enemy or class({})

function modifier_brood_web_aura_enemy:OnCreated()
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
modifier_brood_web_enemy = modifier_brood_web_enemy or class({
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
    -- Ability properties
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.caster = self.ability:GetCaster()
    self.casterTeam = self.caster:GetTeam()
    -- Ability specials
    self.ms_slow = self.ability:GetSpecialValueFor("ms_slow") * -0.01
    self.interval = self.ability:GetSpecialValueFor("spawn_interval")

    --spawn spiderling on enemy in web
    self:StartIntervalThink(self.interval)
end

function modifier_brood_web_enemy:GetMoveSpeedPercentBonus()
    return self.ms_slow
end

function modifier_brood_web_enemy:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    -- idk about alive thing
    if (self.parent and not self.parent:IsNull() and self.parent:IsAlive()) then
        local summon_point = self.parent:GetAbsOrigin()
        local webspider = CreateUnitByName("npc_boss_brood_spiderling", summon_point, true, self.caster, self.caster, self.casterTeam)
        FindClearSpaceForUnit(webspider, summon_point, true)
        webspider:AddNewModifier(self.parent, self.ability, "modifier_kill", { duration = 30 })
        --on spawn
        webspider:EmitSound("broodmother_broo_ability_spawn_04")
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

if (IsServer()) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_brood_toxin, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_brood_hunger, 'OnTakeDamage'))
end