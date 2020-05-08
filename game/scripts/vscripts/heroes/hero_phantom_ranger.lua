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

function modifier_phantom_ranger_soul_echo:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_phantom_ranger_soul_echo:OnTakeDamage(kv)
    if IsServer() then
        local attacker = kv.attacker
        local target = kv.unit
        if (attacker ~= target) then
            if (target.phantom_ranger_soul_echo ~= nil) then
                local phantom = target.phantom_ranger_soul_echo.phantom
                if (phantom ~= nil and phantom:IsAlive() and phantom.dmg_transfer ~= nil) then
                    local recievedDamage = kv.damage
                    local phantomDamage = phantom.dmg_transfer * recievedDamage
                    local phantomHealth = phantom:GetHealth() - phantomDamage
                    if (phantomHealth < 1) then
                        phantom_ranger_soul_echo:DestroyPhantom(phantom)
                        target.phantom_ranger_soul_echo.phantom = nil
                    else
                        target:Heal(phantomDamage, phantom)
                        phantom:SetHealth(phantomHealth)
                    end
                end
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
})

function modifier_phantom_ranger_soul_echo_phantom:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
    }
    return state
end

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
    end,
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_maledict.vpcf"
    end,
    StatusEffectPriority = function(self)
        return 15
    end,
})

LinkedModifiers["modifier_phantom_ranger_soul_echo_phantom"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_phantom_ranger_soul_echo_phantom_status_effect"] = LUA_MODIFIER_MOTION_NONE

-- phantom_ranger_soul_echo
phantom_ranger_soul_echo = class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_soul_echo"
    end,
})

function phantom_ranger_soul_echo:DestroyPhantom(phantom)
    if (phantom ~= nil and phantom:IsAlive()) then
        DestroyWearables(phantom,
                function()
                    phantom:Destroy()
                end)
    end
end

function phantom_ranger_soul_echo:OnSpellStart(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        local ability_level = self:GetLevel() - 1
        local duration = self:GetLevelSpecialValueFor("duration", ability_level)
        local phantomHealthAmplify = self:GetLevelSpecialValueFor("phantom_health", ability_level) / 100
        local phantomDamageTransfer = self:GetLevelSpecialValueFor("damage_reduction", ability_level) / 100
        EmitSoundOn("Hero_VoidSpirit.Pulse.Cast", caster)
        GameMode:ApplyBuff({ caster = caster, target = caster, ability = nil, modifier_name = "modifier_phantom_ranger_soul_echo", duration = duration })
        local phantom = CreateUnitByName("npc_dota_phantom_ranger_phantom", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber())
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = phantom
        modifierTable.caster = phantom
        modifierTable.modifier_name = "modifier_phantom_ranger_soul_echo_phantom"
        modifierTable.duration = -1
        GameMode:ApplyBuff(modifierTable)
        local wearables = GetWearables(caster)
        AddWearables(phantom, wearables)
        modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = phantom
        modifierTable.caster = phantom
        modifierTable.modifier_name = "modifier_phantom_ranger_soul_echo_phantom_status_effect"
        modifierTable.duration = -1
        GameMode:ApplyBuff(modifierTable)
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
        local casterHealth = caster:GetHealth()
        local phantomHealth = casterHealth * phantomHealthAmplify
        phantom:SetMaxHealth(phantomHealth)
        phantom:SetHealth(phantomHealth)
        phantom.dmg_transfer = phantomDamageTransfer
        caster.phantom_ranger_soul_echo = caster.phantom_ranger_soul_echo or {}
        caster.phantom_ranger_soul_echo.phantom = phantom
        Timers:CreateTimer(duration,
                function()
                    phantom_ranger_soul_echo:DestroyPhantom(phantom)
                end)
    end
end

-- phantom_ranger_shadow_waves modifiers
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

function modifier_phantom_ranger_shadow_waves_debuff:GetSpellHasteBonus()
    return self:GetAbility().sph_slow
end

function modifier_phantom_ranger_shadow_waves_debuff:GetMoveSpeedPercentBonus()
    return self:GetAbility().ms_slow
end

function modifier_phantom_ranger_shadow_waves_debuff:GetAttackSpeedPercentBonus()
    return self:GetAbility().as_slow
end

LinkedModifiers["modifier_phantom_ranger_shadow_waves_debuff"] = LUA_MODIFIER_MOTION_NONE

-- phantom_ranger_shadow_waves
phantom_ranger_shadow_waves = class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_shadow_waves"
    end,
})

function phantom_ranger_shadow_waves:OnSpellStart(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        local ability_level = self:GetLevel() - 1
        EmitSoundOn("Hero_DrowRanger.Silence", caster)
        self.silence_duration = self:GetLevelSpecialValueFor("silence_duration", ability_level)
        self.duration = self:GetLevelSpecialValueFor("duration", ability_level)
        self.ms_slow = self:GetLevelSpecialValueFor("ms_slow", ability_level) / 100
        self.as_slow = self:GetLevelSpecialValueFor("as_slow", ability_level) / 100
        self.sph_slow = self:GetLevelSpecialValueFor("sph_slow", ability_level) / 100
        local info = {
            Ability = self,
            EffectName = "particles/units/phantom_ranger/phantom_ranger_shadow_wave_proj.vpcf",
            vSpawnOrigin = caster:GetAbsOrigin(),
            fDistance = 800,
            fStartRadius = 400,
            fEndRadius = 400,
            Source = caster,
            bHasFrontalCone = false,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 10.0,
            bDeleteOnHit = true,
            vVelocity = caster:GetForwardVector() * 1800,
            bProvidesVision = true,
            iVisionRadius = 500,
            iVisionTeamNumber = caster:GetTeamNumber()
        }
        ProjectileManager:CreateLinearProjectile(info)
    end
end

function phantom_ranger_shadow_waves:OnProjectileHit(target, location)
    if (target ~= nil) then
        local caster = self:GetCaster()
        GameMode:ApplyDebuff({ caster = caster, target = target, ability = self, modifier_name = "modifier_phantom_ranger_shadow_waves_debuff", duration = self.duration })
        GameMode:ApplyDebuff({ caster = caster, target = target, ability = self, modifier_name = "modifier_silence", duration = self.silence_duration })
    end
    return false
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
})

function modifier_phantom_ranger_phantom_harmonic:OnCreated(kv)
    if (IsServer()) then
        self.owner = self:GetParent()
        self.ability = self:GetAbility()
    end
end

function modifier_phantom_ranger_phantom_harmonic:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_phantom_ranger_phantom_harmonic:OnAttackLanded(kv)
    if IsServer() then
        local attacker = kv.attacker
        local target = kv.target
        if (attacker ~= nil and target ~= nil and attacker ~= target and attacker == self.owner) then
            local IsProc = RollPercentage(self.ability.proc_chance)
            if (not IsProc) then
                return
            end
            local targetPosition = target:GetAbsOrigin()
            local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                    targetPosition,
                    nil,
                    600,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            if (#enemies > 0) then
                local index = self.ability:GetUniqueInt()
                self.ability.projectiles[index] = { targets = enemies }
                phantom_ranger_phantom_harmonic:CreateBounceProjectile(target, target, { index = index }, self.ability)
            end
        end
    end
end

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

LinkedModifiers["modifier_phantom_ranger_phantom_harmonic"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_phantom_ranger_phantom_harmonic_stacks"] = LUA_MODIFIER_MOTION_NONE

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
    if IsServer() then
        local ability_level = self:GetLevel() - 1
        self.max_stacks = self:GetLevelSpecialValueFor("max_stacks", ability_level)
        self.proc_damage = self:GetLevelSpecialValueFor("proc_damage", ability_level) / 100
        self.duration = self:GetLevelSpecialValueFor("duration", ability_level)
        self.proc_chance = self:GetLevelSpecialValueFor("proc_chance", ability_level)
    end
end

function phantom_ranger_phantom_harmonic:OnProjectileHit_ExtraData(target, vLocation, ExtraData)
    if (IsServer() and target ~= nil and ExtraData ~= nil) then
        local caster = self:GetCaster()
        local index = ExtraData.index
        if (target == caster) then
            GameMode:ApplyStackingBuff({ caster = caster, target = caster, ability = self, modifier_name = "modifier_phantom_ranger_phantom_harmonic_stacks", duration = self.duration, stacks = #self.projectiles[index].reachedTargets, max_stacks = self.max_stacks })
            self.projectiles[index] = nil
            self:DelUniqueInt(index)
            return true
        end
        local jumpTarget
        local enemies = self.projectiles[index].targets
        self.projectiles[index].reachedTargets = self.projectiles[index].reachedTargets or {}
        local damage = self.proc_damage * Units:GetAttackDamage(caster)
        GameMode:DamageUnit({ caster = caster, target = target, damage = damage, voiddmg = true })
        table.insert(self.projectiles[index].reachedTargets, target)
        while #enemies > 0 do
            local potentialJumpTarget = enemies[1]
            if potentialJumpTarget == nil or potentialJumpTarget:IsNull() or TableContains(self.projectiles[index].reachedTargets, potentialJumpTarget) then
                table.remove(enemies, 1)
            else
                jumpTarget = potentialJumpTarget
                break
            end
        end
        self.projectiles[index].targets = enemies
        if (#enemies == 0) then
            phantom_ranger_phantom_harmonic:CreateBounceProjectile(target, caster, ExtraData, self)
        else
            phantom_ranger_phantom_harmonic:CreateBounceProjectile(target, jumpTarget, ExtraData, self)
        end
    end
    return false
end

function phantom_ranger_phantom_harmonic:CreateBounceProjectile(source, target, extraData, ability)
    local projectile = {
        Target = target,
        Source = source,
        Ability = ability,
        EffectName = "particles/units/phantom_ranger/phantom_ranger_phantom_harmonic_proj.vpcf",
        bDodgable = false,
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
})

function phantom_ranger_void_disciple:OnSpellStart(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        local position = caster:GetAbsOrigin()
        local harmonic_stacks = caster:GetModifierStackCount("modifier_phantom_ranger_phantom_harmonic_stacks", caster)
        local harmonic_ability = caster:FindAbilityByName("phantom_ranger_phantom_harmonic")
        if (harmonic_stacks > 0 and harmonic_ability ~= nil) then
            local harmonic_ability_level = harmonic_ability:GetLevel()
            if (harmonic_ability_level > 0) then
                local cdr_per_stack = harmonic_ability:GetLevelSpecialValueFor("cdr_per_stack", harmonic_ability_level - 1)
                local reducedCooldown = harmonic_stacks * cdr_per_stack
                GameMode:ReduceAbilityCooldown({ target = caster, ability = "phantom_ranger_void_disciple", reduction = reducedCooldown, isflat = true })
            end
        end
        caster.phantom_ranger_void_disciple = caster.phantom_ranger_void_disciple or {}
        caster.phantom_ranger_void_disciple.current_voids = caster.phantom_ranger_void_disciple.current_voids or 0
        if (caster.phantom_ranger_void_disciple.current_voids == self.max_voids) then
            return
        end
        caster.phantom_ranger_void_disciple.current_voids = caster.phantom_ranger_void_disciple.current_voids + 1
        local summon_damage = Units:GetAttackDamage(caster) * self.void_damage
        local summon = Summons:SummonUnit({ caster = caster, unit = "npc_dota_phantom_ranger_void_disciple", position = position, damage = summon_damage, ability = self })
        if (summon == nil) then
            return
        end
        EmitSoundOn("Hero_VoidSpirit.Pulse.Cast", summon)
        Summons:SetSummonHaveVoidDamageType(summon, true)
        Summons:SetSummonAttackSpeed(summon, Units:GetAttackSpeed(caster) * self.void_aa_speed)
        Summons:SetSummonCanProcOwnerAutoAttack(summon, true)
        local particle = ParticleManager:CreateParticle("particles/units/phantom_ranger/test/void_disciple/void_disciple_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, summon)
        ParticleManager:SetParticleControl(particle, 0, summon:GetAbsOrigin())
        Timers:CreateTimer(self.duration,
                function()
                    summon:Destroy()
                    caster.phantom_ranger_void_disciple.current_voids = caster.phantom_ranger_void_disciple.current_voids - 1
                    ParticleManager:DestroyParticle(particle, false)
                end)
    end
end

function phantom_ranger_void_disciple:OnUpgrade()
    if IsServer() then
        local ability_level = self:GetLevel() - 1
        self.max_voids = self:GetLevelSpecialValueFor("max_voids", ability_level)
        self.void_damage = self:GetLevelSpecialValueFor("void_damage", ability_level) / 100
        self.duration = self:GetLevelSpecialValueFor("duration", ability_level)
        self.void_aa_speed = self:GetLevelSpecialValueFor("void_aa_speed", ability_level) / 100
    end
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_phantom_ranger", MotionController)
end