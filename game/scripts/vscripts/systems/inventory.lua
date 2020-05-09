if Inventory == nil then
    _G.Inventory = class({})
end

-- items database
function Inventory:SetupItems()
    Inventory:RegisterItemSlot("item_claymore", self.rarity.common, self.slot.mainhand)
    Inventory:RegisterItemSlot("item_broadsword", self.rarity.cursed, self.slot.offhand)
    Inventory:RegisterItemSlot("item_chainmail", self.rarity.rare, self.slot.body)
    Inventory:RegisterItemSlot("item_third_eye", self.rarity.cursed, self.slot.ring1)
end

function Inventory:Init()
    self.items_data = {}
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
    Inventory:SetupItems()
    Inventory:InitPanaromaEvents()
end

--  internal stuff to make all work
--- Return item slot if it possible to add item or Inventory.slot.invalid if impossible (no space)
---@param hero CDOTA_BaseNPC_Hero
---@param item string
---@return number
function Inventory:AddItem(hero, item)
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
            if (Inventory:GetItemInSlot(hero, false, i) == "") then
                Inventory:SetItemInSlot(hero, item, false, i)
                return i
            end
        end
        return Inventory.slot.invalid
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
                return hero.inventory.equipped_items[slot]
            else
                return hero.inventory.items[slot]
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
function Inventory:SetItemInSlot(hero, item, is_equipped, slot)
    slot = tonumber(slot)
    if (hero ~= nil and item ~= nil and is_equipped ~= nil and slot ~= nil) then
        if (Inventory:IsHeroHaveInventory(hero) and Inventory:IsSlotValid(slot, is_equipped)) then
            if (is_equipped) then
                if (hero.inventory.equipped_modifiers[slot] ~= nil and not hero.inventory.equipped_modifiers[slot]:IsNull()) then
                    hero.inventory.equipped_modifiers[slot]:Destroy()
                end
                if (item ~= "") then
                    local modifierTable = {}
                    modifierTable.ability = nil
                    modifierTable.target = hero
                    modifierTable.caster = hero
                    modifierTable.modifier_name = "modifier_inventory_" .. item
                    modifierTable.duration = -1
                    hero.inventory.equipped_modifiers[slot] = GameMode:ApplyBuff(modifierTable)
                end
                hero.inventory.equipped_items[slot] = item
            else
                hero.inventory.items[slot] = item
            end
        end
        Inventory:SendUpdateInventorySlotRequest(hero, item, is_equipped, slot)
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
        hero.inventory.equipped_modifiers = {}
        for i = 0, Inventory.max_stored_items do
            hero.inventory.items[i] = ""
        end
        for i = 0, Inventory.slot.last do
            hero.inventory.equipped_items[i] = ""
        end
        Inventory:AddItem(hero, "item_claymore")
        Inventory:AddItem(hero, "item_claymore")
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
function Inventory:RegisterItemSlot(itemName, itemRarity, itemSlot)
    if (itemName ~= nil and itemSlot ~= nil and itemRarity ~= nil) then
        if (string.len(itemName) == 0) then
            DebugPrint("[INVENTORY] Item name can't be empty.")
            return
        end
        if (not Inventory:IsSlotValid(itemSlot, true)) then
            DebugPrint("[INVENTORY] Item slot (" .. itemSlot .. ") invalid.")
            return
        end
        for _, value in pairs(Inventory.items_data) do
            if value.item == itemName then
                DebugPrint("[INVENTORY] Bad attempt to add item \"" .. itemName .. "\" for slot " .. itemSlot .. " (already exists).")
                return
            end
        end
        if (itemRarity < 0 or itemRarity > Inventory.rarity.max) then
            DebugPrint("[INVENTORY] Bad attempt to add item \"" .. itemName .. "\" for slot " .. itemSlot .. " with rarity " .. itemRarity .. " (unknown rarity).")
            return
        end
        table.insert(Inventory.items_data, { item = itemName, slot = itemSlot, rarity = itemRarity })
    else
        DebugPrint("[INVENTORY] Bad attempt to add item (something is nil)");
        DebugPrint("itemName");
        DebugPrint(itemName);
        DebugPrint("itemRarity");
        DebugPrint(itemRarity);
        DebugPrint("itemSlot");
        DebugPrint(itemSlot);
    end
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
    --local abilitySpecial = ability:GetAbilityKeyValues()["AbilitySpecial"]
    local itemsData = {}
    for _, value in pairs(Inventory.items_data) do
        table.insert(itemsData, { item = value.item, slot = value.slot, rarity = value.rarity })
    end
    CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_item_slots", { items_data = json.encode(itemsData) })
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
                    if (itemInInventorySlot ~= "") then
                        Inventory:SendUpdateInventorySlotRequest(hero, itemInInventorySlot, false, i)
                    end
                end
                for i = 0, Inventory.slot.last do
                    local itemInInventoryEquippedSlot = Inventory:GetItemInSlot(hero, true, i)
                    if (itemInInventoryEquippedSlot ~= "") then
                        Inventory:SendUpdateInventorySlotRequest(hero, hero.inventory.equipped_items[i], true, i)
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
        if (itemInSlot == "") then
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
    if (Inventory:GetItemInSlot(hero, false, event.inslot) == "") then
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
    if (Inventory:GetItemInSlot(hero, true, desiredItemSlot) == "") then
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

if not Inventory.initialized then
    Inventory:Init()
    Inventory.initialized = true
end