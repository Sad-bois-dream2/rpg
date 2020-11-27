var TALENT_PANEL = 0, TALENT_IMAGE = 1, TALENT_LEVEL = 2, TALENT_ID = 3;
var TALENTS_CONTAINER, TALENTS_WINDOW;

var TALENTS_LAYOUT = {
    "lastColumn": -1
};
var talentsData = {
    "talentsCount": 0,
};

var TooltipManager = GameUI.CustomUIConfig().TooltipManager;

function OnTalentTreeData(event) {
    var parsedTalents = JSON.parse(event.talents);
    for(var i=0; i < parsedTalents.length; i++) {
        talentsData[parsedTalents[i].id] = parsedTalents[i].data
    }
    BuildTalentTree(parsedTalents);
    talentsData.talentsCount += parsedTalents.length;
    if(talentsData.talentsCount >= event.count) {
	    GameEvents.SendCustomGameEventToServer( "rpg_talent_tree_get_state", {});
	    TALENTS_LAYOUT[TALENTS_LAYOUT["lastColumn"]].SetHasClass("last", true);
    }
}


function OnTalentTreeState(event) {
    var talentPoints = event.points;
    var parsedStateData = JSON.parse(event.talents);
    for(var i=0; i < parsedStateData.length; i++) {
        var talentId = parsedStateData[i].id;
        var talentColumn = talentsData[talentId].Column;
        var talentRow = talentsData[talentId].Row;
        var isTalentMissLevels = (parsedStateData[i].level < parsedStateData[i].maxlevel)
        talentsData[talentId].panel.SetHasClass("disabled", parsedStateData[i].disabled);
        talentsData[talentId].panel.SetHasClass("lvlup", isTalentMissLevels && parsedStateData[i].disabled == false);
        talentsData[talentId].panel.levelLabel.text = parsedStateData[i].level + " / " + parsedStateData[i].maxlevel;
    }
    TALENTS_LAYOUT["TalentPointsLabel"].text = $.Localize("DOTA_TalentTree_Total_Talent_Points").replace("%value%", talentPoints);
}

function BuildTalentTree(parsedTalents) {
    for (var key in parsedTalents) {
        var talentColumn = parsedTalents[key].data["Column"];
        var talentRow = parsedTalents[key].data["Row"];
        CreateTalentPanel(talentRow, talentColumn, parsedTalents[key].id);
    }
}

function CreateTalentPanel(row, column, talentId) {
    if (TALENTS_LAYOUT[column]) {
        if (TALENTS_LAYOUT[column][row]) {
            var talentPanel = $.CreatePanel("Panel", TALENTS_LAYOUT[column][row], "HeroTalent" + talentId);
            talentPanel.BLoadLayout("file://{resources}/layout/custom_game/windows/talenttree/talenttree_talent.xml", false, false);
            talentPanel.hittest = true;
            talentPanel.hittestchildren = false;
			talentPanel.Data().ShowTalentTooltip = ShowTalentTooltip;
			talentPanel.Data().HideTalentTooltip = HideTalentTooltip;
			talentPanel.Data().OnTalentClick = OnTalentClick;
			var talentImagePanel = talentPanel.FindChildTraverse("TalentImage");
			if(talentImagePanel) {
			    talentImagePanel.SetImage(talentsData[talentId].Icon);
			}
			if(column > TALENTS_LAYOUT["lastColumn"]) {
			    TALENTS_LAYOUT["lastColumn"] = column;
			}
			talentsData[talentId].panel = talentPanel;
			talentsData[talentId].panel.levelLabel = talentPanel.FindChildTraverse("TalentLevel");
        } else {
            TALENTS_LAYOUT[column][row] = CreateTalentRow(row, column);
            CreateTalentPanel(row, column, talentId);
        }
    } else {
        var talentColumnPanel = $.CreatePanel("Panel", TALENTS_CONTAINER, "");
        talentColumnPanel.SetHasClass("TalentsColumn", true);
        TALENTS_LAYOUT[column] = talentColumnPanel;
        talentColumnPanel.hittest = false;
        talentColumnPanel.hittestchildren = true;
        CreateTalentPanel(row, column, talentId);
    }
}

function CreateTalentRow(row, column) {
    if (TALENTS_LAYOUT[column]) {
        var talentRowPanel = $.CreatePanel("Panel", TALENTS_LAYOUT[column], "");
        talentRowPanel.SetHasClass("TalentsRow", true);
        return talentRowPanel
    }
}

function ShowTalentTooltip(id) {
    var talentImage = talentsData[id].Icon
    var talentName = $.Localize("#DOTA_TalentTree_Talent_"+id);
    var talentDescription = $.Localize("#DOTA_TalentTree_Talent_"+id+"_Description");
    TooltipManager.ShowTalentTooltip(talentImage, talentName, talentDescription);
}

function HideTalentTooltip() {
    TooltipManager.HideTalentTooltip();
}

function OnTalentClick(talentId) {
    HideTalentTooltip()
    GameEvents.SendCustomGameEventToServer( "rpg_talent_tree_level_up_talent", {"id": talentId});
    Game.EmitSound("General.SelectAction");
}

function OnTalentTreeWindowOpenRequest(event) {
    TALENTS_WINDOW.style.visibility = "visible";
}

function OnTalentTreeWindowCloseRequest(event) {
    TALENTS_WINDOW.style.visibility = "collapse";
}

function OnTalentTreeResetButtonClick() {
    GameEvents.SendCustomGameEventToServer( "rpg_talent_tree_reset_talents", {});
    Game.EmitSound("General.SelectAction");
}

(function() {
    TALENTS_WINDOW = $("#MainWindow")
    TALENTS_CONTAINER = $("#TalentTree");
    TALENTS_LAYOUT["TalentPointsLabel"] = $("#TotalTalentPointsLabel");
    GameEvents.Subscribe("rpg_talent_tree_get_talents_from_server", OnTalentTreeData);
    GameEvents.Subscribe("rpg_talent_tree_get_state_from_server", OnTalentTreeState);
	GameEvents.Subscribe("rpg_talent_tree_open_window_from_server", OnTalentTreeWindowOpenRequest);
	GameEvents.Subscribe("rpg_talent_tree_close_window_from_server", OnTalentTreeWindowCloseRequest);
	GameEvents.SendCustomGameEventToServer( "rpg_talent_tree_get_talents", {});
})();