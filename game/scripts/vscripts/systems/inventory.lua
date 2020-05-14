if Inventory == nil then
    _G.Inventory = class({})
end
-- for test only, remove later pls
if (IsServer()) then
    ListenToGameEvent("player_chat", function(event)
        if (event.text == "-additem") then
            local player = PlayerResource:GetPlayer(event.playerid)
            local hero = player:GetAssignedHero()
            Inventory:AddItem(hero, "item_claymore_custom")
        end
    end, nil)
end

-- items database
function Inventory:SetupItems()
    Inventory:RegisterItemSlot("item_claymore_custom", self.rarity.common, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_broadsword", self.rarity.cursed, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_chainmail", self.rarity.rare, self.slot.body, 5)
    Inventory:RegisterItemSlot("item_third_eye", self.rarity.cursed, self.slot.ring1, 5)
end

function Inventory:Init()
    self.maxItemsPerRequest = 10
    -- slots count, change here require same changes in client side inventory.js
    self.max_stored_items = 14 * 7
    -- slot types
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
    self.slot.ring1 = 9
    self.slot.belt = 10
    self.slot.ring2 = 11
    -- latest slot id for internal stuff
    self.slot.last = 11
    -- Invalid slot id for internal stuff
    self.slot.invalid = -1
    -- item types
    self.rarity = {}
    self.rarity.common = 0
    self.rarity.rare = 1
    self.rarity.cursed = 2
    -- latest rarity id for internal stuff
    self.rarity.max = 2
    self.items_data = {}
    self.items_kv = LoadKeyValues("scripts/npc/npc_items_custom.txt")
    Inventory:SetupItems()
    Inventory:InitPanaromaEvents()
end

--  internal stuff to make all work
--- Return item slot if it possible to add item or Inventory.slot.invalid if impossible (no space)
---@param hero CDOTA_BaseNPC_Hero
---@param item string
---@return number
function Inventory:AddItem(hero, item, itemStats)
    if (hero ~= nil and item ~= nil and hero.inventory ~= nil) then
        local IsItemValid = false
        for _, value in pairs(Inventory.items_data) do
            if value.item == item then
                IsItemValid = true
                break
            end
        end
        if (not IsItemValid) then
            DebugPrint("[INVENTORY] Attempt to add unknown item (" .. item .. ").")
            return Inventory.slot.invalid
        end
        for i = 0, Inventory.max_stored_items do
            if (not Inventory:IsItemNotEmpty(Inventory:GetItemInSlot(hero, false, i))) then
                if (not itemStats) then
                    local difficulty = 1
                    itemStats = Inventory:GenerateStatsForItem(item, difficulty)
                end
                Inventory:SetItemInSlot(hero, item, false, i, itemStats)
                return i
            end
        end
        return Inventory.slot.invalid
    end
end

---@param item string
---@param difficulty number
---@return number
function Inventory:GenerateStatsForItem(item, difficulty)
    local result = {}
    difficulty = tonumber(difficulty)
    if (not item or not type(item) == "string" or not difficulty) then
        return result
    end
    local itemStats = Inventory:GetPossibleItemStats(item)
    if (not itemStats) then
        return result
    end
    local itemDifficulty = Inventory:GetItemDifficulty(item)
    local minRoll = 0
    if (itemDifficulty > difficulty * 0.5 or math.abs(difficulty * 0.5 - itemDifficulty) < 0.01) then
        minRoll = 0.5
    end
    if (difficulty > itemDifficulty or math.abs(difficulty - itemDifficulty) < 0.01) then
        minRoll = 1
    end
    for _, stat in pairs(itemStats) do
        local value = Inventory:PerformRoll(stat.min, stat.max, stat.type, minRoll)
        table.insert(result, { name = stat.name, value = value })
    end
    return result
end

function Inventory:RoundStatValue(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

function Inventory:PerformRoll(min, max, type, minRoll)
    min = min + ((max - min) * minRoll)
    if (type == "FIELD_INTEGER") then
        return math.random(math.floor(min), max)
    end
    if (type == "FIELD_FLOAT") then
        return Inventory:RoundStatValue((min + math.random() * (max - min)) * 100) / 100
    end
    DebugPrint("[INVENTORY] Got unknown role type " .. tostring(type) .. ". Wtf?")
    return 0
end

---@param item string
---@param difficulty number
---@return table
function Inventory:GetPossibleItemStats(item)
    if (not item or not type(item) == "string") then
        return nil
    end
    for _, itemData in pairs(Inventory.items_data) do
        if (itemData.item == item) then
            return itemData.stats
        end
    end
    return nil
end

---@param hero CDOTA_BaseNPC_Hero
---@return boolean
function Inventory:IsHeroHaveInventory(hero)
    if (hero ~= nil and hero.inventory ~= nil and hero.inventory.items ~= nil and hero.inventory.equipped_items ~= nil) then
        return true
    end
    return false
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
            if (slot > Inventory.slot.invalid and slot < Inventory.max_stored_items) then
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
---@return boolean
function Inventory:SetItemInSlot(hero, item, is_equipped, slot, stats)
    slot = tonumber(slot)
    if (hero ~= nil and item ~= nil and is_equipped ~= nil and slot ~= nil) then
        if (Inventory:IsHeroHaveInventory(hero) and Inventory:IsSlotValid(slot, is_equipped)) then
            if (is_equipped) then
                if (hero.inventory.equipped_items[slot].modifier ~= nil and not hero.inventory.equipped_items[slot].modifier:IsNull()) then
                    hero.inventory.equipped_items[slot].modifier:Destroy()
                end
                if (Inventory:IsItemNotEmpty(item)) then
                    local modifierTable = {}
                    modifierTable.ability = nil
                    modifierTable.target = hero
                    modifierTable.caster = hero
                    modifierTable.modifier_name = "modifier_inventory_" .. item
                    modifierTable.duration = -1
                    hero.inventory.equipped_items[slot].modifier = GameMode:ApplyBuff(modifierTable)
                end
                hero.inventory.equipped_items[slot].name = item
            else
                hero.inventory.items[slot].name = item
            end
            Inventory:SendUpdateInventorySlotRequest(hero, item, is_equipped, slot)
        end
    end
end

--- Return slot id for that item or Inventory.slot.invalid
---@param item string
---@return number
function Inventory:GetValidSlotForItem(item)
    if (item ~= nil) then
        for i = 1, #Inventory.items_data do
            if (Inventory.items_data[i].item == item) then
                return Inventory.items_data[i].slot
            end
        end
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
        if (slot > Inventory.slot.invalid) then
            for i = 1, #Inventory.items_data do
                if (Inventory.items_data[i].item == item and Inventory.items_data[i].slot == slot) then
                    return true
                end
            end
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
        for i = 0, Inventory.max_stored_items do
            hero.inventory.items[i] = {}
            hero.inventory.items[i].name = ""
        end
        for i = 0, Inventory.slot.last do
            hero.inventory.equipped_items[i] = {}
            hero.inventory.equipped_items[i].name = ""
        end
        Inventory:AddItem(hero, "item_claymore_custom")
        Inventory:AddItem(hero, "item_claymore_custom")
        Inventory:AddItem(hero, "item_broadsword")
        Inventory:AddItem(hero, "item_broadsword")
        Inventory:AddItem(hero, "item_chainmail")
        Inventory:AddItem(hero, "item_third_eye")
        Inventory:AddItem(hero, "item_chainmail")
        Inventory:AddItem(hero, "item_third_eye")
    end
end

---@param itemName string
---@param itemRarity number
---@param itemSlot number
function Inventory:RegisterItemSlot(itemName, itemRarity, itemSlot, itemDifficulty)
    if (itemName ~= nil and itemSlot ~= nil and itemRarity ~= nil) then
        if (not type(itemName) == "string" or string.len(itemName) == 0) then
            DebugPrint("[INVENTORY] Item name can't be empty and must be string.")
            return
        end
        if (not Inventory:IsSlotValid(itemSlot, true)) then
            DebugPrint("[INVENTORY] Item slot (" .. itemSlot .. ") invalid.")
            return
        end
        for _, value in pairs(Inventory.items_data) do
            if value.item == itemName then
                DebugPrint("[INVENTORY] Bad attempt to register item \"" .. tostring(itemName) .. "\" for slot " .. tostring(itemSlot) .. " (already exists).")
                return
            end
        end
        if (itemRarity < 0 or itemRarity > Inventory.rarity.max) then
            DebugPrint("[INVENTORY] Bad attempt to register item \"" .. tostring(itemName) .. "\" for slot " .. tostring(itemSlot) .. " with rarity " .. tostring(itemRarity) .. " (unknown rarity).")
            return
        end
        itemDifficulty = tonumber(itemDifficulty)
        if (not itemDifficulty or itemDifficulty < 0) then
            DebugPrint("[INVENTORY] Bad attempt to register item \"" .. tostring(itemName) .. "\" for slot " .. tostring(itemSlot) .. " with rarity " .. tostring(itemRarity) .. " (item difficulty can't be nil or negative).")
            return
        end
        local itemStats = {}
        if (Inventory.items_kv[itemName] and Inventory.items_kv[itemName]["AbilitySpecial"]) then
            local itemStatsNames = Inventory:GetItemStatsFromKeyValues(Inventory.items_kv[itemName]["AbilitySpecial"], itemName)
            for _, stat in pairs(itemStatsNames) do
                local statEntry = Inventory:GenerateItemStatsEntry(Inventory.items_kv[itemName]["AbilitySpecial"], stat)
                if (statEntry and stat.type) then
                    statEntry.type = stat.type
                    table.insert(itemStats, statEntry)
                else
                    DebugPrint("[INVENTORY] Can't find min and max values or type for " .. tostring(stat.name) .. " in item " .. tostring(itemName) .. ". Ignoring.")
                end
            end
        end
        table.insert(Inventory.items_data, { item = itemName, slot = itemSlot, rarity = itemRarity, stats = itemStats, difficulty = itemDifficulty })
    else
        DebugPrint("[INVENTORY] Bad attempt to add item (something is nil)");
        DebugPrint("itemName", itemName);
        DebugPrint("itemRarity", itemRarity);
        DebugPrint("itemSlot", itemSlot);
    end
end

function Inventory:GetItemDifficulty(item)
    local result = 1
    if (not item or not type(item) == "string") then
        return result
    end
    for _, itemData in pairs(Inventory.items_data) do
        if (itemData.item == item) then
            return itemData.difficulty
        end
    end
    return result
end

function Inventory:GenerateItemStatsEntry(statsTable, stat)
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
        result = { name = stat.name, min = min, max = max }
    end
    return result
end

function Inventory:GetItemStatsFromKeyValues(statsTable, itemName)
    local result = {}
    for _, statEntry in pairs(statsTable) do
        local entrySize = Inventory:GetTableSize(statEntry)
        if (entrySize == 2) then
            local entryType
            local entry
            for k, v in pairs(statEntry) do
                if (k == "var_type") then
                    entryType = v
                elseif (string.match(k, "_min")) then
                    entry = string.gsub(k, "_min", "")
                end
            end
            if (entry and entryType) then
                table.insert(result, { name = entry, type = entryType })
            end
        else
            DebugPrint("[INVENTORY] Expected two key-value pairs from ability special for item " .. tostring(itemName) .. ", but received " .. tostring(entrySize) .. ". Ignoring.")
            DebugPrintTable(statEntry)
        end
    end
    return result
end

function Inventory:GetTableSize(kv)
    local count = 0
    for _, __ in pairs(kv) do
        count = count + 1
    end
    return count
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
    local itemsDataLength = #Inventory.items_data
    local currentItem = 1
    while currentItem <= itemsDataLength do
        local itemsData = {}
        local maxItemId = math.min(currentItem + self.maxItemsPerRequest, itemsDataLength)
        for i = currentItem, maxItemId do
            table.insert(itemsData, { item = Inventory.items_data[i].item, slot = Inventory.items_data[i].slot, rarity = Inventory.items_data[i].rarity, stats = Inventory.items_data[i].stats })
        end
        currentItem = currentItem + self.maxItemsPerRequest + 1
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_items_data", { items_data = json.encode(itemsData) })
    end
end

function Inventory:OnInventoryItemsAndRestDataRequest(event, args)
    if (event == nil or event.player_id == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
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
                for i = 0, Inventory.max_stored_items do
                    local itemInInventorySlot = Inventory:GetItemInSlot(hero, false, i)
                    if (Inventory:IsItemNotEmpty(itemInInventorySlot)) then
                        Inventory:SendUpdateInventorySlotRequest(hero, itemInInventorySlot, false, i)
                    end
                end
                for i = 0, Inventory.slot.last do
                    local itemInInventoryEquippedSlot = Inventory:GetItemInSlot(hero, true, i)
                    if (Inventory:IsItemNotEmpty(itemInInventoryEquippedSlot)) then
                        Inventory:SendUpdateInventorySlotRequest(hero, itemInInventoryEquippedSlot, true, i)
                    end
                end
            end)
end

function Inventory:OnInventoryItemPickedFromGround(event)
    if (event ~= nil and event.item ~= nil and event.itemEntity ~= nil and event.player_id ~= nil) then
        local player = PlayerResource:GetPlayer(event.player_id)
        if (player ~= nil) then
            local hero = player:GetAssignedHero()
            if (hero ~= nil) then
                if (Inventory:IsHeroHaveInventory(hero)) then
                    if (event.itemEntity:GetPurchaser() == hero and Inventory:AddItem(hero, event.item) ~= Inventory.slot.invalid) then
                        event.itemEntity:Destroy()
                    else
                        hero:DropItemAtPositionImmediate(event.itemEntity, hero:GetAbsOrigin())
                    end
                end
            end
        end
    end
end

function Inventory:OnInventoryDropItemRequest(event, args)
    if (event == nil or event.data == nil) then
        return
    end
    local parsedData = json.decode(event.data)
    event.slot = tonumber(parsedData.slot)
    event.item = parsedData.item
    event.equipped = parsedData.equipped
    event.player_id = tonumber(parsedData.player_id)
    if (event.slot == nil or event.item == nil or event.equipped == nil or not GameMode:IsValidBoolean(event.equipped) or event.player_id == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player == nil) then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    if (Inventory:GetItemInSlot(hero, event.equipped, event.slot) ~= event.item) then
        return
    end
    local item = CreateItem(event.item, hero, hero)
    local positionOnGround = hero:GetAbsOrigin()
    local itemOnGround = CreateItemOnPositionSync(positionOnGround, item)
    if (itemOnGround == nil) then
        item:Destroy()
        return
    end
    item:SetPurchaser(hero)
    Inventory:SetItemInSlot(hero, "", event.equipped, event.slot)
end

function Inventory:OnInventorySwapItemsRequest(event, args)
    if (event == nil or event.data == nil) then
        return
    end
    local parsedData = json.decode(event.data)
    event.fromslot = tonumber(parsedData.fromslot)
    event.inslot = tonumber(parsedData.inslot)
    event.player_id = tonumber(parsedData.player_id)
    event.equipped = parsedData.equipped
    if (event.fromslot == nil or event.inslot == nil or event.player_id == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player == nil) then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil) then
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
        --local desiredItemSlotForFromItem = Inventory:GetValidSlotForItem(itemFromSlot)
        --local desiredItemSlotForInItem = Inventory:GetValidSlotForItem(itemInSlot)
        -- swap equipped item with empty bottom slot
        if (not Inventory:IsItemNotEmpty(itemInSlot)) then
            Inventory:SetItemInSlot(hero, "", true, event.fromslot)
            Inventory:SetItemInSlot(hero, itemFromSlot, false, event.inslot)
        else
            -- swap equipped item with not empty bottom slot (conflict)
            local event_data = {
                inslot = event.fromslot,
                fromslot = event.inslot,
                item = itemInSlot,
                player_id = event.player_id
            }
            Inventory:OnInventoryItemReplaceDialogRequest(event_data, nil)
        end
    else
        -- swap in bottom slots
        local itemFromSlot = Inventory:GetItemInSlot(hero, false, event.fromslot)
        local itemInSlot = Inventory:GetItemInSlot(hero, false, event.inslot)
        Inventory:SetItemInSlot(hero, itemFromSlot, false, event.inslot)
        Inventory:SetItemInSlot(hero, itemInSlot, false, event.fromslot)
    end
end

function Inventory:OnInventoryEquippedItemRightClick(event, args)
    if (event == nil) then
        return
    end
    event.inslot = tonumber(event.inslot)
    event.fromslot = tonumber(event.fromslot)
    if (event.item == nil or event.fromslot == nil or event.player_id == nil or event.inslot == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player == nil) then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    if (Inventory:GetItemInSlot(hero, true, event.fromslot) ~= event.item) then
        return
    end
    if (not Inventory:IsItemNotEmpty(Inventory:GetItemInSlot(hero, false, event.inslot))) then
        Inventory:SetItemInSlot(hero, "", true, event.fromslot)
        Inventory:SetItemInSlot(hero, event.item, false, event.inslot)
    end
end

function Inventory:OnInventoryItemReplaceDialogRequest(event, args)
    if (event == nil) then
        return
    end
    event.inslot = tonumber(event.inslot)
    event.fromslot = tonumber(event.fromslot)
    if (event.item == nil or event.fromslot == nil or event.player_id == nil or event.inslot == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player == nil) then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil) then
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
    if (Inventory:GetItemInSlot(hero, false, event.fromslot) ~= event.item) then
        return
    end
    if (not Inventory:IsItemNotEmpty(Inventory:GetItemInSlot(hero, true, desiredItemSlot))) then
        Inventory:SetItemInSlot(hero, event.item, true, desiredItemSlot)
        Inventory:SetItemInSlot(hero, "", false, event.fromslot)
    else
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_start_item_replace_dialog_from_server", { player_id = event.player_id, item = event.item, slot = event.fromslot })
    end
end

function Inventory:OnInventoryWindowOpenRequest(event, args)
    if (event ~= nil and event.player_id ~= nil) then
        local player = PlayerResource:GetPlayer(event.player_id)
        if player ~= nil then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_open_window_from_server", {})
        end
    end
end

function Inventory:OnInventoryWindowCloseRequest(event, args)
    if (event ~= nil and event.player_id ~= nil) then
        local player = PlayerResource:GetPlayer(event.player_id)
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
    if (event.player_id == nil or event.item == nil or event.slot == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if player == nil then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    local desiredItemSlot = Inventory:GetValidSlotForItem(event.item)
    if (desiredItemSlot == Inventory.slot.invalid) then
        return
    end
    if (Inventory:GetItemInSlot(hero, false, event.slot) == event.item) then
        Inventory:SetItemInSlot(hero, event.item, true, desiredItemSlot)
        Inventory:SetItemInSlot(hero, "", false, event.slot)
    end
end

function Inventory:SendUpdateInventorySlotRequest(hero, itemName, is_equipped, itemSlot)
    if (hero ~= nil and itemName ~= nil and is_equipped ~= nil and itemSlot ~= nil) then
        local player = hero:GetPlayerOwner()
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_update_slot", { item = itemName, equipped = is_equipped, slot = itemSlot })
    end
end

Inventory.initialized = nil

if not Inventory.initialized then
    Inventory:Init()
    Inventory.initialized = true
end