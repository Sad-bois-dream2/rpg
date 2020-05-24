var MAX_STATS = 5;
var tankStats, dpsStats, supportStats;
var STATE_SELECTED = 0;
var STATE_PICKED = 1;

function OnHeroSelected(event) {
    $("#HeroIcon" + event.player_id).heroname = event.hero;
    if(event.player_id == Players.GetLocalPlayer()) {
        $("#SelectedHeroName").text = $.Localize("#" + event.hero);
        $("#HeroStats").style.visibility = "visible";
        UpdateHeroStats(event.hero);
    }
}

function OnHeroPicked(event) {
    var heroIcon = $("#HeroIcon" + event.player_id);
    heroIcon.heroname = event.hero;
    heroIcon.SetHasClass("notpicked", false);
}

function UpdateHeroStats(hero) {
    var tank = 0;
    var dps = 0;
    var support = 0;
    if(heroesData[hero]) {
        tank = heroesData[hero]["tank"];
        dps = heroesData[hero]["dps"];
        support = heroesData[hero]["support"];
    }
    for(var i = 1; i <= MAX_STATS; i++) {
        var index = i - 1;
        var statValue = index + 1;
        tankStats[index].SetHasClass("selected", (statValue <= tank));
        dpsStats[index].SetHasClass("selected", (statValue <= dps));
        supportStats[index].SetHasClass("selected", (statValue <= support));
    }
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

function OnStateDataReceived(event) {
    var state = JSON.parse(event.state);
    var localPlayerId = Players.GetLocalPlayer();
    Object.entries(state).map(entry => {
        var value = entry[1];
        var playerId = value.playerId;
        var playerHero = value.hero;
        var state = value.state;
        if(state == STATE_SELECTED) {
            var event = {
                "player_id" : playerId,
                "hero" : playerHero
            };
            OnHeroSelected(event);
        }
        if(state == STATE_PICKED) {
            var event = {
                "player_id" : playerId,
                "hero" : playerHero
            };
            OnHeroPicked(event);
        }
    });
}


(function() {
	UpdateTimer();
	UpdateHeroColors();
	HideDefaultUI();
    FixGameSetupWindow();
    var tankContainer = $("#TankStat");
    var dpsContainer = $("#DpsStat");
    var supportContainer = $("#SupportStat");
    tankStats = [];
    supportStats = [];
    dpsStats = [];
    for(var i = 0; i < MAX_STATS; i++) {
        tankStats.push(tankContainer.GetChild(i));
        dpsStats.push(dpsContainer.GetChild(i));
        supportStats.push(supportContainer.GetChild(i));
    }
	GameEvents.SendCustomGameEventToServer("rpg_hero_selection_get_state",{});
	GameEvents.Subscribe("rpg_hero_selection_hero_selected_from_server", OnHeroSelected);
	GameEvents.Subscribe("rpg_hero_selection_hero_picked_from_server", OnHeroPicked);
	GameEvents.Subscribe("rpg_hero_selection_get_state_from_server", OnStateDataReceived);
})();


