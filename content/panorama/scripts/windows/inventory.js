"use strict"
var INVENTORY_SLOTS_PER_ROW = 14;
var INVENTORY_SLOT_ROWS = 7;
var INVENTORY_SLOTS_COUNT = INVENTORY_SLOTS_PER_ROW * INVENTORY_SLOT_ROWS;
var inventorySlots = [];
var inventoryEquippedSlots = [];
var SLOT_PANEL = 0, SLOT_ITEM_IMAGE = 1, SLOT_ITEM_STATS = 2;
var ELEMENTS_DEFENSIVE = "D", ELEMENTS_OFFENSIVE = "O";
var defensiveElePanels = [], offensiveElePanels = [];
var ELEMENT_PANEL = 0, ELEMENT_VALUE = 1;
var pagePanels = [], pageButtons = [];
var tooltip = [];
var TOOLTIP_PANEL = 0, TOOLTIP_IMAGE = 1, TOOLTIP_NAME_LABEL = 2, TOOLTIP_RARITY_LABEL = 3, TOOLTIP_TYPE_LABEL = 4, TOOLTIP_DESCRIPTION_LABEL = 5, TOOLTIP_QUALITY_LABEL = 6, TOOLTIP_STATS_CONTAINER = 7;
var initialStatsLabelsInTooltip = 10;
var statsLabels = [], statsLabelsForCompareWindowPanel1 = [], statsLabelsForCompareWindowPanel2 = [];
var compareWindow = [];
var COMPARE_PANEL = 0, COMPARE_PANEL1_IMAGE = 1, COMPARE_PANEL1_NAME_LABEL = 2, COMPARE_PANEL1_RARITY_LABEL = 3, COMPARE_PANEL1_TYPE_LABEL = 4, COMPARE_PANEL1_DESCRIPTION_LABEL = 5,
COMPARE_PANEL2_IMAGE = 6, COMPARE_PANEL2_NAME_LABEL = 7, COMPARE_PANEL2_RARITY_LABEL = 8, COMPARE_PANEL2_TYPE_LABEL = 9, COMPARE_PANEL2_DESCRIPTION_LABEL = 10,
COMPARE_PANEL1_QUALITY_LABEL = 11, COMPARE_PANEL1_STATS_CONTAINER = 12, COMPARE_PANEL2_QUALITY_LABEL = 13, COMPARE_PANEL2_STATS_CONTAINER = 14;
var inventoryItemsData = [], currentHero = -1;
var dropContainer;
// adding slots here require change GetInventoryItemSlotName()
var INVENTORY_SLOT_MAINHAND = 0
var INVENTORY_SLOT_BODY = 1
var INVENTORY_SLOT_LEGS = 2
var INVENTORY_SLOT_BOOTS = 3
var INVENTORY_SLOT_HELMET = 4
var INVENTORY_SLOT_OFFHAND = 5
var INVENTORY_SLOT_CAPE = 6
var INVENTORY_SLOT_SHOULDER = 7
var INVENTORY_SLOT_GLOVES = 8
var INVENTORY_SLOT_RING = 9
var INVENTORY_SLOT_BELT = 10
var INVENTORY_SLOT_AMULET = 11
var INVENTORY_SLOT_LAST = 11
// adding rarity here require change GetInventoryItemRarityName()
var INVENTORY_ITEM_RARITY_COMMON = 0;
var INVENTORY_ITEM_RARITY_UNCOMMON = 1;
var INVENTORY_ITEM_RARITY_RARE = 2;
var INVENTORY_ITEM_RARITY_UNIQUE_RARE = 3;
var INVENTORY_ITEM_RARITY_LEGENDARY = 4;
var INVENTORY_ITEM_RARITY_UNIQUE_LEGENDARY = 5;
var INVENTORY_ITEM_RARITY_CURSED_LEGENDARY = 6;
var INVENTORY_ITEM_RARITY_ANCIENT = 7;
var INVENTORY_ITEM_RARITY_UNIQUE_ANCIENT = 8;
var INVENTORY_ITEM_RARITY_CURSED_ANCIENT = 9;
var INVENTORY_ITEM_RARITY_IMMORTAL = 10;
var INVENTORY_ITEM_RARITY_UNIQUE_IMMORTAL = 11;
var INVENTORY_ITEM_RARITY_CURSED_IMMORTAL = 12;

var ELEMENTS = [
	["Fire", "file://{images}/custom_game/hud/fire_element.png"],
	["Frost", "file://{images}/custom_game/hud/frost_element.png"],
	["Earth", "file://{images}/custom_game/hud/earth_element.png"],
	["Nature", "file://{images}/custom_game/hud/nature_element.png"],
	["Void", "file://{images}/custom_game/hud/void_element.png"],
	["Inferno", "file://{resources}/images/custom_game/hud/inferno_element.png"],
	["Holy", "file://{images}/custom_game/hud/holy_element.png"]
];

function GetInventoryItemRarityName(rarity) {
	switch(rarity) {
        case INVENTORY_ITEM_RARITY_COMMON:
			return "#DOTA_Inventory_rarity_common";
			break;
        case INVENTORY_ITEM_RARITY_UNCOMMON:
			return "#DOTA_Inventory_rarity_uncommon";
			break;
        case INVENTORY_ITEM_RARITY_RARE:
			return "#DOTA_Inventory_rarity_rare";
			break;
        case INVENTORY_ITEM_RARITY_UNIQUE_RARE:
			return "#DOTA_Inventory_rarity_unique_rare";
			break;
        case INVENTORY_ITEM_RARITY_LEGENDARY:
			return "#DOTA_Inventory_rarity_legendary";
			break;
        case INVENTORY_ITEM_RARITY_UNIQUE_LEGENDARY:
			return "#DOTA_Inventory_rarity_unique_legendary";
			break;
        case INVENTORY_ITEM_RARITY_CURSED_LEGENDARY:
			return "#DOTA_Inventory_rarity_cursed_legendary";
			break;
        case INVENTORY_ITEM_RARITY_ANCIENT:
			return "#DOTA_Inventory_rarity_ancient";
			break;
        case INVENTORY_ITEM_RARITY_UNIQUE_ANCIENT:
			return "#DOTA_Inventory_rarity_unique_ancient";
			break;
        case INVENTORY_ITEM_RARITY_CURSED_ANCIENT:
			return "#DOTA_Inventory_rarity_cursed_ancient";
			break;
        case INVENTORY_ITEM_RARITY_IMMORTAL:
			return "#DOTA_Inventory_rarity_immortal";
			break;
        case INVENTORY_ITEM_RARITY_UNIQUE_IMMORTAL:
			return "#DOTA_Inventory_unique_immortal";
			break;
        case INVENTORY_ITEM_RARITY_CURSED_IMMORTAL:
			return "#DOTA_Inventory_cursed_immortal";
			break;
		default:
			return "Unknown";
	}

}

function GetInventoryItemSlotName(slot) {
	switch(slot) {
		case INVENTORY_SLOT_MAINHAND:
			return "#DOTA_Inventory_slot_mainhand";
			break;
		case INVENTORY_SLOT_BODY:
			return "#DOTA_Inventory_slot_body";
			break;
		case INVENTORY_SLOT_LEGS:
			return "#DOTA_Inventory_slot_legs";
			break;
		case INVENTORY_SLOT_BOOTS:
			return "#DOTA_Inventory_slot_boots";
			break;
		case INVENTORY_SLOT_HELMET:
			return "#DOTA_Inventory_slot_helmet";
			break;
		case INVENTORY_SLOT_OFFHAND:
			return "#DOTA_Inventory_slot_offhand";
			break;
		case INVENTORY_SLOT_CAPE:
			return "#DOTA_Inventory_slot_cape";
			break;
		case INVENTORY_SLOT_SHOULDER:
			return "#DOTA_Inventory_slot_shoulder";
			break;
		case INVENTORY_SLOT_GLOVES:
			return "#DOTA_Inventory_slot_gloves";
			break;
		case INVENTORY_SLOT_RING:
			return "#DOTA_Inventory_slot_ring";
			break;
		case INVENTORY_SLOT_BELT:
			return "#DOTA_Inventory_slot_belt";
			break;
		case INVENTORY_SLOT_AMULET:
			return "#DOTA_Inventory_slot_amulet";
			break;
		default:
			return "Unknown";
	}
}

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
    var displayPanel = $.CreatePanel( "DOTAItemImage", $.GetContextPanel(), "");
	displayPanel.SetHasClass("InventorySlot", true);
	displayPanel.style.width = inventorySlots[0][SLOT_PANEL].actuallayoutwidth + "px";
	HideItemTooltip();
	displayPanel.itemname = inventoryEquippedSlots[slotId][SLOT_ITEM_IMAGE].itemname;
    dragCallbacks.displayPanel = displayPanel;
    dragCallbacks.offsetX = 0; 
    dragCallbacks.offsetY = 0;
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
    var desiredInventorySlot = GetInventoryItemSlot(inventorySlots[slotId][SLOT_ITEM_IMAGE].itemname);
    if(desiredInventorySlot > -1) {
        inventoryEquippedSlots[desiredInventorySlot][SLOT_PANEL].SetHasClass("Drag", true);
    }
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
    var desiredInventorySlot = GetInventoryItemSlot(inventorySlots[slotFromId][SLOT_ITEM_IMAGE].itemname);
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
		var slotInId = GetInventoryItemSlot(item);
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
		spellHaste = (spellHaste) * 100;
		$("#SpellhasteLabel").text = Math.round(spellHaste);
		if(armor>=0){
		var physProtection = ((armor * 0.06) / (1 + armor * 0.06));
		} else {
		var physProtection = -1 + Math.pow(0.94,armor * -1);
		}
		physProtection = Math.round(physProtection * 100);
		$("#PhysArmorLabel").text = armor + " (" + physProtection + "%)";
		$("#PhysBlockLabel").text = block;
		$("#MagicBlockLabel").text = magicBlock;
		var attackDelay = (currentHero > -1 ? Entities.GetSecondsPerAttack(currentHero) : "0");
		attackDelay = Math.round(attackDelay * 100) / 100;
		$("#AttackSpeedLabel").text = attackSpeed + " (" + attackDelay + ")";
		damageReduction = 1 - damageReduction;
		$("#DamageReductionLabel").text = Math.round(damageReduction * 100) + "%";
		cooldownReduction = 1 - cooldownReduction;
		if(cooldownReduction>=0.5){
        		cooldownReduction=0.5;
        }
		$("#CooldownReductionLabel").text = (Math.round(cooldownReduction * 10000) / 100) + "%";
		debuffAmplification = debuffAmplification;
		$("#DebuffAmplificationLabel").text = (Math.round(debuffAmplification * 10000) / 100) + "%";
		debuffResistance = 1 - debuffResistance;
		$("#DebuffResistanceLabel").text = (Math.round(debuffResistance * 10000) / 100) + "%";
		buffAmplification = buffAmplification;
		$("#BuffAmplificationLabel").text = (Math.round(buffAmplification * 10000) / 100) + "%";
		criticalDamage = criticalDamage - 1;
		$("#CriticalDamageLabel").text = (Math.round(criticalDamage * 10000) / 100) + "%";
		criticalChance = criticalChance - 1;
		$("#CriticalChanceLabel").text = (Math.round(criticalChance * 10000) / 100) + "%";
    }
}

function UpdateHeroModelAndIcon() {
    var heroModelContainer = $("#HeroModelContainer");
	var heroName = Entities.GetUnitName(currentHero);
	$("#HeroIcon").heroname = heroName;
	heroModelContainer.BCreateChildren('<DOTAScenePanel renderdeferred="false" class="HeroModel OverviewHeroRender" unit="' + heroName + '" drawbackground="1" allowrotation="true" antialias="false" activity-modifier="PostGameIdle" particleonly="false"/>');
	heroModelContainer.GetChild(0).style.visibility = "visible";
}

var dataRequestSended = false;

function UpdateValues() {
	if(inventoryItemsData.length == 0 && !dataRequestSended) {
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
}

function HideItemTooltip(slotId) {
	tooltip[TOOLTIP_PANEL].style.visibility = "collapse";
}

function OnStartItemReplaceDialogRequest(event) {
	compareWindow[COMPARE_PANEL].Data().slotInQuestion = event.slot;
	compareWindow[COMPARE_PANEL].style.visibility = "visible";	
	var itemIcon = inventorySlots[event.slot][SLOT_ITEM_IMAGE].itemname;
	var itemName = $.Localize("#DOTA_Tooltip_Ability_"+inventorySlots[event.slot][SLOT_ITEM_IMAGE].itemname);
	var itemDesiredSlot = GetInventoryItemSlot(inventorySlots[event.slot][SLOT_ITEM_IMAGE].itemname);
	var itemRarity = GetInventoryItemRarityName(GetInventoryItemRarity(inventorySlots[event.slot][SLOT_ITEM_IMAGE].itemname));
	var itemType = GetInventoryItemSlotName(itemDesiredSlot);
	var itemDescription = $.Localize("#DOTA_Tooltip_Ability_"+inventorySlots[event.slot][SLOT_ITEM_IMAGE].itemname + "_Description");
	var itemQuality = $.Localize("#DOTA_Inventory_quality").replace("%VALUE%", CalculateQualityOfItem(inventorySlots[event.slot][SLOT_ITEM_IMAGE].itemname, inventorySlots[event.slot][SLOT_ITEM_STATS]));
	var itemStatsCount = inventorySlots[event.slot][SLOT_ITEM_STATS].length;
	var missedLabels = itemStatsCount - compareWindow[COMPARE_PANEL1_STATS_CONTAINER].GetChildCount();
	if(missedLabels > 0) {
	    for(var i = 0; i < missedLabels; i++) {
	        var statsLabel = $.CreatePanel("Label", compareWindow[COMPARE_PANEL1_STATS_CONTAINER], "");
            statsLabelsForCompareWindowPanel1.html = true;
            statsLabelsForCompareWindowPanel1.style.visibility = "collapse";
            statsLabelsForCompareWindowPanel1.push(statsLabel);
	    }
	}
	ModifyItemComparePanel(1, itemIcon, itemName, itemRarity, itemType, itemDescription, itemQuality, inventorySlots[event.slot]);
	itemIcon = inventoryEquippedSlots[itemDesiredSlot][SLOT_ITEM_IMAGE].itemname;
	itemName = $.Localize("#DOTA_Tooltip_Ability_"+inventoryEquippedSlots[itemDesiredSlot][SLOT_ITEM_IMAGE].itemname);
	itemDesiredSlot = GetInventoryItemSlot(inventoryEquippedSlots[itemDesiredSlot][SLOT_ITEM_IMAGE].itemname);
	itemRarity = GetInventoryItemRarityName(GetInventoryItemRarity(inventoryEquippedSlots[itemDesiredSlot][SLOT_ITEM_IMAGE].itemname));
	itemType = GetInventoryItemSlotName(itemDesiredSlot);
	itemDescription = $.Localize("#DOTA_Tooltip_Ability_"+inventoryEquippedSlots[itemDesiredSlot][SLOT_ITEM_IMAGE].itemname + "_Description");
	itemQuality = $.Localize("#DOTA_Inventory_quality").replace("%VALUE%", CalculateQualityOfItem(inventoryEquippedSlots[itemDesiredSlot][SLOT_ITEM_IMAGE].itemname, inventoryEquippedSlots[itemDesiredSlot][SLOT_ITEM_STATS]));
	itemStatsCount = inventoryEquippedSlots[itemDesiredSlot][SLOT_ITEM_STATS].length;
	missedLabels = itemStatsCount - compareWindow[COMPARE_PANEL2_STATS_CONTAINER].GetChildCount();
	if(missedLabels > 0) {
	    for(var i = 0; i < missedLabels; i++) {
	        var statsLabel = $.CreatePanel("Label", compareWindow[COMPARE_PANEL2_STATS_CONTAINER], "");
            statsLabelsForCompareWindowPanel2.html = true;
            statsLabelsForCompareWindowPanel2.style.visibility = "collapse";
            statsLabelsForCompareWindowPanel2.push(statsLabel);
	    }
	}
	ModifyItemComparePanel(2, itemIcon, itemName, itemRarity, itemType, itemDescription, itemQuality, inventoryEquippedSlots[itemDesiredSlot]);
}

function ModifyItemComparePanel(panelId, icon, name, rarity, type, description, quality, slot) {
	if(panelId === 1) {
		compareWindow[COMPARE_PANEL1_IMAGE].itemname = icon;
		compareWindow[COMPARE_PANEL1_NAME_LABEL].text = name;
		compareWindow[COMPARE_PANEL1_RARITY_LABEL].text = rarity;
		compareWindow[COMPARE_PANEL1_TYPE_LABEL].text = type;
		compareWindow[COMPARE_PANEL1_DESCRIPTION_LABEL].text = description;
		if(description.toLowerCase().includes("dota_tooltip") || description.length == 0) {
            compareWindow[COMPARE_PANEL1_DESCRIPTION_LABEL].style.visibility = "collapse";
        } else {
            compareWindow[COMPARE_PANEL1_DESCRIPTION_LABEL].style.visibility = "visible";
        }
		compareWindow[COMPARE_PANEL1_QUALITY_LABEL].text = quality;
		var latestStatId = 0;
		for(var i = 0; i < slot[SLOT_ITEM_STATS].length; i++) {
		    var statName = $.Localize("#DOTA_Tooltip_Ability_"+slot[SLOT_ITEM_IMAGE].itemname+"_"+slot[SLOT_ITEM_STATS][i].name);
		    var statValue = slot[SLOT_ITEM_STATS][i].value;
		    var preSymbol = "";
		    if(statValue < 0) {
		        preSymbol = "-";
		    }
		    var IsPercent = (statName.charAt(0) == "%");
            if(IsPercent) {
                statName = statName.slice(1, statName.length);
                statValue *= 100;
                statValue += "%";
            }
		    statsLabelsForCompareWindowPanel1[i].text = statName + preSymbol + statValue;
		    statsLabelsForCompareWindowPanel1[i].style.visibility = "visible";
		    latestStatId++;
		}
		for(var i = latestStatId; i < compareWindow[COMPARE_PANEL1_STATS_CONTAINER].GetChildCount(); i++) {
		    statsLabelsForCompareWindowPanel1[i].style.visibility = "collapse";
		}
	}
	if(panelId == 2) {
		compareWindow[COMPARE_PANEL2_IMAGE].itemname = icon;
		compareWindow[COMPARE_PANEL2_NAME_LABEL].text = name;
		compareWindow[COMPARE_PANEL2_RARITY_LABEL].text = rarity;
		compareWindow[COMPARE_PANEL2_TYPE_LABEL].text = type;
		compareWindow[COMPARE_PANEL2_DESCRIPTION_LABEL].text = description;
		if(description.toLowerCase().includes("dota_tooltip") || description.length == 0) {
            compareWindow[COMPARE_PANEL2_DESCRIPTION_LABEL].style.visibility = "collapse";
        } else {
            compareWindow[COMPARE_PANEL2_DESCRIPTION_LABEL].style.visibility = "visible";
        }
		compareWindow[COMPARE_PANEL2_QUALITY_LABEL].text = quality;
		var latestStatId = 0;
		for(var i = 0; i < slot[SLOT_ITEM_STATS].length; i++) {
		    var statName = $.Localize("#DOTA_Tooltip_Ability_"+slot[SLOT_ITEM_IMAGE].itemname+"_"+slot[SLOT_ITEM_STATS][i].name);
		    var statValue = slot[SLOT_ITEM_STATS][i].value;
		    var preSymbol = "";
		    if(statValue < 0) {
		        preSymbol = "-";
		    }
		    var IsPercent = (statName.charAt(0) == "%");
            if(IsPercent) {
                statName = statName.slice(1, statName.length);
                statValue *= 100;
                statValue += "%";
            }
		    statsLabelsForCompareWindowPanel2[i].text = statName + preSymbol + statValue;
		    statsLabelsForCompareWindowPanel2[i].style.visibility = "visible";
		    latestStatId++;
		}
		for(var i = latestStatId; i < compareWindow[COMPARE_PANEL2_STATS_CONTAINER].GetChildCount(); i++) {
		    statsLabelsForCompareWindowPanel2[i].style.visibility = "collapse";
		}
	}
}

function OnInventoryChangeEquippedItemClicked() {
	var slot = compareWindow[COMPARE_PANEL].Data().slotInQuestion;
	GameEvents.SendCustomGameEventToServer("rpg_inventory_equip_item", { "player_id" : Players.GetLocalPlayer(), "slot" : slot, "item": inventorySlots[slot][SLOT_ITEM_IMAGE].itemname});
	compareWindow[COMPARE_PANEL].style.visibility = "collapse";	
}

function OnInventoryKeepBothClicked() {
	compareWindow[COMPARE_PANEL].style.visibility = "collapse";	
}

function ShowEquippedItemTooltip(slotId) {
	var position = GameUI.GetCursorPosition();
	if(!inventoryEquippedSlots[slotId][SLOT_PANEL].BHasClass("empty")) {
		var itemIcon = inventoryEquippedSlots[slotId][SLOT_ITEM_IMAGE].itemname;
		var itemName = $.Localize("#DOTA_Tooltip_Ability_"+inventoryEquippedSlots[slotId][SLOT_ITEM_IMAGE].itemname);
		var itemDesiredSlot = GetInventoryItemSlot(inventoryEquippedSlots[slotId][SLOT_ITEM_IMAGE].itemname);
		var itemRarity = GetInventoryItemRarityName(GetInventoryItemRarity(inventoryEquippedSlots[slotId][SLOT_ITEM_IMAGE].itemname));
		var itemType = GetInventoryItemSlotName(itemDesiredSlot);
		var itemDescription = $.Localize("#DOTA_Tooltip_Ability_"+inventoryEquippedSlots[slotId][SLOT_ITEM_IMAGE].itemname + "_Description");
		var itemQuality = $.Localize("#DOTA_Inventory_quality").replace("%VALUE%", CalculateQualityOfItem(inventoryEquippedSlots[slotId][SLOT_ITEM_IMAGE].itemname, inventoryEquippedSlots[slotId][SLOT_ITEM_STATS]));
		var itemStatsCount = inventoryEquippedSlots[slotId][SLOT_ITEM_STATS].length;
		var missedLabels = itemStatsCount - tooltip[TOOLTIP_STATS_CONTAINER].GetChildCount();
		if(missedLabels > 0) {
		    for(var i = 0; i < missedLabels; i++) {
		        var statsLabel = $.CreatePanel("Label", tooltip[TOOLTIP_STATS_CONTAINER], "");
                statsLabel.html = true;
                statsLabel.style.visibility = "collapse";
                statsLabels.push(statsLabel);
		    }
		}
		CreateItemTooltip(itemIcon, itemName, itemRarity, itemType, itemDescription, itemQuality, inventoryEquippedSlots[slotId][SLOT_ITEM_STATS], position[0], position[1]);
	}
}

function ShowItemDropTooltip(name, stats) {
	var position = GameUI.GetCursorPosition();
	var itemIcon = name;
	var itemName = $.Localize("#DOTA_Tooltip_Ability_"+name);
	var itemDesiredSlot = GetInventoryItemSlot(name);
	var itemRarity = GetInventoryItemRarityName(GetInventoryItemRarity(name));
	var itemType = GetInventoryItemSlotName(itemDesiredSlot);
	var itemDescription = $.Localize("#DOTA_Tooltip_Ability_" + name + "_Description");
	var itemQuality = $.Localize("#DOTA_Inventory_quality").replace("%VALUE%", CalculateQualityOfItem(name, stats));
	var itemStatsCount = stats.length;
	var missedLabels = itemStatsCount - tooltip[TOOLTIP_STATS_CONTAINER].GetChildCount();
	if(missedLabels > 0) {
	    for(var i = 0; i < missedLabels; i++) {
	        var statsLabel = $.CreatePanel("Label", tooltip[TOOLTIP_STATS_CONTAINER], "");
            statsLabel.html = true;
            statsLabel.style.visibility = "collapse";
            statsLabels.push(statsLabel);
	    }
	}
	CreateItemTooltip(itemIcon, itemName, itemRarity, itemType, itemDescription, itemQuality, stats, position[0], position[1]);
}

function GetMinMaxValueForItemStat(itemName, itemStat) {
    var result = [];
    for(var i = 0; i < inventoryItemsData.length; i++) {
        if(inventoryItemsData[i].item == itemName && inventoryItemsData[i].stats[itemStat] != null) {
            result[0] = inventoryItemsData[i].stats[itemStat].min;
            result[1] = inventoryItemsData[i].stats[itemStat].max;
            break;
        }
    }
    return result
}

function CalculateItemStatRoll(value, min, max, itemName, itemStat) {
	if(min == max) {
		return 1;
	}
    if(min < 0 && max >= 0) {
        return 1 - (value / min); // save roll = value / min, save load = save roll * min
    }
    if(min >= 0 && max > 0) {
        return (value - min) / (max - min); // save roll = value / max, save load = save roll * max
    }
    if(min < 0 && max < 0) {
        return 1 - ((value-max)/(min-max)); // save roll = value / max, save load = save roll * max
    }
    $.Msg("[INVENTORY] Unable to calculate roll value for " + itemName + " and stat " + itemStats[i].name + ". Used 0 to fix that. Value = " + value + ", min = " + min + ", max = " + max);
    return 0;
}

function CalculateQualityOfItem(itemName, itemStats) {
    var totalQuality = itemStats.length;
    var currentQuality = 0;
    for(var i = 0; i < itemStats.length; i++) {
        var minMaxValues = GetMinMaxValueForItemStat(itemName, itemStats[i].name);
        if(minMaxValues.length > 0) {
            currentQuality += CalculateItemStatRoll(itemStats[i].value, minMaxValues[0], minMaxValues[1], itemName, itemStats[i].name);
        } else {
            totalQuality = totalQuality - 1;
            $.Msg("[INVENTORY] There are error receiving min & max values for " + itemName + " and stat " + itemStats[i].name + ". Ignoring.");
        }
    }
    if(totalQuality > 0) {
        totalQuality = currentQuality / totalQuality;
    } else {
        totalQuality = 1;
    }
    return Math.round(totalQuality * 10000) / 100;
}

function ShowItemTooltip(slotId) {
	var position = GameUI.GetCursorPosition();
	if(inventorySlots[slotId][SLOT_ITEM_IMAGE].itemname !== "") {
		var itemIcon = inventorySlots[slotId][SLOT_ITEM_IMAGE].itemname;
		var itemName = $.Localize("#DOTA_Tooltip_Ability_"+inventorySlots[slotId][SLOT_ITEM_IMAGE].itemname);
		var itemDesiredSlot = GetInventoryItemSlot(inventorySlots[slotId][SLOT_ITEM_IMAGE].itemname);
		var itemRarity = GetInventoryItemRarityName(GetInventoryItemRarity(inventorySlots[slotId][SLOT_ITEM_IMAGE].itemname));
		var itemType = GetInventoryItemSlotName(itemDesiredSlot);
		var itemDescription = $.Localize("#DOTA_Tooltip_Ability_"+inventorySlots[slotId][SLOT_ITEM_IMAGE].itemname + "_Description");
		var itemQuality = $.Localize("#DOTA_Inventory_quality").replace("%VALUE%", CalculateQualityOfItem(inventorySlots[slotId][SLOT_ITEM_IMAGE].itemname, inventorySlots[slotId][SLOT_ITEM_STATS]));
		var itemStatsCount = inventorySlots[slotId][SLOT_ITEM_STATS].length;
		var missedLabels = itemStatsCount - tooltip[TOOLTIP_STATS_CONTAINER].GetChildCount();
		if(missedLabels > 0) {
		    for(var i = 0; i < missedLabels; i++) {
		        var statsLabel = $.CreatePanel("Label", tooltip[TOOLTIP_STATS_CONTAINER], "");
                statsLabel.html = true;
                statsLabel.style.visibility = "collapse";
                statsLabels.push(statsLabel);
		    }
		}
		CreateItemTooltip(itemIcon, itemName, itemRarity, itemType, itemDescription, itemQuality, inventorySlots[slotId][SLOT_ITEM_STATS], position[0], position[1]);
	}
}

function CreateItemTooltip(icon, name, rarity, type, description, quality, stats, x, y) {
    tooltip[TOOLTIP_IMAGE].itemname = icon;
	tooltip[TOOLTIP_NAME_LABEL].text = name.toUpperCase();
	tooltip[TOOLTIP_RARITY_LABEL].text = rarity;
	tooltip[TOOLTIP_TYPE_LABEL].text = type;
    if(description.toLowerCase().includes("dota_tooltip") || description.length == 0) {
        tooltip[TOOLTIP_DESCRIPTION_LABEL].style.visibility = "collapse";
    } else {
        tooltip[TOOLTIP_DESCRIPTION_LABEL].style.visibility = "visible";
    }
	tooltip[TOOLTIP_DESCRIPTION_LABEL].text = description;
	tooltip[TOOLTIP_QUALITY_LABEL].text = quality;
	if(tooltip[TOOLTIP_PANEL].actuallayoutwidth + x > Game.GetScreenWidth()) {
	    x -= tooltip[TOOLTIP_PANEL].actuallayoutwidth;
	}
	if(tooltip[TOOLTIP_PANEL].actuallayoutheight + y > Game.GetScreenHeight()) {
	    y -= tooltip[TOOLTIP_PANEL].actuallayoutheight;
	}
	tooltip[TOOLTIP_PANEL].style.marginLeft = x + "px";
	tooltip[TOOLTIP_PANEL].style.marginTop = y + "px";
	tooltip[TOOLTIP_PANEL].style.visibility = "visible";
	var latestStatId = 0;
	for(var i = 0; i < stats.length; i++) {
	    var statName = $.Localize("#DOTA_Tooltip_Ability_"+icon+"_"+stats[i].name);
	    var statValue = stats[i].value;
	    var IsPercent = (statName.charAt(0) == "%");
        if(IsPercent) {
            statName = statName.slice(1, statName.length);
            statValue += "%";
        }
	    statsLabels[i].text = statName + statValue;
	    statsLabels[i].style.visibility = "visible";
	    latestStatId++;
	}
	for(var i = latestStatId; i < tooltip[TOOLTIP_STATS_CONTAINER].GetChildCount(); i++) {
		statsLabels[i].style.visibility = "collapse";
	}
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
			var inventorySlotItemImage = inventorySlot.GetChild(0);
			inventorySlot.Data().ShowItemTooltip = ShowItemTooltip;
			inventorySlot.Data().HideItemTooltip = HideItemTooltip;
			inventorySlot.Data().OnRightClickOnInventorySlot = OnRightClickOnInventorySlot;
			inventorySlot.Data().OnDragStart = OnInventorySlotDragStart;
			inventorySlot.Data().OnDragEnd = OnInventorySlotDragEnd;
			inventorySlots.push([inventorySlot, inventorySlotItemImage, []]);
		}
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
	if(!event.equipped) {
		inventorySlots[event.slot][SLOT_ITEM_IMAGE].itemname = event.item;
		inventorySlots[event.slot][SLOT_ITEM_STATS] = JSON.parse(event.stats);
	} else {
		var IsItemExists = (event.item !== "");
		inventoryEquippedSlots[event.slot][SLOT_PANEL].SetHasClass("empty", !IsItemExists);
		inventoryEquippedSlots[event.slot][SLOT_ITEM_IMAGE].itemname = IsItemExists ? event.item : inventoryEquippedSlots[event.slot][SLOT_ITEM_IMAGE].Data().defaultImage;
		inventoryEquippedSlots[event.slot][SLOT_ITEM_STATS] = JSON.parse(event.stats);
	}
}

function GetHEXPlayerColor(playerId) {
	var playerColor = Players.GetPlayerColor(playerId).toString(16);
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}

function GetInventoryItemRarity(itemname) {
	for(var i = 0; i < inventoryItemsData.length; i++) {
		if(inventoryItemsData[i].item == itemname) {
			return inventoryItemsData[i].rarity;
		}
	}
	return -1;
}

function GetInventoryItemSlot(itemname) {
	for(var i = 0; i < inventoryItemsData.length; i++) {
		if(inventoryItemsData[i].item == itemname) {
			return inventoryItemsData[i].slot;
		}
	}
	return -1;
}

var modelUpdated = false;

function OnInventoryItemsDataRequest(event) {
	inventoryItemsData = inventoryItemsData.concat(JSON.parse(event.items_data));
	if(!modelUpdated) {
	    UpdateHeroModelAndIcon();
	    modelUpdated = true;
	}
}

function OnItemDrop(event) {
	var itemDropPanel = $.CreatePanel("Panel", dropContainer, "");
	itemDropPanel.BLoadLayout("file://{resources}/layout/custom_game/dropped_item.xml", false, false);
	var itemIcon = itemDropPanel.FindChildTraverse('DropItemIcon');
    itemIcon.itemname = event.item;
    itemDropPanel.FindChildTraverse('DropItemHeroContainerIcon').heroname = event.hero;
    itemDropPanel.FindChildTraverse('DropItemHeroContainerLabel').text = "<font color='" + GetHEXPlayerColor(event.player_id) + "'>" + Players.GetPlayerName(event.player_id) + "</font>";
    itemIcon.SetPanelEvent(
      "onmouseover",
      function(){
        ShowItemDropTooltip(event.item, JSON.parse(event.stats));
      }
    )
    itemIcon.SetPanelEvent(
      "onmouseout",
      function(){
        HideItemTooltip();
      }
    )
    dropContainer.MoveChildBefore(itemDropPanel, dropContainer.GetChild(0));
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
            HideItemTooltip();
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
                ShowItemDropTooltip(item.value.itemName, fixedItemStats);
                latestShowedItemId = item.key;
            }
        });
    }
    $.Schedule(0.1, function() {
        ShowDroppedItemTooltip();
    });
}

(function () {
	pagePanels = [$("#Page0"), $("#Page1"), $("#Page2")];
	pageButtons = [$("#Page0Button"), $("#Page1Button"), $("#Page2Button")];
	for(var i = 0; i < INVENTORY_SLOT_LAST + 1; i++) {
		var inventorySlotPanel = $("#InventoryEquippedSlot"+i);
		var inventorySlotImage = $("#InventoryEquippedSlotImage"+i);
		inventorySlotImage.Data().defaultImage = inventorySlotImage.itemname;
		inventoryEquippedSlots.push([inventorySlotPanel, inventorySlotImage, []]);
	}
	OnSwitchPageButtonClick(0);
	CreateInventorySlots();
	SetupDragAndDropForInventoryEquippedSlots();
	CreateElementPanels($("#OffensiveElements"), ELEMENTS_OFFENSIVE);
	CreateElementPanels($("#DefensiveElements"), ELEMENTS_DEFENSIVE);
	compareWindow = [$("#ConflictDialogPanel"), 
	$("#ItemTooltipImage1"), $("#ItemTooltipNameLabel1"), $("#ItemTooltipRarityLabel1"), $("#ItemTooltipTypeLabel1"), $("#ItemTooltipLabel1"),
	$("#ItemTooltipImage2"), $("#ItemTooltipNameLabel2"), $("#ItemTooltipRarityLabel2"), $("#ItemTooltipTypeLabel2"), $("#ItemTooltipLabel2"),
	$("#ItemTooltipQualityLabel1"), $("#ItemTooltipStatsContainer1"), $("#ItemTooltipQualityLabel2"), $("#ItemTooltipStatsContainer2")];
	tooltip = [$("#ItemTooltip"), $("#ItemTooltipImage"), $("#ItemTooltipNameLabel"), $("#ItemTooltipRarityLabel"), $("#ItemTooltipTypeLabel"), $("#ItemTooltipLabel"), $("#ItemTooltipQualityLabel"), $("#ItemTooltipStatsContainer")];
    for (var i = 0; i < initialStatsLabelsInTooltip; i++) {
        var statsLabel = $.CreatePanel("Label", tooltip[TOOLTIP_STATS_CONTAINER], "");
        statsLabel.html = true;
        statsLabel.style.visibility = "collapse";
        statsLabels.push(statsLabel);
        statsLabel = $.CreatePanel("Label", compareWindow[COMPARE_PANEL1_STATS_CONTAINER], "");
        statsLabel.html = true;
        statsLabel.style.visibility = "collapse";
        statsLabelsForCompareWindowPanel1.push(statsLabel);
        statsLabel = $.CreatePanel("Label", compareWindow[COMPARE_PANEL2_STATS_CONTAINER], "");
        statsLabel.html = true;
        statsLabel.style.visibility = "collapse";
        statsLabelsForCompareWindowPanel2.push(statsLabel);
    }
    dropContainer = $("#DropContainer");
    GameEvents.Subscribe("rpg_inventory_open_window_from_server", OnInventoryButtonClicked);
	GameEvents.Subscribe("rpg_inventory_close_window_from_server", OnInventoryWindowCloseRequest);
	GameEvents.Subscribe("rpg_inventory_update_slot", OnUpdateInventorySlotRequest);
	GameEvents.Subscribe("rpg_inventory_start_item_replace_dialog_from_server", OnStartItemReplaceDialogRequest);
	GameEvents.Subscribe("rpg_inventory_items_data", OnInventoryItemsDataRequest);
    GameEvents.Subscribe("rpg_update_hero_stats", OnHeroStatsUpdateRequest);
    GameEvents.Subscribe("rpg_enemy_item_dropped", OnItemDrop);
	ShowDroppedItemTooltip();
    AutoUpdateValues();
})();
