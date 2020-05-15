if Difficulty == nil then
    _G.Difficulty = class({})
end

function Difficulty:Init()
    Difficulty.confirmed = false
    Difficulty.PICK_TIME = 30
    Difficulty:InitPanaromaEvents()
end

function Difficulty:IsSet()
    return Difficulty.confirmed
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
    if (not IsServer()) then
        return
    end
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

modifier_difficulty_stun = class({
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
    CheckState = function(self)
        return {
            [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
            [MODIFIER_STATE_ROOTED] = true,
            [MODIFIER_STATE_DISARMED] = true,
            [MODIFIER_STATE_ATTACK_IMMUNE] = true,
            [MODIFIER_STATE_SILENCED] = true,
            [MODIFIER_STATE_INVULNERABLE] = true
        }
    end
})

LinkLuaModifier("modifier_difficulty_stun", "systems/difficulty", LUA_MODIFIER_MOTION_NONE)

ListenToGameEvent("npc_spawned", function(keys)
    if (not IsServer()) then
        return
    end
    local unit = EntIndexToHScript(keys.entindex)
    if (unit.IsRealHero and unit:IsRealHero() and Difficulty:IsSet() == false) then
        unit:AddNewModifier(unit, nil, "modifier_difficulty_stun", { Duration = Difficulty.PICK_TIME })
    end
end, nil)

if not Difficulty.initialized and IsServer() then
    Difficulty:Init()
    Difficulty.initialized = true
end