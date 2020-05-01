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
    if (args.casterTeam == nil or caster == nil or summon == nil or position == nil or ability == nil) then
        return nil
    end
    summon = CreateUnitByName(summon, position, true, caster, caster, args.casterTeam)
    summon:AddNewModifier(caster, self, "modifier_kill", { duration = self.duration })
    return summon
end

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
    caster:EmitSound("lycan_lycan_ability_summon_03")
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
            local summon_damage = Units:GetAttackDamage(caster) * 0.1
            self:SummonWolf({ caster = caster, casterTeam = casterTeam, unit = "npc_boss_lycan_call_wolf", position = summon_point, damage = summon_damage, ability = self })
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
    self.parentTeam = self.parent:GetTeam()
    self.ability = self:GetAbility()
end

function modifier_lycan_companion:OnAttackLanded(keys)
    if (not IsServer()) then
        return
    end
    --local summon_damage = Units:GetAttackDamage(self.parent) * 0.1 ??? how to give damage
    if (keys.attacker == self.parent and self.ability:IsCooldownReady() and RollPercentage(self.chance)) then
        local summon_point = self.parent:GetAbsOrigin() + 100 * self.parent:GetForwardVector()
        local wolf = CreateUnitByName("npc_boss_lycan_companion_wolf", summon_point, true, self.parent, self.parent, self.parentTeam)
        wolf:AddNewModifier(self.parent, self.ability, "modifier_kill", { duration = 5 })
        self.ability:StartCooldown(self.cooldown)
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
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    -- call and calculate values
    --local ability = self:GetAbility() --or self:GetCaster():FindAbilityByName("lycan_wound")--trace back to lycan ability that create this modifier
    --self.parent = self:GetParent()
    -- --dot
    -- if (ability) then
    --   self.dot = ability:GetSpecialValueFor("dot") * 0.01
    self:StartIntervalThink(1.0)
    -- end
end

-- function modifier_lycan_wound_debuff:OnIntervalThink()
-- if IsServer() then
--   local parent            = self:GetParent()
--   local caster            = self:GetCaster()
--   local damage            = self.dot * parent:GetMaxHealth()
--   local damageTable       = {}
--  damageTable.caster = caster
--   damageTable.target = parent
--   damageTable.ability = nil
--   damageTable.damage = damage
--   damageTable.puredmg = true
--   GameMode:DamageUnit(damageTable)
--  end
--end


function modifier_lycan_wound_debuff:GetHealthRegenerationPercentBonus()
    --heal negate
    return -1 --that boi can never regain hp again
end

function modifier_lycan_wound_debuff:GetStatusEffectName()
    return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

LinkLuaModifier("modifier_lycan_wound_debuff", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

function lycan_wound:ApplyDamagethendebuff(target, caster)
    if (not IsServer()) then
        return
    end
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
    modifierTable.duration = duration
    GameMode:ApplyDebuff(modifierTable)
    EmitSoundOn("hero_bloodseeker.rupture", target)
    --dot damage
    --somehow dot debuff interval code doesn't work so i will put it here current idea is undispellable anyway
    damage = Max_health * dot
    local counter = 0
    Timers:CreateTimer(0, function()
        if counter < 5 then
            damageTable = {}
            damageTable.caster = caster
            damageTable.target = target
            damageTable.ability = nil
            damageTable.damage = damage
            damageTable.puredmg = true
            GameMode:DamageUnit(damageTable)
            counter = counter + 1
            return 1.0
        end
    end)
end

function lycan_wound:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    self:ApplyDamagethendebuff(target, caster)
end

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

LinkLuaModifier("modifier_lycan_wolf_form", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lycan_transform = modifier_lycan_transform or class({
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
        self.ms_bonus = modifier.ability:GetSpecialValueFor("ms_bonus")
    end
end

function modifier_lycan_transform:DeclareFunctions()
    local decFuncs = { MODIFIER_PROPERTY_MODEL_CHANGE,
                       MODIFIER_EVENT_ON_ATTACK_LANDED }
    return decFuncs
end

function modifier_lycan_transform:GetMoveSpeedPercentBonus()
    return self.ms_bonus
end

function modifier_lycan_transform:GetModifierModelChange()
    return "models/items/lycan/ultimate/hunter_kings_trueform/hunter_kings_trueform.vmdl"
end

function modifier_lycan_transform:GetBaseAttackTime()
    return self.bat
end

function modifier_lycan_transform:GetModifierPreAttack_CriticalStrike(keys)
    --crit damage
    if IsServer() then
        if RollPercentage(self.crit_chance) then
            self.crit_strike = true
            return self.crit_factor
        end
        self.crit_strike = false
        return nil
    end
end

function modifier_lycan_transform:OnAttackLanded(keys)
    --crit particle
    local target = keys.target
    local attacker = keys.attacker
    if (keys.attacker == self.parent and RollPercentage(self.crit_chance)) then
        self.parent:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
        local crit_particle = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"
        local coup_pfx = ParticleManager:CreateParticle(crit_particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControlEnt(coup_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(coup_pfx, 1, target:GetAbsOrigin())
        ParticleManager:SetParticleControlOrientation(coup_pfx, 1, self:GetParent():GetForwardVector() * (-1), self:GetParent():GetRightVector(), self:GetParent():GetUpVector())
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(coup_pfx, false)
            ParticleManager:ReleaseParticleIndex(coup_pfx)
        end)
        local attack_damage = keys.attacker:GetAttackDamage()
        local damageTable = {}
        damageTable.damage = attack_damage
        damageTable.crit = self.crit_factor
        damageTable.caster = attacker
        damageTable.target = target
        damageTable.physdmg = true
        damageTable.ability = nil
        GameMode:DamageUnit(damageTable)
    end
end

LinkLuaModifier("modifier_lycan_transform", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

function lycan_wolf_form:Transform()
    if (not IsServer()) then
        return
    end
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
    ParticleManager:SetParticleControl(particle_cast_fx, 0, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_cast_fx, 1, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_cast_fx, 2, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_cast_fx, 3, self.caster:GetAbsOrigin())
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(particle_cast_fx, false)
        ParticleManager:ReleaseParticleIndex(particle_cast_fx)
    end)
    self.caster:EmitSound("Hero_Lycan.Shapeshift.Cast")
end

function modifier_lycan_wolf_form:OnTakeDamage()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.hp_threshold = self.ability:GetSpecialValueFor("hp_threshold") * 0.01
    self.hp_pct = self.parent:GetHealth() / self.parent:GetMaxHealth()
    if self.parent:HasModifier("modifier_lycan_transform") then
        -- already transform ? destroy hp check buff
        self.parent:RemoveModifierByName("modifier_lycan_wolf_form")
    end
    if self.hp_pct <= self.hp_threshold then
        -- hp drop below threshold = transform
        self.ability:Transform()
    end
end

---------------------
--lycan howl aura
---------------------
--howl aura is an active. It has 2 components dmg reduced debuff on enemies and lycan aura active on cast
lycan_howl_aura = class({
    GetAbilityTextureName = function(self)
        return "lycan_howl_aura"
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
        return "modifier_lycan_howl_aura_buff" --  The name of the secondary modifier that will be applied by this modifier (if it is an aura).
    end,
    GetTexture = function(self)
        return lycan_howl_aura:GetAbilityTextureName()
    end,

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
    GetTexture = function(self)
        return lycan_howl_aura:GetAbilityTextureName()
    end,

})

function modifier_lycan_howl_aura_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.radius = self.ability:GetSpecialValueFor("radius")
    self.as_aura = self.ability:GetSpecialValueFor("as_aura")
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
        local radius = self:GetSpecialValueFor("radius")
        local particle_lycan_howl = "particles/units/heroes/hero_lycan/lycan_howl_cast.vpcf"
        local particle_lycan_howl_fx = ParticleManager:CreateParticle(particle_lycan_howl, PATTACH_ABSORIGIN, self.caster)
        ParticleManager:SetParticleControl(particle_lycan_howl_fx, 0, self.caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_lycan_howl_fx, 1, self.caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_lycan_howl_fx, 2, self.caster:GetAbsOrigin())
        self.caster:EmitSound("Hero_Lycan.Howl")
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
})

function lycan_agility:FindTargetForBlink(caster)
    if IsServer() then
        local radius = self:GetSpecialValueFor("jump_range")
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
        if (randomEnemy) then
            return randomEnemy
        else
            return nil
        end
    end
end

function lycan_agility:Blink(target, caster)
    if not IsServer() then
        return
    end
    if (target == nil) then
        return
    end
    --self:GetCaster():EmitSound("Hero_Spirit_Breaker.NetherStrike.End")
    local start_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_nether_strike_begin.vpcf", PATTACH_ABSORIGIN, caster)

    local targetPosition = target:GetAbsOrigin()
    local vector = (targetPosition - caster:GetAbsOrigin())
    local direction = vector:Normalized()
    -- "Nether Strike instantly moves Spirit Breaker on the opposite side of the target, 54 range away from it."
    FindClearSpaceForUnit(self:GetCaster(), target:GetAbsOrigin() + ((target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * (54)), false)

    -- IMBAfication: Warp Beast
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

modifier_lycan_agility_buff = modifier_lycan_agility_buff or class({
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

function modifier_lycan_agility_buff:OnCreated()
    if not IsServer() then
        return
    end
end

function modifier_lycan_agility_buff:GetIgnoreAggroTarget()
    return self.caster
end

LinkLuaModifier("modifier_lycan_agility_buff", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

function lycan_agility:OnSpellStart()
    if not IsServer() then
        return
    end

    local target = self:GetCursorTarget()
    local caster = self:GetCaster()
    --apply ignore aggro, is it working kekw
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_lycan_agility_buff"
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
            self:Blink(target, caster)
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
    end, })

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
    self.chance = self.ability:GetSpecialValueFor("chance")

end

LinkLuaModifier("modifier_lycan_double_strike", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_lycan_double_strike:OnAttackLanded(keys)
    if (not IsServer()) then
        return
    end
    --eat AS buff if there are any
    if (keys.attacker:HasModifier("modifier_lycan_double_strike_quick")) then
        local mod = keys.attacker:FindModifierByName("modifier_lycan_double_strike_quick")
        mod:DecrementStackCount()
        if mod:GetStackCount() < 1 then
            mod:Destroy()
        end
    else
        --add AS buff
        if (keys.attacker == self.parent and self.ability:IsCooldownReady()) then
            if RollPercentage(self.chance) then
                self.ability:ApplyQuick(self.parent)
                local abilityCooldown = self.ability:GetCooldown(self.ability:GetLevel())
                self.ability:StartCooldown(abilityCooldown)
            end
        end

    end

end

function lycan_double_strike:ApplyQuick(parent)
    --apply AS bonus
    local max_stacks = 5
    local max_hits = self:GetSpecialValueFor("max_hits")
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = parent
    modifierTable.caster = parent
    modifierTable.modifier_name = "modifier_lycan_double_strike_quick"
    modifierTable.duration = -1
    modifierTable.stacks = max_hits
    modifierTable.max_stacks = max_stacks
    GameMode:ApplyStackingBuff(modifierTable)
end


--modifier double strike quick
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
    end,
    GetTexture = function(self)
        return lycan_double_strike:GetAbilityTextureName()
    end,
})

function modifier_lycan_double_strike_quick:OnCreated()
    if (not IsServer()) then
        return
    end
    self.as_bonus = 0
    local modifier = self:GetCaster():FindModifierByName("modifier_lycan_double_strike")
    if (modifier) then
        self.as_bonus = modifier.ability:GetSpecialValueFor("as_bonus")
    end
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

        self.dot = modifier.ability:GetSpecialValueFor("dot") * 0.01
        self:StartIntervalThink(1.0);
    end
end

function modifier_lycan_bleeding_dot:OnIntervalThink()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local Max_health = parent:GetMaxHealth()
    local mod_bleed = self:GetParent():FindModifierByName("modifier_lycan_bleeding_dot")
    local damage = Max_health * self.dot * mod_bleed:GetStackCount()
    local damageTable = {}
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
        local mod_heal = self:GetParent():FindModifierByName("modifier_lycan_bleeding_heal_reduced")
        self.heal_reduced = modifier.ability:GetSpecialValueFor("heal_reduced") * (mod_heal:GetStackCount() + 1) * -0.01
        --if no +1 the heal reduced effect seem delay by 1 stack
    end
end

function modifier_lycan_bleeding_heal_reduced:OnRefresh()
    self:OnCreated()
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

function lycan_bleeding:ApplyBleeding(target, parent)

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

function modifier_lycan_bleeding_dot:GetStatusEffectName()
    return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end


