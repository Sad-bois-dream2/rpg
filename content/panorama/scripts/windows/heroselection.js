var heroes = [];
var heroScreenLoaded = false;

function OnHeroSelected(hero) {
	$.DispatchEvent('DOTAGlobalSceneSetCameraEntity', 'HeroSelectionScreen', hero, 0.5);
}

function OnHeroSelectionScreenLoaded() {
    $("#Spinner").style.visibility = "collapse";
    $("#AvailableHeroesContainer").style.visibility = "visible";
    $("#HeroControls").style.visibility = "visible";
    heroScreenLoaded = true;
}

function WaitHeroScreenLoading() {
    if(heroScreenLoaded) {
	    $.DispatchEvent('DOTAGlobalSceneSetCameraEntity', 'HeroSelectionScreen', heroes[0], 0);
    } else {
        $.Schedule( 0.1, WaitHeroScreenLoading );
    }
}

function OnHeroesDataRecieved(event) {
    var heroesContainer = $("#AvailableHeroes");
    heroes = JSON.parse(event.heroes);
    for(var i = 0; i < heroes.length; i++) {
		var heroPanel = $.CreatePanel( "RadioButton", heroesContainer, heroes[i]);
        heroPanel.BLoadLayout("file://{resources}/layout/custom_game/windows/heroselection/heroselection_button.xml", false, false);
        heroPanel.FindChildTraverse('HeroIcon').heroname = heroes[i];
        heroPanel.Data().OnHeroSelected = OnHeroSelected;
    }
}

(function() {
	GameEvents.SendCustomGameEventToServer("rpg_hero_selection_get_heroes",{});
	GameEvents.Subscribe("rpg_hero_selection_get_heroes_from_server", OnHeroesDataRecieved);
	WaitHeroScreenLoading();
})();
