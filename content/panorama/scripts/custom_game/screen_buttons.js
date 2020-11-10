var buttonsPanel;
var inventoryWindowOpened = false, talentTreeWindowOpened = false;

function OnInventoryButtonClicked() {
    if(Game.GameStateIsBefore(DOTA_GameState.DOTA_GAMERULES_STATE_GAME_IN_PROGRESS)) {
        return
    }
	var localPlayer = Players.GetLocalPlayer();
	$.DispatchEvent("DOTAHideTitleTextTooltip", $.GetContextPanel());
	if(inventoryWindowOpened == false) {
        CloseAllWindows(localPlayer);
        GameEvents.SendCustomGameEventToServer("rpg_inventory_open_window", { "player_id" : localPlayer});
        inventoryWindowOpened = true;
    } else {
        GameEvents.SendCustomGameEventToServer("rpg_inventory_close_window", { "player_id" : localPlayer});
        inventoryWindowOpened = false;
    }
    Game.EmitSound("General.SelectAction");
}

function OnTalentTreeButtonClicked() {
    if(Game.GameStateIsBefore(DOTA_GameState.DOTA_GAMERULES_STATE_GAME_IN_PROGRESS)) {
        return
    }
	var localPlayer = Players.GetLocalPlayer();
	$.DispatchEvent("DOTAHideTitleTextTooltip", $.GetContextPanel());
	if(talentTreeWindowOpened == false) {
        CloseAllWindows(localPlayer);
        GameEvents.SendCustomGameEventToServer("rpg_talenttree_open_window", { "player_id" : localPlayer});
        talentTreeWindowOpened = true;
    } else {
        GameEvents.SendCustomGameEventToServer("rpg_talenttree_close_window", { "player_id" : localPlayer});
        talentTreeWindowOpened = false;
    }
    Game.EmitSound("General.SelectAction");
}

function FixButtonPanelPosition() {
    buttonsPanel.SetHasClass("OnLeftSide", Game.IsHUDFlipped());
    $.Schedule(0.1, function() {
        FixButtonPanelPosition();
    });
}

function CloseAllWindows(localPlayer) {
    GameEvents.SendCustomGameEventToServer("rpg_close_all_windows", { "player_id" : localPlayer});
    talentTreeWindowOpened = false;
    inventoryWindowOpened = false;
}

(function() {
	buttonsPanel = $("#ButtonsRoot");
	FixButtonPanelPosition();
})();