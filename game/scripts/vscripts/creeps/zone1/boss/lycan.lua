---------------------
--lycan call
---------------------
lycan_call = class({
    GetAbilityTextureName = function(self)
        return "lycan_call"
    end,

})

modifier_lycan_call_timer = modifier_lycan_call_timer or class({
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
})

function modifier_lycan_call_timer:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    Timers:CreateTimer(20.0, function()
        self.parent:RemoveModifierByName("modifier_lycan_call_timer")
    end) --20 s lifetime
end


function modifier_lycan_call_timer:OnDestroyed() -- kill summon wolves  > Doesnt work wolves are still chilling
    local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
            self:GetParent():GetAbsOrigin(),
            nil,
            FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER, false)
    for _, unit in pairs(units) do
        if unit:GetUnitName() == "npc_lycan_call_wolf" then
            unit:ForceKill(false)
        end
    end
end

LinkLuaModifier("modifier_lycan_call_timer", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

function lycan_call:SummonWolf(enemy)
    local caster = self:GetCaster()
    local wolf_name = "npc_creep_lycan_call_wolf"
    -- Reset variables
    local summon_origin = enemy:GetAbsOrigin() + 100 * enemy:GetForwardVector() --distance = 100
    local summon_point = nil
    local angleLeft = nil
    local angleRight = nil
    local numbers = self:GetSpecialValueFor("numbers")

    -- -- Define spawn locations
    for i = 0,numbers-1,1 do
        angleLeft = QAngle(0, 30 + 45*(math.floor(i/2)), 0)
        angleRight = QAngle(0, -30 + (-45*(math.floor(i/2))), 0)

        if (i+1) % 2 == 0 then --to the right
            summon_point = RotatePosition(enemy:GetAbsOrigin(),angleLeft,summon_origin)
        else --to the left
            summon_point = RotatePosition(enemy:GetAbsOrigin(),angleRight,summon_origin)
        end

    end
    local puppy = CreateUnitByName(wolf_name, summon_point, false, caster, caster, caster:GetTeamNumber())
    caster:AddNewModifier(caster, nil, "modifier_lycan_call_timer", { Duration = -1 })
    puppy:FindAbilityByName("lycan_double_strike"):SetLevel(3)
    puppy:FindAbilityByName("lycan_bleeding"):SetLevel(3)

end

function lycan_call:OnSpellStart()
    self.parent = self:GetCaster()
    self.parent:EmitSound("lycan_lycan_ability_summon_03")
    local caster = self:GetCaster()
    local range = self:GetSpecialValueFor("range")
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            range,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        self:SummonWolf(enemy)
    end
end

---------------------
--lycan companion
---------------------
lycan_companion = class({
    GetAbilityTextureName = function(self)
        return "lycan_companion"
    end,
    GetIntrinsicModifierName = function(self)
        return "lycan_companion"
    end,
})

modifier_lycan_companion = modifier_lycan_companion or class({
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

function modifier_lycan_companion:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

LinkLuaModifier("modifier_lycan_companion", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_lycan_companion:OnAttackLanded(keys)
    -- start cd
    if not IsServer() then
        return
    end
    local max = self.ability:GetSpecialValueFor("max")
    local wolfcount = self.ability:WolfCount(self.parent)
    local caster = self:GetParent()
    self.chance = self.ability:GetSpecialValueFor("chance")
    self:WolfCount(caster)
    if (wolfcount <= max) then --exceed max wolf count ?
        if (keys.attacker == self.parent and self.ability:IsCooldownReady()) then
            if RollPercentage(self.chance) then
                self.parent:EmitSound("lycan_lycan_ally_03")
                self.ability:SummonWolf(caster)
                local abilityCooldown = self.ability:GetCooldown(self.ability:GetLevel())
                self.ability:StartCooldown(abilityCooldown)
            end
        end
    end

end


function lycan_companion:SummonWolf(caster)
    local wolf_name = "npc_creep_lycan_companion_wolf"
    -- Reset variables
    local summon_origin = caster:GetAbsOrigin() + 100 * caster:GetForwardVector() --distance = 100
    local puppy = CreateUnitByName(wolf_name, summon_origin, false, caster, caster, caster:GetTeamNumber())
    puppy:FindAbilityByName("lycan_double_strike"):SetLevel(3)
    puppy:FindAbilityByName("lycan_bleeding"):SetLevel(3)
end

function lycan_companion:WolfCount(caster)
    local creatures = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local keys = {}
    for k in pairs(creatures) do
        table.insert(keys, k)
    end
    return #keys
end

---------------------
--lycan wound
---------------------
lycan_wound = class({
    GetAbilityTextureName = function(self)
        return "lycan_wound"
    end,
})


function lycan_wound:OnSpellStart()
    local caster = self:GetCaster()
    --apply a buff dealing initial damage then dot and heal negation
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_lycan_wound_debuff"
    modifierTable.duration = duration
    GameMode:ApplyDebuff(modifierTable)
    caster:EmitSound("hero_bloodseeker.rupture")
end

modifier_lycan_wound_debuff = modifier_lycan_wound_debuff or class({
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
        return false
    end
})

function modifier_lycan_wound_debuff:OnCreated()
    if not IsServer() then
        return
    end
    -- call and calculate values
    self.ability = self:GetAbility()
    self.ability = self.ability:GetSpecialValueFor("initial_damage")
    local parent 			= self:GetParent(); -- i want this to call victim that have this debuff
    local Max_health 	    = parent:GetMaxHealth();
    local damage 			= Max_health * self.dot;
    --initial damage
    local damageTable 			= {};
    damageTable.attacker = nil -- wound dot cant be reflect
    damageTable.target = parent
    damageTable.ability = nil -- can be nil
    damageTable.damage = damage
    damageTable.puredmg = true
    GameMode:DamageUnit(damageTable)
    --dot
    self.dot = self.ability:GetSpecialValueFor("dot")
    self:StartIntervalThink(1.0);
end

function modifier_lycan_wound_debuff:OnIntervalThink() --dot
    local parent 			= self:GetParent(); -- i want this to call victim that have this debuff
    local Max_health 	= parent:GetMaxHealth();
    local damage 			= Max_health * self.dot;
    local damageTable 			= {};
    damageTable.attacker = nil -- wound dot cant be reflect
    damageTable.target = parent
    damageTable.ability = nil -- can be nil
    damageTable.damage = damage
    damageTable.puredmg = true
    GameMode:DamageUnit(damageTable)
end


function modifier_lycan_wound_debuff:GetHealthRegenerationPercentBonus() --heal negate
    return -1000 --that boi can never regain hp again
end



LinkLuaModifier("modifier_lycan_wound_debuff", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)
---------------------
--lycan wolf form
---------------------
lycan_wolf_form = class({
    GetAbilityTextureName = function(self)
        return "lycan_wolf_form"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_lycan_wolf_form"
    end,
})

modifier_lycan_wolf_form = modifier_lycan_wolf_form or class({
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
        return { MODIFIER_EVENT_ON_TAKEDAMAGE}
    end
})

function modifier_lycan_wolf_form:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

end

LinkLuaModifier("modifier_lycan_wolf_form", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)


modifier_lycan_transform= modifier_lycan_transform or class({
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

function modifier_lycan_transform:OnCreated()
    if not IsServer() then
        return
    end
    local modifier = self:GetParent():FindModifierByName("modifier_lycan_wolf_form")
    if (modifier) then
        self.bat = modifier.ability:GetSpecialValueFor("bat")
        self.crit_factor = modifier.ability:GetSpecialValueFor("crit_factor")
        self.crit_chance = modifier.ability:GetSpecialValueFor("crit_chance")
    end
end

function modifier_lycan_transform:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MODEL_CHANGE}

    return decFuncs
end


function modifier_lycan_transform:GetModifierModelChange()
    return "models/items/lycan/ultimate/hunter_kings_trueform/hunter_kings_trueform.vmdl"
end


function modifier_lycan_transform:GetBaseAttackTime()
    return self.bat
end -- seems make him cant AA im not sure

function modifier_lycan_transform:OnTakeDamage(damageTable) -- Critical on autoattack
    local modifier = damageTable.attacker:FindModifierByName("modifier_lycan_transform")
    if (modifier ~= nil and damageTable.physdmg and not damageTable.ablity) then
        if (damageTable.damage > 0) then
            if RollPercentage(self.crit_chance) then
                self.parent:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
                damageTable.crit = damageTable.damage*self.crit_factor*0.01
            end
            return damageTable
        end
    end
end



LinkLuaModifier("modifier_lycan_transform", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

function lycan_wolf_form:Transform()
    local particle_cast = "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf"
    local particle_cast_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, caster)
    local transform_buff = "modifier_lycan_transform"
    local modifierTable = {}
    self.caster = self:GetCaster()
    modifierTable.ability = self
    modifierTable.target = self.caster
    modifierTable.caster = self.caster
    modifierTable.modifier_name = transform_buff
    modifierTable.duration = -1
    GameMode:ApplyBuff(modifierTable)
    ParticleManager:SetParticleControl(particle_cast_fx, 0 , self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_cast_fx, 1 , self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_cast_fx, 2 , self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_cast_fx, 3 , self.caster:GetAbsOrigin())
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(particle_cast_fx, false)
        ParticleManager:ReleaseParticleIndex(particle_cast_fx)
    end)
    self.caster:EmitSound("Hero_Lycan.Shapeshift.Cast")
end


function modifier_lycan_wolf_form:OnTakeDamage() --this doesnt work lycan just transform immediately sadkek
    self.parent = self:GetParent()
    self.hp_threshold = self.ability:GetSpecialValueFor("hp_threshold")*0.01
    self.hp_pct = self.parent:GetHealth()/self.parent:GetMaxHealth()
    if self.parent:HasModifier("modifier_lycan_transform") then -- already transform ? destroy hp check buff
        self.parent:RemoveModifierByName("modifier_lycan_wolf_form")
    end
    if self.hp_pct <= self.hp_threshold then -- hp drop below threshold = transform
        self.ability:Transform()
    end
end




---------------------
--lycan howl aura
---------------------
--howl aura is an active. It has 2 components dmg reduced debuff on enemies and lycan aura active on cast
lycan_howl_aura = class({
    GetAbilityTextureName = function(self)
        return "howl_aura"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_lycan_howl_aura"
    end,
})

modifier_lycan_howl_aura = modifier_lycan_howl_aura or class({
    IsHidden = function(self)
        return false
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.ability.radius or 0
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
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
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_lycan_howl_aura_buff" --	The name of the secondary modifier that will be applied by this modifier (if it is an aura).
    end,
    GetAbilityTextureName = function(self)
        return "howl_aura"
    end,
})


function modifier_lycan_howl_aura:OnCreated() -- giving lycan primary buff this buff give him secondary modifier aura buff
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.hero = self.ability:GetCaster()
    self.radius =  self.ability:GetSpecialValueFor("radius")

end

LinkLuaModifier("modifier_lycan_howl_aura", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lycan_howl_aura_buff = modifier_lycan_howl_aura_buff or class({
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
    GetAbilityTextureName = function(self)
        return "howl_aura"
    end,
})

function modifier_lycan_howl_aura_buff:OnCreated()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
        self.radius = self.ability:GetSpecialValueFor("radius")
        self.as_aura = self.ability:GetSpecialValueFor("as_aura")
        self.ms_aura = self.ability:GetSpecialValueFor("ms_aura")
        self.damage_reduce_incoming_pct_aura =  self.ability:GetSpecialValueFor("damage_reduce_incoming_pct_aura")*0.01

end

function modifier_lycan_howl_aura_buff:GetDamageReductionBonus()
    return self.damage_reduce_incoming_pct_aura or 0
end

function modifier_lycan_howl_aura_buff:GetAttackSpeedBonus()
    return self.as_aura
end

function modifier_lycan_howl_aura_buff:GetMoveSpeedPercentBonus()
    return self.ms_aura
end

LinkLuaModifier("modifier_lycan_howl_aura_buff", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lycan_howl_debuff = modifier_lycan_howl_debuff or class({
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
        return "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
    end,
    GetAbilityTextureName = function(self)
        return "howl_aura"
    end,
})

function lycan_howl_aura:OnUpgrade()
    if not IsServer() then
        return
    end
    self.radius = self:GetSpecialValueFor("radius")
end

function modifier_lycan_howl_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.aa_reduction = 0
    self.spelldmg_reduction = 0
    local ability = self:GetParent():FindAbilityByName("howl_aura")
    if (ability) then
        self.aa_reduction = ability:GetSpecialValueFor("dmg_done_reduced") * -0.01
        self.spelldmg_reduction = ability:GetSpecialValueFor("dmg_done_reduced") * -0.01
    end
end

function modifier_lycan_howl_debuff:GetAttackDamagePercentBonus()
    return self.aa_reduction or 0
end

function modifier_lycan_howl_debuff:GetSpellDamageBonus()
    return self.spelldmg_reduction or 0
end

LinkLuaModifier("modifier_lycan_howl_debuff", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)



function lycan_howl_aura:OnSpellStart()
    if IsServer() then
        local duration = self:GetSpecialValueFor("duration")
        self.caster = self:GetCaster()
        --apply aura
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.caster
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_lycan_howl_aura"
        modifierTable.duration = duration
        GameMode:ApplyBuff(modifierTable)

        --apply debuff
        local radius = self:GetSpecialValueFor("radius")
        local particle_lycan_howl = "particles/units/heroes/hero_lycan/lycan_howl_cast.vpcf"
        local particle_lycan_howl_fx = ParticleManager:CreateParticle(particle_lycan_howl, PATTACH_ABSORIGIN, self.caster)
        ParticleManager:SetParticleControl(particle_lycan_howl_fx, 0 , self.caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_lycan_howl_fx, 1 , self.caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_lycan_howl_fx, 2 , self.caster:GetAbsOrigin())
        --local particle_hit = "particles/units/heroes/hero_slardar/slardar_crush_entity.vpcf"
        --self.caster:EmitSound("Hero_Lycan.Howl")
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
            modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_lycan_howl_debuff"
            modifierTable.duration = duration
            GameMode:ApplyDebuff(modifierTable)
        end
    end
end

---------------------
--lycan agility
---------------------
lycan_agility = class({
    GetAbilityTextureName = function(self)
        return "lycan_agility"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_lycan_agility"
    end,
})


modifier_lycan_agility_already_hit = modifier_lycan_agility_already_hit or class({
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

LinkLuaModifier("modifier_lycan_agility_already_hit", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)


function lycan_agility:FindTargetForBlink(caster, radius)

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
    for k,enemy in pairs(enemies) do
        if (enemy:HasModifier("modifier_lycan_agility_already_hit")==nil) then -- only give numbers to enemies with no already hit buff
            table.insert(keys, k)
        end
    end
        if (#enemies > 0) then --#keys?
            local target = enemies[keys[math.random(#keys)]] --pick one number = pick one enemy
            target:AddNewModifier(caster, nil, "modifier_lycan_agility_already_hit", {duration=25.0}) -- add already hit buff to target
            return target
        else
            return nil
        end
end

function lycan_agility:Blink(target)
    -- Teleport
    local caster = self:GetCaster()
        --local sound_cast = "Hero_Antimage.Blink_out"
    if (target==nil) then
        return
    end
        --caster:EmitSound(sound_cast)
        -- Blink
    local targetPosition = target:GetAbsOrigin()
    local vector = (targetPosition - caster:GetAbsOrigin())
        --local distance = vector:Length2D()
    local direction = vector:Normalized()
    local blink_point = targetPosition - (target:GetForwardVector()*100)--+ direction * (distance -10 )
    caster:SetAbsOrigin(blink_point)
    Timers:CreateTimer(1.0, function()
        FindClearSpaceForUnit(caster, blink_point, true)
        end)
        --sound_cast = "Hero_Antimage.Blink_in"
        --caster:EmitSound(sound_cast)
    Aggro:Reset(caster)
    Aggro:Add(target, caster, 100)
    caster:MoveToTargetToAttack(target)
    caster:PerformAttack(target, true, true, true, true, false, false, false)
    caster:SetForwardVector(direction)

    -- Disjoint projectiles
    ProjectileManager:ProjectileDodge(caster)
end

function lycan_agility:OnSpellStart()
    local caster = self:GetCaster()
    local radius = 1000
    local target = caster
    caster:EmitSound("lycan_lycan_attack_08")
    -- first hit is unit targetting
    radius = self:GetSpecialValueFor("range")
    local firstTarget = self:FindTargetForBlink(caster, radius)
    target = self:GetCursorTarget(firstTarget)
    self:Blink(target)
    --find next target
    repeat     radius = self:GetSpecialValueFor("jump_range")
               target = self:FindTargetForBlink(caster, radius)
               self:Blink(target)
               Timers:CreateTimer(1.0, function()
               end) --delay between jump so that he can autoattack
    until target == nil
    Aggro:Reset(caster)
end

---------------------
--lycan double strike
---------------------
-- get 1 insane AS buff remove on next hit
lycan_double_strike = class({
    GetAbilityTextureName = function(self)
        return "lycan_double_strike"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_lycan_double_strike"
    end,
})


modifier_lycan_double_strike = modifier_lycan_double_strike or class({
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


function modifier_lycan_double_strike:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.chance = self.chance or self.ability:GetSpecialValueFor("chance")
end

LinkLuaModifier("modifier_lycan_double_strike", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lycan_quick_hit= modifier_lycan_quick_hit or class({
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
    GetAbilityTextureName = function(self)
        return "lycan_double_strike"
    end,
})

function modifier_lycan_quick_hit:OnCreated()
    if not IsServer() then
        return
    end
    local modifier = self:GetParent():FindModifierByName("modifier_lycan_double_strike")
    if (modifier) then
        self.as_bonus = modifier.ability:GetSpecialValueFor("as_bonus")
    end

end


function modifier_lycan_quick_hit:GetAttackSpeedBonus()
    return self.as_bonus
end

LinkLuaModifier("modifier_lycan_quick_hit", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_lycan_double_strike:OnAttackLanded(keys)
    -- start cd
    if not IsServer() then
        return
    end
    if (keys.attacker:HasModifier("modifier_lycan_quick_hit")) then
        keys.attacker:RemoveModifierByName("modifier_lycan_quick_hit")
    else
        if (keys.attacker == self.parent and self.ability:IsCooldownReady()) then
            if RollPercentage(self.chance) then
                self.ability:ApplyQuickHit(self.parent)
                local abilityCooldown = self.ability:GetCooldown(self.ability:GetLevel())
                self.ability:StartCooldown(abilityCooldown)
            end
        end
    end
end

function lycan_double_strike:ApplyQuickHit(parent)
    --insane AS for one hit
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = parent
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_lycan_quick_hit"
    modifierTable.duration = -1
    GameMode:ApplyBuff(modifierTable)
end




---------------------
--lycan bleeding
---------------------
lycan_bleeding = class({
    GetAbilityTextureName = function(self)
        return "lycan_bleeding"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_lycan_bleeding"
    end,
})


modifier_lycan_bleeding = modifier_lycan_bleeding or class({
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

function modifier_lycan_bleeding:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end
LinkLuaModifier("modifier_lycan_bleeding", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lycan_bleeding_dot = modifier_lycan_bleeding_dot or class({
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
})

function modifier_lycan_bleeding_dot:OnCreated()
    if not IsServer() then
        return
    end
    local modifier = self:GetCaster():FindModifierByName("modifier_lycan_bleeding")
    if (modifier) then
        self.dot = modifier.ability:GetSpecialValueFor("dot")
        self:StartIntervalThink(1.0);
    end
end

function modifier_lycan_bleeding_dot:OnIntervalThink()
    local parent 			= self:GetParent();
    local Max_health 	= parent:GetMaxHealth();
    local damage 			= Max_health*self.dot*0.01;
    local damageTable 			= {};
    damageTable.attacker = nil
    damageTable.target = parent
    damageTable.ability = nil -- can be nil
    damageTable.damage = damage
    damageTable.puredmg = true
    GameMode:DamageUnit(damageTable)
end



LinkLuaModifier("modifier_lycan_bleeding_dot", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lycan_bleeding_heal_reduced = modifier_lycan_bleeding_heal_reduced or class({
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
        return false
    end,
})

function modifier_lycan_bleeding_heal_reduced:OnCreated()
    if not IsServer() then
        return
    end
    local modifier = self:GetCaster():FindModifierByName("modifier_lycan_bleeding")
    if (modifier) then
        self.heal_reduced = modifier.ability:GetSpecialValueFor("heal_reduced")
    end
end

function modifier_lycan_bleeding_heal_reduced:GetHealthRegenerationPercentBonus()
    return self.heal_reduced
end


LinkLuaModifier("modifier_lycan_heal_reduced", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)



function modifier_lycan_bleeding:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    self.ability:ApplyBleeding(keys.target, self.parent)
end

function lycan_bleeding:ApplyBleeding(target,parent)

    local max_stacks = self:GetSpecialValueFor("max_stacks")
    self.duration = self:GetSpecialValueFor("duration")
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_lycan_bleeding_heal_reduced"
    modifierTable.duration = self.duration
    modifierTable.stacks = 1
    modifierTable.max_stacks = max_stacks
    GameMode:ApplyStackingDebuff(modifierTable)
    modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_lycan_bleeding_dot"
    modifierTable.duration = self.duration
    modifierTable.stacks = 1
    modifierTable.max_stacks = max_stacks
    GameMode:ApplyStackingDebuff(modifierTable)

end
