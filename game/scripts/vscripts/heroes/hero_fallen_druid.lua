local LinkedModifiers = {}

-- fallen_druid_wisp_companion
modifier_fallen_druid_wisp_companion_primary_buff = class({
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
    end
})

function modifier_fallen_druid_wisp_companion_primary_buff:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_fallen_druid_wisp_companion_primary_buff:GetPrimaryAttributePercentBonus()
    return self.ability.wispPrimaryBuff
end

LinkedModifiers["modifier_fallen_druid_wisp_companion_primary_buff"] = LUA_MODIFIER_MOTION_NONE

WISPY_STATE_ATTACHED_TO_WAIFU = 1
WISPY_STATE_ATTACHED_TO_ALLY = 2
WISPY_STATE_TRAVEL_TO_TARGET = 3
WISPY_STATE_TRAVEL_BACK = 4
WISPY_STATE_TRAVEL_TO_SHADOW_VORTEX = 5
WISPY_STATE_CASTING_SHADOW_VORTEX = 6

modifier_fallen_druid_wisp_companion_ai = class({
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
        return MODIFIER_ATTRIBUTE_PERMAMENT
    end,
    CheckState = function(self)
        return
        {
            [MODIFIER_STATE_INVULNERABLE] = true,
            [MODIFIER_STATE_UNSELECTABLE] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_OUT_OF_GAME] = true,
            [MODIFIER_STATE_FLYING] = true
        }
    end,
    DeclareFunctions = function(self)
        return
        {
            MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
            MODIFIER_EVENT_ON_ATTACK_LANDED,
            MODIFIER_PROPERTY_VISUAL_Z_DELTA
        }
    end
})

function modifier_fallen_druid_wisp_companion_ai:GetVisualZDelta()
    local state = self:GetStackCount()
    if (state == WISPY_STATE_TRAVEL_BACK or state == WISPY_STATE_TRAVEL_TO_TARGET or state == WISPY_STATE_ATTACHED_TO_ALLY or state == WISPY_STATE_TRAVEL_TO_SHADOW_VORTEX or state == WISPY_STATE_CASTING_SHADOW_VORTEX) then
        return 120
    end
    return 0
end

function modifier_fallen_druid_wisp_companion_ai:GetModifierMoveSpeed_AbsoluteMin()
    return self.ability.wispMoveSpeed
end

function modifier_fallen_druid_wisp_companion_ai:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    if (self.state == WISPY_STATE_TRAVEL_BACK) then
        local wispyPosition = self.wispy:GetAbsOrigin()
        local targetPosition = self.holder:GetAbsOrigin()
        if ((targetPosition - wispyPosition):Length2D() > 100) then
            self.wispy:MoveToPosition(targetPosition)
        else
            if (self.holder == self.caster) then
                self:ChangeState(WISPY_STATE_ATTACHED_TO_WAIFU)
            else
                self:ChangeState(WISPY_STATE_ATTACHED_TO_ALLY)
                self.wispy.rotationAngle = math.atan2(targetPosition[2] - wispyPosition[2], targetPosition[1] - wispyPosition[1])
            end
        end
    elseif (self.state == WISPY_STATE_TRAVEL_TO_TARGET) then
        if (self.target and not self.target:IsNull()) then
            if (self.wispy:GetAggroTarget() ~= self.target) then
                self.wispy:MoveToTargetToAttack(self.target)
            end
        else
            self:ChangeState(WISPY_STATE_TRAVEL_BACK)
        end
    elseif (self.state == WISPY_STATE_ATTACHED_TO_ALLY) then
        self.wispy:Stop()
        local position = self.holder:GetAbsOrigin()
        local distanceFromCenter = self.holder:GetPaddedCollisionRadius() + 75
        local wispyPosition = Vector(position[1] + distanceFromCenter * math.cos(self.wispy.rotationAngle), position[2] + distanceFromCenter * math.sin(self.wispy.rotationAngle), position[3])
        self.wispy:SetAbsOrigin(wispyPosition)
        self.wispy.rotationAngle = self.wispy.rotationAngle + 0.1
        if (self.wispy.rotationAngle > 6) then
            self.wispy.rotationAngle = 0
        end
    elseif (self.state == WISPY_STATE_TRAVEL_TO_SHADOW_VORTEX) then
        local wispyPosition = self.wispy:GetAbsOrigin()
        local targetPosition = self.shadowVortexPosition
        if not ((targetPosition - wispyPosition):Length2D() > 100) then
            self.wispy.rotationAngle = math.atan2(targetPosition[2] - wispyPosition[2], targetPosition[1] - wispyPosition[1])
            self:ChangeState(WISPY_STATE_CASTING_SHADOW_VORTEX)
            self.shadowVortexAbility:CreateShadowVortex(self.shadowVortexPosition)
        end
    elseif (self.state == WISPY_STATE_CASTING_SHADOW_VORTEX) then
        self.wispy:Stop()
        local position = self.shadowVortexPosition
        local distanceFromCenter = self.shadowVortexRadius
        local wispyPosition = Vector(position[1] + distanceFromCenter * math.cos(self.wispy.rotationAngle), position[2] + distanceFromCenter * math.sin(self.wispy.rotationAngle), position[3])
        self.wispy:SetAbsOrigin(wispyPosition)
        self.wispy.rotationAngle = self.wispy.rotationAngle + 0.1
        if (self.wispy.rotationAngle > 6) then
            self.wispy.rotationAngle = 0
        end
    else
        self.wispy:Stop()
        self.wispy:SetOrigin(self.caster:GetAttachmentOrigin(self.caster:ScriptLookupAttachment("attach_lantern")))
    end
end

function modifier_fallen_druid_wisp_companion_ai:OnAttackLanded(kv)
    if IsServer() then
        local attacker = kv.attacker
        local target = kv.target
        if (attacker and target and not target:IsNull() and attacker == self.wispy) then
            self.ability:DealWispyDamageToTarget(self.caster, target)
            local thirdSkillModifier = target:FindModifierByName("modifier_fallen_druid_grasping_roots_dot")
            if (thirdSkillModifier and thirdSkillModifier.ability.wispyBounce > 0) then
                local enemies = FindUnitsInRadius(self.casterTeam,
                        Vector(0, 0, 0),
                        nil,
                        FIND_UNITS_EVERYWHERE,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_ALL,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false)
                local index = self.ability:GetUniqueInt()
                self.ability.projectiles[index] = { targets = enemies, reachedTargets = {}, caster = self.caster }
                table.insert(self.ability.projectiles[index].reachedTargets, target)
                self.ability:CreateWispyBounceProjectile(target, target, { index = index })
            end
            self.wispy:Stop()
            self:ChangeState(WISPY_STATE_TRAVEL_BACK)
        end
    end
end

function modifier_fallen_druid_wisp_companion_ai:ChangeState(newstate)
    if (not IsServer()) then
        return
    end
    self.state = newstate
    self:SetStackCount(self.state)
end

function modifier_fallen_druid_wisp_companion_ai:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.casterTeam = self.caster:GetTeamNumber()
    self.wispy = self:GetParent()
    self.particle = ParticleManager:CreateParticle("particles/units/fallen_druid/wisp_companion/wispy.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:StartIntervalThink(0.05)
end

function modifier_fallen_druid_wisp_companion_ai:OnDestroy()
    if (not IsServer()) then
        return
    end
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    UTIL_Remove(self.wispy)
end

LinkedModifiers["modifier_fallen_druid_wisp_companion_ai"] = LUA_MODIFIER_MOTION_NONE

modifier_fallen_druid_wisp_companion = class({
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
        return MODIFIER_ATTRIBUTE_PERMAMENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_fallen_druid_wisp_companion:OnCreated(kv)
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_fallen_druid_wisp_companion:OnAttackLanded(kv)
    if IsServer() then
        local attacker = kv.attacker
        local target = kv.target
        if (attacker and target and not target:IsNull() and attacker == self.caster) then
            self.ability:OrderWispyAttackTarget(self.ability.wispy, target)
        end
    end
end

LinkedModifiers["modifier_fallen_druid_wisp_companion"] = LUA_MODIFIER_MOTION_NONE

modifier_fallen_druid_wisp_companion_aa_fix = class({
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
        return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
    end,
    GetModifierBaseDamageOutgoing_Percentage = function(self)
        return -100
    end
})

LinkedModifiers["modifier_fallen_druid_wisp_companion_aa_fix"] = LUA_MODIFIER_MOTION_NONE

fallen_druid_wisp_companion = class({
    GetIntrinsicModifierName = function(self)
        return "modifier_fallen_druid_wisp_companion"
    end
})

fallen_druid_wisp_companion.projectiles = {}
fallen_druid_wisp_companion.unique = {}
fallen_druid_wisp_companion.i = 0
fallen_druid_wisp_companion.max = 65536

function fallen_druid_wisp_companion:GetUniqueInt()
    while self.unique[self.i] do
        self.i = self.i + 1
        if self.i == self.max then
            self.i = 0
        end
    end

    self.unique[self.i] = true
    return self.i
end

function fallen_druid_wisp_companion:DelUniqueInt(i)
    self.unique[i] = nil
end

function fallen_druid_wisp_companion:DealWispyDamageToTarget(owner, target)
    local pidx = ParticleManager:CreateParticle("particles/units/fallen_druid/wisp_companion/wispy_impact.vpcf", PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControlEnt(pidx, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    local damageTable = {}
    damageTable.caster = owner
    damageTable.target = target
    damageTable.ability = self
    damageTable.damage = self.wispDamage * Units:GetHeroAgility(owner)
    damageTable.naturedmg = true
    damageTable.fromsummon = true
    damageTable.single = true
    GameMode:DamageUnit(damageTable)
    target:EmitSound("Hero_DarkWillow.WillOWisp.Damage")
    if (self.wispDamageOnHitProc > 0) then
        local modifier = owner:AddNewModifier(owner, nil, "modifier_fallen_druid_wisp_companion_aa_fix", {})
        owner:PerformAttack(target, true, true, true, true, false, false, true)
        modifier:Destroy()
    end
end

function fallen_druid_wisp_companion:OnProjectileHit_ExtraData(target, vLocation, ExtraData)
    if (not IsServer() or not target or not ExtraData) then
        return
    end
    local jumpTarget
    local enemies = self.projectiles[ExtraData.index].targets
    self:DealWispyDamageToTarget(self.projectiles[ExtraData.index].caster, target)
    table.insert(self.projectiles[ExtraData.index].reachedTargets, target)
    while #enemies > 0 do
        local potentialJumpTarget = enemies[1]
        if (not potentialJumpTarget or potentialJumpTarget:IsNull() or TableContains(self.projectiles[ExtraData.index].reachedTargets, potentialJumpTarget) or potentialJumpTarget:GetHealth() < 1 or not potentialJumpTarget:HasModifier("modifier_fallen_druid_grasping_roots_dot")) then
            table.remove(enemies, 1)
        else
            jumpTarget = potentialJumpTarget
            break
        end
    end
    self.projectiles[ExtraData.index].targets = enemies
    if (#enemies > 0) then
        self:CreateWispyBounceProjectile(target, jumpTarget, ExtraData)
    else
        self.projectiles[ExtraData.index] = nil
        self:DelUniqueInt(ExtraData.index)
        return true
    end
    return false
end

function fallen_druid_wisp_companion:CreateWispyBounceProjectile(source, target, extraData)
    local projectile = {
        Target = target,
        Source = source,
        Ability = self,
        EffectName = "particles/units/fallen_druid/wisp_companion/wispy_bounce_projectile.vpcf",
        bDodgeable = false,
        bProvidesVision = false,
        iMoveSpeed = 1200,
        ExtraData = extraData
    }
    ProjectileManager:CreateTrackingProjectile(projectile)
end

function fallen_druid_wisp_companion:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    self:AttachWispyToAlly(self.wispy, target)
    if (self.wispPrimaryBuffDuration > 0 and caster ~= target) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = target
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_fallen_druid_wisp_companion_primary_buff"
        modifierTable.duration = self.wispPrimaryBuffDuration
        GameMode:ApplyBuff(modifierTable)
    end
end

function fallen_druid_wisp_companion:OnPostTakeDamage(damageTable)
    local ability = damageTable.attacker:FindAbilityByName("fallen_druid_wisp_companion")
    if (not ability or ability:GetLevel() == 0 or not damageTable.fromsummon or not damageTable.ability) then
        return damageTable
    end
    if (ability.wispHealing and not (ability.wispHealing > 0) or ability.wispHealingCurrentInCD) then
        return damageTable
    end
    local healTable = {}
    healTable.caster = damageTable.attacker
    healTable.target = damageTable.attacker
    healTable.heal = damageTable.damage * ability.wispHealing
    GameMode:HealUnit(healTable)
    local healFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_POINT_FOLLOW, damageTable.attacker)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(healFX, false)
        ParticleManager:ReleaseParticleIndex(healFX)
    end)
    ability.wispHealingCurrentInCD = true
    Timers:CreateTimer(ability.wispHealingCooldown, function()
        ability.wispHealingCurrentInCD = nil
    end)
end

function fallen_druid_wisp_companion:CreateWispy()
    if (not self.wispy and IsServer()) then
        local caster = self:GetCaster()
        self.wispy = CreateUnitByName("npc_dota_fallen_druid_wispy", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
        self.wispy.modifier = self.wispy:AddNewModifier(self.wispy, self, "modifier_fallen_druid_wisp_companion_ai", {})
        self:AttachWispyToLantern(self.wispy, caster)
        self.wispy.modifier:ChangeState(WISPY_STATE_ATTACHED_TO_WAIFU)
        self.wispy:SetHullRadius(0)
    end
end

function fallen_druid_wisp_companion:AttachWispyToLantern(wispy, waifu)
    if (wispy and not wispy:IsNull()) then
        wispy.modifier.holder = waifu
    end
end

function fallen_druid_wisp_companion:AttachWispyToAlly(wispy, ally)
    if (not wispy or wispy:IsNull()) then
        return
    end
    wispy.modifier.holder = ally
    if (wispy.modifier.state == WISPY_STATE_TRAVEL_TO_TARGET) then
        return
    end
    if (wispy.modifier.state == WISPY_STATE_TRAVEL_TO_SHADOW_VORTEX) then
        return
    end
    if (wispy.modifier.state == WISPY_STATE_CASTING_SHADOW_VORTEX) then
        return
    end
    wispy.modifier:ChangeState(WISPY_STATE_TRAVEL_BACK)
end

function fallen_druid_wisp_companion:OrderWispyCastShadowVortex(wispy, castPosition, shadowVortexAbility)
    if (not wispy or wispy:IsNull()) then
        return
    end
    wispy.modifier:ChangeState(WISPY_STATE_TRAVEL_TO_SHADOW_VORTEX)
    wispy.modifier.shadowVortexPosition = castPosition
    local ability = self:GetCaster():FindAbilityByName("fallen_druid_shadow_vortex")
    if (ability and ability:GetLevel() > 0) then
        wispy.modifier.shadowVortexRadius = ability.radius * 0.8
    else
        wispy.modifier.shadowVortexRadius = 480 -- default * 0.8
    end
    wispy.modifier.shadowVortexAbility = shadowVortexAbility
    wispy:MoveToPosition(wispy.modifier.shadowVortexPosition)
end

function fallen_druid_wisp_companion:OrderWispyAttackTarget(wispy, target)
    if (not wispy or wispy:IsNull()) then
        return
    end
    if (wispy.modifier.state == WISPY_STATE_TRAVEL_TO_TARGET or wispy.modifier.state == WISPY_STATE_TRAVEL_BACK) then
        return
    end
    if (wispy.modifier.state == WISPY_STATE_TRAVEL_TO_SHADOW_VORTEX or wispy.modifier.state == WISPY_STATE_CASTING_SHADOW_VORTEX) then
        return
    end
    wispy.modifier:ChangeState(WISPY_STATE_TRAVEL_TO_TARGET)
    wispy.modifier.target = target
end

function fallen_druid_wisp_companion:OnUpgrade()
    self:CreateWispy()
    self.wispDamage = self:GetSpecialValueFor("wisp_damage") / 100
    self.wispMoveSpeed = self:GetSpecialValueFor("wisp_ms")
    self.wispHealing = self:GetSpecialValueFor("wisp_healing") / 100
    self.wispHealingCooldown = self:GetSpecialValueFor("wisp_healing_cd")
    self.wispPrimaryBuff = self:GetSpecialValueFor("wist_primary_buff") / 100
    self.wispPrimaryBuffDuration = self:GetSpecialValueFor("wist_primary_buff_duration")
    self.wispDamageOnHitProc = self:GetSpecialValueFor("wist_on_hit_proc")
end

--fallen_druid_flashbang
modifier_fallen_druid_flashbang_miss = class({
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
    DeclareFunctions = function(self)
        return
        {
            MODIFIER_PROPERTY_MISS_PERCENTAGE
        }
    end,
    GetModifierMiss_Percentage = function(self)
        return self.ability.missChance
    end
})

function modifier_fallen_druid_flashbang_miss:OnCreated()
    self.ability = self:GetAbility()
end

LinkedModifiers["modifier_fallen_druid_flashbang_miss"] = LUA_MODIFIER_MOTION_NONE

modifier_fallen_druid_flashbang_buff = class({
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
    GetSpellDamageBonus = function(self)
        return self.ability.spellDamageAmplify
    end
})

function modifier_fallen_druid_flashbang_buff:OnCreated()
    self.ability = self:GetAbility()
end

LinkedModifiers["modifier_fallen_druid_flashbang_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_fallen_druid_flashbang_shadow = class({
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
    GetEffectName = function(self)
        return "particles/units/fallen_druid/flashbang/flashbang_shadow.vpcf"
    end,
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_void_spirit_astral_step_debuff.vpcf"
    end,
    StatusEffectPriority = function(self)
        return 15
    end,
    GetAttackRangeBonus = function(self)
        return Units:GetAttackRange(self.caster, true)
    end,
    GetMoveSpeedBonus = function(self)
        return Units:GetMoveSpeed(self.caster)
    end
})

function modifier_fallen_druid_flashbang_shadow:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self:StartIntervalThink(self.ability.shadowDuration)
end

function modifier_fallen_druid_flashbang_shadow:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local shadow = self:GetParent()
    DestroyWearables(shadow, function()
        shadow:Destroy()
    end)
end

LinkedModifiers["modifier_fallen_druid_flashbang_shadow"] = LUA_MODIFIER_MOTION_NONE

fallen_druid_flashbang = class({
    GetCastRange = function(self)
        return self:GetSpecialValueFor("radius")
    end,
})

function fallen_druid_flashbang:OnSpellStart(customPosition)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("fallen_druid_wisp_companion")
    local casterPos = caster:GetAbsOrigin()
    if (customPosition) then
        casterPos = customPosition
    else
        if (ability and ability:GetLevel() > 0) then
            casterPos = ability.wispy:GetAbsOrigin()
        end
    end
    local pidx = ParticleManager:CreateParticle("particles/units/fallen_druid/flashbang/flashbang.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx, 0, casterPos)
    ParticleManager:SetParticleControl(pidx, 1, Vector(self.radius, 1, 1))
    ParticleManager:SetParticleControl(pidx, 2, Vector(0.5, 0.5, 0.5))
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
            casterPos,
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local damage = Units:GetHeroAgility(caster) * self.damage
    for _, enemy in pairs(enemies) do
        local damageTable = {}
        damageTable.damage = damage
        damageTable.caster = caster
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.naturedmg = true
        damageTable.aoe = true
        GameMode:DamageUnit(damageTable)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = enemy
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_fallen_druid_flashbang_miss"
        modifierTable.duration = self.missDuration
        GameMode:ApplyDebuff(modifierTable)
    end
    if (self.spellDamageDuration > 0 and #enemies > 0) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_fallen_druid_flashbang_buff"
        modifierTable.duration = self.spellDamageDuration
        GameMode:ApplyBuff(modifierTable)
    end
    if (self.cdrFlat > 0) then
        for i = 0, caster:GetAbilityCount() - 1 do
            local ability = caster:GetAbilityByIndex(i)
            if (ability and ability ~= self) then
                local cooldownTable = {
                    target = caster,
                    ability = ability:GetAbilityName(),
                    reduction = self.cdrFlat,
                    isflat = true
                }
                GameMode:ReduceAbilityCooldown(cooldownTable)
            end
        end
    end
    EmitSoundOn("Hero_KeeperOfTheLight.BlindingLight", caster)
    if (self.shadowDuration > 0) then
        local summonTable = {
            caster = caster,
            unit = "npc_dota_fallen_druid_flashbang_shadow",
            position = casterPos,
            damage = 0,
            ability = self
        }
        local summon = Summons:SummonUnit(summonTable)
        Summons:SetSummonHaveNatureDamageType(summon, true)
        Summons:SetSummonAttackSpeed(summon, Units:GetAttackSpeed(caster))
        Summons:SetSummonCanProcOwnerAutoAttack(summon, true)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = summon
        modifierTable.caster = summon
        modifierTable.modifier_name = "modifier_fallen_druid_flashbang_shadow"
        modifierTable.duration = -1
        GameMode:ApplyBuff(modifierTable)
        local wearables = GetWearables(caster)
        AddWearables(summon, wearables)
    end
end

function fallen_druid_flashbang:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.radius = self:GetSpecialValueFor("radius")
    self.missChance = self:GetSpecialValueFor("miss_chance")
    self.missDuration = self:GetSpecialValueFor("miss_duration")
    self.shadowAAspeed = self:GetSpecialValueFor("shadow_aaspeed")
    self.shadowDuration = self:GetSpecialValueFor("shadow_duration")
    self.spellDamageAmplify = self:GetSpecialValueFor("spell_damage_amplify") / 100
    self.spellDamageDuration = self:GetSpecialValueFor("spell_damage_duration")
    self.cdrFlat = self:GetSpecialValueFor("cdr_flat")
end

-- fallen_druid_grasping_roots
modifier_fallen_druid_grasping_roots_dot = class({
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
    GetEffectName = function(self)
        return "particles/units/fallen_druid/grasping_roots/grasping_roots.vpcf"
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
})

function modifier_fallen_druid_grasping_roots_dot:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self:StartIntervalThink(self.ability.dotTick)
end

function modifier_fallen_druid_grasping_roots_dot:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local damageTable = {}
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.damage = self.ability.dotDamage * Units:GetHeroAgility(self.caster)
    damageTable.naturedmg = true
    damageTable.dot = true
    GameMode:DamageUnit(damageTable)
end

LinkedModifiers["modifier_fallen_druid_grasping_roots_dot"] = LUA_MODIFIER_MOTION_NONE

modifier_fallen_druid_grasping_roots_root = class({
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
        return "particles/units/heroes/hero_dark_willow/dark_willow_bramble.vpcf"
    end,
    CheckState = function(self)
        return {
            [MODIFIER_STATE_ROOTED] = true,
        }
    end
})

LinkedModifiers["modifier_fallen_druid_grasping_roots_root"] = LUA_MODIFIER_MOTION_NONE

modifier_fallen_druid_grasping_roots = class({
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
        return MODIFIER_ATTRIBUTE_PERMAMENT
    end,
})

function modifier_fallen_druid_grasping_roots:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_fallen_druid_grasping_roots:GetEarthDamageBonus()
    return self.ability.earthBonusDamage
end

function modifier_fallen_druid_grasping_roots:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_fallen_druid_grasping_roots")
    if (modifier and modifier.ability.earthElement > 0 and damageTable.naturedmg) then
        damageTable.earthdmg = true
        return damageTable
    end
end

function modifier_fallen_druid_grasping_roots:OnPostTakeDamage(damageTable)
    local ability = damageTable.attacker:FindAbilityByName("fallen_druid_grasping_roots")
    if (ability and not damageTable.ability and ability:GetLevel() > 0 and damageTable.physdmg and RollPercentage(ability.spreadChance) and damageTable.victim:HasModifier("modifier_fallen_druid_grasping_roots_dot")) then
        local enemies = FindUnitsInRadius(damageTable.attacker:GetTeamNumber(),
                damageTable.victim:GetAbsOrigin(),
                nil,
                ability.spreadRadius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            if (not enemy:HasModifier("modifier_fallen_druid_grasping_roots_dot")) then
                local cd = ability:GetCooldownTimeRemaining()
                ability:EndCooldown()
                damageTable.attacker:SetCursorCastTarget(enemy)
                ability:OnSpellStart()
                ability:StartCooldown(cd)
            end
        end
    end
end

LinkedModifiers["modifier_fallen_druid_grasping_roots"] = LUA_MODIFIER_MOTION_NONE

fallen_druid_grasping_roots = class({
    GetIntrinsicModifierName = function(self)
        return "modifier_fallen_druid_grasping_roots"
    end
})

function fallen_druid_grasping_roots:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if (self:GetAutoCastState()) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = target
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_fallen_druid_grasping_roots_root"
        modifierTable.duration = self.rootDuration
        GameMode:ApplyDebuff(modifierTable)
    end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = target
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_fallen_druid_grasping_roots_dot"
    modifierTable.duration = self.dotDuration
    GameMode:ApplyDebuff(modifierTable)
    EmitSoundOn("Hero_DarkWillow.Brambles.CastTarget", target)
end

function fallen_druid_grasping_roots:OnUpgrade()
    self.dotDamage = self:GetSpecialValueFor("dot_damage") / 100
    self.dotDuration = self:GetSpecialValueFor("dot_duration")
    self.dotTick = self:GetSpecialValueFor("dot_tick")
    self.rootDuration = self:GetSpecialValueFor("root_duration")
    self.spreadChance = self:GetSpecialValueFor("spread_chance")
    self.spreadRadius = self:GetSpecialValueFor("spread_radius")
    self.wispyBounce = self:GetSpecialValueFor("wispy_bounce")
    self.earthElement = self:GetSpecialValueFor("earth_element")
    self.earthBonusDamage = self:GetSpecialValueFor("earth_bonus") / 100
end
-- fallen_druid_crown_of_death
modifier_fallen_druid_crown_of_death_crit_dot = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
})

function modifier_fallen_druid_crown_of_death_crit_dot:OnCreated(kv)
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self.critDmg = kv.damage or 0
    self.damage = (Units:GetHeroAgility(self.caster) * self.ability.critsDotDamage * self.critDmg) / (self:GetDuration() / self.ability.critsDotTick)
    self:StartIntervalThink(self.ability.critsDotTick)
end

function modifier_fallen_druid_crown_of_death_crit_dot:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local damageTable = {}
    damageTable.damage = self.damage
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.naturedmg = true
    damageTable.dot = true
    GameMode:DamageUnit(damageTable)
end

function modifier_fallen_druid_crown_of_death_crit_dot:OnCriticalDamage(damageTable)
    local ability = damageTable.attacker:FindAbilityByName("fallen_druid_crown_of_death")
    if (ability and ability.critsDotDuration and ability.critsDotDuration > 0 and not ability.critsDotProcCooldown) then
        local modifierTable = {}
        modifierTable.ability = ability
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_fallen_druid_crown_of_death_crit_dot"
        modifierTable.duration = ability.critsDotDuration
        modifierTable.modifier_params = { damage = damageTable.damage }
        GameMode:ApplyDebuff(modifierTable)
        ability.critsDotProcCooldown = true
        Timers:CreateTimer(ability.critsDotCooldown, function()
            ability.critsDotProcCooldown = nil
        end)
    end
end

LinkedModifiers["modifier_fallen_druid_crown_of_death_crit_dot"] = LUA_MODIFIER_MOTION_NONE

modifier_fallen_druid_crown_of_death_dot = class({
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
        return "particles/units/fallen_druid/crown_of_death/crown_of_death_dot_v2.vpcf"
    end,
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_poison_venomancer.vpcf"
    end,
    StatusEffectPriority = function(self)
        return 15
    end,
})

function modifier_fallen_druid_crown_of_death_dot:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self:StartIntervalThink(self.ability.dotTick)
end

function modifier_fallen_druid_crown_of_death_dot:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local damage = Units:GetHeroAgility(self.caster) * self.ability.dotDamagePerStack * self:GetStackCount()
    local damageTable = {}
    damageTable.damage = damage
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.naturedmg = true
    damageTable.dot = true
    GameMode:DamageUnit(damageTable)
end

function modifier_fallen_druid_crown_of_death_dot:OnDestroy()
    if (not IsServer()) then
        return
    end
    if (self.ability.explosionDamagePerStack > 0) then
        local targetPosition = self.target:GetAbsOrigin()
        local pidx = ParticleManager:CreateParticle("particles/units/fallen_druid/crown_of_death/crown_of_death_explosion.vpcf", PATTACH_ABSORIGIN, self.target)
        --ParticleManager:SetParticleControlEnt(pidx, 0, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
        local damage = Units:GetHeroAgility(self.caster) * self.ability.explosionDamagePerStack * self:GetStackCount()
        local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
                targetPosition,
                nil,
                self.ability.explosionRadius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            local damageTable = {}
            damageTable.damage = damage
            damageTable.caster = self.caster
            damageTable.target = enemy
            damageTable.ability = self.ability
            damageTable.naturedmg = true
            damageTable.aoe = true
            GameMode:DamageUnit(damageTable)
        end
    end
end

LinkedModifiers["modifier_fallen_druid_crown_of_death_dot"] = LUA_MODIFIER_MOTION_NONE

modifier_fallen_druid_crown_of_death = class({
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
    GetEffectName = function(self)
        return "particles/units/fallen_druid/crown_of_death/crown_of_death_buff.vpcf"
    end,
    DeclareFunctions = function(self)
        return
        {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end
})

function modifier_fallen_druid_crown_of_death:OnAttackLanded(kv)
    if (not IsServer()) then
        return
    end
    local attacker = kv.attacker
    local target = kv.target
    if (attacker and target and not target:IsNull() and attacker == self.caster) then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.caster = attacker
        modifierTable.target = target
        modifierTable.modifier_name = "modifier_fallen_druid_crown_of_death_dot"
        modifierTable.duration = self.ability.dotDuration
        modifierTable.stacks = 1
        modifierTable.max_stacks = self.ability.dotStacksCap
        GameMode:ApplyStackingDebuff(modifierTable)
    end
end

function modifier_fallen_druid_crown_of_death:OnPostTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_fallen_druid_crown_of_death")
    if (modifier) then
        if (damageTable.ability and damageTable.fromsummon and damageTable.ability:GetAbilityName() == "fallen_druid_wisp_companion" and modifier.ability.wispyProcRadius > 0) then
            local enemies = FindUnitsInRadius(damageTable.attacker:GetTeamNumber(),
                    damageTable.victim:GetAbsOrigin(),
                    nil,
                    modifier.ability.wispyProcRadius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            for _, enemy in pairs(enemies) do
                if (enemy ~= damageTable.victim) then
                    local modifierTable = {}
                    modifierTable.ability = modifier.ability
                    modifierTable.caster = damageTable.attacker
                    modifierTable.target = enemy
                    modifierTable.modifier_name = "modifier_fallen_druid_crown_of_death_dot"
                    modifierTable.duration = modifier.ability.dotDuration
                    modifierTable.stacks = 1
                    modifierTable.max_stacks = modifier.ability.dotStacksCap
                    GameMode:ApplyStackingDebuff(modifierTable)
                end
            end
        end
    end
end

function modifier_fallen_druid_crown_of_death:OnCreated()
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
end

LinkedModifiers["modifier_fallen_druid_crown_of_death"] = LUA_MODIFIER_MOTION_NONE

fallen_druid_crown_of_death = class({})

function fallen_druid_crown_of_death:OnSpellStart(durationMultiplier)
    if (not IsServer()) then
        return
    end
    if (not durationMultiplier or type(durationMultiplier) ~= "number") then
        durationMultiplier = 1
    end
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_fallen_druid_crown_of_death"
    modifierTable.duration = self.duration * durationMultiplier
    GameMode:ApplyBuff(modifierTable)
    caster:EmitSound("Hero_DarkWillow.Ley.Cast")
end

function fallen_druid_crown_of_death:OnUpgrade()
    self.dotDamagePerStack = self:GetSpecialValueFor("dot_damage_per_stack") / 100
    self.dotDuration = self:GetSpecialValueFor("dot_duration")
    self.dotTick = self:GetSpecialValueFor("dot_tick")
    self.duration = self:GetSpecialValueFor("duration")
    self.explosionDamagePerStack = self:GetSpecialValueFor("explosion_damage_per_stack") / 100
    self.explosionRadius = self:GetSpecialValueFor("explosion_radius")
    self.wispyProcRadius = self:GetSpecialValueFor("wispy_proc_radius")
    self.critsDotDamage = self:GetSpecialValueFor("crits_dot_damage") / 100
    self.critsDotTick = self:GetSpecialValueFor("crits_dot_tick")
    self.critsDotDuration = self:GetSpecialValueFor("crits_dot_duration")
    self.dotStacksCap = self:GetSpecialValueFor("dot_stacks_cap")
    self.critsDotCooldown = self:GetSpecialValueFor("crits_dot_cd")
end
-- fallen_druid_whispering_doom
modifier_fallen_druid_whispering_doom_buff = class({
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

function modifier_fallen_druid_whispering_doom_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end
function modifier_fallen_druid_whispering_doom_buff:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_fallen_druid_whispering_doom_buff")
    if (modifier and damageTable.ability) then
        if (damageTable.ability:GetAbilityName() == "fallen_druid_wisp_companion" and modifier.ability.wispyBonus and damageTable.fromsummon) then
            damageTable.damage = damageTable.damage * (1 + modifier.ability.wispyBonus)
        end
        if (damageTable.ability:GetAbilityName() == "fallen_druid_shadow_vortex" and modifier.ability.shadowVortexBonus) then
            damageTable.damage = damageTable.damage * (1 + modifier.ability.shadowVortexBonus)
        end
        return damageTable
    end
end

LinkedModifiers["modifier_fallen_druid_whispering_doom_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_fallen_druid_whispering_doom_dot = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end
})

function modifier_fallen_druid_whispering_doom_dot:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self.particle = ParticleManager:CreateParticle("particles/units/fallen_druid/whispering_doom/whispering_doom_dot.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target)
    ParticleManager:SetParticleControl(self.particle, 5, Vector(self.target:GetPaddedCollisionRadius() + 50, 0, 0))
    self:StartIntervalThink(self.ability.dotTick)
end

function modifier_fallen_druid_whispering_doom_dot:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local damageTable = {}
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.damage = self.ability.dotDamage * Units:GetHeroAgility(self.caster)
    damageTable.naturedmg = true
    damageTable.dot = true
    GameMode:DamageUnit(damageTable)
    local pidx = ParticleManager:CreateParticle("particles/units/fallen_druid/wisp_companion/wispy_impact.vpcf", PATTACH_ABSORIGIN, self.target)
    ParticleManager:SetParticleControlEnt(pidx, 3, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    self.target:EmitSound("Hero_DarkWillow.WillOWisp.Damage")
end

function modifier_fallen_druid_whispering_doom_dot:GetArmorPercentBonus()
    return self.ability.armorReduction
end

function modifier_fallen_druid_whispering_doom_dot:GetNatureProtectionBonus()
    return self.ability.natureReduction
end

function modifier_fallen_druid_whispering_doom_dot:OnDestroy()
    if (not IsServer()) then
        return
    end
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

LinkedModifiers["modifier_fallen_druid_whispering_doom_dot"] = LUA_MODIFIER_MOTION_NONE

fallen_druid_whispering_doom = class({})

function fallen_druid_whispering_doom:OnProjectileHit(enemy, vLocation)
    if (not IsServer()) then
        return
    end
    if (not TableContains(self.damagedEnemies, enemy)) then
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = self.target
        damageTable.ability = self.ability
        damageTable.damage = self.damage * Units:GetHeroAgility(self.caster)
        damageTable.naturedmg = true
        damageTable.aoe = true
        GameMode:DamageUnit(damageTable)
        if (self.dotDuration > 0) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_fallen_druid_whispering_doom_dot"
            modifierTable.duration = self.dotDuration
            GameMode:ApplyDebuff(modifierTable)
        end
        if (self:GetAutoCastState()) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = enemy
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_stunned"
            modifierTable.duration = self.stunDuration
            GameMode:ApplyDebuff(modifierTable)
        end
        table.insert(self.damagedEnemies, enemy)
    end
    return false
end

function fallen_druid_whispering_doom:OnSpellStart()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    self.casterTeam = self.caster:GetTeamNumber()
    local casterPosition = self.caster:GetAbsOrigin()
    local velocity = self.caster:GetForwardVector() * 1500
    local deathTime = GameRules:GetGameTime() + 10.0
    self.damagedEnemies = {}
    for _ = 1, 10 do
        local projectile = {
            Ability = self,
            EffectName = "particles/units/fallen_druid/whispering_doom/whispering_doom_projectile.vpcf",
            vSpawnOrigin = casterPosition + RandomVector(RandomInt(0, 200)),
            fDistance = 2000,
            fStartRadius = 100,
            fEndRadius = 100,
            Source = self.caster,
            bHasFrontalCone = false,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = deathTime,
            bDeleteOnHit = false,
            vVelocity = velocity,
            bProvidesVision = true,
            iVisionRadius = 1000,
            iVisionTeamNumber = self.casterTeam
        }
        projectile = ProjectileManager:CreateLinearProjectile(projectile)
    end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = self.caster
    modifierTable.caster = self.caster
    modifierTable.modifier_name = "modifier_fallen_druid_whispering_doom_buff"
    modifierTable.duration = self.bonusDuration
    GameMode:ApplyBuff(modifierTable)
    self.caster:EmitSound("Hero_DarkWillow.Fear.Cast")
end

function fallen_druid_whispering_doom:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.stunDuration = self:GetSpecialValueFor("stun")
    self.natureReduction = self:GetSpecialValueFor("nature_reduction") / 100
    self.armorReduction = self:GetSpecialValueFor("armor_reduction") / 100
    self.dotDamage = self:GetSpecialValueFor("dot_damage") / 100
    self.dotTick = self:GetSpecialValueFor("dot_tick")
    self.dotDuration = self:GetSpecialValueFor("dot_duration")
    self.shadowVortexBonus = self:GetSpecialValueFor("shadow_vortex_bonus") / 100
    self.wispyBonus = self:GetSpecialValueFor("wispy_bonus") / 100
    self.bonusDuration = self:GetSpecialValueFor("bonus_duration")
end

-- fallen_druid_shadow_vortex
modifier_fallen_druid_shadow_vortex_stacks = class({
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
    end
})

function modifier_fallen_druid_shadow_vortex_stacks:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
end

function modifier_fallen_druid_shadow_vortex_stacks:OnStackCountChanged()
    if (not IsServer()) then
        return
    end
    if (self:GetStackCount() >= self.ability.stackToProc and not self.ability.bonusDmgCurrentCooldown) then
        self:Destroy()
    end
end

function modifier_fallen_druid_shadow_vortex_stacks:OnDestroy()
    if (not IsServer()) then
        return
    end
    if (self:GetStackCount() >= self.ability.stackToProc) then
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = self.target
        damageTable.ability = self.ability
        damageTable.damage = self.ability.damage * Units:GetHeroAgility(self.caster)
        damageTable.naturedmg = true
        damageTable.single = true
        GameMode:DamageUnit(damageTable)
        if (self.ability:GetAutoCastState()) then
            local modifierTable = {}
            modifierTable.ability = self.ability
            modifierTable.target = self.target
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_silence"
            modifierTable.duration = self.ability.bonusSilenceDuration
            GameMode:ApplyDebuff(modifierTable)
        end
        self.ability.bonusDmgCurrentCooldown = true
        local ability = self.ability
        Timers:CreateTimer(ability.bonusDmgCooldown, function()
            ability.bonusDmgCurrentCooldown = nil
        end)
    end
end

LinkedModifiers["modifier_fallen_druid_shadow_vortex_stacks"] = LUA_MODIFIER_MOTION_NONE

modifier_fallen_druid_shadow_vortex_thinker_aura_buff = class({
    IsDebuff = function(self)
        return true
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
    end
})

function modifier_fallen_druid_shadow_vortex_thinker_aura_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
end

function modifier_fallen_druid_shadow_vortex_thinker_aura_buff:OnPostTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_fallen_druid_shadow_vortex_thinker_aura_buff")
    if (not modifier or not modifier.ability or damageTable.attacker ~= modifier.ability.caster) then
        return damageTable
    end
    local modifierTable = {}
    modifierTable.ability = modifier.ability
    modifierTable.caster = damageTable.attacker
    modifierTable.target = damageTable.victim
    modifierTable.modifier_name = "modifier_fallen_druid_shadow_vortex_stacks"
    modifierTable.duration = 5
    modifierTable.stacks = 1
    modifierTable.max_stacks = modifier.ability.stackToProc
    GameMode:ApplyStackingDebuff(modifierTable)
end

LinkedModifiers["modifier_fallen_druid_shadow_vortex_thinker_aura_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_fallen_druid_shadow_vortex_thinker = class({
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
    IsAura = function(self)
        return true
    end,
    GetAuraRadius = function(self)
        return self.ability.radius
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_fallen_druid_shadow_vortex_thinker_aura_buff"
    end,
})

function modifier_fallen_druid_shadow_vortex_thinker:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.casterTeam = self.caster:GetTeamNumber()
    self.parent = self:GetParent()
    self.position = self.parent:GetAbsOrigin()
    self.pidx = ParticleManager:CreateParticle("particles/units/fallen_druid/shadow_vortex/shadow_vortex.vpcf", PATTACH_ABSORIGIN, self.caster)
    --self.wispy = self.caster:FindAbilityByName("fallen_druid_wisp_companion")
    self.timer = 0
    self.internalTick = 0.1
    ParticleManager:SetParticleControl(self.pidx, 0, self.position)
    ParticleManager:SetParticleControl(self.pidx, 20, Vector(self.ability.radius, 0, 0))
    self:StartIntervalThink(self.internalTick)
end

function modifier_fallen_druid_shadow_vortex_thinker:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    if (self.timer >= self.ability.tick) then
        if(not self.ability.wispyAbility) then
            local casterMana = self.caster:GetMana() - (self.caster:GetMaxMana() * self.ability.manacostPerTick)
            if (casterMana < 0) then
                self:Destroy()
                return
            else
                self.caster:SetMana(casterMana)
            end
        end
        local enemies = FindUnitsInRadius(self.casterTeam,
                self.position,
                nil,
                self.ability.radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            local damageTable = {}
            damageTable.caster = self.caster
            damageTable.target = enemy
            damageTable.ability = self.ability
            damageTable.damage = self.ability.bonusDmg * Units:GetHeroAgility(self.caster)
            damageTable.naturedmg = true
            damageTable.aoe = true
            GameMode:DamageUnit(damageTable)
            local pidx = ParticleManager:CreateParticle("particles/units/fallen_druid/shadow_vortex/shadow_vortex_impact.vpcf", PATTACH_ABSORIGIN, enemy)
            Timers:CreateTimer(1.0, function()
                ParticleManager:DestroyParticle(pidx, false)
                ParticleManager:ReleaseParticleIndex(pidx)
            end)
        end
        self.timer = 0
    else
        self.timer = self.timer + self.internalTick
    end
end

function modifier_fallen_druid_shadow_vortex_thinker:OnDestroy()
    if (not IsServer()) then
        return
    end
    local ability = self.caster:FindAbilityByName("fallen_druid_flashbang")
    if (self.ability.flashbangCast > 0 and ability and ability:GetLevel() > 0) then
        local cd = ability:GetCooldownTimeRemaining()
        ability:EndCooldown()
        self.caster:SetCursorCastTarget(self.caster)
        ability:OnSpellStart(self.position)
        ability:StartCooldown(cd)
    end
    if(self.ability.wispyAbility) then
        self.ability.wispyAbility.wispy.modifier:ChangeState(WISPY_STATE_TRAVEL_BACK)
    end
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
    UTIL_Remove(self.parent)
end

LinkedModifiers["modifier_fallen_druid_shadow_vortex_thinker"] = LUA_MODIFIER_MOTION_NONE

fallen_druid_shadow_vortex = class({
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("radius")
    end,
    GetBehavior = function(self)
        if (self:GetSpecialValueFor("bonus_silence_duration") > 0) then
            return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_AUTOCAST
        else
            return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
        end
    end,
})

function fallen_druid_shadow_vortex:CreateShadowVortex(castPosition)
    if (not IsServer()) then
        return
    end
    CreateModifierThinker(
            self.caster,
            self,
            "modifier_fallen_druid_shadow_vortex_thinker",
            {
                duration = self.duration
            },
            castPosition,
            self.caster:GetTeamNumber(),
            false
    )
end

function fallen_druid_shadow_vortex:OnSpellStart()
    if (not IsServer()) then
        return
    end
    self.wispyAbility = nil
    self.caster = self:GetCaster()
    local cursorPosition = self:GetCursorPosition()
    local wispyAbility = self.caster:FindAbilityByName("fallen_druid_wisp_companion")
    if (wispyAbility and wispyAbility:GetLevel() > 0) then
        wispyAbility:OrderWispyCastShadowVortex(wispyAbility.wispy, cursorPosition, self)
        self.wispyAbility = wispyAbility
    else
        self:CreateShadowVortex(cursorPosition)
    end
    local ability = self.caster:FindAbilityByName("fallen_druid_crown_of_death")
    if (self.crownOfDeathCastMultiplier > 0 and ability and ability:GetLevel() > 0) then
        local cd = ability:GetCooldownTimeRemaining()
        ability:EndCooldown()
        self.caster:SetCursorCastTarget(self.caster)
        ability:OnSpellStart(self.crownOfDeathCastMultiplier)
        ability:StartCooldown(cd)
    end
    self.caster:EmitSound("Hero_DarkWillow.Fear.Cast")
end

function fallen_druid_shadow_vortex:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.tick = self:GetSpecialValueFor("tick")
    self.radius = self:GetSpecialValueFor("radius")
    self.duration = self:GetSpecialValueFor("duration")
    self.crownOfDeathCastMultiplier = self:GetSpecialValueFor("crown_of_death_duration_multiplier")
    self.flashbangCast = self:GetSpecialValueFor("flashbang_cast")
    self.manacostPerTick = self:GetSpecialValueFor("manacost_per_tick") / 100
    self.stackToProc = self:GetSpecialValueFor("stacks_to_proc_bonus_dmg")
    self.bonusDmg = self:GetSpecialValueFor("bonus_dmg") / 100
    self.bonusSilenceDuration = self:GetSpecialValueFor("bonus_silence_duration")
    self.bonusDmgCooldown = self:GetSpecialValueFor("bonus_dmg_cd")
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_fallen_druid", MotionController)
end

if (IsServer() and not GameMode.FALLEN_DRUID_INIT) then
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(fallen_druid_wisp_companion, 'OnPostTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_fallen_druid_grasping_roots, 'OnTakeDamage'), true)
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_fallen_druid_grasping_roots, 'OnPostTakeDamage'))
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_fallen_druid_crown_of_death, 'OnPostTakeDamage'))
    GameMode:RegisterCritDamageEventHandler(Dynamic_Wrap(modifier_fallen_druid_crown_of_death_crit_dot, 'OnCriticalDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_fallen_druid_whispering_doom_buff, 'OnTakeDamage'))
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_fallen_druid_shadow_vortex_thinker_aura_buff, 'OnPostTakeDamage'))
    GameMode.FALLEN_DRUID_INIT = true
end
