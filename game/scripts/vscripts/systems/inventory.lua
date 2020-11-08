if Inventory == nil then
    _G.Inventory = class({})
end

function Inventory:Init()
    self.maxItemsPerRequest = 10
    -- slots count, changes here require same changes in client side inventory.js
    self.maxStoredItems = 14 * 7
    -- slot types, changes here require changes in GetItemSlotName() in client side tooltip_manager.js and in GetSlotIdByName() in client side saveload.js
    -- SaveLoad:GetItemSlotName(), SaveLoad:GetItemSlotIdByName() in server side
    self.slot = {}
    self.slot.mainhand = 0
    self.slot.body = 1
    self.slot.legs = 2
    self.slot.boots = 3
    self.slot.helmet = 4
    self.slot.offhand = 5
    self.slot.cape = 6
    self.slot.shoulder = 7
    self.slot.gloves = 8
    self.slot.ring = 9
    self.slot.belt = 10
    self.slot.amulet = 11
    -- latest slot id for internal stuff
    self.slot.last = 11
    -- Invalid slot id for internal stuff
    self.slot.invalid = -1
    -- item types, changes here require changes in GetItemRarityName() in client side tooltip_manager.js
    self.rarity = {}
    self.rarity.common = 0
    self.rarity.uncommon = 1
    self.rarity.rare = 2
    self.rarity.uniqueRare = 3
    self.rarity.legendary = 4
    self.rarity.uniqueLegendary = 5
    self.rarity.cursedLegendary = 6
    self.rarity.ancient = 7
    self.rarity.uniqueAncient = 8
    self.rarity.cursedAncient = 9
    self.rarity.immortal = 10
    self.rarity.uniqueImmortal = 11
    self.rarity.cursedImmortal = 12
    -- latest rarity id for internal stuff
    self.rarity.max = 12
    self.itemsData = {}
    self.itemsKeyValues = LoadKeyValues("scripts/npc/npc_items_custom.txt")
    for itemName, itemData in pairs(Inventory.itemsKeyValues) do
        Inventory:RegisterItemSlot(itemName, Inventory.rarity[itemData.ItemRarity], Inventory.slot[itemData.ItemSlot])
    end
    Inventory:InitPanaromaEvents()
end

--  internal stuff to make all work

function Inventory:IsItemNameValid(itemName)
    if (not Inventory.itemsData[itemName]) then
        return false
    end
    return true
end

---@param hero CDOTA_BaseNPC_Hero
---@param item string
---@return number
function Inventory:AddItem(hero, item, itemStats, canDropOnGround)
    if (hero ~= nil and item ~= nil and hero.inventory ~= nil) then
        if (not Inventory:IsItemNameValid(item)) then
            DebugPrint("[INVENTORY] Attempt to add unknown item (" .. item .. ").")
            return Inventory.slot.invalid, nil
        end
        if (not itemStats) then
            local difficulty = Difficulty:GetValue()
            itemStats = Inventory:GenerateStatsForItem(item, difficulty)
        end
        for i = 0, Inventory.maxStoredItems do
            local itemInSlot = Inventory:GetItemInSlot(hero, false, i)
            if (not Inventory:IsItemNotEmpty(itemInSlot)) then
                Inventory:SetItemInSlot(hero, item, false, i, itemStats)
                return i, Inventory:GetItemInSlot(hero, false, i)
            end
        end
        if (canDropOnGround) then
            local itemOnGround = Inventory:CreateItemOnGround(hero, hero:GetAbsOrigin(), item, itemStats)
            return Inventory.slot.invalid, itemOnGround
        else
            return Inventory.slot.invalid, nil
        end
    end
end

function Inventory:CreateItemOnGround(hero, location, item, itemStats)
    local itemEntity = CreateItem(item, hero, hero)
    if (not itemEntity) then
        DebugPrint("[INVENTORY] Failed to create " .. tostring(item) .. ". Probably bugs related to npc_items.")
        return nil, nil
    end
    local itemId = itemEntity:GetEntityIndex()
    local itemOnGround = CreateItemOnPositionSync(location, itemEntity)
    Inventory:SetItemEntityStats(itemEntity, itemStats)
    itemEntity:SetPurchaser(hero)
    CustomNetTables:SetTableValue("inventory_world_items", tostring(itemId), { itemWorldId = itemOnGround:GetEntityIndex(), itemStats = itemStats, itemName = itemEntity:GetAbilityName() })
    return itemOnGround, itemEntity
end

function Inventory:GetItemsByRarity(rarity)
    local result = {}
    rarity = tonumber(rarity)
    if (not rarity or not not Inventory:IsRarityValid(rarity)) then
        DebugPrint("[INVENTORY] Attempt to get items with unknown rarity (rarity=" .. tostring(rarity) .. ")")
        return result
    end
    for itemName, itemData in pairs(Inventory.itemsData) do
        if (itemData.rarity == rarity) then
            table.insert(result, { name = itemName, slot = itemData.slot, rarity = itemData.rarity, stats = itemData.stats })
        end
    end
    return result
end

---@param item string
---@param difficulty number
---@return number
function Inventory:GenerateStatsForItem(item, difficultyWhereDropped, itemDifficulty)
    local result = {}
    difficultyWhereDropped = tonumber(difficultyWhereDropped)
    if (not item or not Inventory.itemsData[item] or not difficultyWhereDropped) then
        DebugPrint("[INVENTORY] Unable to generate stats for " .. tostring(item) .. ". Wtf?")
        DebugPrint("item", item)
        DebugPrint("Inventory.itemsData[item]", Inventory.itemsData[item])
        DebugPrint("difficulty", difficultyWhereDropped)
        return result
    end
    local itemStats = Inventory:GetPossibleItemStats(item)
    if (not itemStats) then
        return result
    end

    local convertedItemDifficulty = tonumber(itemDifficulty)
    local minRoll = 0
    if (convertedItemDifficulty and convertedItemDifficulty > 0) then
        if (difficultyWhereDropped > convertedItemDifficulty or math.abs(difficultyWhereDropped - convertedItemDifficulty) < 0.01) then
            minRoll = math.min(convertedItemDifficulty / difficultyWhereDropped, 0.5)
        end
    end
    for statName, statValues in pairs(itemStats) do
        local value = Inventory:PerformRoll(statValues.min, statValues.max, minRoll)
        table.insert(result, { name = statName, value = value })
    end
    return result
end

function Inventory:PerformRoll(min, max, minRoll)
    min = min + ((max - min) * minRoll)
    return math.random(math.floor(min), max)
end

---@param item string
---@return table
function Inventory:GetPossibleItemStats(item)
    if (not item or not Inventory.itemsData[item]) then
        return nil
    end
    return Inventory.itemsData[item].stats
end

---@param hero CDOTA_BaseNPC_Hero
---@param slot number
---@param is_equipped boolean
---@return table
function Inventory:GetItemStatsForHero(hero, is_equipped, slot)
    if (not hero or not slot or not Inventory:IsHeroHaveInventory(hero)) then
        return {}
    end
    if (is_equipped) then
        return DeepTableCopy(hero.inventory.equipped_items[slot].stats)
    else
        return DeepTableCopy(hero.inventory.items[slot].stats)
    end
end

---@param hero CDOTA_BaseNPC_Hero
---@return boolean
function Inventory:IsHeroHaveInventory(hero)
    if (hero ~= nil and hero.inventory ~= nil and hero.inventory.items ~= nil and hero.inventory.equipped_items ~= nil) then
        return true
    end
    return false
end

function Inventory:IsRarityValid(rarity)
    rarity = tonumber(rarity)
    if (not rarity) then
        return false
    end
    if (rarity < 0 or rarity > Inventory.rarity.max) then
        DebugPrint("[INVENTORY] Attempt to get items with unknown rarity (rarity=" .. tostring(rarity) .. ")")
        return false
    end
    return true
end

---@param slot number
---@param equipped boolean
---@return boolean
function Inventory:IsSlotValid(slot, equipped)
    if (slot ~= nil and equipped ~= nil) then
        if (equipped) then
            if (slot > Inventory.slot.invalid and slot <= Inventory.slot.last) then
                return true
            end
        else
            if (slot > Inventory.slot.invalid and slot < Inventory.maxStoredItems) then
                return true
            end
        end
    end
    return false
end

--- Return item name in desired slot (can be empty string if there are no item) or empty string if arguments invalid
---@param hero CDOTA_BaseNPC_Hero
---@param slot number
---@param is_equipped boolean
---@return string
function Inventory:GetItemInSlot(hero, is_equipped, slot)
    slot = tonumber(slot)
    if (hero ~= nil and slot ~= nil and is_equipped ~= nil) then
        if (Inventory:IsHeroHaveInventory(hero) and Inventory:IsSlotValid(slot, is_equipped)) then
            if (is_equipped) then
                return hero.inventory.equipped_items[slot].name
            else
                return hero.inventory.items[slot].name
            end
        end
    end
    return ""
end

--- Set item in slot and inform client about that
---@param hero CDOTA_BaseNPC_Hero
---@param slot number
---@param item string
---@param is_equipped boolean
---@param stats table
---@return boolean
function Inventory:SetItemInSlot(hero, item, is_equipped, slot, stats)
    slot = tonumber(slot)
    if (hero ~= nil and item ~= nil and is_equipped ~= nil and slot ~= nil and type(item) == "string") then
        if (Inventory:IsHeroHaveInventory(hero) and Inventory:IsSlotValid(slot, is_equipped)) then
            if (not stats) then
                stats = {}
            end
            if (is_equipped) then
                if (hero.inventory.equipped_items[slot].modifier ~= nil and not hero.inventory.equipped_items[slot].modifier:IsNull()) then
                    hero.inventory.equipped_items[slot].modifier:Destroy()
                end
                hero.inventory.equipped_items[slot].name = item
                hero.inventory.equipped_items[slot].stats = stats
                if (Inventory:IsItemNotEmpty(hero.inventory.equipped_items[slot].name)) then
                    local modifierTable = {}
                    modifierTable.ability = nil
                    modifierTable.target = hero
                    modifierTable.caster = hero
                    modifierTable.modifier_name = "modifier_inventory_" .. item
                    local modifierParams = {}
                    for _, statData in pairs(stats) do
                        modifierParams[statData.name] = statData.value
                    end
                    modifierTable.modifier_params = modifierParams
                    modifierTable.duration = -1
                    hero.inventory.equipped_items[slot].modifier = GameMode:ApplyBuff(modifierTable)
                end
            else
                hero.inventory.items[slot].name = item
                hero.inventory.items[slot].stats = stats
            end
            Inventory:SendUpdateInventorySlotRequest(hero, item, is_equipped, slot, stats)
        end
    end
end

--- Return slot id for that item or Inventory.slot.invalid
---@param item string
---@return number
function Inventory:GetValidSlotForItem(item)
    if (item and Inventory.itemsData[item]) then
        return Inventory.itemsData[item].slot
    end
    return Inventory.slot.invalid
end

---@param item string
---@return boolean
function Inventory:IsItemNotEmpty(item)
    if (type(item) == "string") then
        return string.len(item) > 0
    end
    return false
end

---@param item string
---@param slot number
---@return boolean
function Inventory:IsItemValidForSlot(item, slot)
    slot = tonumber(slot)
    if (item ~= nil and slot ~= nil) then
        if (slot > Inventory.slot.invalid and Inventory.itemsData[item]) then
            return Inventory.itemsData[item].slot == slot
        end
        return false
    end
    return false
end

---@param hero CDOTA_BaseNPC_Hero
function Inventory:SetupForHero(hero)
    if (hero ~= nil) then
        hero.inventory = {}
        hero.inventory.items = {}
        hero.inventory.equipped_items = {}
        for i = 0, Inventory.maxStoredItems do
            hero.inventory.items[i] = {}
            hero.inventory.items[i].name = ""
        end
        for i = 0, Inventory.slot.last do
            hero.inventory.equipped_items[i] = {}
            hero.inventory.equipped_items[i].name = ""
        end
        Inventory:AddItem(hero, "item_two_handed_sword")
        Inventory:AddItem(hero, "item_two_handed_sword_2")
        Inventory:AddItem(hero, "item_helmet")
    end
end

---@param itemName string
---@param itemRarity number
---@param itemSlot number
function Inventory:RegisterItemSlot(itemName, itemRarity, itemSlot)
    if (itemName and itemSlot and itemRarity) then
        if (not type(itemName) == "string" or string.len(itemName) == 0) then
            DebugPrint("[INVENTORY] Item name can't be empty and must be string. (got " .. tostring(itemName) .. ")")
            return
        end
        if (not Inventory:IsSlotValid(itemSlot, true)) then
            DebugPrint("[INVENTORY] Item slot (" .. tostring(itemSlot) .. ") invalid.")
            return
        end
        for _, value in pairs(Inventory.itemsData) do
            if value.item == itemName then
                DebugPrint("[INVENTORY] Bad attempt to register item \"" .. tostring(itemName) .. "\" for slot " .. tostring(itemSlot) .. " (already exists).")
                return
            end
        end
        if (not Inventory:IsRarityValid(itemRarity)) then
            DebugPrint("[INVENTORY] Bad attempt to register item \"" .. tostring(itemName) .. "\" for slot " .. tostring(itemSlot) .. " with rarity " .. tostring(itemRarity) .. " (unknown rarity).")
            return
        end
        local itemStats = {}
        local itemSetName = "none"
        if (Inventory.itemsKeyValues[itemName]) then
            if(Inventory.itemsKeyValues[itemName]["AbilitySpecial"]) then
                local itemStatsNames = Inventory:GetItemStatsFromKeyValues(Inventory.itemsKeyValues[itemName]["AbilitySpecial"], itemName)
                for _, stat in pairs(itemStatsNames) do
                    local statEntry = Inventory:FindStatValuesFromKeyValues(Inventory.itemsKeyValues[itemName]["AbilitySpecial"], stat, itemName)
                    if (statEntry) then
                        itemStats[stat.name] = statEntry
                    else
                        DebugPrint("[INVENTORY] Can't find min and max values for " .. tostring(stat.name) .. " in item " .. tostring(itemName) .. ". Ignoring.")
                    end
                end
            end
            if(Inventory.itemsKeyValues[itemName]["ItemSetName"]) then
                itemSetName = Inventory.itemsKeyValues[itemName]["ItemSetName"]
            end
        end
        Inventory.itemsData[itemName] = { slot = itemSlot, rarity = itemRarity, stats = itemStats, difficulty = 1 }
        if(itemSetName ~= "none") then
            Inventory.itemsData[itemName].setName = itemSetName
        end
    else
        DebugPrint("[INVENTORY] Bad attempt to register item (something is nil)")
        DebugPrint("itemName", itemName)
        DebugPrint("itemRarity", itemRarity)
        DebugPrint("itemSlot", itemSlot)
    end
end

function Inventory:FindStatValuesFromKeyValues(statsTable, stat, itemName)
    local result
    local min
    local max
    for _, statEntry in pairs(statsTable) do
        for k, v in pairs(statEntry) do
            if (k == (tostring(stat.name) .. "_min")) then
                min = v
            end
            if (k == (tostring(stat.name) .. "_max")) then
                max = v
            end
        end
    end
    if (min and max) then
        if (max < min) then
            min = 0
            max = 0
            DebugPrint("[INVENTORY] Max value for stat " .. tostring(stat.name) .. " from item " .. tostring(itemName) .. " must be greater or equal min. Used 0 for both to fix that.")
        end
        result = { min = min, max = max }
    end
    return result
end

function Inventory:GetItemStatsFromKeyValues(statsTable, itemName)
    local result = {}
    for _, statEntry in pairs(statsTable) do
        local entrySize = GetTableSize(statEntry)
        if (entrySize == 2) then
            local entry
            for k, v in pairs(statEntry) do
                if (string.match(k, "_min")) then
                    entry = string.gsub(k, "_min", "")
                end
            end
            if (entry) then
                table.insert(result, { name = entry })
            end
        else
            DebugPrint("[INVENTORY] Expected two key-value pairs from ability special for item " .. tostring(itemName) .. ", but received " .. tostring(entrySize) .. ". Ignoring.")
            DebugPrintTable(statEntry)
        end
    end
    return result
end

-- Panaroma related stuff
function Inventory:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_inventory_open_window", Dynamic_Wrap(Inventory, 'OnInventoryWindowOpenRequest'))
    CustomGameEventManager:RegisterListener("rpg_inventory_close_window", Dynamic_Wrap(Inventory, 'OnInventoryWindowCloseRequest'))
    CustomGameEventManager:RegisterListener("rpg_inventory_equip_item", Dynamic_Wrap(Inventory, 'OnInventoryEquipItemRequest'))
    CustomGameEventManager:RegisterListener("rpg_inventory_start_item_replace_dialog", Dynamic_Wrap(Inventory, 'OnInventoryItemReplaceDialogRequest'))
    CustomGameEventManager:RegisterListener("rpg_inventory_swap_items", Dynamic_Wrap(Inventory, 'OnInventorySwapItemsRequest'))
    CustomGameEventManager:RegisterListener("rpg_inventory_drop_item_on_ground", Dynamic_Wrap(Inventory, 'OnInventoryDropItemRequest'))
    CustomGameEventManager:RegisterListener("rpg_inventory_remove_equipped_item", Dynamic_Wrap(Inventory, 'OnInventoryEquippedItemRightClick'))
    CustomGameEventManager:RegisterListener("rpg_inventory_require_items_and_rest_data", Dynamic_Wrap(Inventory, 'OnInventoryItemsAndRestDataRequest'))
end

function Inventory:GenerateAndSendToPlayerInventoryItemsDataTable(player)
    local currentItem = 0
    local itemsData = {}
    for itemName, data in pairs(Inventory.itemsData) do
        if (currentItem > self.maxItemsPerRequest) then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_items_data", { items_data = json.encode(itemsData) })
            itemsData = {}
            currentItem = 0
        end
        table.insert(itemsData, { item = itemName, slot = data.slot, rarity = data.rarity, stats = data.stats, setName = data.setName })
        currentItem = currentItem + 1
    end
    if (#itemsData > 0) then
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_items_data", { items_data = json.encode(itemsData) })
    end
end

function Inventory:OnInventoryItemsAndRestDataRequest(event, args)
    if (event == nil or event.PlayerID == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (player == nil) then
        return
    end
    Timers:CreateTimer(0,
            function()
                local hero = player:GetAssignedHero()
                if (hero == nil) then
                    return 1.0
                end
                if (not Inventory:IsHeroHaveInventory(hero)) then
                    return 1.0
                end
                Inventory:GenerateAndSendToPlayerInventoryItemsDataTable(player)
                for i = 0, Inventory.maxStoredItems do
                    local itemInInventorySlot = Inventory:GetItemInSlot(hero, false, i)
                    if (Inventory:IsItemNotEmpty(itemInInventorySlot)) then
                        Inventory:SendUpdateInventorySlotRequest(hero, itemInInventorySlot, false, i, Inventory:GetItemStatsForHero(hero, false, i))
                    end
                end
                for i = 0, Inventory.slot.last do
                    local itemInInventoryEquippedSlot = Inventory:GetItemInSlot(hero, true, i)
                    if (Inventory:IsItemNotEmpty(itemInInventoryEquippedSlot)) then
                        Inventory:SendUpdateInventorySlotRequest(hero, itemInInventoryEquippedSlot, true, i, Inventory:GetItemStatsForHero(hero, true, i))
                    end
                end
            end)
end

--Inventory:CreateItemOnGround(HeroList:GetHero(0), HeroList:GetHero(0):GetAbsOrigin(), "item_two_handed_sword", Inventory:GenerateStatsForItem("item_two_handed_sword", 1))

function Inventory:OnInventoryItemPickedFromGround(event)
    if (not event or not event.item or not event.itemEntity or not event.player_id) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (not player) then
        return
    end
    local hero = player:GetAssignedHero()
    if (not hero) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    local itemId = event.itemEntity:GetEntityIndex()
    local itemOwner = event.itemEntity:GetPurchaser()
    local itemStats = Inventory:GetItemEntityStats(event.itemEntity)
    if (itemOwner == hero) then
        local itemSlot = Inventory:AddItem(hero, event.item, itemStats)
        if (itemSlot == Inventory.slot.invalid) then
            Inventory:CreateItemOnGround(hero, hero:GetAbsOrigin(), event.item, itemStats)
        end
    else
        Inventory:CreateItemOnGround(itemOwner, hero:GetAbsOrigin(), event.item, itemStats)
    end
    CustomNetTables:SetTableValue("inventory_world_items", tostring(itemId), nil)
    event.itemEntity:Destroy()
end

function Inventory:OnInventoryDropItemRequest(event, args)
    if (event == nil or event.data == nil) then
        return
    end
    local parsedData = json.decode(event.data)
    event.slot = tonumber(parsedData.slot)
    event.item = parsedData.item
    event.equipped = parsedData.equipped
    event.player_id = tonumber(event.PlayerID)
    if (event.slot == nil or event.item == nil or event.equipped == nil or not GameMode:IsValidBoolean(event.equipped) or event.player_id == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player == nil) then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil or not hero:IsAlive()) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    local itemInSlot = Inventory:GetItemInSlot(hero, event.equipped, event.slot)
    if (itemInSlot ~= event.item) then
        return
    end
    local itemStats = Inventory:GetItemStatsForHero(hero, event.equipped, event.slot)
    if (Inventory:CreateItemOnGround(hero, hero:GetAbsOrigin(), event.item, itemStats)) then
        Inventory:SetItemInSlot(hero, "", event.equipped, event.slot)
    end
end

function Inventory:SetItemEntityStats(item, itemStats)
    if (item) then
        item.inventoryStats = itemStats
    end
end

function Inventory:GetItemEntityStats(item)
    if (item and item.inventoryStats) then
        return item.inventoryStats
    end
    return nil
end

function Inventory:OnInventorySwapItemsRequest(event, args)
    if (event == nil or event.data == nil) then
        return
    end
    local parsedData = json.decode(event.data)
    event.fromslot = tonumber(parsedData.fromslot)
    event.inslot = tonumber(parsedData.inslot)
    event.player_id = tonumber(event.PlayerID)
    event.equipped = parsedData.equipped
    if (event.fromslot == nil or event.inslot == nil or event.player_id == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player == nil) then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil or not hero:IsAlive()) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    if (event.equipped == nil or not GameMode:IsValidBoolean(event.equipped)) then
        return
    end
    -- swap bottom slot with equipped slots
    if (event.equipped) then
        local itemFromSlot = Inventory:GetItemInSlot(hero, true, event.fromslot)
        local itemInSlot = Inventory:GetItemInSlot(hero, false, event.inslot)
        local statsFromSlot = Inventory:GetItemStatsForHero(hero, true, event.fromslot)
        local statsInSlot = Inventory:GetItemStatsForHero(hero, false, event.inslot)
        -- swap equipped item with empty bottom slot
        if (Inventory:IsItemNotEmpty(itemInSlot)) then
            Inventory:SetItemInSlot(hero, itemFromSlot, false, event.inslot, statsFromSlot)
            Inventory:SetItemInSlot(hero, itemInSlot, true, event.fromslot, statsInSlot)
        else
            Inventory:SetItemInSlot(hero, itemFromSlot, false, event.inslot, statsFromSlot)
            Inventory:SetItemInSlot(hero, "", true, event.fromslot, statsInSlot)
        end
    else
        -- swap in bottom slots
        local itemFromSlot = Inventory:GetItemInSlot(hero, false, event.fromslot)
        local itemInSlot = Inventory:GetItemInSlot(hero, false, event.inslot)
        local statsFromSlot = Inventory:GetItemStatsForHero(hero, false, event.fromslot)
        local statsInSlot = Inventory:GetItemStatsForHero(hero, false, event.inslot)
        Inventory:SetItemInSlot(hero, itemInSlot, false, event.fromslot, statsInSlot)
        Inventory:SetItemInSlot(hero, itemFromSlot, false, event.inslot, statsFromSlot)
    end
end

function Inventory:OnInventoryEquippedItemRightClick(event, args)
    if (event == nil) then
        return
    end
    event.inslot = tonumber(event.inslot)
    event.fromslot = tonumber(event.fromslot)
    event.player_id = event.PlayerID
    if (event.item == nil or event.fromslot == nil or event.player_id == nil or event.inslot == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player == nil) then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil or not hero:IsAlive()) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    local itemFromSlot = Inventory:GetItemInSlot(hero, true, event.fromslot)
    if (not itemFromSlot or itemFromSlot ~= event.item) then
        return
    end
    if (not Inventory:IsItemNotEmpty(Inventory:GetItemInSlot(hero, false, event.inslot))) then
        local statsFromSlot = Inventory:GetItemStatsForHero(hero, true, event.fromslot)
        Inventory:SetItemInSlot(hero, "", true, event.fromslot, {})
        Inventory:SetItemInSlot(hero, event.item, false, event.inslot, statsFromSlot)
    end
end

function Inventory:OnInventoryItemReplaceDialogRequest(event, args)
    if (event == nil) then
        return
    end
    event.inslot = tonumber(event.inslot)
    event.fromslot = tonumber(event.fromslot)
    if (event.item == nil or event.fromslot == nil or event.PlayerID == nil or event.inslot == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (player == nil) then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil or not hero:IsAlive()) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    local desiredItemSlot = Inventory:GetValidSlotForItem(event.item)
    if (desiredItemSlot == Inventory.slot.invalid) then
        return
    end
    if (desiredItemSlot ~= event.inslot) then
        return
    end
    local itemFromSlot = Inventory:GetItemInSlot(hero, false, event.fromslot)
    if (not itemFromSlot or itemFromSlot ~= event.item) then
        return
    end
    local itemInSlot = Inventory:GetItemInSlot(hero, true, desiredItemSlot)
    local statsInSlot = Inventory:GetItemStatsForHero(hero, true, desiredItemSlot)
    local statsFromSlot = Inventory:GetItemStatsForHero(hero, false, event.fromslot)
    Inventory:SetItemInSlot(hero, event.item, true, desiredItemSlot, statsFromSlot)
    Inventory:SetItemInSlot(hero, itemInSlot, false, event.fromslot, statsInSlot)
end

function Inventory:OnInventoryWindowOpenRequest(event, args)
    if (event ~= nil and event.PlayerID ~= nil) then
        local player = PlayerResource:GetPlayer(event.PlayerID)
        if player ~= nil then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_open_window_from_server", {})
        end
    end
end

function Inventory:OnInventoryWindowCloseRequest(event, args)
    if (event ~= nil and event.PlayerID ~= nil) then
        local player = PlayerResource:GetPlayer(event.PlayerID)
        if player ~= nil then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_close_window_from_server", {})
        end
    end
end

function Inventory:OnInventoryEquipItemRequest(event, args)
    if (event == nil) then
        return
    end
    event.slot = tonumber(event.slot)
    if (event.PlayerID == nil or event.item == nil or event.slot == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if player == nil then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil or not hero:IsAlive()) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    local desiredItemSlot = Inventory:GetValidSlotForItem(event.item)
    if (desiredItemSlot == Inventory.slot.invalid) then
        return
    end
    local itemInSlot = Inventory:GetItemInSlot(hero, false, event.slot)
    if (itemInSlot == event.item) then
        local statsFromSlot = Inventory:GetItemStatsForHero(hero, false, event.slot)
        Inventory:SetItemInSlot(hero, event.item, true, desiredItemSlot, statsFromSlot)
        Inventory:SetItemInSlot(hero, "", false, event.slot, {})
    end
end

function Inventory:SendUpdateInventorySlotRequest(hero, itemName, is_equipped, itemSlot, itemStats)
    if (hero ~= nil and itemName ~= nil and is_equipped ~= nil and itemSlot ~= nil) then
        local player = hero:GetPlayerOwner()
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_update_slot", { item = itemName, equipped = is_equipped, slot = itemSlot, stats = json.encode(itemStats) })
    end
end

function Inventory:GetItemStatValueFromRoll(roll, min, max)
    if (min == max) then
        return max
    end
    if (min < 0 and max >= 0) then
        return math.floor(min * roll)
    end
    if (min >= 0 and max > 0) then
        return math.floor(max * roll)
    end
    if (min < 0 and max < 0) then
        return math.floor(max * roll)
    end
    return min
end

function Inventory:LoadItemsFromSaveData(playerHero, itemData)
    if (not playerHero or not itemData) then
        return
    end
    for _, itemEntry in pairs(itemData.inventory) do
        if (itemEntry.name ~= "" and Inventory:IsItemNameValid(itemEntry.name) and itemEntry.slot ~= "unknown") then
            local itemStats = Inventory:GenerateStatsForItem(itemEntry.name, 1, 1)
            for _, itemStatEntry in pairs(itemStats) do
                for _, loadedItemStatEntry in pairs(itemEntry.stats) do
                    if (itemStatEntry.name == loadedItemStatEntry.name) then
                        itemStatEntry.value = Inventory:GetItemStatValueFromRoll(loadedItemStatEntry.roll, Inventory.itemsData[itemEntry.name].stats[loadedItemStatEntry.name].min, Inventory.itemsData[itemEntry.name].stats[loadedItemStatEntry.name].max)
                        break
                    end
                end
            end
            local itemSlot = SaveLoad:GetItemSlotIdByName(itemEntry.slot, false)
            if (not itemSlot) then
                return
            end
            Inventory:SetItemInSlot(playerHero, itemEntry.name, false, itemSlot, itemStats)
        end
    end
    for _, itemEntry in pairs(itemData.equipped) do
        if (itemEntry.name ~= "" and Inventory:IsItemNameValid(itemEntry.name) and itemEntry.slot ~= "unknown") then
            local itemStats = Inventory:GenerateStatsForItem(itemEntry.name, 1, 1)
            for _, itemStatEntry in pairs(itemStats) do
                for _, loadedItemStatEntry in pairs(itemEntry.stats) do
                    if (itemStatEntry.name == loadedItemStatEntry.name) then
                        itemStatEntry.value = Inventory:GetItemStatValueFromRoll(loadedItemStatEntry.roll, Inventory.itemsData[itemEntry.name].stats[loadedItemStatEntry.name].min, Inventory.itemsData[itemEntry.name].stats[loadedItemStatEntry.name].max)
                        break
                    end
                end
            end
            local itemSlot = SaveLoad:GetItemSlotIdByName(itemEntry.slot, true)
            if (not itemSlot) then
                return
            end
            Inventory:SetItemInSlot(playerHero, itemEntry.name, true, itemSlot, itemStats)
        end
    end
end

if not Inventory.initialized then
    Inventory:Init()
    Inventory.initialized = true
end