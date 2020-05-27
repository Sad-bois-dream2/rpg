var heroes = [];
var latestSelectedHero;
var heroPicked = true;
var heroSelected = false;
var tankStats, dpsStats, supportStats, utilityStats;
var availableHeroes = [];
var HERO_PANEL = 0, HERO_NAME = 1;
var heroesData = {};
var MAX_STATS = 5;
var STATE_SELECTED = 0;
var STATE_PICKED = 1;
var filterData = {};

function OnHeroSelected(hero, notPlaySound) {
    if(heroPicked) {
        return;
    }
	ChangeHeroModel(hero);
	latestSelectedHero = hero;
    $("#SelectedHeroName").text = $.Localize("#" + hero);
    $("#SelectedHeroIcon").heroname = hero;
    $("#HeroStats").style.visibility = "visible";
    ResetFilter();
	UpdateSaveSlots(hero);
    UpdateHeroStats(hero);
    UpdateHeroAbilities(hero);
	GameEvents.SendCustomGameEventToServer("rpg_hero_selection_hero_selected", {"hero" : hero});
	if(notPlaySound == true) {
	    return;
    }
    Game.EmitSound("General.SelectAction");
}

function ChangeHeroModel(hero) {
    $.DispatchEvent('DOTAGlobalSceneSetCameraEntity', 'HeroSelectionScreen', hero, 0);
}

function UpdateSaveSlots(hero) {
    for(var i = 0; i < $("#HeroSlotsPanel").GetChildCount(); i++) {
        var slot = $("#HeroSlotsPanel").GetChild(i);
        var slotHeroImage = slot.FindChildTraverse('HeroSlotImage');
        slotHeroImage.heroname = hero;
    }
}

function UpdateHeroAbilities(hero) {
    for(var i = 0; i < $("#HeroAbilitiesContainer").GetChildCount(); i++) {
        var abilityName = heroesData[hero]["Ability" + i];
        if(abilityName) {
            var abilityPanel = $("#HeroAbilitiesContainer").GetChild(i);
            abilityPanel.abilityname = abilityName;
        }
    }
}

function UpdateHeroStats(hero) {
    var tank = 0;
    var dps = 0;
    var support = 0;
    var utility = 0;
    if(heroesData[hero]) {
        tank = heroesData[hero]["tank"];
        dps = heroesData[hero]["dps"];
        support = heroesData[hero]["support"];
        utility = heroesData[hero]["utility"];
    }
    for(var i = 1; i <= MAX_STATS; i++) {
        var index = i - 1;
        var statValue = index + 1;
        tankStats[index].SetHasClass("selected", (statValue <= tank));
        dpsStats[index].SetHasClass("selected", (statValue <= dps));
        supportStats[index].SetHasClass("selected", (statValue <= support));
        utilityStats[index].SetHasClass("selected", (statValue <= utility));
    }
}

function OnMouseOverStat(container, childIndex) {
    var statContainer = $("#" + container);
    for(var i = 0; i < childIndex; i++) {
        var statPanel = statContainer.GetChild(i);
        statPanel.SetHasClass("hover", true);
    }
    for(var i = childIndex; i < statContainer.GetChildCount(); i++) {
        var statPanel = statContainer.GetChild(i);
        statPanel.SetHasClass("hover", false);
    }
}

function OnMouseOutOfStatPanel(container) {
    var statContainer = $("#" + container);
    for(var i = 0; i < statContainer.GetChildCount(); i++) {
        var statPanel = statContainer.GetChild(i);
        statPanel.SetHasClass("hover", false);
    }
}

function OnMouseClickOverStat(container, childIndex) {
    var statContainer = $("#" + container);
    for(var i = 0; i < childIndex; i++) {
        var statPanel = statContainer.GetChild(i);
        statPanel.SetHasClass("filter", true);
    }
    for(var i = childIndex; i < statContainer.GetChildCount(); i++) {
        var statPanel = statContainer.GetChild(i);
        statPanel.SetHasClass("filter", false);
    }
    filterData[container] = childIndex;
    UpdateFilter();
}

function OnResetFilterButtonClick() {
    Game.EmitSound("General.SelectAction");
    ResetFilter();
    UpdateFilter();
}

function ResetFilter() {
    Object.entries(filterData).map(entry => {
        var key = entry[0];
        OnMouseClickOverStat(key, 0);
    });
}

function UpdateFilter() {
    var tank = 0;
    var dps = 0;
    var support = 0;
    var utility = 0;
    if(filterData['TankStat']) {
        tank = filterData['TankStat'];
    }
    if(filterData['DpsStat']) {
        dps = filterData['DpsStat'];
    }
    if(filterData['SupportStat']) {
        support = filterData['SupportStat'];
    }
    if(filterData['UtilityStat']) {
        utility = filterData['UtilityStat'];
    }
    if(tank == 0 && dps == 0 && support == 0 && utility == 0) {
        for(var i = 0; i < availableHeroes.length; i++) {
            availableHeroes[i][HERO_PANEL].SetHasClass("filter", false);
        }
    } else {
        for(var i = 0; i < availableHeroes.length; i++) {
            var heroName = availableHeroes[i][HERO_NAME];
            var tankCondition = (heroesData[heroName].tank >= tank);
            var dpsCondition = (heroesData[heroName].dps >= dps);
            var supportCondition = (heroesData[heroName].support >= support);
            var utilityCondition = (heroesData[heroName].utility >= utility);
            var finalCondition = tankCondition && dpsCondition && supportCondition && utilityCondition;
            availableHeroes[i][HERO_PANEL].SetHasClass("filter", !finalCondition);
        }
    }
}

function OnHeroSelectionScreenLoaded() {
    $("#Spinner").style.visibility = "collapse";
    $("#AvailableHeroesContainer").style.visibility = "visible";
    $("#HeroSlotsContainer").style.visibility = "visible";
    if(heroSelected) {
        OnHeroSelected(latestSelectedHero, true);
    }
}

function OnPickHeroButtonPressed(slot) {
    var slot = $("#" + slot);
    if(slot.BHasClass("Locked") || heroPicked) {
        return;
    }
    Game.EmitSound("HeroPicker.Selected");
	GameEvents.SendCustomGameEventToServer("rpg_hero_selection_hero_picked", {"hero" : latestSelectedHero});
	HideUIAfterHeroPick();
}

function HideUIAfterHeroPick() {
    $("#AvailableHeroesContainer").style.visibility = "collapse";
    $("#HeroSlotsContainer").style.visibility = "collapse";
}

function OnHeroesDataReceived(event) {
    var heroesContainerStr = $("#AvailableHeroesStrength");
    var heroesContainerAgi = $("#AvailableHeroesAgility");
    var heroesContainerInt = $("#AvailableHeroesIntellect");
    heroes = JSON.parse(event.heroes);
    for(var i = 0; i < heroes.length; i++) {
        var heroPanel;
        if(heroes[i].Attribute == "DOTA_ATTRIBUTE_STRENGTH") {
		    heroPanel = $.CreatePanel( "RadioButton", heroesContainerStr, heroes[i].Name);
		}
        if(heroes[i].Attribute == "DOTA_ATTRIBUTE_AGILITY") {
		    heroPanel = $.CreatePanel( "RadioButton", heroesContainerAgi, heroes[i].Name);
		}
        if(heroes[i].Attribute == "DOTA_ATTRIBUTE_INTELLECT") {
		    heroPanel = $.CreatePanel( "RadioButton", heroesContainerInt, heroes[i].Name);
		}
        heroPanel.BLoadLayout("file://{resources}/layout/custom_game/windows/heroselection/heroselection_button.xml", false, false);
        heroPanel.FindChildTraverse('HeroIcon').heroname = heroes[i].Name;
        heroPanel.Data().OnHeroSelected = OnHeroSelected;
        availableHeroes.push([heroPanel, heroes[i].Name]);
        heroesData[heroes[i].Name] = {}
        if(heroes[i].Roles) {
            if(heroes[i].Roles.Tank) {
                heroesData[heroes[i].Name].tank = heroes[i].Roles.Tank;
            } else {
                heroesData[heroes[i].Name].tank = 0;
            }
            if(heroes[i].Roles.DPS) {
                heroesData[heroes[i].Name].dps = heroes[i].Roles.DPS;
            } else {
                heroesData[heroes[i].Name].dps = 0;
            }
            if(heroes[i].Roles.Support) {
                heroesData[heroes[i].Name].support = heroes[i].Roles.Support;
            } else {
                heroesData[heroes[i].Name].support = 0;
            }
            if(heroes[i].Roles.Utility) {
                heroesData[heroes[i].Name].utility = heroes[i].Roles.Utility;
            } else {
                heroesData[heroes[i].Name].utility = 0;
            }
        } else {
            heroesData[heroes[i].Name].tank = 0;
            heroesData[heroes[i].Name].dps = 0;
            heroesData[heroes[i].Name].support = 0;
            heroesData[heroes[i].Name].utility = 0;
        }
        for(var j = 0; j < 6; j++) {
            if(heroes[i].Abilities[j]) {
                heroesData[heroes[i].Name]["Ability"+j] = heroes[i].Abilities[j];
            } else {
                heroesData[heroes[i].Name]["Ability"+j] = "";
            }
        }
    }
    latestSelectedHero = heroes[0].Name;
    heroSelected = true;
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
        if(playerId == localPlayerId) {
            if(state >= STATE_SELECTED) {
                latestSelectedHero = playerHero;
                heroSelected = true;
            }
            if(state == STATE_PICKED) {
                picked = true;
                HideUIAfterHeroPick();
            }
        }
    });
    heroPicked = picked;
}

(function() {
    var tankContainer = $("#TankStat");
    var dpsContainer = $("#DpsStat");
    var supportContainer = $("#SupportStat");
    var utilityContainer = $("#UtilityStat");
    tankStats = [];
    supportStats = [];
    dpsStats = [];
    utilityStats = [];
    for(var i = 0; i < MAX_STATS; i++) {
        tankStats.push(tankContainer.GetChild(i));
        dpsStats.push(dpsContainer.GetChild(i));
        supportStats.push(supportContainer.GetChild(i));
        utilityStats.push(utilityContainer.GetChild(i));
    }
	GameEvents.SendCustomGameEventToServer("rpg_hero_selection_get_heroes",{});
	GameEvents.SendCustomGameEventToServer("rpg_hero_selection_get_state",{});
	GameEvents.Subscribe("rpg_hero_selection_get_heroes_from_server", OnHeroesDataReceived);
	GameEvents.Subscribe("rpg_hero_selection_get_state_from_server", OnStateDataReceived);
})();

