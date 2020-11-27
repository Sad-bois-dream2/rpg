var TOOLTIP_PANEL = 0;
var TOOLTIP_IMAGE = 1;
var TOOLTIP_NAME_LABEL = 2;
var TOOLTIP_RARITY_LABEL = 3;
var TOOLTIP_TYPE_LABEL = 4;
var TOOLTIP_DESCRIPTION_LABEL = 5;
var TOOLTIP_QUALITY_LABEL = 6;
var TOOLTIP_STATS_CONTAINER = 7;
var TOOLTIP_STATS_LABELS = 8;
var TOOLTIP_SET_NAME_LABEL = 9;
var TOOLTIP_SET_STATS_CONTAINER = 10;
var TOOLTIP_SET_STATS_LABELS = 11;
var TOOLTIP_SET_CONTAINER = 12;
var TOOLTIP_SET_PARTS_CONTAINER = 13;
var TOOLTIP_SET_PARTS_LABELS = 14;
var TOOLTIP_ITEM_ICON_BORDER = 15;
var initialStatsLabelsInTooltip = 10;

var ItemsDatabase = GameUI.CustomUIConfig().ItemsDatabase;
var PlayerInventory = GameUI.CustomUIConfig().PlayerInventory;
var TooltipManager = GameUI.CustomUIConfig().TooltipManager;

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
            CreateItemStatsLabel(TooltipManager.itemTooltipContainer[TOOLTIP_STATS_CONTAINER], TooltipManager.itemTooltipContainer[TOOLTIP_STATS_LABELS]);
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
    TooltipManager.itemTooltipContainer[TOOLTIP_ITEM_ICON_BORDER].style.border = "2px solid " + itemRarityColor;
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
        TooltipManager.itemTooltipContainer[TOOLTIP_STATS_LABELS][i].text = "<span class='ItemTooltipStatsSign'>" + statSign + "</span> " + "<img class='ItemStatIcon' src='" + TooltipManager.GetItemStatIcon(stats[i].type) + "'>" + " <span class='ItemTooltipStatsValue'>" + statValue + "</span> <span class='ItemTooltipStatsText'> " + statName + "</span>";
	    TooltipManager.itemTooltipContainer[TOOLTIP_STATS_LABELS][i].style.visibility = "visible";
	    TooltipManager.itemTooltipContainer[TOOLTIP_STATS_LABELS][i].SetHasClass("last", false);
	    latestStatId++;
	}
	TooltipManager.itemTooltipContainer[TOOLTIP_STATS_LABELS][latestStatId - 1].SetHasClass("last", true);
	TooltipManager.itemTooltipContainer[TOOLTIP_DESCRIPTION_LABEL].text = TooltipManager.FindAndFixPercents(description);
	for(var i = latestStatId; i < TooltipManager.itemTooltipContainer[TOOLTIP_STATS_CONTAINER].GetChildCount(); i++) {
		TooltipManager.itemTooltipContainer[TOOLTIP_STATS_LABELS][i].style.visibility = "collapse";
	}
	var itemSetName = ItemsDatabase.GetItemSetName(icon);
	if(itemSetName != "none") {
        var itemSetParts = ItemsDatabase.GetItemsInSet(itemSetName);
	    var itemSetTotalParts = itemSetParts.length;
        var missedLabels = itemSetTotalParts - TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_CONTAINER].GetChildCount();
        if(missedLabels > 0) {
            for(var i = 0; i < missedLabels; i++) {
                CreateItemSetStatsLabel(TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_CONTAINER], TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_LABELS]);
            }
        }
        missedLabels = itemSetTotalParts - TooltipManager.itemTooltipContainer[TOOLTIP_SET_PARTS_CONTAINER].GetChildCount();
        if(missedLabels > 0) {
            for(var i = 0; i < missedLabels; i++) {
                CreateItemSetPartsLabel(TooltipManager.itemTooltipContainer[TOOLTIP_SET_PARTS_CONTAINER], TooltipManager.itemTooltipContainer[TOOLTIP_SET_PARTS_LABELS]);
            }
        }
        var amountOfItemSetPartsEquipped = 0;
        latestStatId = 0;
        for(var i = 0; i < itemSetTotalParts; i++) {
            var setPartName = $.Localize("#DOTA_Tooltip_Ability_" + itemSetParts[i]);
            if(PlayerInventory.IsLocalPlayerEquippedItem(itemSetParts[i])) {
                TooltipManager.itemTooltipContainer[TOOLTIP_SET_PARTS_LABELS][i].SetHasClass("Equipped", true);
                amountOfItemSetPartsEquipped++;
            } else {
                TooltipManager.itemTooltipContainer[TOOLTIP_SET_PARTS_LABELS][i].SetHasClass("Equipped", false);
            }
            TooltipManager.itemTooltipContainer[TOOLTIP_SET_PARTS_LABELS][i].itemIcon.itemname = itemSetParts[i];
            var itemSetPartsRarity = ItemsDatabase.GetItemRarity(itemSetParts[i]);
            var itemSetPartsRarityColor = ItemsDatabase.GetItemRarityColor(itemSetPartsRarity);
            TooltipManager.itemTooltipContainer[TOOLTIP_SET_PARTS_LABELS][i].itemIconBorder.style.border = "1px solid " + itemSetPartsRarityColor;
            TooltipManager.itemTooltipContainer[TOOLTIP_SET_PARTS_LABELS][i].itemLabel.text = setPartName;
            TooltipManager.itemTooltipContainer[TOOLTIP_SET_PARTS_LABELS][i].style.visibility = "visible";
            latestStatId++;
        }
        for(var i = latestStatId; i < TooltipManager.itemTooltipContainer[TOOLTIP_SET_PARTS_CONTAINER].GetChildCount(); i++) {
            TooltipManager.itemTooltipContainer[TOOLTIP_SET_PARTS_LABELS][i].style.visibility = "collapse";
        }
	    var itemSetNameLabel = "<img class='SetIcon' src='s2r://panorama/images/hud/reborn/ult_ready_psd.vtex'>";
	    var itemSetNameInnerLabel = $.Localize("#DOTA_Inventory_item_set").replace("%NAME%", $.Localize("#DOTA_Tooltip_" + itemSetName));
	    itemSetNameInnerLabel = itemSetNameInnerLabel.replace("%CURRENTAMOUNTOFSETPARTS%", amountOfItemSetPartsEquipped);
	    itemSetNameInnerLabel = itemSetNameInnerLabel.replace("%TOTALAMOUNTOFSETPARTS%", itemSetTotalParts);
	    itemSetNameLabel += " <span class='SetName'>" + itemSetNameInnerLabel + "</span>";
        TooltipManager.itemTooltipContainer[TOOLTIP_SET_NAME_LABEL].text = itemSetNameLabel;
        latestStatId = 0;
        var setStatLabel = $.Localize("#DOTA_Inventory_item_set_bonus_title");
        var setStatBonusLabel = $.Localize("#DOTA_Inventory_item_set_bonus_value");
        for(var i = 0; i < itemSetTotalParts; i++) {
            var itemPartIndex = i + 1;
            if(setStatBonusLabel.includes("DOTA_Tooltip")) {
                TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_LABELS][i].style.visibility = "collapse";
                TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_LABELS][i].bonusLabel.style.visibility = "collapse";
                continue;
            }
            TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_LABELS][i].text = setStatLabel.replace("%SETPARTSREQUIRED%", itemPartIndex);
            TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_LABELS][i].SetHasClass("Enabled", itemPartIndex <= amountOfItemSetPartsEquipped);
            TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_LABELS][i].style.visibility = "visible";
            var bonusLabelText = setStatBonusLabel.replace("%BONUS%", $.Localize("#DOTA_Tooltip_" + itemSetName + "_items" + itemPartIndex));
            bonusLabelText = TooltipManager.FindAndReplaceStatIconsMarkers(bonusLabelText);
            TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_LABELS][i].bonusLabel.text = bonusLabelText;
            TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_LABELS][i].bonusLabel.SetHasClass("Enabled", itemPartIndex <= amountOfItemSetPartsEquipped);
            TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_LABELS][i].bonusLabel.style.visibility = "visible";
            latestStatId++;
        }
        for(var i = latestStatId; i < TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_LABELS].length; i++) {
            TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_LABELS][i].style.visibility = "collapse";
            TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_LABELS][i].bonusLabel.style.visibility = "collapse";
        }
 	    TooltipManager.itemTooltipContainer[TOOLTIP_SET_CONTAINER].style.visibility = "visible";
	} else {
	    TooltipManager.itemTooltipContainer[TOOLTIP_SET_CONTAINER].style.visibility = "collapse";
	}
}

function CreateItemStatsLabel(parent, container) {
    var statsLabel = $.CreatePanel("Label", parent, "");
    statsLabel.html = true;
    statsLabel.style.visibility = "collapse";
    container.push(statsLabel);
}

function CreateItemSetPartsLabel(parent, container) {
    var setPartLabel = $.CreatePanel("Panel", parent, "");
    setPartLabel.BLoadLayout("file://{resources}/layout/custom_game/tooltips/custom/tooltip_item_set_part.xml", false, false);
    setPartLabel.style.visibility = "collapse";
    setPartLabel.itemIcon = setPartLabel.FindChildTraverse("SetPartIcon");
    setPartLabel.itemIconBorder = setPartLabel.FindChildTraverse("ItemTooltipImageBorder");
    setPartLabel.itemLabel = setPartLabel.FindChildTraverse("SetPartLabel");
    container.push(setPartLabel);
}

function CreateItemSetStatsLabel(parent, container) {
    var setStatLabel = $.CreatePanel("Label", parent, "");
    setStatLabel.style.visibility = "collapse";
    setStatLabel.html = true;
    var setStatBonusLabel = $.CreatePanel("Label", parent, "");
    setStatBonusLabel.style.visibility = "collapse";
    setStatBonusLabel.html = true;
    setStatBonusLabel.SetHasClass("Bonus", true);
    setStatLabel.bonusLabel = setStatBonusLabel;
    container.push(setStatLabel);
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
        $("#ItemTooltipStatsContainer"),
        [],
        $("#ItemTooltipSetNameLabel"),
        $("#ItemTooltipSetStatsContainer"),
        [],
        $("#ItemTooltipSetContainer"),
        $("#ItemTooltipSetPartsContainer"),
        [],
        $("#ItemTooltipImageBorder"),
        $("#ItemTooltipDOTAItemImage")
        ];
        GameUI.CustomUIConfig().TooltipManager.itemTooltipContainer = itemTooltip;
        GameUI.CustomUIConfig().TooltipManager.itemTooltipInitialized = true;
        for (var i = 0; i < initialStatsLabelsInTooltip; i++) {
            CreateItemStatsLabel(TooltipManager.itemTooltipContainer[TOOLTIP_STATS_CONTAINER], TooltipManager.itemTooltipContainer[TOOLTIP_STATS_LABELS]);
            CreateItemSetStatsLabel(TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_CONTAINER], TooltipManager.itemTooltipContainer[TOOLTIP_SET_STATS_LABELS]);
            CreateItemSetPartsLabel(TooltipManager.itemTooltipContainer[TOOLTIP_SET_PARTS_CONTAINER], TooltipManager.itemTooltipContainer[TOOLTIP_SET_PARTS_LABELS]);
        }
    }
}

(function() {
    CreateItemTooltip();
})();