local LinkedModifiers = {}

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
    end,
    GetTexture = function(self)
        return phantom_ranger_soul_echo:GetAbilityTextureName()
    end,
})

function modifier_phantom_ranger_soul_echo:OnTakeDamage(damageTable)
    if (damageTable.victim.phantom_ranger_soul_echo) then
        local modifier = damageTable.victim:FindModifierByName("modifier_phantom_ranger_soul_echo")
        local phantom = damageTable.victim.phantom_ranger_soul_echo.phantom
        if (damageTable.damage > 0 and modifier and phantom and not phantom:IsNull() and phantom:IsAlive()) then
            local phantomDamage = phantom.damageTransfer * damageTable.damage
            local phantomHealth = phantom:GetHealth() - phantomDamage
            if (phantomHealth < 1) then
                phantom_ranger_soul_echo:DestroyPhantom(phantom)
                damageTable.victim.phantom_ranger_soul_echo.phantom = nil
            else
                damageTable.damage = damageTable.damage - phantomDamage
                phantom:SetHealth(phantomHealth)
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
    GetEffectName = function(self)
        return "particles/units/phantom_ranger/test/soul_echo/soul_echo_phantom.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end,
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_maledict.vpcf"
    end,
    StatusEffectPriority = function(self)
        return 15
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

function modifier_phantom_ranger_soul_echo_phantom:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_phantom_ranger_soul_echo_phantom")
    if (modifier) then
        damageTable.damage = 0
        return damageTable
    end
end

LinkedModifiers["modifier_phantom_ranger_soul_echo_phantom"] = LUA_MODIFIER_MOTION_NONE

-- phantom_ranger_soul_echo
phantom_ranger_soul_echo = class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_soul_echo"
    end,
})

function phantom_ranger_soul_echo:DestroyPhantom(phantom)
    if (phantom ~= nil and phantom:IsAlive()) then
        DestroyWearables(phantom, function()
            phantom:Destroy()
        end)
    end
end

function phantom_ranger_soul_echo:CreatePhantom()
    local phantom = CreateUnitByName("npc_dota_phantom_ranger_phantom", self.caster:GetAbsOrigin(), true, self.caster, self.caster, self.caster:GetTeamNumber())
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = phantom
    modifierTable.caster = phantom
    modifierTable.modifier_name = "modifier_phantom_ranger_soul_echo_phantom"
    modifierTable.duration = -1
    GameMode:ApplyBuff(modifierTable)
    local wearables = GetWearables(self.caster)
    AddWearables(phantom, wearables)
    ForEachWearable(phantom,
            function(wearable)
                modifierTable = {}
                modifierTable.ability = self
                modifierTable.target = wearable
                modifierTable.caster = phantom
                modifierTable.modifier_name = "modifier_phantom_ranger_soul_echo_phantom"
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
    -- Talent 47 (Mirage) duration increase
    local modifier = self.caster:FindModifierByName("modifier_npc_dota_hero_drow_ranger_talent_47")
    if (modifier) then

        local talent47_level = TalentTree:GetHeroTalentLevel(self.caster, 47)
        self.duration = self.duration + modifier.talent47_baseExtraDuration + talent47_level * modifier.talent47_extraDurationPerLevel

    end
    Timers:CreateTimer(self.duration, function()
        phantom_ranger_soul_echo:DestroyPhantom(phantom)
    end)
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
    end,
    GetEffectName = function(self)
        return "particles/units/phantom_ranger/phantom_ranger_shadow_wave_debuff.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end,
    GetTexture = function(self)
        return phantom_ranger_shadow_waves:GetAbilityTextureName()
    end,
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

    if not IsServer() then return end 
    self.caster = self:GetCaster()
    self.damageScaling = self:GetSpecialValueFor("void_damage") / 100
    self.silenceDuration = self:GetSpecialValueFor("silence_duration")
    self.duration = self:GetSpecialValueFor("duration")
    self.msSlow = self:GetSpecialValueFor("ms_slow") / 100
    self.asSlow = self:GetSpecialValueFor("as_slow") / 100
    self.sphSlow = self:GetSpecialValueFor("sph_slow") / 100 
    self.talent51_level = TalentTree:GetHeroTalentLevel(self.caster, 51) 
    -- Shadowcaster - talent 51 variables
    self.talent51_baseCastTime = 2.2
    self.talent51_reducedCastTimePerLevel = 0.2
    self.talent51_cd = 0



end

function phantom_ranger_shadow_waves:OnAbilityPhaseStart()

    if not IsServer() then return true end 
    self.talent51_level = TalentTree:GetHeroTalentLevel(self.caster, 51) 
    return true

end

function phantom_ranger_shadow_waves:OnSpellStart(sourceUnit, target)
    if not IsServer() then return end
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
        EffectName = "particles/units/phantom_ranger/phantom_ranger_shadow_wave_proj.vpcf",
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

        local talent45_level = TalentTree:GetHeroTalentLevel(self.caster, 45)
        local stealthDuration = modifier.talent45_baseStealthDuration + talent45_level * modifier.talent45_stealthDurationPerLevel
        GameMode:ApplyBuff ({ caster = self.caster, target = self.caster, ability = nil, modifier_name = "modifier_phantom_ranger_stealth", duration = stealthDuration })
        self.caster:AddNewModifier(self.caster, nil, "modifier_phantom_ranger_cloak_of_shadows_stealth_cd", { duration = modifier.talent45_cd }) 

    end

end

function phantom_ranger_shadow_waves:OnProjectileHit_ExtraData(target, location, ExtraData)

    if (target ~= nil) then

        GameMode:DamageUnit({ caster = self.caster, target = target, ability = self, damage = Units:GetAttackDamage(self.caster) * self.damageScaling , voiddmg = true, fromsummon = ExtraData.fromsummon })
        target:EmitSound("Hero_ShadowDemon.ShadowPoison.Impact")
        GameMode:ApplyDebuff({ caster = self.caster, target = target, ability = self, modifier_name = "modifier_phantom_ranger_shadow_waves_debuff", duration = self.duration })
        if not (self.talent51_level > 0) then

            GameMode:ApplyDebuff({ caster = self.caster, target = target, ability = self, modifier_name = "modifier_silence", duration = self.silenceDuration })

        else

            local silenceCoolingDown = target:FindModifierByName("modifier_phantom_ranger_shadow_waves_silence_cd")
            local silenceCd = self:GetOriginalCooldown(self:GetLevel() - 1) * Units:GetCooldownReduction(self.caster)
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

    if not IsServer() then return self.BaseClass.GetCastPoint(self) end
    if not self.talent51_level then self.talent51_level = TalentTree:GetHeroTalentLevel(self.caster, 51) end
    if (self.talent51_level > 0) then

        return (self.talent51_baseCastTime - self.talent51_level * self.talent51_reducedCastTimePerLevel)

    else

        return self.BaseClass.GetCastPoint(self)

    end

end

function phantom_ranger_shadow_waves:IsRequireCastbar()

    if not IsServer() then return end
    if not self.talent51_level then self.talent51_level = TalentTree:GetHeroTalentLevel(self.caster, 51) end
    return (self.talent51_level > 0)

end

function phantom_ranger_shadow_waves:GetCooldown(level)

    if not IsServer() then return self.BaseClass.GetCooldown(self, level) end
    if not self.talent51_level then self.talent51_level = TalentTree:GetHeroTalentLevel(self.caster, 51) end
    if (self.talent51_level > 0) then

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
            local talent48_level = TalentTree:GetHeroTalentLevel(self.caster, 48)
            local bonusProcChance = 0
            if (talent48_level > 0) then bonusProcChance = self.talent48_baseChanceIncrease + self.talent48_chanceIncreasePerLevel * talent48_level end 
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

    if not IsServer() then return end
    local caster = self:GetParent()
    self.talent48_level = TalentTree:GetHeroTalentLevel(caster, 48)
    --Deadly Vibration - talent 48 variables
    self.talent48_percentAdPerStack, self.talent48_percentArmorPerStack, self.talent48_resistsPerStack = 3, 3, 3

end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetAttackDamagePercentBonus()
    if (self.talent48_level > 0) then return self:GetStackCount() * self.talent48_percentAdPerStack / 100 else return 0 end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetArmorPercentBonus()
   if (self.talent48_level > 0) then return self:GetStackCount() * self.talent48_percentArmorPerStack / 100 else return 0 end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetFireProtectionBonus()
   if (self.talent48_level > 0) then return self:GetStackCount() * self.talent48_resistsPerStack / 100 else return 0 end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetFrostProtectionBonus()
    if (self.talent48_level > 0) then return self:GetStackCount() * self.talent48_resistsPerStack / 100 else return 0 end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetEarthProtectionBonus()
    if (self.talent48_level > 0) then return self:GetStackCount() * self.talent48_resistsPerStack / 100 else return 0 end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetVoidProtectionBonus()
    if (self.talent48_level > 0) then return self:GetStackCount() * self.talent48_resistsPerStack / 100 else return 0 end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetHolyProtectionBonus()
    if (self.talent48_level > 0) then return self:GetStackCount() * self.talent48_resistsPerStack / 100 else return 0 end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetNatureProtectionBonus()
    if (self.talent48_level > 0) then return self:GetStackCount() * self.talent48_resistsPerStack / 100 else return 0 end
end

function modifier_phantom_ranger_phantom_harmonic_stacks:GetInfernoProtectionBonus()
    if (self.talent48_level > 0) then return self:GetStackCount() * self.talent48_resistsPerStack / 100 else return 0 end
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
        GameMode:ApplyStackingBuff(modifierTable)
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
        EffectName = "particles/units/phantom_ranger/phantom_ranger_phantom_harmonic_proj.vpcf",
        bDodgeable = false,
        bProvidesVision = false,
        iMoveSpeed = 800,
        ExtraData = extraData
    }
    ProjectileManager:CreateTrackingProjectile(projectile)
end

-- phantom_ranger_void_disciple
phantom_ranger_void_disciple = class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_void_disciple"
    end,
     GetCastAnimation = function(self)
        return ACT_DOTA_CAST_ABILITY_3
    end
})

function phantom_ranger_void_disciple:OnSpellStart(source)
    if not IsServer() then return end
    local caster = self:GetCaster()
    source = source or caster
    local casterPosition = source:GetAbsOrigin()
    local harmonicStacks = caster:GetModifierStackCount("modifier_phantom_ranger_phantom_harmonic_stacks", caster)
    local harmonicAbility = caster:FindAbilityByName("phantom_ranger_phantom_harmonic")
    if (harmonicStacks > 0 and harmonicAbility and harmonicAbility:GetLevel() > 0) then
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
    Summons:SetSummonCanProcOwnerAutoAttack(summon, true)
    local particle = ParticleManager:CreateParticle("particles/units/phantom_ranger/test/void_disciple/void_disciple_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, summon)
    ParticleManager:SetParticleControl(particle, 0, summon:GetAbsOrigin())
    Timers:CreateTimer(self.duration, function()
        summon:Destroy()
        caster.phantom_ranger_void_disciple.current_voids = caster.phantom_ranger_void_disciple.current_voids - 1
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
    end)
end

function phantom_ranger_void_disciple:OnUpgrade()
    if (not IsServer()) then

    end
    self.max_voids = self:GetSpecialValueFor("max_voids")
    self.void_damage = self:GetSpecialValueFor("void_damage") / 100
    self.duration = self:GetSpecialValueFor("duration")
    self.void_aa_speed = self:GetSpecialValueFor("void_aa_speed") / 100
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_phantom_ranger", MotionController)
end

if (IsServer() and not GameMode.PHANTOM_RANGER_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_phantom_ranger_soul_echo, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_phantom_ranger_soul_echo_phantom, 'OnTakeDamage'))
    GameMode.PHANTOM_RANGER_INIT = true
end