LinkLuaModifier("modifier_talent_41", "talents/talent_41", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_41_effect", "talents/talent_41", LUA_MODIFIER_MOTION_NONE)

modifier_talent_41 = class({
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

function modifier_talent_41:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetParent()
    self.abilitiesCasted = {}
end

function modifier_talent_41:OnAbilityFullyCast(keys)
    if not IsServer() then
        return
    end
    if (keys.unit ~= self.hero) then
        return
    end
    self.abilitiesCasted[keys.ability:GetAbilityIndex()] = true
    if (self.abilitiesCasted[0] and self.abilitiesCasted[1] and self.abilitiesCasted[2]) then
        local modifierTable = {}
        modifierTable.caster = keys.unit
        modifierTable.target = keys.unit
        modifierTable.ability = nil
        modifierTable.modifier_name = "modifier_talent_41_effect"
        modifierTable.duration = 12
        GameMode:ApplyBuff(modifierTable)
        self.abilitiesCasted[0] = nil
        self.abilitiesCasted[1] = nil
        self.abilitiesCasted[2] = nil
    end
end

modifier_talent_41_effect = class({
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
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_41.png"
    end,
    DeclareFunctions = function(self)
        return {
            MODIFIER_PROPERTY_TOOLTIP
        }
    end
})

function modifier_talent_41_effect:OnTooltip()
    return self:GetStackCount()
end

function modifier_talent_41_effect:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetParent()
    self.maxStacks = 1
    self:OnRefresh()
    self:OnIntervalThink()
    self:StartIntervalThink(1)
end

function modifier_talent_41_effect:OnIntervalThink()
    if not IsServer() then
        return
    end
    local stacksCount = self:GetStackCount()
    if (stacksCount < self.maxStacks) then
        self:SetStackCount(math.min(stacksCount + TalentTree:GetHeroTalentLevel(self.hero, 41), self.maxStacks))
    end
end

function modifier_talent_41_effect:OnRefresh()
    if not IsServer() then
        return
    end
    local newStacksCount = math.floor(self:GetDuration()) * TalentTree:GetHeroTalentLevel(self.hero, 41)
    if (newStacksCount > self.maxStacks) then
        self.maxStacks = newStacksCount
    end
end

function modifier_talent_41_effect:GetAttackSpeedPercentBonus()
    return self:GetStackCount() * 0.01
end

function modifier_talent_41_effect:GetSpellDamageBonus()
    return self:GetStackCount() * 0.01
end
