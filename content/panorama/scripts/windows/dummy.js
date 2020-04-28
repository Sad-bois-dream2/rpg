//text = text + "<br><span class='DamageOwner'>Crystal Sorceress</span> dealed <span class='DamageNumber'>" + damage.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,") + " </span> <font color='#8f8f8f'>Physical</font>, <font color='#2084f6'>Frost</font> damage from <span class='DamageSource'>" + damageType + "</span>.";

var latestSelectedDummy;

function OnClearLogButtonPressed() {
	var log = $("#DamageText");
	log.text = "";
}

function OnStartTestButtonPressed() {
    if(latestSelectedDummy < 0) {
        return;
    }
	var localPlayer = Players.GetLocalPlayer();
    var event = {
        "dummy" : latestSelectedDummy,
        "player_id" : localPlayer,
    }
    GameEvents.SendCustomGameEventToServer("rpg_dummy_start", event);
}

function UpdateSelection() {
    var selectedUnit = Players.GetLocalPlayerPortraitUnit();
    if(Entities.GetUnitName(selectedUnit) == "npc_dummy_dps_unit") {
        latestSelectedDummy = selectedUnit;
        var localPlayer = Game.GetLocalPlayerID()
        GameEvents.SendCustomGameEventToServer("rpg_close_all_windows", { "player_id" : localPlayer});
        GameEvents.SendCustomGameEventToServer("rpg_dummy_open_window", { "player_id" : localPlayer});
    }
}

function OnWindowOpenRequest(event) {
	var window = $("#MainWindow");
	window.style.visibility = "visible";
}

function OnWindowCloseRequest(event) {
	var window = $("#MainWindow");
	window.style.visibility = "collapse";
}

(function() {
    GameEvents.Subscribe("dota_player_update_query_unit", UpdateSelection);
    GameEvents.Subscribe("dota_player_update_selected_unit", UpdateSelection);
    GameEvents.Subscribe("rpg_dummy_open_window_from_server", OnWindowOpenRequest);
    GameEvents.Subscribe("rpg_dummy_close_window_from_server", OnWindowCloseRequest);
})();
