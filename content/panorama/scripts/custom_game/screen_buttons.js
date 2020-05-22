var buttonsPanel;

function OnInventoryButtonClicked() {
    if(Game.GameStateIsBefore(DOTA_GameState.DOTA_GAMERULES_STATE_GAME_IN_PROGRESS)) {
        return
    }
	var localPlayer = Players.GetLocalPlayer();
	$.DispatchEvent("DOTAHideTitleTextTooltip", $.GetContextPanel());
    GameEvents.SendCustomGameEventToServer("rpg_close_all_windows", { "player_id" : localPlayer});
    GameEvents.SendCustomGameEventToServer("rpg_inventory_open_window", { "player_id" : localPlayer});
}

function OnTalentTreeButtonClicked() {
    if(Game.GameStateIsBefore(DOTA_GameState.DOTA_GAMERULES_STATE_GAME_IN_PROGRESS)) {
        return
    }
	var localPlayer = Players.GetLocalPlayer();
	$.DispatchEvent("DOTAHideTitleTextTooltip", $.GetContextPanel());
    GameEvents.SendCustomGameEventToServer("rpg_close_all_windows", { "player_id" : localPlayer});
    GameEvents.SendCustomGameEventToServer("rpg_talenttree_open_window", { "player_id" : localPlayer});
}

function FixButtonPanelPosition() {
    buttonsPanel.SetHasClass("OnLeftSide", Game.IsHUDFlipped());
    $.Schedule(0.1, function() {
        FixButtonPanelPosition();
    });
}

(function() {
	buttonsPanel = $("#ButtonsRoot");
	FixButtonPanelPosition();
})();