---------------------
--lycan call
---------------------
lycan_call = class({
    GetAbilityTextureName = function(self)
        return "lycan_call"
    end,

})


--set wolf parameter
function lycan_call:SummonWolf(args)
    if (args == nil) then
        return nil
    end
    local caster = args.caster
    local summon = args.unit
    local position = args.position
    local ability = args.ability
    if (caster == nil or summon == nil or position == nil or ability == nil) then
        return nil
    end
    summon = CreateUnitByName(summon, position, true, caster, caster, caster:GetTeamNumber())
    summon:AddNewModifier(caster, self, "modifier_lycan_call_wolf", {})
    summon:AddNewModifier(caster, self, "modifier_kill", {duration = self.duration})
end

function lycan_call:OnSpellStart()
    local caster = self:GetCaster()
    caster:EmitSound("lycan_lycan_ability_summon_03")
    --Find enemies in range
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            self.range,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    --summon wolf on each enemy position
    for _, enemy in pairs(enemies) do
        local summon_point = enemy:GetAbsOrigin() + 100 * enemy:GetForwardVector()
        for i = 0,self.number-1,1 do
        summon_point = enemy:GetAbsOrigin() + 50 * enemy:GetForwardVector() * i
        local summon_damage = Units:GetAttackDamage(caster)*0.1
        self:SummonWolf({caster = caster, unit = "npc_boss_lycan_call_wolf", position = summon_point, damage = summon_damage, ability = self })
        end
    end
end

function lycan_call:OnUpgrade()
    if IsServer() then
        local ability_level = self:GetLevel() - 1
        self.range = self:GetLevelSpecialValueFor("range", ability_level)
        self.number = self:GetLevelSpecialValueFor("number", ability_level)
        self.duration = self:GetLevelSpecialValueFor("duration", ability_level)
    end
end

--modifier for lycan call wolf
modifier_lycan_call_wolf = modifier_lycan_call_wolf or class({})



-- Modifier properties
function modifier_lycan_call_wolf:IsDebuff() return false end
function modifier_lycan_call_wolf:IsHidden() return true end
function modifier_lycan_call_wolf:IsPurgable() return false end

function modifier_lycan_call_wolf:OnCreated()
    if IsServer() then
        local parent			=	self:GetParent()
        local ability			=	self:GetAbility()
        local bleeding	=	parent:FindAbilityByName("lycan_bleeding")
        local double    =   parent:FindAbilityByName("lycan_double_strike")
        -- Level the wolf ability
        bleeding:SetLevel(ability:GetLevel() )
        double:SetLevel(ability:GetLevel() )
    end
end


-- Kill wolf when it's duration is over
function modifier_lycan_call_wolf:OnDestroy()
    if IsServer() then
        self:GetParent():ForceKill(false)
    end
end

LinkLuaModifier("modifier_lycan_call_wolf", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

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
    local caster = self:GetParent()
    self.chance = self.ability:GetSpecialValueFor("chance")
    if (keys.attacker == self.parent and self.ability:IsCooldownReady()) then
            if RollPercentage(self.chance) then
                self.parent:EmitSound("lycan_lycan_ally_03")
                local summon_point = caster:GetAbsOrigin() + 100 * caster:GetForwardVector()
                local summon_damage = Units:GetAttackDamage(caster)*0.1
                self:SummonWolf({caster = caster, unit = "npc_boss_lycan_companion_wolf", position = summon_point, damage = summon_damage, ability = self })
                local abilityCooldown = self.ability:GetCooldown(self.ability:GetLevel())
                self.ability:StartCooldown(abilityCooldown)
            end

    end

end


function lycan_companion:SummonWolf(args)
    if (args == nil) then
        return nil
    end
    local caster = args.caster
    local summon = args.unit
    local position = args.position
    local ability = args.ability
    if (caster == nil or summon == nil or position == nil or ability == nil) then
        return nil
    end
    summon = CreateUnitByName(summon, position, true, caster, caster, caster:GetTeamNumber())
    summon:AddNewModifier(caster, self, "modifier_lycan_companion_wolf", {})
    summon:AddNewModifier(caster, self, "modifier_kill", {duration = self.duration})
end


--modifier for lycan companion wolf
modifier_lycan_companion_wolf = modifier_lycan_companion_wolf or class({})



-- Modifier properties
function modifier_lycan_companion_wolf:IsDebuff() return false end
function modifier_lycan_companion_wolf:IsHidden() return true end
function modifier_lycan_companion_wolf:IsPurgable() return false end

function modifier_lycan_companion_wolf:OnCreated()
    if IsServer() then
        local parent			=	self:GetParent()
        local ability			=	self:GetAbility()
        local bleeding	=	parent:FindAbilityByName("lycan_bleeding")
        local double    =   parent:FindAbilityByName("lycan_double_strike")
        -- Level the wolf ability
        bleeding:SetLevel(ability:GetLevel() )
        double:SetLevel(ability:GetLevel() )
    end
end


-- Kill wolf when it's duration is over
function modifier_lycan_companion_wolf:OnDestroy()
    if IsServer() then
        self:GetParent():ForceKill(false)
    end
end

LinkLuaModifier("modifier_lycan_companion_wolf", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)


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

    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    local initial = self:GetSpecialValueFor("initial_damage")
    local Max_health 	    = target:GetMaxHealth();
    local damage 			= Max_health * initial * -0.01;
    --apply a buff dealing initial damage then dot and heal negation
    --initial damage
    local damageTable 			= {}
    damageTable.attacker = self.caster
    damageTable.target = target
    damageTable.ability = nil -- can be nil
    damageTable.damage = damage
    damageTable.puredmg = true
    GameMode:DamageUnit(damageTable)
    --dot
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = caster
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
})

function modifier_lycan_wound_debuff:OnCreated()
    if IsServer() then
        return
    end
    -- call and calculate values
    self.ability = self:GetAbility() --trace back to lycan ability that create this modifier
    self.parent = self:GetParent()
    --dot
    self.dot = self.ability:GetSpecialValueFor("dot")
    self:StartIntervalThink(1.0);
end

function modifier_lycan_wound_debuff:OnIntervalThink() --dot
    print(self.parent)
    local Max_health 	    = self.parent:GetMaxHealth();
    local damage 			= Max_health * self.dot * -0.01;
    local damageTable 			= {};
    damageTable.attacker = self.caster -- wound dot cant be reflect
    damageTable.target = self.parent
    damageTable.ability = nil -- can be nil
    damageTable.damage = damage
    damageTable.puredmg = true
    GameMode:DamageUnit(damageTable)
end


function modifier_lycan_wound_debuff:GetHealthRegenerationPercentBonus() --heal negate
    return -1 --that boi can never regain hp again
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
    self.parent = self:GetParent()
    local modifier = self:GetCaster():FindModifierByName("modifier_lycan_wolf_form")
    if (modifier) then
        self.bat = modifier.ability:GetSpecialValueFor("bat")
        self.crit_factor = modifier.ability:GetSpecialValueFor("crit_factor")
        self.crit_chance = modifier.ability:GetSpecialValueFor("crit_chance")
    end
end

function modifier_lycan_transform:DeclareFunctions()
    local decFuncs = {MODIFIER_PROPERTY_MODEL_CHANGE,
                      MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
                      MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
                      MODIFIER_PROPERTY_MOVESPEED_LIMIT}
    return decFuncs
end

function modifier_lycan_transform:GetModifierMoveSpeed_AbsoluteMin()
        return self.absolute_speed
end

function modifier_lycan_transform:GetModifierMoveSpeed_Limit()
    return 1000
end


function modifier_lycan_transform:GetModifierModelChange()
    return "models/items/lycan/ultimate/hunter_kings_trueform/hunter_kings_trueform.vmdl"
end


function modifier_lycan_transform:GetBaseAttackTime()
    return self.bat
end

function modifier_lycan_transform:GetModifierPreAttack_CriticalStrike()
    if IsServer() then
        if RollPercentage(self.crit_chance) then
            self.parent:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
            return self.crit_factor
        end
        return nil
    end
end

LinkLuaModifier("modifier_lycan_transform", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

function lycan_wolf_form:Transform()
    local particle_cast = "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf"
    local particle_cast_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.caster)
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


function modifier_lycan_wolf_form:OnTakeDamage()
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

})

function modifier_lycan_howl_aura_buff:OnCreated()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
        self.radius = self.ability:GetSpecialValueFor("radius")
        self.as_aura = self.ability:GetSpecialValueFor("as_aura")
        self.ms_aura = self.ability:GetSpecialValueFor("ms_aura")/100
        self.damage_reduce_incoming_pct_aura =  self.ability:GetSpecialValueFor("damage_reduce_incoming_pct_aura")*0.01

end

function modifier_lycan_howl_aura_buff:GetDamageReductionBonus()
    return self.damage_reduce_incoming_pct_aura or 0
end

function modifier_lycan_howl_aura_buff:GetAttackSpeedPercentBonus()
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
    local ability = self:GetCaster():FindAbilityByName("howl_aura")
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


---------------------
--lycan double strike
---------------------

lycan_double_strike = class({
    GetAbilityTextureName = function(self)
        return "lycan_double_strike"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_lycan_double_strike"
    end,})

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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_lycan_double_strike:OnCreated()
    self.parent = self:GetParent()
end


function modifier_lycan_double_strike:OnAttack(keys)
    local ability = self:GetAbility()
    local parent = self:GetParent()
    local ability_level = ability:GetLevel() - 1
    local chance = ability:GetSpecialValueFor("chance", ability_level)
    --eat AS buff if there are any
    if parent:HasModifier("modifier_lycan_double_strike_quick") then
        local mod = parent:FindModifierByName("modifier_lycan_double_strike_quick")
        mod:DecrementStackCount()
        if mod:GetStackCount() < 1 then
            mod:Destroy()
        end
    end
    --add AS buff
    if (keys.attacker == parent and self.ability:IsCooldownReady())  then
        if RollPercentage(chance) then
            parent:AddNewModifier(parent, ability, "modifier_lycan_double_strike_quick", {})
            local abilityCooldown = self.ability:GetCooldown(self.ability:GetLevel())
            self.ability:StartCooldown(abilityCooldown)
        end
    end

end

function modifier_lycan_double_strike:OnRemoved()
    if not IsServer() then return end
    if (self:GetParent():FindModifierByName("modifier_lycan_double_strike_quick")) then
        self:GetParent():FindModifierByName("modifier_lycan_double_strike_quick"):Destroy()
    end
end

--modifier double strike quick hit
modifier_lycan_double_strike_quick = modifier_lycan_double_strike_quick or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_lycan_double_strike_quick:OnCreated()
    local ability = self:GetAbility()
    self.parent = self:GetParent()
    if ability then
        local max_hits = ability:GetSpecialValueFor("max_hits")
        self:SetStackCount(max_hits)
    end
end

function modifier_lycan_double_strike_quick:GetAttackSpeedPercentBonus()
    return 1000
end

LinkLuaModifier("modifier_lycan_double_strike", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lycan_double_strike_quick", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)
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
    local caster            = self:GetCaster();
    local Max_health 	    = parent:GetMaxHealth();
    local damage 			= Max_health * self.dot * -0.01;
    local damageTable 			= {};
    damageTable.caster = caster
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


LinkLuaModifier("modifier_lycan_bleeding_heal_reduced", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)



function modifier_lycan_bleeding:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    if (keys.attacker:HasModifier("modifier_lycan_bleeding")) then
        self.ability:ApplyBleeding(keys.target, self.parent)

    end
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
