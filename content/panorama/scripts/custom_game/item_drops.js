var dropContainer;
var droppedItems = [];
var UPDATE_INTERVAL = 0.1;
var DROP_TIMER = 5 + UPDATE_INTERVAL;
var tooltip;
var TOOLTIP_PANEL = 0, TOOLTIP_IMAGE = 1, TOOLTIP_NAME_LABEL = 2, TOOLTIP_RARITY_LABEL = 3, TOOLTIP_TYPE_LABEL = 4, TOOLTIP_DESCRIPTION_LABEL = 5, TOOLTIP_QUALITY_LABEL = 6, TOOLTIP_STATS_CONTAINER = 7;

function GetHEXPlayerColor(playerId) {
	var playerColor = Players.GetPlayerColor(playerId).toString(16);
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}

function HideItemTooltip(slotId) {
	tooltip[TOOLTIP_PANEL].style.visibility = "collapse";
}

function CreateItemTooltip(slot, icon, name, rarity, type, description, quality, x, y) {
		tooltip[TOOLTIP_IMAGE].itemname = icon;
		tooltip[TOOLTIP_NAME_LABEL].text = name.toUpperCase();
		tooltip[TOOLTIP_RARITY_LABEL].text = rarity;
		tooltip[TOOLTIP_TYPE_LABEL].text = type;
        if(description.toLowerCase().includes("dota_tooltip") || description.length == 0) {
            tooltip[TOOLTIP_DESCRIPTION_LABEL].style.visibility = "collapse";
        } else {
            tooltip[TOOLTIP_DESCRIPTION_LABEL].style.visibility = "visible";
        }
		tooltip[TOOLTIP_DESCRIPTION_LABEL].text = description;
		tooltip[TOOLTIP_QUALITY_LABEL].text = quality;
		tooltip[TOOLTIP_PANEL].style.marginLeft = (x+40) + "px";
		tooltip[TOOLTIP_PANEL].style.marginTop = (y-50) + "px";
		tooltip[TOOLTIP_PANEL].style.visibility = "visible";
		var latestStatId = 0;
		for(var i = 0; i < slot[SLOT_ITEM_STATS].length; i++) {
		    var statName = $.Localize("#DOTA_Tooltip_Ability_"+slot[SLOT_ITEM_IMAGE].itemname+"_"+slot[SLOT_ITEM_STATS][i].name);
		    var statValue = slot[SLOT_ITEM_STATS][i].value;
		    var IsPercent = (statName.charAt(0) == "%");
            if(IsPercent) {
                statName = statName.slice(1, statName.length);
                statValue += "%";
            }
		    statsLabels[i].text = statName + statValue;
		    statsLabels[i].style.visibility = "visible";
		    latestStatId++;
		}
		for(var i = latestStatId; i < tooltip[TOOLTIP_STATS_CONTAINER].GetChildCount(); i++) {
		    statsLabels[i].style.visibility = "collapse";
		}
}

function OnItemDrop(event) {
	var itemDropPanel = $.CreatePanel("Panel", dropContainer, "");
	itemDropPanel.BLoadLayout("file://{resources}/layout/custom_game/item_drops_item.xml", false, false);
    itemDropPanel.FindChildTraverse('DropItemIcon').itemname = event.item;
    itemDropPanel.FindChildTraverse('HeroContainerIcon').heroname = event.hero;
    itemDropPanel.FindChildTraverse('HeroContainerLabel').text = "<font color='" + GetHEXPlayerColor(event.player_id) + "'>" + Players.GetPlayerName(event.player_id) + "</font>";
    dropContainer.MoveChildBefore(itemDropPanel, dropContainer.GetChild(0));
}

function UpdateValues() {

}

function AutoUpdateValues() {
    UpdateValues();
    $.Schedule(UPDATE_INTERVAL, function() {
        AutoUpdateValues();
    });
}

function OnInventoryItemsDataRequest(event) {

}

(function() {
    dropContainer = $("#DropContainer");
	tooltip = [$("#ItemTooltip"), $("#ItemTooltipImage"), $("#ItemTooltipNameLabel"), $("#ItemTooltipRarityLabel"), $("#ItemTooltipTypeLabel"), $("#ItemTooltipLabel"), $("#ItemTooltipQualityLabel"), $("#ItemTooltipStatsContainer")];
    GameEvents.Subscribe("rpg_enemy_item_dropped", OnItemDrop);
	GameEvents.Subscribe("rpg_inventory_items_data", OnInventoryItemsDataRequest);
    AutoUpdateValues();
})();