LinkLuaModifier("modifier_talent_23", "talents/talent_23", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_23_buff", "talents/talent_23", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_23_debuff", "talents/talent_23", LUA_MODIFIER_MOTION_NONE)

modifier_talent_23 = class({
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
    end
})

function modifier_talent_23:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
    self:OnIntervalThink()
    self:StartIntervalThink(15)
end

function modifier_talent_23:OnIntervalThink()
    local sunModifier = self.hero:FindModifierByName("modifier_talent_23_buff")
    if (sunModifier) then
        sunModifier:Destroy()
        local modifierTable = {}
        modifierTable.caster = self.hero
        modifierTable.target = self.hero
        modifierTable.ability = nil
        modifierTable.duration = 15
        modifierTable.modifier_name = "modifier_talent_23_debuff"
        local addedModifier = GameMode:ApplyDebuff(modifierTable)
        if(addedModifier) then
            addedModifier:SetDuration(15.1, true)
        end
    else
        local moonModifier = self.hero:FindModifierByName("modifier_talent_23_debuff")
        if (moonModifier) then
            moonModifier:Destroy()
        end
        local modifierTable = {}
        modifierTable.caster = self.hero
        modifierTable.target = self.hero
        modifierTable.ability = nil
        modifierTable.duration = 15
        modifierTable.modifier_name = "modifier_talent_23_buff"
        local addedModifier = GameMode:ApplyBuff(modifierTable)
        if(addedModifier) then
            addedModifier:SetDuration(15.1, true)
        end
    end
end

modifier_talent_23_buff = class({
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
        return "file://{images}/custom_game/hud/talenttree/talent_23.png"
    end
})

function modifier_talent_23_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_23_buff:GetCriticalDamageBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 23) * 0.1
end

modifier_talent_23_debuff = class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_23.png"
    end
})

function modifier_talent_23_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_23_debuff:GetCriticalDamageBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 23) * -0.1
end