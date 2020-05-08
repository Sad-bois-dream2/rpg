local LinkedModifiers = {}

-- chosen_invoker_purification_brilliance modifiers
modifier_chosen_invoker_purification_brilliance_buff = class({
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
        return chosen_invoker_purification_brilliance:GetAbilityTextureName()
    end
})

function modifier_chosen_invoker_purification_brilliance_buff:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    if (not keys or not keys.mana) then
        self:Destroy()
    end
    self.caster = self:GetParent()
    self.mana = keys.mana
end

function modifier_chosen_invoker_purification_brilliance_buff:GetManaRegenerationBonus()
    return self.mana * self:GetStackCount() * self.caster:GetMaxMana()
end

LinkedModifiers["modifier_chosen_invoker_purification_brilliance_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_chosen_invoker_purification_brilliance = class({
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

function modifier_chosen_invoker_purification_brilliance:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.target = self.ability:GetCursorTarget()
    self.damage = self.ability:GetSpecialValueFor("damage") / 100
    local tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
    self:OnIntervalThink()
end

function modifier_chosen_invoker_purification_brilliance:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.caster:RemoveGesture(ACT_DOTA_ATTACK)
    self.caster:RemoveGesture(ACT_DOTA_ATTACK2)
    local attachPoint = "attach_attack"
    if (RandomInt(0, 1) == 1) then
        self.caster:StartGesture(ACT_DOTA_ATTACK2)
        attachPoint = "attach_attack2"
    else
        self.caster:StartGesture(ACT_DOTA_ATTACK)
        attachPoint = "attach_attack1"
    end
    local pidx = ParticleManager:CreateParticle("particles/units/chosen_invoker/purification_brilliance/purification_brilliance_rope.vpcf", PATTACH_POINT, self.caster)
    ParticleManager:SetParticleControlEnt(pidx, 0, self.caster, PATTACH_POINT_FOLLOW, attachPoint, self.caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(pidx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
    EmitSoundOn("Hero_KeeperOfTheLight.BlindingLight", self.target)
    Timers:CreateTimer(0.97, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
        self.target:StopSound("Hero_KeeperOfTheLight.BlindingLight")
    end, self)
    local damageTable = {}
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.damage = self.damage * self.caster:GetMaxMana()
    damageTable.holydmg = true
    GameMode:DamageUnit(damageTable)
end

function modifier_chosen_invoker_purification_brilliance:OnDestroy()
    if (not IsServer()) then
        return
    end
    self.caster:RemoveGesture(ACT_DOTA_ATTACK)
    self.caster:RemoveGesture(ACT_DOTA_ATTACK2)
end

LinkedModifiers["modifier_chosen_invoker_purification_brilliance"] = LUA_MODIFIER_MOTION_NONE

-- chosen_invoker_purification_brilliance
chosen_invoker_purification_brilliance = class({
    GetAbilityTextureName = function(self)
        return "chosen_invoker_purification_brilliance"
    end,
    IsRequireCastbar = function(self)
        return true
    end
})

function chosen_invoker_purification_brilliance:OnChannelFinish(interrupted)
    if (not IsServer()) then
        return
    end
    local target = self:GetCursorTarget()
    if (interrupted and (not target or target:IsNull() or not target:IsAlive())) then
        local caster = self:GetCaster()
        local mana = self:GetSpecialValueFor("mana") / 100
        local manaDuration = self:GetSpecialValueFor("mana_duration")
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = caster
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_chosen_invoker_purification_brilliance_buff"
        modifierTable.modifier_params = { mana = mana }
        modifierTable.duration = manaDuration
        modifierTable.stacks = 1
        modifierTable.max_stacks = 99999
        GameMode:ApplyStackingBuff(modifierTable)
    end
    self.modifier:Destroy()
end

function chosen_invoker_purification_brilliance:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_chosen_invoker_purification_brilliance"
    modifierTable.duration = self:GetChannelTime()
    self.modifier = GameMode:ApplyBuff(modifierTable)
end

-- chosen_invoker_flare_array modifiers
modifier_chosen_invoker_flare_array_dot = class({
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
        return chosen_invoker_flare_array:GetAbilityTextureName()
    end
})

function modifier_chosen_invoker_flare_array_dot:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    if (not keys or not keys.dot_damage or not keys.bonus_damage) then
        self:Destroy()
    end
    self.ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.damage = keys.dot_damage
    self.bonusDamage = keys.bonus_damage
    local tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
end

function modifier_chosen_invoker_flare_array_dot:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local damageTable = {}
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = self.ability
    damageTable.damage = self.damage * self.caster:GetMaxMana() * self.bonusDamage
    damageTable.holydmg = true
    GameMode:DamageUnit(damageTable)
end

LinkedModifiers["modifier_chosen_invoker_flare_array_dot"] = LUA_MODIFIER_MOTION_NONE

modifier_chosen_invoker_flare_array_buff = class({
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
        return chosen_invoker_flare_array:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_TOOLTIP }
    end
})

function modifier_chosen_invoker_flare_array_buff:OnCreated()
    self.bonus = self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_chosen_invoker_flare_array_buff:OnTooltip()
    return self:GetStackCount() * self.bonus
end

LinkedModifiers["modifier_chosen_invoker_flare_array_buff"] = LUA_MODIFIER_MOTION_NONE

-- chosen_invoker_flare_array
chosen_invoker_flare_array = class({
    GetAbilityTextureName = function(self)
        return "chosen_invoker_flare_array"
    end
})

function chosen_invoker_flare_array:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local offset = 0.5
    local caster = self:GetCaster()
    local casterTeam = caster:GetTeam()
    local casterPosition = caster:GetAbsOrigin()
    local direction = (self:GetCursorPosition() - casterPosition):Normalized()
    local range = self:GetSpecialValueFor("range")
    local distanceBetweenExplosion = 200
    local offsetMax = range * 2 / distanceBetweenExplosion
    local damageRadius = self:GetSpecialValueFor("damage_radius")
    local maxStacks = self:GetSpecialValueFor("bonus_max")
    local baseDamage = self:GetSpecialValueFor("mana_damage") * caster:GetMaxMana() * 0.01
    local dotDamage = self:GetSpecialValueFor("dot_damage") / 100
    local dotDuration = self:GetSpecialValueFor("dot_duration")
    local damagePerStack = self:GetSpecialValueFor("bonus_damage")
    local bonusDamage = 1
    local modifier = caster:FindModifierByName("modifier_chosen_invoker_flare_array_buff")
    local enemiesAffected = {}
    local playSound = true
    if (modifier) then
        bonusDamage = 1 + (damagePerStack * modifier:GetStackCount() / 100)
        modifier:Destroy()
    end
    Timers:CreateTimer(0, function()
        local position = caster:GetAbsOrigin() + (direction * distanceBetweenExplosion * offset)
        if (playSound) then
            EmitSoundOnLocationWithCaster(position, "Hero_Invoker.SunStrike.Ignite", caster)
            playSound = false
        else
            playSound = true
        end
        AddFOWViewer(casterTeam, position, damageRadius, 2, false)
        local pidx = ParticleManager:CreateParticle("particles/units/chosen_invoker/flare_array/flare_array.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(pidx, 0, position)
        ParticleManager:SetParticleControl(pidx, 1, position)
        Timers:CreateTimer(1.0, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
        local enemies = FindUnitsInRadius(casterTeam,
                position,
                nil,
                damageRadius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        baseDamage = baseDamage * bonusDamage
        for _, enemy in pairs(enemies) do
            if (not TableContains(enemiesAffected, enemy)) then
                local modifierTable = {}
                modifierTable.ability = self
                modifierTable.target = caster
                modifierTable.caster = caster
                modifierTable.modifier_name = "modifier_chosen_invoker_flare_array_buff"
                modifierTable.duration = -1
                modifierTable.stacks = 1
                modifierTable.max_stacks = maxStacks
                GameMode:ApplyStackingBuff(modifierTable)
                local damageTable = {}
                damageTable.caster = caster
                damageTable.target = enemy
                damageTable.ability = self
                damageTable.damage = baseDamage
                damageTable.holydmg = true
                GameMode:DamageUnit(damageTable)
                modifierTable = {}
                modifierTable.ability = self
                modifierTable.target = enemy
                modifierTable.caster = caster
                modifierTable.modifier_name = "modifier_chosen_invoker_flare_array_dot"
                modifierTable.modifier_params = { dot_damage = dotDamage, bonus_damage = bonusDamage }
                modifierTable.duration = dotDuration
                GameMode:ApplyDebuff(modifierTable)
                table.insert(enemiesAffected, enemy)
            end
        end
        offset = offset + 1
        if (offset < offsetMax) then
            return 0.1
        end
    end, self)
end

-- chosen_invoker_photon_pulse modifiers
modifier_chosen_invoker_photon_pulse = class({
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

function modifier_chosen_invoker_photon_pulse:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.caster:StartGesture(ACT_DOTA_TELEPORT)
    EmitSoundOn("Hero_KeeperOfTheLight.Illuminate.Charge", self.caster)
    self.pidx = ParticleManager:CreateParticle("particles/units/chosen_invoker/photon_pulse/photon_pulse.vpcf", PATTACH_ABSORIGIN, self.caster)
    local orbPosition = self.caster:GetAbsOrigin()
    local lifespan = 1.3 * Units:GetSpellHaste(self.caster)
    local scaling = 1 + (1 - Units:GetSpellHaste(self.caster))
    ParticleManager:SetParticleControl(self.pidx, 0, orbPosition + Vector(0, 0, 300))
    ParticleManager:SetParticleControl(self.pidx, 1, orbPosition + Vector(0, 0, 250))
    ParticleManager:SetParticleControl(self.pidx, 3, Vector(500, scaling, lifespan))
end

function modifier_chosen_invoker_photon_pulse:OnDestroy()
    if (not IsServer()) then
        return
    end
    StopSoundOn("Hero_KeeperOfTheLight.Illuminate.Charge", self.caster)
    self.caster:RemoveGesture(ACT_DOTA_TELEPORT)
    ParticleManager:DestroyParticle(self.pidx, false)
    ParticleManager:ReleaseParticleIndex(self.pidx)
end

LinkedModifiers["modifier_chosen_invoker_photon_pulse"] = LUA_MODIFIER_MOTION_NONE

modifier_chosen_invoker_photon_pulse_slow = class({
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
        return chosen_invoker_photon_pulse:GetAbilityTextureName()
    end
})

function modifier_chosen_invoker_photon_pulse_slow:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    if (not keys or not keys.slow) then
        self:Destroy()
    end
    self.slow = keys.slow
end

function modifier_chosen_invoker_photon_pulse_slow:GetMoveSpeedPercentBonus()
    return self.slow
end

LinkedModifiers["modifier_chosen_invoker_photon_pulse_slow"] = LUA_MODIFIER_MOTION_NONE

-- chosen_invoker_photon_pulse
chosen_invoker_photon_pulse = class({
    GetAbilityTextureName = function(self)
        return "chosen_invoker_photon_pulse"
    end,
    IsRequireCastbar = function(self)
        return true
    end
})

function chosen_invoker_photon_pulse:OnSpellStart()
    if (not IsServer()) then
        return
    end
    self.modifier:Destroy()
    self.modifier = nil
    local caster = self:GetCaster()
    local casterTeam = caster:GetTeam()
    local radius = self:GetSpecialValueFor("radius")
    local slow = self:GetSpecialValueFor("slow") * -0.01
    local slowDur = self:GetSpecialValueFor("slow_duration")
    local damage = self:GetSpecialValueFor("mana_damage") * caster:GetMaxMana() * 0.01
    local silenceDur = self:GetSpecialValueFor("silence_duration")
    local enemies = FindUnitsInRadius(casterTeam,
            caster:GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    EmitSoundOn("Hero_KeeperOfTheLight.BlindingLight", caster)
    for _, enemy in pairs(enemies) do
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = enemy
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_silence"
        modifierTable.duration = silenceDur
        GameMode:ApplyDebuff(modifierTable)
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.holydmg = true
        GameMode:DamageUnit(damageTable)
        modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = enemy
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_chosen_invoker_photon_pulse_slow"
        modifierTable.modifier_params = { slow = slow }
        modifierTable.duration = slowDur
        GameMode:ApplyDebuff(modifierTable)
    end
    local pidx = ParticleManager:CreateParticle("particles/units/chosen_invoker/photon_pulse/photon_pulse_explosion.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx, 1, Vector(radius, 0, 0))
    Timers:CreateTimer(2, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end, self)
end

function chosen_invoker_photon_pulse:OnAbilityPhaseInterrupted()
    if (not IsServer()) then
        return
    end
    self.modifier:Destroy()
    self.modifier = nil
end

function chosen_invoker_photon_pulse:OnAbilityPhaseStart()
    if (not IsServer()) then
        return true
    end
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_chosen_invoker_photon_pulse"
    modifierTable.duration = -1
    self.modifier = GameMode:ApplyBuff(modifierTable)
    return true
end

-- chosen_invoker_light_shock
chosen_invoker_light_shock = class({
    GetAbilityTextureName = function(self)
        return "chosen_invoker_light_shock"
    end,
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("aoe")
    end
})

function chosen_invoker_light_shock:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local casterTeam = self:GetTeam()
    local targetPosition = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("aoe")
    local damage = self:GetSpecialValueFor("mana_damage") * caster:GetMaxMana() * 0.01
    local stunDuration = self:GetSpecialValueFor("stun")
    local pidx = ParticleManager:CreateParticle("particles/units/chosen_invoker/light_shock/light_shock.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx, 0, targetPosition)
    Timers:CreateTimer(2, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    EmitSoundOnLocationWithCaster(targetPosition, "Hero_Invoker.SunStrike.Ignite", caster)
    local enemies = FindUnitsInRadius(casterTeam,
            targetPosition,
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        local damageTable = {}
        damageTable.caster = caster
        damageTable.target = enemy
        damageTable.ability = self
        damageTable.damage = damage
        damageTable.holydmg = true
        GameMode:DamageUnit(damageTable)
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = enemy
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_stunned"
        modifierTable.duration = stunDuration
        GameMode:ApplyDebuff(modifierTable)
    end
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_chosen_invoker", MotionController)
end