var difficultySlider, difficultyLabel, difficultyContainer;
var difficultyContainerLabels = [];
var INITIAL_LINES_IN_DIFFICULTY_CHANGES_CONTAINER = 20;
var UPDATE_INTERVAL = 0.25, UPDATE_INTERVAL_TIMER = 0.1, UPDATE_INTERVAL_TIMER_LOADING_DOTS = 0.5;
var mainWindow;
var confirmButton;
var TIMER = -1;
var timerStarted = false;
var hostId = -1;
var DIFFICULTY_MAX = 20;

function GetPickedDifficulty(value) {
    if(value  < 0.01) {
        return 1;
    }
    if(value  < 0.06) {
        return 2;
    }
    if(value  < 0.11) {
        return 3;
    }
    if(value  < 0.16) {
        return 4;
    }
    if(value  < 0.22) {
        return 5;
    }
    if(value  < 0.27) {
        return 6;
    }
    if(value  < 0.32) {
        return 7;
    }
    if(value  < 0.37) {
        return 8;
    }
    if(value  < 0.43) {
        return 9;
    }
    if(value  < 0.48) {
        return 10;
    }
    if(value  < 0.53) {
        return 11;
    }
    if(value  < 0.58) {
        return 12;
    }
    if(value  < 0.64) {
        return 13;
    }
    if(value  < 0.69) {
        return 14;
    }
    if(value  < 0.74) {
        return 15;
    }
    if(value  < 0.79) {
        return 16;
    }
    if(value  < 0.85) {
        return 17;
    }
    if(value  < 0.90) {
        return 18;
    }
    if(value  < 0.95) {
        return 19;
    }
    return 20;
}

function GetHealthBonusForDifficulty(difficulty) {
    var heroesInGame =  Entities.GetAllHeroEntities().length;
    var result = (difficulty * 100 * heroesInGame) - 100;
    return RoundValue(result);
}

function GetArmorBonusForDifficulty(difficulty) {
    var result = (difficulty / 20) * 100;
    return RoundValue(result);
}

function GetEleArmorBonusForDifficulty(difficulty) {
    var result = (difficulty / 20) * 100;
    return RoundValue(result);
}

function GetAttackDamageBonusForDifficulty(difficulty) {
    var result = Math.pow((difficulty / 2), 3) * 100;;
    return RoundValue(result);
}

function GetExperienceBonusForDifficulty(difficulty) {
    return 0;
}

function GetAbilitiesLevelForDifficulty(difficulty) {
    var result = 1;
    if (difficulty > 8) {
        result = 2;
    }
    if (difficulty > 14) {
        result = 3;
    }
    return result;
}

function GetEliteEnemyDropChance(difficulty) {
    var baseDropChance = 35;
    var maxDropChance = 70;
    var difficultyMax = 10.5;
    return Math.min(baseDropChance + ((maxDropChance - baseDropChance) * ((difficulty * 1.8) / difficultyMax)), maxDropChance);
}

function GetItemDropChances(difficulty) {
    var common = 0, uncommon = 1, rare = 2, uniqueRare = 3, legendary = 4, uniqueLegendary = 5, cursedLegendary = 6, ancient = 7, uniqueAncient = 8, cursedAncient = 9, immortal = 10, uniqueImmortal = 11, cursedImmortal = 12, last = 12;
    var result = [100,0,0,0,0,0,0,0,0,0,0,0,0];
    var factor = 1;
    if(difficulty > 1) {
        result[uncommon] = 60;
    }
    if(difficulty > 1.5) {
        result[uncommon] = 80;
        result[rare] = 25;
    }
    if(difficulty > 2) {
        result[rare] = 35;
    }
    if(difficulty > 2.5) {
        result[uniqueRare] = 20;
    }
    if(difficulty > 3) {
        result[uniqueRare] = 25;
    }
    if(difficulty > 3.5) {
        result[legendary] = 25;
    }
    if(difficulty > 4) {
        result[uniqueLegendary] = 25;
    }
    if(difficulty > 4.5) {
        result[cursedLegendary] = 35;
    }
    if(difficulty > 5) {
        result[ancient] = 20;
    }
    if(difficulty > 5.5) {
        result[ancient] = 10;
        result[cursedAncient] = 10;
        result[uniqueAncient] = 15;
        result[common] = 0;
        result[uncommon] = 0;
        result[rare] = 100;
        factor += 0.1;
    }
    if(difficulty > 7) {
        factor += 0.2;
    }
    if(difficulty > 7.5) {
        result[immortal] = 7;
    }
    if(difficulty > 8) {
        result[uniqueImmortal] = 2;
    }
    if(difficulty > 8.5) {
        result[cursedImmortal] = 3;
    }
    if(difficulty > 9) {
        result[rare] = 0;
        result[uniqueRare] = 0;
        result[legendary] = 0;
        result[uniqueLegendary] = 0;
        result[cursedLegendary] = 0;
        result[ancient] = 100;
    }
    if(difficulty > 9.5) {
         result[immortal] = result[immortal] * 1.5;
         result[uniqueImmortal] = result[uniqueImmortal] * 1.5;
         result[cursedImmortal] = result[cursedImmortal] * 1.5;
    }
    if(difficulty > 10) {
        factor += 0.25;
    }
    for(var i = 0; i <= last; i++) {
        result[i] = Math.ceil(Math.min(result[i] * factor, 100));
    }
    return result;
}

function RoundValue(value) {
    return Math.floor(value * 100) / 100;
}

function FormatChangesText(change, difficulty) {
    var convertedDifficulty = (difficulty / 2) + 0.5;
    var dropChances = GetItemDropChances(convertedDifficulty);
    change = change.replace("%HEALTH%", GetHealthBonusForDifficulty(difficulty));
    change = change.replace("%ARMOR%", GetArmorBonusForDifficulty(difficulty));
    change = change.replace("%ELEARMOR%", GetEleArmorBonusForDifficulty(difficulty));
    change = change.replace("%ATTACKDAMAGE%", GetAttackDamageBonusForDifficulty(difficulty));
    change = change.replace("%EXPERIENCE%", GetExperienceBonusForDifficulty(difficulty));
    change = change.replace("%ABILITYLEVEL%", GetAbilitiesLevelForDifficulty(difficulty));
    change = change.replace("%ELITEDROPCHANCE%", GetEliteEnemyDropChance(convertedDifficulty));
    change = change.replace("%UNCOMMONCHANCE%", dropChances[1]);
    change = change.replace("%RARECHANCE%", dropChances[2]);
    change = change.replace("%UNIQUERARECHANCE%", dropChances[3]);
    change = change.replace("%LEGENDARYCHANCE%", dropChances[4]);
    change = change.replace("%UNIQUELEGENDARYCHANCE%", dropChances[5]);
    change = change.replace("%CURSEDLEGENDARYCHANCE%", dropChances[6]);
    change = change.replace("%ANCIENTCHANCE%", dropChances[7]);
    change = change.replace("%UNIQUEANCIENTCHANCE%", dropChances[8]);
    change = change.replace("%CURSEDANCIENTCHANCE%", dropChances[9]);
    change = change.replace("%IMMORTALCHANCE%", dropChances[10]);
    change = change.replace("%UNIQUEIMMORTALCHANCE%", dropChances[11]);
    change = change.replace("%CURSEDIMMORTALCHANCE%", dropChances[12]);
    return change;
}

function GetPickedDifficultyChanges(difficulty) {
    var changes = [];
    for(var i = 1; i < difficulty + 1; i++) {
        var change = $.Localize("#DOTA_Difficulty_Change" + i);
        if(!change.toLowerCase().includes("dota_") && change.length > 0) {
            changes.push(change);
        }
    }
    return changes;
}

function ModifyDifficultyWindow(difficulty) {
    var changes = GetPickedDifficultyChanges(difficulty);
    var missedLines = changes.length - difficultyContainer.GetChildCount();
    if(missedLines > 0) {
        var difficultyChange = $.CreatePanel("Label", difficultyContainer, "");
        difficultyChange.SetHasClass("DifficultyChangeLabel", true);
        difficultyChange.style.visibility = "visible";
        difficultyChange.html = true;
        difficultyContainerLabels.push(difficultyChange);
    }
    var latestChangeId = 0;
    changes.forEach(change => {
        difficultyContainerLabels[latestChangeId].text = FormatChangesText(change, difficulty);
        difficultyContainerLabels[latestChangeId].style.visibility = "visible";
        latestChangeId += 1;
    });
    for(var i = latestChangeId; i < difficultyContainer.GetChildCount(); i++) {
        difficultyContainerLabels[i].style.visibility = "collapse";
    }
    difficultyLabel.text = $.Localize("#DOTA_Difficulty_" + difficulty);
}

function OnConfirmButtonPressed() {
    GameEvents.SendCustomGameEventToServer("rpg_difficulty_confirm", {"difficulty" : GetPickedDifficulty(difficultySlider.value)});
    timerStarted = false;
}

var prevSliderValue = -1;
var checkStateRequestSended = false;

function UpdateValues() {
    var difficulty = GetPickedDifficulty(difficultySlider.value);
    ModifyDifficultyWindow(difficulty);
    if(prevSliderValue != difficultySlider.value && hostId == Players.GetLocalPlayer()) {
        GameEvents.SendCustomGameEventToServer("rpg_difficulty_changed", {"value": difficultySlider.value});
        prevSliderValue = difficultySlider.value;
    }
    if(!checkStateRequestSended) {
        GameEvents.SendCustomGameEventToServer("rpg_difficulty_check_state", {});
        checkStateRequestSended = true;
    }
}

function AutoUpdateTimer() {
    if(MainWindow.style.visibility == "collapse") {
        return;
    }
    if(timerStarted) {
        if(!Game.IsGamePaused()) {
            TIMER = (Math.round((TIMER - UPDATE_INTERVAL_TIMER) * 100) / 100).toFixed(2);
            timeLeftLabel.text = $.Localize("#DOTA_Difficulty_TimeLeft").replace("%TIME%", TIMER);
            if(TIMER < 0) {
                OnConfirmButtonPressed();
            }
        }
    }
    $.Schedule(UPDATE_INTERVAL_TIMER, function() {
        AutoUpdateTimer();
    });
}

function AutoUpdateValues() {
    if(MainWindow.style.visibility == "collapse") {
        return;
    }
    UpdateValues();
    $.Schedule(UPDATE_INTERVAL, function() {
        AutoUpdateValues();
    });
}

function OnDifficultyWindowCloseRequest(event) {
    Game.EmitSound("Item.GlimmerCape.Activate");
    MainWindow.style.visibility = "collapse";
}

function OnDifficultyWindowInfo(event) {
    if(event.host == 1) {
        confirmButton.style.visibility = "visible";
        $("#DifficultySliderContainer").hittestchildren = true;
    } else {
        confirmButton.style.visibility = "collapse";
        $("#DifficultySliderContainer").hittestchildren = false;
        $("#TitleLabel").text = $.Localize("#DOTA_Difficulty_Title_Client").toUpperCase();
    }
    TIMER = event.pick_time;
    timerStarted = true;
}

function OnDifficultyWindowValueChangeRequest(event) {
    difficultySlider.value = event.value;
}

function OnDifficultyWindowHostIdInfo(event) {
    hostId = event.host;
}

function OnDifficultyWindowCheckState(event) {
    if(event.state == 1) {
        MainWindow.style.visibility = "collapse";
    }
}

(function() {
    difficultySlider = $("#DifficultySlider");
    difficultyLabel = $("#PickedDifficultyLabel");
    difficultyContainer = $("#DifficultyChangesContainer");
    MainWindow = $("#MainWindow");
    confirmButton = $("#ConfirmButton");
    timeLeftLabel = $("#TimeLeftLabel");
    for(var i = 0; i < INITIAL_LINES_IN_DIFFICULTY_CHANGES_CONTAINER; i++) {
        var difficultyChange = $.CreatePanel("Label", difficultyContainer, "");
        difficultyChange.SetHasClass("DifficultyChangeLabel", true);
        difficultyChange.style.visibility = "visible";
        difficultyChange.html = true;
        difficultyContainerLabels.push(difficultyChange);
    }
    GameEvents.Subscribe("rpg_difficulty_close_window_from_server", OnDifficultyWindowCloseRequest);
    GameEvents.Subscribe("rpg_difficulty_change_value", OnDifficultyWindowValueChangeRequest);
    GameEvents.Subscribe("rpg_difficulty_host_id", OnDifficultyWindowHostIdInfo);
    GameEvents.Subscribe("rpg_difficulty_get_info_from_server", OnDifficultyWindowInfo);
    GameEvents.Subscribe("rpg_difficulty_check_state_from_server", OnDifficultyWindowCheckState);
    AutoUpdateValues();
    AutoUpdateTimer();
    GameEvents.SendCustomGameEventToServer("rpg_difficulty_get_info", {});
})();