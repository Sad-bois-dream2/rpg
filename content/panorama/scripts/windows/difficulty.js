var difficultySlider, difficultyLabel;

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

function UpdateValues() {
    var difficulty = GetPickedDiffculty(difficultySlider.value);
    difficultyLabel.text = $.Localize("#DOTA_Difficulty_" + difficulty);
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
    AutoUpdateValues();
})();