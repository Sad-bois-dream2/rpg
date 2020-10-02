var talents = [];
var tooltip = [];
var hero = -1;
var totalPointsLabel;

var TALENT_PANEL = 0, TALENT_IMAGE = 1, TALENT_LEVEL = 2, TALENT_ID = 3, TALENT_ABILITY = 4;
var TOOLTIP_PANEL = 0, TOOLTIP_IMAGE = 1, TOOLTIP_NAME = 2, TOOLTIP_DESCRIPTION = 3;

function OnTalentClick(id) {
	GameEvents.SendCustomGameEventToServer("rpg_talenttree_lvlup_talent", {"talent_id" : id});
}

function ShowTalentTooltip(id) {
    var IsHeroLoaded = (hero > -1);
    var cursorPosition = GameUI.GetCursorPosition();
    if(IsHeroLoaded) {
        var talentName, talentDescription;
        var talentImage = talents[id-1][TALENT_PANEL].Data().talentImage;
        talentName = $.Localize("#DOTA_TalentTree_Talent_"+id);
        talentDescription = $.Localize("#DOTA_TalentTree_Talent_"+id+"_Description");
        CreateTalentTooltip(talentImage, talentName, talentDescription, cursorPosition[0], cursorPosition[1]);
    }

}

function HideTalentTooltip(id) {
    tooltip[TOOLTIP_PANEL].style.visibility = "collapse";
}

function OnTalentTreeWindowCloseRequest() {
	var window = $("#MainWindow");
	window.style.visibility = "collapse";
}

function OnTalentTreeButtonClicked() {
	var window = $("#MainWindow");
	window.style.visibility = (window.style.visibility === "collapse") ? "visible" : "collapse";
}

function CreateTalentTooltip(icon, name, description, x, y) {
	tooltip[TOOLTIP_IMAGE].SetImage(icon);
	tooltip[TOOLTIP_NAME].text = name.toUpperCase();
	tooltip[TOOLTIP_DESCRIPTION].text = description;
	if(tooltip[TOOLTIP_PANEL].actuallayoutwidth + x > Game.GetScreenWidth()) {
	    x -= tooltip[TOOLTIP_PANEL].actuallayoutwidth;
	}
	if(tooltip[TOOLTIP_PANEL].actuallayoutheight + y > Game.GetScreenHeight()) {
	    y -= tooltip[TOOLTIP_PANEL].actuallayoutheight;
	}
	tooltip[TOOLTIP_PANEL].style.marginLeft = x + "px";
	tooltip[TOOLTIP_PANEL].style.marginTop = y + "px";
	tooltip[TOOLTIP_PANEL].style.visibility = "visible";
}


function BuildTalentTree() {
	var root = $("#TalentTree");
	var totalLines = 7;
	var totalColumns = 3;
	var talentsPerColumn = 3;
	var talentId = 1;
	for(var i = 0; i < totalLines; i++) {
		var talentsRow = $.CreatePanel("Panel", root, "");
		talentsRow.SetHasClass("TalentsRow", true);
		for(var j = 0; j < totalColumns; j++) {
			var talentsColumn = $.CreatePanel("Panel", talentsRow, "");
			talentsColumn.SetHasClass("TalentsColumn", true);
			for(k = 0; k < talentsPerColumn; k++) {
				var talent = $.CreatePanel("Panel", talentsColumn, "HeroTalent"+talentId);
				talent.SetHasClass("disabled", true);
				talent.BLoadLayout("file://{resources}/layout/custom_game/windows/talenttree/talenttree_talent.xml", false, false);
				talent.Data().ShowTalentTooltip = ShowTalentTooltip;
				talent.Data().HideTalentTooltip = HideTalentTooltip;
				talent.Data().OnTalentClick = OnTalentClick;
				talent.Data().talentImage = "file://{images}/custom_game/hud/talenttree/talent_"+talentId+".png";
				var talentImageAndLevel = talent.GetChild(0);
				var talentImage = talentImageAndLevel.GetChild(0);
				var talentLevel = talentImageAndLevel.GetChild(2);
				var talentAbility = talentImageAndLevel.GetChild(1);
				talentImage.SetImage(talent.Data().talentImage);
				talents.push([talent, talentImage, talentLevel, talentId, talentAbility]);
				talentId++;
			}
		}
	}
}

function OnTalentTreeTotalPointsUpdateRequest(event) {
	totalPointsLabel.text = $.Localize("#DOTA_TalentTree_Total_Talent_Points").replace("%value%", event.amount);
}

function OnTalentTreeStateUpdateRequest(event) {
	var parsedData = JSON.parse(event.data);
	for(var i = 0; i < parsedData.length; i++) {
		var index = parsedData[i].talent_id - 1;
		talents[index][TALENT_PANEL].SetHasClass("disabled", parsedData[i].disabled);
		talents[index][TALENT_PANEL].SetHasClass("lvlup", parsedData[i].lvlup);
		talents[index][TALENT_LEVEL].text = parsedData[i].level + " / " + parsedData[i].maxlevel;
	}
}

var TalentsDataRequired = false;
function UpdateValues() {
	if(hero == -1) {
		var localPlayer = Players.GetLocalPlayer();
		hero = Players.GetPlayerHeroEntityIndex(localPlayer);
	} else {
		if(!TalentsDataRequired) {
	        BuildTalentTree();
			GameEvents.SendCustomGameEventToServer("rpg_talenttree_require_player_talents_state", {});
			TalentsDataRequired = true;
		}
	}
}

function AutoUpdateValues() {
    UpdateValues();
    $.Schedule(0.1, function() {
        AutoUpdateValues();
    });
}

(function() {
	tooltip = [$("#ItemTooltip"), $("#ItemTooltipImage"), $("#ItemTooltipNameLabel"), $("#ItemTooltipLabel")];
	totalPointsLabel = $("#TotalTalentPointsLabel");
	GameEvents.Subscribe("rpg_talenttree_open_window_from_server", OnTalentTreeButtonClicked);
	GameEvents.Subscribe("rpg_talenttree_close_window_from_server", OnTalentTreeWindowCloseRequest);
	GameEvents.Subscribe("rpg_talenttree_require_player_talents_state_from_server", OnTalentTreeStateUpdateRequest);
	GameEvents.Subscribe("rpg_talenttree_update_total_talents_points", OnTalentTreeTotalPointsUpdateRequest);
	AutoUpdateValues();
})();