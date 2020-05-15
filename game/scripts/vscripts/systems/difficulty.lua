if Difficulty == nil then
    _G.Difficulty = class({})
end

function Difficulty:Init()
    Difficulty.value = 1
    Difficulty.PICK_TIME = 30
    Difficulty:InitPanaromaEvents()
end

function Difficulty:Get()
    return Difficulty.value
end

function Difficulty:FindHostPlayerId()
    local players = PlayerResource:GetPlayerCount() - 1
    for i = 0, players do
        if (GameRules:PlayerHasCustomGameHostPrivileges(PlayerResource:GetPlayer(i))) then
            return i
        end
    end
    return -1
end

function Difficulty:OnAllHeroesSpawned()
    CustomGameEventManager:Send_ServerToAllClients("rpg_difficulty_open_window_from_server", { pick_time = Difficulty.PICK_TIME })
    Difficulty.hostId = Difficulty:FindHostPlayerId()
    if (Difficulty.hostId > -1) then
        CustomGameEventManager:Send_ServerToAllClients("rpg_difficulty_is_host", { player_id = Difficulty.hostId })
    end
end

function Difficulty:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_difficulty_changed", Dynamic_Wrap(Difficulty, 'OnDifficultyWindowChangedRequest'))
    CustomGameEventManager:RegisterListener("rpg_difficulty_confirm", Dynamic_Wrap(Difficulty, 'OnDifficultyWindowConfirmRequest'))
end

function Difficulty:OnDifficultyWindowConfirmRequest(event)
    if (not event) then
        return
    end
    event.PlayerID = tonumber(event.PlayerID)
    if (Difficulty.hostId == event.PlayerID) then

    end
end

function Difficulty:OnDifficultyWindowChangedRequest(event)
    if (not event) then
        return
    end

end

if not Difficulty.initialized and IsServer() then
    Difficulty:Init()
    Difficulty.initialized = true
end