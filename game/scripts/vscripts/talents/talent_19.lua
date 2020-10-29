LinkLuaModifier("modifier_talent_19", "talents/talent_19", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_19_cd", "talents/talent_19", LUA_MODIFIER_MOTION_NONE)

modifier_talent_19 = class({
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

function modifier_talent_19:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_19:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_talent_19")
    if (not modifier) then
        return
    end
    local desiredAbility = damageTable.attacker:GetAbilityByIndex(2)
    if (not damageTable.ability or damageTable.ability ~= desiredAbility) then
        return
    end
    if (damageTable.attacker:HasModifier("modifier_talent_19_cd")) then
        return
    end
    damageTable.attacker:AddNewModifier(damageTable.attacker, nil, "modifier_talent_19_cd", { Duration = 10 })
    damageTable.crit = TalentTree:GetHeroTalentLevel(damageTable.attacker, 19) + 1
    return damageTable
end

modifier_talent_19_cd = class({
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
        return "file://{images}/custom_game/hud/talenttree/talent_19.png"
    end
})

if (IsServer() and not GameMode.TALENT_19_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_19, 'OnTakeDamage'))
    GameMode.TALENT_14_INIT = true
end
