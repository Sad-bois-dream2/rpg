---------------------
--lycan call
---------------------
lycan_call = class({
    GetAbilityTextureName = function(self)
        return "lycan_call"
    end,

})

function lycan_call:OnUpgrade()
    if (not IsServer()) then
    end
    self.range = self:GetSpecialValueFor("range")
    self.number = self:GetSpecialValueFor("number")
    self.duration = self:GetSpecialValueFor("duration")
end

function lycan_call:OnSpellStart()
    local caster = self:GetCaster()
    local casterTeam = caster:GetTeamNumber()
    caster:EmitSound("lycan_lycan_ability_summon_0"..math.random(3,6))
    --Find enemies in range
    local enemies = FindUnitsInRadius(casterTeam,
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
        for i = 0, self.number - 1, 1 do
            summon_point = enemy:GetAbsOrigin() + 50 * enemy:GetForwardVector() * i
            local wolf = CreateUnitByName("npc_boss_lycan_call_wolf", summon_point, true, caster, caster, casterTeam)
            wolf:AddNewModifier(caster, self, "modifier_kill", { duration = 5 })
        end
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
        return "modifier_lycan_companion"
    end,
})

function lycan_companion:OnUpgrade()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local modifier = caster:FindModifierByName(self:GetIntrinsicModifierName())
    if (modifier) then
        self.chance = self:GetSpecialValueFor("chance")
        self.cooldown = self:GetCooldown(self:GetLevel())
    end
end

modifier_lycan_companion = class({
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
    self.parentTeam = self.parent:GetTeamNumber()
    self.ability = self:GetAbility()
end

function modifier_lycan_companion:OnAttackLanded(keys)
    if (not IsServer()) then
        return
    end
    --local summon_damage = Units:GetAttackDamage(self.parent) * 0.1 ??? how to give damage
    if (keys.attacker == self.parent and self.ability:IsCooldownReady() and RollPercentage(self.ability.chance)) then
        local summon_point = self.parent:GetAbsOrigin() + 100 * self.parent:GetForwardVector()
        local wolf = CreateUnitByName("npc_boss_lycan_companion_wolf", summon_point, true, self.parent, self.parent, self.parentTeam)
        wolf:AddNewModifier(self.parent, self.ability, "modifier_kill", { duration = 5 })
        self.ability:StartCooldown(self.ability.cooldown)
        if RollPercentage(15) then
        self.parent:EmitSound("lycan_lycan_ally_0"..math.random(3,5))
        end
    end
end

LinkLuaModifier("modifier_lycan_companion", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

---------------------
--lycan wound
---------------------
lycan_wound = class({
    GetAbilityTextureName = function(self)
        return "lycan_wound"
    end,
})

function lycan_wound:ApplyDamageAndDebuff(target, caster)
    local duration = self:GetSpecialValueFor("duration")
    local initial = self:GetSpecialValueFor("initial_damage") * 0.01
    local Max_health = target:GetMaxHealth()
    local damage = Max_health * initial
    local dot = self:GetSpecialValueFor("dot") * 0.01
    --apply a buff dealing initial damage then dot and heal negation
    --initial damage
    local damageTable = {}
    damageTable.caster = caster
    damageTable.target = target
    damageTable.ability = self
    damageTable.damage = damage
    damageTable.puredmg = true
    GameMode:DamageUnit(damageTable)
    --heal negate
    local modifierTable = {}
    modifierTable.caster = caster
    modifierTable.target = target
    modifierTable.ability = self
    modifierTable.modifier_name = "modifier_lycan_wound_debuff"
    modifierTable.modifier_params = { dot = dot }
    modifierTable.duration = duration
    GameMode:ApplyDebuff(modifierTable)
    EmitSoundOn("hero_bloodseeker.rupture", target)
end

function lycan_wound:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    self:ApplyDamageAndDebuff(target, caster)
    if caster:HasModifier("modifier_lycan_transform") then
        caster:EmitSound("lycan_lycan_wolf_attack_08")
    else caster:EmitSound("lycan_lycan_attack_08") end

end

modifier_lycan_wound_debuff = class({
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
    GetEffectName = function(self)
        return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
    end
})

function modifier_lycan_wound_debuff:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    if (not keys or not keys.dot) then
        self:Destroy()
    end
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.dot = keys.dot
    self:StartIntervalThink(1.0)
end

function modifier_lycan_wound_debuff:OnIntervalThink()
    local damageTable = {}
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.damage = self.dot * self.target:GetMaxHealth()
    damageTable.puredmg = true
    GameMode:DamageUnit(damageTable)
end
--heal negate
function modifier_lycan_wound_debuff:GetHealthRegenerationPercentBonus()
    return -1
end

function modifier_lycan_wound_debuff:GetHealingReceivedPercentBonus()
    return -1
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

function lycan_wolf_form:OnUpgrade()
    if (not IsServer()) then
        return
    end
    local modifier = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
    modifier.hp_threshold = self:GetSpecialValueFor("hp_threshold") * 0.01
end

function lycan_wolf_form:Transform()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local casterPosition = caster:GetAbsOrigin()
    local particle_cast_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf", PATTACH_ABSORIGIN, caster)
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_lycan_transform"
    modifierTable.duration = -1
    GameMode:ApplyBuff(modifierTable)
    ParticleManager:SetParticleControl(particle_cast_fx, 0, casterPosition)
    ParticleManager:SetParticleControl(particle_cast_fx, 1, casterPosition)
    ParticleManager:SetParticleControl(particle_cast_fx, 2, casterPosition)
    ParticleManager:SetParticleControl(particle_cast_fx, 3, casterPosition)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(particle_cast_fx, false)
        ParticleManager:ReleaseParticleIndex(particle_cast_fx)
    end)
    caster:EmitSound("Hero_Lycan.Shapeshift.Cast")
end

modifier_lycan_wolf_form = class({
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
        return { MODIFIER_EVENT_ON_TAKEDAMAGE }
    end
})

function modifier_lycan_wolf_form:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_lycan_wolf_form:OnTakeDamage()
    if (not IsServer()) then
        return
    end
    if self.parent:HasModifier("modifier_lycan_transform") then
        -- already transform ? destroy hp check buff
        self:Destroy()
        return
    end
    self.hp_pct = self.parent:GetHealth() / self.parent:GetMaxHealth()
    if self.hp_pct <= self.hp_threshold then
        -- hp drop below threshold = transform
        self.ability:Transform()
        Timers:CreateTimer(5, function() self.ability:EmitSound("lycan_lycan_level_05") end)
    end
end

LinkLuaModifier("modifier_lycan_wolf_form", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lycan_transform = class({
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
    self.ability = self:GetAbility()
    self.bat = self.ability:GetSpecialValueFor("bat")
    self.crit_factor = self.ability:GetSpecialValueFor("crit_factor") / 100
    self.crit_chance = self.ability:GetSpecialValueFor("crit_chance")
    self.ms_absolute = self.ability:GetSpecialValueFor("ms_absolute")
end

function modifier_lycan_transform:GetBaseAttackTime()
    return self.bat
end

function modifier_lycan_transform:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
        MODIFIER_PROPERTY_MODEL_CHANGE,
    }
end

function modifier_lycan_transform:CheckState()
    return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end
function modifier_lycan_transform:GetModifierModelChange()
    return "models/items/lycan/ultimate/hunter_kings_trueform/hunter_kings_trueform.vmdl"
end

function modifier_lycan_transform:GetModifierMoveSpeed_AbsoluteMin()
    return self.ms_absolute
end

---@param damageTable DAMAGE_TABLE
function modifier_lycan_transform:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_lycan_transform")
    if (damageTable.damage > 0 and modifier and GameMode:RollCriticalChance(damageTable.attacker, modifier.crit_chance) and not damageTable.ability and damageTable.physdmg) then
        local victimPosition = damageTable.victim:GetAbsOrigin()
        local crit_particle = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"
        local coup_pfx = ParticleManager:CreateParticle(crit_particle, PATTACH_ABSORIGIN_FOLLOW, damageTable.victim)
        ParticleManager:SetParticleControlEnt(coup_pfx, 0, damageTable.victim, PATTACH_POINT_FOLLOW, "attach_hitloc", victimPosition, true)
        ParticleManager:SetParticleControl(coup_pfx, 1, victimPosition)
        ParticleManager:SetParticleControlOrientation(coup_pfx, 1, damageTable.attacker:GetForwardVector() * (-1), damageTable.attacker:GetRightVector(), damageTable.attacker:GetUpVector())
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(coup_pfx, false)
            ParticleManager:ReleaseParticleIndex(coup_pfx)
        end)
        damageTable.crit = modifier.crit_factor
        return damageTable
    end
end

LinkLuaModifier("modifier_lycan_transform", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

---------------------
--lycan howl aura
---------------------
--howl aura is an active. It has 2 components dmg reduced debuff on enemies and lycan aura active on cast
lycan_howl_aura = class({
    GetAbilityTextureName = function(self)
        return "lycan_howl_aura"
    end
})

modifier_lycan_howl_aura = class({
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.radius or 0
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
        return "modifier_lycan_howl_aura_buff" --  The name of the secondary modifier that will be applied by this modifier (if it is an aura).
    end,
    GetTexture = function(self)
        return lycan_howl_aura:GetAbilityTextureName()
    end
})

function modifier_lycan_howl_aura:OnCreated()
    -- giving lycan primary buff this buff give him secondary modifier aura buff
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.hero = self.ability:GetCaster()
    self.radius = self.ability:GetSpecialValueFor("radius")
end

LinkLuaModifier("modifier_lycan_howl_aura", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lycan_howl_aura_buff = class({
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
        return lycan_howl_aura:GetAbilityTextureName()
    end
})

function modifier_lycan_howl_aura_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.radius = self.ability:GetSpecialValueFor("radius")
    self.as_aura = self.ability:GetSpecialValueFor("as_aura") / 100
    self.ms_aura = self.ability:GetSpecialValueFor("ms_aura") / 100
    self.damage_reduce_incoming_pct_aura = self.ability:GetSpecialValueFor("damage_reduce_incoming_pct_aura") * 0.01
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

modifier_lycan_howl_debuff = class({
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
    GetTexture = function(self)
        return lycan_howl_aura:GetAbilityTextureName()
    end,

})

function modifier_lycan_howl_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.aa_reduction = self.ability:GetSpecialValueFor("dmg_reduce_outgoing_pct") * -0.01
    self.spelldmg_reduction = self.ability:GetSpecialValueFor("dmg_reduce_outgoing_pct") * -0.01
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
        local casterPosition = self.caster:GetAbsOrigin()
        local radius = self:GetSpecialValueFor("radius")
        local particle_lycan_howl = "particles/units/heroes/hero_lycan/lycan_howl_cast.vpcf"
        local particle_lycan_howl_fx = ParticleManager:CreateParticle(particle_lycan_howl, PATTACH_ABSORIGIN, self.caster)
        ParticleManager:SetParticleControl(particle_lycan_howl_fx, 0, casterPosition)
        ParticleManager:SetParticleControl(particle_lycan_howl_fx, 1, casterPosition)
        ParticleManager:SetParticleControl(particle_lycan_howl_fx, 2, casterPosition)
        Timers:CreateTimer(duration, function()
            ParticleManager:DestroyParticle(particle_lycan_howl_fx, false)
            ParticleManager:ReleaseParticleIndex(particle_lycan_howl_fx)
        end)
        self.caster:EmitSound("Hero_Lycan.Howl")
        local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
                casterPosition,
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
})

function lycan_agility:FindTargetForBlink(caster) --random with already hit removal
    if IsServer() then
        local radius = self:GetSpecialValueFor("jump_range")
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
            if (not TableContains(self.already_hit, enemy)) then
                table.insert(self.already_hit, enemy)
                randomEnemy = enemy
                break
            end
        end
        return randomEnemy
    end
end

function lycan_agility:Blink(target, caster)
    if not IsServer() then
        return
    end
    if (target == nil) then
        return
    end

    local start_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_nether_strike_begin.vpcf", PATTACH_ABSORIGIN, caster)

    local targetPosition = target:GetAbsOrigin()
    local vector = (targetPosition - caster:GetAbsOrigin())
    local direction = vector:Normalized()
    -- move to 54 range on the back of target
    FindClearSpaceForUnit(self:GetCaster(), target:GetAbsOrigin() + ((target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * (54)), false)

    ProjectileManager:ProjectileDodge(caster)
    ParticleManager:SetParticleControl(start_particle, 2, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(start_particle)
    local end_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_nether_strike_end.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:ReleaseParticleIndex(end_particle)
    Aggro:Reset(caster)
    Aggro:Add(target, caster, 100)
    caster:PerformAttack(target, true, true, true, true, false, false, false)
    caster:SetForwardVector(direction)
end

modifier_lycan_agility_buff = class({
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

function modifier_lycan_agility_buff:OnCreated(keys)
    if not IsServer() then
        return
    end
    if (not keys or keys.target) then
        self:Destroy()
    end
    self.target = keys.target
end

function modifier_lycan_agility_buff:GetIgnoreAggroTarget()
    return self.target
end

function modifier_lycan_agility_buff:GetCriticalChanceBonus()
    return 2 -- 300% crit chance
end


LinkLuaModifier("modifier_lycan_agility_buff", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

function lycan_agility:OnSpellStart()
    if not IsServer() then
        return
    end

    local target = self:GetCursorTarget()
    local caster = self:GetCaster()
    --apply ignore aggro
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_lycan_agility_buff"
    modifierTable.modifier_params = { target = target }
    modifierTable.duration = -1
    GameMode:ApplyBuff(modifierTable)
    --set table for already hit
    self.already_hit = {}
    self:Blink(target, caster) --first target on cursor mostly gonna be tank
    table.insert(self.already_hit, target)
    --next target
    target = self:FindTargetForBlink(caster)
    Timers:CreateTimer(1.5, function()
        --other targets 1.5 s delay from first and 1.5s delay on every target after
        if target ~= nil then
            --remove ignore aggro
            caster:RemoveModifierByName("modifier_lycan_agility_buff")
            --add new ignore aggro
            modifierTable.ability = self
            modifierTable.target = caster
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_lycan_agility_buff"
            modifierTable.modifier_params = { target = target }
            modifierTable.duration = -1
            GameMode:ApplyBuff(modifierTable)
            --smash
            self:Blink(target, caster)
            --new target
            target = self:FindTargetForBlink(caster)
            return 1.5
        end
    end)
    Aggro:Reset(caster)
    Aggro:Add(target, caster, 100)
    caster:RemoveModifierByName("modifier_lycan_agility_buff")
end



---------------------
--lycan double strike
---------------------

lycan_double_strike = class({
    GetAbilityTextureName = function(self)
        return "lycan_double_strike"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_lycan_double_strike"
    end
})

function lycan_double_strike:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.chance = self:GetSpecialValueFor("chance")
    self.cooldown = self:GetCooldown(self:GetLevel())
    self.max_hits = self:GetSpecialValueFor("max_hits")
end

modifier_lycan_double_strike = class({
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
end

function modifier_lycan_double_strike:OnAttackLanded(keys)
    if (not IsServer() or keys.attacker ~= self.parent) then
        return
    end
    --eat AS buff if there are any
    local modifier = keys.attacker:FindModifierByName("modifier_lycan_double_strike_quick")
    if (modifier) then
        local stacks = modifier:GetStackCount() - 1
        modifier:SetStackCount(stacks)
        if (stacks < 1) then
            modifier:Destroy()
        end
    else
        --add AS buff
        if (self.ability:IsCooldownReady() and RollPercentage(self.ability.chance)) then
            local modifierTable = {}
            modifierTable.ability = self.ability
            modifierTable.target = self.parent
            modifierTable.caster = self.parent
            modifierTable.modifier_name = "modifier_lycan_double_strike_quick"
            modifierTable.duration = -1
            modifierTable.stacks = self.ability.max_hits
            modifierTable.max_stacks = self.ability.max_hits
            GameMode:ApplyStackingBuff(modifierTable)
            self.ability:StartCooldown(self.ability.cooldown)
        end
    end
end

LinkLuaModifier("modifier_lycan_double_strike", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

--modifier double strike quick
modifier_lycan_double_strike_quick = class({
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
    end,
    GetTexture = function(self)
        return lycan_double_strike:GetAbilityTextureName()
    end,
})

function modifier_lycan_double_strike_quick:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.as_bonus = self:GetAbility():GetSpecialValueFor("as_bonus")
end

function modifier_lycan_double_strike_quick:GetAttackSpeedBonus()
    return self.as_bonus
end

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

function lycan_bleeding:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.duration = self:GetSpecialValueFor("duration")
    self.max_stacks = self:GetSpecialValueFor("max_stacks")
end

function lycan_bleeding:ApplyBleeding(target, parent)
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_lycan_bleeding_heal_reduced"
    modifierTable.duration = self.duration
    modifierTable.stacks = 1
    modifierTable.max_stacks = self.max_stacks
    GameMode:ApplyStackingDebuff(modifierTable)
    modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_lycan_bleeding_dot"
    modifierTable.duration = self.duration
    modifierTable.stacks = 1
    modifierTable.max_stacks = self.max_stacks
    GameMode:ApplyStackingDebuff(modifierTable)
end

modifier_lycan_bleeding = class({
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

function modifier_lycan_bleeding:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    if (keys.attacker == self.parent) then
        self.ability:ApplyBleeding(keys.target, self.parent)
    end
end

LinkLuaModifier("modifier_lycan_bleeding", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lycan_bleeding_dot = class({
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
        return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
    end
})

function modifier_lycan_bleeding_dot:OnCreated()
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.ability = self:GetAbility()
    self.dot = self.ability:GetSpecialValueFor("dot") * 0.01
    self:StartIntervalThink(1.0)
end

function modifier_lycan_bleeding_dot:OnIntervalThink()
    local maxHealth = self.target:GetMaxHealth()
    local damage = maxHealth * self.dot * self:GetStackCount()
    local damageTable = {}
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.damage = damage
    damageTable.puredmg = true
    GameMode:DamageUnit(damageTable)
end

LinkLuaModifier("modifier_lycan_bleeding_dot", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lycan_bleeding_heal_reduced = class({
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
    self.heal_reduced = self:GetAbility():GetSpecialValueFor("heal_reduced") * (self:GetStackCount() + 1) * -0.01
end

function modifier_lycan_bleeding_heal_reduced:OnRefresh()
    if (not IsServer()) then
        return
    end
    self:OnCreated()
end

function modifier_lycan_bleeding_heal_reduced:GetHealthRegenerationPercentBonus()
    return self.heal_reduced
end

function modifier_lycan_bleeding_heal_reduced:GetHealingReceivedPercentBonus()
    return self.heal_reduced
end

LinkLuaModifier("modifier_lycan_bleeding_heal_reduced", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

if (IsServer() and not GameMode.ZONE1_BOSS_LYCAN) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_lycan_transform, 'OnTakeDamage'))
    GameMode.ZONE1_BOSS_LYCAN = true
end
