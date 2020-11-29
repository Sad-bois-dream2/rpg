LinkLuaModifier("modifier_talent_33", "talents/talent_33", LUA_MODIFIER_MOTION_NONE)

modifier_talent_33 = class({
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

function modifier_talent_33:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
    self.counter = 0
    self.critsForProc = 2
end

function modifier_talent_33:OnPostTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_talent_33")
    if (not modifier) then
        return
    end
    if (damageTable.crit > 1) then
        modifier.counter = modifier.counter + 1
        if (modifier.counter >= modifier.critsForProc) then
            local modifierTable = {}
            modifierTable.caster = damageTable.attacker
            modifierTable.target = damageTable.attacker
            modifierTable.ability = nil
            modifierTable.modifier_name = "modifier_talent_33_effect"
            modifierTable.duration = 5
            GameMode:ApplyBuff(modifierTable)
            modifier.counter = 0
        end
    else
        modifier.counter = 0
    end
end

modifier_talent_33_effect = class({
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
        return "file://{images}/custom_game/hud/talenttree/talent_33.png"
    end
})

function modifier_talent_33_effect:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_33_effect:GetCriticalDamageBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 33) * 0.1
end

if (IsServer() and not GameMode.TALENT_33_INIT) then
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_talent_33, 'OnPostTakeDamage'))
    GameMode.TALENT_33_INIT = true
end
