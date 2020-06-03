---------------
--HELPER FUNCTION
-----------------
function IsMirana(unit)
    if unit:GetUnitName() == "npc_boss_mirana" then
        return true
    else
        return false
    end
end

-------------
--luna void
------------
luna_void = class({
    GetAbilityTextureName = function(self)
        return "luna_void"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_luna_void"
    end,
})

modifier_luna_void = class({
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
        return true
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})


function modifier_luna_void:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_luna_void:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    if (keys.attacker == self.parent) and keys.attacker:IsAlive() then
        Timers:CreateTimer(0.1,function()
        local radius = self:GetAbility():GetSpecialValueFor("radius")
        local Max_mana = keys.target:GetMaxMana()
        local Mana = keys.target:GetMana()
        local damage = self:GetAbility():GetSpecialValueFor("explode_per_mana") * (Max_mana - Mana)
            if Mana < Max_mana then
                local void_pfx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/antimage_manavoid_ti_5.vpcf", PATTACH_POINT_FOLLOW, keys.target)
                ParticleManager:SetParticleControlEnt(void_pfx, 0, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetOrigin(), true)
                ParticleManager:SetParticleControl(void_pfx, 1, Vector(radius,0,0))
                ParticleManager:ReleaseParticleIndex(void_pfx)
                keys.attacker:EmitSoundParams("Hero_Antimage.ManaVoidCast", 1.0, 0.2, 0) --name pitch volume(81 for base) delay
                keys.target:EmitSoundParams("Hero_Antimage.ManaVoid", 1.0, 0.2, 0)
                -- Find all nearby enemies
                local enemies = FindUnitsInRadius(keys.attacker:GetTeamNumber(),
                        keys.target:GetAbsOrigin(),
                        nil,
                        radius,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false)
                for _, enemy in pairs(enemies) do
                    local damageTable= {}
                    damageTable.caster = keys.attacker
                    damageTable.target = enemy
                    damageTable.ability = self.ability
                    damageTable.damage = damage
                    damageTable.voiddmg = true
                    GameMode:DamageUnit(damageTable)
                end
            end
        end)
    end
end

LinkLuaModifier("modifier_luna_void", "creeps/zone1/boss/luna.lua", LUA_MODIFIER_MOTION_NONE)


--------------
--luna_sky
---------------

modifier_luna_sky = class({
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
        return true
    end,
    DeclareFunctions = function(self)
        return {MODIFIER_PROPERTY_FIXED_DAY_VISION,
                MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
                MODIFIER_EVENT_ON_DEATH }
    end
})

function modifier_luna_sky:OnCreated()
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.ability = self:GetAbility()
    self.fixed_vision = self.ability:GetSpecialValueFor("fixed_vision")
    self:StartIntervalThink(29)
    self:OnIntervalThink()
end

function modifier_luna_sky:GetFixedDayVision()
    return self.fixed_vision
end

function modifier_luna_sky:GetFixedNightVision()
    return self.fixed_vision
end

function modifier_luna_sky:OnDeath(params)
    if (not IsServer()) then
        return
    end
    if params.unit == self.caster  then
        self:Destroy()
    end
end

function modifier_luna_sky:OnIntervalThink()
    self.game_mode = GameRules:GetGameModeEntity()
    GameRules:BeginTemporaryNight(30)
end


LinkLuaModifier("modifier_luna_sky", "creeps/zone1/boss/luna.lua", LUA_MODIFIER_MOTION_NONE)

luna_sky = class({
    GetAbilityTextureName = function(self)
        return "luna_sky"
    end,
})

function luna_sky:OnSpellStart()
    if IsServer() then
        local caster = self:GetCaster()
        local caster_position = self:GetCaster():GetAbsOrigin()
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                30000,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_luna_sky"
            modifierTable.duration = -1
            GameMode:ApplyDebuff(modifierTable)
        end
        self:GetCaster():EmitSound("Hero_Nightstalker.Darkness.Team")
        local particle_moon = "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf"
        local particle_darkness = "particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf"
        local particle_darkness_fx = ParticleManager:CreateParticle(particle_darkness, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(particle_darkness_fx, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_darkness_fx, 1, caster:GetAbsOrigin())
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(particle_darkness_fx, false)
            ParticleManager:ReleaseParticleIndex(particle_darkness_fx)
        end)
        local particle_moon_fx = ParticleManager:CreateParticle(particle_moon, PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(particle_moon_fx, 0, Vector(caster_position.x, caster_position.y, caster_position.z + 400))
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(particle_moon_fx, false)
            ParticleManager:ReleaseParticleIndex(particle_moon_fx)
        end)
    end
end
--------
--luna curse
---------
-- Damage amp modifier

modifier_luna_curse_amp = class({
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
        return  "file://{images}/custom_game/hud/luna/luna_curse_amp.png"--luna_curse:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return  "particles/units/npc_boss_luna/luna_curse/curse_green.vpcf"
    end,
})

function modifier_luna_curse_amp:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.dmg_amp = self.ability:GetSpecialValueFor("dmg_amp") * -0.01
    self.parent = self:GetParent()
    local healFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_POINT_FOLLOW, self.parent)
    Timers:CreateTimer(1, function()
        ParticleManager:DestroyParticle(healFX, false)
        ParticleManager:ReleaseParticleIndex(healFX)
    end)
end

function modifier_luna_curse_amp:GetDamageReductionBonus()
    return self.dmg_amp
end

LinkLuaModifier("modifier_luna_curse_amp", "creeps/zone1/boss/luna.lua", LUA_MODIFIER_MOTION_NONE)

modifier_luna_curse_reduce = class({
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
        return "file://{images}/custom_game/hud/luna/luna_curse_reduce.png"--luna_curse:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/econ/items/lycan/ti9_immortal/lycan_ti9_immortal_howl_buff.vpcf"--
    end,
})

function modifier_luna_curse_reduce:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.reduce = self.ability:GetSpecialValueFor("dmg_reduction") * -0.01
    local healFX = ParticleManager:CreateParticle("particles/units/npc_boss_brood/brood_angry/anger_stack_gain.vpcf", PATTACH_POINT_FOLLOW, self.parent)
    Timers:CreateTimer(1, function()
        ParticleManager:DestroyParticle(healFX, false)
        ParticleManager:ReleaseParticleIndex(healFX)
    end)
end

function modifier_luna_curse_reduce:GetAttackDamagePercentBonus()
    return self.reduce
end

function modifier_luna_curse_reduce:GetSpellDamageBonus()
    return self.reduce
end

function modifier_luna_curse_reduce:GetHealingCausedBonus()
    return self.reduce
end

LinkLuaModifier("modifier_luna_curse_reduce", "creeps/zone1/boss/luna.lua", LUA_MODIFIER_MOTION_NONE)

luna_curse = class({
    GetAbilityTextureName = function(self)
        return "luna_curse"
    end,
})

function luna_curse:OnSpellStart()
    if IsServer() then
        -- Ability properties
        self.caster = self:GetCaster()
        local sound_cast = "Hero_ShadowDemon.DemonicPurge.Cast"


        local sound_impact = "Hero_ShadowDemon.DemonicPurge.Impact"
        -- Ability specials
        local radius = self:GetSpecialValueFor("range")
        local duration = self:GetSpecialValueFor("duration")

        -- Play cast sound
        if RollPercentage(50) then
            EmitSoundOn(sound_cast, self.caster)
        else self.caster:EmitSound("luna_luna_attack_26")
        end
        -- Find all nearby enemies
        local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
                self.caster:GetAbsOrigin(),
                nil,
                radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)

        for _, enemy in pairs(enemies) do
            -- Apply debuff on them
            if RollPercentage(50) then
                local modifierTable = {}
                modifierTable.ability = self
                modifierTable.target = enemy
                modifierTable.caster = self.caster
                modifierTable.modifier_name = "modifier_luna_curse_amp"
                modifierTable.duration = duration
                GameMode:ApplyDebuff(modifierTable)
                enemy:EmitSound(sound_impact)
            else local modifierTable = {}
                modifierTable.ability = self
                modifierTable.target = enemy
                modifierTable.caster = self.caster
                modifierTable.modifier_name = "modifier_luna_curse_reduce"
                modifierTable.duration = duration
                GameMode:ApplyDebuff(modifierTable)
                enemy:EmitSound(sound_impact)
            end
        end
    end
end
-------------
--luna wave
---------------
-- Damage amp modifier
modifier_luna_wave_amp = class({
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
        return luna_wave:GetAbilityTextureName()
    end,
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_gush.vpcf"
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
})

function modifier_luna_wave_amp:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.amp = self.ability:GetSpecialValueFor("amp") * -0.01
end

function modifier_luna_wave_amp:GetDamageReductionBonus()
    return self.amp
end

LinkLuaModifier("modifier_luna_wave_amp", "creeps/zone1/boss/luna.lua", LUA_MODIFIER_MOTION_NONE)

luna_wave = class({
    GetAbilityTextureName = function(self)
        return "luna_wave"
    end,
})

function luna_wave:IsRequireCastbar()
    return true
end

function luna_wave:IsInterruptible()
    return true
end

function luna_wave:OnAbilityPhaseStart()
    if IsServer() then
        local caster = self:GetCaster()
        local bound = "particles/econ/items/spectre/spectre_transversant_soul/spectre_transversant_spectral_dagger_path_owner_impact.vpcf"
        self.bound_fx = ParticleManager:CreateParticle(bound, PATTACH_POINT_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(self.bound_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(self.bound_fx)
    end

    return true
end

function luna_wave:OnSpellStart()
    local range = self:GetSpecialValueFor("range")
    local caster = self:GetCaster()
    -- Find all nearby enemies
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
            self:GetCaster():GetAbsOrigin(),
            nil,
            range,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO ,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)

    for _, enemy in pairs(enemies) do
        -- This "dummy" literally only exists to attach the gush travel sound to
        local gush_dummy = CreateModifierThinker(self:GetCaster(), self, nil, {}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
        gush_dummy:EmitSoundParams("Hero_Tidehunter.Gush.AghsProjectile",1.0, 0.2, 0)

        local direction	= (enemy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()

        local linear_projectile = {
            Ability				= self,
            EffectName			= "particles/units/heroes/hero_tidehunter/tidehunter_gush_upgrade.vpcf", -- Might not do anything
            vSpawnOrigin		= self:GetCaster():GetAbsOrigin(),
            fDistance			= self:GetSpecialValueFor("range"),
            fStartRadius		= self:GetSpecialValueFor("radius"),
            fEndRadius			= self:GetSpecialValueFor("radius"),
            Source				= self:GetCaster(),
            bHasFrontalCone		= false,
            bReplaceExisting	= false,
            iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType		= DOTA_UNIT_TARGET_HERO ,
            fExpireTime 		= GameRules:GetGameTime() + 10.0,
            bDeleteOnHit		= true,
            vVelocity			= direction * self:GetSpecialValueFor("projectile_speed"),
            bProvidesVision		= false,

            ExtraData			=
            {
                gush_dummy	= gush_dummy:entindex(),
            }
        }
        self.projectile = ProjectileManager:CreateLinearProjectile(linear_projectile)
    end
end

-- Make the travel sound follow the Gush
function luna_wave:OnProjectileThink_ExtraData(location, data)
    if not IsServer() then return end
    if data.gush_dummy then
        EntIndexToHScript(data.gush_dummy):SetAbsOrigin(location)
    end
end

function luna_wave:OnProjectileHit_ExtraData(target, data)
    if not IsServer() then return end
    local damage = self:GetSpecialValueFor("damage")
    local duration = self:GetSpecialValueFor("duration")
    local caster = self:GetCaster()
    if target and caster:IsAlive()then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = target
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_luna_wave_amp"
        modifierTable.duration = duration
        GameMode:ApplyDebuff(modifierTable)
        local amp_modifiers = target:FindAllModifiersByName("modifier_luna_wave_amp")
        for _,modifier in pairs(amp_modifiers) do
            modifier:ForceRefresh()
        end
        local damageTable = {}
        damageTable.caster = self:GetCaster()
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.frostdmg = true
        damageTable.voiddmg = true
        GameMode:DamageUnit(damageTable)
        local fx = "particles/econ/items/luna/luna_lucent_ti5/luna_lucent_beam_moonfall.vpcf"
        local particle = ParticleManager:CreateParticle(fx, PATTACH_POINT_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
        ParticleManager:SetParticleControlEnt(particle,	5,target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle,	6, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
        Timers:CreateTimer(3, function()
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
        end)
        -- Gush has reached its end location
    elseif data.gush_dummy then
        EntIndexToHScript(data.gush_dummy):StopSound("Hero_Tidehunter.Gush.AghsProjectile")
        EntIndexToHScript(data.gush_dummy):RemoveSelf() --this is UTIL remove
    end
end


---------
--luna wax wane
--------
luna_wax_wane = class({
    GetAbilityTextureName = function(self)
        return "luna_wax_wane"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_luna_wax_wane"
    end,
})

modifier_luna_wax_wane = class({
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
        return true
    end,
})


function modifier_luna_wax_wane:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self:StartIntervalThink(10)
    self:OnIntervalThink()
end

function modifier_luna_wax_wane:OnIntervalThink()
    Timers:CreateTimer(0.5, function()
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.parent
        modifierTable.caster = self.parent
        modifierTable.modifier_name = "modifier_luna_wax"
        modifierTable.duration = 5
        modifierTable.stacks = 1
        modifierTable.max_stacks = 5
        GameMode:ApplyStackingBuff(modifierTable)
        if RollPercentage(35) and self.parent:IsAlive() then
            local responses =
            {
                "luna_luna_levelup_01",
                "luna_luna_levelup_03",
                "luna_luna_levelup_05",
                "luna_luna_levelup_06",
                "luna_luna_levelup_07",
                "luna_luna_levelup_09",
                "luna_luna_levelup_10",
                "luna_luna_attack_13"

            }
            self:GetCaster():EmitSound(responses[RandomInt(1, #responses)])
        end
        Timers:CreateTimer(5, function()
            modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = self.parent
            modifierTable.caster = self.parent
            modifierTable.modifier_name = "modifier_luna_wane"
            modifierTable.duration = 5
            modifierTable.stacks = 1
            modifierTable.max_stacks = 5
            GameMode:ApplyStackingDebuff(modifierTable)
        end)
    end)
end

LinkLuaModifier("modifier_luna_wax_wane", "creeps/zone1/boss/luna.lua", LUA_MODIFIER_MOTION_NONE)

luna_wax = class({
    GetAbilityTextureName = function(self)
        return "luna_wax"
    end,
})

modifier_luna_wax = class({
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
        return true
    end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/luna/luna_wax.png"--luna_wax_wane:GetAbilityTextureName()
    end,
})

function modifier_luna_wax:OnCreated(keys)
    if not IsServer() then
        return
    end
    local modifier = self:GetParent():FindModifierByName("modifier_luna_wax_wane")
    self.ability = modifier:GetAbility()
    self.parent = self:GetParent()
    self.go_up = true
    self:StartIntervalThink(0.5)
    local wax = "particles/econ/items/luna/luna_lucent_ti5/luna_eclipse_cast_moonfall.vpcf"
    local wax_fx = ParticleManager:CreateParticle(wax, PATTACH_POINT_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(wax_fx, 1, Vector(300, 0, 0))--self.radius
    Timers:CreateTimer(5, function()
        ParticleManager:DestroyParticle(wax_fx, false)
        ParticleManager:ReleaseParticleIndex(wax_fx)
    end)
end

function modifier_luna_wax:OnIntervalThink(keys)
    local stacks = self:GetStackCount()
    self.dmg_reduction = self.ability:GetSpecialValueFor("dmg_reduction") * 0.01 *stacks/5
    self.as_bonus = self.ability:GetSpecialValueFor("as_bonus") * 0.01 * stacks/5
    self.ms_bonus  = self.ability:GetSpecialValueFor("ms_bonus") * 0.01 * stacks/5
    if self.parent:HasModifier("modifier_luna_cruelty") then
        self.dmg_reduction = self.dmg_reduction * 2
        self.as_bonus = self.as_bonus * 2
        self.ms_bonus = self.ms_bonus * 2 end
    if self.go_up == false and  stacks > 0 then
        stacks = stacks - 1
        self:SetStackCount(stacks)
    elseif self.go_up == false and stacks == 0 then self:Destroy()
    end

    if self.go_up == true and stacks < 5 then
        stacks = stacks + 1
        self:SetStackCount(stacks)
    else self.go_up= false
    end
end


function modifier_luna_wax:GetAttackSpeedPercentBonus()
    return self.as_bonus
end

function modifier_luna_wax:GetMoveSpeedPercentBonus()
     return self.ms_bonus
end

function modifier_luna_wax:GetDamageReductionBonus()
    return self.dmg_reduction
end

LinkLuaModifier("modifier_luna_wax", "creeps/zone1/boss/luna.lua", LUA_MODIFIER_MOTION_NONE)


modifier_luna_wane = class({
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
        return true
    end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/luna/luna_wane.png"--luna_wax_wane:GetAbilityTextureName()
    end,
})

function modifier_luna_wane:OnCreated(keys)
    if not IsServer() then
        return
    end
    local modifier = self:GetParent():FindModifierByName("modifier_luna_wax_wane")
    self.ability = modifier:GetAbility()
    self.parent = self:GetParent()
    self.go_up = true
    self:StartIntervalThink(0.5)
end

function modifier_luna_wane:OnIntervalThink(keys)
    local stacks = self:GetStackCount()
    self.dmg_amp = self.ability:GetSpecialValueFor("dmg_amp") * -0.01 * stacks/5
    self.as_reduce = self.ability:GetSpecialValueFor("as_reduce") * -0.01 * stacks/5
    self.ms_reduce  = self.ability:GetSpecialValueFor("ms_reduce") * -0.01 * stacks/5
    if self.parent:HasModifier("modifier_luna_cruelty") then
        self.dmg_amp = 0
        self.as_reduce = 0
        self.ms_reduce = 0 end

    if self.go_up == false and  stacks > 0 then
        stacks = stacks - 1
        self:SetStackCount(stacks)
    elseif self.go_up == false and  stacks == 0  then self:Destroy()
    end

    if self.go_up == true and stacks < 5 then
        stacks = stacks + 1
        self:SetStackCount(stacks)
    else self.go_up= false
    end
end

function modifier_luna_wane:GetAttackSpeedPercentBonus()
        return  self.as_reduce
end

function modifier_luna_wane:GetMoveSpeedPercentBonus()
        return self.ms_reduce
end

function modifier_luna_wane:GetDamageReductionBonus()
        return self.dmg_amp
end


LinkLuaModifier("modifier_luna_wane", "creeps/zone1/boss/luna.lua", LUA_MODIFIER_MOTION_NONE)
--------------
--luna cruelty
--------------
modifier_luna_cruelty = class({
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
    GetStatusEffectName = function(self)
        return "particles/units/npc_boss_luna/luna_cruelty/luna_cruelty.vpcf"
    end,
})

function modifier_luna_cruelty:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    self.bonus_range = self.ability:GetSpecialValueFor("bonus_range")
    local responses =
        {
            "luna_luna_battlebegins_01",
            "luna_luna_attack_07",
            "luna_luna_attack_06",
            "luna_luna_attack_10",
            "luna_luna_attack_13"
        }
    self:GetCaster():EmitSound(responses[RandomInt(1, #responses)])
    self:StartIntervalThink(8)
    self:OnIntervalThink()
end

function modifier_luna_cruelty:GetAttackRangeBonus()
    return self.bonus_range
end

LinkLuaModifier("modifier_luna_cruelty", "creeps/zone1/boss/luna.lua", LUA_MODIFIER_MOTION_NONE)

luna_cruelty = class({
    GetAbilityTextureName = function(self)
        return "luna_cruelty"
    end,})


function luna_cruelty:GatherVoid(radius, number, projectile_speed, set, set_interval)
    if (not IsServer()) then
        return
    end
    --particle
    self.arrow_particle = "particles/units/npc_boss_luna/luna_cruelty/luna_cruelty_gather_void.vpcf"
    local angleLeft
    local angleRandom
    local direction
    local caster = self:GetCaster()
    local summon_origin
    local summon_point_base
    local summon_point
    local counter = 0
    local gather =1
    Timers:CreateTimer(0,function()
        if counter < set then
            --random initial angle for each set so they wont be memorizable like TB act 6 SF
            summon_origin = caster:GetAbsOrigin()
            angleRandom = QAngle(0, math.random(1,math.floor(360 / number)) ,0)
            summon_point_base = caster:GetAbsOrigin() + radius * caster:GetForwardVector()
            summon_point_base = RotatePosition(summon_origin, angleRandom, summon_point_base)
            for i = 0, number - 1, 1 do
                --rotate to form perfect circle
                angleLeft = QAngle(0, i * (math.floor(360 / number)), 0)
                summon_point = RotatePosition(summon_origin, angleLeft, summon_point_base)
                direction = (summon_point - summon_origin):Normalized()*-1 --go in
                local projectile =
                {
                    Ability				= self,
                    EffectName			= self.arrow_particle,
                    vSpawnOrigin		= summon_point, -- start from outer
                    fDistance			= 2000,
                    fStartRadius		= 125,
                    fEndRadius			= 125,
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
                    ExtraData			=
                    {  gather = gather,
                       originX = summon_origin.x,
                       originY = summon_origin.y,
                       originZ = summon_origin.z,-- store caster pos on cast as center
                    }
                }
                ProjectileManager:CreateLinearProjectile(projectile)
            end
            counter = counter +1
            return set_interval
        end
    end)
end

function luna_cruelty:ReleaseVoid(radius, number, projectile_speed, set, set_interval)
    if (not IsServer()) then
        return
    end
    --particle
    self.arrow_particle = "particles/units/npc_boss_luna/luna_cruelty/luna_cruelty_gather_void.vpcf"
    local angleLeft
    local angleRandom
    local direction
    local caster = self:GetCaster()
    local summon_origin
    local summon_point_base
    local summon_point
    local counter = 0
    local gather = 2
    Timers:CreateTimer(0,function()
        if counter < set then
            --random initial angle for each set so they wont be memorizable like TB act 6 SF
            summon_origin = caster:GetAbsOrigin()
            angleRandom = QAngle(0, math.random(1,math.floor(360 / number)) ,0)
            summon_point_base = caster:GetAbsOrigin() + radius * caster:GetForwardVector()
            summon_point_base = RotatePosition(summon_origin, angleRandom, summon_point_base)
            --rotate to form perfect circle
            for i = 0, number - 1, 1 do
                angleLeft = QAngle(0, i * (math.floor(360 / number)), 0)
                summon_point = RotatePosition(summon_origin, angleLeft, summon_point_base)
                direction = (summon_point - summon_origin):Normalized()  --go out
                local projectile =
                {
                    Ability				= self,
                    EffectName			= self.arrow_particle,
                    vSpawnOrigin		= summon_origin, --start from center
                    fDistance			= 2000,
                    fStartRadius		= 125,
                    fEndRadius			= 125,
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
                    ExtraData			=
                    {    gather = gather,
                         originX = summon_origin.x,
                         originY = summon_origin.y,
                         originZ = summon_origin.z,-- store caster pos on cast
                    }
                }
                ProjectileManager:CreateLinearProjectile(projectile)
            end
            counter = counter +1
            return set_interval
        end
    end)
end

function luna_cruelty:OnProjectileHit_ExtraData(target, vLocation, extraData)
    local caster = self:GetCaster()
    if target and caster:IsAlive() then
        local caster_loc = Vector( extraData.originX, extraData.originY, extraData.originZ )
        local target_loc = target:GetAbsOrigin()
        local increment = self:GetSpecialValueFor("increment_damage")
        local distance = (caster_loc -  target_loc):Length2D()
        --print(extraData.gather)
        --print(caster_loc)
        --print(target_loc)
            --gather
        if extraData.gather == 1 then
            local damage = self:GetSpecialValueFor("gather_damage")
            damage = damage + increment * distance
            --print(distance)
            --print(damage)
            local damageTable = {}
            damageTable.caster = caster
            damageTable.target = target
            damageTable.ability = self
            damageTable.damage = damage
            damageTable.voiddmg = true
            GameMode:DamageUnit(damageTable)
            --release
        elseif extraData.gather == 2 then
            local damage = self:GetSpecialValueFor("release_damage")
            damage = damage - increment * distance
            --print(distance)
            --print(damage)
            local damageTable = {}
            damageTable.caster = caster
            damageTable.target = target
            damageTable.ability = self
            damageTable.damage = damage
            damageTable.voiddmg = true
            GameMode:DamageUnit(damageTable)
        end
    end
end

function luna_cruelty:OnSpellStart()
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")
    local number = self:GetSpecialValueFor("number")
    local projectile_speed = self:GetSpecialValueFor("projectile_speed") --in perfect conjunction case radius*2/set_interval
    local set = self:GetSpecialValueFor("set") --in perfect conjunction case duration/set_interval
    local set_interval = self:GetSpecialValueFor("set_interval")
    local half_set_interval = set_interval/2
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_luna_cruelty"
    modifierTable.duration = duration
    GameMode:ApplyBuff(modifierTable)
    self:GatherVoid( radius, number, projectile_speed, set, set_interval)
    Timers:CreateTimer(half_set_interval, function()  --4 3.2 2.5
        self:ReleaseVoid( radius, number, projectile_speed, set, set_interval)
        local bound = "particles/econ/items/spectre/spectre_transversant_soul/spectre_transversant_spectral_dagger_path_owner_impact.vpcf"
        local bound_fx = ParticleManager:CreateParticle(bound, PATTACH_POINT_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(bound_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        Timers:CreateTimer(2.0, function()
            ParticleManager:DestroyParticle(bound_fx, false)
            ParticleManager:ReleaseParticleIndex(bound_fx)
        end)
    end)
end

-----------------
--luna orbs
----------------
luna_orbs = class({
    GetAbilityTextureName = function(self)
        return "luna_orbs"
    end,
})

function luna_orbs:IsRequireCastbar()
    return true
end

function luna_orbs:IsInterruptible()
    return false
end

function luna_orbs:OnAbilityPhaseStart()
    if IsServer() then
        local caster = self:GetCaster()
        local bound = "particles/econ/items/spectre/spectre_transversant_soul/spectre_transversant_spectral_dagger_path_owner_impact.vpcf"
        self.bound_fx = ParticleManager:CreateParticle(bound, PATTACH_POINT_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(self.bound_fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(self.bound_fx)
    end

    return true
end

function luna_orbs:OnSpellStart()
    -- Ability properties
    local caster = self:GetCaster()
    local range = self:GetSpecialValueFor("range")
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),
            self:GetCaster():GetAbsOrigin(),
            nil,
            range,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO ,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)

    for _, enemy in pairs(enemies) do
        self:LaunchProjectile(caster, enemy)
    end
end

function luna_orbs:LaunchProjectile(source, target)
    if not IsServer() then return end
    -- Ability properties
    local caster = self:GetCaster()
    local ability = self
    local sound_cast = "Hero_Lich.ChainFrost"
    local particle_projectile = "particles/units/npc_boss_luna/luna_orbs/luna_orbs_projectile.vpcf"

    -- Ability specials
    local projectile_base_speed = ability:GetSpecialValueFor("projectile_speed")
    -- Play cast sound
    caster:EmitSound(sound_cast)

    -- Launch the projectile
    local chain_frost_projectile
    chain_frost_projectile = {Target = target,
                              Source = source,
                              Ability = ability,
                              EffectName = particle_projectile,
                              iMoveSpeed = projectile_base_speed,
                              bDodgeable = false,
                              bVisibleToEnemies = true,
                              bReplaceExisting = false,
    }

    ProjectileManager:CreateTrackingProjectile(chain_frost_projectile)
end

function luna_orbs:OnProjectileHit_ExtraData(target, data)
    if not IsServer() then return end
    -- Ability properties
    local caster = self:GetCaster()
    local ability = self
    local particle_projectile = "particles/units/npc_boss_luna/luna_orbs/luna_orbs_projectile.vpcf"
    local projectile_delay = 0.2
    local stun = self:GetSpecialValueFor("stun")
    -- Ability specials
    local bounce_range = ability:GetSpecialValueFor("bounce")
    local damage = self:GetSpecialValueFor("damage")
    local projectile_speed = self:GetSpecialValueFor("projectile_speed")
    self.already_hit = {}
    -- Make sure there is a target
    if target and caster:IsAlive() then
        table.insert(self.already_hit, target)
        EmitSoundOn("Hero_Lich.ChainFrostImpact.Hero", target)
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.voiddmg = true
        damageTable.naturedmg = true
        GameMode:DamageUnit(damageTable)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = target
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_stunned"
        modifierTable.duration = stun
        GameMode:ApplyDebuff(modifierTable)
        -- Start a timer and bounce again!
        Timers:CreateTimer(projectile_delay, function()

            -- Find enemies in bounce range
            local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                    target:GetAbsOrigin(),
                    nil,
                    bounce_range,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NO_INVIS,
                    FIND_ANY_ORDER,
                    false)
            for i = #enemies, 1, -1 do
                if enemies[i] ~= nil and (target == enemies[i]) then
                    table.remove(enemies, i)
                    --break
                end
            end

            -- If there are no enemies, do nothing
            if #enemies <= 0 then
                return nil
            end

            local bounce_target = enemies[1]
            local chain_frost_projectile
            chain_frost_projectile = {Target = bounce_target,
                                      Source = target,
                                      Ability = ability,
                                      EffectName = particle_projectile,
                                      iMoveSpeed = projectile_speed,
                                      bDodgeable = false,
                                      bVisibleToEnemies = true,
                                      bReplaceExisting = false,

            }
            ProjectileManager:CreateTrackingProjectile(chain_frost_projectile)
        end)
    end
end

--------------
--luna bound
---------------
luna_bound = class({
    GetAbilityTextureName = function(self)
        return "luna_bound"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_luna_bound"
    end,
})

modifier_luna_bound = class({
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
        return { MODIFIER_EVENT_ON_DEATH }
    end
})

function modifier_luna_bound:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    --apply buff to luna but set inactive state
    local modifierTable = {}
    modifierTable.ability = self.ability
    modifierTable.target = self.parent
    modifierTable.caster = self.parent
    modifierTable.modifier_name = "modifier_luna_bound_buff"
    modifierTable.duration = -1
    modifierTable.stacks = 1
    modifierTable.max_stacks = 2
    GameMode:ApplyStackingBuff(modifierTable)
    self.mirana = nil
    Timers:CreateTimer(0, function()
        if self.mirana == nil then
            self.mirana = self.ability:FindMirana(self.parent)
            return 0.1
        end
    end)
    local bound = "particles/econ/items/spectre/spectre_transversant_soul/spectre_transversant_spectral_dagger_path_owner_impact.vpcf"
    local bound_fx = ParticleManager:CreateParticle(bound, PATTACH_POINT_FOLLOW, self.parent)
    ParticleManager:SetParticleControlEnt(bound_fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(bound_fx, false)
        ParticleManager:ReleaseParticleIndex(bound_fx)
    end)
end

function luna_bound:FindMirana(parent)
    local allies = FindUnitsInRadius(parent:GetTeamNumber(),
            parent:GetAbsOrigin(),
            nil,
            25000,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, ally in pairs(allies) do
        if IsMirana(ally) == true then
            local Mirana = ally
            return Mirana
        else return nil
        end
    end
end

function modifier_luna_bound:OnDeath(params)
    local stack = self.parent:FindModifierByName("modifier_luna_bound_buff"):GetStackCount()
    if (params.unit == self.parent and stack == 1) then
        if self.mirana ~= nil then
            self.mirana:FindModifierByName("modifier_mirana_bound_buff"):SetStackCount(2)
            self.mirana:EmitSound("Item.MoonShard.Consume")
        end
        local bound = "particles/econ/items/spectre/spectre_transversant_soul/spectre_transversant_spectral_dagger_path_owner_impact.vpcf"
        local bound_fx = ParticleManager:CreateParticle(bound, PATTACH_POINT_FOLLOW, self.parent)
        ParticleManager:SetParticleControlEnt(bound_fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(bound_fx, false)
            ParticleManager:ReleaseParticleIndex(bound_fx)
        end)
    end
end

LinkLuaModifier("modifier_luna_bound", "creeps/zone1/boss/luna.lua", LUA_MODIFIER_MOTION_NONE)

modifier_luna_bound_buff = class({
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
        return luna_bound:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_luna_bound_buff:OnCreated()
    if not IsServer() then
        return
    end
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal")
end

---@param damageTable DAMAGE_TABLE
function modifier_luna_bound_buff:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_luna_bound_buff")
    local stack = 1
    if modifier ~= nil then
        stack = modifier:GetStackCount()
    end
    if (damageTable.damage > 0 and stack>1 and not damageTable.ability and damageTable.physdmg) then
        --lifesteal
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

function modifier_luna_bound_buff:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    if (keys.attacker == self.parent) and self:GetStackCount() > 1 and keys.attacker:IsAlive() then
        self.mana_burn = self:GetAbility():GetSpecialValueFor("mana_burn") * 0.01
        self.void_per_burn = self:GetAbility():GetSpecialValueFor("void_per_burn") *0.01
        local Max_mana = keys.target:GetMaxMana()
        local burn = Max_mana * self.mana_burn

        local Mana = keys.target:GetMana()
        --if burn more than current mana burn equal to current mana
        if burn > Mana then
            burn = Mana
        end
        local damage = burn * self.void_per_burn
        keys.target:ReduceMana(burn)
        keys.target:EmitSound("Hero_Antimage.ManaBreak")
        local manaburn_pfx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/am_manaburn_basher_ti_5.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
        ParticleManager:SetParticleControl(manaburn_pfx, 0, keys.target:GetAbsOrigin() )
        ParticleManager:ReleaseParticleIndex(manaburn_pfx)

        local damageTable= {}
        damageTable.caster = keys.attacker
        damageTable.target = keys.target
        damageTable.ability = self.ability
        damageTable.damage = damage
        damageTable.voiddmg = true
        GameMode:DamageUnit(damageTable)
    end
end

LinkLuaModifier("modifier_luna_bound_buff", "creeps/zone1/boss/luna.lua", LUA_MODIFIER_MOTION_NONE)

--internal stuff
if (IsServer() and not GameMode.ZONE1_BOSS_LUNA) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_luna_bound_buff, 'OnTakeDamage'))
    GameMode.ZONE1_BOSS_LUNA = true
end