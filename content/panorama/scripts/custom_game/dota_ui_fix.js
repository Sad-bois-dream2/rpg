var chatLinesContainer;
var TooltipManager = GameUI.CustomUIConfig().TooltipManager;

function GetHEXPlayerColor(playerId) {
	var playerColor = Players.GetPlayerColor(playerId).toString(16);
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}

function OnChatMessageRequest(event) {
    var chatLine = $.CreatePanel("Panel", chatLinesContainer, "");
    chatLine.BLoadLayout("file://{resources}/layout/custom_game/chat_line.xml", false, false);
    chatLine.SetHasClass("NotReallyExpired", true);
    var playerColor = GetHEXPlayerColor(event.player_id);
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
    var playerNamePanel = chatLine.FindChildTraverse('PlayerName');
    playerNamePanel.steamid = event.steamID;
    var playerName = "Unknown";
    if(playerNamePanel) {
        playerNamePanel = playerNamePanel.GetChild(0);
        if(playerNamePanel) {
            playerName = playerNamePanel.text;
        }
    }
    var chatMessage = '<Panel class="CustomHeroBadge" selectionpos="auto" />';
    chatMessage += '<img id="HeroIcon" class="CustomHeroIcon" selectionpos="auto" src="' + 'file://{images}/heroes/' + event.hero + '.png' + '" scaling="stretch-to-fit-preserve-aspect" />';
    chatMessage += ' [' + $.Localize("DOTA_ToolTip_Targeting_Allies") + '] ';
    chatMessage += '<font color="' + playerColor + '">' + playerName + '</font>' + ': ' + event.text;
    var chatLabel = chatLine.FindChildTraverse('ChatLabel');
    chatLabel.text = chatMessage;
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

var DROPPED_ITEM_HITBOX_SIZE = 70;
var latestShowedItemId = -1;

function ShowDroppedItemTooltip() {
    var cursorPosition = GameUI.GetCursorPosition();
    cursorPosition = Game.ScreenXYToWorld(cursorPosition[0], cursorPosition[1]);
    var itemsInWorld = CustomNetTables.GetAllTableValues("inventory_world_items");
    var latestShowedItem = CustomNetTables.GetTableValue("inventory_world_items", latestShowedItemId.toString());
    if(latestShowedItem) {
        if(Game.Length2D(Entities.GetAbsOrigin(latestShowedItem.itemWorldId), cursorPosition) > DROPPED_ITEM_HITBOX_SIZE) {
            TooltipManager.HideItemTooltip();
            latestShowedItemId = -1;
        }
    } else {
        latestShowedItemId = -1;
        $.Each(itemsInWorld, function(item) {
            var itemPosition = Entities.GetAbsOrigin(item.value.itemWorldId);
            if((Game.Length2D(itemPosition, cursorPosition) <= DROPPED_ITEM_HITBOX_SIZE)) {
                var fixedItemStats = []
                $.Each(item.value.itemStats, function(itemStat) {
                    fixedItemStats.push(itemStat);
                });
                TooltipManager.ShowItemTooltip(item.value.itemName, fixedItemStats);
                latestShowedItemId = item.key;
            }
        });
    }
    $.Schedule(0.1, function() {
        ShowDroppedItemTooltip();
    });
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
    GameEvents.Subscribe("rpg_say_chat_message_from_server", OnChatMessageRequest);
    StartCastbarFixTimer();
    ShowDroppedItemTooltip();
    TooltipManager.HideItemTooltip();
})();