var heroesData = {
    "npc_dota_hero_drow_ranger" : {
        "tank" : 0,
        "dps" : 5,
        "support" : 0
    },
    "npc_dota_hero_abyssal_underlord" : {
        "tank" : 5,
        "dps" : 3,
        "support" : 0
    },
    "npc_dota_hero_invoker" : {
        "tank" : 0,
        "dps" : 5,
        "support" : 0
    },
    "npc_dota_hero_dark_willow" : {
        "tank" : 0,
        "dps" : 5,
        "support" : 0
    },
    "npc_dota_hero_silencer" : {
        "tank" : 0,
        "dps" : 2,
        "support" : 5
    },
    "npc_dota_hero_phantom_assassin" : {
        "tank" : 0,
        "dps" : 5,
        "support" : 0
    },
    "npc_dota_hero_mars" : {
        "tank" : 5,
        "dps" : 2,
        "support" : 0
    },
    "npc_dota_hero_doom_bringer" : {
        "tank" : 0,
        "dps" : 5,
        "support" : 0
    },
    "npc_dota_hero_axe" : {
        "tank" : 0,
        "dps" : 5,
        "support" : 0
    },
    "npc_dota_hero_crystal_maiden" : {
        "tank" : 0,
        "dps" : 5,
        "support" : 0
    },
    "npc_dota_hero_enchantress" : {
        "tank" : 0,
        "dps" : 0,
        "support" : 5
    },
    "npc_dota_hero_juggernaut" : {
        "tank" : 0,
        "dps" : 5,
        "support" : 0
    },
};

var MAX_STATS = 5;
var tankStats, dpsStats, supportStats;

function OnHeroSelected(event) {
    $("#HeroIcon" + event.player_id).heroname = event.hero;
    if(event.player_id == Players.GetLocalPlayer()) {
        $("#SelectedHeroName").text = $.Localize("#" + event.hero);
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
	GameEvents.Subscribe("rpg_hero_selection_hero_selected_from_server", OnHeroSelected);
})();
