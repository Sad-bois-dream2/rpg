"use strict";

var m_InventoryPanels = []

// Currently hardcoded: first 6 are inventory, next 6 are stash items
var DOTA_ITEM_BACKPACK_MIN = 6;
var DOTA_ITEM_STASH_MIN = 9;
var DOTA_ITEM_STASH_MAX = 15;
function UpdateInventory()
{
	var queryUnit = Players.GetLocalPlayerPortraitUnit();
	for ( var i = 0; i < DOTA_ITEM_STASH_MAX; ++i )
	{
		var inventoryPanel = m_InventoryPanels[i]
		var item = Entities.GetItemInSlot( queryUnit, i );
		inventoryPanel.Data().SetItem( queryUnit, item );
	}
}

function CreateInventoryPanels()
{
	var stashPanel = $( "#stash_row" );
	var firstRowPanel = $( "#inventory_row_1" );
	var secondRowPanel = $( "#inventory_row_2" );
	var thirdRowPanel = $( "#inventory_row_3" );
	if ( !stashPanel || !firstRowPanel || !secondRowPanel || !thirdRowPanel)
		return;

	stashPanel.RemoveAndDeleteChildren();
	firstRowPanel.RemoveAndDeleteChildren();
	secondRowPanel.RemoveAndDeleteChildren();
	thirdRowPanel.RemoveAndDeleteChildren();
	m_InventoryPanels = []

	for ( var i = 0; i < DOTA_ITEM_STASH_MAX; ++i )
	{
		var parentPanel = firstRowPanel;
		if ( i >= 3 )
		{
			parentPanel = secondRowPanel;
		}
		if(i >= DOTA_ITEM_BACKPACK_MIN) {
			parentPanel = thirdRowPanel;
		}
		else if ( i > DOTA_ITEM_STASH_MIN )
		{
			parentPanel = stashPanel;
		}

		var inventoryPanel = $.CreatePanel( "Panel", parentPanel, "" );
		inventoryPanel.BLoadLayout( "file://{resources}/layout/custom_game/inventory_item.xml", false, false );
		inventoryPanel.Data().SetItemSlot( i );

		m_InventoryPanels.push( inventoryPanel );
	}
}


(function()
{
	CreateInventoryPanels();
	UpdateInventory();

	GameEvents.Subscribe( "dota_inventory_changed", UpdateInventory );
	GameEvents.Subscribe( "dota_inventory_item_changed", UpdateInventory );
	GameEvents.Subscribe( "m_event_dota_inventory_changed_query_unit", UpdateInventory );
	GameEvents.Subscribe( "m_event_keybind_changed", UpdateInventory );
	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateInventory );
	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateInventory );
})();

