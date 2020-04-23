var castBarPanel, castBarValue, castbarLabel, castBarAbility;
var currentCastTime = 2.0, initialCastTime = 2.0;
var currentAbility = -1;
var castBarId;

function UpdateValues() {
    currentCastTime = currentCastTime - 0.1;
    if(castBarId === undefined) {
        castBarId = $.GetContextPanel().Data.id;
    }
    if(currentCastTime < 0) {
        currentCastTime = 0;
    }
    var IsHeroCastingAbility = Abilities.IsInAbilityPhase(currentAbility);
    var abilityChannelTime = Abilities.GetChannelTime(currentAbility);
    var IsChannelAbility = (abilityChannelTime > 0)
    var abilityStartChannelTime = Abilities.GetChannelStartTime(currentAbility);
    if((IsHeroCastingAbility || (IsChannelAbility && abilityStartChannelTime > 0)) && currentCastTime > 0) {
        castbarLabel.text = (Math.round(currentCastTime * 100) / 100) + "s";
        var castBarWidth = ((currentCastTime / initialCastTime)*100);
        // idk, there are was weird shit during test
        if(castBarWidth < 1) {
            castBarWidth = 1;
        }
        castBarValue.style.width = castBarWidth + "%";
    } else {
        castBarPanel.style.visibility = "collapse";
        castBarValue.style.width = "100%";
    }
}

function OnCastBarShowRequest(event) {
    if(castBarId != event.id) {
        return
    }
    var castTime = event.casttime;
    if(castTime < 0.01) {
        event.casttime = 0.01;
    }
    initialCastTime = event.casttime;
    currentCastTime = event.casttime;
    currentAbility = event.ability;
    castBarAbility.abilityname = Abilities.GetAbilityName(currentAbility);
    castBarPanel.style.visibility = "visible";
}

function AutoUpdateValues() {
    UpdateValues();
	$.Schedule( 0.1, AutoUpdateValues );
}

(function() {
    castBarPanel = $("#CastbarPanel");
    castBarValue = $("#CastbarValue");
    castbarLabel = $("#CastbarLabel");
    castBarAbility = $("#CastbarAbility");
    GameEvents.Subscribe("rpg_show_castbar", OnCastBarShowRequest);
    AutoUpdateValues();
})();