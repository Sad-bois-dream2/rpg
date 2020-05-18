local LinkedModifiers = {}

--------------------------------------------------------------------------------
-- Phantom of Vengeance modifiers 

modifier_phantom_ranger_phantom_of_vengeance_phantom = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetEffectName = function(self)
        return "particles/units/phantom_ranger/test/soul_echo/soul_echo_phantom.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_ABSORIGIN_FOLLOW
    end,
    GetStatusEffectName = function(self)
        return "particles/status_fx/status_effect_maledict.vpcf"
    end,
    StatusEffectPriority = function(self)
        return 15
    end,
    CheckState = function(self)
    if not IsServer() then return end
        return
        {
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_INVULNERABLE] = true,
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_MAGIC_IMMUNE] = true,
            [MODIFIER_STATE_UNSELECTABLE] = true,
            [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
            [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
        }
    end,
    DeclareFunctions = function(self)
    return { MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN }
end
})

LinkedModifiers["modifier_phantom_ranger_phantom_of_vengeance_phantom"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_phantom_ranger_phantom_of_vengeance_phantom:OnCreated(params)
    if not IsServer() then return end
    self.phantomSpeed = params.phantomSpeed
end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_phantom_of_vengeance_phantom:GetModifierMoveSpeed_AbsoluteMin()
    return self.phantomSpeed
end

--------------------------------------------------------------------------------
-- Phantom of Vengeance

phantom_ranger_phantom_of_vengeance = class({
    GetAbilityTextureName = function(self)	
        return "phantom_ranger_phantom_of_vengeance"
    end
})

--------------------------------------------------------------------------------

 function phantom_ranger_phantom_of_vengeance:GetAssociatedSecondaryAbilities()
     return "phantom_ranger_shadowstep"
 end

--------------------------------------------------------------------------------

function phantom_ranger_phantom_of_vengeance:OnSpellStart(pSource, pTarget)

	self.caster = self:GetCaster()
    self.caster.phantom_of_vengeance_shadowstep_enabled = false
    self.damage = self:GetSpecialValueFor("contact_damage")
    self.cdr = self:GetSpecialValueFor("contact_cdr")
    self.receivedCdr = false
	local phantomSpeed = self:GetSpecialValueFor("phantom_speed")
    local radius = self:GetSpecialValueFor("radius")
    local phantomDuration = self:GetSpecialValueFor("duration")
	local source
	local target
    local sourceUnit
	if (pSource) then 

        sourceUnit = pSource  
        source = pSource:GetAbsOrigin() 

    else 

        sourceUnit = self.caster
        source = self.caster:GetAbsOrigin() 

    end
	if (pTarget) then target = pTarget:GetAbsOrigin() else target = self:GetCursorPosition() end
    if target == source then
        self.caster:SetCursorPosition(target + self.caster:GetForwardVector())
        target = self:GetCursorPosition()
    end
    -- Damaging part of the spell is a linear projectile.
    local distance = DistanceBetweenVectors(source, target)
	local targetVector = target - source
    local projectile = {
        Source = sourceUnit,
        vSpawnOrigin = source,
        Ability = self,
        bDodgable = false,
        bProvidesVision = false,
        fDistance = distance,
        fStartRadius = radius,
        fEndRadius = radius,
        vVelocity = targetVector:Normalized() * phantomSpeed,
        bDeleteOnHit = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bReplaceExisting = false,
        bProvidesVision = false
    }
    Timers:CreateTimer(0.05, function()
        self.caster.phantom_of_vengeance_projectile = ProjectileManager:CreateLinearProjectile(projectile)
        sourceUnit:EmitSound("Hero_Spectre.Haunt")
    end) 

    local phantom = self:CreatePhantomAtPoint(source, phantomSpeed, phantomDuration)
    Timers:CreateTimer(0.05, function()
        phantom:MoveToPosition(target)
        end, self)


    if not self.caster:HasAbility("phantom_ranger_shadowstep") then
        local index
        local i = 7
        while (not index and i < self.caster:GetAbilityCount()) do
            if (not self.caster:GetAbilityByIndex(i)) then index = i end
            i = i + 1
        end
        local ability = self.caster:AddAbility("phantom_ranger_shadowstep")
        if (index) then ability:SetAbilityIndex(index) end
    end
    self.caster:SwapAbilities("phantom_ranger_phantom_of_vengeance", "phantom_ranger_shadowstep", false, true)
    self.caster.phantom_of_vengeance_shadowstep_enabled = true
    self.caster:FindAbilityByName("phantom_ranger_shadowstep"):SetLevel(1)
    -- Goes on a 0.1 second cooldown when ability is cast to prevent accidental double tap
    self.caster:FindAbilityByName("phantom_ranger_shadowstep"):StartCooldown(0.1)
end

--------------------------------------------------------------------------------

function phantom_ranger_phantom_of_vengeance:OnProjectileHit(target, location)

    if (target) then

        GameMode:DamageUnit({ caster = self.caster, target = target, ability = self, damage = Units:GetAttackDamage(self.caster) * self.damage / 100, voiddmg = true })
        target:EmitSound("Hero_Spectre.HauntCast")
        if ((Enemies:IsBoss(target) or Enemies:IsElite(target)) and not self.receivedCdr) then 

            self.receivedCdr = true
            GameMode:ReduceAbilityCooldown({ ability = self:GetAbilityName(), reduction = self.cdr, isflat = true, target = self.caster })

        end

    end

end

--------------------------------------------------------------------------------

function phantom_ranger_phantom_of_vengeance:CreatePhantomAtPoint(point, phantomSpeed, phantomDuration)

    local phantom = CreateUnitByName("npc_dota_phantom_ranger_phantom", point, true, self.caster, self.caster, self.caster:GetTeamNumber())
    local pSpeed
    if (phantomSpeed) then pSpeed = phantomSpeed else pSpeed = phantom:GetBaseMoveSpeed() end
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = phantom
    modifierTable.caster = phantom
    modifierTable.modifier_name = "modifier_phantom_ranger_phantom_of_vengeance_phantom"
    modifierTable.duration = -1
    modifierTable.modifier_params = { phantomSpeed = pSpeed }
    GameMode:ApplyBuff(modifierTable)
    phantom:SetOwner(self.caster)
    local wearables = GetWearables(self.caster)
    AddWearables(phantom, wearables)
    phantom:SetRenderColor(120, 0, 30)
    ForEachWearable(phantom, function(wearable)
        wearable:SetRenderColor(120, 0, 30)
    end)
    if (phantomDuration) then 

        Timers:CreateTimer(phantomDuration, function()

            phantom_ranger_phantom_of_vengeance:DestroyPhantom(phantom)
            if (self.caster.phantom_of_vengeance_shadowstep_enabled) then

                self.caster:SwapAbilities("phantom_ranger_shadowstep", "phantom_ranger_phantom_of_vengeance", false, true)
                self.caster.phantom_of_vengeance_shadowstep_enabled = false

            end

        end)

    end

    return phantom

end

--------------------------------------------------------------------------------

function phantom_ranger_phantom_of_vengeance:DestroyPhantom(phantom)
    if (phantom ~= nil and phantom:IsAlive()) then
        DestroyWearables(phantom, function()
            phantom:Destroy()
        end)
    end
end

--------------------------------------------------------------------------------
-- Shadowstep (phantom of vengeance associated spell)

phantom_ranger_shadowstep = class({
    GetAbilityTextureName = function(self)  
        return "phantom_ranger_shadowstep"
    end
})

--------------------------------------------------------------------------------

 function phantom_ranger_phantom_of_vengeance:GetAssociatedPrimaryAbilities()
     return "phantom_ranger_phantom_of_vengeance"
 end

--------------------------------------------------------------------------------

function phantom_ranger_shadowstep:OnSpellStart()

    if not IsServer() then return end
    local caster = self:GetCaster()
    local target = self:GetCursorPosition()
    local activePhantoms = FindActivePhantoms(caster)
    if (activePhantoms) then

        local closestPhantom = activePhantoms[1]
        local closestPhantomPoint = activePhantoms[1]:GetAbsOrigin()
        local closestDistance = DistanceBetweenVectors(target, closestPhantomPoint)
        for _, phantom in pairs(activePhantoms) do

            if (DistanceBetweenVectors(target, phantom:GetAbsOrigin()) < closestDistance) then

                closestPhantom = phantom
                closestPhantomPoint = phantom:GetAbsOrigin()
                closestDistance = DistanceBetweenVectors(target, closestPhantomPoint)

            end

        end

        closestPhantom:Stop()
        ProjectileManager:DestroyLinearProjectile(self.caster.phantom_of_vengeance_projectile)
        FindClearSpaceForUnit(closestPhantom, caster:GetAbsOrigin(), true)
        FindClearSpaceForUnit(caster, closestPhantomPoint, true)
        caster:EmitSound("Hero_Spectre.Reality")

    end    
    if (caster.phantom_of_vengeance_shadowstep_enabled) then

        caster:SwapAbilities("phantom_ranger_shadowstep", "phantom_ranger_phantom_of_vengeance", false, true)
        caster.phantom_of_vengeance_shadowstep_enabled = false

    end

end

--------------------------------------------------------------------------------
-- Black Arrow modifiers 

modifier_phantom_ranger_black_arrow_debuff = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAbilityTextureName = function(self)
        return "phantom_ranger_black_arrow"
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACKED }
    end
})

LinkedModifiers["modifier_phantom_ranger_black_arrow_debuff"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_phantom_ranger_black_arrow_debuff:OnCreated()

	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.target = self:GetParent()
	self.ability = self:GetAbility()
	self.damage = self.ability:GetSpecialValueFor("black_arrow_damage")
	self.baneDamage = self.ability:GetSpecialValueFor("bane_damage")
	self.baneDuration = self.ability:GetSpecialValueFor("bane_duration")
	self.baneMaxStacks = self.ability:GetSpecialValueFor("bane_max_stacks")
	local tickRate = self.ability:GetSpecialValueFor("tick_rate")
	self:StartIntervalThink (tickRate)
	self:OnIntervalThink()

end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_black_arrow_debuff:OnIntervalThink()

	if not IsServer() then return end
	local hasBane = self.target:FindModifierByName("modifier_phantom_ranger_black_arrow_bane")
	local finalDamage = Units:GetAttackDamage(self.caster) * self.damage / 100
	if (hasBane) then

		local baneStacks = hasBane:GetStackCount()
		finalDamage = finalDamage * (1 + baneStacks * self.baneDamage / 100)

	end
	GameMode:DamageUnit({ caster = self.caster, target = self.target, ability = self.ability, damage = finalDamage, voiddmg = true })

end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_black_arrow_debuff:OnAttacked(params)

	if not IsServer() then return end
	if (params.attacker == self.caster) then
		GameMode:ApplyStackingDebuff({ caster = self.caster, target = params.target, ability = self.ability, modifier_name = "modifier_phantom_ranger_black_arrow_bane", duration = self.baneDuration, stacks = 1, max_stacks = self.baneMaxStacks }) 
	end

end

--------------------------------------------------------------------------------

modifier_phantom_ranger_black_arrow_bane = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_drow_ranger/phantom_ranger_black_arrow_bane.png"
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_TOOLTIP }
    end
})

LinkedModifiers["modifier_phantom_ranger_black_arrow_bane"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_phantom_ranger_black_arrow_bane:OnTooltip()
    return self:GetStackCount() * 10
end

--------------------------------------------------------------------------------
-- Black Arrow

phantom_ranger_black_arrow = class({
    GetAbilityTextureName = function(self)	
        return "phantom_ranger_black_arrow"
    end
})

--------------------------------------------------------------------------------

function phantom_ranger_black_arrow:OnSpellStart(pSource, pTarget)

	self.caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("black_arrow_duration")
	local phantomSpeed = self:GetSpecialValueFor("projectile_speed")
	local source
	local target
	if (pSource) then source = pSource else source = self.caster end
	if (pTarget) then target = pTarget else target = self:GetCursorTarget() end
	local projectile = {
        Target = target,
        Source = source,
        Ability = self,
        EffectName = "particles/units/heroes/hero_drow/drow_frost_arrow.vpcf",
        bDodgable = false,
        bProvidesVision = false,
        iMoveSpeed = phantomSpeed,
        ExtraData = { duration = duration }
    }
    ProjectileManager:CreateTrackingProjectile(projectile)
    source:EmitSound("Hero_DrowRanger.FrostArrows")
end

--------------------------------------------------------------------------------

function phantom_ranger_black_arrow:OnProjectileHit_ExtraData(target, location, ExtraData)

    if (target ~= nil) then
        GameMode:ApplyDebuff({ caster = self.caster, target = target, ability = self, modifier_name = "modifier_phantom_ranger_black_arrow_debuff", duration = ExtraData.duration})
        target:EmitSound("Hero_ShadowDemon.DemonicPurge.Impact")
    end
    return false

end

--------------------------------------------------------------------------------
-- Void Arrows

phantom_ranger_void_arrows = class({
    GetAbilityTextureName = function(self)
        return "phantom_ranger_void_arrows"
    end
})

LinkLuaModifier( "modifier_generic_orb_effect_lua", "generic/modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function phantom_ranger_void_arrows:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end

--------------------------------------------------------------------------------

function phantom_ranger_void_arrows:OnSpellStart()
end

--------------------------------------------------------------------------------

function phantom_ranger_void_arrows:GetProjectileName()
	return "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf"
end

--------------------------------------------------------------------------------

function phantom_ranger_void_arrows:GetManaCost(level)

	local manaCost = self.BaseClass.GetManaCost(self, level)
	if not IsServer() then return manaCost end
	local caster = self:GetCaster()
	local talent36Level = TalentTree:GetHeroTalentLevel(caster, 36)
	local talent36PercentManaIncreasePerLevel = 100 
	if (talent36Level > 0) then
		return manaCost * (100 + talent36Level * talent36PercentManaIncreasePerLevel) / 100
	else 
		return manaCost
	end
end

--------------------------------------------------------------------------------

function phantom_ranger_void_arrows:OnOrbImpact(params)

	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("void_arrows_damage")
	-- accounting for Power Addiction (talent 36) dmg increase
	local talent36Level = TalentTree:GetHeroTalentLevel(caster, 36)
	local talent36PercentDmgPerLevel = 100 / 3
	if params.target ~= nil then GameMode:DamageUnit({ caster = caster, target = params.target, damage = damage * (1 + talent36Level * talent36PercentDmgPerLevel / 100), voiddmg = true, ability = self }) end
	--local sound_cast = "Hero_ObsidianDestroyer.ArcaneOrb.Impact"
	--EmitSoundOn( sound_cast, params.target )
end

--------------------------------------------------------------------------------
-- Hunter's Focus Modifiers

modifier_phantom_ranger_hunters_focus_buff = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK }
    end
})

LinkedModifiers["modifier_phantom_ranger_hunters_focus_buff"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_phantom_ranger_hunters_focus_buff:OnCreated()

	if not IsServer() then return end
	self.caster = self:GetParent()
    self.bonusAttackSpeed = MAXIMUM_ATTACK_SPEED
    self.bonusAttackDamage = self:GetAbility():GetSpecialValueFor("attack_damage") / 100
    self.talent37Level = TalentTree:GetHeroTalentLevel(self.caster, 37)

end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_hunters_focus_buff:GetAttackSpeedBonus()
	return self.bonusAttackSpeed
end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_hunters_focus_buff:GetAttackDamagePercentBonus()
	return self.bonusAttackDamage
end

--------------------------------------------------------------------------------
-- Multishot (talent 37) logic 

function modifier_phantom_ranger_hunters_focus_buff:OnTakeDamage(damageTable)
	
	if not IsServer() then return end
	local drow = damageTable.attacker
	local talent37Level = TalentTree:GetHeroTalentLevel(drow, 37)
	if (drow:HasModifier("modifier_phantom_ranger_hunters_focus_buff") and talent37Level > 0 and not damageTable.fromsummon and damageTable.damage > 0) then 

		local talent37PercentDmgRegainedPerLevel = 0.1
		damageTable.damage = damageTable.damage * (0.45 + (talent37PercentDmgRegainedPerLevel * talent37Level))
		return damageTable

	end

end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_hunters_focus_buff:OnAttack(keys)

	if not IsServer() then return end
	if self.talent37Level == 0 then return end
	-- "Secondary arrows are not released upon attacking allies."
	-- The "not keys.no_attack_cooldown" clause seems to make sure the function doesn't trigger on PerformAttacks with that false tag so this thing doesn't crash
	local talent37ExtraTargetsPerLevel = 1
	local talent37Radius = 600
	local extraTargets = 1 + self.talent37Level * talent37ExtraTargetsPerLevel
	if (keys.attacker == self.caster and keys.target and keys.target:GetTeamNumber() ~= self.caster:GetTeamNumber() and not keys.no_attack_cooldown and not self.caster:PassivesDisabled()) then	

		local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), keys.target:GetAbsOrigin(), nil, talent37Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)
		local targetNumber = 0				
		for _, enemy in pairs(enemies) do		

			self.caster:PerformAttack(enemy, true, true, true, true, true, false, false)
			targetNumber = targetNumber + 1
			if targetNumber >= extraTargets then break end

		end

	end

end

--------------------------------------------------------------------------------
-- Hunter's Focus

phantom_ranger_hunters_focus = class({
    GetAbilityTextureName = function(self)	
        return "phantom_ranger_hunters_focus"
    end
})

function phantom_ranger_hunters_focus:OnSpellStart()

    if not IsServer() then return end
    local hunters_focus_duration = self:GetSpecialValueFor("duration")
    local caster = self:GetCaster()
    GameMode:ApplyBuff({ caster = caster, target = caster, ability = self, modifier_name = "modifier_phantom_ranger_hunters_focus_buff", duration = hunters_focus_duration })
    caster:EmitSound("Ability.Focusfire")

end

--------------------------------------------------------------------------------
-- Talent 36 - Power Addiction 

modifier_npc_dota_hero_drow_ranger_talent_36 = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH }
    end
})

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_36"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_36:OnCreated()

    if not IsServer() then return end
    self.caster = self:GetParent()

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_36:GetManaRestore()

	local talent36Level = TalentTree:GetHeroTalentLevel(self.caster, 36)
	local talent36PercentManaOnKillPerLevel = 5
	return 0.05 + (talent36Level * talent36PercentManaOnKillPerLevel / 100)

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_36:OnDeath(params)

	if not IsServer() then return end
	if (params.attacker ~= self.caster) then return end
	if (self.caster:GetTeamNumber() == params.unit:GetTeamNumber()) then return end
	if (params.unit:IsBuilding()) then return end
	GameMode:HealUnitMana({ caster = self.caster, target = self.caster, ability = self:GetAbility(), heal = self:GetManaRestore() * self.caster:GetMaxMana() }) 

end

--------------------------------------------------------------------------------
-- Talent 37 - Multishot 
-- logic is in modifier_phantom_ranger_hunters_focus_buff


--------------------------------------------------------------------------------
-- Talent 39 - Death's Embrace


modifier_npc_dota_hero_drow_ranger_talent_39 = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end
})

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_39"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_39:OnCreated()
    if not IsServer() then return end
    self.caster = self:GetParent()
end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_39:OnTakeDamage(damageTable)

	if not IsServer() then return end
	local drow = damageTable.attacker
	local target = damageTable.victim

	if (drow:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_39") and (target:HasModifier("modifier_phantom_ranger_shadow_waves_debuff") or target:HasModifier("modifier_phantom_ranger_black_arrow_debuff"))) then

		local talent39Level = TalentTree:GetHeroTalentLevel(drow, 39)
		local talent39DamagePerLevel = 5
		damageTable.damage = damageTable.damage * (105 + talent39Level * talent39DamagePerLevel) / 100
		
		return damageTable
	end

end

--------------------------------------------------------------------------------
-- Talent 40 - Frenetic


modifier_npc_dota_hero_drow_ranger_talent_40 = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end
})

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_40"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_40:OnCreated()
    if not IsServer() then return end
    self.caster = self:GetParent()
end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_40:OnAbilityFullyCast()
    if not IsServer() then return end
    local talent40Level = TalentTree:GetHeroTalentLevel(self.caster, 40)
    local talent40PercentHealPerLevel = 1
    GameMode:HealUnit({ caster = self.caster, target = self.caster, ability = nil, heal = self.caster:GetMaxHealth() * talent40Level * talent40PercentHealPerLevel / 100 })
end

--------------------------------------------------------------------------------
-- Talent 41 - Assassination
modifier_npc_dota_hero_drow_ranger_talent_41 = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_41"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_41:OnCreated()

    if not IsServer() then return end
    self.caster = self:GetParent()

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_41:OnAttackLanded(keys)

    if not IsServer() then return end
    if not (Enemies:IsElite(keys.target) or Enemies:IsBoss(keys.target)) then return end
    local talent41Level = TalentTree:GetHeroTalentLevel(self.caster, 41)
    local talent41CdrPerLevel = 0.05
    for i = 0, self.caster:GetAbilityCount() do

        local ability = self.caster:GetAbilityByIndex(i)
        if (ability) then

            local cooldownTable = {}
            cooldownTable.reduction = math.min(talent41Level * talent41CdrPerLevel, 0.5)
            cooldownTable.ability = ability:GetAbilityName()
            cooldownTable.isflat = true
            cooldownTable.target = self.caster
            GameMode:ReduceAbilityCooldown(cooldownTable)

        end

    end

end

--------------------------------------------------------------------------------
-- Talent 42 - Phantom Wail


modifier_phantom_ranger_phantom_wail_shield = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_drow_ranger/talent_42.png"
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_TOOLTIP }
    end
})

LinkedModifiers["modifier_phantom_ranger_phantom_wail_shield"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_phantom_ranger_phantom_wail_shield:OnTooltip()
    return self:GetStackCount()
end

--------------------------------------------------------------------------------

modifier_npc_dota_hero_drow_ranger_talent_42 = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
    	return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_42"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_42:OnTakeDamage(damageTable)

	local drow = damageTable.victim
	local shielded = drow:FindModifierByName("modifier_phantom_ranger_phantom_wail_shield")
    if (shielded) then

        local shieldAmount = shielded:GetStackCount()
        if (damageTable.damage >= shieldAmount) then

            damageTable.damage = damageTable.damage - shieldAmount
            shielded:Destroy()

        else

            shielded:SetStackCount(math.floor(shieldAmount - damageTable.damage))
            damageTable.damage = 0
        
        end

        return damageTable

    end

    local modifier = drow:FindModifierByName("modifier_npc_dota_hero_drow_ranger_talent_42")
    local coolingDown = drow:HasModifier("modifier_phantom_ranger_phantom_wail_cd")
    if (modifier ~= nil and not coolingDown and damageTable.damage > 0 ) then

       	local talent42Level = TalentTree:GetHeroTalentLevel(drow, 42)
        local remainingHealth = drow:GetHealth() - damageTable.damage
        if (remainingHealth < 1) then

           	local talent42CdrPerLevel = 30
           	local talent42PercentHpShieldPerLevel = 100
           	local talent42ShieldDuration = 5
           	local talent42PercentAdPerLevel = 100
           	local talent42Radius = 500
           	local talent42CCduration = 2

            drow:AddNewModifier(drow, nil, "modifier_phantom_ranger_phantom_wail_cd", { duration = 210 - (talent42Level * talent42CdrPerLevel) })
            local shield = drow:AddNewModifier(drow, nil, "modifier_phantom_ranger_phantom_wail_shield", { duration = talent42ShieldDuration })
            shield:SetStackCount(math.floor(drow:GetMaxHealth() * (1 + talent42Level * talent42PercentHpShieldPerLevel / 100)))	
  
            local enemies = FindUnitsInRadius(drow:GetTeamNumber(), drow:GetAbsOrigin(), nil, talent42Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
            for _, enemy in pairs(enemies) do

               	GameMode:DamageUnit({ caster = drow, target = enemy, ability = nil, damage = Units:GetAttackDamage(drow) * talent42Level * talent42PercentAdPerLevel / 100, voiddmg = true })
               	GameMode:ApplyDebuff({ caster = drow, target = enemy, ability = nil, modifier_name = "modifier_silence", duration = talent42CCduration })
               	GameMode:ApplyDebuff({ caster = drow, target = enemy, ability = nil, modifier_name = "modifier_disarmed", duration = talent42CCduration })
			
			end

            local pulse_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/pulse/void_spirit_pulse.vpcf", PATTACH_ABSORIGIN_FOLLOW, drow)
			ParticleManager:SetParticleControl(pulse_particle, 1, Vector(2400, 1, 0))
			ParticleManager:ReleaseParticleIndex(pulse_particle)
            drow:EmitSound("Hero_QueenOfPain.SonicWave")
            damageTable.damage = 0
            return damageTable

        end

    end

end

--------------------------------------------------------------------------------

modifier_phantom_ranger_phantom_wail_cd = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAbilityTextureName = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_drow_ranger/talent_42.png"
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH }
    end
})

LinkedModifiers["modifier_phantom_ranger_phantom_wail_cd"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_phantom_ranger_phantom_wail_cd:OnCreated()

    if not IsServer() then return end
    self.hero = self:GetParent()

end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_phantom_wail_cd:OnDeath(event)

    if self.hero ~= event.unit then return end
    self:Destroy()

end

--------------------------------------------------------------------------------
-- Talent 43 - Hunter's Guile 

modifier_npc_dota_hero_drow_ranger_talent_43 = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
    	return MODIFIER_ATTRIBUTE_PERMANENT 
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_43"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_43:OnCreated()

    if not IsServer() then return end
    self.caster = self:GetParent()

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_43:OnAttackLanded()

    if not IsServer() then return end
    local talent43Level = TalentTree:GetHeroTalentLevel(self.caster, 43)
    local talent43ChancePerLevel = 20 / 3
    local talent43StealthDuration = 1
    local stealthProc = RollPercentage(talent43Level * talent43ChancePerLevel)
    if (stealthProc and not self.caster:HasModifier("modifier_phantom_ranger_stealth")) then GameMode:ApplyBuff ({ caster = self.caster, target = self.caster, ability = nil, modifier_name = "modifier_phantom_ranger_stealth", duration = talent43StealthDuration }) end

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_43:OnTakeDamage(damageTable)

	if not IsServer() then return end
	local drow = damageTable.attacker
	if (drow:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_43")) then

		local talent43Level = TalentTree:GetHeroTalentLevel(drow, 43)
		if (drow:HasModifier("modifier_phantom_ranger_stealth") and not damageTable.fromsummon) then 

			local talent43CritDmgPerLevel = 25
			damageTable.crit = (125 + talent43CritDmgPerLevel * talent43Level) / 100
			return damageTable

		end

	end

end

--------------------------------------------------------------------------------
-- Talent 44 - Herald of the Void

modifier_npc_dota_hero_drow_ranger_talent_44 = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
    	return MODIFIER_ATTRIBUTE_PERMANENT 
    end
})

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_44"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_44:OnCreated()

    if not IsServer() then return end
    self.caster = self:GetParent()

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_44:GetVoidDamageBonus()
	
	local talent44Level = TalentTree:GetHeroTalentLevel(self.caster, 44)
	local talent44PercentDmgPerLevel = 0.03
	return math.min (((0.01 + talent44Level * talent44PercentDmgPerLevel) * Units:GetAttackSpeed(self.caster) / 100), 0.8)

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_44:GetCriticalDamageBonus()
	
	local talent44Level = TalentTree:GetHeroTalentLevel(self.caster, 44)
	local talent44PercentDmgPerLevel = 0.03
	local attackSpeed = Units:GetAttackSpeed(self.caster)
	if (attackSpeed > 800) then return (0.01 + talent44Level * talent44PercentDmgPerLevel) * (Units:GetAttackSpeed(self.caster) - 800) / 100 else return 0 end

end

--------------------------------------------------------------------------------
-- Talent 45 - Cloak of Shadows 
-- rest of logic is in hero_phantom_ranger.lua -> phantom_ranger_shadow_waves

modifier_npc_dota_hero_drow_ranger_talent_45 = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
    	return MODIFIER_ATTRIBUTE_PERMANENT 
    end
})

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_45"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_45:OnTakeDamage(damageTable)

	if not IsServer() then return end
	local drow = damageTable.victim
	if (drow:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_45") and damageTable.damage > 0) then

		local talent45Level = TalentTree:GetHeroTalentLevel(drow, 45)
		if (drow:HasModifier("modifier_phantom_ranger_stealth")) then 

			local talent45ReducedDmgTakenPerLevel = 10
			local reducedDmgTaken = (20 + talent45Level * talent45ReducedDmgTakenPerLevel) / 100
			if (TalentTree:GetHeroTalentLevel(drow, 51) > 0) then reducedDmgTaken = reducedDmgTaken / 5 end
			damageTable.damage = damageTable.damage * (1 - reducedDmgTaken)
			return damageTable

		end

	end

end

--------------------------------------------------------------------------------
-- Talent 48 - Deadly Vibration 
-- logic is in hero_phantom_ranger.lua -> modifier_phantom_ranger_phantom_harmonic(_stacks)

--------------------------------------------------------------------------------
-- Talent 49 - Master of the Cold Void 

modifier_npc_dota_hero_drow_ranger_talent_49 = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_49"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_49:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_49:GetFrostDamageBonus()
	local talent49Level = TalentTree:GetHeroTalentLevel(self.caster, 49)
	local talent49FrostDmgPerLevel = 10
    return 0.2 + (talent49Level * talent49FrostDmgPerLevel / 100)
end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_49:OnTakeDamage(damageTable)

    if (damageTable.attacker:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_49") and (damageTable.voiddmg or (damageTable.physdmg and damageTable.ability == nil))) then

        damageTable.frostdmg = true
        return damageTable

    end

end

--------------------------------------------------------------------------------
-- Talent 50 - Avatar of the Void 

modifier_npc_dota_hero_drow_ranger_talent_50 = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
    	return MODIFIER_ATTRIBUTE_PERMANENT 
    end
})

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_50"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_50:OnTakeDamage(damageTable)

	if not IsServer() then return end
	local drow = damageTable.attacker
	if (drow:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_50") and damageTable.voiddmg) then

		local target = damageTable.victim
		local targetVoidResist = 1 - Units:GetVoidProtection(target)
		local talent50Level = TalentTree:GetHeroTalentLevel(drow, 50)
		local talent50PenetrationPerLevel = 10
		local voidPenetration = 0 

		if (drow:HasModifier("modifier_phantom_ranger_stealth")) then
			voidPenetration = 1
		else
			voidPenetration = (55 + talent50Level * talent50PenetrationPerLevel) / 100
		end 

		local resistBeforePenetration = 0 
		local resistAfterPenetration = 0

		-- will be mixed resistance with Frost talent
		if (TalentTree:GetHeroTalentLevel(drow, 49) > 0) then

			local targetFrostResist = 1 - Units:GetFrostProtection(target)
			resistBeforePenetration = (targetVoidResist + targetFrostResist) / 2
			resistAfterPenetration = (targetVoidResist * (1 - voidPenetration) + targetFrostResist) / 2

		else 

			resistBeforePenetration = targetVoidResist
			resistAfterPenetration = targetVoidResist * (1 - voidPenetration)

		end

		damageTable.damage = damageTable.damage * (1 - resistAfterPenetration) / (1 - resistBeforePenetration)
		return damageTable

	end

end

--------------------------------------------------------------------------------
-- Talent 51 - Shadowcaster  
-- rest of logic is in hero_phantom_ranger.lua -> phantom_ranger_shadow_waves

modifier_npc_dota_hero_drow_ranger_talent_51 = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
    	return MODIFIER_ATTRIBUTE_PERMANENT 
    end
})

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_51"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_51:OnCreated()

	if not IsServer() then return end
	self.hero = self:GetParent()

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_51:GetSpellHasteBonus()
	
	return 1 - (100 / Units:GetAttackSpeed(self.hero))

end

--------------------------------------------------------------------------------
-- Phantom Ranger's generic Stealth modifier 

modifier_phantom_ranger_stealth = class({
	IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetPriority = function(self)
    	return MODIFIER_PRIORITY_SUPER_ULTRA
   	end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_drow_ranger/talent_43.png"
    end,
    DeclareFunctions = function(self)
    	return { MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS }
    end
})

LinkedModifiers["modifier_phantom_ranger_stealth"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_phantom_ranger_stealth:OnCreated()

	if not IsServer() then return end
	self.hero = self:GetParent()
	self.hero:MoveToTargetToAttack(self.hero:GetAggroTarget()) 

end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_stealth:CheckState()

	return {
		[MODIFIER_STATE_INVISIBLE]			= true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE]	= true
	}

end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_stealth:GetModifierInvisibilityLevel()
	return 1
end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_stealth:GetActivityTranslationModifiers()
	return "phantom_ranger_stealth"
end

--------------------------------------------------------------------------------
-- Internal stuff

for LinkedModifier, MotionController in pairs(LinkedModifiers) do LinkLuaModifier(LinkedModifier, "talents/talents_phantom_ranger", MotionController) end

function FindActivePhantoms(caster)
    local phantoms = Entities:FindAllByModel("models/heroes/drow/drow_base.vmdl")   
    Custom_ArrayRemove(phantoms, function(i, j)
        -- Remember that you want to return whatever STAYS in the array
        return phantoms[i] and phantoms[i]:IsAlive() and not phantoms[i]:IsHero() and phantoms[i]:GetOwner() == caster and phantoms[i]:HasModifier("modifier_phantom_ranger_phantom_of_vengeance_phantom")
    end)
    
    return phantoms
end

-- GameMode.PreDamageBeforeResistancesEventHandlersTable = {}
-- GameMode.PreDamageAfterResistancesEventHandlersTable = {}
-- GameMode.TALENTS_PHANTOM_RANGER_INIT = false
 

if (IsServer() and not GameMode.TALENTS_PHANTOM_RANGER_INIT) then

	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_phantom_ranger_hunters_focus_buff, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_39, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_42, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_43, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_45, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_49, 'OnTakeDamage'), true)
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_50, 'OnTakeDamage'))
	GameMode.TALENTS_PHANTOM_RANGER_INIT = true

end


