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

(function() {
    dropContainer = $("#DropContainer");
	tooltip = [$("#ItemTooltip"), $("#ItemTooltipImage"), $("#ItemTooltipNameLabel"), $("#ItemTooltipRarityLabel"), $("#ItemTooltipTypeLabel"), $("#ItemTooltipLabel"), $("#ItemTooltipQualityLabel"), $("#ItemTooltipStatsContainer")];
    GameEvents.Subscribe("rpg_item_dropped", OnItemDrop);
    AutoUpdateValues();
})();