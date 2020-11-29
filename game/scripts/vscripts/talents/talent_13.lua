LinkLuaModifier("modifier_talent_13", "talents/talent_13", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_13_crit_buff", "talents/talent_13", LUA_MODIFIER_MOTION_NONE)

modifier_talent_13 = class({
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

function modifier_talent_13:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_13:OnPostTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_talent_13")
    if (not modifier) then
        return
    end
    if (damageTable.crit > 1.0) then
        local critModifier = damageTable.attacker:FindModifierByName("modifier_talent_13_crit_buff")
        if (critModifier) then
            critModifier:Destroy()
        end
    else
        local modifierTable = {}
        modifierTable.ability = nil
        modifierTable.caster = damageTable.attacker
        modifierTable.target = damageTable.attacker
        modifierTable.modifier_name = "modifier_talent_13_crit_buff"
        modifierTable.duration = -1
        modifierTable.stacks = 1
        modifierTable.max_stacks = 100
        GameMode:ApplyStackingBuff(modifierTable)
    end
end

modifier_talent_13_crit_buff = class({
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
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_13.png"
    end
})

function modifier_talent_13_crit_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_13_crit_buff:GetCriticalChanceBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 13) * self:GetStackCount() * 0.05
end

if (IsServer() and not GameMode.TALENT_13_INIT) then
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_talent_13, 'OnPostTakeDamage'))
    GameMode.TALENT_13_INIT = true
end
