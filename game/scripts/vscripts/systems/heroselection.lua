if HeroSelection == nil then
    _G.HeroSelection = class({})
end

function HeroSelection:Init()
    HeroSelection.data = LoadKeyValues("scripts/npc/herolist.txt")
    local enabledHeroes = {}
    for hero, enabled in pairs(HeroSelection.data) do
        if (enabled == 1) then
            table.insert(enabledHeroes, hero)
        end
    end
    HeroSelection.data = enabledHeroes
    HeroSelection:InitPanaromaEvents()
end

function HeroSelection:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_hero_selection_check_state", Dynamic_Wrap(HeroSelection, 'OnCheckStateRequest'))
    CustomGameEventManager:RegisterListener("rpg_hero_selection_get_heroes", Dynamic_Wrap(HeroSelection, 'OnGetHeroesRequest'))
    CustomGameEventManager:RegisterListener("rpg_hero_selection_hero_selected", Dynamic_Wrap(HeroSelection, 'OnHeroSelectedRequest'))
end

function HeroSelection:OnHeroSelectedRequest(event)
    if (not event or not event.PlayerID) then
        return
    end
    CustomGameEventManager:Send_ServerToAllClients("rpg_hero_selection_hero_selected_from_server", { hero = event.hero, player_id = event.PlayerID })
end

function HeroSelection:OnGetHeroesRequest(event)
    if (not event or not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    CustomGameEventManager:Send_ServerToPlayer(player, "rpg_hero_selection_get_heroes_from_server", { heroes = json.encode(HeroSelection.data) })
end

function HeroSelection:OnCheckStateRequest(event)
    if (not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    CustomGameEventManager:Send_ServerToPlayer(player, "rpg_hero_selection_check_state_from_server", { picked = true })
end

if IsServer() and not HeroSelection.initialized then
    HeroSelection:Init()
    HeroSelection.initialized = true
end