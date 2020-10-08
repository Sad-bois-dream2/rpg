var ItemsDatabase = GameUI.CustomUIConfig().ItemsDatabase;

var TooltipManager = {};

// Items tooltip
var TOOLTIP_PANEL = 0;
var TOOLTIP_IMAGE = 1;
var TOOLTIP_NAME_LABEL = 2;
var TOOLTIP_RARITY_LABEL = 3;
var TOOLTIP_TYPE_LABEL = 4;
var TOOLTIP_DESCRIPTION_LABEL = 5;
var TOOLTIP_QUALITY_LABEL = 6;
var TOOLTIP_STATS_CONTAINER = 7;

TooltipManager.ShowItemTooltip = function(itemName, itemStats) {
	var position = GameUI.GetCursorPosition();
	var itemNameTooltip = $.Localize("#DOTA_Tooltip_Ability_"+itemName);
	var itemDesiredSlot = ItemsDatabase.GetItemSlot(itemName);
	var itemRarity = ItemsDatabase.GetItemRarityName(ItemsDatabase.GetItemRarity(itemName));
	var itemType = ItemsDatabase.GetItemSlotName(itemDesiredSlot);
	var itemDescription = $.Localize("#DOTA_Tooltip_Ability_" + itemName + "_Description");
	var itemQuality = $.Localize("#DOTA_Inventory_quality").replace("%VALUE%", ItemsDatabase.GetItemQuality(itemName, itemStats));
	var itemStatsCount = itemStats.length;
	var missedLabels = itemStatsCount - tooltip[TOOLTIP_STATS_CONTAINER].GetChildCount();
	if(missedLabels > 0) {
	    for(var i = 0; i < missedLabels; i++) {
	        var statsLabel = $.CreatePanel("Label", tooltip[TOOLTIP_STATS_CONTAINER], "");
               statsLabel.html = true;
               statsLabel.style.visibility = "collapse";
               statsLabels.push(statsLabel);
	    }
	}
	UpdateItemTooltip(itemName, itemNameTooltip, itemRarity, itemType, itemDescription, itemQuality, itemStats, position[0], position[1]);
}

function UpdateItemTooltip(icon, name, rarity, type, description, quality, stats, x, y) {
    var itemTooltip = GameUI.CustomUIConfig().TooltipManager.itemTooltipPanel;
    itemTooltip[TOOLTIP_IMAGE].itemname = icon;
	itemTooltip[TOOLTIP_NAME_LABEL].text = name.toUpperCase();
	itemTooltip[TOOLTIP_RARITY_LABEL].text = rarity;
	itemTooltip[TOOLTIP_TYPE_LABEL].text = type;
    if(description.toLowerCase().includes("dota_tooltip") || description.length == 0) {
        itemTooltip[TOOLTIP_DESCRIPTION_LABEL].style.visibility = "collapse";
    } else {
        itemTooltip[TOOLTIP_DESCRIPTION_LABEL].style.visibility = "visible";
    }
	itemTooltip[TOOLTIP_DESCRIPTION_LABEL].text = description;
	itemTooltip[TOOLTIP_QUALITY_LABEL].text = quality;
	if(itemTooltip[TOOLTIP_PANEL].actuallayoutwidth + x > Game.GetScreenWidth()) {
	    x -= itemTooltip[TOOLTIP_PANEL].actuallayoutwidth;
	}
	if(tooltip[TOOLTIP_PANEL].actuallayoutheight + y > Game.GetScreenHeight()) {
	    y -= itemTooltip[TOOLTIP_PANEL].actuallayoutheight;
	}
	itemTooltip[TOOLTIP_PANEL].style.marginLeft = x + "px";
	itemTooltip[TOOLTIP_PANEL].style.marginTop = y + "px";
	itemTooltip[TOOLTIP_PANEL].style.visibility = "visible";
	var latestStatId = 0;
	for(var i = 0; i < stats.length; i++) {
	    var statName = $.Localize("#DOTA_Tooltip_Ability_"+icon+"_"+stats[i].name);
	    var statValue = stats[i].value;
	    var IsPercent = (statName.charAt(0) == "%");
        if(IsPercent) {
            statName = statName.slice(1, statName.length);
            statValue += "%";
        }
	    statsLabels[i].text = statName + statValue;
	    statsLabels[i].style.visibility = "visible";
	    latestStatId++;
	}
	for(var i = latestStatId; i < itemTooltip[TOOLTIP_STATS_CONTAINER].GetChildCount(); i++) {
		statsLabels[i].style.visibility = "collapse";
	}
}

function CreateItemTooltip() {
    var root = $.GetContextPanel();
    var itemTooltipRoot = root.FindChildTraverse("ItemTooltipHeader");
    if(itemTooltipRoot) {
        var itemTooltip = [itemTooltipRoot.GetParent(),
        $("#ItemTooltipImage"),
        $("#ItemTooltipNameLabel"),
        $("#ItemTooltipRarityLabel"),
        $("#ItemTooltipTypeLabel"),
        $("#ItemTooltipLabel"),
        $("#ItemTooltipQualityLabel"),
        $("#ItemTooltipStatsContainer")];
        GameUI.CustomUIConfig().TooltipManager.itemTooltipPanel = itemTooltip;
    }
}

function Init() {
    if(!GameUI.CustomUIConfig().TooltipManager) {
        GameUI.CustomUIConfig().TooltipManager = TooltipManager;
    }
}

(function() {
    Init();
    CreateItemTooltip();
})();