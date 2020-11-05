LinkLuaModifier("modifier_talent_46", "talents/talent_46", LUA_MODIFIER_MOTION_NONE)

modifier_talent_46 = class({
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

function modifier_talent_46:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_46:OnPostTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_talent_46")
    if (not modifier) then
        return
    end
    local talentLvl = TalentTree:GetHeroTalentLevel(self.hero, 46)
    local chance = talentLvl * 5
    if (not RollPercentage(chance)) then
        return
    end
    local damageTable = {}
    damageTable.caster = self.hero
    damageTable.target = damageTable.attacker
    damageTable.fromtalent = 46
    damageTable.damage = (talentLvl + 4) * self.hero:GetMaxHealth() * 0.01
    damageTable.firedmg = true
    damageTable.infernodmg = true
    GameMode:DamageUnit(damageTable)
end

if (IsServer() and not GameMode.TALENT_46_INIT) then
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_talent_46, 'OnPostTakeDamage'))
    GameMode.TALENT_40_INIT = true
end