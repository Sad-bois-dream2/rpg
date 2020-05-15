var mainWindow, damageLabel, dpsLabel, logCapacity;
var DPS_TIME = 10
var MAX_CAPACITY = 50;
var currentEntryIndex = 0;
var damageEntries = [];
var latestSelectedDummy;
var armors = [];
var storedDamage = 0;

function OnClearLogButtonPressed() {
    for (var i = 0; i < MAX_CAPACITY; i++) {
	    damageEntries[i].style.visibility = "collapse";
	}
    currentEntryIndex = 0;
    UpdateLogCapacityText();
}

function OnStartTestButtonPressed() {
    if(latestSelectedDummy < 0) {
        return;
    }
    OnClearLogButtonPressed();
    storedDamage = 0;
    dpsLabel.text = "?";
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
        return $.Localize("#DOTA_Dummy_Damage_Source_Ability").replace("%ABILITY%", $.Localize("#DOTA_Tooltip_Ability_" + event.abilityName));
    }
}

function FormatDamageNumber(number) {
    return Math.floor(number).toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
}

function OnDamageRegisterRequest(event) {
    if(currentEntryIndex < MAX_CAPACITY) {
        var text = $.Localize("#DOTA_Dummy_Damage_Instance");
        text = text.replace("%SOURCE%", $.Localize("#" + event.source));
        text = text.replace("%DAMAGE%", FormatDamageNumber(event.damage));
        text = text.replace("%DAMAGE_TYPES%", BuildDamageTypesString(event));
        text = text.replace("%DAMAGE_SOURCE%", BuildDamageSourceString(event));
	    damageEntries[currentEntryIndex].text = text;
	    damageEntries[currentEntryIndex].style.visibility = "visible";
	    currentEntryIndex++;
	    UpdateLogCapacityText();
	}
    storedDamage += event.damage;
    CalculateDPS();
}

function UpdateLogCapacityText() {
    logCapacity.text = $.Localize("#DOTA_Dummy_Log_Capacity").replace("%CURRENT%", currentEntryIndex).replace("%MAX%", MAX_CAPACITY);
}

function CalculateDPS() {
    dpsLabel.text = FormatDamageNumber(storedDamage / DPS_TIME);
}

function OnBossStatsButtonPressed() {
    armors[0].text = "15";
    for (var i = 1; i < armors.length; i++) {
	    armors[i].text = "47";
	}
}

function OnEliteStatsButtonPressed() {
    armors[0].text = "5";
    for (var i = 1; i < armors.length; i++) {
	    armors[i].text = "23";
	}
}

function OnUpdateStatsButtonPressed() {
    var event = {
        "dummy" : latestSelectedDummy,
        "physdmg" : armors[0].text,
        "firedmg" : armors[1].text,
        "frostdmg" : armors[2].text,
        "earthdmg" : armors[3].text,
        "naturedmg" : armors[4].text,
        "voiddmg" : armors[5].text,
        "infernodmg" : armors[6].text,
        "holydmg" : armors[7].text,
    }
    GameEvents.SendCustomGameEventToServer("rpg_dummy_update_stats", event);
}

(function() {
    mainWindow = $("#MainWindow");
    logCapacity = $("#DamageLogCapacity");
    damageContainer = $("#DamageLog");
    for (var i =0; i < MAX_CAPACITY; i++) {
        var damageEntry = $.CreatePanel("Label", damageContainer, "");
        damageEntry.SetHasClass("DamageEntry", true)
        damageEntry.style.visibility = "collapse";
        damageEntry.html = true;
        damageEntries.push(damageEntry);
    }
    UpdateLogCapacityText();
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
})();
