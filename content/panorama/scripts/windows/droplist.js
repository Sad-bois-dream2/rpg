var dropContainer;
var ItemsDatabase = GameUI.CustomUIConfig().ItemsDatabase;

function GetHEXPlayerColor(playerId) {
	var playerColor = Players.GetPlayerColor(playerId).toString(16);
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}

function OnItemDrop(event) {
	var itemDropPanel = $.CreatePanel("Panel", dropContainer, "");
	var itemDesiredSlot = ItemsDatabase.GetItemSlot(event.item);
	var itemRarity = ItemsDatabase.GetItemRarity(event.item);
    var itemRarityColor = ItemsDatabase.GetItemRarityColor(itemRarity);
	itemDropPanel.BLoadLayout("file://{resources}/layout/custom_game/windows/droplist/droplist_item.xml", false, false);
	var itemIcon = itemDropPanel.FindChildTraverse('DropItemIcon');
    itemIcon.itemname = event.item;
    itemDropPanel.FindChildTraverse('ItemOwnerIcon').heroname = event.hero;
    itemDropPanel.FindChildTraverse('ItemOwnerLabel').text = $.Localize("DOTA_DropList_FoundByPlayer").replace("%PLAYER_NAME%", "<font color='" + GetHEXPlayerColor(event.player_id) + "'>" + Players.GetPlayerName(event.player_id) + "</font>");
    var itemNameLabel = itemDropPanel.FindChildTraverse('ItemNameLabel');
    itemNameLabel.text = $.Localize("#DOTA_Tooltip_Ability_"+event.item);
    itemNameLabel.style.color = itemRarityColor;
    itemDropPanel.FindChildTraverse('ItemRarityLabel').text = ItemsDatabase.GetItemRarityName(itemRarity);
    itemDropPanel.FindChildTraverse('ItemTypeLabel').text = ItemsDatabase.GetItemSlotName(itemDesiredSlot);
    itemDropPanel.FindChildTraverse('ItemTooltipImageBorder').style.border = "2px solid " + itemRarityColor;
    itemDropPanel.Data().itemName = event.item;
    itemDropPanel.Data().itemStats = JSON.parse(event.stats);
    dropContainer.MoveChildBefore(itemDropPanel, dropContainer.GetChild(0));
    itemDropPanel.SetHasClass("show", true);
}

(function () {
    dropContainer = $("#DropContainer");
    GameEvents.Subscribe("rpg_enemy_item_dropped", OnItemDrop);
})();

