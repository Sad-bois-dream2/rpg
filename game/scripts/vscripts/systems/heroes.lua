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
        if (Enemies:IsDamagedByHero(killer, hero)) then
            Enemies:OnBossHealing(killer)
        end
    else
        local owner = killer:GetOwner()
        if (Enemies:IsBoss(owner)) then
            if (Enemies:IsDamagedByHero(owner, hero)) then
                Enemies:OnBossHealing(owner)
            end
        else
            local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                    hero:GetAbsOrigin(),
                    nil,
                    5000,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            for _, enemy in pairs(enemies) do
                if (Enemies:IsBoss(enemy) and Enemies:IsDamagedByHero(enemy, hero)) then
                    Enemies:OnBossHealing(enemy)
                end
            end
        end
    end
end

function modifier_hero:OnOrder(event)
    if IsServer() then
        modifier_summon:OnSummonMasterIssueOrder(event)
    end
end

LinkLuaModifier("modifier_hero", "systems/heroes", LUA_MODIFIER_MOTION_NONE)