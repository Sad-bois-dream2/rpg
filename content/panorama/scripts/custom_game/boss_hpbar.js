var localPlayerId;
var bossPanel, bossImage, bossName, bossHpBar, bossHpBarValue, bossHpBarRegValue, bossMpBar, bossMpBarValue, bossMpBarRegValue, bossAbilitiesPanel, bossBuffPanel, bossDebuffPanel;
var bossAttackDamage, bossArmor, bossElementalArmor, bossMovespeed;
var bossAbilties = [];
var MAX_ABILITIES_ON_PANEL = 10;
var latestSelectedCreep;
var m_BuffPanels = [];
var m_DebuffPanels = [];

function OnPortraitClick() {
	var IsAltDown = GameUI.IsAltDown();
	GameUI.SetCameraTargetPosition(Entities.GetAbsOrigin(latestSelectedCreep), -1.0);
	if(IsAltDown) {
		var player = Players.GetLocalPlayer();
		var message = "Enemy " + $.Localize("#" + Entities.GetUnitName(latestSelectedCreep)) + " is still alive.";
		GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message});
	}
}

function OnHPBarClick() {
	var IsAltDown = GameUI.IsAltDown();
	if(IsAltDown) {
		var player = Players.GetLocalPlayer();
		var currentHp = Entities.GetHealth(latestSelectedCreep);
		var maxHp = Entities.GetMaxHealth(latestSelectedCreep);
		var hpPercent = (currentHp / maxHp) * 100;
		hpPercent = Math.round(hpPercent * 100) / 100;
		var message = "Enemy " + $.Localize("#" + Entities.GetUnitName(latestSelectedCreep)) + " have " + currentHp + " (" + hpPercent + "%) health left.";
		GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message});
	}
}

function OnMPBarClick() {
	var IsAltDown = GameUI.IsAltDown();
	if(IsAltDown) {
		var player = Players.GetLocalPlayer();
		var currentMp = Entities.GetMana(latestSelectedCreep);
		var maxMp = Entities.GetMaxMana(latestSelectedCreep);
		var mpPercent = (currentMp / maxMp) * 100;
		mpPercent = Math.round(mpPercent * 100) / 100;
		if (!isNaN(mpPercent)) {
			var message = "Enemy " + $.Localize("#" + Entities.GetUnitName(latestSelectedCreep)) + " have " + currentMp + " (" + mpPercent + "%) mana left.";
			GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message});
		}
	}
}

function RenderBossModel(bossName) {
    bossImage.RemoveAndDeleteChildren()
    bossImage.BCreateChildren("<DOTAScenePanel id='BossPortraitScenePanel' antialias='true' renderdeferred='false' class='OverviewHeroRender' map='enemies' particleonly='false' light='" + bossName +"_light' camera='" + bossName + "'/>");
}

function UpdateSelection() {
    var selectedCreep = Players.GetLocalPlayerPortraitUnit();
    if (Entities.GetTeamNumber(selectedCreep) != Players.GetTeam(localPlayerId)) {
        bossPanel.style.visibility = "visible";
        latestSelectedCreep = selectedCreep;
        UpdateModifiers();
		GameEvents.SendCustomGameEventToServer("rpg_update_enemy_stats", { "player_id" : Players.GetLocalPlayer(), "enemy": selectedCreep});
        var currentAbilities = 0;
        var abiltiesCount = Entities.GetAbilityCount(selectedCreep);
        for (var i = 0; i < MAX_ABILITIES_ON_PANEL; i++) {
            bossAbilties[i].Data().abilityPanel.abilityname = "empty";
            bossAbilties[i].Data().cooldownPanel.SetHasClass("in_cooldown", false);
            bossAbilties[i].Data().ready = false;
        }
		//bossImage.SetUnit(Entities.GetUnitName(selectedCreep), "fuckyou", false);
		RenderBossModel(Entities.GetUnitName(selectedCreep))
        var lastLegitIndex = 0;
        for (var i = 0; i < abiltiesCount; i++) {
            var ability = Entities.GetAbility(selectedCreep, i);
            var abilityLevel = Abilities.GetLevel(ability);
            var IsValidAbility = (abilityLevel > 0 && Abilities.GetMaxLevel(ability) > 0 && Abilities.GetManaCost(ability) > -1 && !Abilities.IsHidden(ability));
            if (IsValidAbility) {
                bossAbilties[lastLegitIndex].Data().abilityPanel.abilityname = Abilities.GetAbilityName(ability);
                bossAbilties[lastLegitIndex].Data().abilityPanel.abilitylevel = abilityLevel;
                bossAbilties[lastLegitIndex].Data().abilityIndex = i;
                bossAbilties[lastLegitIndex].Data().ability = ability;
                bossAbilties[lastLegitIndex].Data().ready = true;
                lastLegitIndex++;
                currentAbilities++;
            }
            if (currentAbilities >= MAX_ABILITIES_ON_PANEL) {
                break;
            }
        }
    }
}

function UpdateValues() {
    if (latestSelectedCreep != null && Entities.GetTeamNumber(latestSelectedCreep) != Players.GetTeam(localPlayerId)) {
        bossPanel.style.visibility = Entities.IsAlive(latestSelectedCreep) ? "visible" : "collapse";
    } else {
        return;
    }
    var name = $.Localize("#" + Entities.GetUnitName(latestSelectedCreep));
    var currentHp = Entities.GetHealth(latestSelectedCreep);
    var maxHp = Entities.GetMaxHealth(latestSelectedCreep);
    var hpReg = Entities.GetHealthThinkRegen(latestSelectedCreep);
    var hpPercent = (currentHp / maxHp) * 100;
    var currentMp = Entities.GetMana(latestSelectedCreep);
    var maxMp = Entities.GetMaxMana(latestSelectedCreep);
    var mpReg = Entities.GetManaThinkRegen(latestSelectedCreep);
    var mpPercent = (currentMp / maxMp) * 100;
	var IsAltDown = GameUI.IsAltDown();
    if (isNaN(mpPercent)) {
        mpPercent = 100;
    }
    bossName.text = name;
	if(!IsAltDown) {
		bossHpBarValue.text = currentHp + " / " + maxHp;
	} else {
		bossHpBarValue.text = (Math.round(hpPercent * 100) / 100) + "%";
	}
    var preSymbol = "+";
    if(mpReg < 0) {
        preSymbol = "";
    }
    if(hpReg == 0) {
        bossHpBarRegValue.style.visibility = "collapse";
    } else {
        bossHpBarRegValue.style.visibility = "visible";
    }
    bossHpBar.style.width = hpPercent + "%";
    bossHpBarRegValue.text = preSymbol + (Math.round(hpReg * 100) / 100);
    bossMpBar.style.width = mpPercent + "%";
    if (maxMp == 0) {
        bossMpBarValue.text = "";
        bossMpBarRegValue.text = "";
    } else {
        if(!IsAltDown) {
            bossMpBarValue.text = currentMp + " / " + maxMp;
        } else {
            bossMpBarValue.text = (Math.round(mpPercent * 100) / 100) + "%";
        }
        preSymbol = "+";
        if(mpReg < 0) {
            preSymbol = "";
        }
        if(mpReg == 0) {
            bossMpBarRegValue.style.visibility = "collapse";
        } else {
            bossMpBarRegValue.style.visibility = "visible";
        }
        bossMpBarRegValue.text = preSymbol + (Math.round(mpReg * 100) / 100);
    }
    if(latestStats) {
        bossAttackDamage.text = Entities.GetDamageMax(latestSelectedCreep);
        var armorReduction = (latestStats.armor * 0.06) / (1 + latestStats.armor * 0.06);
        bossArmor.text = (Math.round(armorReduction * 10000) / 100) + "%";
        var elementalArmorValue = 0;
        var arr = Object.values(latestStats.elementsProtection);
        var length = arr.length;
        for(var i = 0; i < length; i++) {
            elementalArmorValue += (1 - arr[i]);
        }
        elementalArmorValue = elementalArmorValue / length;
        bossElementalArmor.text = Math.round(elementalArmorValue * 10000) / 100 + "%";
        bossMovespeed.text = Entities.GetMoveSpeedModifier(latestSelectedCreep, Entities.GetBaseMoveSpeed(latestSelectedCreep));
    }
    for (var i = 0; i < MAX_ABILITIES_ON_PANEL; i++) {
        if (bossAbilties[i].Data().abilityPanel.abilityname !== "empty" && bossAbilties[i].Data().ready) {
            var ability = bossAbilties[i].Data().ability;
            var IsAbilityReady = Abilities.IsCooldownReady(ability);
            var manacost = Abilities.GetManaCost(ability);
            bossAbilties[i].Data().cooldownPanel.SetHasClass("in_cooldown", !IsAbilityReady);
            if (!IsAbilityReady) {
                var cooldownLength = Abilities.GetCooldownLength(ability);
                var cooldownRemaining = Abilities.GetCooldownTimeRemaining(ability);
                var cooldownPercent = Math.ceil(100 * (cooldownRemaining / cooldownLength));
                var cooldownOverlayValue = cooldownPercent * 3.6;
                bossAbilties[i].Data().cooldownOverlay.style.clip = "radial(50% 50%, 0deg, " + -cooldownOverlayValue + "deg)";
                bossAbilties[i].Data().cooldownTimer.text = Math.ceil(cooldownRemaining);
            }
            bossAbilties[i].Data().manacost.text = manacost > 0 ? manacost : "";
            bossAbilties[i].Data().abilityPanel.SetHasClass("insufficient_mana", manacost > currentMp);
        }
    }
}

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
}

function UpdateDebuffs()
{
	var queryUnit = latestSelectedCreep;
	if(queryUnit == null) {
	    return;
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
			var buffPanel = $.CreatePanel( "Panel", bossDebuffPanel, "" );
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
	var queryUnit = latestSelectedCreep;
	if(queryUnit == null) {
	    return;
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
			var buffPanel = $.CreatePanel( "Panel", bossBuffPanel, "" );
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

function UpdateModifiers() {
    UpdateBuffs();
    UpdateDebuffs();
}

function AutoUpdateValues() {
    UpdateValues();
    UpdateModifiers();
    $.Schedule(0.1, function() {
        AutoUpdateValues();
    });
}

var aggroParticle = null;

function OnAggroChanged(event) {
    if(latestSelectedCreep != event.creep) {
        return
    }
	if(aggroParticle != null) {
		Particles.DestroyParticleEffect( aggroParticle, true );
		Particles.ReleaseParticleIndex( aggroParticle );
	}
	aggroParticle = Particles.CreateParticle( "particles/aggro.vpcf", ParticleAttachment_t.PATTACH_POINT_FOLLOW, event.target );
	Particles.SetParticleControl(aggroParticle, 0, Entities.GetAbsOrigin(event.target) );
	Particles.SetParticleControl(aggroParticle, 3, [255,0,0] );
}

var latestStats;

function OnUpdateStatsRequest(event) {
    if(event.enemy == latestSelectedCreep) {
	    latestStats = JSON.parse(event.stats);
    }
}

function ClosePanel() {
    latestSelectedCreep = null
    bossPanel.style.visibility = "collapse";
}

(function() {
    var root = $.GetContextPanel();
    bossPanel = root.GetChild(0);
    bossImage = $('#BossPortraitImage');
    bossName = $('#BossName');
    bossHpBar = $('#BossHpBar');
    bossHpBarValue = $('#BossHpBarValue');
    bossHpBarRegValue = $('#BossHpBarRegValue');
    bossMpBar = $('#BossMpBar');
    bossMpBarValue = $('#BossMpBarValue');
    bossMpBarRegValue = $('#BossMpBarRegValue');
    bossAbilitiesPanel = $('#BossAbilitiesPanel');
    bossBuffPanel = $("#BossBuffPanel");
    bossDebuffPanel = $("#BossDebuffPanel");
    bossAttackDamage = $("#BossAttackDamage");
    bossArmor = $("#BossArmor");
    bossElementalArmor = $("#BossElementArmor");
    bossMovespeed = $("#BossMoveSpeed");
    localPlayerId = Players.GetLocalPlayer();
    for (var i = 0; i < MAX_ABILITIES_ON_PANEL; i++) {
        var abilityPanel = $.CreatePanel("Panel", bossAbilitiesPanel, "");
        abilityPanel.BLoadLayout("file://{resources}/layout/custom_game/boss_hpbar_ability.xml", false, false);
        abilityPanel.Data().abilityPanel = abilityPanel.GetChild(0);
        abilityPanel.Data().cooldownPanel = abilityPanel.GetChild(1);
        abilityPanel.Data().cooldownOverlay = abilityPanel.Data().cooldownPanel.GetChild(0);
        abilityPanel.Data().cooldownTimer = abilityPanel.Data().cooldownPanel.GetChild(1);
        abilityPanel.Data().manacost = abilityPanel.GetChild(2);
        abilityPanel.Data().ready = false;
        bossAbilties.push(abilityPanel);
    }
    GameEvents.Subscribe("dota_player_update_query_unit", UpdateSelection);
    GameEvents.Subscribe("dota_player_update_selected_unit", UpdateSelection);
    GameEvents.Subscribe("rpg_aggro_target_changed", OnAggroChanged);
    GameEvents.Subscribe("rpg_update_enemy_stats_from_server", OnUpdateStatsRequest);
    AutoUpdateValues();
})();