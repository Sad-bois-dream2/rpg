local LinkedModifiers = {}

-- molten_guardian_scorching_clash modifiers
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
        local ability = self:GetAbility()
        local ability_level = ability:GetLevel() - 1
        local tick = ability:GetLevelSpecialValueFor("dot_tick", ability_level)
        self.dot_dmg = ability:GetLevelSpecialValueFor("dot_dmg", ability_level) / 100
        self.ability = ability
        self.unit = self:GetParent()
        self.caster = self:GetCaster()
        self:StartIntervalThink(tick)
    end
end

function modifier_molten_guardian_scorching_clash_dot:OnIntervalThink()
    if IsServer() then
        local damage = self.caster:GetMaxHealth() * self.dot_dmg
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = self.unit
        damageTable.ability = self.ability
        damageTable.damage = damage
        damageTable.firedmg = true
        GameMode:DamageUnit(damageTable)
    end
end

LinkedModifiers["modifier_molten_guardian_scorching_clash_dot"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_scorching_clash_stun = class({
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
        return "particles/generic_gameplay/generic_stunned.vpcf"
    end,
    IsStunDebuff = function(self)
        return true
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
    end,
    GetOverrideAnimation = function(self)
        return ACT_DOTA_DISABLED
    end,
    CheckState = function(self)
        local state = {
            [MODIFIER_STATE_STUNNED] = true,
        }
        return state
    end,
    GetTexture = function(self)
        return molten_guardian_scorching_clash:GetAbilityTextureName()
    end,
})

LinkedModifiers["modifier_molten_guardian_scorching_clash_stun"] = LUA_MODIFIER_MOTION_NONE

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
    end
})

function modifier_molten_guardian_scorching_clash_motion:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
    return state
end

function modifier_molten_guardian_scorching_clash_motion:OnCreated(kv)
    if IsServer() then
        local ability = self:GetAbility()
        local ability_level = ability:GetLevel() - 1
        self.ability = ability
        self.caster = self:GetParent()
        self.start_location = self.caster:GetAbsOrigin()
        self.dash_speed = ability:GetLevelSpecialValueFor("dash_speed", ability_level)
        self.dash_range = math.min(ability:GetLevelSpecialValueFor("dash_range", ability_level), DistanceBetweenVectors(self.start_location, self.ability:GetCursorPosition()))
        self.base_damage = ability:GetLevelSpecialValueFor("base_damage", ability_level)
        self.dot_duration = ability:GetLevelSpecialValueFor("dot_duration", ability_level)
        self.stun_duration = ability:GetLevelSpecialValueFor("stun_duration", ability_level)
        self.stun_radius = ability:GetLevelSpecialValueFor("stun_radius", ability_level)
        self.damagedEnemies = {}
        if (self:ApplyHorizontalMotionController() == false) then
            self:Destroy()
        end
    end
end

function modifier_molten_guardian_scorching_clash_motion:OnDestroy()
    if IsServer() then
        self.caster:RemoveHorizontalMotionController(self)
        self.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
        ParticleManager:DestroyParticle(self.ability.particle, false)
        ParticleManager:ReleaseParticleIndex(self.ability.particle)
        if (self.ability:GetLevel() >= 3) then
            local pidx = ParticleManager:CreateParticle("particles/units/molten_guardian/scorching_clash/scorching_clash_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
            ParticleManager:SetParticleControl(pidx, 3, self.caster:GetAbsOrigin())
            Timers:CreateTimer(2.0, function()
                ParticleManager:DestroyParticle(pidx, false)
                ParticleManager:ReleaseParticleIndex(pidx)
            end)
            local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                    self.caster:GetAbsOrigin(),
                    nil,
                    self.stun_radius,
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
                modifierTable.modifier_name = "modifier_molten_guardian_scorching_clash_stun"
                modifierTable.duration = self.stun_duration
                GameMode:ApplyDebuff(modifierTable)
            end
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
        local current_location = self.caster:GetAbsOrigin()
        local expected_location = current_location + self.caster:GetForwardVector() * self.dash_speed * dt
        local isTraversable = GridNav:IsTraversable(expected_location)
        local isBlocked = GridNav:IsBlocked(expected_location)
        local isTreeNearby = GridNav:IsNearbyTree(expected_location, self.caster:GetHullRadius(), true)
        local traveled_distance = DistanceBetweenVectors(current_location, self.start_location)
        if (isTraversable and not isBlocked and not isTreeNearby and traveled_distance < self.dash_range) then
            self.caster:SetAbsOrigin(expected_location)
            local particle_location = expected_location + Vector(0, 0, 100)
            ParticleManager:SetParticleControl(self.ability.particle, 0, particle_location)
            ParticleManager:SetParticleControl(self.ability.particle, 1, particle_location)
            local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                    expected_location,
                    nil,
                    200,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            for _, enemy in pairs(enemies) do
                if (not TableContains(self.damagedEnemies, enemy)) then
                    local damageTable = {}
                    damageTable.caster = self.caster
                    damageTable.target = enemy
                    damageTable.ability = self.ability
                    damageTable.damage = self.base_damage
                    damageTable.firedmg = true
                    GameMode:DamageUnit(damageTable)
                    local modifierTable = {}
                    modifierTable.ability = self.ability
                    modifierTable.target = enemy
                    modifierTable.caster = self.caster
                    modifierTable.modifier_name = "modifier_molten_guardian_scorching_clash_dot"
                    modifierTable.duration = self.dot_duration
                    GameMode:ApplyDebuff(modifierTable)
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
    end,
})

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
    end
end

-- molten_guardian_lava_skin modifiers
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
    if IsServer() then
        local ability = self:GetAbility()
        local ability_level = ability:GetLevel() - 1
        local tick = ability:GetLevelSpecialValueFor("tick", ability_level)
        self.phys_dmg_reduce = ability:GetLevelSpecialValueFor("phys_dmg_reduce", ability_level)
        self.str_to_damage = ability:GetLevelSpecialValueFor("str_to_damage", ability_level) / 100
        self.damage_radius = ability:GetLevelSpecialValueFor("damage_radius", ability_level)
        self.ms_slow_duration = ability:GetLevelSpecialValueFor("ms_slow_duration", ability_level)
        self.ability = ability
        self.caster = self:GetCaster()
        self:StartIntervalThink(tick)
        self.caster:EmitSound("Hero_EmberSpirit.FlameGuard.Cast")
    end
end

function modifier_molten_guardian_lava_skin_toggle:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_molten_guardian_lava_skin_toggle")
    if (modifier ~= nil and damageTable.physdmg) then
        damageTable.damage = damageTable.damage * modifier.phys_dmg_reduce
        return damageTable
    end
end

function modifier_molten_guardian_lava_skin_toggle:OnIntervalThink()
    if IsServer() then
        local pidx = ParticleManager:CreateParticle("particles/units/molten_guardian/lava_skin/lava_skin_proc.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
        self.caster:EmitSound("Hero_EmberSpirit.FlameGuard.Loop")
        local damage = Units:GetHeroStrength(self.caster) * self.str_to_damage
        local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                self.caster:GetAbsOrigin(),
                nil,
                self.damage_radius,
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
            local modifierTable = {}
            modifierTable.ability = self.ability
            modifierTable.target = enemy
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_molten_guardian_lava_skin_slow"
            modifierTable.duration = self.ms_slow_duration
            GameMode:ApplyDebuff(modifierTable)
            local pidx = ParticleManager:CreateParticle("particles/units/molten_guardian/lava_skin/lava_skin_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
            Timers:CreateTimer(1.0, function()
                ParticleManager:DestroyParticle(pidx, false)
                ParticleManager:ReleaseParticleIndex(pidx)
            end)
        end
    end
end

LinkedModifiers["modifier_molten_guardian_lava_skin_toggle"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_lava_skin_slow = class({
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
        return molten_guardian_lava_skin:GetAbilityTextureName()
    end
})

function modifier_molten_guardian_lava_skin_slow:GetMoveSpeedBonus()
    return self.ms_slow
end

function modifier_molten_guardian_lava_skin_slow:OnCreated(kv)
    if IsServer() then
        local ability = self:GetAbility()
        local ability_level = ability:GetLevel() - 1
        self.ms_slow = ability:GetLevelSpecialValueFor("ms_slow", ability_level)
    end
end

LinkedModifiers["modifier_molten_guardian_lava_skin_slow"] = LUA_MODIFIER_MOTION_NONE

-- molten_guardian_lava_skin
molten_guardian_lava_skin = class({
    GetAbilityTextureName = function(self)
        return "molten_guardian_lava_skin"
    end,
})

function molten_guardian_lava_skin:OnToggle(unit, special_cast)
    if IsServer() then
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
            self:StartCooldown(self:GetCooldown(1))
        else
            if (caster.molten_guardian_lava_skin.modifier ~= nil) then
                caster.molten_guardian_lava_skin.modifier:Destroy()
                caster:StopSound("Hero_EmberSpirit.FlameGuard.Loop")
            end
        end
    end
end
-- molten_guardian_volcanic_blow modifiers
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
    end,
    GetTexture = function(self)
        return molten_guardian_volcanic_blow:GetAbilityTextureName()
    end
})

function modifier_molten_guardian_volcanic_blow_block:OnCreated(kv)
    if IsServer() then
        local ability = self:GetAbility()
        local ability_level = ability:GetLevel() - 1
        self.block_chance = ability:GetLevelSpecialValueFor("block_chance", ability_level)
    end
end

function modifier_molten_guardian_volcanic_blow_block:IsTaunt()
    return true
end

function modifier_molten_guardian_volcanic_blow_block:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_molten_guardian_volcanic_blow_block")
    if (modifier ~= nil and damageTable.physdmg and RollPercentage(modifier.block_chance)) then
        damageTable.damage = 0
        return damageTable
    end
end

LinkedModifiers["modifier_molten_guardian_volcanic_blow_block"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_volcanic_blow_stun = class({
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
        return molten_guardian_volcanic_blow:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/generic_gameplay/generic_stunned.vpcf"
    end,
    IsStunDebuff = function(self)
        return true
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
    end,
    GetOverrideAnimation = function(self)
        return ACT_DOTA_DISABLED
    end,
    CheckState = function(self)
        local state = {
            [MODIFIER_STATE_STUNNED] = true,
        }
        return state
    end
})

LinkedModifiers["modifier_molten_guardian_volcanic_blow_stun"] = LUA_MODIFIER_MOTION_NONE

-- molten_guardian_volcanic_blow
molten_guardian_volcanic_blow = class({
    GetAbilityTextureName = function(self)
        return "molten_guardian_volcanic_blow"
    end,
})

function molten_guardian_volcanic_blow:OnSpellStart(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local pidx = ParticleManager:CreateParticle("particles/units/molten_guardian/volcanic_blow/volcanic_blow_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(pidx, 1, Vector(200, 200, 0))
        ParticleManager:SetParticleControl(pidx, 0, caster:GetAbsOrigin())
        Timers:CreateTimer(3.0, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
        EmitSoundOn("Hero_Mars.Shield.Cast", caster)
        local ability_level = self:GetLevel() - 1
        self.stun_duration = self:GetLevelSpecialValueFor("stun_duration", ability_level)
        self.damage = self:GetLevelSpecialValueFor("damage", ability_level) / 100
        self.block_chance = self:GetLevelSpecialValueFor("block_chance", ability_level)
        self.block_duration = self:GetLevelSpecialValueFor("block_duration", ability_level)
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = target
        damageTable.ability = self
        damageTable.damage = target:GetHealth() * self.damage
        damageTable.firedmg = true
        GameMode:DamageUnit(damageTable)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = target
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_molten_guardian_volcanic_blow_stun"
        modifierTable.duration = self.stun_duration
        GameMode:ApplyDebuff(modifierTable)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_molten_guardian_volcanic_blow_block"
        modifierTable.duration = self.block_duration
        GameMode:ApplyBuff(modifierTable)
    end
end

-- molten_guardian_molten_fortress modifiers
modifier_molten_guardian_molten_fortress_helper = class({
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
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end
})

function modifier_molten_guardian_molten_fortress_helper:OnAbilityFullyCast(keys)
    if (not IsServer()) then
        return
    end
    local cursor_position = keys.ability:GetCursorPosition()
    if keys.unit == self:GetParent() and keys.ability:GetName() == "mars_arena_of_blood" and cursor_position then
        local duration = keys.ability:GetSpecialValueFor("formation_time") + keys.ability:GetSpecialValueFor("duration")
        local handle = CreateModifierThinker(
                keys.unit,
                keys.ability,
                "modifier_molten_guardian_molten_fortress_thinker",
                {
                    duration = duration,
                    ability_entindex = keys.ability:entindex()
                },
                cursor_position,
                keys.unit:GetTeamNumber(),
                false
        )
    end
end

LinkedModifiers["modifier_molten_guardian_molten_fortress_helper"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_molten_fortress_thinker = class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.radius or 0
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
    end
})

function modifier_molten_guardian_molten_fortress_thinker:OnCreated(keys)
    if not IsServer() then
        return
    end
    if (keys.ability_entindex == nil) then
        return
    end
    self.ability = EntIndexToHScript(keys.ability_entindex)
    if self.ability then
        self.radius = self.ability:GetSpecialValueFor("radius")
        local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                self:GetParent():GetAbsOrigin(),
                nil,
                self.radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        local caster = self.ability:GetCaster()
        local duration = self:GetDuration()
        for _, enemy in pairs(enemies) do
            local modifierTable = {}
            modifierTable.ability = self.ability
            modifierTable.target = enemy
            modifierTable.caster = caster
            modifierTable.modifier_name = "modifier_molten_guardian_molten_fortress_aggro"
            modifierTable.duration = duration
            GameMode:ApplyDebuff(modifierTable)
        end
    else
        self:Destroy()
    end
end
function modifier_molten_guardian_molten_fortress_thinker:OnDestroy()
    if IsServer() then
        UTIL_Remove(self:GetParent())
    end
end

LinkedModifiers["modifier_molten_guardian_molten_fortress_thinker"] = LUA_MODIFIER_MOTION_NONE

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
    GetTexture = function(self)
        return "mars_arena_of_blood" -- should be like that
    end,
    GetEffectName = function(self)
        return "particles/units/molten_guardian/molten_fortress/lava_buff.vpcf"
    end,
})

function modifier_molten_guardian_molten_fortress_thinker_buff:OnCreated(keys)
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.dmg_bonus = self.ability:GetSpecialValueFor("dmg_bonus") / 100
    self.as_bonus = self.ability:GetSpecialValueFor("as_bonus")
    self.sph_bonus = self.ability:GetSpecialValueFor("sph_bonus") / 100
end

function modifier_molten_guardian_molten_fortress_thinker_buff:GetAttackDamagePercentBonus()
    return self.dmg_bonus
end

function modifier_molten_guardian_molten_fortress_thinker_buff:GetAttackSpeedBonus()
    return self.as_bonus
end

function modifier_molten_guardian_molten_fortress_thinker_buff:GetSpellHasteBonus()
    return self.sph_bonus
end

LinkedModifiers["modifier_molten_guardian_molten_fortress_thinker_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_molten_guardian_molten_fortress_aggro = class({
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
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end
})

function modifier_molten_guardian_molten_fortress_aggro:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
end

function modifier_molten_guardian_molten_fortress_aggro:GetIgnoreAggroTarget()
    return self.caster
end

LinkedModifiers["modifier_molten_guardian_molten_fortress_aggro"] = LUA_MODIFIER_MOTION_NONE

-- molten_guardian_molten_fortress
if (IsServer()) then
    ListenToGameEvent('npc_spawned', function(event)
        if (event ~= nil) then
            local entity = EntIndexToHScript(event.entindex)
            if entity:IsRealHero() and entity:HasAbility("mars_arena_of_blood") then
                local modifierTable = {}
                modifierTable.ability = nil
                modifierTable.target = entity
                modifierTable.caster = entity
                modifierTable.modifier_name = "modifier_molten_guardian_molten_fortress_helper"
                modifierTable.duration = -1
                GameMode:ApplyBuff(modifierTable)
            end
        end
    end, nil)
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_molten_guardian", MotionController)
end

if (IsServer() and not GameMode.MOLTEN_GUARDIAN_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_molten_guardian_lava_skin_toggle, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_molten_guardian_volcanic_blow_block, 'OnTakeDamage'))
    GameMode.MOLTEN_GUARDIAN_INIT = true
end