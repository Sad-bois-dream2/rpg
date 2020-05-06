local LinkedModifiers = {}
-- luminous_samurai_bankai modifiers
modifier_luminous_samurai_bankai_buff = class({
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
        return luminous_samurai_bankai:GetAbilityTextureName()
    end,
    DeclareFunctions = function(self)
        return {
            MODIFIER_PROPERTY_TOOLTIP,
            MODIFIER_PROPERTY_TOOLTIP2
        }
    end
})

function modifier_luminous_samurai_bankai_buff:OnCreated()
    self.ability = self:GetAbility()
    self.attackDamage = self.ability:GetSpecialValueFor("attack_dmg_per_stack")
    self.critDamage = self.ability:GetSpecialValueFor("crit_dmg_per_stack") / 100
end

function modifier_luminous_samurai_bankai_buff:GetAttackDamageBonus()
    return self.attackDamage * self:GetStackCount()
end

function modifier_luminous_samurai_bankai_buff:GetCriticalDamageBonus()
    return self.critDamage * self:GetStackCount()
end

function modifier_luminous_samurai_bankai_buff:OnTooltip()
    return self.attackDamage * self:GetStackCount()
end

function modifier_luminous_samurai_bankai_buff:OnTooltip2()
    return self.critDamage * self:GetStackCount() * 100
end

LinkedModifiers["modifier_luminous_samurai_bankai_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_luminous_samurai_bankai = class({
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
        return "particles/units/luminous_samurai/bankai/bankai_buff.vpcf"
    end,
    DeclareFunctions = function(self)
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
            MODIFIER_EVENT_ON_DEATH
        }
    end
})

function modifier_luminous_samurai_bankai:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
    self.stackDuration = self.ability:GetSpecialValueFor("stack_duration")
    self.maxStacks = self.ability:GetSpecialValueFor("max_stacks")
    self.bonusDuration = self.ability:GetSpecialValueFor("bonus_duration")
end

function modifier_luminous_samurai_bankai:OnAttackLanded(keys)
    if (not IsServer()) then
        return
    end
    local attacker = keys.attacker
    local target = keys.target
    if (attacker ~= nil and target ~= nil and attacker ~= target and attacker == self.caster) then
        local modifierTable = {}
        modifierTable.ability = self.ability
        modifierTable.target = self.caster
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_luminous_samurai_bankai_buff"
        modifierTable.duration = self.stackDuration
        modifierTable.stacks = 1
        modifierTable.max_stacks = self.maxStacks
        GameMode:ApplyStackingBuff(modifierTable)
        local pidx = ParticleManager:CreateParticle("particles/units/luminous_samurai/bankai/bankai_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControlEnt(pidx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        Timers:CreateTimer(3.0, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
    end
end

function modifier_luminous_samurai_bankai:OnDeath(keys)
    if (not IsServer()) then
        return
    end
    if (keys.attacker == self.caster) then
        self:SetDuration(self:GetElapsedTime() + self.bonusDuration, true)
    end
end

LinkedModifiers["modifier_luminous_samurai_bankai"] = LUA_MODIFIER_MOTION_NONE

-- luminous_samurai_bankai
luminous_samurai_bankai = class({
    GetAbilityTextureName = function(self)
        return "luminous_samurai_bankai"
    end
})

function luminous_samurai_bankai:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_luminous_samurai_bankai"
    modifierTable.duration = self:GetSpecialValueFor("duration")
    GameMode:ApplyBuff(modifierTable)
    local pidx = ParticleManager:CreateParticle("particles/units/luminous_samurai/bankai/bankai.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    Timers:CreateTimer(3.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
end

-- luminous_samurai_jhana modifiers
modifier_luminous_samurai_jhana_buff = class({
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

function modifier_luminous_samurai_jhana_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
end

function modifier_luminous_samurai_jhana_buff:OnStackCountChanged(oldStacks)
    if (not IsServer()) then
        return
    end
    Timers:CreateTimer(self.ability.stackDuration, function()
        local stacks = self:GetStackCount() - 1
        if(stacks < 1) then
            self:Destroy()
        else
            self:SetStackCount(stacks)
        end
    end)
end

function modifier_luminous_samurai_jhana_buff:GetHealthRegenerationBonus()
    return self.ability.hpPerStack * self:GetStackCount()
end

function modifier_luminous_samurai_jhana_buff:GetManaRegenerationBonus()
    return self.ability.mpPerStack * self:GetStackCount()
end

LinkedModifiers["modifier_luminous_samurai_jhana_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_luminous_samurai_jhana = class({
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
    end
})

function modifier_luminous_samurai_jhana:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_luminous_samurai_jhana:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_luminous_samurai_jhana")
    if (damageTable.damage > 0 and modifier and RollPercentage(modifier.ability.procChance) and not modifier.cooldown) then
        local modifierTable = {}
        modifierTable.ability = modifier.ability
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.victim
        modifierTable.modifier_name = "modifier_luminous_samurai_jhana_buff"
        modifierTable.duration = -1
        modifierTable.stacks = 1
        modifierTable.max_stacks = modifier.ability.maxStacks
        GameMode:ApplyStackingBuff(modifierTable)
        modifier.cooldown = true
        Timers:CreateTimer(modifier.ability.stackCooldown, function()
            modifier.cooldown = nil
        end)
        damageTable.damage = 0
        return damageTable
    end
end

LinkedModifiers["modifier_luminous_samurai_jhana"] = LUA_MODIFIER_MOTION_NONE

-- luminous_samurai_jhana
luminous_samurai_jhana = class({
    GetAbilityTextureName = function(self)
        return "luminous_samurai_jhana"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_luminous_samurai_jhana"
    end
})

function luminous_samurai_jhana:OnUpgrade()
    if (not IsServer()) then
        return
    end
    self.procChance = self:GetSpecialValueFor("proc_chance")
    self.hpPerStack = self:GetSpecialValueFor("hp_per_stack")
    self.mpPerStack = self:GetSpecialValueFor("mp_per_stack")
    self.maxStacks = self:GetSpecialValueFor("max_stacks")
    self.stackDuration = self:GetSpecialValueFor("stack_duration")
    self.stackCooldown = self:GetSpecialValueFor("stack_cd")
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_luminous_samurai", MotionController)
end

if (IsServer() and not GameMode.LUMINOUS_SAMURAI_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_luminous_samurai_jhana, 'OnTakeDamage'))
    GameMode.LUMINOUS_SAMURAI_INIT = true
end