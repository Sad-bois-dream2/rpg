"use strict";

var m_Ability = -1;
var m_QueryUnit = -1;
var m_bInLevelUp = false;

var LOCAL_PLAYER_HERO;

function OnLevelUpClicked()
{
	var canUpgradeRet = Abilities.CanAbilityBeUpgraded( m_Ability );
	var canUpgrade = ( canUpgradeRet == AbilityLearnResult_t.ABILITY_CAN_BE_UPGRADED );
	if(canUpgrade) {
		var abilityLevelOrder =
		{
			OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_TRAIN_ABILITY,
			AbilityIndex: m_Ability
		};
		Game.PrepareUnitOrders( abilityLevelOrder );
	}
}


function SetAbility( ability, queryUnit, bInLevelUp )
{
	var bChanged = ( ability !== m_Ability || queryUnit !== m_QueryUnit );
	m_Ability = ability;
	m_QueryUnit = queryUnit;
	m_bInLevelUp = bInLevelUp;
	
	var canUpgradeRet = Abilities.CanAbilityBeUpgraded( m_Ability );
	var canUpgrade = ( canUpgradeRet == AbilityLearnResult_t.ABILITY_CAN_BE_UPGRADED );
	
	$.GetContextPanel().SetHasClass( "no_ability", ( ability == -1 ) );
	$.GetContextPanel().SetHasClass( "learnable_ability", bInLevelUp && canUpgrade );

	RebuildAbilityUI();
	UpdateAbility();
}

function AutoUpdateAbility()
{
	UpdateAbility();
	$.Schedule( 0.1, AutoUpdateAbility );
}

function UpdateAbility()
{
	var abilityButton = $( "#AbilityButton" );
	var abilityName = Abilities.GetAbilityName( m_Ability );
	var noLevel =( 0 == Abilities.GetLevel( m_Ability ) );
	var isCastable = !Abilities.IsPassive( m_Ability ) && !noLevel;
	var manaCost = Abilities.GetManaCost( m_Ability );
	var hotkey = Abilities.GetKeybind( m_Ability, m_QueryUnit );
	var unitMana = Entities.GetMana( m_QueryUnit );

	$.GetContextPanel().SetHasClass( "no_level", noLevel );
	$.GetContextPanel().SetHasClass( "is_passive", Abilities.IsPassive(m_Ability) );
	$.GetContextPanel().SetHasClass( "no_mana_cost", ( 0 == manaCost ) );
	$.GetContextPanel().SetHasClass( "insufficient_mana", ( manaCost > unitMana ) );
	$.GetContextPanel().SetHasClass( "auto_cast_enabled", Abilities.GetAutoCastState(m_Ability) );
	$.GetContextPanel().SetHasClass( "toggle_enabled", Abilities.GetToggleState(m_Ability) );
	$.GetContextPanel().SetHasClass( "is_active", ( m_Ability == Abilities.GetLocalPlayerActiveAbility() ) );

	//abilityButton.enabled = ( isCastable || m_bInLevelUp );
	
	$( "#HotkeyText" ).text = hotkey;
	
	$( "#AbilityImage" ).abilityname = abilityName;
	$( "#AbilityImage" ).contextEntityIndex = m_Ability;
	
	$( "#ManaCost" ).text = manaCost;
	
	if ( Abilities.IsCooldownReady( m_Ability ) )
	{
		$.GetContextPanel().SetHasClass( "cooldown_ready", true );
		$.GetContextPanel().SetHasClass( "in_cooldown", false );
	}
	else
	{
		$.GetContextPanel().SetHasClass( "cooldown_ready", false );
		$.GetContextPanel().SetHasClass( "in_cooldown", true );
		var cooldownLength = Abilities.GetCooldownLength( m_Ability );
		var cooldownRemaining = Abilities.GetCooldownTimeRemaining( m_Ability );
		var cooldownPercent = Math.ceil( 100 * cooldownRemaining / cooldownLength );
		var cooldownOverlayValue = cooldownPercent * 3.6;
		$( "#CooldownOverlay" ).style.clip = "radial(50% 50%, 0deg, " + -cooldownOverlayValue + "deg)";
		$( "#CooldownTimer" ).text = Math.ceil( cooldownRemaining );
		//$( "#CooldownOverlay" ).style.width = "50%";
	}
	
}

function AbilityShowTooltip()
{
	var abilityButton = $( "#AbilityButton" );
	var abilityName = Abilities.GetAbilityName( m_Ability );
	// If you don't have an entity, you can still show a tooltip that doesn't account for the entity
	//$.DispatchEvent( "DOTAShowAbilityTooltip", abilityButton, abilityName );
	
	// If you have an entity index, this will let the tooltip show the correct level / upgrade information
	$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", abilityButton, abilityName, m_QueryUnit );
}

function AbilityHideTooltip()
{
	var abilityButton = $( "#AbilityButton" );
	$.DispatchEvent( "DOTAHideAbilityTooltip", abilityButton );
}

function ActivateAbility()
{
	if(GameUI.IsAltDown()) {
		Abilities.PingAbility(m_Ability);
		return;
	}
	if ( m_bInLevelUp )
	{
		Abilities.AttemptToUpgrade( m_Ability );
		return;
	}
	if(LOCAL_PLAYER_HERO == m_QueryUnit) {
		Abilities.ExecuteAbility( m_Ability, m_QueryUnit, false );
	}
}

function DoubleClickAbility()
{
	if(LOCAL_PLAYER_HERO == m_QueryUnit) {
	// Handle double-click like a normal click - ExecuteAbility will either double-tap (self cast) or normal toggle as appropriate
		ActivateAbility();
	}
}

function RightClickAbility()
{
	if ( m_bInLevelUp || LOCAL_PLAYER_HERO != m_QueryUnit)
		return;

	if ( Abilities.IsAutocast( m_Ability ) )
	{
		Game.PrepareUnitOrders( { OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO, AbilityIndex: m_Ability } );
	}
}

function RebuildAbilityUI()
{
	var abilityLevelContainer = $( "#AbilityLevelContainer" );
	abilityLevelContainer.RemoveAndDeleteChildren();
	var currentLevel = Abilities.GetLevel( m_Ability );
	var maxLevel = Abilities.GetMaxLevel( m_Ability );
	var root = $.GetContextPanel();
	if(maxLevel <= 0 && Abilities.GetManaCost( m_Ability ) == -1) {
		root.style.visibility = "collapse";
	} else {
		root.style.visibility = "visible";
	}
	var abiltiyLevelContainerHeight = Math.max(1, Math.ceil(maxLevel / 4)) * 16;
	abilityLevelContainer.style.height = abiltiyLevelContainerHeight + "px";
	var canUpgradeRet = Abilities.CanAbilityBeUpgraded( m_Ability );
	var canUpgrade = ( canUpgradeRet == AbilityLearnResult_t.ABILITY_CAN_BE_UPGRADED );
	var nRemainingPoints = Entities.GetAbilityPoints( m_QueryUnit );
	var bPointsToSpend = ( nRemainingPoints > 0 );
	var abilityLevelButton = $( "#AbilityLevelPanel" );
	var abilityLevelButtonFiller = $( "#AbilityLevelPanelFiller" );
	var isValidUnitForLearnBorder = (LOCAL_PLAYER_HERO == m_QueryUnit);
	$.GetContextPanel().SetHasClass( "learnable_ability", (canUpgrade && bPointsToSpend && isValidUnitForLearnBorder));
	abilityLevelButton.style.visibility = (canUpgrade && bPointsToSpend && isValidUnitForLearnBorder) ? "visible" : "collapse";
	abilityLevelButtonFiller.style.visibility = (canUpgrade && bPointsToSpend && isValidUnitForLearnBorder) ? "collapse" : "visible";
	for ( var lvl = 0; lvl < Abilities.GetMaxLevel( m_Ability ); lvl++ )
	{
		var levelPanel = $.CreatePanel( "Panel", abilityLevelContainer, "" );
		levelPanel.AddClass( "LevelPanel" );
		levelPanel.SetHasClass( "active_level", ( lvl < currentLevel ) );
		levelPanel.SetHasClass( "next_level", ( lvl == currentLevel ) );
	}
}

(function()
{
	$.GetContextPanel().Data().SetAbility = SetAbility;
	GameEvents.Subscribe( "dota_ability_changed", RebuildAbilityUI ); // major rebuild
	AutoUpdateAbility(); // initial update of dynamic state
	var localPlayer = Game.GetLocalPlayerID();
	LOCAL_PLAYER_HERO = Players.GetPlayerHeroEntityIndex(localPlayer);
})();
