var dropContainer;

function GetHEXPlayerColor(playerId) {
	var playerColor = Players.GetPlayerColor(playerId).toString(16);
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}

function OnItemDrop(event) {
	var itemDropPanel = $.CreatePanel("Panel", dropContainer, "");
	itemDropPanel.BLoadLayout("file://{resources}/layout/custom_game/windows/droplist/droplist_item.xml", false, false);
	var itemIcon = itemDropPanel.FindChildTraverse('DropItemIcon');
    itemIcon.itemname = event.item;
    itemDropPanel.FindChildTraverse('DropItemHeroContainerIcon').heroname = event.hero;
    itemDropPanel.FindChildTraverse('DropItemHeroContainerLabel').text = "<font color='" + GetHEXPlayerColor(event.player_id) + "'>" + Players.GetPlayerName(event.player_id) + "</font>";
    itemDropPanel.Data().itemName = event.item;
    $.Msg(event.stats);
    itemDropPanel.Data().itemStats = JSON.parse(event.stats);
    $.Msg(itemDropPanel.Data().itemStats);
    dropContainer.MoveChildBefore(itemDropPanel, dropContainer.GetChild(0));
}

(function () {
    dropContainer = $("#DropContainer");
    GameEvents.Subscribe("rpg_enemy_item_dropped", OnItemDrop);
})();

