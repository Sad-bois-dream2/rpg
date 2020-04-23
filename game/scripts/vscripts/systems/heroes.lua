if Heroes == nil then
    _G.Heroes = class({})
end

---@param hero CDOTA_BaseNPC_Hero
function Heroes:OnHeroCreation(hero)
    if (hero ~= nil and IsServer()) then
        -- changing that require changes in party.js (MAX_LIVES)
        local maxLives = 5
        local livesModifier = hero:AddNewModifier(hero, nil, "modifier_hero_lives", { Duration = -1 })
        livesModifier:SetStackCount(maxLives)
        TalentTree:SetupForHero(hero)
        Inventory:SetupForHero(hero)
        Summons:SetupForHero(hero)
    end
end

modifier_hero_lives = modifier_hero_lives or class({
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
    GetTexture = function(self)
        return "pangolier_heartpiercer"
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH, MODIFIER_EVENT_ON_ORDER }
    end
})

function modifier_hero_lives:OnOrder(event)
    if IsServer() then
        modifier_summon:OnSummonMasterIssueOrder(event)
    end
end

function modifier_hero_lives:OnDeath(event)
    local hero = self:GetParent()
    if (hero ~= event.unit) then
        return
    end
    local lives = self:GetStackCount() - 1
    if (lives <= 0) then
        hero:SetTimeUntilRespawn(9999999)
        self:Destroy()
    else
        self:SetStackCount(lives)
    end
end

function Heroes:SetLives(hero, value)
    if (hero ~= nil) then
        local modifier = hero:FindModifierByName("modifier_hero_lives")
        if (modifier ~= nil) then
            modifier:SetStackCount(value)
        end
    end
end

function Heroes:GetLives(hero)
    if (hero ~= nil) then
        local modifier = hero:FindModifierByName("modifier_hero_lives")
        if (modifier ~= nil) then
            return modifier:GetStackCount()
        end
    end
    return 0
end

LinkLuaModifier("modifier_hero_lives", "systems/heroes", LUA_MODIFIER_MOTION_NONE)