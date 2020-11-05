LinkLuaModifier("modifier_talent_10", "talents/talent_10", LUA_MODIFIER_MOTION_NONE)

modifier_talent_10 = class({
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

function modifier_talent_10:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_10:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_talent_10")
    if (modifier and damageTable.ability) then
        local bonusDmg = TalentTree:GetHeroTalentLevel(damageTable.attacker, 10) * Units:GetHeroPrimaryAttribute(damageTable.attacker) * 0.1
        damageTable.damage = damageTable.damage + bonusDmg
        return damageTable
    end
end

if (IsServer() and not GameMode.TALENT_10_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_10, 'OnTakeDamage'), true)
    GameMode.TALENT_10_INIT = true
end
