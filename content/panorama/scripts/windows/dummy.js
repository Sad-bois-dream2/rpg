//text = text + "<br><span class='DamageOwner'>Crystal Sorceress</span> dealed <span class='DamageNumber'>" + damage.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,") + " </span> <font color='#8f8f8f'>Physical</font>, <font color='#2084f6'>Frost</font> damage from <span class='DamageSource'>" + damageType + "</span>.";
var mainWindow, damageLabel, dpsLabel;
var MAX_CAPACITY = 50;
var DAMAGE_ENTRY_CONTAINER = 0, DAMAGE_ENTRY_LABEL = 1;
var currentEntryIndex = 0;
var damageEntries = [];
var latestSelectedDummy;
var armors = [];

function OnClearLogButtonPressed() {
    for (var i = 0; i < MAX_CAPACITY; i++) {
	    damageEntries[i][DAMAGE_ENTRY_CONTAINER].style.visibility = "collapse";
	}
    currentEntryIndex = 0;
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
        if(selectedUnit != latestSelectedDummy) {
            ClearWindow();
            GameEvents.SendCustomGameEventToServer("rpg_load_damage", { "player_id" : localPlayer, "dummy" : selectedUnit});
        }
        latestSelectedDummy = selectedUnit;
        var localPlayer = Game.GetLocalPlayerID()
        GameEvents.SendCustomGameEventToServer("rpg_close_all_windows", { "player_id" : localPlayer});
        GameEvents.SendCustomGameEventToServer("rpg_dummy_open_window", { "player_id" : localPlayer});
    }
}

function OnWindowOpenRequest(event) {
	mainWindow.style.visibility = "visible";
}

function OnWindowCloseRequest(event) {
	mainWindow.style.visibility = "collapse";
}

function BuildDamageTypesString(event) {
    var result = "";
    if(event.physdmg) {
        result += $.Localize("#DOTA_Dummy_Damage_Physical") + ", ";
    }
    if(event.puredmg) {
        result += $.Localize("#DOTA_Dummy_Damage_Pure") +", ";
    }
    if(event.firedmg) {
        result += $.Localize("#DOTA_Dummy_Damage_Fire") +", ";
    }
    if(event.frostdmg) {
        result += $.Localize("#DOTA_Dummy_Damage_Frost") +", ";
    }
    if(event.earthdmg) {
        result += $.Localize("#DOTA_Dummy_Damage_Earth") +", ";
    }
    if(event.naturedmg) {
        result += $.Localize("#DOTA_Dummy_Damage_Nature") +", ";
    }
    if(event.voiddmg) {
        result += $.Localize("#DOTA_Dummy_Damage_Void") +", ";
    }
    if(event.infernodmg) {
        result += $.Localize("#DOTA_Dummy_Damage_Inferno") +", ";
    }
    if(event.holydmg) {
        result += $.Localize("#DOTA_Dummy_Damage_Holy") +", ";
    }
    result = result.trim();
    if(result.length > 1) {
        result = result.slice(0, -1);
    }
    return result;
}

function BuildDamageSourceString(event) {
    if(event.fromsummon) {
        return $.Localize("#DOTA_Dummy_Damage_Source_Summon");
    }
    if(!event.ability && event.physdmg) {
        return $.Localize("#DOTA_Dummy_Damage_Source_Autoattack");
    } else {
        return $.Localize("#DOTA_Dummy_Damage_Source_Ability").replace("%ABILITY%", $.Localize("#" + event.abilityName));
    }
}

function OnDamageRegisterRequest(event) {
    if(currentEntryIndex < MAX_CAPACITY) {
	    damageEntries[currentEntryIndex][DAMAGE_ENTRY_LABEL].text = $.Localize("#DOTA_Dummy_Damage_Instance");
	    damageEntries[currentEntryIndex][DAMAGE_ENTRY_LABEL].text = damageEntries[currentEntryIndex][DAMAGE_ENTRY_LABEL].text.replace("%SOURCE%", $.Localize("#" + event.source));
	    damageEntries[currentEntryIndex][DAMAGE_ENTRY_LABEL].text = damageEntries[currentEntryIndex][DAMAGE_ENTRY_LABEL].text.replace("%DAMAGE%", event.damage);
	    damageEntries[currentEntryIndex][DAMAGE_ENTRY_LABEL].text = damageEntries[currentEntryIndex][DAMAGE_ENTRY_LABEL].text.replace("%DAMAGE_TYPES%", BuildDamageTypesString(event));
	    damageEntries[currentEntryIndex][DAMAGE_ENTRY_LABEL].text = damageEntries[currentEntryIndex][DAMAGE_ENTRY_LABEL].text.replace("%DAMAGE_SOURCE%", BuildDamageSourceString(event));
	    damageEntries[currentEntryIndex][DAMAGE_ENTRY_CONTAINER].style.visibility = "visible";
	    currentEntryIndex++;
	}
}

function OnResultRegisterRequest(event) {
    event.dps = Math.floor(event.dps);
	dpsLabel.text = Math.floor(event.dps).toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
}

function ClearWindow() {
    dpsLabel.text = "?";
    OnClearLogButtonPressed();
}

function OnBossStatsButtonPressed() {
    for (var i = 0; i < armors.length; i++) {
	    armors[i].text = "47";
	}
}

function OnEliteStatsButtonPressed() {
    for (var i = 0; i < armors.length; i++) {
	    armors[i].text = "23";
	}
}

function OnUpdateStatsButtonPressed() {
    for (var i = 0; i < armors.length; i++) {
	    armors[i].text = "23";
	}
}

(function() {
    mainWindow = $("#MainWindow");
    damageContainer = $("#DamageLog");
    for (var i =0; i < MAX_CAPACITY; i++) {
        var damageEntry = $.CreatePanel("Panel", damageContainer, "");
        damageEntry.SetHasClass("DamageEntry", true)
        damageEntry.BLoadLayout("file://{resources}/layout/custom_game/windows/dummy/dummy_damage_entry.xml", false, false);
        damageEntry.style.visibility = "collapse";
        damageEntries.push([damageEntry, damageEntry.GetChild(0)]);
    }
    armors.push($("#PhysArmor"));
    armors.push($("#FireArmor"));
    armors.push($("#FrostArmor"));
    armors.push($("#EarthArmor"));
    armors.push($("#NatureArmor"));
    armors.push($("#VoidArmor"));
    armors.push($("#InfernoArmor"));
    armors.push($("#HolyArmor"));
    for (var i = 0; i < armors.length; i++) {
	    armors[i].text = "0";
	}
    dpsLabel = $("#DPS");
    GameEvents.Subscribe("dota_player_update_query_unit", UpdateSelection);
    GameEvents.Subscribe("dota_player_update_selected_unit", UpdateSelection);
    GameEvents.Subscribe("rpg_dummy_open_window_from_server", OnWindowOpenRequest);
    GameEvents.Subscribe("rpg_dummy_close_window_from_server", OnWindowCloseRequest);
    GameEvents.Subscribe("rpg_dummy_damage", OnDamageRegisterRequest);
    GameEvents.Subscribe("rpg_dummy_result_dps", OnResultRegisterRequest);
})();
