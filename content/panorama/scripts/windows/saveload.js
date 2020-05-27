var heroInfoPanel, saveSlots = [];

function ShowHeroInfo() {
    var cursorPosition = GameUI.GetCursorPosition();
    var tooltipX = cursorPosition[0] + 40;
    var tooltipY = cursorPosition[1];
    var overflowX = (tooltipX + heroInfoPanel.actuallayoutwidth) - Game.GetScreenWidth();
    var overflowY = (tooltipY + heroInfoPanel.actuallayoutheight) - Game.GetScreenHeight();
    if(overflowX > 0) {
        tooltipX -= overflowX;
    }
    if(overflowY > 0) {
        tooltipY -= overflowY;
    }
    heroInfoPanel.style.marginLeft = tooltipX + "px";
    heroInfoPanel.style.marginTop = tooltipY + "px";
    heroInfoPanel.style.visibility = "visible";
}

function HideHeroInfo() {
    heroInfoPanel.style.visibility = "collapse";
}

(function() {
    heroInfoPanel = $("#SaveSlotHeroPreview");
    var saveSlotsContainer = $("#SlotsContainer");
    for(var i = 0; i < 6; i++) {
	    var saveSlotPanel = $.CreatePanel("Panel", saveSlotsContainer, "SaveSlot" + i);
		saveSlotPanel.BLoadLayout("file://{resources}/layout/custom_game/windows/saveload/saveload_slot.xml", false, false);
		saveSlotPanel.Data().ShowHeroInfo = ShowHeroInfo;
		saveSlotPanel.Data().HideHeroInfo = HideHeroInfo;
		if(i == 2) {
		    saveSlotPanel.SetHasClass("Empty", true);
		}
		if(i > 2) {
		    saveSlotPanel.SetHasClass("Locked", true);
		}
        saveSlots.push(saveSlotPanel);
    }
})();