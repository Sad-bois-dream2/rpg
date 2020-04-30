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

modifier_chosen_invoker_purification_brilliance = modifier_chosen_invoker_purification_brilliance or class({
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
    self.baseDamage = self.ability:GetSpecialValueFor("base_damage")
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
    damageTable.damage = self.baseDamage + (self.damage * Units:GetHeroIntellect(self.caster))
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
    self.modifier = caster:AddNewModifier(caster, self, "modifier_chosen_invoker_purification_brilliance", { duration = self:GetChannelTime() })
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
    local baseDamage = self:GetSpecialValueFor("base_damage")
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

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_chosen_invoker", MotionController)
end