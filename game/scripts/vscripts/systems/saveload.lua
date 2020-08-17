if not SaveLoad then
    SaveLoad = class({})
end

function SaveLoad:Init()
    SaveLoad.LOAD_URL = "http://mistassassin.eu3.biz/load.php"
    SaveLoad.SAVE_URL = "http://mistassassin.eu3.biz/save.php"
    SaveLoad.TIMEOUT = 5000 -- Changing that require same change in heroselection.js
    SaveLoad.LOADING_DELAY = 2 -- delay in seconds before calling LoadHeroFromData()
    SaveLoad.LATEST_SLOT_ID = 2
    SaveLoad.TASK_GET_PLAYER_SLOTS_DATA = "playerSlots"
    SaveLoad.heroes = {}
    SaveLoad.playersData = {}
    SaveLoad.NPC = {}
    SaveLoad.SAVE_CD = 30 -- in seconds, changing that require same change in saveload.js
    local heroesData = LoadKeyValues("scripts/npc/herolist.txt")
    local index = 0
    for hero, enabled in pairs(heroesData) do
        if (enabled == 1) then
            SaveLoad.heroes[hero] = index
            index = index + 1
        end
    end
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(SaveLoad, 'OnNPCSpawned'), SaveLoad)
    ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(SaveLoad, 'OnGameStateChanged'), SaveLoad)
end

function SaveLoad:GetItemSlotIdByName(slotName, equipped)
    if (not slotName and (equipped ~= false or equipped ~= true)) then
        return nil
    end
    local slots = {}
    slots["mainhand"] = Inventory.slot.mainhand
    slots["body"] = Inventory.slot.body
    slots["legs"] = Inventory.slot.legs
    slots["boots"] = Inventory.slot.boots
    slots["helmet"] = Inventory.slot.helmet
    slots["offhand"] = Inventory.slot.offhand
    slots["cape"] = Inventory.slot.cape
    slots["shoulder"] = Inventory.slot.shoulder
    slots["gloves"] = Inventory.slot.gloves
    slots["ring"] = Inventory.slot.ring
    slots["belt"] = Inventory.slot.belt
    slots["amulet"] = Inventory.slot.amulet
    if (equipped == true) then
        if (slots[slotName]) then
            return slots[slotName]
        else
            return nil
        end
    end
    local result, _ = slotName:gsub("inventory", "")
    return tonumber(result)
end

function SaveLoad:GetItemSlotName(slotId, equipped)
    if (not slotId and (equipped ~= false or equipped ~= true)) then
        return "unknown"
    end
    local slots = {}
    table.insert(slots, Inventory.slot.mainhand, "mainhand")
    table.insert(slots, Inventory.slot.body, "body")
    table.insert(slots, Inventory.slot.legs, "legs")
    table.insert(slots, Inventory.slot.boots, "boots")
    table.insert(slots, Inventory.slot.helmet, "helmet")
    table.insert(slots, Inventory.slot.offhand, "offhand")
    table.insert(slots, Inventory.slot.cape, "cape")
    table.insert(slots, Inventory.slot.shoulder, "shoulder")
    table.insert(slots, Inventory.slot.gloves, "gloves")
    table.insert(slots, Inventory.slot.ring, "ring")
    table.insert(slots, Inventory.slot.belt, "belt")
    table.insert(slots, Inventory.slot.amulet, "amulet")
    if (equipped == true) then
        if (slots[slotId]) then
            return slots[slotId]
        else
            return "unknown"
        end
    end
    return "inventory" .. slotId
end

function SaveLoad:OnGameStateChanged()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        local playerSteamIds = {}
        for i = 0, PlayerResource:GetPlayerCount() - 1 do
            local player = PlayerResource:GetPlayer(i)
            if (PlayerResource:IsValidPlayerID(i) and player and player:GetTeam() ~= 1) then
                local steamID = tostring(PlayerResource:GetSteamID(i))
                local playerEntry = {
                    steamID = steamID,
                    heroes = {},
                    loaded = false
                }
                for i = 0, GetTableSize(SaveLoad.heroes) - 1 do
                    playerEntry.heroes[i] = {
                        slots = {}
                    }
                end
                table.insert(SaveLoad.playersData, playerEntry)
                table.insert(playerSteamIds, steamID)
            end
        end
        SaveLoad:LoadPlayerHeroes(playerSteamIds)
    end
end

function SaveLoad:LoadPlayerHeroes(playerSteamIds)
    local req = CreateHTTPRequestScriptVM("POST", SaveLoad.LOAD_URL)
    local loadTaskData = json.encode(SaveLoad:GenerateDataForSlotsRequest(playerSteamIds))
    req:SetHTTPRequestGetOrPostParameter("data", loadTaskData)
    req:SetHTTPRequestAbsoluteTimeoutMS(SaveLoad.TIMEOUT)
    req:Send(function(response)
        local data
        if (response.StatusCode == 200) then
            data = json.decode(response.Body)
            if (data.status == "ok") then
                data = json.decode(data.data)
            else
                data = nil
            end
        end
        SaveLoad:ParseSlotData(data)
    end)
end

function SaveLoad:ParseSlotData(data)
    if (not data) then
        for _, playerEntryData in pairs(SaveLoad.playersData) do
            playerEntryData.loaded = true
        end
        return
    end
    for _, slotData in pairs(data) do
        local entryId = -1
        for id, playerEntryData in pairs(SaveLoad.playersData) do
            if (playerEntryData.steamID == slotData.steamID) then
                entryId = id
                break
            end
        end
        local parsed, result = pcall(json.decode, slotData.items)
        if (parsed == true) then
            slotData.items = result
        else
            slotData.items = {}
        end
        parsed, result = pcall(json.decode, slotData.talents)
        if (parsed == true) then
            slotData.talents = result
        else
            slotData.talents = {}
        end
        SaveLoad.playersData[entryId].heroes[SaveLoad.heroes[slotData.hero]].slots[slotData.slotNumber] = slotData
        SaveLoad.playersData[entryId].heroes[SaveLoad.heroes[slotData.hero]].slots[slotData.slotNumber].hero = SaveLoad.heroes[slotData.hero]
        SaveLoad.playersData[entryId].loaded = true
    end
end

function SaveLoad:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_saveload_get_slots", Dynamic_Wrap(SaveLoad, 'OnGetSlotsRequest'))
    CustomGameEventManager:RegisterListener("rpg_saveload_open_window", Dynamic_Wrap(SaveLoad, 'OnSaveLoadWindowOpenRequest'))
    CustomGameEventManager:RegisterListener("rpg_saveload_close_window", Dynamic_Wrap(SaveLoad, 'OnSaveLoadWindowCloseRequest'))
    CustomGameEventManager:RegisterListener("rpg_saveload_save_hero", Dynamic_Wrap(SaveLoad, 'OnSaveHeroRequest'))
    CustomGameEventManager:RegisterListener("rpg_saveload_get_slots_for_hero", Dynamic_Wrap(SaveLoad, 'OnGetSlotsForHeroRequest'))
end

function SaveLoad:OnGetSlotsForHeroRequest(event, args)
    if (not event or not event.PlayerID) then
        return
    end
    local playerId = event.PlayerID
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if not player then
        return
    end
    local steamID = tostring(PlayerResource:GetSteamID(event.PlayerID))
    Timers:CreateTimer(0, function()
        local entryId = -1
        for id, playerData in pairs(SaveLoad.playersData) do
            if (playerData.steamID == steamID) then
                entryId = id
                break
            end
        end
        if (SaveLoad.playersData[entryId] and HeroSelection.playerHeroes["player" .. playerId]) then
            if (SaveLoad.playersData[entryId].loaded == true) then
                local data = {}
                for _, heroSlots in pairs(SaveLoad.playersData[entryId].heroes) do
                    for _, slotData in pairs(heroSlots.slots) do
                        if (slotData.hero == SaveLoad.heroes[HeroSelection.playerHeroes["player" .. playerId].hero]) then
                            table.insert(data, { hero = slotData.hero, heroLevel = SaveLoad:GetHeroLevel(slotData.heroXP), items = json.encode(slotData.items.equipped), slotNumber = slotData.slotNumber, locked = slotData.locked, new = slotData.new })
                        end
                    end
                end
                CustomGameEventManager:Send_ServerToPlayer(player, "rpg_saveload_get_slots_for_hero_from_server", { data = json.encode(data) })
            end
        else
            return 0.25
        end
    end)
end

function SaveLoad:OnSaveHeroRequest(event, args)
    if (not event or not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    local slotNumber = tonumber(event.slot)
    if (not slotNumber or slotNumber ~= 0) then
        Notifications:Bottom(event.PlayerID, { text = "What you did to cause this? slotNumber", duration = 5, style = { color = "red" } })
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_saveload_remove_cooldown", {})
        return
    end
    if (player.SaveLoadCooldown) then
        local cooldownLeft = math.floor(math.max(0, (player.SaveLoadCooldown - GameRules:GetGameTime())))
        Notifications:Bottom(event.PlayerID, { text = "#DOTA_SaveLoad_SaveCooldown", duration = 5, style = { color = "red" } })
        Notifications:Bottom(event.PlayerID, { text = " "..tostring(cooldownLeft).." ", duration = 5, style = { color = "red" }, continue = true })
        Notifications:Bottom(event.PlayerID, { text = "#DOTA_SaveLoad_SaveCooldown1", duration = 5, style = { color = "red" }, continue = true })
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_saveload_remove_cooldown", {})
        return
    end
    player.SaveLoadCooldown = GameRules:GetGameTime() + SaveLoad.SAVE_CD
    Timers:CreateTimer(SaveLoad.SAVE_CD, function()
        player.SaveLoadCooldown = nil
    end)
    SaveLoad:SaveHeroForPlayerInSlot(event.PlayerID, slotNumber)
end

function SaveLoad:OnSaveLoadWindowOpenRequest(event, args)
    if (not event or not event.player_id) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_saveload_open_window_from_server", {})
    end
end

function SaveLoad:OnSaveLoadWindowCloseRequest(event, args)
    if (not event or not event.player_id) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_saveload_close_window_from_server", {})
    end
end

function SaveLoad:GetHeroLevel(xp)
    local level = 1
    xp = tonumber(xp)
    if (not xp) then
        return level
    end
    for i = 1, MAX_LEVEL do
        if (xp >= XP_PER_LEVEL_TABLE[i]) then
            level = i
        else
            break
        end
    end
    return level
end

function SaveLoad:OnGetSlotsRequest(event)
    if (not event or not event.PlayerID) then
        return
    end
    local playerId = event.PlayerID
    local checkInterval = 0.25
    local steamID = tostring(PlayerResource:GetSteamID(playerId))
    local timeout = (SaveLoad.TIMEOUT / 1000) + checkInterval
    local entryId = -1
    for id, playerData in pairs(SaveLoad.playersData) do
        if (playerData.steamID == steamID) then
            entryId = id
            break
        end
    end
    Timers:CreateTimer(0, function()
        timeout = timeout - checkInterval
        local IsTimeout = (timeout < 0)
        if (not IsTimeout) then
            if (SaveLoad.playersData[entryId].loaded == true) then
                local player = PlayerResource:GetPlayer(playerId)
                local data = {}
                for _, heroSlots in pairs(SaveLoad.playersData[entryId].heroes) do
                    for _, slotData in pairs(heroSlots.slots) do
                        table.insert(data, { hero = slotData.hero, heroLevel = SaveLoad:GetHeroLevel(slotData.heroXP), slotNumber = slotData.slotNumber, locked = slotData.locked, new = slotData.new })
                    end
                end
                CustomGameEventManager:Send_ServerToPlayer(player, "rpg_saveload_get_slots_from_server", { data = json.encode(data), heroes = json.encode(SaveLoad.heroes) })
            else
                return 0.25
            end
        end
    end)
end

function SaveLoad:CalculateRoll(current, min, max)
    if (min == max) then
        return 1
    end
    if (min < 0 and max >= 0) then
        return math.floor((current / min) * 100) / 100
    end
    if (min >= 0 and max > 0) then
        return math.floor((current / max) * 100) / 100
    end
    if (min < 0 and max < 0) then
        return math.floor((current / max) * 100) / 100
    end
    return 0
end

function SaveLoad:BuildStatEntriesForSlot(item, stats)
    local result = {}
    if (not stats) then
        return result
    end
    local possibleItemStats = Inventory:GetPossibleItemStats(item)
    for _, statEntry in pairs(stats) do
        for statName, statValues in pairs(possibleItemStats) do
            if (statEntry.name == statName) then
                table.insert(result, { name = statName, roll = tostring(SaveLoad:CalculateRoll(statEntry.value, statValues.min, statValues.max)) })
                break
            end
        end
    end
    return result
end

function SaveLoad:SaveHeroForPlayerInSlot(playerId, slotId)
    if (not slotId or slotId < 0 or slotId > SaveLoad.LATEST_SLOT_ID or not playerId or playerId < 0) then
        return "error"
    end
    local playerID = playerId
    local req = CreateHTTPRequestScriptVM("POST", SaveLoad.SAVE_URL)
    local saveData = json.encode(SaveLoad:GenerateSaveDataForSlot(playerId, slotId))
    req:SetHTTPRequestGetOrPostParameter("data", saveData)
    req:SetHTTPRequestAbsoluteTimeoutMS(SaveLoad.TIMEOUT)
    req:Send(function(response)
        local data
        if (response.StatusCode == 200) then
            data = json.decode(response.Body)
        else
            data = { status = "error", data = "Unable connect to data server (" .. response.StatusCode .. ")." }
        end
        if (data.status == "error") then
            Notifications:Bottom(playerID, { text = "#DOTA_SaveLoad_SaveError", duration = 5, style = { color = "red" } })
            Notifications:Bottom(playerID, { text = data.data, duration = 9, style = { color = "red" } })
        else
            Notifications:Bottom(playerID, { text = "#DOTA_SaveLoad_SaveSuccessful", duration = 5, style = { color = "lime" } })
        end
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "rpg_saveload_save_hero_from_server", { data = json.encode(data) })
    end)
end

function SaveLoad:GenerateSaveDataForSlot(playerId, slotId)
    if (not slotId or slotId < 0 or slotId > SaveLoad.LATEST_SLOT_ID or not playerId or playerId < 0) then
        return "error"
    end
    local player = PlayerResource:GetPlayer(playerId)
    if (not player) then
        return "error"
    end
    local playerHero = player:GetAssignedHero()
    if (not playerHero) then
        return "error"
    end
    local data = {
        slot = slotId,
        steamID = tostring(PlayerResource:GetSteamID(playerId)),
        hero = playerHero:GetUnitName(),
        heroXP = playerHero:GetCurrentXP(),
    }
    data.items = {}
    data.items.equipped = {}
    data.items.inventory = {}
    for i = 0, Inventory.slot.last do
        local itemName = Inventory:GetItemInSlot(playerHero, true, i)
        data.items.equipped["slot" .. i] = {
            name = itemName,
            slot = SaveLoad:GetItemSlotName(i, true),
            stats = SaveLoad:BuildStatEntriesForSlot(itemName, Inventory:GetItemStatsForHero(playerHero, true, i))
        }
    end
    for i = 0, Inventory.maxStoredItems do
        local itemName = Inventory:GetItemInSlot(playerHero, false, i)
        data.items.inventory["slot" .. i] = {
            name = itemName,
            slot = SaveLoad:GetItemSlotName(i, false),
            stats = SaveLoad:BuildStatEntriesForSlot(itemName, Inventory:GetItemStatsForHero(playerHero, false, i))
        }
    end
    data.talents = {}
    for i = 1, TalentTree.latest_talent_id do
        data.talents["talent" .. i] = TalentTree:GetHeroTalentLevel(playerHero, i)
    end
    return data
end

function SaveLoad:GenerateDataForSlotsRequest(playerSteamIDs)
    if (not playerSteamIDs) then
        return "error"
    end
    local data = {
        steamIDs = json.encode(playerSteamIDs),
        task = SaveLoad.TASK_GET_PLAYER_SLOTS_DATA
    }
    return data
end

function SaveLoad:OnNPCSpawned(keys)
    if (not IsServer()) then
        return
    end
    local npc = EntIndexToHScript(keys.entindex)
    if (npc and npc:GetUnitName() == "npc_save_unit" and not npc:HasModifier("modifier_save_npc") and npc:GetTeam() == DOTA_TEAM_GOODGUYS) then
        npc:AddNewModifier(npc, nil, "modifier_save_npc", { Duration = -1 })
        SaveLoad.NPC = npc
    end
    if (npc.IsRealHero and npc:IsRealHero() == true and not npc.saveDataLoaded) then
        npc.saveDataLoaded = true
        Timers:CreateTimer(SaveLoad.LOADING_DELAY, function()
            local playerId = npc:GetPlayerOwnerID()
            local entryId = -1
            local steamID = tostring(PlayerResource:GetSteamID(playerId))
            for id, playerData in pairs(SaveLoad.playersData) do
                if (playerData.steamID == steamID) then
                    entryId = id
                    break
                else
                end
            end
            if (entryId == -1 or not HeroSelection.playerHeroes["player" .. playerId]) then
                return
            end
            local slotNumber = tonumber(HeroSelection.playerHeroes["player" .. playerId].slotNumber)
            if (not slotNumber or slotNumber < 0 or slotNumber > SaveLoad.LATEST_SLOT_ID or SaveLoad.playersData[entryId].loaded ~= true) then
                return
            end
            slotNumber = tostring(slotNumber)
            local pickedHero = HeroSelection.playerHeroes["player" .. playerId].hero
            if (not pickedHero) then
                return
            end
            pickedHero = SaveLoad.heroes[pickedHero]
            if (not pickedHero) then
                return
            end
            if (not SaveLoad.playersData[entryId].heroes[pickedHero] or not SaveLoad.playersData[entryId].heroes[pickedHero].slots[slotNumber]) then
                return
            end
            local heroXP = tonumber(SaveLoad.playersData[entryId].heroes[pickedHero].slots[slotNumber].heroXP)
            if (not heroXP) then
                heroXP = 0
            end
            npc:AddExperience(heroXP, DOTA_ModifyXP_Unspecified, false, false)
            Inventory:LoadItemsFromSaveData(npc, SaveLoad.playersData[entryId].heroes[pickedHero].slots[slotNumber].items)
            --TalentTree:LoadTalentsFromSaveData(npc, SaveLoad.playersData[entryId].heroes[pickedHero].slots[slotNumber].talents)
        end)
    end
end

modifier_save_npc = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_MIN_HEALTH }
    end,
    CheckState = function(self)
        return {
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_INVULNERABLE] = true
        }
    end,
    GetMinHealth = function(self)
        return 1
    end
})

LinkLuaModifier("modifier_save_npc", "systems/saveload", LUA_MODIFIER_MOTION_NONE)

if not SaveLoad.initialized and IsServer() then
    SaveLoad:InitPanaromaEvents()
    SaveLoad:Init()
    SaveLoad.initialized = true
end
