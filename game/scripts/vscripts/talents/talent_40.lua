LinkLuaModifier("modifier_talent_40", "talents/talent_40", LUA_MODIFIER_MOTION_NONE)

modifier_talent_40 = class({
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

function modifier_talent_40:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_40:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_talent_40")
    if (not modifier or modifier.cd) then
        return
    end
    local chance = TalentTree:GetHeroTalentLevel(damageTable.attacker, 40) * 10
    local proc = RollPercentage(chance)
    if (proc) then
        damageTable.caster = damageTable.attacker
        damageTable.target = damageTable.victim
        modifier.cd = true
        GameMode:DamageUnit(damageTable)
        Timers:CreateTimer(1, function()
            modifier.cd = nil
        end)
    end
    return damageTable
end

if (IsServer() and not GameMode.TALENT_40_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_40, 'OnTakeDamage'), true)
    GameMode.TALENT_40_INIT = true
end