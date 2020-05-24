if HeroSelection == nil then
    _G.HeroSelection = class({})
end

function HeroSelection:Init()
    local heroesData = LoadKeyValues("scripts/npc/herolist.txt")
    local heroesStatsData = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
    local enabledHeroes = {}
    for hero, enabled in pairs(heroesData) do
        if (enabled == 1) then
            table.insert(enabledHeroes, HeroSelection:BuildHeroEntry(hero, heroesStatsData))
        end
    end
    HeroSelection.data = enabledHeroes
    HeroSelection.playerHeroes = {}
    HeroSelection.STATE_SELECTED = 0
    HeroSelection.STATE_PICKED = 1
    HeroSelection.pickTimeEnded = false
    ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(HeroSelection, 'OnGameStateChanged'), nil)
    HeroSelection:InitPanaromaEvents()
end

function HeroSelection:BuildHeroEntry(heroName, kv)
    local heroEntry = {
        Roles = {
            Tank = 0,
            DPS = 0,
            Support = 0,
            Utility = 0
        },
        Attribute = DOTA_ATTRIBUTE_STRENGTH,
        Name = heroName,
        Abilities = {
            [1] = "",
            [2] = "",
            [3] = "",
            [4] = "",
            [5] = "",
            [6] = "",
        }
    }
    if(not kv or not kv[heroName]) then
        return heroEntry
    end
    if(kv[heroName].Roles) then
        heroEntry.Roles.Tank = kv[heroName].Roles.Tank or 0
        heroEntry.Roles.DPS = kv[heroName].Roles.DPS or 0
        heroEntry.Roles.Support = kv[heroName].Roles.Support or 0
        heroEntry.Roles.Utility = kv[heroName].Roles.Utility or 0
    end
    heroEntry.Attribute = kv[heroName].AttributePrimary or heroEntry.Attribute
    for index = 1, 6 do
        heroEntry.Abilities[index] = kv[heroName]["Ability"..index] or heroEntry.Abilities[index]
    end
    return heroEntry
end

function HeroSelection:IsEnded()
    return HeroSelection.pickTimeEnded
end

function HeroSelection:OnGameStateChanged()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
        HeroSelection:OnAllPlayersSelectedHero()
    end
end

function HeroSelection:OnAllPlayersSelectedHero()
    for i = 0, PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) - 1 do
        if(not HeroSelection.playerHeroes["player"..i]) then
            HeroSelection.playerHeroes["player"..i] = {}
            HeroSelection.playerHeroes["player"..i].playerId = i
            HeroSelection.playerHeroes["player"..i].hero = HeroSelection.data[math.random(1, #HeroSelection.data)].Name
        end
        local player = PlayerResource:GetPlayer(i)
        if(player) then
            player:SetSelectedHero(HeroSelection.playerHeroes["player"..i].hero)
        end
    end
    HeroSelection.pickTimeEnded = true
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

function HeroSelection:IsAllPlayersPickedHero()
    local totalPlayersCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
    local totalPlayersPickedHero = 0
    for _, playerData in pairs(HeroSelection.playerHeroes) do
        if(playerData.state == HeroSelection.STATE_PICKED) then
            totalPlayersPickedHero = totalPlayersPickedHero + 1
        end
    end
    if(totalPlayersPickedHero >= totalPlayersCount) then
        return true
    end
    return false
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
    if (HeroSelection:IsAllPlayersPickedHero()) then
        GameRules:FinishCustomGameSetup()
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