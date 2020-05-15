var difficultySlider, difficultyLabel, difficultyContainer;
var difficultyContainerLabels = [];
var INITIAL_LINES_IN_DIFFICULTY_CHANGES_CONTAINER = 10;

function GetPickedDiffculty(value) {
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

function RoundValue(value) {
    return Math.floor(value * 100) / 100;
}

function FormatChangesText(change, difficulty) {
    change = change.replace("%HEALTH%", GetHealthBonusForDifficulty(difficulty));
    change = change.replace("%ARMOR%", GetArmorBonusForDifficulty(difficulty));
    change = change.replace("%ELEARMOR%", GetEleArmorBonusForDifficulty(difficulty));
    change = change.replace("%ATTACKDAMAGE%", GetAttackDamageBonusForDifficulty(difficulty));
    change = change.replace("%EXPERIENCE%", GetExperienceBonusForDifficulty(difficulty));
    change = change.replace("%ABILITYLEVEL%", GetAbilitiesLevelForDifficulty(difficulty));
    return change;
}

function GetPickedDiffcultyChanges(difficulty) {
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
    var changes = GetPickedDiffcultyChanges(difficulty);
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

}

function UpdateValues() {
    var difficulty = GetPickedDiffculty(difficultySlider.value);
    ModifyDifficultyWindow(difficulty);
}

function AutoUpdateValues() {
    UpdateValues();
    $.Schedule(0.1, function() {
        AutoUpdateValues();
    });
}

(function() {
    difficultySlider = $("#DifficultySlider");
    difficultyLabel = $("#PickedDifficultyLabel");
    difficultyContainer = $("#DifficultyChangesContainer");
    for(var i = 0; i < INITIAL_LINES_IN_DIFFICULTY_CHANGES_CONTAINER; i++) {
        var difficultyChange = $.CreatePanel("Label", difficultyContainer, "");
        difficultyChange.SetHasClass("DifficultyChangeLabel", true);
        difficultyChange.style.visibility = "visible";
        difficultyChange.html = true;
        difficultyContainerLabels.push(difficultyChange);
    }
    AutoUpdateValues();
})();