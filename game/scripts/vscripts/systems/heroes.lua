if Heroes == nil then
    _G.Heroes = class({})
end

---@param hero CDOTA_BaseNPC_Hero
function Heroes:OnHeroCreation(hero)
    if (hero ~= nil and IsServer() and not hero:HasModifier("modifier_hero")) then
        local modifierTable = {
            ability = nil,
            target = hero,
            caster = hero,
            modifier_name = "modifier_hero",
            duration = -1
        }
        GameMode:ApplyBuff(modifierTable)
        TalentTree:SetupForHero(hero)
        Inventory:SetupForHero(hero)
        Summons:SetupForHero(hero)
    end
end

function Heroes:OnHeroLevelUp(event)
    if (not IsServer()) then
        return
    end
    local hero = EntIndexToHScript(event.hero_entindex)
    if (hero) then
        Units:ForceStatsCalculation(hero)
    end
end

modifier_hero = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ORDER }
    end
})

function modifier_hero:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_hero:OnOrder(event)
    if IsServer() then
        modifier_summon:OnSummonMasterIssueOrder(event)
    end
end

function modifier_hero:GetSpellDamageBonus()
    return 0.0007 * Units:GetHeroIntellect(self.hero)
end

function modifier_hero:GetCriticalChanceBonus()
    return 0.0005 * Units:GetHeroAgility(self.hero)
end

function modifier_hero:GetCriticalDamageBonus()
    return 0.001 * Units:GetHeroStrength(self.hero)
end

function modifier_hero:GetMoveSpeedPercentBonus()
    return 0.0006 * Units:GetHeroAgility(self.hero)
end

LinkLuaModifier("modifier_hero", "systems/heroes", LUA_MODIFIER_MOTION_NONE)