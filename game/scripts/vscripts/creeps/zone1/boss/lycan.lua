------------
--Helper function
-------------
function RotateVectorAroundAngle( vec, angle )
    local x = vec[1]
    local y = vec[2]
    angle = angle * 0.01745
    local vec2 = Vector(0,0,0)
    vec2[1] = x * math.cos(angle) - y * math.sin(angle)
    vec2[2] = x * math.sin(angle) + y * math.cos(angle)
    return vec2
end

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
            wolf:AddNewModifier(caster, self, "modifier_kill", { duration = 30 })
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
        wolf:AddNewModifier(self.parent, self.ability, "modifier_kill", { duration = 30 })
        self.ability:StartCooldown(self.ability.cooldown)
        if RollPercentage(25) then
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

function lycan_wound:IsRequireCastbar()
    return true
end

function lycan_wound:IsInterruptible()
    return false
end

function lycan_wound:ApplyDamageAndDebuff(target, caster)
    local duration = self:GetSpecialValueFor("duration")
    local initial = self:GetSpecialValueFor("initial_damage") * 0.01
    local Max_health = target:GetMaxHealth()
    local damage = Max_health * initial
    local dot = self:GetSpecialValueFor("dot") * 0.01
    --apply a buff dealing initial damage then dot and heal negation
    --initial damage --dont need to check IsAlive here because its instant
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

function lycan_wound:OnAbilityPhaseStart()
    if IsServer() then
        local caster = self:GetCaster()
        local bound = "particles/econ/items/spectre/spectre_transversant_soul/spectre_ti7_crimson_spectral_dagger_path_owner_impact.vpcf"
        self.bound_fx = ParticleManager:CreateParticle(bound, PATTACH_POINT_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(self.bound_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    end

    return true
end

function lycan_wound:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    ParticleManager:DestroyParticle(self.bound_fx, false)
    ParticleManager:ReleaseParticleIndex(self.bound_fx)
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
        return true
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
    if self.caster:IsAlive() then
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = self.target
        damageTable.ability = self.ability
        damageTable.damage = self.dot * self.target:GetMaxHealth()
        damageTable.puredmg = true
        GameMode:DamageUnit(damageTable)
    end
end
--set 0
function modifier_lycan_wound_debuff:GetHealthRegenerationPercentBonusMulti()
    return 0
end

function modifier_lycan_wound_debuff:GetHealingReceivedPercentBonusMulti()
    return 0
end

LinkLuaModifier("modifier_lycan_wound_debuff", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

-------------
--lycan lupine
----------------

-- Slow modifier
modifier_lycan_lupine = class({
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
        return lycan_lupine:GetAbilityTextureName()
    end,
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_enchantress_enchant_slow.vpcf"
    end,
})

function modifier_lycan_lupine:GetAttackSpeedPercentBonusMulti()
    return self.slowmulti
end

function modifier_lycan_lupine:GetMoveSpeedPercentBonusMulti()
    return self.slowmulti
end

function modifier_lycan_lupine:GetSpellHasteBonusMulti()
    return self.slowmulti
end

function modifier_lycan_lupine:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.slow = self.ability:GetSpecialValueFor("slow") * -0.01
    self.slowmulti = self.slow + 1
end


LinkLuaModifier("modifier_lycan_lupine", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

lycan_lupine = class({
    GetAbilityTextureName = function(self)
        return "lycan_lupine"
    end,
})

function lycan_lupine:IsRequireCastbar()
    return true
end

function lycan_lupine:IsInterruptible()
    return false
end

function lycan_lupine:LupineShower(caster, pos, lifetimeinticks, tickdelay, movement,aoe, damage  )
    if not caster:IsNull() then
        local offset_start = math.random(0,359)
        local strikepos = pos
        --each set of explosion have different pattern
        local responses =
        {
            "from_out_inwards",
            "spiral_in_random",
        }
        local aoetype = responses[RandomInt(1, #responses)]
        print(aoetype)
        -- boss aoe random
        if aoetype == "from_out_inwards" then
            strikepos = pos + Vector(1500*math.cos(math.rad(offset_start)), 1500*math.sin(math.rad(offset_start)), 0)
            local direction = (pos - strikepos):Normalized()
            for i=1, lifetimeinticks do
                Timers:CreateTimer(tickdelay*(i-1), function()
                    strikepos = strikepos + i*movement*direction
                    self:LupineAoe(caster, aoe, strikepos, damage)
                end)
            end
        elseif aoetype == "spiral_in_random" then
            for i=1, lifetimeinticks do
                Timers:CreateTimer(tickdelay*(lifetimeinticks-i), function()
                    strikepos = strikepos + Vector((lifetimeinticks-i)*movement*math.cos(math.rad(offset_start+i*20)), (lifetimeinticks-i)*movement*math.sin(math.rad(offset_start+i*20)), 0)
                    self:LupineAoe(caster, aoe, strikepos, damage)
                end)
            end
        end
    end
end


function lycan_lupine:LupineAoe(caster, aoe, strikepos, damage)
    if not caster:IsNull() then
        --explode
        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
                strikepos,
                nil,
                aoe,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO ,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            if caster:IsAlive() then
                local damageTable = {}
                damageTable.caster = caster
                damageTable.target = enemy
                damageTable.ability = self
                damageTable.damage = damage
                damageTable.physdmg = true
                GameMode:DamageUnit(damageTable)
                local modifierTable = {}
                modifierTable.ability = self
                modifierTable.target = enemy
                modifierTable.caster = caster
                modifierTable.modifier_name = "modifier_lycan_lupine"
                modifierTable.duration = self:GetSpecialValueFor("duration")
                GameMode:ApplyDebuff(modifierTable)
            end
        end
        local particle_cast = "particles/units/npc_boss_lycan/lycan_lupine/lupine_explode.vpcf"
        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl( effect_cast, 0, strikepos)
        ParticleManager:SetParticleControl( effect_cast, 1, Vector( aoe, aoe, aoe ) )
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(effect_cast, false)
            ParticleManager:ReleaseParticleIndex(effect_cast)
        end)
    end
end


function lycan_lupine:OnAbilityPhaseStart()
    if IsServer() then
        local caster = self:GetCaster()
        local bound = "particles/econ/items/spectre/spectre_transversant_soul/spectre_ti7_crimson_spectral_dagger_path_owner_impact.vpcf"
        self.bound_fx = ParticleManager:CreateParticle(bound, PATTACH_POINT_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(self.bound_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    end

    return true
end

function lycan_lupine:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(self.bound_fx, false)
        ParticleManager:ReleaseParticleIndex(self.bound_fx)
    end)
    --random explosion
    local pos = caster:GetAbsOrigin()
    local lifetimeinticks = 30
    local tickdelay = 0.5
    local movement = 50
    local aoe = 315
    local counter2 = 0
    local number2 = self:GetSpecialValueFor("number_of_lupine_set")
    local damage = self:GetSpecialValueFor("damage")
    EmitSoundOn("lycan_lycan_battlebegins_01", caster)
    Timers:CreateTimer(0, function()
        if counter2 < number2 then
            self:LupineShower(caster, pos, lifetimeinticks, tickdelay, movement,aoe, damage  )
            counter2 = counter2 +1
            return 1
        end
    end)
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
    if not caster:IsNull() then
        caster:EmitSound("Hero_Lycan.Shapeshift.Cast")
        ParticleManager:SetParticleControl(particle_cast_fx, 0, casterPosition)
        ParticleManager:SetParticleControl(particle_cast_fx, 1, casterPosition)
        ParticleManager:SetParticleControl(particle_cast_fx, 2, casterPosition)
        ParticleManager:SetParticleControl(particle_cast_fx, 3, casterPosition)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(particle_cast_fx, false)
            ParticleManager:ReleaseParticleIndex(particle_cast_fx)
        end)
    end
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

function modifier_lycan_wolf_form:OnTakeDamage(keys)
    if (not IsServer()) then
        return
    end
    if keys.unit == self.parent then
        if self.parent:HasModifier("modifier_lycan_transform") then
            -- already transform ? destroy hp check buff
            self:Destroy()
            return
        end
        self.hp_pct = self.parent:GetHealth() / self.parent:GetMaxHealth()
        if self.hp_pct <= self.hp_threshold then
            -- hp drop below threshold = transform
            self.ability:Transform()
        end
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
    if (damageTable.damage > 0 and modifier and GameMode:RollCriticalChance(damageTable.attacker, modifier.crit_chance) and not damageTable.ability and damageTable.physdmg and damageTable.attacker:IsAlive()) then
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
    self.aa_reduction_multi = 1 + self.aa_reduction
    self.spelldmg_reduction = self.ability:GetSpecialValueFor("dmg_reduce_outgoing_pct") * -0.01
    self.spelldmg_reduction = 1 + self.spelldmg_reduction
end

function modifier_lycan_howl_debuff:GetAttackDamagePercentBonusMulti()
    return self.aa_reduction_multi
end

function modifier_lycan_howl_debuff:GetSpellDamageBonusMulti()
    return self.spelldmg_reduction_multi
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
--attack damage and crit bonus

modifier_lycan_agility_attack = class({
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
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end,
})


function modifier_lycan_agility_attack:OnCreated()
    if not IsServer() then
        return
    end
    self.ad = self:GetAbility():GetSpecialValueFor("attack_bonus") * 0.01
    self.crit = self:GetAbility():GetSpecialValueFor("crit_chance_bonus")*0.01
end

function modifier_lycan_agility_attack:GetAttackDamagePercentBonus()
    return self.ad
end

function modifier_lycan_agility_attack:GetCriticalChanceBonus()
    return self.crit
end


LinkLuaModifier("modifier_lycan_agility_attack", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

--ignore aggro and invul
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
    GetStatusEffectName = function(self)
        return "particles/units/npc_boss_luna/luna_cruelty/luna_cruelty.vpcf"
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

function modifier_lycan_agility_buff:CheckState()
    local state = { [MODIFIER_STATE_INVULNERABLE] = true,
                    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
    return state
end


function modifier_lycan_agility_buff:GetIgnoreAggroTarget()
    return self.target
end

LinkLuaModifier("modifier_lycan_agility_buff", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)

lycan_agility = class({
    GetAbilityTextureName = function(self)
        return "lycan_agility"
    end,
})


function lycan_agility:IsRequireCastbar()
    return true
end

function lycan_agility:IsInterruptible()
    return true
end


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


function lycan_agility:OnAbilityPhaseStart()
    if IsServer() then
        local caster = self:GetCaster()
        local bound = "particles/units/npc_boss_venge/venge_control/nevermore_loadout_purple.vpcf"
        self.bound_fx = ParticleManager:CreateParticle(bound, PATTACH_ABSORIGIN, caster)
        --ParticleManager:SetParticleControlEnt(self.bound_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    end

    return true
end


function lycan_agility:OnSpellStart()
    if not IsServer() then
        return
    end

    local target = self:GetCursorTarget()
    local caster = self:GetCaster()
    local sound = "lycan_lycan_attack_05"
    EmitSoundOn(sound, caster)
    ParticleManager:DestroyParticle(self.bound_fx, false)
    ParticleManager:ReleaseParticleIndex(self.bound_fx)
    --apply ignore aggro
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_lycan_agility_buff"
    modifierTable.duration = -1
    GameMode:ApplyBuff(modifierTable)
    --apply attack buff
    modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_lycan_agility_attack"
    modifierTable.duration = -1
    GameMode:ApplyBuff(modifierTable)
    --set table for already hit
    self.already_hit = {}
    self:Blink(target, caster) --first target on cursor mostly gonna be tank
    table.insert(self.already_hit, target)

    --next target
    target = self:FindTargetForBlink(caster)
    --if only 1 remove buff
    if target == nil then
        --delay remove attack multiplier
        Timers:CreateTimer(1, function ()
            if caster:HasModifier("modifier_lycan_agility_attack") then
                caster:RemoveModifierByName("modifier_lycan_agility_buff")
                caster:RemoveModifierByName("modifier_lycan_agility_attack")
                return 0.1
            end
        end)
    end
    --check for more target
    Timers:CreateTimer(1, function()
        --other targets 1 s delay from first and 1s delay on every target after
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
            --attack multiplier
            modifierTable.ability = self
            modifierTable.target = caster
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_lycan_agility_attack"
            modifierTable.duration = -1
            GameMode:ApplyBuff(modifierTable)
            --smash
            self:Blink(target, caster)
            --new target
            target = self:FindTargetForBlink(caster)
            --when he cannot find target
            if target == nil then
                --delay remove attack multiplier
                Timers:CreateTimer(2, function ()
                    if caster:HasModifier("modifier_lycan_agility_attack") then
                        caster:RemoveModifierByName("modifier_lycan_agility_buff")
                        caster:RemoveModifierByName("modifier_lycan_agility_attack")
                        return 0.1
                    end
                end)
            end
            return 1
        end
    end)
    Aggro:Reset(caster)
    Aggro:Add(target, caster, 100)

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
    end,
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
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
    end,
    GetTexture = function(self)
        return lycan_bleeding:GetAbilityTextureName()
    end,
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
    --if self.caster:IsAlive() then --Bleed should still work after caster ded wolf can apply bleed. Intentionally remove IsAlive() check.
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = self.target
        damageTable.ability = self.ability
        damageTable.damage = damage
        damageTable.puredmg = true
        GameMode:DamageUnit(damageTable)
    --end
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
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return lycan_bleeding:GetAbilityTextureName()
    end,
})

function modifier_lycan_bleeding_heal_reduced:OnCreated()
    if not IsServer() then
        return
    end
    --not fixing because already working first loop getstack count = 0 then get +1, every loop after get stacks - 1 but alse get +1
    self.heal_reduced = self:GetAbility():GetSpecialValueFor("heal_reduced") * (self:GetStackCount() + 1) * -0.01
    self.heal_reduced_multi = self.heal_reduced + 1
end

function modifier_lycan_bleeding_heal_reduced:OnRefresh()
    if (not IsServer()) then
        return
    end
    self:OnCreated()
end

function modifier_lycan_bleeding_heal_reduced:GetHealthRegenerationPercentBonusMulti()
    return self.heal_reduced_multi
end

function modifier_lycan_bleeding_heal_reduced:GetHealingReceivedPercentBonusMulti()
    return self.heal_reduced_multi
end

LinkLuaModifier("modifier_lycan_bleeding_heal_reduced", "creeps/zone1/boss/lycan.lua", LUA_MODIFIER_MOTION_NONE)


if (IsServer() and not GameMode.ZONE1_BOSS_LYCAN) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_lycan_transform, 'OnTakeDamage'))
    GameMode.ZONE1_BOSS_LYCAN = true
end
