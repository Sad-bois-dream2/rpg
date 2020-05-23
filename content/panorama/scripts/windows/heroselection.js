var heroesContainer;

function OnHeroSelected(hero) {
    $.Msg(hero);
}

function OnHeroesDataRecieved(event) {
    var heroes = JSON.parse(event.heroes);
    for(var i = 0; i < heroes.length; i++) {
		var heroPanel = $.CreatePanel( "RadioButton", heroesContainer, heroes[i]);
        heroPanel.BLoadLayout("file://{resources}/layout/custom_game/windows/heroselection/heroselection_button.xml", false, false);
        heroPanel.FindChildTraverse('HeroIcon').heroname = heroes[i];
        heroPanel.Data().OnHeroSelected = OnHeroSelected;
    }
}

(function() {
    heroesContainer = $("#AvailableHeroes");
	GameEvents.SendCustomGameEventToServer("rpg_hero_selection_get_heroes",{});
	GameEvents.Subscribe("rpg_hero_selection_get_heroes_from_server", OnHeroesDataRecieved);
})();
