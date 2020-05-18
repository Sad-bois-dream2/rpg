if Difficulty == nil then
    _G.Difficulty = class({})
end

function Difficulty:Init()
    Difficulty.confirmed = false
    Difficulty.PICK_TIME = 35 -- desired time + ~5
    Difficulty.value = 1
    Difficulty:InitPanaromaEvents()
end

function Difficulty:IsConfirmed()
    return Difficulty.confirmed
end

function Difficulty:GetValue()
    return Difficulty.value
end

function Difficulty:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_difficulty_changed", Dynamic_Wrap(Difficulty, 'OnDifficultyWindowChangedRequest'))
    CustomGameEventManager:RegisterListener("rpg_difficulty_confirm", Dynamic_Wrap(Difficulty, 'OnDifficultyWindowConfirmRequest'))
    CustomGameEventManager:RegisterListener("rpg_difficulty_get_info", Dynamic_Wrap(Difficulty, 'OnDifficultyWindowGetInfoRequest'))
    CustomGameEventManager:RegisterListener("rpg_difficulty_check_state", Dynamic_Wrap(Difficulty, 'OnDifficultyWindowCheckStateRequest'))
end

function Difficulty:OnDifficultyWindowCheckStateRequest(event)
    if (not event) then
        return
    end
    event.PlayerID = tonumber(event.PlayerID)
    local player = PlayerResource:GetPlayer(event.PlayerID)
    local state = 0
    if (Difficulty:IsConfirmed() == true) then
        state = 1
    end
    if (player) then
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_difficulty_check_state_from_server", { state = state })
    end
end

function Difficulty:OnDifficultyWindowGetInfoRequest(event)
    if (not event) then
        return
    end
    event.PlayerID = tonumber(event.PlayerID)
    local player = PlayerResource:GetPlayer(event.PlayerID)
    local IsHost = 0
    if GameRules:PlayerHasCustomGameHostPrivileges(player) then
        IsHost = 1
        CustomGameEventManager:Send_ServerToAllClients("rpg_difficulty_host_id", { host = event.PlayerID })
    end
    CustomGameEventManager:Send_ServerToPlayer(player, "rpg_difficulty_get_info_from_server", { host = IsHost, pick_time = Difficulty.PICK_TIME })
end

function Difficulty:OnDifficultyWindowConfirmRequest(event)
    if (not event) then
        return
    end
    event.PlayerID = tonumber(event.PlayerID)
    event.difficulty = tonumber(event.difficulty)
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (player and event.difficulty and event.difficulty > 0 and Difficulty:IsConfirmed() == false) then
        if (GameRules:PlayerHasCustomGameHostPrivileges(player)) then
            Difficulty.value = math.max(1, (event.difficulty / 2) + 0.5)
            print(Difficulty.value)
            Difficulty.confirmed = true
            Notifications:BottomToAll({ image = "s2r://panorama/images/hud/skull_stroke_png.vtex", duration = 3 })
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
end

function Difficulty:OnDifficultyWindowChangedRequest(event)
    if (not event) then
        return
    end
    event.PlayerID = tonumber(event.PlayerID)
    event.value = tonumber(event.value)
    if (event.PlayerID and event.value) then
        local player = PlayerResource:GetPlayer(event.PlayerID)
        if GameRules:PlayerHasCustomGameHostPrivileges(player) then
            CustomGameEventManager:Send_ServerToAllClients("rpg_difficulty_change_value", { value = event.value })
        end
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