var playerLoaded = false;

function CheckPlayerState() {
	if (!playerLoaded) {
		GameEvents.SendCustomGameEventToServer("rpg_hero_selection_check_state",{});
	}
	$.Schedule(1, CheckPlayerState);
}

function OnPlayerLoaded(event) {
    playerLoaded = true;
    $("#Container").BLoadLayout("file://{resources}/layout/custom_game/windows/heroselection/heroselection.xml",false,false);
}

(function(){
	GameEvents.Subscribe( "rpg_hero_selection_check_state_from_server", OnPlayerLoaded);
	var SidebarAndBattleCupLayoutContainer = $.GetContextPanel().GetParent().FindChild("SidebarAndBattleCupLayoutContainer")
	SidebarAndBattleCupLayoutContainer.hittest=false;
	SidebarAndBattleCupLayoutContainer.hittestchildren=false;
	$.Schedule(1,CheckPlayerState);
})()