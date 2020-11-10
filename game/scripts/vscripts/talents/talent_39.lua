LinkLuaModifier("modifier_talent_39", "talents/talent_39", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_39_dot", "talents/talent_39", LUA_MODIFIER_MOTION_NONE)

modifier_talent_39 = class({
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

function modifier_talent_39:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetParent()
    self:OnIntervalThink()
    self:StartIntervalThink(10)
end

function modifier_talent_39:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.firstAbility = self.hero:GetAbilityByIndex(0)
end

function modifier_talent_39:GetDOTDamageBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 39) * 0.1
end

function modifier_talent_39:OnPostTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_talent_39")
    if (modifier and RollPercentage(40) and damageTable.ability and damageTable.ability == self.firstAbility) then
        local modifierTable = {}
        modifierTable.caster = damageTable.attacker
        modifierTable.target = damageTable.victim
        modifierTable.ability = nil
        modifierTable.modifier_name = "modifier_talent_39_dot"
        modifierTable.duration = 3
        modifierTable.stacks = 1
        modifierTable.max_stacks = 99999
        local addedModifier = GameMode:ApplyStackingDebuff(modifierTable)
        local duration = addedModifier:GetDuration()
        Timers:CreateTimer(duration, function()
            if (addedModifier and not addedModifier:IsNull()) then
                addedModifier:DecrementStackCount()
            end
        end)
    end
end

modifier_talent_39_dot = class({
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
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_39.png"
    end
})

function modifier_talent_39_dot:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetCaster()
    self.damageTable = {
        caster = self.hero,
        target = self:GetParent(),
        damage = nil,
        dot = true,
        single = true,
        fromtalent = 39
    }
    self:StartIntervalThink(1)
end

function modifier_talent_39_dot:OnIntervalThink()
    if not IsServer() then
        return
    end
    local scale = TalentTree:GetHeroTalentLevel(self.hero, 39) * 0.15
    self.damageTable.damage = Units:GetHeroPrimaryAttribute(self.hero) * scale * self:GetStackCount()
    GameMode:DamageUnit(self.damageTable)
end

if (IsServer() and not GameMode.TALENT_39_INIT) then
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_talent_39, 'OnPostTakeDamage'))
    GameMode.TALENT_39_INIT = true
end