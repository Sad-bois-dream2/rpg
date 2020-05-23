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
    HeroSelection.playerHeroes = {}
    HeroSelection.STATE_SELECTED = 0
    HeroSelection.STATE_PICKED = 1
    HeroSelection.pickTimeEnded = false
    HeroSelection:InitPanaromaEvents()
end

function HeroSelection:IsEnded()
    return HeroSelection.pickTimeEnded
end

function HeroSelection:OnAllPlayersSelectedHero()
    GameRules:FinishCustomGameSetup()
    for i = 0, PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) - 1 do
        if(not HeroSelection.playerHeroes["player"..i]) then
            HeroSelection.playerHeroes["player"..i] = {}
            HeroSelection.playerHeroes["player"..i].playerId = i
            HeroSelection.playerHeroes["player"..i].hero = HeroSelection.data[math.random(1, #HeroSelection.data)]
        end
        local player = PlayerResource:GetPlayer(i)
        if(player) then
            player:SetSelectedHero(HeroSelection.playerHeroes["player"..i].hero)
        end
    end
end

function HeroSelection:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_hero_selection_check_state", Dynamic_Wrap(HeroSelection, 'OnCheckStateRequest'))
    CustomGameEventManager:RegisterListener("rpg_hero_selection_get_heroes", Dynamic_Wrap(HeroSelection, 'OnGetHeroesRequest'))
    CustomGameEventManager:RegisterListener("rpg_hero_selection_get_state", Dynamic_Wrap(HeroSelection, 'OnGetStateRequest'))
    CustomGameEventManager:RegisterListener("rpg_hero_selection_hero_selected", Dynamic_Wrap(HeroSelection, 'OnHeroSelectedRequest'))
    CustomGameEventManager:RegisterListener("rpg_hero_selection_hero_picked", Dynamic_Wrap(HeroSelection, 'OnHeroPickedRequest'))
end

function HeroSelection:OnGetStateRequest(event)
    if (not event or not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    CustomGameEventManager:Send_ServerToPlayer(player, "rpg_hero_selection_get_state_from_server", { state = json.encode(HeroSelection.playerHeroes) })
end

function HeroSelection:OnHeroPickedRequest(event)
    if (not event or not event.PlayerID) then
        return
    end
    HeroSelection.playerHeroes["player" .. event.PlayerID] = HeroSelection.playerHeroes["player" .. event.PlayerID] or {}
    HeroSelection.playerHeroes["player" .. event.PlayerID].hero = event.hero
    HeroSelection.playerHeroes["player" .. event.PlayerID].state = HeroSelection.STATE_PICKED
    HeroSelection.playerHeroes["player" .. event.PlayerID].playerId = event.PlayerID
    CustomGameEventManager:Send_ServerToAllClients("rpg_hero_selection_hero_picked_from_server", { hero = event.hero, player_id = event.PlayerID })
    if (GetTableSize(HeroSelection.playerHeroes) >= PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)) then
        HeroSelection:OnAllPlayersSelectedHero()
    end
end

function HeroSelection:OnHeroSelectedRequest(event)
    if (not event or not event.PlayerID) then
        return
    end
    if (HeroSelection.playerHeroes[event.PlayerID] and HeroSelection.playerHeroes[event.PlayerID].state == HeroSelection.STATE_PICKED) then
        return
    end
    HeroSelection.playerHeroes["player" .. event.PlayerID] = HeroSelection.playerHeroes["player" .. event.PlayerID] or {}
    HeroSelection.playerHeroes["player" .. event.PlayerID].hero = event.hero
    HeroSelection.playerHeroes["player" .. event.PlayerID].state = HeroSelection.STATE_SELECTED
    HeroSelection.playerHeroes["player" .. event.PlayerID].playerId = event.PlayerID
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
    local state = 0
    if (HeroSelection.IsEnded() == true) then
        state = 1
    end
    CustomGameEventManager:Send_ServerToPlayer(player, "rpg_hero_selection_check_state_from_server", { ended = state })
end

if IsServer() and not HeroSelection.initialized then
    HeroSelection:Init()
    HeroSelection.initialized = true
end