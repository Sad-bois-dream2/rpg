"use strict"
var INVENTORY_SLOTS_PER_ROW = 14;
var INVENTORY_SLOT_ROWS = 7;
var INVENTORY_SLOTS_COUNT = INVENTORY_SLOTS_PER_ROW * INVENTORY_SLOT_ROWS;
var INVENTORY_SLOT_LAST = 11;
var inventorySlots = [];
var inventoryEquippedSlots = [];
var SLOT_PANEL = 0, SLOT_ITEM_IMAGE = 1, SLOT_ITEM_STATS = 2, SLOT_ITEM_BORDER = 3;
var ELEMENTS_DEFENSIVE = "D", ELEMENTS_OFFENSIVE = "O";
var defensiveElePanels = [], offensiveElePanels = [];
var ELEMENT_PANEL = 0, ELEMENT_VALUE = 1;
var pagePanels = [], pageButtons = [];
var currentHero = -1;
var ELEMENTS = [
	["Fire", "file://{images}/custom_game/hud/stats/fire_element.png"],
	["Frost", "file://{images}/custom_game/hud/stats/frost_element.png"],
	["Earth", "file://{images}/custom_game/hud/stats/earth_element.png"],
	["Nature", "file://{images}/custom_game/hud/stats/nature_element.png"],
	["Void", "file://{images}/custom_game/hud/stats/void_element.png"],
	["Inferno", "file://{images}/custom_game/hud/stats/inferno_element.png"],
	["Holy", "file://{images}/custom_game/hud/stats/holy_element.png"]
];

var TooltipManager = GameUI.CustomUIConfig().TooltipManager;
var ItemsDatabase = GameUI.CustomUIConfig().ItemsDatabase;
var PlayerInventory = GameUI.CustomUIConfig().PlayerInventory;

function SetupDragAndDropForInventoryEquippedSlots() {
	for(var i = 0; i < inventoryEquippedSlots.length; i++) {
		$.RegisterEventHandler( 'DragStart', inventoryEquippedSlots[i][SLOT_PANEL].id, OnInventoryEquippedSlotDragStart );
		$.RegisterEventHandler( 'DragEnd', inventoryEquippedSlots[i][SLOT_PANEL].id, OnInventoryEquippedSlotDragEnd);
	}
}

function OnInventoryEquippedSlotDragStart( panelId, dragCallbacks ) {
	var slotId = parseInt(panelId.id.replace("InventoryEquippedSlot", ""));
	if(inventoryEquippedSlots[slotId][SLOT_PANEL].BHasClass("empty")) {
		return true;
	}
	HideItemTooltip();
    var displayPanel = $.CreatePanel( "DOTAItemImage", $.GetContextPanel(), "");
	displayPanel.SetHasClass("InventorySlot", true);
	displayPanel.style.width = inventorySlots[0][SLOT_PANEL].actuallayoutwidth + "px";
	displayPanel.itemname = inventoryEquippedSlots[slotId][SLOT_ITEM_IMAGE].itemname;
    dragCallbacks.displayPanel = displayPanel;
    dragCallbacks.offsetX = 0; 
    dragCallbacks.offsetY = 0;
	var itemRarity = ItemsDatabase.GetItemRarity(displayPanel.itemname);
    displayPanel.style.borderColor = ItemsDatabase.GetItemRarityColor(itemRarity);
    displayPanel.SetHasClass("InventorySlotDragged", true);
} 

function OnInventoryEquippedSlotDragEnd( panelId, draggedPanel ) {
	draggedPanel.DeleteAsync(0);
	var slotInfo = GetSlotUnderUserCursor();
	var slotFromId = parseInt(panelId.id.replace("InventoryEquippedSlot", ""));
	var slotInId = slotInfo[0];
	var IsSlotFinded = slotInId > -1;
	var IsEquipped = slotInfo[1];
	var IsInsideInventoryWindow = slotInfo[2];
	var item = inventoryEquippedSlots[slotFromId][SLOT_ITEM_IMAGE].itemname;
	if(IsSlotFinded) {
		if(!IsEquipped) {
			var jsonEncodedData = JSON.stringify({"player_id" : Players.GetLocalPlayer(), "fromslot" : slotFromId, "inslot" : slotInId, "equipped": true});
			GameEvents.SendCustomGameEventToServer("rpg_inventory_swap_items", {"data" : jsonEncodedData});
		}
	} else {
		if(!IsInsideInventoryWindow) {
			var jsonEncodedData = JSON.stringify({ "player_id" : Players.GetLocalPlayer(), "slot" : slotFromId, "item": item, "equipped" : true});
			GameEvents.SendCustomGameEventToServer("rpg_inventory_drop_item_on_ground", {"data" : jsonEncodedData});
		}
	}
} 

function OnInventorySlotDragStart( panelId, dragCallbacks ) {
	var slotId = parseInt(panelId.id.replace("InventorySlot", ""));
	if(inventorySlots[slotId][SLOT_ITEM_IMAGE].itemname == "") {
		return true;
	}
    var displayPanel = $.CreatePanel( "DOTAItemImage", $.GetContextPanel(), "");
	displayPanel.SetHasClass("InventorySlot", true);
	displayPanel.style.width = inventorySlots[slotId][SLOT_PANEL].actuallayoutwidth + "px";
	HideItemTooltip();
	displayPanel.itemname = inventorySlots[slotId][SLOT_ITEM_IMAGE].itemname;
    dragCallbacks.displayPanel = displayPanel;
    dragCallbacks.offsetX = 0; 
    dragCallbacks.offsetY = 0;
    var desiredInventorySlot = ItemsDatabase.GetItemSlot(inventorySlots[slotId][SLOT_ITEM_IMAGE].itemname);
    if(desiredInventorySlot > -1) {
        inventoryEquippedSlots[desiredInventorySlot][SLOT_PANEL].SetHasClass("Drag", true);
    }
	var itemRarity = ItemsDatabase.GetItemRarity(displayPanel.itemname);
    displayPanel.style.borderColor = ItemsDatabase.GetItemRarityColor(itemRarity);
    displayPanel.SetHasClass("InventorySlotDragged", true);
} 

function OnInventorySlotDragEnd( panelId, draggedPanel ) {
	draggedPanel.DeleteAsync(0);
	var slotInfo = GetSlotUnderUserCursor();
	var slotFromId = parseInt(panelId.id.replace("InventorySlot", ""));
	var slotInId = slotInfo[0];
	var IsSlotFinded = slotInId > -1;
	var IsEquipped = slotInfo[1];
	var IsInsideInventoryWindow = slotInfo[2];
	var item = inventorySlots[slotFromId][SLOT_ITEM_IMAGE].itemname;
	if(IsSlotFinded) {
		if(IsEquipped) {
			GameEvents.SendCustomGameEventToServer("rpg_inventory_start_item_replace_dialog", { "player_id" : Players.GetLocalPlayer(), "fromslot" : slotFromId, "inslot" : slotInId, "item": item});
		} else {
			var jsonEncodedData = JSON.stringify({"player_id" : Players.GetLocalPlayer(), "fromslot" : slotFromId, "inslot" : slotInId, "equipped": IsEquipped});
			GameEvents.SendCustomGameEventToServer("rpg_inventory_swap_items", {"data" : jsonEncodedData});
		}
	} else {
		if(!IsInsideInventoryWindow) {
			var jsonEncodedData = JSON.stringify({ "player_id" : Players.GetLocalPlayer(), "slot" : slotFromId, "item": item, "equipped" : false});
			GameEvents.SendCustomGameEventToServer("rpg_inventory_drop_item_on_ground", {"data" : jsonEncodedData});
		}
	}
    var desiredInventorySlot = ItemsDatabase.GetItemSlot(inventorySlots[slotFromId][SLOT_ITEM_IMAGE].itemname);
    if(desiredInventorySlot > -1) {
        inventoryEquippedSlots[desiredInventorySlot][SLOT_PANEL].SetHasClass("Drag", false);
    }
} 

function OnRightClickOnInventoryEquippedSlot(slotId) {
	var item = inventoryEquippedSlots[slotId][SLOT_ITEM_IMAGE].itemname;
	if(!inventoryEquippedSlots[slotId][SLOT_PANEL].BHasClass("empty")) {
		var freeSlotId = 0;
		for(var i = 0; i < inventorySlots.length; i++) {
			if(inventorySlots[i][SLOT_ITEM_IMAGE].itemname == "") {
				freeSlotId = i;
				break;
			}
		}
		GameEvents.SendCustomGameEventToServer("rpg_inventory_remove_equipped_item", { "player_id" : Players.GetLocalPlayer(), "fromslot" : slotId, "inslot" : freeSlotId, "item": item});
	}
}

function OnRightClickOnInventorySlot(slotId) {
	var item = inventorySlots[slotId][SLOT_ITEM_IMAGE].itemname;
	if(item != "") {
		var slotInId = ItemsDatabase.GetItemSlot(item);
		GameEvents.SendCustomGameEventToServer("rpg_inventory_start_item_replace_dialog", { "player_id" : Players.GetLocalPlayer(), "fromslot" : slotId, "inslot" : slotInId, "item": item});
	} 
}

function GetSlotUnderUserCursor() {
	var equippedSlot = false;
	var window = $("#MainWindow");
	var inventorySlotsContainer = $("#InventoryContainer");
	var cursorPosition = GameUI.GetCursorPosition();
	var findedSlot = -1;
	var slotWidth = inventorySlots[0][SLOT_PANEL].actuallayoutwidth;
	var slotHeight = inventorySlots[0][SLOT_PANEL].actuallayoutheight;
	var currentSlot = 0;
	for(var j = 0; j < INVENTORY_SLOT_ROWS; j++) {
		for(var i = 0; i < INVENTORY_SLOTS_PER_ROW; i++) {
			var slot_min_x = window.actualxoffset + inventorySlotsContainer.actualxoffset + (slotWidth * i);
			var slot_min_y = window.actualyoffset + inventorySlotsContainer.actualyoffset + (slotHeight * j);
			var slot_max_x = slot_min_x + slotWidth;	
			var slot_max_y = slot_min_y + slotHeight;
			if(cursorPosition[0] > slot_min_x && cursorPosition[0] < slot_max_x && cursorPosition[1] > slot_min_y && cursorPosition[1] < slot_max_y) {
				findedSlot = currentSlot;
				break;
			}
			currentSlot++;
		}
	}
	slotWidth = inventoryEquippedSlots[0][SLOT_PANEL].actuallayoutwidth;
	slotHeight = inventoryEquippedSlots[0][SLOT_PANEL].actuallayoutheight;
	var slotSpacingX = 10, slotSpacingY = 10;
	inventorySlotsContainer = $("#LeftItemSlots");
	for(var i = 0; i < 4; i++) {
		var slot_min_x = window.actualxoffset + inventorySlotsContainer.actualxoffset + slotSpacingX;
		var slot_min_y = window.actualyoffset + inventorySlotsContainer.actualyoffset + (slotHeight * i) + (slotSpacingY * (i + 1));
		var slot_max_x = slot_min_x + slotWidth;	
		var slot_max_y = slot_min_y + slotHeight + slotSpacingY * 2;
		if(cursorPosition[0] > slot_min_x && cursorPosition[0] < slot_max_x && cursorPosition[1] > slot_min_y && cursorPosition[1] < slot_max_y) {
			findedSlot = i;
			equippedSlot = true;
			break;
		}
	}
	inventorySlotsContainer = $("#RightItemSlots");
	for(var i = 5; i < 9; i++) {
		var slot_min_x = window.actualxoffset + inventorySlotsContainer.actualxoffset + slotSpacingX;
		var slot_min_y = window.actualyoffset + inventorySlotsContainer.actualyoffset + (slotHeight * (i-5)) + (slotSpacingY * (i - 4));
		var slot_max_x = slot_min_x + slotWidth;	
		var slot_max_y = slot_min_y + slotHeight + slotSpacingY * 2;
		if(cursorPosition[0] > slot_min_x && cursorPosition[0] < slot_max_x && cursorPosition[1] > slot_min_y && cursorPosition[1] < slot_max_y) {
			findedSlot = i;
			equippedSlot = true;
			break;
		}
	}
	inventorySlotsContainer = $("#MiddleItemSlotsFromBottom");
	for(var i = 9; i < 12; i++) {
		var slot_min_x = window.actualxoffset + inventorySlotsContainer.actualxoffset + (slotWidth * (i-9)) + (slotSpacingY * (i - 8));
		var slot_min_y = window.actualyoffset + inventorySlotsContainer.actualyoffset + slotSpacingY;
		var slot_max_x = slot_min_x + slotWidth + slotSpacingX * 2;	
		var slot_max_y = slot_min_y + slotHeight;
		if(cursorPosition[0] > slot_min_x && cursorPosition[0] < slot_max_x && cursorPosition[1] > slot_min_y && cursorPosition[1] < slot_max_y) {
			findedSlot = i;
			equippedSlot = true;
			break;
		}
	}
	inventorySlotsContainer = $("#MiddleItemSlots");
	var slot_min_x = window.actualxoffset + inventorySlotsContainer.actualxoffset + slotSpacingX;
	var slot_min_y = window.actualyoffset + inventorySlotsContainer.actualyoffset + slotSpacingY;
	var slot_max_x = slot_min_x + slotWidth + slotSpacingX * 2;	
	var slot_max_y = slot_min_y + slotHeight;
	if(cursorPosition[0] > slot_min_x && cursorPosition[0] < slot_max_x && cursorPosition[1] > slot_min_y && cursorPosition[1] < slot_max_y) {
		findedSlot = 4;
		equippedSlot = true;
	}
	var insideWindow = false;
	var window_min_x = window.actualxoffset;
	var window_min_y = window.actualyoffset;
	var window_max_x = window_min_x + window.actuallayoutwidth;	
	var window_max_y = window_min_y + window.actuallayoutheight;
	if(cursorPosition[0] > window_min_x && cursorPosition[0] < window_max_x && cursorPosition[1] > window_min_y && cursorPosition[1] < window_max_y) {
		insideWindow = true;
	}
	return [findedSlot, equippedSlot, insideWindow]; 
}

function OnHeroStatsUpdateRequest(event) {
	var localPlayerId = Players.GetLocalPlayer();
	var parsedData = JSON.parse(event.data);
    var recievedPlayerId = parsedData.player_id;
    if (localPlayerId == recievedPlayerId) {
        var str = Math.round(parsedData.statsTable.str);
        var agi = Math.round(parsedData.statsTable.agi);
        var int = Math.round(parsedData.statsTable.int);
		var spellDamage = parsedData.statsTable.spellDamage;
		var spellHaste = parsedData.statsTable.spellHaste;
		var armor = Math.round(parsedData.statsTable.armor);
		var block = parsedData.statsTable.block;
		var magicBlock = parsedData.statsTable.magicBlock;
		var damageReduction = parsedData.statsTable.damageReduction;
		var cooldownReduction = parsedData.statsTable.cdr;
		var attackSpeed = parsedData.statsTable.attackSpeed;
		var buffAmplification = parsedData.statsTable.buffAmplification;
		var debuffAmplification = parsedData.statsTable.debuffAmplification;
		var debuffResistance = parsedData.statsTable.debuffResistance;
		var criticalDamage = parsedData.statsTable.critDamage;
		var criticalChance = parsedData.statsTable.critChance;
		var aggroCaused = parsedData.statsTable.aggroCaused;
		var healingCausedPercent = parsedData.statsTable.healingCausedPercent;
		var healingReceivedPercent = parsedData.statsTable.healingReceivedPercent;
		var elementsProtection = [
		Math.round((1 - parsedData.statsTable.elementsProtection.fire) * 100),
		Math.round((1 - parsedData.statsTable.elementsProtection.frost) * 100),
		Math.round((1 - parsedData.statsTable.elementsProtection.earth) * 100),
		Math.round((1 - parsedData.statsTable.elementsProtection.nature) * 100),
		Math.round((1 - parsedData.statsTable.elementsProtection.void) * 100),
		Math.round((1 - parsedData.statsTable.elementsProtection.inferno) * 100),
		Math.round((1 - parsedData.statsTable.elementsProtection.holy) * 100)];
		var elementsDamage = [
		Math.round((parsedData.statsTable.elementsDamage.fire - 1) * 100),
		Math.round((parsedData.statsTable.elementsDamage.frost - 1) * 100),
		Math.round((parsedData.statsTable.elementsDamage.earth - 1) * 100),
		Math.round((parsedData.statsTable.elementsDamage.nature - 1) * 100),
		Math.round((parsedData.statsTable.elementsDamage.void - 1) * 100),
		Math.round((parsedData.statsTable.elementsDamage.inferno - 1) * 100),
		Math.round((parsedData.statsTable.elementsDamage.holy - 1) * 100)];
		for(var i = 0; i < offensiveElePanels.length; i++) {
			offensiveElePanels[i][ELEMENT_VALUE].text = elementsDamage[i] + "%";
		}
		for(var i = 0; i < defensiveElePanels.length; i++) {
			defensiveElePanels[i][ELEMENT_VALUE].text = elementsProtection[i] + "%";
		}
		$("#StrengthLabel").text = str;
		$("#AgilityLabel").text = agi;
		$("#IntelligenceLabel").text = int;
		$("#SpellDamageLabel").text = Math.round((spellDamage-1) * 100) + "%";
		$("#SpellHasteLabel").text = spellHaste;
		var physProtection = 0;
		if(armor >= 0){
		    physProtection = ((armor * 0.06) / (1 + armor * 0.06));
		} else {
		    physProtection = -1 + Math.pow(0.94,armor * -1);
		}
		physProtection = Math.round(physProtection * 100);
		$("#PhysArmorLabel").text = armor + " (" + physProtection + "%)";
		var attackDelay = (currentHero > -1 ? Entities.GetSecondsPerAttack(currentHero) : "0");
		attackDelay = Math.round(attackDelay * 100) / 100;
		$("#AttackSpeedLabel").text = attackSpeed + " (" + attackDelay + ")";
		damageReduction = 1 - damageReduction;
		$("#DamageReductionLabel").text = Math.round(damageReduction * 100) + "%";
		cooldownReduction = 1 - cooldownReduction;
		$("#CooldownReductionLabel").text = (Math.round(cooldownReduction * 10000) / 100) + "%";
		$("#DebuffAmplificationLabel").text = (Math.round((debuffAmplification - 1) * 10000) / 100) + "%";
		$("#DebuffResistanceLabel").text = (Math.round((1 -debuffResistance) * 10000) / 100) + "%";
		buffAmplification = buffAmplification - 1;
		$("#BuffAmplificationLabel").text = (Math.round(buffAmplification * 10000) / 100) + "%";
		criticalDamage = criticalDamage - 1;
		$("#CriticalDamageLabel").text = (Math.round(criticalDamage * 10000) / 100) + "%";
		criticalChance = criticalChance - 1;
		$("#CriticalChanceLabel").text = (Math.round(criticalChance * 10000) / 100) + "%";
		$("#AggroCausedLabel").text = (Math.round((aggroCaused - 1) * 10000) / 100) + "%";
		$("#HealingReceivedLabel").text = (Math.round((healingReceivedPercent - 1) * 10000) / 100) + "%";
		$("#HealingCausedLabel").text = (Math.round((healingCausedPercent - 1) * 10000) / 100) + "%";
    }
}

function OnHeroesTableData(event) {
    var parsedData = JSON.parse(event.heroes);
    UpdateHeroModelAndIcon(parsedData);
}


function UpdateHeroModelAndIcon(data) {
    if(currentHero > -1) {
        var heroModelContainer = $("#HeroModelContainer");
        var heroName = Entities.GetUnitName(currentHero);
        var heroIndex = -1;
        for(var i = 0; i < data.length; i++) {
            if(data[i].Name == heroName) {
                heroIndex = data[i].HeroIndex;
            }
        }
        $("#HeroIcon").heroname = heroName;
        heroModelContainer.BCreateChildren('<DOTAScenePanel renderdeferred="false" class="HeroModel OverviewHeroRender" unit="' + heroName + '" drawbackground="1" allowrotation="true" antialias="false" activity-modifier="PostGameIdle" particleonly="false"/>');
        var scenePanel = heroModelContainer.GetChild(0);
        scenePanel.style.visibility = "visible";
        scenePanel.SetScenePanelToLocalHero(heroIndex);
	} else {
        $.Schedule(1, function() {
            UpdateHeroModelAndIcon(data);
        });
	}
}

var dataRequestSended = false;

function UpdateValues() {
	if(!dataRequestSended) {
		GameEvents.SendCustomGameEventToServer("rpg_inventory_require_items_and_rest_data", {"player_id" : Players.GetLocalPlayer()});
		dataRequestSended = true;
	}
	if(currentHero > -1) {
		var currentHp = Entities.GetHealth(currentHero);
		var currentMana = Entities.GetMana(currentHero);
		var hpPercent = (currentHp / Entities.GetMaxHealth(currentHero)) * 100;
		var manaPercent = (currentMana / Entities.GetMaxMana(currentHero)) * 100;
		hpPercent = Math.round(hpPercent * 100) / 100;
		manaPercent = Math.round(manaPercent * 100) / 100;
		$("#HealthLabel").text = Entities.GetHealth(currentHero) + " (" + hpPercent + "%)";
		$("#ManaLabel").text = Entities.GetMana(currentHero) + " (" + manaPercent + "%)";
		$("#LevelLabel").text = Entities.GetLevel(currentHero) + " / 50";
        var currentExp = Entities.GetCurrentXP(currentHero);
        var maxExp = Entities.GetNeededXPToLevel(currentHero);
        var expPercent = (currentExp / maxExp) * 100;
		expPercent = Math.round(expPercent * 100) / 100;
		if(maxExp == 0) {
			expPercent = 100;
		}
		$("#CurrentXPLabel").text = currentExp + " (" + expPercent + "%)";
		$("#AttackRangeLabel").text = Entities.GetAttackRange(currentHero);
		$("#AttackDamageLabel").text = Entities.GetDamageMax(currentHero);
		$("#MoveSpeedLabel").text = Math.round(Entities.GetMoveSpeedModifier(currentHero, Entities.GetBaseMoveSpeed(currentHero)));
		$("#ManaRegenLabel").text = Math.round(Entities.GetManaThinkRegen(currentHero) * 100) / 100;
		$("#HealthRegenLabel").text = Math.round(Entities.GetHealthThinkRegen(currentHero) * 100) / 100;
		$("#BaseAttackTimeLabel").text = Math.round(Entities.GetBaseAttackTime(currentHero) * 100) / 100;
	} else {
		var localPlayer = Players.GetLocalPlayer();
		currentHero = Players.GetPlayerHeroEntityIndex(localPlayer);
	}
	var showNames = false;
	if(GameUI.IsAltDown()) {
	    showNames = true;
	}
	for(var i = 0; i < INVENTORY_SLOT_LAST + 1; i++) {
		inventoryEquippedSlots[i][SLOT_PANEL].SetHasClass("Alt", showNames);
	}
}

function AutoUpdateValues() {
    UpdateValues();
    $.Schedule(0.1, function() {
        AutoUpdateValues();
    });
}

function OnSwitchPageButtonClick(page) {
	var IsPage0 = (page == 0), IsPage1 = (page == 1), IsPage2 = (page == 2);
	pagePanels[0].style.visibility = IsPage0 ? "visible" : "collapse";
	pagePanels[1].style.visibility = IsPage1 ? "visible" : "collapse";
	pagePanels[2].style.visibility = IsPage2 ? "visible" : "collapse";
	pageButtons[0].SetHasClass("is_pressed", IsPage0);
	pageButtons[1].SetHasClass("is_pressed", IsPage1);
	pageButtons[2].SetHasClass("is_pressed", IsPage2);
    Game.EmitSound("General.SelectAction");
}

function ShowItemTooltip(slotId) {
	var itemName = inventorySlots[slotId][SLOT_ITEM_IMAGE].itemname;
	if(itemName !== "") {
		var itemStats = inventorySlots[slotId][SLOT_ITEM_STATS];
		 TooltipManager.ShowItemTooltip(itemName, itemStats);
	}
}

function ShowEquippedItemTooltip(slotId) {
	if(!inventoryEquippedSlots[slotId][SLOT_PANEL].BHasClass("empty")) {
		var itemName = inventoryEquippedSlots[slotId][SLOT_ITEM_IMAGE].itemname;
		var itemStats = inventoryEquippedSlots[slotId][SLOT_ITEM_STATS];
		TooltipManager.ShowItemTooltip(itemName, itemStats);
	}
}

function HideItemTooltip() {
    TooltipManager.HideItemTooltip();
}

function CreateInventorySlots() {
	var inventoryPanel = $("#InventoryContainer");
	var inventorySlot;
	for(var i = 0; i < INVENTORY_SLOT_ROWS; i++) {
		var inventoryRow = $.CreatePanel("Panel", inventoryPanel, "");
		inventoryRow.SetHasClass("InventoryRow", true);
		for(var j = 0; j < INVENTORY_SLOTS_PER_ROW; j++) {
			inventorySlot = $.CreatePanel("Panel", inventoryRow, "InventorySlot" + (j+(INVENTORY_SLOTS_PER_ROW * i)));
			inventorySlot.BLoadLayout("file://{resources}/layout/custom_game/windows/inventory/inventory_slot.xml", false, false);
			var inventorySlotItemImage = inventorySlot.FindChildTraverse('ItemImage');
			var inventorySlotItemBorder = inventorySlot.FindChildTraverse('ItemBorder');
			inventorySlot.Data().ShowItemTooltip = ShowItemTooltip;
			inventorySlot.Data().HideItemTooltip = HideItemTooltip;
			inventorySlot.Data().OnRightClickOnInventorySlot = OnRightClickOnInventorySlot;
			inventorySlot.Data().OnDragStart = OnInventorySlotDragStart;
			inventorySlot.Data().OnDragEnd = OnInventorySlotDragEnd;
			inventorySlots.push([inventorySlot, inventorySlotItemImage, [], inventorySlotItemBorder]);
			if(j == 0) {
		        inventorySlot.SetHasClass("first", true);
			}
		}
		inventorySlot.SetHasClass("last", true);
	}
}

function CreateElementPanels(panelId, type) {
	for(var i = 0; i < ELEMENTS.length; i++) {
		var element = $.CreatePanel("Panel", panelId, type+ELEMENTS[i][0]);
        element.BLoadLayout("file://{resources}/layout/custom_game/windows/inventory/inventory_boxed_attribute.xml", false, false);
		var elementLabel = element.GetChild(1);
		var elementImage = element.GetChild(0).GetChild(0);
		elementImage.SetImage(ELEMENTS[i][1]);
		if(type == ELEMENTS_OFFENSIVE) {
			offensiveElePanels.push([element, elementLabel]);
		} else {
			defensiveElePanels.push([element, elementLabel]);
		}
	}
}

function OnInventoryWindowCloseRequest() {
	var window = $("#MainWindow");
	window.style.visibility = "collapse";
}

function OnInventoryButtonClicked() {
	var window = $("#MainWindow");
	window.style.visibility = window.style.visibility === "collapse" ? "visible" : "collapse";
}


function OnUpdateInventorySlotRequest(event) {
	HideItemTooltip();
	var IsItemExists = (event.item !== "");
	if(!event.equipped) {
		inventorySlots[event.slot][SLOT_ITEM_IMAGE].itemname = event.item;
		inventorySlots[event.slot][SLOT_ITEM_STATS] = JSON.parse(event.stats);
		if(IsItemExists) {
		    inventorySlots[event.slot][SLOT_ITEM_BORDER].style.borderWidth = "1px";
		    var itemRarity = ItemsDatabase.GetItemRarity(event.item);
		    inventorySlots[event.slot][SLOT_ITEM_BORDER].style.borderColor = ItemsDatabase.GetItemRarityColor(itemRarity);
		} else {
		    inventorySlots[event.slot][SLOT_ITEM_BORDER].style.borderWidth = "0px";
		}
	} else {
		inventoryEquippedSlots[event.slot][SLOT_PANEL].SetHasClass("empty", !IsItemExists);
		inventoryEquippedSlots[event.slot][SLOT_ITEM_IMAGE].itemname = IsItemExists ? event.item : inventoryEquippedSlots[event.slot][SLOT_ITEM_IMAGE].Data().defaultImage;
		inventoryEquippedSlots[event.slot][SLOT_ITEM_STATS] = JSON.parse(event.stats);
		if(IsItemExists) {
		    inventoryEquippedSlots[event.slot][SLOT_ITEM_BORDER].style.borderWidth = "2px";
		    var itemRarity = ItemsDatabase.GetItemRarity(event.item);
		    inventoryEquippedSlots[event.slot][SLOT_ITEM_BORDER].style.borderColor = ItemsDatabase.GetItemRarityColor(itemRarity);
		} else {
		    inventoryEquippedSlots[event.slot][SLOT_ITEM_BORDER].style.borderWidth = "0px";
		}
	}
}

function SetupAPI() {
    PlayerInventory.IsLocalPlayerEquippedItem = function(itemName) {
        for(var i = 0; i < inventoryEquippedSlots.length; i++) {
            if(inventoryEquippedSlots[i][SLOT_ITEM_IMAGE].itemname == itemName && !inventoryEquippedSlots[i][SLOT_PANEL].BHasClass("empty")) {
                return true;
            }
        }
        return false;
    };
}

(function () {
	pagePanels = [$("#Page0"), $("#Page1"), $("#Page2")];
	pageButtons = [$("#Page0Button"), $("#Page1Button"), $("#Page2Button")];
	for(var i = 0; i < INVENTORY_SLOT_LAST + 1; i++) {
		var inventorySlotPanel = $("#InventoryEquippedSlot"+i);
		var inventorySlotImage = $("#InventoryEquippedSlotImage"+i);
		var inventorySlotBorder = $("#InventoryEquippedSlotBorder"+i);
		inventorySlotImage.Data().defaultImage = inventorySlotImage.itemname;
		inventoryEquippedSlots.push([inventorySlotPanel, inventorySlotImage, [], inventorySlotBorder]);
	}
	OnSwitchPageButtonClick(0);
	CreateInventorySlots();
	SetupDragAndDropForInventoryEquippedSlots();
	CreateElementPanels($("#OffensiveElements"), ELEMENTS_OFFENSIVE);
	CreateElementPanels($("#DefensiveElements"), ELEMENTS_DEFENSIVE);
    GameEvents.Subscribe("rpg_inventory_open_window_from_server", OnInventoryButtonClicked);
	GameEvents.Subscribe("rpg_inventory_close_window_from_server", OnInventoryWindowCloseRequest);
	GameEvents.Subscribe("rpg_inventory_update_slot", OnUpdateInventorySlotRequest);
    GameEvents.Subscribe("rpg_update_hero_stats", OnHeroStatsUpdateRequest);
    GameEvents.Subscribe("rpg_hero_selection_get_heroes_from_server", OnHeroesTableData);
	GameEvents.SendCustomGameEventToServer("rpg_hero_selection_get_heroes", {});
    AutoUpdateValues();
    SetupAPI();
})();