if Difficulty == nil then
    _G.Difficulty = class({})
end

function Difficulty:Init()
    Difficulty.confirmed = false
    Difficulty.PICK_TIME = 30
    Difficulty.value = 1
    Difficulty:InitPanaromaEvents()
end

function Difficulty:IsConfirmed()
    return Difficulty.confirmed
end

function Difficulty:GetValue()
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
    Difficulty.hostId = Difficulty:FindHostPlayerId()
    if (Difficulty.hostId > -1) then
        CustomGameEventManager:Send_ServerToAllClients("rpg_difficulty_is_host", { player_id = Difficulty.hostId })
    end
    CustomGameEventManager:Send_ServerToAllClients("rpg_difficulty_open_window_from_server", { pick_time = Difficulty.PICK_TIME })
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
    event.difficulty = tonumber(event.difficulty)
    if (Difficulty.hostId == event.PlayerID and event.difficulty and event.difficulty > 0 and Difficulty:IsConfirmed() == false) then
        Difficulty.value = event.difficulty / 10
        Difficulty.confirmed = true
        Notifications:BottomToAll({ image = "s2r://panorama/images/hud/skull_stroke_png.vtex", duration = 3})
        Notifications:BottomToAll({ text = "#DOTA_Difficulty_Set", duration = 3, continue = true })
        Notifications:BottomToAll({ text = "#DOTA_Difficulty_" .. event.difficulty, duration = 3, continue = true })
        Notifications:BottomToAll({ text = "!", duration = 3, continue = true })
        CustomGameEventManager:Send_ServerToAllClients("rpg_difficulty_close_window_from_server", {})
        local heroes = HeroList:GetAllHeroes()
        for _, hero in pairs(heroes) do
            local modifier = hero:FindModifierByName("modifier_difficulty_stun")
            if (modifier) then
                modifier:Destroy()
            end
        end
    end
end

function Difficulty:OnDifficultyWindowChangedRequest(event)
    if (not event) then
        return
    end
    event.PlayerID = tonumber(event.PlayerID)
    event.value = tonumber(event.value)
    if (event.PlayerID == Difficulty.hostId and event.value) then
        CustomGameEventManager:Send_ServerToAllClients("rpg_difficulty_change_value", { value = event.value })
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
    if (unit.IsRealHero and unit:IsRealHero() and Difficulty:IsConfirmed() == false) then
        unit:AddNewModifier(unit, nil, "modifier_difficulty_stun", { Duration = Difficulty.PICK_TIME })
    end
end, nil)

if not Difficulty.initialized and IsServer() then
    Difficulty:Init()
    Difficulty.initialized = true
end