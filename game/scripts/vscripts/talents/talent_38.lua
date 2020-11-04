LinkLuaModifier("modifier_talent_38", "talents/talent_38", LUA_MODIFIER_MOTION_NONE)

modifier_talent_38 = class({
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
function modifier_talent_38:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
    self.heroTeam = self.hero:GetTeamNumber()
end

function modifier_talent_38:OnPostHeal(healTable)
    local modifier = healTable.target:FindModifierByName("modifier_talent_38")
    if (not modifier or healTable.fromTalent38) then
        return
    end
    local allies = FindUnitsInRadius(self.heroTeam,
            self.hero:GetAbsOrigin(),
            nil,
            500,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local healTable = {}
    healTable.caster = self.hero
    healTable.target = nil
    healTable.ability = nil
    healTable.fromTalent38 = true
    healTable.heal = healTable.heal * 0.1 * TalentTree:GetHeroTalentLevel(self.hero, 38)
    for _, ally in pairs(allies) do
        healTable.target = ally
        GameMode:HealUnit(healTable)
    end
end

if (IsServer() and not GameMode.TALENT_38_INIT) then
    GameMode:RegisterPostHealEventHandler(Dynamic_Wrap(modifier_talent_38, 'OnPostHeal'))
    GameMode.TALENT_38_INIT = true
end