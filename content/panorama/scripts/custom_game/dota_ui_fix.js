var chatLinesContainer, chatControls;
var customChatLines = [];
var CHAT_LINE_PANEL = 0, CHAT_LINE_TIME = 1;
var UPDATE_INTERVAL = 0.1;
var CHAT_EXPIRE_TIME = 7 + UPDATE_INTERVAL;

function UpdateValues() {
    for(var i = 0; i < customChatLines.length; i++) {
        customChatLines[i][CHAT_LINE_TIME] -= UPDATE_INTERVAL;
        if(customChatLines[i][CHAT_LINE_TIME] <= UPDATE_INTERVAL) {
            customChatLines[i][CHAT_LINE_PANEL].SetHasClass("NotReallyExpired", false);
            customChatLines[i][CHAT_LINE_TIME] = UPDATE_INTERVAL;
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
    if(event.args != "[]") {
        event.args = JSON.parse(event.args);
        event.args = JSON.parse(event.args);
    } else {
        event.args = [];
    }
    if(event.text.startsWith('#')) {
        event.text = $.Localize(event.text);
    }
    for(var i = 0; i < event.args.length; i++) {
        if(event.args[i].value.toString().startsWith('#')) {
            event.args[i].value = $.Localize(event.args[i].value);
        }
        event.text = event.text.replace(event.args[i].name, event.args[i].value);
    }
    var chatLineText = $.Localize("#DOTA_Chat_Allies").replace("%NAME%", "<font color='" + playerColor + "'>" + Players.GetPlayerName(event.player_id) + "</font>").replace("%TEXT%", event.text);
    chatLineLabel.text = chatLineText;
    heroIcon.SetImage("file://{images}/heroes/" + event.hero + ".png");
    customChatLines.push([chatLine, CHAT_EXPIRE_TIME])
}

function FixCastbarLayout() {
    var customUIContainer = $.GetContextPanel().GetParent();
    var found = false;
    var castbarsContainer;
    for(var i = 0; i < customUIContainer.GetChildCount(); i++) {
        var customContainer = customUIContainer.GetChild(i);
        if(found) {
            break;
        }
        for(var j = 0; j < customContainer.GetChildCount(); j++) {
            var customContainerChild = customContainer.GetChild(j);
            if(customContainerChild.FindChildTraverse('CastbarPanel') != null) {
                found = true;
                castbarsContainer = customContainer;
                break;
            }
        }
    }
    if(found) {
        castbarsContainer.style.zIndex = null;
    }
    return found;
}

function StartCastbarFixTimer() {
    var stopTimer = false;
    if(Game.GameStateIsAfter(DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME)) {
        stopTimer = FixCastbarLayout();
    }
    if(!stopTimer) {
        $.Schedule(0.1, function() {
            StartCastbarFixTimer();
        });
    }
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
    StartCastbarFixTimer();
})();