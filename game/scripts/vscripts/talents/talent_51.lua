LinkLuaModifier("modifier_talent_51", "talents/talent_51", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_51_effect", "talents/talent_51", LUA_MODIFIER_MOTION_NONE)

modifier_talent_51 = class({
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

function modifier_talent_51:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_51:OnModifierApplied(modifierTable)
    local modifier = modifierTable.target:FindModifierByName("modifier_talent_51")
    if (not modifier or self:GetName() == "modifier_talent_51_effect") then
        return
    end
    if (self.IsHidden and self:IsHidden() == false and self.IsDebuff and self:IsDebuff() == false) then
        local modifiers = {}
        modifiers.caster = modifierTable.target
        modifiers.target = modifierTable.target
        modifiers.ability = nil
        modifiers.modifier_name = "modifier_talent_51_effect"
        modifiers.stacks = 1
        modifiers.max_stacks = 99999
        modifiers.duration = TalentTree:GetHeroTalentLevel(modifierTable.target, 51) + 1
        local addedModifier = GameMode:ApplyStackingBuff(modifiers)
        local duration = addedModifier:GetDuration()
        Timers:CreateTimer(duration, function()
            if (addedModifier and not addedModifier:IsNull()) then
                addedModifier:DecrementStackCount()
            end
        end)
    end
end

modifier_talent_51_effect = class({
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
    DeclareFunctions = function(self)
        return {
            MODIFIER_PROPERTY_TOOLTIP
        }
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_51.png"
    end
})

function modifier_talent_51_effect:OnTooltip()
    return self:GetStackCount()
end

function modifier_talent_51_effect:GetSpellDamageBonus()
    return self:GetStackCount() * 0.01
end

function modifier_talent_51_effect:GetAttackDamagePercentBonus()
    return self:GetStackCount() * 0.01
end

if (IsServer() and not GameMode.TALENT_51_INIT) then
    GameMode:RegisterPostApplyModifierEventHandler(Dynamic_Wrap(modifier_talent_51, 'OnModifierApplied'))
    GameMode.TALENT_51_INIT = true
end