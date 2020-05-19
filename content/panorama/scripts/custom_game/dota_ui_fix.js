var chatLinesContainer, chatControls;
var customChatLines = [];
var CHAT_LINE_PANEL = 0, CHAT_LINE_TIME = 1;
var UPDATE_INTERVAL = 0.1;
var CHAT_EXPIRE_TIME = 7 + UPDATE_INTERVAL;

function UpdateValues() {
    for(var i = 0; i < customChatLines.length; i++) {
        if(customChatLines[i][CHAT_LINE_TIME] > UPDATE_INTERVAL) {
            customChatLines[i][CHAT_LINE_TIME] -= UPDATE_INTERVAL;
        }
        if(customChatLines[i][CHAT_LINE_TIME] <= UPDATE_INTERVAL) {
            customChatLines[i][CHAT_LINE_PANEL].SetHasClass("NotReallyExpired", false);
        }
    }
}

function AutoUpdateValues() {
    UpdateValues();
    $.Schedule(UPDATE_INTERVAL, function() {
        AutoUpdateValues();
    });
}


function GetHEXPlayerColor(playerId) {
	var playerColor = Players.GetPlayerColor(playerId).toString(16);
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}

function OnChatMessageRequest(event) {
    var chatLine = $.CreatePanel("Panel", chatLinesContainer, "");
    chatLine.BLoadLayout("file://{resources}/layout/custom_game/chat_line.xml", false, false);
    var heroIcon = chatLine.FindChildTraverse('HeroIcon');
    var chatLineLabel = chatLine.FindChildTraverse('ChatLabel');
    chatLine.SetHasClass("NotReallyExpired", true);
    var playerColor = GetHEXPlayerColor(0);
    var chatLineText = $.Localize("#DOTA_Chat_Allies").replace("%NAME%", "<font color='" + playerColor + "'>" + Players.GetPlayerName(event.player_id) + "</font>").replace("%TEXT%", event.text);
    chatLineLabel.text = chatLineText;
    customChatLines.push([chatLine, CHAT_EXPIRE_TIME])
}

(function() {
    var base = $.GetContextPanel().GetParent().GetParent().GetParent();
    var kdaPanel = base.FindChildTraverse('quickstats');
    kdaPanel.style.visibility = "collapse";
    var killCam = base.FindChildTraverse('KillCam');
    killCam.style.visibility = "collapse";
    var minimapButtons = base.FindChildTraverse('GlyphScanContainer');
    minimapButtons.style.visibility = "collapse";
    var minimapSkin = base.FindChildTraverse('HUDSkinMinimap');
    minimapSkin.style.visibility = "collapse";
    var minimapPanel = base.FindChildTraverse('minimap_block');
    minimapPanel.style.borderColor = "#FF0000FF";
    minimapPanel.style.border = "1px solid gray";
    minimapPanel.style.borderRadius = "10px";
    minimapPanel.style.width = "260px";
    minimapPanel.style.height = "260px";
    minimapPanel.style.backgroundImage = "url('s2r://panorama/images/backgrounds/gallery_background_png.vtex')";
    var minimap = base.FindChildTraverse('minimap');
    minimap.style.width = "245px";
    minimap.style.height = "245px";
    minimap.style.borderRadius = "10px";
    chatLinesContainer = base.FindChildTraverse('ChatLinesPanel');
    chatControls = base.FindChildTraverse('ChatControls');
    GameEvents.Subscribe("rpg_say_chat_message_from_server", OnChatMessageRequest);
    AutoUpdateValues();
})();