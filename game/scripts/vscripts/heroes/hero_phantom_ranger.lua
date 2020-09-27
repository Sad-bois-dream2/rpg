local LinkedModifiers = {}

-- 

--------------------------------------------------------------------------------
-- Phantom of Vengeance modifiers 

modifier_phantom_ranger_phantom_of_vengeance_phantom = class({
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
        return "particles/units/phantom_ranger/test/soul_echo/soul_echo_phantom.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end,
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_terrorblade_reflection.vpcf"
    end,
    StatusEffectPriority = function(self)
        return 15
    end,
    CheckState = function(self)
        if not IsServer() then
            return
        end
        return
        {
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_INVULNERABLE] = true,
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_MAGIC_IMMUNE] = true,
            [MODIFIER_STATE_UNSELECTABLE] = true,
            [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
            [MODIFIER_STATE_DISARMED] = true,
            [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
        }
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN }
    end
})

LinkedModifiers["modifier_phantom_ranger_phantom_of_vengeance_phantom"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_phantom_ranger_phantom_of_vengeance_phantom:OnCreated(params)
    if not IsServer() then
        return
    end
    self.phantomSpeed = params.phantomSpeed
end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_phantom_of_vengeance_phantom:GetModifierMoveSpeed_AbsoluteMin()
    return self.phantomSpeed
end

--------------------------------------------------------------------------------
-- Phantom of Vengeance

phantom_ranger_phantom_of_vengeance = class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_phantom_of_vengeance"
    end,
    GetAssociatedSecondaryAbilities = function(self)
        return "phantom_ranger_shadowstep"
    end,
    GetCastAnimation = function(self)
        return ACT_DOTA_CAST_ABILITY_2
    end
})

--------------------------------------------------------------------------------

function phantom_ranger_phantom_of_vengeance:OnUpgrade()

    self.caster = self:GetCaster()
    self.level = self:GetLevel()
    self.damage = self:GetSpecialValueFor("contact_damage")
    self.cdr = self:GetSpecialValueFor("contact_cdr")
    self.radius = self:GetSpecialValueFor("radius")
    self.phantomDuration = self:GetSpecialValueFor("duration")
    self.phantomSpeed = self:GetSpecialValueFor("phantom_speed")

    if (self.level >= 3 and not self.caster:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_38")) then
        GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = self, modifier_name = "modifier_npc_dota_hero_drow_ranger_talent_38", duration = -1 })
    end
    if (self.level >= 4 and not self.caster:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_50")) then
        GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = self, modifier_name = "modifier_npc_dota_hero_drow_ranger_talent_50", duration = -1 })
    end

end

--------------------------------------------------------------------------------

function phantom_ranger_phantom_of_vengeance:OnSpellStart(sourceUnit, target)


    sourceUnit = sourceUnit or self.caster
    target = target or self:GetCursorPosition()
    self.fromPhantom = (sourceUnit ~= self.caster)
    if (not self.fromPhantom) then
        self.caster.phantom_of_vengeance_shadowstep_enabled = false
    end
    self.receivedCdr = false
    local source = sourceUnit:GetAbsOrigin()

    if target == source then

        self.caster:SetCursorPosition(target + sourceUnit:GetForwardVector())
        target = self:GetCursorPosition()

    end

    local phantom = CreatePhantomAtPoint(source, self, "modifier_phantom_ranger_phantom_of_vengeance_phantom", self.phantomSpeed, self.phantomDuration)
    Timers:CreateTimer(0.05, function()
        phantom:MoveToPosition(target)
    end, self)
    if (not self.fromPhantom) then
        Timers:CreateTimer(self.phantomDuration, function()

            if (self.caster.phantom_of_vengeance_shadowstep_enabled) then

                self.caster:SwapAbilities("phantom_ranger_shadowstep", "phantom_ranger_phantom_of_vengeance", false, true)
                self.caster.phantom_of_vengeance_shadowstep_enabled = false

            end

        end)

    end
    -- Damaging part of the spell is a linear projectile.
    local distance = DistanceBetweenVectors(source, target)
    local targetVector = target - source
    local projectile = {
        Source = sourceUnit,
        vSpawnOrigin = source,
        Ability = self,
        bDodgeable = false,
        bProvidesVision = false,
        fDistance = distance,
        fStartRadius = self.radius,
        fEndRadius = self.radius,
        vVelocity = targetVector:Normalized() * self.phantomSpeed,
        bDeleteOnHit = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bReplaceExisting = false,
        bProvidesVision = false,
        ExtraData = { fromsummon = self.fromPhantom }
    }

    Timers:CreateTimer(0.05, function()
        phantom.phantom_of_vengeance_projectile = ProjectileManager:CreateLinearProjectile(projectile)
        sourceUnit:EmitSound("Hero_Spectre.Haunt")
    end)

    if not self.caster:HasAbility("phantom_ranger_shadowstep") then
        local index
        local i = 7
        while (not index and i < self.caster:GetAbilityCount()) do
            if (not self.caster:GetAbilityByIndex(i)) then
                index = i
            end
            i = i + 1
        end
        local ability = self.caster:AddAbility("phantom_ranger_shadowstep")
        if (index) then
            ability:SetAbilityIndex(index)
        end
    end

    if (not self.fromPhantom) then

        self.caster:SwapAbilities("phantom_ranger_phantom_of_vengeance", "phantom_ranger_shadowstep", false, true)
        self.caster.phantom_of_vengeance_shadowstep_enabled = true
        self.caster:FindAbilityByName("phantom_ranger_shadowstep"):SetLevel(1)
        -- Goes on a 0.1 second cooldown when ability is cast to prevent accidental double tap
        self.caster:FindAbilityByName("phantom_ranger_shadowstep"):StartCooldown(0.1)

    end

end

--------------------------------------------------------------------------------

function phantom_ranger_phantom_of_vengeance:OnProjectileHit_ExtraData(target, location, ExtraData)

    if (target and not target:IsNull()) then

        GameMode:DamageUnit({ caster = self.caster, target = target, ability = self, damage = Units:GetAttackDamage(self.caster) * self.damage / 100, voiddmg = true, fromsummon = ExtraData.fromsummon })
        target:EmitSound("Hero_Spectre.HauntCast")
        if (self.level >= 2 and (Enemies:IsBoss(target) or Enemies:IsElite(target)) and not self.receivedCdr) then

            self.receivedCdr = true
            GameMode:ReduceAbilityCooldown({ ability = self:GetAbilityName(), reduction = self.cdr, isflat = true, target = self.caster })

        end

    end
    return false

end

--------------------------------------------------------------------------------
-- Shadowstep (phantom of vengeance associated spell)

phantom_ranger_shadowstep = class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_shadowstep"
    end,
    GetAssociatedPrimaryAbilities = function(self)
        return "phantom_ranger_phantom_of_vengeance"
    end
})

--------------------------------------------------------------------------------

function phantom_ranger_shadowstep:OnSpellStart()

    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local target = self:GetCursorPosition()
    local activePhantoms = FindActivePhantoms(caster)
    if (activePhantoms) then

        local closestPhantom = activePhantoms[1]
        local closestPhantomPoint = activePhantoms[1]:GetAbsOrigin()
        local closestDistance = DistanceBetweenVectors(target, closestPhantomPoint)
        for _, phantom in pairs(activePhantoms) do

            if (DistanceBetweenVectors(target, phantom:GetAbsOrigin()) < closestDistance) then

                closestPhantom = phantom
                closestPhantomPoint = phantom:GetAbsOrigin()
                closestDistance = DistanceBetweenVectors(target, closestPhantomPoint)

            end

        end

        if (GridNav:CanFindPath(caster:GetAbsOrigin(), closestPhantomPoint)) then

            closestPhantom:Stop()
            ProjectileManager:DestroyLinearProjectile(closestPhantom.phantom_of_vengeance_projectile)
            FindClearSpaceForUnit(closestPhantom, caster:GetAbsOrigin(), true)
            FindClearSpaceForUnit(caster, closestPhantomPoint, true)
            caster:EmitSound("Hero_Spectre.Reality")

        end

    end

    caster:SwapAbilities("phantom_ranger_shadowstep", "phantom_ranger_phantom_of_vengeance", false, true)
    caster.phantom_of_vengeance_shadowstep_enabled = false

end

-- 

--------------------------------------------------------------------------------
-- Hunter's Focus Modifiers

modifier_phantom_ranger_hunters_focus_buff = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK }
    end
})

LinkedModifiers["modifier_phantom_ranger_hunters_focus_buff"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_phantom_ranger_hunters_focus_buff:OnCreated()

    if not IsServer() then
        return
    end
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
    self.bonusAttackSpeed = self:GetAbility():GetSpecialValueFor("attack_speed")
    self.bonusAttackDamage = self:GetAbility():GetSpecialValueFor("attack_damage") / 100
    --self.talent37_level = TalentTree:GetHeroTalentLevel(self.caster, 37)
    if (self.ability.level > 1) then

        -- Multishot - talent 37 variables 
        self.talent37_baseExtraTargets = 4
        self.talent37_extraTargetsPerLevel = 0
        self.talent37_radius = 600
        self.talent37_basePercentDmg = 0.5
        self.talent37_percentDmgRegainedPerLevel = 0

    end

end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_hunters_focus_buff:GetAttackSpeedBonus()
    return self.bonusAttackSpeed
end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_hunters_focus_buff:GetAttackDamagePercentBonus()
    return self.bonusAttackDamage
end

--------------------------------------------------------------------------------
-- Multishot - talent 37 damage reduction 

function modifier_phantom_ranger_hunters_focus_buff:OnTakeDamage(damageTable)

    if not IsServer() then
        return
    end
    local drow = damageTable.attacker
    local modifier = drow:FindModifierByName("modifier_phantom_ranger_hunters_focus_buff")

    if (modifier and modifier.ability.level > 1 and (damageTable.physdmg and damageTable.ability == nil) and not damageTable.fromsummon and damageTable.damage > 0) then

        damageTable.damage = damageTable.damage * modifier.talent37_basePercentDmg -- + (modifier.talent37_percentDmgRegainedPerLevel * modifier.talent37_level))
        return damageTable

    end

end

--------------------------------------------------------------------------------
-- Multishot - talent 37 extra targets

function modifier_phantom_ranger_hunters_focus_buff:OnAttack(params)

    if not IsServer() then
        return
    end
    if self.ability.level < 2 then
        return
    end
    -- "Secondary arrows are not released upon attacking allies."
    -- The "not params.no_attack_cooldown" clause seems to make sure the function doesn't trigger on PerformAttacks with that false tag so this thing doesn't crash
    local extraTargets = self.talent37_baseExtraTargets --+ self.talent37_level * self.talent37_extraTargetsPerLevel
    if (params.attacker == self.caster and params.target and params.target:GetTeamNumber() ~= self.caster:GetTeamNumber() and not params.no_attack_cooldown and not self.caster:PassivesDisabled()) then

        local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), params.target:GetAbsOrigin(), nil, self.talent37_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)
        local targetNumber = 0
        for _, enemy in pairs(enemies) do

            self.caster:PerformAttack(enemy, true, true, true, true, true, false, false)
            targetNumber = targetNumber + 1
            if targetNumber >= extraTargets then
                break
            end

        end

    end

end

--------------------------------------------------------------------------------
-- Hunter's Focus

phantom_ranger_hunters_focus = class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_hunters_focus"
    end
})

function phantom_ranger_hunters_focus:OnUpgrade()

    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.level = self:GetLevel()
    if (self.level >= 3 and not self.caster:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_43")) then
        GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = self, modifier_name = "modifier_npc_dota_hero_drow_ranger_talent_43", duration = -1 })
    end
    if (self.level >= 4 and not self.caster:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_41")) then
        GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = self, modifier_name = "modifier_npc_dota_hero_drow_ranger_talent_41", duration = -1 })
    end

end

function phantom_ranger_hunters_focus:OnSpellStart()

    if not IsServer() then
        return
    end
    local hunters_focus_duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = self, modifier_name = "modifier_phantom_ranger_hunters_focus_buff", duration = hunters_focus_duration })
    self.caster:EmitSound("Ability.Focusfire")

end

--------------------------------------------------------------------------------
-- phantom_ranger_soul_echo modifiers

modifier_phantom_ranger_soul_echo = class({
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
    end
})

function modifier_phantom_ranger_soul_echo:OnTakeDamage(damageTable)
    if (damageTable.victim.phantom_ranger_soul_echo) then
        local modifier = damageTable.victim:FindModifierByName("modifier_phantom_ranger_soul_echo")
        local phantom = damageTable.victim.phantom_ranger_soul_echo.phantom
        local ability = damageTable.victim:FindAbilityByName("phantom_ranger_soul_echo")
        if (damageTable.damage > 0 and modifier and phantom and not phantom:IsNull() and phantom:IsAlive()) then
            local phantomDamage = phantom.damageTransfer * damageTable.damage
            local phantomHealth = phantom:GetHealth() - phantomDamage
            if (phantomHealth < 1 and ability.level < 3) then
                phantom_ranger_soul_echo:DestroyPhantom(phantom)
                damageTable.victim.phantom_ranger_soul_echo.phantom = nil
            else
                damageTable.damage = damageTable.damage - phantomDamage
                if (ability.level < 3) then
                    phantom:SetHealth(phantomHealth)
                end
                return damageTable
            end
        end
    end
end

LinkedModifiers["modifier_phantom_ranger_soul_echo"] = LUA_MODIFIER_MOTION_NONE

modifier_phantom_ranger_soul_echo_phantom = class({
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
    CheckState = function(self)
        return
        {
            [MODIFIER_STATE_ROOTED] = true,
            [MODIFIER_STATE_DISARMED] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
            [MODIFIER_STATE_UNSELECTABLE] = true,
            [MODIFIER_STATE_OUT_OF_GAME] = true,
        }
    end
})

function modifier_phantom_ranger_soul_echo_phantom:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
    self.pidx = ParticleManager:CreateParticle("particles/units/phantom_ranger/soul_echo/soul_echo.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.pidx, 1, self.parent:GetAbsOrigin())
    print("Kekw2?")
end

function modifier_phantom_ranger_soul_echo_phantom:OnDestroy()
    if (not IsServer()) then
        return
    end
    print("Kekw?")
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
    local pidx = ParticleManager:CreateParticle("particles/units/phantom_ranger/soul_echo/soul_echo_endcap.vpcf", PATTACH_ABSORIGIN, self:GetAbility():GetCaster())
    ParticleManager:SetParticleControl(pidx, 0, self.parent:GetAbsOrigin())
    ParticleManager:DestroyParticle(pidx, false)
    ParticleManager:ReleaseParticleIndex(pidx)
    EmitSoundOn("Hero_VoidSpirit.AetherRemnant.Destroy", self.parent)
    DestroyWearables(self.parent, function()
        self.parent:Destroy()
    end)
end

function modifier_phantom_ranger_soul_echo_phantom:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_phantom_ranger_soul_echo_phantom")
    if (modifier) then
        damageTable.damage = 0
        return damageTable
    end
end

LinkedModifiers["modifier_phantom_ranger_soul_echo_phantom"] = LUA_MODIFIER_MOTION_NONE

modifier_phantom_ranger_soul_echo_phantom_status_effect = class({
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
    end
})

function modifier_phantom_ranger_soul_echo_phantom_status_effect:GetStatusEffectName()
    return "particles/units/phantom_ranger/soul_echo/status_fx/status_effect_phantom.vpcf"
end

function modifier_phantom_ranger_soul_echo_phantom_status_effect:StatusEffectPriority()
    return 15
end

LinkedModifiers["modifier_phantom_ranger_soul_echo_phantom_status_effect"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------
-- phantom_ranger_soul_echo

phantom_ranger_soul_echo = class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_soul_echo"
    end,
})

function phantom_ranger_soul_echo:OnUpgrade()
    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.level = self:GetLevel()
    if (self.level >= 2 and not self.caster:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_42")) then
        GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = self, modifier_name = "modifier_npc_dota_hero_drow_ranger_talent_42", duration = -1 })
    end
    if (self.level >= 4 and not self.caster:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_47")) then
        GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = self, modifier_name = "modifier_npc_dota_hero_drow_ranger_talent_47", duration = -1 })
    end
end

function phantom_ranger_soul_echo:CreatePhantom()
    local phantom = CreateUnitByName("npc_dota_phantom_ranger_phantom", self.caster:GetAbsOrigin(), true, self.caster, self.caster, self.caster:GetTeamNumber())
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = phantom
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_phantom_ranger_soul_echo_phantom"
    modifierTable.duration = self.duration
    GameMode:ApplyBuff(modifierTable)
    local wearables = GetWearables(self.caster)
    AddWearables(phantom, wearables)
    ForEachWearable(phantom,
            function(wearable)
                modifierTable = {}
                modifierTable.ability = self
                modifierTable.target = wearable
                modifierTable.caster = phantom
                modifierTable.modifier_name = "modifier_phantom_ranger_soul_echo_phantom_status_effect"
                modifierTable.duration = -1
                GameMode:ApplyBuff(modifierTable)
            end)
    local casterHealth = self.caster:GetHealth()
    local phantomHealth = casterHealth * self.phantomHealth
    phantom:SetMaxHealth(phantomHealth)
    phantom:SetHealth(phantomHealth)
    phantom.damageTransfer = self.phantomDamageTransfer
    self.caster.phantom_ranger_soul_echo = self.caster.phantom_ranger_soul_echo or {}
    self.caster.phantom_ranger_soul_echo.phantom = phantom
end

function phantom_ranger_soul_echo:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    self.duration = self:GetSpecialValueFor("duration")
    self.phantomHealth = self:GetSpecialValueFor("phantom_health") / 100
    self.phantomDamageTransfer = self:GetSpecialValueFor("damage_reduction") / 100
    EmitSoundOn("Hero_VoidSpirit.Pulse.Cast", self.caster)
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = self.caster
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_phantom_ranger_soul_echo"
    modifierTable.duration = self.duration
    GameMode:ApplyBuff(modifierTable)
    self:CreatePhantom()
end

-- phantom_ranger_shadow_waves modifiers

modifier_phantom_ranger_shadow_waves_silence_cd = class({
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
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_drow_ranger/phantom_ranger_shadow_waves_silence_cd.png"
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

LinkedModifiers["modifier_phantom_ranger_shadow_waves_silence_cd"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

modifier_phantom_ranger_cloak_of_shadows_stealth_cd = class({
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
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_drow_ranger/talent_45.png"
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

LinkedModifiers["modifier_phantom_ranger_cloak_of_shadows_stealth_cd"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

modifier_phantom_ranger_shadow_waves_debuff = class({
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

function modifier_phantom_ranger_shadow_waves_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_phantom_ranger_shadow_waves_debuff:GetSpellHastePercentBonus()
    return self.ability.sphSlow
end

function modifier_phantom_ranger_shadow_waves_debuff:GetMoveSpeedPercentBonus()
    return self.ability.msSlow
end

function modifier_phantom_ranger_shadow_waves_debuff:GetAttackSpeedPercentBonus()
    return self.ability.asSlow
end

LinkedModifiers["modifier_phantom_ranger_shadow_waves_debuff"] = LUA_MODIFIER_MOTION_NONE

-- phantom_ranger_shadow_waves
phantom_ranger_shadow_waves = class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_shadow_waves"
    end,
    GetCastAnimation = function(self)
        return ACT_DOTA_CAST_ABILITY_2
    end
})

function phantom_ranger_shadow_waves:OnUpgrade()

    if not IsServer() then
        return
    end
    self.caster = self:GetCaster()
    self.damageScaling = self:GetSpecialValueFor("void_damage") / 100
    self.silenceDuration = self:GetSpecialValueFor("silence_duration")
    self.duration = self:GetSpecialValueFor("duration")
    self.msSlow = self:GetSpecialValueFor("ms_slow") / 100
    self.asSlow = self:GetSpecialValueFor("as_slow") / 100
    self.sphSlow = self:GetSpecialValueFor("sph_slow") / 100
    self.talent51_level = 1 --TalentTree:GetHeroTalentLevel(self.caster, 51) 
    -- Shadowcaster - talent 51 variables
    self.talent51_baseCastTime = 2.0
    self.talent51_reducedCastTimePerLevel = 0.0
    self.talent51_cd = 0

    self.level = self:GetLevel()
    if (self.level >= 2 and not self.caster:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_45")) then
        GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = self, modifier_name = "modifier_npc_dota_hero_drow_ranger_talent_45", duration = -1 })
    end
    if (self.level >= 3 and not self.caster:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_44")) then
        GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = self, modifier_name = "modifier_npc_dota_hero_drow_ranger_talent_44", duration = -1 })
    end
    if (self.level >= 4 and not self.caster:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_51")) then
        GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = self, modifier_name = "modifier_npc_dota_hero_drow_ranger_talent_51", duration = -1 })
    end


end

-- function phantom_ranger_shadow_waves:OnAbilityPhaseStart()

--     if not IsServer() then return true end 
--     self.talent51_level = TalentTree:GetHeroTalentLevel(self.caster, 51) 
--     return true

-- end

function phantom_ranger_shadow_waves:OnSpellStart(sourceUnit, target)
    if not IsServer() then
        return
    end
    sourceUnit = sourceUnit or self.caster
    target = target or self:GetCursorPosition()
    local source = sourceUnit:GetAbsOrigin()
    local fromPhantom = (sourceUnit ~= self.caster)
    EmitSoundOn("Hero_DrowRanger.Silence", sourceUnit)
    if target == source then

        self.caster:SetCursorPosition(target + sourceUnit:GetForwardVector())
        target = self:GetCursorPosition()

    end

    local targetVector = target - source
    local info = {
        Ability = self,
        EffectName = "particles/units/phantom_ranger/shadow_wave/shadow_wave_projectile.vpcf",
        vSpawnOrigin = source,
        fDistance = 800,
        fStartRadius = 400,
        fEndRadius = 400,
        Source = sourceUnit,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = true,
        vVelocity = targetVector:Normalized() * 1800,
        bProvidesVision = true,
        iVisionRadius = 500,
        iVisionTeamNumber = self.caster:GetTeamNumber(),
        ExtraData = { fromsummon = fromPhantom }
    }
    ProjectileManager:CreateLinearProjectile(info)
    -- Cloak of Shadows (talent 45) logic
    local modifier = self.caster:FindModifierByName("modifier_npc_dota_hero_drow_ranger_talent_45")
    local stealthCoolingDown = self.caster:FindModifierByName("modifier_phantom_ranger_cloak_of_shadows_stealth_cd")
    if (modifier and not stealthCoolingDown) then

        local talent45_level = 3 --TalentTree:GetHeroTalentLevel(self.caster, 45)
        local stealthDuration = modifier.talent45_baseStealthDuration + talent45_level * modifier.talent45_stealthDurationPerLevel
        GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = nil, modifier_name = "modifier_phantom_ranger_stealth", duration = stealthDuration })
        self.caster:AddNewModifier(self.caster, nil, "modifier_phantom_ranger_cloak_of_shadows_stealth_cd", { duration = modifier.talent45_cd })

    end

end

function phantom_ranger_shadow_waves:OnProjectileHit_ExtraData(target, location, ExtraData)

    if (target ~= nil) then

        GameMode:DamageUnit({ caster = self.caster, target = target, ability = self, damage = Units:GetAttackDamage(self.caster) * self.damageScaling, voiddmg = true, fromsummon = ExtraData.fromsummon })
        target:EmitSound("Hero_ShadowDemon.ShadowPoison.Impact")
        GameMode:ApplyDebuff({ caster = self.caster, target = target, ability = self, modifier_name = "modifier_phantom_ranger_shadow_waves_debuff", duration = self.duration })
        if not (self.level >= 4) then

            GameMode:ApplyDebuff({ caster = self.caster, target = target, ability = self, modifier_name = "modifier_silence", duration = self.silenceDuration })

        else

            local silenceCoolingDown = target:FindModifierByName("modifier_phantom_ranger_shadow_waves_silence_cd")
            local silenceCd = self:GetOriginalCooldown(self.level - 1) * Units:GetCooldownReduction(self.caster)
            if (not silenceCoolingDown) then

                GameMode:ApplyDebuff({ caster = self.caster, target = target, ability = self, modifier_name = "modifier_silence", duration = self.silenceDuration })
                target:AddNewModifier(self.caster, self, "modifier_phantom_ranger_shadow_waves_silence_cd", { duration = silenceCd })

            end

        end

    end

    return false

end

-- Shadowcaster (talent 51) cast point and cdr stuff

function phantom_ranger_shadow_waves:GetCastPoint()

    if not IsServer() then
        return self.BaseClass.GetCastPoint(self)
    end
    --if not self.talent51_level then self.talent51_level = TalentTree:GetHeroTalentLevel(self.caster, 51) end
    if (self.level >= 4) then

        return (self.talent51_baseCastTime - self.talent51_level * self.talent51_reducedCastTimePerLevel)

    else

        return self.BaseClass.GetCastPoint(self)

    end

end

function phantom_ranger_shadow_waves:IsRequireCastbar()

    if not IsServer() then
        return
    end
    -- if not self.talent51_level then self.talent51_level = TalentTree:GetHeroTalentLevel(self.caster, 51) end
    -- return (self.talent51_level > 0)
    return (self.level >= 4)

end

function phantom_ranger_shadow_waves:GetCooldown(level)

    if not IsServer() then
        return self.BaseClass.GetCooldown(self, level)
    end
    --if not self.talent51_level then self.talent51_level = TalentTree:GetHeroTalentLevel(self.caster, 51) end
    if (self.level >= 4) then

        return self.talent51_cd

    else

        return self.BaseClass.GetCooldown(self, level)

    end

end

function phantom_ranger_shadow_waves:GetOriginalCooldown(level)

    local baseCd = 20
    local cdrPerLevel = 0
    return baseCd - level * cdrPerLevel

end

-- phantom_ranger_phantom_harmonic modifiers
modifier_phantom_ranger_phantom_harmonic = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_phantom_ranger_phantom_harmonic:OnCreated(kv)
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.casterTeam = self.caster:GetTeam()
    self.ability = self:GetAbility()
    -- Deadly Vibration - talent 48 variables
    self.talent48_baseChanceIncrease = 10
    self.talent48_chanceIncreasePerLevel = 10
end

function modifier_phantom_ranger_phantom_harmonic:OnAttackLanded(kv)
    if IsServer() then
        local attacker = kv.attacker
        local target = kv.target

        if (attacker and target and not target:IsNull() and attacker == self.caster) then
            -- Deadly Vibration (talent 48) increased chance to proc
            --local talent48_level = TalentTree:GetHeroTalentLevel(self.caster, 48)
            local bonusProcChance = 0
            --if (self.ability.level >= 3) then bonusProcChance = self.talent48_baseChanceIncrease + self.talent48_chanceIncreasePerLevel * talent48_level end 
            if (not RollPercentage(self.ability.proc_chance + bonusProcChance)) then

                return
            end
            local targetPosition = target:GetAbsOrigin()
            local enemies = FindUnitsInRadius(self.casterTeam,
                    targetPosition,
                    nil,
                    600,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            local index = self.ability:GetUniqueInt()
            self.ability.projectiles[index] = { targets = enemies }
            phantom_ranger_phantom_harmonic:CreateBounceProjectile(target, target, { index = index }, self.ability)
        end
    end
end

LinkedModifiers["modifier_phantom_ranger_phantom_harmonic"] = LUA_MODIFIER_MOTION_NONE

modifier_phantom_ranger_phantom_harmonic_stacks = class({
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
    GetTexture = function(self)
        return phantom_ranger_phantom_harmonic:GetAbilityTextureName()
    end,
})

LinkedModifiers["modifier_phantom_ranger_phantom_harmonic_stacks"] = LUA_MODIFIER_MOTION_NONE

-- Deadly Vibration (talent 48) logic

function modifier_phantom_ranger_phantom_harmonic_stacks:OnCreated()

    if not IsServer() then
        return
    end
    --local caster = self:GetParent()
    --self.talent48_level = TalentTree:GetHeroTalentLevel(caster, 48)
    self.ability = self:GetAbility()
    --Deadly Vibration - talent 48 variables
    self.talent48_percentAdPerStack, self.talent48_percentArmorPerStack, self.talent48_resistsPerStack = 3, 3, 3

end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetAttackDamagePercentBonus()
    if (self.ability.level >= 4) then
        return self:GetStackCount() * self.talent48_percentAdPerStack / 100
    else
        return 0
    end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetArmorPercentBonus()
    if (self.ability.level >= 3) then
        return self:GetStackCount() * self.talent48_percentArmorPerStack / 100
    else
        return 0
    end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetFireProtectionBonus()
    if (self.ability.level >= 3) then
        return self:GetStackCount() * self.talent48_resistsPerStack / 100
    else
        return 0
    end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetFrostProtectionBonus()
    if (self.ability.level >= 3) then
        return self:GetStackCount() * self.talent48_resistsPerStack / 100
    else
        return 0
    end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetEarthProtectionBonus()
    if (self.ability.level >= 3) then
        return self:GetStackCount() * self.talent48_resistsPerStack / 100
    else
        return 0
    end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetVoidProtectionBonus()
    if (self.ability.level >= 3) then
        return self:GetStackCount() * self.talent48_resistsPerStack / 100
    else
        return 0
    end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetHolyProtectionBonus()
    if (self.ability.level >= 3) then
        return self:GetStackCount() * self.talent48_resistsPerStack / 100
    else
        return 0
    end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetNatureProtectionBonus()
    if (self.ability.level >= 3) then
        return self:GetStackCount() * self.talent48_resistsPerStack / 100
    else
        return 0
    end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetInfernoProtectionBonus()
    if (self.ability.level >= 3) then
        return self:GetStackCount() * self.talent48_resistsPerStack / 100
    else
        return 0
    end
end

-- phantom_ranger_phantom_harmonic
phantom_ranger_phantom_harmonic = class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_phantom_harmonic"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_phantom_ranger_phantom_harmonic"
    end,
})

phantom_ranger_phantom_harmonic.projectiles = {}
phantom_ranger_phantom_harmonic.unique = {}
phantom_ranger_phantom_harmonic.i = 0
phantom_ranger_phantom_harmonic.max = 65536

function phantom_ranger_phantom_harmonic:GetUniqueInt()
    while self.unique[self.i] do
        self.i = self.i + 1
        if self.i == self.max then
            self.i = 0
        end
    end

    self.unique[self.i] = true
    return self.i
end

function phantom_ranger_phantom_harmonic:DelUniqueInt(i)
    self.unique[i] = nil
end

function phantom_ranger_phantom_harmonic:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    self.level = self:GetLevel()
    self.max_stacks = self:GetSpecialValueFor("max_stacks")
    self.proc_damage = self:GetSpecialValueFor("proc_damage") / 100
    self.duration = self:GetSpecialValueFor("duration")
    self.proc_chance = self:GetSpecialValueFor("proc_chance")
end

function phantom_ranger_phantom_harmonic:OnProjectileHit_ExtraData(target, vLocation, ExtraData)

    if (not IsServer() or not target or not ExtraData) then
        return
    end
    if (target == self.caster) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.caster = self.caster
        modifierTable.target = self.caster
        modifierTable.modifier_name = "modifier_phantom_ranger_phantom_harmonic_stacks"
        modifierTable.duration = self.duration
        modifierTable.stacks = #self.projectiles[ExtraData.index].reachedTargets
        modifierTable.max_stacks = self.max_stacks
        if (self.level >= 2) then
            GameMode:ApplyStackingBuff(modifierTable)
        end
        self.projectiles[ExtraData.index] = nil
        self:DelUniqueInt(ExtraData.index)
        return true
    end
    local jumpTarget
    local enemies = self.projectiles[ExtraData.index].targets
    self.projectiles[ExtraData.index].reachedTargets = self.projectiles[ExtraData.index].reachedTargets or {}
    local damageTable = {}
    damageTable.caster = self.caster
    damageTable.target = target
    damageTable.ability = self
    damageTable.damage = self.proc_damage * Units:GetAttackDamage(self.caster)
    damageTable.voiddmg = true
    GameMode:DamageUnit(damageTable)
    table.insert(self.projectiles[ExtraData.index].reachedTargets, target)
    while #enemies > 0 do
        local potentialJumpTarget = enemies[1]
        if (not potentialJumpTarget or potentialJumpTarget:IsNull() or TableContains(self.projectiles[ExtraData.index].reachedTargets, potentialJumpTarget)) then
            table.remove(enemies, 1)

        else
            jumpTarget = potentialJumpTarget
            break
        end
    end
    self.projectiles[ExtraData.index].targets = enemies
    if (#enemies == 0) then
        phantom_ranger_phantom_harmonic:CreateBounceProjectile(target, self.caster, ExtraData, self)
    else
        phantom_ranger_phantom_harmonic:CreateBounceProjectile(target, jumpTarget, ExtraData, self)
    end
    return false
end

function phantom_ranger_phantom_harmonic:CreateBounceProjectile(source, target, extraData, ability)
    local projectile = {
        Target = target,
        Source = source,
        Ability = ability,
        EffectName = "particles/units/phantom_ranger/phantom_harmonic/phantom_harmonic_projectile.vpcf",
        bDodgeable = false,
        bProvidesVision = false,
        iMoveSpeed = 800,
        ExtraData = extraData
    }
    ProjectileManager:CreateTrackingProjectile(projectile)
end

-- phantom_ranger_void_disciple
modifier_phantom_ranger_void_disciple_summon = class({
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

function modifier_phantom_ranger_void_disciple_summon:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetAbility():GetCaster()
    self.summon = self:GetParent()
    self.pidx = ParticleManager:CreateParticle("particles/units/phantom_ranger/void_disciple/void_disciple.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.summon)
end

function modifier_phantom_ranger_void_disciple_summon:OnDestroy()
    if (not IsServer()) then
        return
    end
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
    local pidx = ParticleManager:CreateParticle("particles/units/phantom_ranger/void_disciple/void_disciple_endcap.vpcf", PATTACH_ABSORIGIN, self.caster)
    ParticleManager:SetParticleControl(pidx, 0, self.summon:GetAbsOrigin())
    ParticleManager:DestroyParticle(pidx, false)
    ParticleManager:ReleaseParticleIndex(pidx)
    EmitSoundOn("Hero_VoidSpirit.AetherRemnant.Destroy", self.summon)
    self.summon:Destroy()
    self.caster.phantom_ranger_void_disciple.current_voids = self.caster.phantom_ranger_void_disciple.current_voids - 1
end

LinkedModifiers["modifier_phantom_ranger_void_disciple_summon"] = LUA_MODIFIER_MOTION_NONE

phantom_ranger_void_disciple = class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_void_disciple"
    end,
    GetCastAnimation = function(self)
        return ACT_DOTA_CAST_ABILITY_3
    end
})

function phantom_ranger_void_disciple:OnSpellStart(source)
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    source = source or caster
    local casterPosition = source:GetAbsOrigin()
    local harmonicStacks = caster:GetModifierStackCount("modifier_phantom_ranger_phantom_harmonic_stacks", caster)
    local harmonicAbility = caster:FindAbilityByName("phantom_ranger_phantom_harmonic")
    if (harmonicStacks > 0 and harmonicAbility and harmonicAbility:GetLevel() >= 2) then
        local cdrPerStacks = harmonicAbility:GetSpecialValueFor("cdr_per_stack")
        local reducedCooldown = harmonicStacks * cdrPerStacks
        local cooldownTable = {
            target = caster,
            ability = "phantom_ranger_void_disciple",
            reduction = reducedCooldown,
            isflat = true
        }
        GameMode:ReduceAbilityCooldown(cooldownTable)
    end
    caster.phantom_ranger_void_disciple = caster.phantom_ranger_void_disciple or {}
    caster.phantom_ranger_void_disciple.current_voids = caster.phantom_ranger_void_disciple.current_voids or 0
    if (caster.phantom_ranger_void_disciple.current_voids == self.max_voids) then
        return
    end
    caster.phantom_ranger_void_disciple.current_voids = caster.phantom_ranger_void_disciple.current_voids + 1
    local summonTable = {
        caster = caster,
        unit = "npc_dota_phantom_ranger_void_disciple",
        position = casterPosition,
        damage = Units:GetAttackDamage(caster) * self.void_damage,
        ability = self
    }
    local summon = Summons:SummonUnit(summonTable)
    if (not summon) then
        return
    end
    EmitSoundOn("Hero_VoidSpirit.Pulse.Cast", summon)
    Summons:SetSummonHaveVoidDamageType(summon, true)
    Summons:SetSummonAttackSpeed(summon, Units:GetAttackSpeed(caster) * self.void_aa_speed)
    if (self.level >= 3) then
        Summons:SetSummonCanProcOwnerAutoAttack(summon, true)
    end
    summon:AddNewModifier(caster, self, "modifier_phantom_ranger_void_disciple_summon", { duration = self.duration })
end

function phantom_ranger_void_disciple:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.max_voids = self:GetSpecialValueFor("max_voids")
    self.void_damage = self:GetSpecialValueFor("void_damage") / 100
    self.duration = self:GetSpecialValueFor("duration")
    self.void_aa_speed = self:GetSpecialValueFor("void_aa_speed") / 100
    self.caster = self:GetCaster()
    self.level = self:GetLevel()

    if (self.level >= 2 and not self.caster:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_34")) then
        GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = self, modifier_name = "modifier_npc_dota_hero_drow_ranger_talent_34", duration = -1 })
    end
    if (self.level >= 4 and not self.caster:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_49")) then
        GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = self, modifier_name = "modifier_npc_dota_hero_drow_ranger_talent_49", duration = -1 })
    end
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_phantom_ranger", MotionController)
end

if (IsServer() and not GameMode.PHANTOM_RANGER_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_phantom_ranger_hunters_focus_buff, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_phantom_ranger_soul_echo, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_phantom_ranger_soul_echo_phantom, 'OnTakeDamage'))
    GameMode.PHANTOM_RANGER_INIT = true
end