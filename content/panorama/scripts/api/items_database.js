// adding slots here require change GetItemRarityName()
var SLOT_MAINHAND = 0
var SLOT_BODY = 1
var SLOT_LEGS = 2
var SLOT_BOOTS = 3
var SLOT_HELMET = 4
var SLOT_OFFHAND = 5
var SLOT_CAPE = 6
var SLOT_SHOULDER = 7
var SLOT_GLOVES = 8
var SLOT_RING = 9
var SLOT_BELT = 10
var SLOT_AMULET = 11
var SLOT_LAST = 11

// adding rarity here require change GetItemRarityName()
var ITEM_RARITY_COMMON = 0;
var ITEM_RARITY_UNCOMMON = 1;
var ITEM_RARITY_RARE = 2;
var ITEM_RARITY_UNIQUE_RARE = 3;
var ITEM_RARITY_LEGENDARY = 4;
var ITEM_RARITY_UNIQUE_LEGENDARY = 5;
var ITEM_RARITY_CURSED_LEGENDARY = 6;
var ITEM_RARITY_ANCIENT = 7;
var ITEM_RARITY_UNIQUE_ANCIENT = 8;
var ITEM_RARITY_CURSED_ANCIENT = 9;
var ITEM_RARITY_IMMORTAL = 10;
var ITEM_RARITY_UNIQUE_IMMORTAL = 11;
var ITEM_RARITY_CURSED_IMMORTAL = 12;

// Internal stuff
var ItemsDatabase = {};

ItemsDatabase.GetItemRarityName = function(rarity) {
	switch(rarity) {
        case ITEM_RARITY_COMMON:
			return "#DOTA_Inventory_rarity_common";
			break;
        case ITEM_RARITY_UNCOMMON:
			return "#DOTA_Inventory_rarity_uncommon";
			break;
        case ITEM_RARITY_RARE:
			return "#DOTA_Inventory_rarity_rare";
			break;
        case ITEM_RARITY_UNIQUE_RARE:
			return "#DOTA_Inventory_rarity_unique_rare";
			break;
        case ITEM_RARITY_LEGENDARY:
			return "#DOTA_Inventory_rarity_legendary";
			break;
        case ITEM_RARITY_UNIQUE_LEGENDARY:
			return "#DOTA_Inventory_rarity_unique_legendary";
			break;
        case ITEM_RARITY_CURSED_LEGENDARY:
			return "#DOTA_Inventory_rarity_cursed_legendary";
			break;
        case ITEM_RARITY_ANCIENT:
			return "#DOTA_Inventory_rarity_ancient";
			break;
        case ITEM_RARITY_UNIQUE_ANCIENT:
			return "#DOTA_Inventory_rarity_unique_ancient";
			break;
        case ITEM_RARITY_CURSED_ANCIENT:
			return "#DOTA_Inventory_rarity_cursed_ancient";
			break;
        case ITEM_RARITY_IMMORTAL:
			return "#DOTA_Inventory_rarity_immortal";
			break;
        case ITEM_RARITY_UNIQUE_IMMORTAL:
			return "#DOTA_Inventory_rarity_unique_immortal";
			break;
        case ITEM_RARITY_CURSED_IMMORTAL:
			return "#DOTA_Inventory_rarity_cursed_immortal";
			break;
		default:
			return "Unknown";
	}

}

ItemsDatabase.GetItemSlotName = function(slot) {
	switch(slot) {
		case SLOT_MAINHAND:
			return "#DOTA_Inventory_slot_mainhand";
			break;
		case SLOT_BODY:
			return "#DOTA_Inventory_slot_body";
			break;
		case SLOT_LEGS:
			return "#DOTA_Inventory_slot_legs";
			break;
		case SLOT_BOOTS:
			return "#DOTA_Inventory_slot_boots";
			break;
		case SLOT_HELMET:
			return "#DOTA_Inventory_slot_helmet";
			break;
		case SLOT_OFFHAND:
			return "#DOTA_Inventory_slot_offhand";
			break;
		case SLOT_CAPE:
			return "#DOTA_Inventory_slot_cape";
			break;
		case SLOT_SHOULDER:
			return "#DOTA_Inventory_slot_shoulder";
			break;
		case SLOT_GLOVES:
			return "#DOTA_Inventory_slot_gloves";
			break;
		case SLOT_RING:
			return "#DOTA_Inventory_slot_ring";
			break;
		case SLOT_BELT:
			return "#DOTA_Inventory_slot_belt";
			break;
		case SLOT_AMULET:
			return "#DOTA_Inventory_slot_amulet";
			break;
		default:
			return "Unknown";
	}
}

ItemsDatabase.GetItemRarity = function(itemname) {
	for(var i = 0; i < ItemsDatabase.data.length; i++) {
		if(ItemsDatabase.data[i].item == itemname) {
			return ItemsDatabase.data[i].rarity;
		}
	}
	return -1;
}

ItemsDatabase.GetItemSlot = function(itemname) {
	for(var i = 0; i < ItemsDatabase.data.length; i++) {
		if(ItemsDatabase.data[i].item == itemname) {
			return ItemsDatabase.data[i].slot;
		}
	}
	return -1;
}

ItemsDatabase.GetItemQuality = function (itemName, itemStats) {
    var totalQuality = itemStats.length;
    var currentQuality = 0;
    for(var i = 0; i < itemStats.length; i++) {
        var minMaxValues = GetMinMaxValueForItemStat(itemName, itemStats[i].name);
        if(minMaxValues.length > 0) {
            currentQuality += CalculateItemStatRoll(itemStats[i].value, minMaxValues[0], minMaxValues[1], itemName, itemStats[i].name);
        } else {
            totalQuality = totalQuality - 1;
            $.Msg("[ITEMS] There are error receiving min & max values for " + itemName + " and stat " + itemStats[i].name + ". Ignoring.");
        }
    }
    if(totalQuality > 0) {
        totalQuality = currentQuality / totalQuality;
    } else {
        totalQuality = 1;
    }
    return Math.round(totalQuality * 10000) / 100;
}

function GetMinMaxValueForItemStat(itemName, itemStat) {
    var result = [];
    for(var i = 0; i < ItemsDatabase.data.length; i++) {
        if(ItemsDatabase.data[i].item == itemName && ItemsDatabase.data[i].stats[itemStat] != null) {
            result[0] = ItemsDatabase.data[i].stats[itemStat].min;
            result[1] = ItemsDatabase.data[i].stats[itemStat].max;
            break;
        }
    }
    return result
}

function CalculateItemStatRoll(value, min, max, itemName, itemStat) {
	if(min == max) {
		return 1;
	}
    if(min < 0 && max >= 0) {
        return 1 - (value / min);
    }
    if(min >= 0 && max > 0) {
        return (value - min) / (max - min);
    }
    if(min < 0 && max < 0) {
        return 1 - ((value-max)/(min-max));
    }
    $.Msg("[ITEMS] Unable to calculate roll value for " + itemName + " and stat " + itemStats[i].name + ". Using 0 to fix that. Value = " + value + ", min = " + min + ", max = " + max);
    return 0;
}

function OnItemsDataRequest(event) {
	ItemsDatabase.data = ItemsDatabase.data.concat(JSON.parse(event.items_data));
}

(function() {
  GameUI.CustomUIConfig().ItemsDatabase = ItemsDatabase;
  ItemsDatabase.data = [];
  GameEvents.Subscribe("rpg_inventory_items_data", OnItemsDataRequest);
})();