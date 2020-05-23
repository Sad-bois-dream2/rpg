var heroes = [];
var heroScreenLoaded = false;
var latestSelectedHero;
var heroPicked = true;
var STATE_SELECTED = 0;
var STATE_PICKED = 1;

function OnHeroSelected(hero) {
    if(heroPicked) {
        return;
    }
	ChangeHeroModel(hero);
	latestSelectedHero = hero;
	GameEvents.SendCustomGameEventToServer("rpg_hero_selection_hero_selected", {"hero" : hero});
    Game.EmitSound("General.SelectAction");
}

function ChangeHeroModel(hero) {
    $.DispatchEvent('DOTAGlobalSceneSetCameraEntity', 'HeroSelectionScreen', hero, 0);
}

function OnHeroSelectionScreenLoaded() {
    $("#Spinner").style.visibility = "collapse";
    $("#AvailableHeroesContainer").style.visibility = "visible";
    $("#HeroControls").style.visibility = "visible";
    heroScreenLoaded = true;
}

function OnOpenLoadWindowButtonPressed() {
    Game.EmitSound("ui.option_toggle");
    $("#SaveSlotsWindow").SetHasClass("Hidden", false);
}

function OnCloseLoadWindowButtonPressed() {
    Game.EmitSound("ui.match_close");
    $("#SaveSlotsWindow").SetHasClass("Hidden", true);
}

function OnPickHeroButtonPressed() {
    heroPicked = false;
    if(heroPicked) {
        return;
    }
    Game.EmitSound("HeroPicker.Selected");
	GameEvents.SendCustomGameEventToServer("rpg_hero_selection_hero_picked", {"hero" : latestSelectedHero});
}

function OnHeroesDataReceived(event) {
    var heroesContainer = $("#AvailableHeroes");
    heroes = JSON.parse(event.heroes);
    for(var i = 0; i < heroes.length; i++) {
		var heroPanel = $.CreatePanel( "RadioButton", heroesContainer, heroes[i]);
        heroPanel.BLoadLayout("file://{resources}/layout/custom_game/windows/heroselection/heroselection_button.xml", false, false);
        heroPanel.FindChildTraverse('HeroIcon').heroname = heroes[i];
        heroPanel.Data().OnHeroSelected = OnHeroSelected;
    }
}

function OnStateDataReceived(event) {
    var state = JSON.parse(event.state);
    var picked = false;
    var localPlayerId = Players.GetLocalPlayer();
    Object.entries(state).map(entry => {
        var value = entry[1];
        var playerId = value.playerId;
        var playerHero = value.hero;
        var state = value.state;
        if(state == STATE_PICKED && playerId == localPlayerId) {
            latestSelectedHero = playerHero;
            picked = true;
        }
    });
    heroPicked = picked;
}

function FixAltTab() {
    if(latestSelectedHero) {
        ChangeHeroModel(latestSelectedHero);
    }
    $.Schedule( 0.1, FixAltTab );
}

(function() {
	GameEvents.SendCustomGameEventToServer("rpg_hero_selection_get_heroes",{});
	GameEvents.SendCustomGameEventToServer("rpg_hero_selection_get_state",{});
	GameEvents.Subscribe("rpg_hero_selection_get_heroes_from_server", OnHeroesDataReceived);
	GameEvents.Subscribe("rpg_hero_selection_get_state_from_server", OnStateDataReceived);
	FixAltTab();
})();
