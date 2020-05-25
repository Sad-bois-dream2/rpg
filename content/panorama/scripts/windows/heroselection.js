var heroes = [];
var heroScreenLoaded = false;
var latestSelectedHero;
var heroPicked = true;
var heroNotSelected = true;
var tankStats, dpsStats, supportStats, utilityStats;
var heroesData = {};
var MAX_STATS = 5;
var STATE_SELECTED = 0;
var STATE_PICKED = 1;

function OnHeroSelected(hero, notPlaySound) {
    if(heroPicked) {
        return;
    }
	ChangeHeroModel(hero);
	latestSelectedHero = hero;
    $("#SelectedHeroName").text = $.Localize("#" + hero);
    $("#SelectedHeroIcon").heroname = hero;
    $("#HeroStats").style.visibility = "visible";
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

function OnHeroSelectionScreenLoaded() {
    $("#Spinner").style.visibility = "collapse";
    $("#AvailableHeroesContainer").style.visibility = "visible";
    $("#HeroSlotsContainer").style.visibility = "visible";
    heroScreenLoaded = true;
    if(heroNotSelected) {
        OnHeroSelected(heroes[0].Name, true);
    }
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
            heroNotSelected = false;
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
	FixAltTab();
})();

