function OnHeroSelected(event) {
    $("#HeroIcon" + event.player_id).heroname = event.hero;
    if(event.player_id == Players.GetLocalPlayer()) {
        $("#SelectedHeroName").text = $.Localize("#" + event.hero);
    }
}

function OnHeroPicked(event) {
    var heroIcon = $("#HeroIcon" + event.player_id);
    heroIcon.heroname = event.hero;
    heroIcon.SetHasClass("notpicked", false);
}

function UpdateTimer()
{
	var gameTime = Game.GetGameTime();
	var transitionTime = Game.GetStateTransitionTime();
	if ( transitionTime >= 0 )
	{
		$("#TimerLabel").SetDialogVariableInt( "countdown_timer_seconds", Math.max( 0, Math.floor( transitionTime - gameTime ) ) );
	}
	$.Schedule( 0.1, UpdateTimer );
}

function GetHEXPlayerColor(playerId) {
	var playerColor = Players.GetPlayerColor(playerId).toString(16);
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}

function HideDefaultUI()
{
	var defaultGameSetup = $.GetContextPanel().GetParent().FindChildTraverse('TeamSelectContainer');
	if(defaultGameSetup) {
	    defaultGameSetup.style.visibility = "collapse";
	    defaultGameSetup.hittest = false;
	    defaultGameSetup.hittestchildren = false;
	} else {
	    $.Schedule( 0.1, HideDefaultUI );
	}
}

function UpdateHeroColors() {
    var loadedPlayers = 0;
    for(var i =0; i < 5; i++) {
        var playerColor = GetHEXPlayerColor(i);
        if(playerColor != "#ffffffff") {
            loadedPlayers++;
        }
        $("#HeroColor"+i).style.backgroundColor = playerColor;
        var playerName = Players.GetPlayerName(i);
        if(playerName.length > 0) {
            $("#HeroName" + i).text = playerName;
        } else {
            $("#HeroName" + i).GetParent().style.visibility = "collapse";
        }
    }
    if(loadedPlayers < 1) {
	    $.Schedule( 0.1, UpdateHeroColors );
    }
}

function FixGameSetupWindow() {
	$.GetContextPanel().GetParent().style.marginLeft = "0px";
}

(function() {
	UpdateTimer();
	UpdateHeroColors();
	HideDefaultUI();
    FixGameSetupWindow();
	GameEvents.Subscribe("rpg_hero_selection_hero_selected_from_server", OnHeroSelected);
})();
