"use strict";

var m_AbilityPanels = []; // created up to a high-water mark, but reused when selection changes

var hpBar, hpBarValue, hpBarRegValue, mpBar, mpBarValue, mpBarRegValue, expBar, expBarValue, strValue, agiValue, intValue, heroPortrait, deathTimerValue, heroNameValue;
var attackDamageValue, armorValue, spellArmorValue, movespeedValue;
var expBarValue, levelValue, expLabel;
var abilitiesPanelFiller, abilitiesPanel;
var itemTooltip;
var fireResLabel, frostResLabel, earthResLabel, natureResLabel, voidResLabel, infernoResLabel, holyResLabel;

var LOCAL_PLAYER_TEAM, LOCAL_PLAYER_HERO = -1, lastSelectedUnit = -1;

function OnPortraitClick() {
	var IsAltDown = GameUI.IsAltDown();
    var hero = Players.GetLocalPlayerPortraitUnit();
	if(IsAltDown) {
		var player = Players.GetLocalPlayer();
		var message;
		var IsDead = (Entities.GetHealth(hero) < 1);
		if(LOCAL_PLAYER_HERO == hero) {
		    message = IsDead ? "#DOTA_Chat_Self_is_dead" : "#DOTA_Chat_Self_is_alive";
		} else {
			message = IsDead ? "#DOTA_Chat_Ally_is_dead" : "#DOTA_Chat_Ally_is_alive";
		}
		var args = [
		    {
		        "name" : "%HERO%",
		        "value" : "#" + Entities.GetUnitName(hero)
		    },
		    {
		        "name" : "%TIME%",
		        "value" : Players.GetRespawnSeconds(Entities.GetPlayerOwnerID(hero))
		    }
		];
		GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message, "args": JSON.stringify(args)});
	}
}


function OnHPBarClick() {
	var IsAltDown = GameUI.IsAltDown();
    var IsCtrlDown = GameUI.IsControlDown();
	if(IsAltDown) {
        var hero = Players.GetLocalPlayerPortraitUnit();
		var player = Players.GetLocalPlayer();
		var currentHp = Entities.GetHealth(hero);
		var maxHp = Entities.GetMaxHealth(hero);
		var hpPercent = (currentHp / maxHp) * 100;
		hpPercent = Math.round(hpPercent * 100) / 100;
		var message;
		if(LOCAL_PLAYER_HERO == hero) {
			message = IsCtrlDown ? "#DOTA_Chat_Self_health_healing" : "#DOTA_Chat_Self_health"
		} else {
			message = IsCtrlDown ? "#DOTA_Chat_Ally_health_healing" : "#DOTA_Chat_Ally_health"
		}
		var args = [
            {
                "name" : "%HERO%",
                "value" : "#" + Entities.GetUnitName(hero)
            },
            {
                "name" : "%CURRENTHP%",
                "value" : currentHp
            },
        	{
        	    "name" : "%HPPERCENT%",
        		"value" : hpPercent
        	}
        ];
		GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message, "args": JSON.stringify(args)});
	}
}

function OnMPBarClick() {
	var IsAltDown = GameUI.IsAltDown();
	if(IsAltDown) {
        var hero = Players.GetLocalPlayerPortraitUnit();
		var player = Players.GetLocalPlayer();
		var currentMp = Entities.GetMana(hero);
		var maxMp = Entities.GetMaxMana(hero);
		var mpPercent = (currentMp / maxMp) * 100;
		mpPercent = Math.round(mpPercent * 100) / 100;
		var message;
		if(LOCAL_PLAYER_HERO == hero) {
			message = "#DOTA_Chat_Self_mana"
		} else {
			message = "#DOTA_Chat_Ally_mana"
		}
		var args = [
            {
                "name" : "%HERO%",
                "value" : "#" + Entities.GetUnitName(hero)
            },
            {
                "name" : "%CURRENTMP%",
                "value" : currentMp
            },
        	{
        	    "name" : "%MPPERCENT%",
        		"value" : mpPercent
        	}
        ];
		GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message, "args": JSON.stringify(args)});
	}
}

function OnExpBarClick() {
	var IsAltDown = GameUI.IsAltDown();
	if(IsAltDown) {
        var hero = Players.GetLocalPlayerPortraitUnit();
		var player = Players.GetLocalPlayer();
        var currentExp = Entities.GetCurrentXP(hero);
        var maxExp = Entities.GetNeededXPToLevel(hero);
        var expPercent = (currentExp / maxExp) * 100;
		if(maxExp == 0) {
			expPercent = 100;
		} else {
			expPercent = Math.round((100-expPercent) * 100) / 100;
		}
		var message;
		if(LOCAL_PLAYER_HERO == hero) {
			message = maxExp == 0 ? "#DOTA_Chat_Self_maxlevel" : "#DOTA_Chat_Self_needxp"
		} else {
			message = maxExp == 0 ? "#DOTA_Chat_Ally_maxlevel" : "#DOTA_Chat_Ally_needxp"
		}
		var args = [
            {
                "name" : "%HERO%",
                "value" : "#" + Entities.GetUnitName(hero)
            },
            {
                "name" : "%XP%",
                "value" : (maxExp-currentExp)
            },
        	{
        	    "name" : "%EXPPERCENT%",
        		"value" : expPercent
        	},
        	{
        	    "name" : "%NEXTLEVEL%",
        		"value" : Entities.GetLevel(hero) + 1
        	}
        ];
        GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message, "args": JSON.stringify(args)});
	}
}

function OnAbilityLearnModeToggled(bEnabled) {
    UpdateAbilityList();
}

function UpdateAbilityList() {
    var abilityListPanel = $("#ability_list");
	var hero = Players.GetLocalPlayerPortraitUnit();
	var heroTeam = Players.GetTeam(Entities.GetPlayerOwnerID(hero));

    if (!abilityListPanel || (heroTeam != LOCAL_PLAYER_TEAM))
        return;

    var queryUnit = Players.GetLocalPlayerPortraitUnit();

    // see if we can level up
    var nRemainingPoints = Entities.GetAbilityPoints(queryUnit);
    var bPointsToSpend = (nRemainingPoints > 0);
    var bControlsUnit = Entities.IsControllableByPlayer(queryUnit, Game.GetLocalPlayerID());
    $.GetContextPanel().SetHasClass("could_level_up", (bControlsUnit && bPointsToSpend));
    if (!bPointsToSpend) {
        Game.EndAbilityLearnMode();
    }

    // update all the panels
    var nUsedPanels = 0;
    var abilitiesCount = Entities.GetAbilityCount(queryUnit);
    var abilityIconSize = 85;
    var legitAbilities = 0;
    for (var i = 0; i < abilitiesCount; ++i) {
        var ability = Entities.GetAbility(queryUnit, i);
        if (Abilities.IsDisplayedAbility(ability)) {
            legitAbilities++;
        }
    }
    for (var i = 0; i < Entities.GetAbilityCount(queryUnit); ++i) {
        var ability = Entities.GetAbility(queryUnit, i);
        if (ability == -1)
            continue;

        if (!Abilities.IsDisplayedAbility(ability))
            continue;
        if (nUsedPanels >= m_AbilityPanels.length) {
            // create a new panel
            var abilityPanel = $.CreatePanel("Panel", abilityListPanel, "");
            abilityPanel.BLoadLayout("file://{resources}/layout/custom_game/action_bar_ability.xml", false, false);
            m_AbilityPanels.push(abilityPanel);
        }
        // update the panel for the current unit / ability
        var abilityPanel = m_AbilityPanels[nUsedPanels];
        abilityPanel.Data().SetAbility(ability, queryUnit, Game.IsInAbilityLearnMode());

        nUsedPanels++;
    }
    // clear any remaining panels
    for (var i = nUsedPanels; i < m_AbilityPanels.length; ++i) {
        var abilityPanel = m_AbilityPanels[i];
        abilityPanel.Data().SetAbility(-1, -1, false);
    }
    abilitiesPanelFiller.style.width = (abilityListPanel.actuallayoutwidth / abilityListPanel.actualuiscale_x) + "px";
    abilitiesPanelFiller.style.height = (abilityListPanel.actuallayoutheight / abilityListPanel.actualuiscale_y) + "px";
}

var IsFirstTime = true;

function UpdateValues() {
    var hero = Players.GetLocalPlayerPortraitUnit();
	var heroTeam = Players.GetTeam(Entities.GetPlayerOwnerID(hero));
	if(heroTeam != LOCAL_PLAYER_TEAM) {
		hero = lastSelectedUnit;
		if(lastSelectedUnit != null) {
			GameUI.SelectUnit(lastSelectedUnit, false);
		}
	}
	if(LOCAL_PLAYER_HERO < 0) {
	    var localPlayerId = Game.GetLocalPlayerID();
	    LOCAL_PLAYER_TEAM = Players.GetTeam(localPlayerId);
	    LOCAL_PLAYER_HERO = Players.GetPlayerHeroEntityIndex(localPlayerId);
	}
    if (hero > -1) {
		if(IsFirstTime) {
			// weird fix :v
			GameUI.SelectUnit(hero, false);
			IsFirstTime = false;
		}
        var currentHp = Entities.GetHealth(hero);
        var maxHp = Entities.GetMaxHealth(hero);
        var hpPercent = (currentHp / maxHp) * 100;
        var hpReg = Entities.GetHealthThinkRegen(hero);
        var currentMp = Entities.GetMana(hero);
        var maxMp = Entities.GetMaxMana(hero);
        var mpPercent = (currentMp / maxMp) * 100;
        var mpReg = Entities.GetManaThinkRegen(hero);
        var currentExp = Entities.GetCurrentXP(hero);
        var maxExp = Entities.GetNeededXPToLevel(hero);
        var expPercent = (currentExp / maxExp) * 100;
        var currentLevel = Entities.GetLevel(hero);
        var IsDead = (currentHp < 1);
        var IsAltDown = GameUI.IsAltDown();
        heroPortrait.SetHasClass("is_dead", IsDead);
        deathTimerValue.style.visibility = IsDead ? "visible" : "collapse";
        if (IsDead) {
            var respawnTime = Players.GetRespawnSeconds(Entities.GetPlayerOwnerID(hero));
            if (respawnTime > 9999) {
                respawnTime = "";
            }
            deathTimerValue.text = respawnTime;
        }
        hpBar.style.width = hpPercent + "%";
        if (IsAltDown) {
            hpBarValue.text = (Math.round(hpPercent * 100) / 100) + "%";
        } else {
            hpBarValue.text = currentHp + " / " + maxHp;
        }
        hpBarRegValue.text = "+" + hpReg;
        if(currentMp > 65535) {
            if (IsAltDown) {
                mpBarValue.text = latestStoredManaPercent + "%";
            } else {
                mpBarValue.text = latestStoredMana + " / " + latestStoredMaxMana;
            }
            mpBar.style.width = latestStoredManaPercent + "%";
        } else {
            if (IsAltDown) {
                mpBarValue.text = (Math.round(mpPercent * 100) / 100) + "%"
            } else {
                mpBarValue.text = currentMp + " / " + maxMp;
            }
            mpBar.style.width = mpPercent + "%";
        }
        mpBarRegValue.text = "+" + (Math.round(mpReg * 100) / 100);
		if(isNaN(expPercent) || maxExp == 0) {
			expPercent = 100;
			maxExp = currentExp;
		}
		var convertedExpPercent = Math.round(360 * (expPercent / 100));
		expBarValue.style.clip = "radial(50% 50%, 0deg, " + convertedExpPercent + "deg);";
		expPercent = Math.round(expPercent * 100) / 100;
		expLabel.text = currentExp + " / " + maxExp + " (" + expPercent + "%)";
		if(IsAltDown) {
		    expLabel.style.visibility = "visible";
		} else {
		    expLabel.style.visibility = "collapse";
		}
		levelValue.text = Entities.GetLevel(hero);
		attackDamageValue.text = Entities.GetDamageMin(hero);
		// Stats from server
		if(latestStats) {
            var str = latestStats.str;
            var agi = latestStats.agi;
            var int = latestStats.int;
            strValue.text = Math.round(str);
            agiValue.text = Math.round(agi);
            intValue.text = Math.round(int);
            var currentMp = latestStats.display.mana;
            var maxMp = latestStats.display.maxmana;
            var mpPercent = (currentMp / maxMp) * 100;
            mpPercent = (Math.round(mpPercent * 100) / 100);
            latestStoredMana = currentMp;
            latestStoredMaxMana = maxMp;
            latestStoredManaPercent = mpPercent;
            var armor = latestStats.armor;
            var armorReduction = 0;
            if(armor >= 0){
                armorReduction = ((armor * 0.06) / (1 + armor * 0.06));
            } else {
                armorReduction = -1 + Math.pow(0.94,armor * -1);
            }
            if(IsAltDown) {
                armorValue.text = (Math.round(armorReduction * 10000) / 100) + "%";
            } else {
                armorValue.text = armor;
            }
            var elementalArmorValue = 0;
            var arr = Object.values(latestStats.elementsProtection);
            var length = arr.length;
            for(var i = 0; i < length; i++) {
                elementalArmorValue += (1 - arr[i]);
            }
            elementalArmorValue = elementalArmorValue / length;
            spellArmorValue.text = Math.round(elementalArmorValue * 10000) / 100 + "%";
            movespeedValue.text = Entities.GetMoveSpeedModifier(hero, Entities.GetBaseMoveSpeed(hero));
            fireResLabel.text = Math.round((1 - latestStats.elementsProtection["fire"]) * 100) +"%";
            frostResLabel.text = Math.round((1 - latestStats.elementsProtection["frost"]) * 100) +"%";
            earthResLabel.text = Math.round((1 - latestStats.elementsProtection["earth"]) * 100) +"%";
            natureResLabel.text = Math.round((1 - latestStats.elementsProtection["nature"]) * 100) +"%";
            voidResLabel.text = Math.round((1 - latestStats.elementsProtection["void"]) * 100) +"%";
            infernoResLabel.text = Math.round((1 - latestStats.elementsProtection["inferno"]) * 100) +"%";
            holyResLabel.text = Math.round((1 - latestStats.elementsProtection["holy"]) * 100) +"%";
        }
		lastSelectedUnit = hero;
    }
}

function AutoUpdateValues() {
    UpdateValues();
    $.Schedule(0.1, function() {
        AutoUpdateValues();
    });
}

var latestStoredManaPercent = 100, latestStoredMana = 0, latestStoredMaxMana = 0;
var latestStats;

function OnHeroStatsUpdateRequest(event) {
    var selectedUnit = Players.GetLocalPlayerPortraitUnit();
    var localPlayerId = Entities.GetPlayerOwnerID(selectedUnit);
	var parsedData = JSON.parse(event.data);
    var recievedPlayerId = parsedData.player_id;
    if (localPlayerId == recievedPlayerId) {
        latestStats = parsedData.statsTable;
    }
}

function Init() {
    hpBar = $("#HeroHpBar");
    hpBarValue = $("#HeroHpBarValue");
    hpBarRegValue = $("#HeroHpBarRegValue");
    mpBar = $("#HeroMpBar");
    mpBarValue = $("#HeroMpBarValue");
    mpBarRegValue = $("#HeroMpBarRegValue");
    expBar = $("#HeroExpBar");
    expBarValue = $("#HeroExpBarValue");
    strValue = $("#StrengthLabel");
    agiValue = $("#AgilityLabel");
    intValue = $("#IntelligenceLabel");
    heroPortrait = $("#HeroPortrait");
    deathTimerValue = $("#HeroDeathTimer");
    heroNameValue = $("#HeroName");
    attackDamageValue = $("#AttackDamageLabel");
    armorValue = $("#ArmorLabel");
    spellArmorValue = $("#SpellArmorLabel");
    movespeedValue = $("#MovespeedLabel");
    expBarValue = $("#HeroLevelExpBackground");
    levelValue = $("#HeroLevelLabel");
    expLabel = $("#HeroExpAltLabel");
    // Modifier lists
    $("#ModifierListContainer").BLoadLayout("file://{resources}/layout/custom_game/buff_list.xml", false, false);
    // Abilities panels
    abilitiesPanelFiller = $("#HeroAbilitiesPanelFiller");
    abilitiesPanel = $("#HeroAbilitiesPanel");
    // Stats tooltips
    fireResLabel = $("#FireResistanceLabel");
    frostResLabel = $("#FrostResistanceLabel");
    earthResLabel = $("#EarthResistanceLabel");
    natureResLabel = $("#NatureResistanceLabel");
    voidResLabel = $("#VoidResistanceLabel");
    infernoResLabel = $("#InfernoResistanceLabel");
    holyResLabel = $("#HolyResistanceLabel");
    itemTooltip = $("#ItemTooltip");
}

function ShowElementalResistancesTooltip() {
    var cursorPosition = GameUI.GetCursorPosition();
    var x = cursorPosition[0];
    var y = cursorPosition[1];
	if(itemTooltip.actuallayoutwidth + x > Game.GetScreenWidth()) {
	    x -= itemTooltip.actuallayoutwidth;
	}
	if(itemTooltip.actuallayoutheight + y > Game.GetScreenHeight()) {
	    y -= itemTooltip.actuallayoutheight;
	}
	itemTooltip.style.marginLeft = x + "px";
	itemTooltip.style.marginTop = y + "px";
    itemTooltip.style.visibility = "visible";
}

function HideElementalResistancesTooltip() {
    itemTooltip.style.visibility = "collapse";
}

(function() {
    //$.RegisterForUnhandledEvent( "DOTAHUDAbilityLearnModeToggled", OnAbilityLearnModeToggled);
    GameEvents.Subscribe("dota_portrait_ability_layout_changed", UpdateAbilityList);
    GameEvents.Subscribe("dota_player_update_selected_unit", UpdateAbilityList);
    GameEvents.Subscribe("dota_player_update_query_unit", UpdateAbilityList);
    GameEvents.Subscribe("dota_ability_changed", UpdateAbilityList);
    GameEvents.Subscribe("dota_hero_ability_points_changed", UpdateAbilityList);
    UpdateAbilityList(); // initial update
    $.Schedule(0.1, function() {
        UpdateAbilityList();
    });
    $.Schedule(0.2, function() {
        UpdateAbilityList();
    });
    $.Schedule(0.5, function() {
        UpdateAbilityList();
    });
    $.Schedule(1, function() {
        UpdateAbilityList();
    });
    $.Schedule(2, function() {
        UpdateAbilityList();
    });
    $.Schedule(3, function() {
        UpdateAbilityList();
    });
    $.Schedule(4, function() {
        UpdateAbilityList();
    });
    GameEvents.Subscribe("rpg_update_hero_stats", OnHeroStatsUpdateRequest);
    Init();
    AutoUpdateValues();
})();