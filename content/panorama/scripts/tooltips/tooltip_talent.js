var TOOLTIP_TALENT_PANEL = 0;
var TOOLTIP_TALENT_IMAGE = 1;
var TOOLTIP_TALENT_NAME_LABEL = 2;
var TOOLTIP_TALENT_DESCRIPTION_LABEL = 3;

var TooltipManager = GameUI.CustomUIConfig().TooltipManager;

TooltipManager.ShowTalentTooltip = function(icon, name, description) {
    var cursorPosition = GameUI.GetCursorPosition();
    UpdateTalentTooltip(icon, name, description, cursorPosition[0], cursorPosition[1]);
};

TooltipManager.HideTalentTooltip = function() {
    TooltipManager.talentTooltipContainer[TOOLTIP_TALENT_PANEL].style.visibility = "collapse";
};

function UpdateTalentTooltip(icon, name, description, x, y) {
    TooltipManager.talentTooltipContainer[TOOLTIP_TALENT_IMAGE].SetImage(icon);
    TooltipManager.talentTooltipContainer[TOOLTIP_TALENT_NAME_LABEL].text = name.toUpperCase();
    var talentDescription = TooltipManager.FindAndReplaceStatIconsMarkers(description);
    talentDescription = TooltipManager.FindAndFixPercents(talentDescription);
    TooltipManager.talentTooltipContainer[TOOLTIP_TALENT_DESCRIPTION_LABEL].text = talentDescription;
    if (TooltipManager.talentTooltipContainer[TOOLTIP_TALENT_PANEL].actuallayoutwidth + x > Game.GetScreenWidth()) {
        x -= TooltipManager.talentTooltipContainer[TOOLTIP_TALENT_PANEL].actuallayoutwidth;
    }
    if (TooltipManager.talentTooltipContainer[TOOLTIP_TALENT_PANEL].actuallayoutheight + y > Game.GetScreenHeight()) {
        y -= TooltipManager.talentTooltipContainer[TOOLTIP_TALENT_PANEL].actuallayoutheight;
    }
    TooltipManager.talentTooltipContainer[TOOLTIP_TALENT_PANEL].style.marginLeft = x + "px";
    TooltipManager.talentTooltipContainer[TOOLTIP_TALENT_PANEL].style.marginTop = y + "px";
    TooltipManager.talentTooltipContainer[TOOLTIP_TALENT_PANEL].style.visibility = "visible";
}

function CreateTalentTooltip() {
    var root = $.GetContextPanel();
    var talentTooltipRoot = root.FindChildTraverse("TalentTooltipHeader");
    if (talentTooltipRoot) {
        var talentTooltip = [
            talentTooltipRoot.GetParent(),
            $("#TalentTooltipImage"),
            $("#TalentTooltipNameLabel"),
            $("#TalentTooltipTextLabel")
        ];
        GameUI.CustomUIConfig().TooltipManager.talentTooltipContainer = talentTooltip;
    }
}

(function() {
    CreateTalentTooltip();
})();