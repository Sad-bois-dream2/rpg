"use strict"
var Heroes = [];
var HeroesInitialized = [];
var HP_BAR = 0,
    HP_BAR_VALUE = 1,
    HP_BAR_REG_VALUE = 2,
    MP_BAR = 3,
    MP_BAR_VALUE = 4,
    MP_BAR_REG_VALUE = 5,
    EXP_BAR = 6,
    EXP_BAR_VALUE = 7,
    LEVEL_BAR_VALUE = 8,
    HERO_ENTITY = 9,
    HERO_PORTRAIT = 10,
	HERO_PANEL = 11,
	PLAYER_ID = 12,
	PLAYER_PORTRAIT_FIXED = 13,
	DEATH_TIMER = 14,
	HERO_OWNER_NAME = 15;

var MAX_PLAYERS = 5;

function OnPortraitClick(id) {
	var IsAltDown = GameUI.IsAltDown();
    var hero = Heroes[id][HERO_ENTITY];
    Players.PlayerPortraitClicked(Heroes[id][PLAYER_ID], false, false );
	if(IsAltDown) {
		var player = Players.GetLocalPlayer();
		var message;
		var IsDead = (Entities.GetHealth(hero) < 1);
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
		var message = IsDead ? "#DOTA_Chat_Ally_is_dead" : "#DOTA_Chat_Ally_is_alive";
		GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message, "args": JSON.stringify(args)});
	}
}


function OnHPBarClick(id) {
	var IsAltDown = GameUI.IsAltDown();
	if(IsAltDown) {
        var hero = Heroes[id][HERO_ENTITY];
		var player = Players.GetLocalPlayer();
		var currentHp = Entities.GetHealth(hero);
		var maxHp = Entities.GetMaxHealth(hero);
		var hpPercent = (currentHp / maxHp) * 100;
		hpPercent = Math.round(hpPercent * 100) / 100;
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
        GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : "#DOTA_Chat_Ally_health", "args": JSON.stringify(args)});
	}
}

function OnMPBarClick(id) {
	var IsAltDown = GameUI.IsAltDown();
	if(IsAltDown) {
        var hero = Heroes[id][HERO_ENTITY];
		var player = Players.GetLocalPlayer();
		var currentMp = Entities.GetMana(hero);
		var maxMp = Entities.GetMaxMana(hero);
		var mpPercent = (currentMp / maxMp) * 100;
		mpPercent = Math.round(mpPercent * 100) / 100;
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
        GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : "#DOTA_Chat_Ally_mana", "args": JSON.stringify(args)});
	}
}

function OnExpBarClick(id) {
	var IsAltDown = GameUI.IsAltDown();
	if(IsAltDown) {
        var hero = Heroes[id][HERO_ENTITY];
		var player = Players.GetLocalPlayer();
        var currentExp = Entities.GetCurrentXP(hero);
        var maxExp = Entities.GetNeededXPToLevel(hero);
        var expPercent = (currentExp / maxExp) * 100;
		expPercent = Math.round((100-expPercent) * 100) / 100;
		var message;
		if(maxExp == 0) {
			message = "#DOTA_Chat_Ally_maxlevel"
		} else {
			message = "#DOTA_Chat_Ally_needxp";
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

function OnLvlBarClick(id) {
	var IsAltDown = GameUI.IsAltDown();
	if(IsAltDown) {
        var hero = Heroes[id][HERO_ENTITY];
		var player = Players.GetLocalPlayer();
        var currentLevel = Entities.GetLevel(hero);
        var maxExp = Entities.GetNeededXPToLevel(hero);
		var message;
		if(maxExp == 0) {
			message = "#DOTA_Chat_Ally_maxlevel";
		} else {
			message = "#DOTA_Chat_Ally_level";
		}
		var args = [
            {
                "name" : "%HERO%",
                "value" : "#" + Entities.GetUnitName(hero)
            },
        	{
        	    "name" : "%LEVEL%",
        		"value" : Entities.GetLevel(hero)
        	}
        ];
        GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message, "args": JSON.stringify(args)});
	}
}


function UpdateValues() {
	var IsAltDown = GameUI.IsAltDown();
    for (var i = 0; i < Heroes.length; i++) {
        var hero = Heroes[i][HERO_ENTITY];
		var IsPlayerLoaded = (hero > -1);
		Heroes[i][HERO_PANEL].style.visibility = IsPlayerLoaded ? "visible" : "collapse";
        if (IsPlayerLoaded) {
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
			Heroes[i][HERO_PORTRAIT].SetHasClass("is_dead", IsDead);
			Heroes[i][DEATH_TIMER].style.visibility = IsDead ? "visible" : "collapse";
			if(IsDead) {
				var respawnTime = Players.GetRespawnSeconds(Entities.GetPlayerOwnerID(hero));
				if(respawnTime > 9999) {
					respawnTime = "";
				}
				Heroes[i][DEATH_TIMER].text = respawnTime;
			}
            Heroes[i][HP_BAR].style.width = Math.floor(hpPercent) + "%";
			if(IsAltDown) {
				Heroes[i][HP_BAR_VALUE].text = (Math.round(hpPercent * 100) / 100) + "%";
			} else {
				Heroes[i][HP_BAR_VALUE].text = currentHp + " / " + maxHp;
			}
            Heroes[i][HP_BAR_REG_VALUE].text = "+" + (Math.round(hpReg * 100) / 100);
            Heroes[i][MP_BAR].style.width = Math.floor(mpPercent) + "%";
			if(IsAltDown) {
				Heroes[i][MP_BAR_VALUE].text = (Math.round(mpPercent * 100) / 100) + "%";
			} else {
				Heroes[i][MP_BAR_VALUE].text = currentMp + " / " + maxMp;
			}
            Heroes[i][MP_BAR_REG_VALUE].text = "+" + (Math.round(mpReg * 100) / 100);
			if(maxExp == 0) {
				expPercent = 100;
			}
            Heroes[i][EXP_BAR].style.width = Math.floor(expPercent) + "%";
            if (IsAltDown) {
                Heroes[i][EXP_BAR_VALUE].text = currentExp + " / " + maxExp;
            } else {
                Heroes[i][EXP_BAR_VALUE].text = Math.floor(expPercent) + "%";
            }
            if (IsAltDown && Heroes[i][HERO_PANEL].BHasClass("Small")) {
				Heroes[i][LEVEL_BAR_VALUE].text = Math.floor(expPercent) + "%";
			} else {
				Heroes[i][LEVEL_BAR_VALUE].text = currentLevel;
			}
			Heroes[i][HERO_OWNER_NAME].text = Players.GetPlayerName(Heroes[i][PLAYER_ID]);
			Heroes[i][HERO_OWNER_NAME].style.color = GetHEXPlayerColor(Heroes[i][PLAYER_ID]);
			if(!Heroes[i][PLAYER_PORTRAIT_FIXED]) {
				Heroes[i][HERO_PORTRAIT].SetUnit(Entities.GetUnitName(hero), "1", true);
				Heroes[i][PLAYER_PORTRAIT_FIXED] = true;
			}
        } else {
			Heroes[i][HERO_ENTITY] = Players.GetPlayerHeroEntityIndex(Heroes[i][PLAYER_ID]);
		}
    }
}

function GetHEXPlayerColor(playerId) {
	var playerColor = Players.GetPlayerColor(playerId).toString(16);
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}


function AutoUpdateValues() {
    UpdateValues();
    $.Schedule(0.1, function() {
        AutoUpdateValues();
    });
}

function ChangePanelSize() {
	var IsSmall = Heroes[0][HERO_PANEL].BHasClass("Small");
	for(var i = 0; i < Heroes.length; i++) {
		Heroes[i][HERO_PANEL].SetHasClass("Small", !IsSmall);
	}		
}

function Init() {
    var root = $.GetContextPanel();
	var localPlayerId = Players.GetLocalPlayer();
	var IsFirstTime = true;
    for (var i = 0; i < MAX_PLAYERS; i++) {
        var isValidPlayer = Players.IsValidPlayerID(i) && !Players.IsSpectator(i);
        if (isValidPlayer && localPlayerId != i) {
            var heroPanel = $.CreatePanel("Panel", root, "Hero" + (i-1));
            heroPanel.BLoadLayout("file://{resources}/layout/custom_game/party_member.xml", false, false);
			heroPanel.Data().ChangePanelSize = ChangePanelSize;
			heroPanel.Data().OnHPBarClick = OnHPBarClick;
			heroPanel.Data().OnMPBarClick = OnMPBarClick;
			heroPanel.Data().OnExpBarClick = OnExpBarClick;
			heroPanel.Data().OnPortraitClick = OnPortraitClick;
			heroPanel.Data().OnLvlBarClick = OnLvlBarClick;
            var heroEntityIndex = Players.GetPlayerHeroEntityIndex(i);
            var hero = heroPanel.FindChildTraverse("HeroPortraitPanel");
			var heroOwnerName = heroPanel.FindChildTraverse("HeroOwnerName");
            var hpBar = heroPanel.FindChildTraverse("HeroHpBar");
            var hpBarCurrentValue = heroPanel.FindChildTraverse("HeroHpBarValue");
            var hpBarRegValue = heroPanel.FindChildTraverse("HeroHpBarRegValue");
            var mpBar = heroPanel.FindChildTraverse("HeroMpBar");
            var mpBarCurrentValue = heroPanel.FindChildTraverse("HeroMpBarValue");
            var mpBarRegValue = heroPanel.FindChildTraverse("HeroMpBarRegValue");
            var expBar = heroPanel.FindChildTraverse("HeroExpBar");
            var expBarCurrentValue = heroPanel.FindChildTraverse("HeroExpBarValue");
            var heroPortrait = heroPanel.FindChildTraverse("HeroPortrait");
            var levelBarPanel = heroPanel.FindChildTraverse("LevelBar");
            var levelBarValue = heroPanel.FindChildTraverse("LevelBarValue");
			var playerPortraitFixed = false;
			var deathTimer = heroPanel.FindChildTraverse("HeroDeathTimer");
			if(IsFirstTime) {
			    var changeSizeBtn = heroPanel.FindChildTraverse("ChangePanelSizeButton");
			    if(changeSizeBtn != null) {
			        changeSizeBtn.style.visibility = "visible";
			    }
			    IsFirstTime = false;
			}
            Heroes.push([hpBar, hpBarCurrentValue, hpBarRegValue, mpBar, mpBarCurrentValue, mpBarRegValue, expBar, expBarCurrentValue, levelBarValue, heroEntityIndex, heroPortrait, hero, i, playerPortraitFixed, deathTimer, heroOwnerName]);
        }
    }
    AutoUpdateValues();
}

(function() {
    Init();
})();