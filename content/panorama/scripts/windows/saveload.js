var SAVE_CD = 30;
var mainWindow, heroInfoPanel, saveSlots = [], saveSlotsContainer;
var saveSlotsAdded = false;
var welcomeSoundCooldown = -1, errorSoundCooldown = -1;
var slotItemsData = [];

function UpdateSelection() {
    var selectedUnit = Players.GetLocalPlayerPortraitUnit();
    var localPlayer = Game.GetLocalPlayerID()
    if(Entities.GetUnitName(selectedUnit) == "npc_save_unit" && Game.Length2D(Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex(localPlayer)), Entities.GetAbsOrigin(selectedUnit)) <= 800) {
        GameEvents.SendCustomGameEventToServer("rpg_close_all_windows", { "player_id" : localPlayer});
        GameEvents.SendCustomGameEventToServer("rpg_saveload_open_window", { "player_id" : localPlayer});
        if(welcomeSoundCooldown < 0) {
            var responses = ["oracle_orac_move_32", "oracle_orac_move_09", "oracle_orac_move_14",
            "oracle_orac_move_21", "oracle_orac_move_20", "oracle_orac_attack_06",
            "oracle_orac_respawn_10", "oracle_orac_respawn_01", "oracle_orac_death_06", "oracle_orac_kill_05"]
            if(Math.random() < 0.05) {
                responses =["oracle_orac_death_11"];
            }
            Game.EmitSound(responses[Math.floor(Math.random() * responses.length)]);
            welcomeSoundCooldown = 3;
            StartWelcomeSoundCooldown();
        }
    }
}

function StartErrorSoundCooldown() {
    errorSoundCooldown = errorSoundCooldown - 0.1;
    if(errorSoundCooldown > 0) {
        $.Schedule(0.1, function() {
            StartErrorSoundCooldown();
        });
    }
}

function StartWelcomeSoundCooldown() {
    welcomeSoundCooldown = welcomeSoundCooldown - 0.1;
    if(welcomeSoundCooldown > 0) {
        $.Schedule(0.1, function() {
            StartWelcomeSoundCooldown();
        });
    }
}

function RemoveCooldownSpinner() {
    mainWindow.SetHasClass("SaveHeroInProcess", false);
    saveSlotsContainer.hittest = true;
    saveSlotsContainer.hittestchildren = true;
}

function OnSaveSlotClick(id) {
    if(saveSlots[id].BHasClass("Locked")) {
        return;
    }
    Game.EmitSound("General.SelectAction");
    mainWindow.SetHasClass("SaveHeroInProcess", true);
    saveSlotsContainer.hittest = false;
    saveSlotsContainer.hittestchildren = false;
    GameEvents.SendCustomGameEventToServer("rpg_saveload_save_hero", { "slot" : id});
}

function OnSaveLoadResultResponse() {
    var responses = ["oracle_orac_fatesedict_10", "oracle_orac_fatesedict_13", "oracle_orac_falsepromise_01", "oracle_orac_levelup_08", "oracle_orac_kill_05"];
    Game.EmitSound(responses[Math.floor(Math.random() * responses.length)]);
    RemoveCooldownSpinner();
    GameEvents.SendCustomGameEventToServer("rpg_saveload_get_slots_for_hero", {});
}

function OnSaveLoadRemoveCooldownRequest() {
        if(errorSoundCooldown < 0) {
            var responses = ["oracle_orac_falsepromise_03", "oracle_orac_lose_04", "oracle_orac_notyet_01", "oracle_orac_notyet_04", "oracle_orac_notyet_07"];
            Game.EmitSound(responses[Math.floor(Math.random() * responses.length)]);
            errorSoundCooldown = 3;
            StartErrorSoundCooldown();
        }
    RemoveCooldownSpinner();
}

function OnWindowOpenRequest(event) {
	mainWindow.style.visibility = "visible";
}

function OnWindowCloseRequest(event) {
	mainWindow.style.visibility = "collapse";
}

function OnPlayerSaveSlotsData(event) {
    if(saveSlotsAdded) {
        var slotsData = JSON.parse(event.data);
        for(var i =0; i < slotsData.length; i++) {
            saveSlots[slotsData[i].slotNumber].SetHasClass("Locked", !!+slotsData[i].locked);
            saveSlots[slotsData[i].slotNumber].SetHasClass("New", !!+slotsData[i].new);
            var heroLevelLabel = saveSlots[slotsData[i].slotNumber].FindChildTraverse('SaveSlotLevelLabel');
            heroLevelLabel.text = $.Localize("#DOTA_SaveLoad_HeroLevel").replace("%LVL%", slotsData[i].heroLevel);
        }
    } else {
        $.Schedule(0.1, function() {
            OnPlayerSaveSlotsData(event);
        });
    }
}

function SetupDefaultValuesForSaveSlots() {
    var localPlayer = Players.GetLocalPlayer();
    if(Players.IsSpectator(localPlayer)) {
        saveSlotsAdded = true;
        return;
    }
    var playerHero = Players.GetPlayerHeroEntityIndex(localPlayer);
    if(playerHero > 0) {
        var heroName = Entities.GetUnitName(playerHero);
         for(var i = 0; i < saveSlots.length; i++) {
            var heroNameLabel = saveSlots[i].FindChildTraverse('SaveSlotNameLabel');
            heroNameLabel.text = $.Localize("#" + heroName);
            var heroIcon = saveSlots[i].FindChildTraverse('SaveSlotHeroIcon');
            heroIcon.heroname = heroName;
            if(i > 0) {
                saveSlots[i].SetHasClass("Locked", true);
            }
        }
        saveSlotsAdded = true;
    } else {
        $.Schedule(0.1, function() {
            SetupDefaultValuesForSaveSlots();
        });
    }
}

(function() {
    mainWindow = $("#MainWindow");
    heroInfoPanel = $("#SaveSlotHeroPreview");
    saveSlotsContainer = $("#SlotsContainer");
    for(var i = 0; i < 3; i++) {
	    var saveSlotPanel = $.CreatePanel("Panel", saveSlotsContainer, "SaveSlot" + i);
		saveSlotPanel.BLoadLayout("file://{resources}/layout/custom_game/windows/saveload/saveload_slot.xml", false, false);
		saveSlotPanel.Data().OnSaveSlotClick = OnSaveSlotClick;
        saveSlots.push(saveSlotPanel);
    }
    SetupDefaultValuesForSaveSlots();
    GameEvents.SendCustomGameEventToServer("rpg_saveload_get_slots_for_hero", {});
    GameEvents.Subscribe("dota_player_update_query_unit", UpdateSelection);
    GameEvents.Subscribe("dota_player_update_selected_unit", UpdateSelection);
    GameEvents.Subscribe("rpg_saveload_open_window_from_server", OnWindowOpenRequest);
    GameEvents.Subscribe("rpg_saveload_close_window_from_server", OnWindowCloseRequest);
    GameEvents.Subscribe("rpg_saveload_save_hero_from_server", OnSaveLoadResultResponse);
    GameEvents.Subscribe("rpg_saveload_remove_cooldown", OnSaveLoadRemoveCooldownRequest);
    GameEvents.Subscribe("rpg_saveload_get_slots_for_hero_from_server", OnPlayerSaveSlotsData);

})();