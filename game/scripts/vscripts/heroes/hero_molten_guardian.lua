local LinkedModifiers = {}

-- molten_guardian_scorching_clash modifiers
modifier_molten_guardian_scorching_clash_taunt = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetTexture = function(self)
        return molten_guardian_shields_up:GetAbilityTextureName()
    end,
})

function modifier_molten_guardian_scorching_clash_taunt:OnCreated(kv)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

LinkedModifiers["modifier_molten_guardian_scorching_clash_taunt"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_scorching_clash_dot = class({
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
        return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
    end,
    GetTexture = function(self)
        return molten_guardian_scorching_clash:GetAbilityTextureName()
    end,
})

function modifier_molten_guardian_scorching_clash_dot:OnCreated(kv)
    if IsServer() then
        self.ability = self:GetAbility()
        self.target = self:GetParent()
        self.caster = self:GetCaster()
        self:StartIntervalThink(self.ability.dotTick)
    end
end

function modifier_molten_guardian_scorching_clash_dot:OnIntervalThink()
    if IsServer() then
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = self.target
        damageTable.ability = self.ability
        damageTable.damage = self.caster:GetMaxHealth() * self.ability.dotDamage
        damageTable.firedmg = true
        GameMode:DamageUnit(damageTable)
    end
end

LinkedModifiers["modifier_molten_guardian_scorching_clash_dot"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_scorching_clash_motion = class({
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
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetMotionControllerPriority = function(self)
        return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_phoenix/phoenix_icarus_dive.vpcf"
    end,
    CheckState = function(self)
        return {
            [MODIFIER_STATE_STUNNED] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true
        }
    end
})

function modifier_molten_guardian_scorching_clash_motion:OnCreated(kv)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.startLocation = self.caster:GetAbsOrigin()
    self.dashRange = math.min(self.ability.dashRange, DistanceBetweenVectors(self.startLocation, self.ability:GetCursorPosition()))
    self.damagedEnemies = {}
    if (self:ApplyHorizontalMotionController() == false) then
        self:Destroy()
    end
end

function modifier_molten_guardian_scorching_clash_motion:OnDestroy()
    if not IsServer() then
        return
    end
    self.caster:RemoveHorizontalMotionController(self)
    self.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
    ParticleManager:DestroyParticle(self.ability.particle, false)
    ParticleManager:ReleaseParticleIndex(self.ability.particle)
    if (self.ability.stunRadius > 0) then
        local pidx = ParticleManager:CreateParticle("particles/units/molten_guardian/scorching_clash/scorching_clash_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
        ParticleManager:SetParticleControl(pidx, 3, self.caster:GetAbsOrigin())
        Timers:CreateTimer(2.0, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
        local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                self.caster:GetAbsOrigin(),
                nil,
                self.ability.stunRadius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        for _, enemy in pairs(enemies) do
            local modifierTable = {}
            modifierTable.ability = self.ability
            modifierTable.target = enemy
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_stunned"
            modifierTable.duration = self.ability.stunDuration
            GameMode:ApplyDebuff(modifierTable)
        end
    end
end

function modifier_molten_guardian_scorching_clash_motion:OnHorizontalMotionInterrupted()
    if IsServer() then
        self:Destroy()
    end
end

function modifier_molten_guardian_scorching_clash_motion:UpdateHorizontalMotion(me, dt)
    if (IsServer()) then
        local currentLocation = self.caster:GetAbsOrigin()
        local expectedLocation = currentLocation + self.caster:GetForwardVector() * self.ability.dashSpeed * dt
        local isTraversable = GridNav:IsTraversable(expectedLocation)
        local isBlocked = GridNav:IsBlocked(expectedLocation)
        local isTreeNearby = GridNav:IsNearbyTree(expectedLocation, self.caster:GetHullRadius(), true)
        local traveled_distance = DistanceBetweenVectors(currentLocation, self.startLocation)
        if (isTraversable and not isBlocked and not isTreeNearby and traveled_distance < self.dashRange) then
            self.caster:SetAbsOrigin(expectedLocation)
            local particleLocation = expectedLocation + Vector(0, 0, 100)
            ParticleManager:SetParticleControl(self.ability.particle, 0, particleLocation)
            ParticleManager:SetParticleControl(self.ability.particle, 1, particleLocation)
            local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                    expectedLocation,
                    nil,
                    self.ability.dotSearchRadius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            local damage = self.ability.damage * self.caster:GetMaxHealth()
            for _, enemy in pairs(enemies) do
                if (not TableContains(self.damagedEnemies, enemy)) then
                    local damageTable = {}
                    damageTable.caster = self.caster
                    damageTable.target = enemy
                    damageTable.ability = self.ability
                    damageTable.damage = damage
                    damageTable.firedmg = true
                    GameMode:DamageUnit(damageTable)
                    if (self.ability.dotDuration > 0) then
                        local modifierTable = {}
                        modifierTable.ability = self.ability
                        modifierTable.target = enemy
                        modifierTable.caster = self.caster
                        modifierTable.modifier_name = "modifier_molten_guardian_scorching_clash_dot"
                        modifierTable.duration = self.ability.dotDuration
                        GameMode:ApplyDebuff(modifierTable)
                    end
                    table.insert(self.damagedEnemies, enemy)
                end
            end
        else
            self:Destroy()
        end
    end
end

LinkedModifiers["modifier_molten_guardian_scorching_clash_motion"] = LUA_MODIFIER_MOTION_HORIZONTAL

-- molten_guardian_scorching_clash
molten_guardian_scorching_clash = class({
    GetAbilityTextureName = function(self)
        return "molten_guardian_scorching_clash"
    end
})

function molten_guardian_scorching_clash:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.dashRange = self:GetSpecialValueFor("dash_range")
    self.dashSpeed = self:GetSpecialValueFor("dash_speed")
    self.dotDamage = self:GetSpecialValueFor("dot_damage") / 100
    self.dotTick = self:GetSpecialValueFor("dot_tick")
    self.dotDuration = self:GetSpecialValueFor("dot_duration")
    self.stunDuration = self:GetSpecialValueFor("stun_duration")
    self.stunRadius = self:GetSpecialValueFor("stun_radius")
    self.shieldsUpTauntDuration = self:GetSpecialValueFor("shields_up_taunt_duration")
    self.dotSearchRadius = self:GetSpecialValueFor("dot_search_radius")
end

function molten_guardian_scorching_clash:OnSpellStart(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        local location = caster:GetAbsOrigin()
        EmitSoundOn("Hero_Mars.Spear.Cast", caster)
        local vector = (self:GetCursorPosition() - location):Normalized()
        caster:SetForwardVector(vector)
        caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
        self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_remnant_dash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(self.particle, 0, location + Vector(0, 0, 100))
        ParticleManager:SetParticleControl(self.particle, 1, location + Vector(0, 0, 100))
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_molten_guardian_scorching_clash_motion"
        modifierTable.duration = -1
        GameMode:ApplyBuff(modifierTable)
        if (self.shieldsUpTauntDuration > 0) then
            local modifierTable = {}
            modifierTable.ability = self
            modifierTable.target = caster
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_molten_guardian_scorching_clash_taunt"
            modifierTable.duration = -1
            GameMode:ApplyBuff(modifierTable)
        end
    end
end

-- molten_guardian_lava_skin modifiers
modifier_molten_guardian_lava_skin_melt_stacks = class({
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

function modifier_molten_guardian_lava_skin_melt_stacks:OnCreated(kv)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_molten_guardian_lava_skin_melt_stacks:GetHealthPercentBonus()
    return self.ability.meltStacksMaxhp * self:GetStackCount()
end

function modifier_molten_guardian_lava_skin_melt_stacks:GetArmorPercentBonus()
    return self.ability.meltStacksArmorReduction * self:GetStackCount()
end

LinkedModifiers["modifier_molten_guardian_lava_skin_melt_stacks"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_lava_skin = class({
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

function modifier_molten_guardian_lava_skin:OnCreated(kv)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_molten_guardian_lava_skin:GetHealthRegenerationPercentBonus()
    return self.ability.hpRegBonus
end

function modifier_molten_guardian_lava_skin:GetFireProtectionBonus()
    return self.ability.fireResBonus
end

LinkedModifiers["modifier_molten_guardian_lava_skin"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_lava_skin_armor_stacks = class({
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

function modifier_molten_guardian_lava_skin_armor_stacks:OnCreated(kv)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_molten_guardian_lava_skin_armor_stacks:GetArmorPercentBonus()
    return self.ability.armorStacksReduction * self:GetStackCount()
end

LinkedModifiers["modifier_molten_guardian_lava_skin_armor_stacks"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_lava_skin_toggle = class({
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
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetEffectName = function(self)
        return "particles/units/molten_guardian/lava_skin/lava_skin_base.vpcf"
    end
})

function modifier_molten_guardian_lava_skin_toggle:OnCreated(kv)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.casterTeam = self.caster:GetTeamNumber()
    self:StartIntervalThink(self.ability.tick)
end

function modifier_molten_guardian_lava_skin_toggle:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_molten_guardian_lava_skin_toggle")
    if (modifier ~= nil and damageTable.physdmg) then
        damageTable.damage = damageTable.damage * modifier.ability.physDmgReduce
        return damageTable
    end
end

function modifier_molten_guardian_lava_skin_toggle:OnIntervalThink()
    if not IsServer() then
        return
    end
    local pidx = ParticleManager:CreateParticle("particles/units/molten_guardian/lava_skin/lava_skin_proc.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    self.caster:EmitSound("Hero_EmberSpirit.FlameGuard.Loop")
    local damage = self.caster:GetMaxHealth() * self.ability.damage
    local enemies = FindUnitsInRadius(self.casterTeam,
            self.caster:GetAbsOrigin(),
            nil,
            self.ability.damageRadius,
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
        damageTable.damage = damage
        damageTable.firedmg = true
        GameMode:DamageUnit(damageTable)
        if (self.ability.armorStacksDuration > 0) then
            local modifierTable = {}
            modifierTable.ability = self.ability
            modifierTable.caster = self.caster
            modifierTable.target = enemy
            modifierTable.modifier_name = "modifier_molten_guardian_lava_skin_armor_stacks"
            modifierTable.duration = self.ability.armorStacksDuration
            modifierTable.stacks = 1
            modifierTable.max_stacks = self.ability.armorStacksCap
            GameMode:ApplyStackingDebuff(modifierTable)
        end
        local pidx = ParticleManager:CreateParticle("particles/units/molten_guardian/lava_skin/lava_skin_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
    end
    if (self.ability:GetAutoCastState()) then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.caster = self.caster
        modifierTable.target = self.caster
        modifierTable.modifier_name = "modifier_molten_guardian_lava_skin_melt_stacks"
        modifierTable.duration = self.ability.meltStacksDuration
        modifierTable.stacks = 1
        modifierTable.max_stacks = self.ability.meltStacksCap
        PrintTable(modifierTable)
        GameMode:ApplyStackingBuff(modifierTable)
    end
end

LinkedModifiers["modifier_molten_guardian_lava_skin_toggle"] = LUA_MODIFIER_MOTION_NONE

-- molten_guardian_lava_skin
molten_guardian_lava_skin = class({
    GetCastRange = function(self)
        return self:GetSpecialValueFor("damage_radius")
    end,
    GetBehavior = function(self)
        if (self:GetSpecialValueFor("melt_stacks_cap") > 0) then
            return DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_AUTOCAST
        else
            return DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
        end
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_molten_guardian_lava_skin"
    end
})

function molten_guardian_lava_skin:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.physDmgReduce = self:GetSpecialValueFor("phys_dmg_reduce") / 100
    self.damageRadius = self:GetSpecialValueFor("damage_radius")
    self.tick = self:GetSpecialValueFor("tick")
    self.armorStacksReduction = self:GetSpecialValueFor("armor_stacks_reduction") / 100
    self.armorStacksCap = self:GetSpecialValueFor("armor_stacks_cap")
    self.armorStacksDuration = self:GetSpecialValueFor("armor_stacks_duration")
    self.fireResBonus = self:GetSpecialValueFor("fire_res_bonus") / 100
    self.hpRegBonus = self:GetSpecialValueFor("hpreg_bonus") / 100
    self.meltStacksArmorReduction = self:GetSpecialValueFor("melt_stacks_armor_reduction")
    self.meltStacksMaxhp = self:GetSpecialValueFor("melt_stacks_maxhp") / 100
    self.meltStacksCap = self:GetSpecialValueFor("melt_stacks_cap")
    self.meltStacksDuration = self:GetSpecialValueFor("melt_stacks_duration")
end

function molten_guardian_lava_skin:OnToggle(unit, special_cast)
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    caster.molten_guardian_lava_skin = caster.molten_guardian_lava_skin or {}
    if (self:GetToggleState()) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_molten_guardian_lava_skin_toggle"
        modifierTable.duration = -1
        caster.molten_guardian_lava_skin.modifier = GameMode:ApplyBuff(modifierTable)
        self:EndCooldown()
        self:StartCooldown(self:GetCooldown(self:GetLevel()))
    else
        if (caster.molten_guardian_lava_skin.modifier ~= nil) then
            caster.molten_guardian_lava_skin.modifier:Destroy()
            caster:StopSound("Hero_EmberSpirit.FlameGuard.Loop")
        end
        local rank4Modifier = caster:FindModifierByName("modifier_molten_guardian_lava_skin_melt_stacks")
        if (rank4Modifier) then
            rank4Modifier:Destroy()
        end
    end
end

-- molten_guardian_volcanic_blow modifiers
modifier_molten_guardian_volcanic_blow_buff = class({
    IsDebuff = function(self)
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

function modifier_molten_guardian_volcanic_blow_buff:OnCreated()
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_molten_guardian_volcanic_blow_buff:GetHealthPercentBonus()
    return self.ability.bonusMaxHpPerBlock * self:GetStackCount()
end

LinkedModifiers["modifier_molten_guardian_volcanic_blow_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_volcanic_blow_taunt = class({
    IsDebuff = function(self)
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
    IsTaunt = function(self)
        return true
    end
})

function modifier_molten_guardian_volcanic_blow_taunt:OnCreated(kv)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

LinkedModifiers["modifier_molten_guardian_volcanic_blow_taunt"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_volcanic_blow_block = class({
    IsDebuff = function(self)
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

function modifier_molten_guardian_volcanic_blow_block:OnCreated(kv)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_molten_guardian_volcanic_blow_block:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_molten_guardian_volcanic_blow_block")
    if (modifier and damageTable.physdmg and modifier.ability and RollPercentage(modifier.ability.blockChance * modifier.ability.blockMultiplier)) then
        if (modifier.ability.bonusMaxHpPerBlock > 0) then
            local modifierTable = {}
            modifierTable.ability = modifier.ability
            modifierTable.caster = damageTable.victim
            modifierTable.target = damageTable.victim
            modifierTable.modifier_name = "modifier_molten_guardian_volcanic_blow_buff"
            modifierTable.duration = modifier.ability.bonusMaxHpDuration
            modifierTable.stacks = 1
            modifierTable.max_stacks = 99999
            GameMode:ApplyStackingBuff(modifierTable)
        end
        damageTable.damage = 0
        return damageTable
    end
end

LinkedModifiers["modifier_molten_guardian_volcanic_blow_block"] = LUA_MODIFIER_MOTION_NONE

-- molten_guardian_volcanic_blow
molten_guardian_volcanic_blow = class({
    GetAbilityTextureName = function(self)
        return "molten_guardian_volcanic_blow"
    end,
})

function molten_guardian_volcanic_blow:OnSpellStart(unit, special_cast)
    if not IsServer() then
        return
    end
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_molten_guardian_volcanic_blow_block"
    modifierTable.duration = self.blockDuration
    GameMode:ApplyBuff(modifierTable)
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_molten_guardian_volcanic_blow_taunt"
    modifierTable.duration = self.tauntDuration
    GameMode:ApplyBuff(modifierTable)
    self:ApplySpellEffectToTarget(caster, target)
    local pidx = ParticleManager:CreateParticle("particles/units/molten_guardian/volcanic_blow/volcanic_blow_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    if (self.searchWidthPastTarget > 0) then
        local targetPosition = target:GetAbsOrigin()
        local enemies = FindUnitsInLine(DOTA_TEAM_GOODGUYS,
                targetPosition,
                targetPosition + target:GetForwardVector() * -self.searchRangePastTarget,
                caster,
                self.searchWidthPastTarget,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE)
        for _, enemy in pairs(enemies) do
            self:ApplySpellEffectToTarget(caster, enemy)
        end
        ParticleManager:SetParticleControl(pidx, 1, Vector(self.searchWidthPastTarget, self.searchWidthPastTarget, self.searchWidthPastTarget))
    else
        ParticleManager:SetParticleControl(pidx, 1, Vector(200, 200, 200))
    end
    Timers:CreateTimer(3.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    EmitSoundOn("Hero_Mars.Shield.Cast", caster)
end

function molten_guardian_volcanic_blow:ApplySpellEffectToTarget(caster, target)
    local damageTable = {}
    damageTable.caster = caster
    damageTable.target = target
    damageTable.ability = self
    damageTable.damage = caster:GetMaxHealth() * self.damage
    damageTable.firedmg = true
    GameMode:DamageUnit(damageTable)
    if (self:GetAutoCastState()) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = target
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_stunned"
        modifierTable.duration = self.stunDuration
        GameMode:ApplyDebuff(modifierTable)
    end
end

function molten_guardian_volcanic_blow:OnUpgrade()
    self.stunDuration = self:GetSpecialValueFor("stun_duration")
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.blockChance = self:GetSpecialValueFor("block_chance")
    self.blockDuration = self:GetSpecialValueFor("block_duration")
    self.blockMultiplier = self:GetSpecialValueFor("block_multiplier")
    self.tauntDuration = self:GetSpecialValueFor("taunt_duration")
    self.bonusMaxHpPerBlock = self:GetSpecialValueFor("bonus_maxhp_per_block") / 100
    self.searchWidthPastTarget = self:GetSpecialValueFor("search_width_past_target")
    self.searchRangePastTarget = self:GetSpecialValueFor("search_range_past_target")
    self.bonusMaxHpDuration = self:GetSpecialValueFor("bonus_maxhp_duration")
end

--molten_guardian_molten_fortress
modifier_molten_guardian_molten_fortress_pull = class({
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
    CheckState = function(self)
        return {
            [MODIFIER_STATE_STUNNED] = true
        }
    end
})

function modifier_molten_guardian_molten_fortress_pull:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.target = self:GetParent()
    self:StartIntervalThink(FrameTime())
end

function modifier_molten_guardian_molten_fortress_pull:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.target:InterruptMotionControllers(false)
    local pull_distance = 1
    local targetPosition = self.target:GetAbsOrigin()
    local direction = (self.ability.castPosition - targetPosition):Normalized()
    local set_point = targetPosition + direction * pull_distance
    self.target:SetAbsOrigin(Vector(set_point.x, set_point.y, GetGroundPosition(set_point, self.target).z))
    GridNav:DestroyTreesAroundPoint(targetPosition, pull_distance, false)
end

LinkedModifiers["modifier_molten_guardian_molten_fortress_pull"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_molten_fortress_barrier = class({
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
        return {
            MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
        }
    end,
    GetModifierMoveSpeed_Absolute = function(self)
        return 0.1
    end
})

LinkedModifiers["modifier_molten_guardian_molten_fortress_barrier"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_molten_fortress_check_position = class({
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
    end
})

function modifier_molten_guardian_molten_fortress_check_position:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.target = self:GetParent()
    self:StartIntervalThink(FrameTime())
end

function modifier_molten_guardian_molten_fortress_check_position:OnIntervalThink()
    if not IsServer() then
        return
    end
    local modifier_barrier = "modifier_molten_guardian_molten_fortress_barrier"
    local distance = (self.target:GetAbsOrigin() - self.ability.castPosition):Length2D()
    local distance_from_border = distance - self.ability.radius

    -- The target's angle in the world
    local target_angle = self.target:GetAnglesAsVector().y

    -- Solves for the target's angle in relation to the center of the circle in radians
    local origin_difference = self.ability.castPosition - self.target:GetAbsOrigin()
    local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)

    -- Converts the radians to degrees.
    origin_difference_radian = origin_difference_radian * 180
    local angle_from_center = origin_difference_radian / math.pi
    -- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
    angle_from_center = angle_from_center + 180.0
    -- Checks if the target is inside the field
    if distance_from_border <= 0 and math.abs(distance_from_border) <= math.max(self.target:GetHullRadius(), 50) then
        self.target:InterruptMotionControllers(true)
        self.target:AddNewModifier(self.ability.caster, self.ability, modifier_barrier, {})
        self.target:AddNewModifier(self.ability.caster, self.ability, "modifier_molten_guardian_molten_fortress_pull", { duration = 0.5 })
        -- Checks if the target is outside the field,
    elseif distance_from_border > 0 and math.abs(distance_from_border) <= math.max(self.target:GetHullRadius(), 60) then
        self.target:InterruptMotionControllers(true)
        self.target:AddNewModifier(self.ability.caster, self.ability, modifier_barrier, {})
    else
        -- Removes debuffs, so the unit can move freely
        if self.target:HasModifier(modifier_barrier) then
            self.target:RemoveModifierByName(modifier_barrier)
        end
        self:Destroy()
    end
end

function modifier_molten_guardian_molten_fortress_check_position:OnDestroy()
    if not IsServer() then
        return
    end
    if self.target:HasModifier("modifier_molten_guardian_molten_fortress_barrier") then
        self.target:RemoveModifierByName("modifier_molten_guardian_molten_fortress_barrier")
    end
end

LinkedModifiers["modifier_molten_guardian_molten_fortress_check_position"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_molten_fortress_thinker_buff = class({
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
    GetEffectName = function(self)
        return "particles/units/molten_guardian/molten_fortress/molten_fortress_buff.vpcf"
    end
})

function modifier_molten_guardian_molten_fortress_thinker_buff:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_molten_guardian_molten_fortress_thinker_buff:GetAttackDamagePercentBonus()
    return self.ability.dmgBonus
end

function modifier_molten_guardian_molten_fortress_thinker_buff:GetAttackSpeedBonus()
    return self.ability.asBonus
end

function modifier_molten_guardian_molten_fortress_thinker_buff:GetSpellDamageBonus()
    return self.ability.spelldmgBonus
end

function modifier_molten_guardian_molten_fortress_thinker_buff:GetSpellHasteBonus()
    return self.ability.sphBonus
end

LinkedModifiers["modifier_molten_guardian_molten_fortress_thinker_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_molten_fortress_second_thinker_buff = class({
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

function modifier_molten_guardian_molten_fortress_second_thinker_buff:OnCreated()
    self.ability = self:GetAbility()
end

function modifier_molten_guardian_molten_fortress_second_thinker_buff:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_molten_guardian_molten_fortress_second_thinker_buff")
    if (modifier and modifier.ability and modifier.ability.caster and damageTable.damage > 0) then
        local damageReduce = damageTable.damage * modifier.ability.damageRedirect
        local casterHp = modifier.ability.caster:GetHealth() - damageReduce
        if (casterHp >= 1) then
            modifier.ability.caster:SetHealth(casterHp)
            damageTable.damage = damageTable.damage - damageReduce
        end
        if (modifier.ability.deathProcHeal > 0) then
            local victimHp = damageTable.victim:GetHealth() - damageTable.damage
            if (victimHp < 1) then
                damageTable.damage = 0
                local healTable = {}
                healTable.caster = modifier.ability.caster
                healTable.target = damageTable.victim
                healTable.heal = modifier.ability.deathProcHeal * modifier.ability.caster:GetMaxHealth()
                GameMode:HealUnit(healTable)
                modifier:Destroy()
            end
        end
        return damageTable
    end
end

LinkedModifiers["modifier_molten_guardian_molten_fortress_second_thinker_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_molten_fortress_buff = class({
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
function modifier_molten_guardian_molten_fortress_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_molten_guardian_molten_fortress_buff:GetHealthPercentBonus()
    return self.ability.maxhpPerStack * self:GetStackCount()
end

function modifier_molten_guardian_molten_fortress_buff:GetArmorPercentBonus()
    return self.ability.armorPerStack * self:GetStackCount()
end

function modifier_molten_guardian_molten_fortress_buff:GetFireProtectionBonus()
    return self.ability.eleArmorPerStack * self:GetStackCount()
end

function modifier_molten_guardian_molten_fortress_buff:GetFrostProtectionBonus()
    return self.ability.eleArmorPerStack * self:GetStackCount()
end

function modifier_molten_guardian_molten_fortress_buff:GetEarthProtectionBonus()
    return self.ability.eleArmorPerStack * self:GetStackCount()
end

function modifier_molten_guardian_molten_fortress_buff:GetVoidProtectionBonus()
    return self.ability.eleArmorPerStack * self:GetStackCount()
end

function modifier_molten_guardian_molten_fortress_buff:GetHolyProtectionBonus()
    return self.ability.eleArmorPerStack * self:GetStackCount()
end

function modifier_molten_guardian_molten_fortress_buff:GetNatureProtectionBonus()
    return self.ability.eleArmorPerStack * self:GetStackCount()
end

function modifier_molten_guardian_molten_fortress_buff:GetInfernoProtectionBonus()
    return self.ability.eleArmorPerStack * self:GetStackCount()
end

LinkedModifiers["modifier_molten_guardian_molten_fortress_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_molten_fortress_second_thinker = class({
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
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.ability.radius
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_molten_guardian_molten_fortress_second_thinker_buff"
    end,
    GetAuraDuration = function(self)
        return 0
    end,
    GetAuraEntityReject = function(self, npc)
        return npc == self.ability.caster
    end
})
function modifier_molten_guardian_molten_fortress_second_thinker:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_molten_guardian_molten_fortress_second_thinker:OnDestroy()
    if (not IsServer()) then
        return
    end
    UTIL_Remove(self.thinker)
end

LinkedModifiers["modifier_molten_guardian_molten_fortress_second_thinker"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_molten_fortress_thinker = class({
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
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.ability.radius
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_molten_guardian_molten_fortress_thinker_buff"
    end,
    GetAuraDuration = function(self)
        return 0
    end
})

function modifier_molten_guardian_molten_fortress_thinker:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.thinker = self:GetParent()
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_arena_of_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.thinker)
    ParticleManager:SetParticleControl(self.particle, 1, Vector(self.ability.radius, 0, 0))
    ParticleManager:SetParticleControl(self.particle, 2, self.ability.castPosition)
    ParticleManager:SetParticleControl(self.particle, 3, self.ability.castPosition)
    self:StartIntervalThink(FrameTime())
    EmitSoundOn("Hero_Mars.ArenaOfBlood.Start", self.thinker)
    if (self.ability.damageRedirect > 0) then
        self.secondThinker = CreateModifierThinker(
                self.ability.caster,
                self.ability,
                "modifier_molten_guardian_molten_fortress_second_thinker",
                {
                    duration = self.ability.duration,
                },
                self.ability.castPosition,
                self.ability.casterTeam,
                false
        )
    else
        self.secondThinker = true
    end
    if (self.ability.maxhpPerStack > 0) then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.caster = self.ability.caster
        modifierTable.target = self.ability.caster
        modifierTable.modifier_name = "modifier_molten_guardian_molten_fortress_buff"
        modifierTable.duration = self.ability.duration
        GameMode:ApplyBuff(modifierTable)
    end
end

function modifier_molten_guardian_molten_fortress_thinker:OnIntervalThink()
    local enemies = FindUnitsInRadius(self.ability.casterTeam,
            self.ability.castPosition,
            nil,
            self.ability.radius + 200,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        enemy:AddNewModifier(self.ability.caster, self.ability, "modifier_molten_guardian_molten_fortress_check_position", { duration = self:GetRemainingTime() })
    end
    local rank2Modifier = self.ability.caster:FindModifierByName("modifier_molten_guardian_molten_fortress_buff")
    if (rank2Modifier and DistanceBetweenVectors(self.ability.caster:GetAbsOrigin(), self.ability.castPosition) <= self.ability.radius) then
        rank2Modifier:SetStackCount(#enemies)
    end
    if (not self.secondThinker) then
        self:Destroy()
    end
end

function modifier_molten_guardian_molten_fortress_thinker:OnDestroy()
    if (not IsServer()) then
        return
    end
    StopSoundOn("Hero_Mars.ArenaOfBlood", self.thinker)
    EmitSoundOn("Hero_Mars.ArenaOfBlood.End", self.ability.caster)
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    local rank2Modifier = self.ability.caster:FindModifierByName("modifier_molten_guardian_molten_fortress_buff")
    if (rank2Modifier) then
        rank2Modifier:Destroy()
    end
    UTIL_Remove(self.thinker)
end

LinkedModifiers["modifier_molten_guardian_molten_fortress_thinker"] = LUA_MODIFIER_MOTION_NONE

molten_guardian_molten_fortress = class({
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("radius")
    end,
})

function molten_guardian_molten_fortress:OnSpellStart()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    self.casterTeam = self.caster:GetTeamNumber()
    self.castPosition = self:GetCursorPosition()
    CreateModifierThinker(
            self.caster,
            self,
            "modifier_molten_guardian_molten_fortress_thinker",
            {
                duration = self.duration,
            },
            self.castPosition,
            self.casterTeam,
            false
    )
    AddFOWViewer(self.casterTeam, self.castPosition, self.radius, self.duration, false)
end

function molten_guardian_molten_fortress:OnUpgrade()
    self.radius = self:GetSpecialValueFor("radius")
    self.duration = self:GetSpecialValueFor("duration")
    self.dmgBonus = self:GetSpecialValueFor("dmg_bonus") / 100
    self.spelldmgBonus = self:GetSpecialValueFor("spelldmg_bonus") / 100
    self.asBonus = self:GetSpecialValueFor("as_bonus")
    self.sphBonus = self:GetSpecialValueFor("sph_bonus")
    self.maxhpPerStack = self:GetSpecialValueFor("maxhp_per_stack") / 100
    self.armorPerStack = self:GetSpecialValueFor("armor_per_stack") / 100
    self.eleArmorPerStack = self:GetSpecialValueFor("ele_armor_per_stack") / 100
    self.damageRedirect = self:GetSpecialValueFor("damage_redirect") / 100
    self.deathProcHeal = self:GetSpecialValueFor("deathproc_heal") / 100
end

--molten_guardian_shields_up
modifier_molten_guardian_shields_up_taunt = class({
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
    IsTaunt = function(self)
        return true
    end
})

LinkedModifiers["modifier_molten_guardian_shields_up_taunt"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_shields_up = class({
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
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_molten_guardian_shields_up:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
end

function modifier_molten_guardian_shields_up:GetAggroCausedBonus()
    local totalResistances = 0
    totalResistances = totalResistances + Units:GetFireProtection(self.caster)
    totalResistances = totalResistances + Units:GetFrostProtection(self.caster)
    totalResistances = totalResistances + Units:GetEarthProtection(self.caster)
    totalResistances = totalResistances + Units:GetVoidProtection(self.caster)
    totalResistances = totalResistances + Units:GetHolyProtection(self.caster)
    totalResistances = totalResistances + Units:GetNatureProtection(self.caster)
    totalResistances = totalResistances + Units:GetInfernoProtection(self.caster)
    totalResistances = totalResistances - 7
    return (totalResistances * (self.ability.primalBuffPerEleArmorAggro or 0)) + (Units:GetArmor(self.caster) * (self.ability.primalBuffPerArmorAggro or 0)) + (self.caster:GetMaxHealth() * (self.ability.primalBuffPerMaxHpAggro or 0))
end

LinkedModifiers["modifier_molten_guardian_shields_up"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_shields_up_channel = class({
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
        return "particles/units/molten_guardian/shields_up/shields_up_v2.vpcf"
    end,
})

function modifier_molten_guardian_shields_up_channel:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
end

function modifier_molten_guardian_shields_up_channel:GetDamageReductionBonus()
    return self.ability.damageReduction
end

function modifier_molten_guardian_shields_up_channel:GetImmunityToStun()
    return self.ability.statusImmune
end

function modifier_molten_guardian_shields_up_channel:GetImmunityToRoot()
    return self.ability.statusImmune
end

function modifier_molten_guardian_shields_up_channel:GetImmunityToSilence()
    return self.ability.statusImmune
end

function modifier_molten_guardian_shields_up_channel:GetImmunityToHex()
    return self.ability.statusImmune
end

function modifier_molten_guardian_shields_up_channel:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_molten_guardian_shields_up_channel")
    if (modifier and not modifier.damageInstanceBlocked and damageTable.damage > 0) then
        damageTable.damage = 0
        modifier.damageInstanceBlocked = true
        if (modifier.ability.cdrOnProc > 0) then
            local cooldownTable = {
                target = modifier.caster,
                ability = "molten_guardian_shields_up",
                reduction = modifier.ability.cdrOnProc,
                isflat = true
            }
            GameMode:ReduceAbilityCooldown(cooldownTable)
        end
        EmitSoundOn("Hero_Mars.Shield.Block", damageTable.victim)
        return damageTable
    end
end

LinkedModifiers["modifier_molten_guardian_shields_up_channel"] = LUA_MODIFIER_MOTION_NONE

molten_guardian_shields_up = class({
    GetChannelTime = function(self)
        return self:GetSpecialValueFor("channel_time")
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_molten_guardian_shields_up"
    end,
    GetAbilityTextureName = function(self)
        return "molten_guardian_shields_up"
    end
})

function molten_guardian_shields_up:OnUpgrade()
    self.damageReduction = self:GetSpecialValueFor("damage_reduction") / 100
    self.channelTime = self:GetSpecialValueFor("channel_time")
    self.cdrOnProc = self:GetSpecialValueFor("cdr_on_proc")
    self.statusImmune = self:GetSpecialValueFor("status_immune") > 0
    self.primalBuffPerArmorAggro = self:GetSpecialValueFor("primal_buff_per_armor_aggro") / 100
    self.primalBuffPerEleArmorAggro = self:GetSpecialValueFor("primal_buff_per_ele_armor_aggro") / 100
    self.primalBuffPerMaxHpAggro = self:GetSpecialValueFor("primal_buff_per_max_hp_aggro") / 100
end

function molten_guardian_shields_up:OnChannelFinish()
    if (not IsServer()) then
        return
    end
    self.caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_3)
    self.modifier:Destroy()
end

function molten_guardian_shields_up:OnSpellStart()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.caster = self.caster
    modifierTable.target = self.caster
    modifierTable.modifier_name = "modifier_molten_guardian_shields_up_channel"
    modifierTable.duration = self.channelTime
    self.modifier = GameMode:ApplyBuff(modifierTable)
    self.caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_3)
    EmitSoundOn("Hero_Mars.Shield.Cast.Small", self.caster)
    local tauntModifier = self.caster:FindModifierByName("modifier_molten_guardian_scorching_clash_taunt")
    if (tauntModifier and tauntModifier.ability and tauntModifier.ability.shieldsUpTauntDuration) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self.caster
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_molten_guardian_shields_up_taunt"
        modifierTable.duration = tauntModifier.ability.shieldsUpTauntDuration
        GameMode:ApplyBuff(modifierTable)
        tauntModifier:Destroy()
    end
end

-- molten_guardian_lava_spear
modifier_molten_guardian_lava_spear_debuff = class({
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

function modifier_molten_guardian_lava_spear_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_molten_guardian_lava_spear_debuff:GetFireProtectionBonus()
    return self.ability.fireResistanceDebuff
end

function modifier_molten_guardian_lava_spear_debuff:OnPostTakeDamage(damageTable)
    local ability = damageTable.attacker:FindAbilityByName("molten_guardian_lava_spear")
    if (ability and ability:GetLevel() > 0 and damageTable.ability == ability and ability.fireResistanceDebuffDuration > 0) then
        local modifierTable = {}
        modifierTable.ability = ability
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_molten_guardian_lava_spear_debuff"
        modifierTable.duration = ability.fireResistanceDebuffDuration
        GameMode:ApplyDebuff(modifierTable)
    end
end

LinkedModifiers["modifier_molten_guardian_lava_spear_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_lava_spear_slow = class({
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

function modifier_molten_guardian_lava_spear_slow:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_molten_guardian_lava_spear_slow:GetMoveSpeedPercentBonus()
    return self.ability.msSlow
end

LinkedModifiers["modifier_molten_guardian_lava_spear_slow"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_lava_spear_buff = class({
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

function modifier_molten_guardian_lava_spear_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_molten_guardian_lava_spear_buff:GetFireDamageBonus()
    return self.ability.fireDmgPerStack * self:GetStackCount()
end

function modifier_molten_guardian_lava_spear_buff:GetArmorPercentBonus()
    return self.ability.armorPerStack * self:GetStackCount()
end

LinkedModifiers["modifier_molten_guardian_lava_spear_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_lava_spear_thinker = class({
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

function modifier_molten_guardian_lava_spear_thinker:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.thinker = self:GetParent()
    self.casterTeam = self.caster:GetTeamNumber()
    self.startLocation = self.thinker:GetAbsOrigin()
    self.endLocation = self.startLocation + self.ability.direction * self.ability.spearDistance
    local modifier = self
    Timers:CreateTimer(0.3, function()
        modifier.particle = ParticleManager:CreateParticle("particles/units/molten_guardian/lava_spear/lava_spear_ground.vpcf", PATTACH_ABSORIGIN, modifier.thinker)
        ParticleManager:SetParticleControl(modifier.particle, 0, modifier.startLocation)
        ParticleManager:SetParticleControl(modifier.particle, 1, modifier.endLocation)
        ParticleManager:SetParticleControl(modifier.particle, 2, Vector(modifier.ability.dotDuration, 0, 0))
        ParticleManager:SetParticleControl(modifier.particle, 4, modifier.startLocation)
    end)
    self:StartIntervalThink(self.ability.dotTick)
end

function modifier_molten_guardian_lava_spear_thinker:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local enemies = FindUnitsInLine(self.casterTeam,
            self.startLocation,
            self.endLocation,
            nil,
            self.ability.spearWidth,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE)
    local damage = self.caster:GetMaxHealth() * self.ability.dotDamage
    for _, enemy in pairs(enemies) do
        local damageTable = {}
        damageTable.damage = damage
        damageTable.caster = self.caster
        damageTable.target = enemy
        damageTable.ability = self.ability
        damageTable.firedmg = true
        GameMode:DamageUnit(damageTable)
    end
end

function modifier_molten_guardian_lava_spear_thinker:OnDestroy()
    if (not IsServer()) then
        return
    end
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    UTIL_Remove(self.thinker)
end

LinkedModifiers["modifier_molten_guardian_lava_spear_thinker"] = LUA_MODIFIER_MOTION_NONE

molten_guardian_lava_spear = class({})

function molten_guardian_lava_spear:OnProjectileHit(target, location)
    if (not IsServer()) then
        return
    end
    if (target and not TableContains(self.damagedEnemies, target)) then
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = self.damage * self.caster:GetMaxHealth()
        damageTable.firedmg = true
        GameMode:DamageUnit(damageTable)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = target
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_molten_guardian_lava_spear_slow"
        modifierTable.duration = self.msSlowDuration
        GameMode:ApplyDebuff(modifierTable)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.caster = self.caster
        modifierTable.target = self.caster
        modifierTable.modifier_name = "modifier_molten_guardian_lava_spear_buff"
        modifierTable.duration = self.stacksDuration
        modifierTable.stacks = 1
        modifierTable.max_stacks = self.stacksCap
        GameMode:ApplyStackingBuff(modifierTable)
        table.insert(self.damagedEnemies, target)
    end
    return false
end

function molten_guardian_lava_spear:OnSpellStart()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    local casterLocation = self.caster:GetAbsOrigin()
    local casterTeam = self.caster:GetTeamNumber()
    self.direction = (self:GetCursorPosition() - casterLocation):Normalized()
    self.damagedEnemies = {}
    local projectile = {
        Ability = self,
        EffectName = "particles/units/heroes/hero_mars/mars_spear.vpcf",
        vSpawnOrigin = casterLocation,
        fDistance = self.spearDistance,
        fStartRadius = self.spearWidth,
        fEndRadius = self.spearWidth,
        Source = self.caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = true,
        vVelocity = self.direction * self.spearSpeed,
        bProvidesVision = true,
        iVisionRadius = 400,
        iVisionTeamNumber = casterTeam
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    if (self.dotDamage > 0) then
        CreateModifierThinker(
                self.caster,
                self,
                "modifier_molten_guardian_lava_spear_thinker",
                {
                    duration = self.dotDuration,
                },
                casterLocation,
                casterTeam,
                false
        )
    end
    EmitSoundOn("Hero_Mars.Spear.Cast", self.caster)
end

function molten_guardian_lava_spear:OnUpgrade()
    self.damage = self:GetSpecialValueFor("damage") / 100
    self.msSlow = self:GetSpecialValueFor("ms_slow") / 100
    self.msSlowDuration = self:GetSpecialValueFor("ms_slow_duration")
    self.dotDamage = self:GetSpecialValueFor("dot_damage") / 100
    self.dotTick = self:GetSpecialValueFor("dot_tick")
    self.dotDuration = self:GetSpecialValueFor("dot_duration")
    self.armorPerStack = self:GetSpecialValueFor("armor_per_stack") / 100
    self.fireDmgPerStack = self:GetSpecialValueFor("fire_dmg_per_stack") / 100
    self.stacksDuration = self:GetSpecialValueFor("stacks_duration")
    self.stacksCap = self:GetSpecialValueFor("stacks_cap")
    self.fireResistanceDebuff = self:GetSpecialValueFor("fire_resistance_debuff") / 100
    self.fireResistanceDebuffDuration = self:GetSpecialValueFor("fire_resistance_debuff_duration")
    self.spearWidth = self:GetSpecialValueFor("spear_width")
    self.spearSpeed = self:GetSpecialValueFor("spear_speed")
    self.spearDistance = self:GetSpecialValueFor("spear_distance")
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_molten_guardian", MotionController)
end

if (IsServer() and not GameMode.MOLTEN_GUARDIAN_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_molten_guardian_lava_skin_toggle, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_molten_guardian_volcanic_blow_block, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_molten_guardian_shields_up_channel, 'OnTakeDamage'))
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_molten_guardian_lava_spear_debuff, 'OnPostTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_molten_guardian_molten_fortress_second_thinker_buff, 'OnTakeDamage'))
    GameMode.MOLTEN_GUARDIAN_INIT = true
end