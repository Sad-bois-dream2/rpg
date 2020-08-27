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
    if (state == WISPY_STATE_TRAVEL_BACK or state == WISPY_STATE_TRAVEL_TO_TARGET or state == WISPY_STATE_ATTACHED_TO_ALLY) then
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
    if (not ability or not damageTable.fromsummon) then
        return damageTable
    end
    if (not (ability.wispHealing > 0) or ability.wispHealingCurrentInCD) then
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
    wispy.modifier:ChangeState(WISPY_STATE_TRAVEL_BACK)
end

function fallen_druid_wisp_companion:OrderWispyAttackTarget(wispy, target)
    if (not wispy or wispy:IsNull()) then
        return
    end
    if (wispy.modifier.state == WISPY_STATE_TRAVEL_TO_TARGET or wispy.modifier.state == WISPY_STATE_TRAVEL_BACK) then
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

function fallen_druid_flashbang:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local casterPos = caster:GetAbsOrigin()
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
fallen_druid_crown_of_death = class({})

function fallen_druid_crown_of_death:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
end

function fallen_druid_crown_of_death:OnUpgrade()
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_fallen_druid", MotionController)
end

if (IsServer() and not GameMode.FALLEN_DRUID_INIT) then
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(fallen_druid_wisp_companion, 'OnPostTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_fallen_druid_grasping_roots, 'OnTakeDamage'), true)
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_fallen_druid_grasping_roots, 'OnPostTakeDamage'))
    GameMode.FALLEN_DRUID_INIT = true
end