function OnInventoryButtonClicked() {
	var localPlayer = Players.GetLocalPlayer();
	$.DispatchEvent("DOTAHideTitleTextTooltip", $.GetContextPanel());
    GameEvents.SendCustomGameEventToServer("rpg_talenttree_close_window", { "player_id" : localPlayer});
    GameEvents.SendCustomGameEventToServer("rpg_inventory_open_window", { "player_id" : localPlayer});
}

function OnTalentTreeButtonClicked() {
	var localPlayer = Players.GetLocalPlayer();
	$.DispatchEvent("DOTAHideTitleTextTooltip", $.GetContextPanel());
    GameEvents.SendCustomGameEventToServer("rpg_inventory_close_window", { "player_id" : localPlayer});
    GameEvents.SendCustomGameEventToServer("rpg_talenttree_open_window", { "player_id" : localPlayer});
}

(function() {
	var container = $("#ButtonsRoot");
	container.style.width = (container.GetChildCount() * 85) + "px";
})();