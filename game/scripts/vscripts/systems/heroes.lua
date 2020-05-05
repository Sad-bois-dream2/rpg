if Heroes == nil then
    _G.Heroes = class({})
end

---@param hero CDOTA_BaseNPC_Hero
function Heroes:OnHeroCreation(hero)
    if (hero ~= nil and IsServer() and not hero:HasModifier("modifier_hero")) then
        hero:AddNewModifier(hero, nil, "modifier_hero", { Duration = -1 })
        TalentTree:SetupForHero(hero)
        Inventory:SetupForHero(hero)
        Summons:SetupForHero(hero)
    end
end

modifier_hero = modifier_hero or class({
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
        return { MODIFIER_EVENT_ON_ORDER, MODIFIER_EVENT_ON_DEATH }
    end
})

function modifier_hero:OnCreated()
    if (not IsServer()) then
        return
    end
    self.parent = self:GetParent()
end

function modifier_hero:OnDeath(keys)
    if (not IsServer()) then
        return
    end
    local hero = keys.unit
    local killer = keys.attacker
    if (hero ~= self.parent) then
        return
    end
    if (Enemies:IsBoss(killer)) then
        Enemies:OnBossHealing(killer)
    else
        local owner = killer:GetOwnerEntity()
        if(Enemies:IsBoss(owner)) then
            Enemies:OnBossHealing(killer)
        end
    end
end

function modifier_hero:OnOrder(event)
    if IsServer() then
        modifier_summon:OnSummonMasterIssueOrder(event)
    end
end

LinkLuaModifier("modifier_hero", "systems/heroes", LUA_MODIFIER_MOTION_NONE)