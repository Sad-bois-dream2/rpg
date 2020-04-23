"use strict";

var m_BuffPanels = []; // created up to a high-water mark, but reused
var m_DebuffPanels = [];

function UpdateBuff( buffPanel, queryUnit, buffSerial )
{
	var noBuff = ( buffSerial == -1 );
	buffPanel.SetHasClass( "no_buff", noBuff );
	buffPanel.Data().m_QueryUnit = queryUnit;
	buffPanel.Data().m_BuffSerial = buffSerial;
	if ( noBuff )
	{
		return;
	}
	var isDebuff = Buffs.IsDebuff( queryUnit, buffSerial );
	var nNumStacks = Buffs.GetStackCount( queryUnit, buffSerial );
	var stackCount = buffPanel.FindChildInLayoutFile( "StackCount" );
	var itemImage = buffPanel.FindChildInLayoutFile( "ItemImage" );
	var abilityImage = buffPanel.FindChildInLayoutFile( "AbilityImage" );
	var buffBorder = buffPanel.FindChildInLayoutFile( "BuffBorder" );
	
	buffPanel.SetHasClass( "has_stacks", ( nNumStacks > 0 ) );
	//buffBorder.SetHasClass( "is_debuff", isDebuff );
	
	var completion = Math.max( 0, 360 * (Buffs.GetRemainingTime(queryUnit, buffSerial ) / Buffs.GetDuration(queryUnit, buffSerial )) )
	if(Buffs.GetDuration( queryUnit, buffSerial ) == -1 || Buffs.GetRemainingTime(queryUnit, buffSerial ) < 0)
	{
		completion = 360; 
	}
	buffBorder.style.clip = "radial(50% 50%, 0deg, " + -completion + "deg)";
	if ( stackCount )
	{
		stackCount.text = nNumStacks;
	}
	var buffTexture = Buffs.GetTexture( queryUnit, buffSerial );

	var abilityImagePanel = buffPanel.FindChildInLayoutFile( "AbilityImagePanel" );
	var customIconIdx = buffTexture.indexOf(".png");
	itemImage.itemname = buffTexture;
	if(customIconIdx === -1) {
        abilityImage.abilityname = buffTexture;
	    abilityImagePanel.style.visibility = "collapse";
	    abilityImage.style.visibility = "visible";
	} else {
	    abilityImagePanel.SetImage(buffTexture);
	    abilityImagePanel.style.visibility = "visible";
	    abilityImage.style.visibility = "collapse";
	}
	buffPanel.SetHasClass( "item_buff", false );
	buffPanel.SetHasClass( "ability_buff", true );
	// Item modifiers fix?
	//var itemIdx = buffTexture.indexOf( "item_" );
	/*
		if ( itemIdx === -1 )
	{
		buffPanel.SetHasClass( "item_buff", false );
		buffPanel.SetHasClass( "ability_buff", true );
	}
	else
	{
		buffPanel.SetHasClass( "item_buff", true );
		buffPanel.SetHasClass( "ability_buff", false );
	}
	*/
}
function UpdateDebuffs()
{
	var buffsListPanel = $( "#debuffs_list" );
	if ( !buffsListPanel )
		return;

	var queryUnit = Players.GetLocalPlayerPortraitUnit();
    if(localHero > -1) {
        var IsAlly = Entities.GetTeamNumber(localHero) == Entities.GetTeamNumber(queryUnit);
        if(!IsAlly) {
            queryUnit = localHero;
        }
    }

	var nBuffs = Entities.GetNumBuffs( queryUnit );
	
	// update all the panels
	var nUsedPanels = 0;
	for ( var i = 0; i < nBuffs; ++i )
	{
		var buffSerial = Entities.GetBuff( queryUnit, i );
		if ( buffSerial == -1 )
			continue;

		if ( Buffs.IsHidden( queryUnit, buffSerial ) )
			continue;
		if ( !Buffs.IsDebuff( queryUnit, buffSerial ) ) 
			continue;
	
		if ( nUsedPanels >= m_DebuffPanels.length )
		{
			// create a new panel
			var buffPanel = $.CreatePanel( "Panel", buffsListPanel, "" );
			buffPanel.BLoadLayout( "file://{resources}/layout/custom_game/buff_list_debuff.xml", false, false );
			m_DebuffPanels.push( buffPanel );
		}

		// update the panel for the current unit / buff
		var buffPanel = m_DebuffPanels[ nUsedPanels ];
		UpdateBuff( buffPanel, queryUnit, buffSerial );
		
		nUsedPanels++;
	}

	// clear any remaining panels
	for ( var i = nUsedPanels; i < m_DebuffPanels.length; ++i )
	{
		var buffPanel = m_DebuffPanels[ i ];
		UpdateBuff( buffPanel, -1, -1 );
	}
}

function UpdateBuffs()
{
	var buffsListPanel = $( "#buffs_list" );
	if ( !buffsListPanel )
		return;

	var queryUnit = Players.GetLocalPlayerPortraitUnit();
    if(localHero > -1) {
        var IsAlly = Entities.GetTeamNumber(localHero) == Entities.GetTeamNumber(queryUnit);
        if(!IsAlly) {
            queryUnit = localHero;
        }
    }

	var nBuffs = Entities.GetNumBuffs( queryUnit );
	
	// update all the panels
	var nUsedPanels = 0;
	for ( var i = 0; i < nBuffs; ++i )
	{
		var buffSerial = Entities.GetBuff( queryUnit, i );
		if ( buffSerial == -1 )
			continue;

		if ( Buffs.IsHidden( queryUnit, buffSerial ) )
			continue;
		if ( Buffs.IsDebuff( queryUnit, buffSerial ) ) 
			continue;
	
		if ( nUsedPanels >= m_BuffPanels.length )
		{
			// create a new panel
			var buffPanel = $.CreatePanel( "Panel", buffsListPanel, "" );
			buffPanel.BLoadLayout( "file://{resources}/layout/custom_game/buff_list_buff.xml", false, false );
			m_BuffPanels.push( buffPanel );
		}

		// update the panel for the current unit / buff
		var buffPanel = m_BuffPanels[ nUsedPanels ];
		UpdateBuff( buffPanel, queryUnit, buffSerial );
		
		nUsedPanels++;
	}

	// clear any remaining panels
	for ( var i = nUsedPanels; i < m_BuffPanels.length; ++i )
	{
		var buffPanel = m_BuffPanels[ i ];
		UpdateBuff( buffPanel, -1, -1 );
	}
}
var localHero = -1;

function AutoUpdateBuffs()
{
	UpdateBuffs();
	UpdateDebuffs();
	if(localHero == -1) {
	    var localPlayerId = Players.GetLocalPlayer();
	    localHero = Players.GetPlayerHeroEntityIndex(localPlayerId);
	}
	$.Schedule( 0.1, AutoUpdateBuffs );
}

(function()
{
	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateBuffs );
	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateBuffs );
	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateDebuffs );
	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateDebuffs );
	AutoUpdateBuffs(); // initial update of dynamic state
})();

