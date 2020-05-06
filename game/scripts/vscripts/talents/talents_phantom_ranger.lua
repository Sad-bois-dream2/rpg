local LinkedModifiers = {}


--------------------------------------------------------------------------------
-- Phantom Ranger Void Arrows

phantom_ranger_void_arrows = class({
    GetAbilityTextureName = function(self)
        return "dark_seer_surge"
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

function phantom_ranger_void_arrows:OnOrbFire(params)
	local caster = self:GetCaster()
	local manaCost = self:GetManaCost(self:GetLevel() - 1)
	-- accounting for Power Addiction (talent 36) mana increase
	local talent36Level = TalentTree:GetHeroTalentLevel(caster, 36)
	local talent36PercentManaIncreasePerLevel = 100
	if costIncrease ~= 0 then caster:SpendMana(manaCost * talent36Level * talent36PercentManaIncreasePerLevel / 100, self) end	
end

--------------------------------------------------------------------------------

function phantom_ranger_void_arrows:OnOrbImpact(params)
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("void_damage")
	-- accounting for Power Addiction (talent 36) dmg increase
	local talent36Level = TalentTree:GetHeroTalentLevel(caster, 36)
	local talent36PercentDmgPerLevel = 100 / 3
	if params.target ~= nil then GameMode:DamageUnit({ caster = caster, target = params.target, damage = damage * (1 + talent36Level * talent36PercentDmgPerLevel / 100), voiddmg = true, ability = self }) end
	--local sound_cast = "Hero_ObsidianDestroyer.ArcaneOrb.Impact"
	--EmitSoundOn( sound_cast, params.target )
end

--------------------------------------------------------------------------------
-- Hunter's Focus Modifiers

modifier_phantom_ranger_hunters_focus_buff = modifier_phantom_ranger_hunters_focus_buff or class({
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
    GetAbilityTextureName = function(self)
        return "phantom_ranger_hunters_focus"
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
-- Multishot (talent 37) talent logic 

function modifier_phantom_ranger_hunters_focus_buff:OnTakeDamage(damageTable)
	
	if not IsServer() then return end
	local drow = damageTable.attacker
	local talent37Level = TalentTree:GetHeroTalentLevel(drow, 37)
	if (drow:HasModifier("modifier_phantom_ranger_hunters_focus_buff") and talent37Level > 0 and damageTable.damage > 0) then 

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
    end,
})

function phantom_ranger_hunters_focus:OnSpellStart()
    if not IsServer() then return end
    local hunters_focus_duration = self:GetSpecialValueFor("duration")
    local caster = self:GetCaster()
    GameMode:ApplyBuff({ caster = caster, target = caster, ability = self, modifier_name = "modifier_phantom_ranger_hunters_focus_buff", duration = hunters_focus_duration })
    caster:EmitSound("Ability.Focusfire")
end

--------------------------------------------------------------------------------
-- Drow Ranger Talent 36 - Power Addiction 

modifier_npc_dota_hero_drow_ranger_talent_36 = modifier_npc_dota_hero_drow_ranger_talent_36 or class({
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
	return 0.05 + (0.05 * TalentTree:GetHeroTalentLevel(self.caster, 36))
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
-- Drow Ranger Talent 37 - Multishot 
-- logic is in modifier_phantom_ranger_hunters_focus_buff


--------------------------------------------------------------------------------
-- Drow Ranger Talent 42 - Phantom Wail


modifier_phantom_ranger_phantom_wail_shield = modifier_phantom_ranger_phantom_wail_shield or class({
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

modifier_npc_dota_hero_drow_ranger_talent_42 = modifier_npc_dota_hero_drow_ranger_talent_42 or class({
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

function modifier_npc_dota_hero_drow_ranger_talent_36:OnCreated()
    if not IsServer() then return end
end

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

modifier_phantom_ranger_phantom_wail_cd = modifier_phantom_ranger_phantom_wail_cd or class({
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

function modifier_npc_dota_hero_drow_ranger_talent_36:OnCreated()
    if not IsServer() then return end
end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_phantom_wail_cd:OnDeath(event)
    local hero = self:GetParent()
    if (hero ~= event.unit) then
        return
    end
    self:Destroy()
end

--------------------------------------------------------------------------------
-- Internal stuff

for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "talents/talents_phantom_ranger", MotionController)
end

if (IsServer() and not GameMode.TALENTS_PHANTOM_RANGER_INIT) then
    --GameMode.PreDamageEventHandlersTable = {}
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_phantom_ranger_hunters_focus_buff, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_42, 'OnTakeDamage'))
	GameMode.TALENTS_PHANTOM_RANGER_INIT = true
end


