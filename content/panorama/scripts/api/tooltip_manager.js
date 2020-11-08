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
var TOOLTIP_STATS_LABELS = 8;
var initialStatsLabelsInTooltip = 10;

TooltipManager.ShowItemTooltip = function(itemName, itemStats) {
	var position = GameUI.GetCursorPosition();
	var itemNameLabel = $.Localize("#DOTA_Tooltip_Ability_"+itemName);
	var itemDesiredSlot = ItemsDatabase.GetItemSlot(itemName);
	var itemRarity = ItemsDatabase.GetItemRarity(itemName);
	var itemTypeLabel = ItemsDatabase.GetItemSlotName(itemDesiredSlot);
	var itemDescriptionLabel = $.Localize("#DOTA_Tooltip_Ability_" + itemName + "_Description");
	var itemQuality = ItemsDatabase.GetItemQuality(itemName, itemStats);
	var itemQualityLabel = $.Localize("#DOTA_Inventory_quality").replace("%VALUE%", "<span class='Value'>" + itemQuality + "%</span>");
	var itemStatsCount = itemStats.length;
	var missedLabels = itemStatsCount - TooltipManager.itemTooltipContainer[TOOLTIP_STATS_CONTAINER].GetChildCount();
	if(missedLabels > 0) {
	    for(var i = 0; i < missedLabels; i++) {
            CreateItemStatsLabel();
	    }
	}
	UpdateItemTooltip(
	itemName,
	itemNameLabel,
	itemRarity,
	itemTypeLabel,
	itemDescriptionLabel,
	itemQualityLabel,
	itemStats,
	position[0],
	position[1]
	);
};

TooltipManager.HideItemTooltip = function() {
	TooltipManager.itemTooltipContainer[TOOLTIP_PANEL].style.visibility = "collapse";
};

function UpdateItemTooltip(icon, name, rarity, type, description, quality, stats, x, y) {
	var itemRarityColor = ItemsDatabase.GetItemRarityColor(rarity);
	var itemRarityLabel = ItemsDatabase.GetItemRarityName(rarity);
    TooltipManager.itemTooltipContainer[TOOLTIP_IMAGE].itemname = icon;
	TooltipManager.itemTooltipContainer[TOOLTIP_NAME_LABEL].text = name.toUpperCase();
	TooltipManager.itemTooltipContainer[TOOLTIP_NAME_LABEL].style.color = itemRarityColor;
	TooltipManager.itemTooltipContainer[TOOLTIP_RARITY_LABEL].text = itemRarityLabel;
	TooltipManager.itemTooltipContainer[TOOLTIP_TYPE_LABEL].text = type;
    if(description.toLowerCase().includes("dota_tooltip") || description.length == 0) {
        TooltipManager.itemTooltipContainer[TOOLTIP_DESCRIPTION_LABEL].style.visibility = "collapse";
    } else {
        TooltipManager.itemTooltipContainer[TOOLTIP_DESCRIPTION_LABEL].style.visibility = "visible";
    }
	TooltipManager.itemTooltipContainer[TOOLTIP_QUALITY_LABEL].text = quality;
	if(TooltipManager.itemTooltipContainer[TOOLTIP_PANEL].actuallayoutwidth + x > Game.GetScreenWidth()) {
	    x -= TooltipManager.itemTooltipContainer[TOOLTIP_PANEL].actuallayoutwidth;
	}
	if(TooltipManager.itemTooltipContainer[TOOLTIP_PANEL].actuallayoutheight + y > Game.GetScreenHeight()) {
	    y -= TooltipManager.itemTooltipContainer[TOOLTIP_PANEL].actuallayoutheight;
	}
	TooltipManager.itemTooltipContainer[TOOLTIP_PANEL].style.marginLeft = x + "px";
	TooltipManager.itemTooltipContainer[TOOLTIP_PANEL].style.marginTop = y + "px";
	TooltipManager.itemTooltipContainer[TOOLTIP_PANEL].style.visibility = "visible";
	var latestStatId = 0;
	for(var i = 0; i < stats.length; i++) {
	    var statName = $.Localize("#DOTA_Tooltip_Ability_"+icon+"_"+stats[i].name);
	    var statValue = stats[i].value;
	    var statSign = "";
	    if(statValue > 0) {
	        statSign = "+";
	    } else {
	        statSign = "-";
	    }
	    statValue = statValue.toString().replace("-", "").replace("+", "").replace(",", ".").replace(/\s+/g,"");
	    var IsPercent = (statName.charAt(0) == "%");
        if(IsPercent) {
            statName = statName.slice(1, statName.length);
            statValue += "%";
        }
        description = description.replace("%"+stats[i].name+"%", statValue);
	    TooltipManager.itemTooltipContainer[TOOLTIP_STATS_LABELS][i].text = "<span class='ItemTooltipStatsSign'>" + statSign + "</span> <span class='ItemTooltipStatsValue'>" + statValue + "</span>" + "<span class='ItemTooltipStatsText'> " + statName + "</span>";
	    TooltipManager.itemTooltipContainer[TOOLTIP_STATS_LABELS][i].style.visibility = "visible";
	    latestStatId++;
	}
	TooltipManager.itemTooltipContainer[TOOLTIP_DESCRIPTION_LABEL].text = description;
	for(var i = latestStatId; i < TooltipManager.itemTooltipContainer[TOOLTIP_STATS_CONTAINER].GetChildCount(); i++) {
		TooltipManager.itemTooltipContainer[TOOLTIP_STATS_LABELS][i].style.visibility = "collapse";
	}
}

function CreateItemTooltip() {
    var root = $.GetContextPanel();
    var itemTooltipRoot = root.FindChildTraverse("ItemTooltipHeader");
    if(itemTooltipRoot && GameUI.CustomUIConfig().TooltipManager.itemTooltipInitialized == false) {
        var itemTooltip = [itemTooltipRoot.GetParent(),
        $("#ItemTooltipImage"),
        $("#ItemTooltipNameLabel"),
        $("#ItemTooltipRarityLabel"),
        $("#ItemTooltipTypeLabel"),
        $("#ItemTooltipLabel"),
        $("#ItemTooltipQualityLabel"),
        $("#ItemTooltipStatsContainer"),
        []];
        GameUI.CustomUIConfig().TooltipManager.itemTooltipContainer = itemTooltip;
        GameUI.CustomUIConfig().TooltipManager.itemTooltipInitialized = true;
        for (var i = 0; i < initialStatsLabelsInTooltip; i++) {
            CreateItemStatsLabel();
        }
    }
}

function CreateItemStatsLabel() {
    var statsLabel = $.CreatePanel("Label", TooltipManager.itemTooltipContainer[TOOLTIP_STATS_CONTAINER], "");
    statsLabel.html = true;
    statsLabel.style.visibility = "collapse";
    TooltipManager.itemTooltipContainer[TOOLTIP_STATS_LABELS].push(statsLabel);
}

(function() {
    GameUI.CustomUIConfig().TooltipManager = TooltipManager;
    GameUI.CustomUIConfig().TooltipManager.itemTooltipInitialized = false;
    CreateItemTooltip();
})();