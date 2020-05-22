if HeroSelection == nil then
    _G.HeroSelection = class({})
end

function HeroSelection:Init()
    HeroSelection:InitPanaromaEvents()
end

function HeroSelection:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_hero_selection_check_state", Dynamic_Wrap(HeroSelection, 'OnCheckStateRequest'))
end

function HeroSelection:OnCheckStateRequest(event)
    if (not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    CustomGameEventManager:Send_ServerToPlayer(player, "rpg_hero_selection_check_state_from_server", { picked = false })
end

if IsServer() and not HeroSelection.initialized then
    HeroSelection:Init()
    HeroSelection.initialized = true
end