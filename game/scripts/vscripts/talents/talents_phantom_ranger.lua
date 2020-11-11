local LinkedModifiers = {}

--------------------------------------------------------------------------------
-- Talent 34 - Phantom Lord (Rank 2 Void Disciple)

modifier_npc_dota_hero_drow_ranger_talent_34 = class({
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

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_34"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_34:OnCreated()

    if not IsServer() then return end
    self.caster = self:GetParent()
    -- Phantom Lord - talent 34 variables
    self.talent34_basePercentDmg = 0
    self.talent34_percentDmgPerLevel = 10

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_34:OnTakeDamage(damageTable)

    if not IsServer() then return end
    if not damageTable.fromsummon then return end
    local drow = damageTable.attacker
    local target = damageTable.victim
    local modifier = drow:FindModifierByName("modifier_npc_dota_hero_drow_ranger_talent_34")

    if (modifier) then

        local talent34_level = 3 --TalentTree:GetHeroTalentLevel(drow, 34)
        damageTable.damage = damageTable.damage * (100 + modifier.talent34_basePercentDmg + talent34_level * modifier.talent34_percentDmgPerLevel) / 100
        
        return damageTable
    end

end


--------------------------------------------------------------------------------
-- Talent 37 - Multishot (Rank 2 Hunter's Focus)
-- logic is in modifier_phantom_ranger_hunters_focus_buff


--------------------------------------------------------------------------------
-- Talent 38 - Sudden Vengeance (Rank 3 Phantom of Vengeance)

modifier_npc_dota_hero_drow_ranger_talent_38 = class({
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

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_38"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_38:OnCreated()
    if not IsServer() then return end
    self.caster = self:GetParent()
    -- Sudden Vengeance - talent 38 variables
    self.talent38_basePercentAd = 120
    self.talent38_percentAdPerLevel = 0
    self.talent38_radius = 300
end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_38:OnAbilityFullyCast(params)

    if not IsServer() then return end
    if not self.caster:HasAbility("phantom_ranger_phantom_of_vengeance") then return end
    if (params.ability and params.ability:GetCaster() == self.caster and params.ability:GetAbilityName() ~= "phantom_ranger_phantom_of_vengeance") then 

        local talent38_level = 0 --TalentTree:GetHeroTalentLevel(self.caster, 38)
        local activePhantoms = FindActivePhantoms(self.caster)
        if (activePhantoms) then

            for _, phantom in pairs(activePhantoms) do

                local emp_explosion_effect = ParticleManager:CreateParticle("particles/units/abyssal_stalker/void_dust/void_dust_explosion.vpcf",  PATTACH_ABSORIGIN, phantom)
                ParticleManager:SetParticleControl(emp_explosion_effect, 2, Vector(self.talent38_radius, 0, 0))
                ParticleManager:ReleaseParticleIndex(emp_explosion_effect)
                phantom:EmitSound("Hero_Invoker.EMP.Discharge")
                local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), phantom:GetAbsOrigin(), nil, self.talent38_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
                for _, enemy in pairs(enemies) do
                    GameMode:DamageUnit({ caster = self.caster, target = enemy, ability = params.ability, damage = Units:GetAttackDamage(self.caster) * (self.talent38_basePercentAd + talent38_level * self.talent38_percentAdPerLevel) / 100, voiddmg = true, fromsummon = true, aoe = true })
                end

            end

        end

    end

end

-- 

--------------------------------------------------------------------------------
-- Talent 41 - Assassination (Rank 4 Hunter's Focus)
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
    -- Assassination - talent 41 variables
    self.talent41_baseCdr = 0
    self.talent41_cdrPerLevel = 0.05
    self.talent41_cdrCap = 0.5

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_41:OnAttackLanded(params)

    if not IsServer() then return end
    if (params.attacker and params.target and not params.target:IsNull() and (Enemies:IsElite(params.target) or Enemies:IsBoss(params.target)) and params.attacker == self.caster) then

        local talent41_level = 3 --TalentTree:GetHeroTalentLevel(self.caster, 41)
        for i = 0, self.caster:GetAbilityCount()-1 do

            local ability = self.caster:GetAbilityByIndex(i)
            if (ability) then

                local cooldownTable = {}
                cooldownTable.reduction = math.min(self.talent41_baseCdr + talent41_level * self.talent41_cdrPerLevel, self.talent41_cdrCap)
                cooldownTable.ability = ability:GetAbilityName()
                cooldownTable.isflat = true
                cooldownTable.target = self.caster
                GameMode:ReduceAbilityCooldown(cooldownTable)

            end

        end

    end

end

--------------------------------------------------------------------------------
-- Talent 42 - Phantom Wail (Rank 2 Soul Echo)

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

function modifier_npc_dota_hero_drow_ranger_talent_42:OnCreated()

    if not IsServer() then return end
    -- Phantom Wail - talent 42 variables
    self.talent42_baseCd = 210
    self.talent42_cdrPerLevel = 30
    self.talent42_basePercentHpShield = 100
    self.talent42_percentHpShieldPerLevel = 100
    self.talent42_shieldDuration = 5
    self.talent42_basePercentAd = 0
    self.talent42_percentAdPerLevel = 100
    self.talent42_radius = 500
    self.talent42_ccDuration = 2

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

       	local talent42_level = 3 --TalentTree:GetHeroTalentLevel(drow, 42)
        local remainingHealth = drow:GetHealth() - damageTable.damage
        if (remainingHealth < 1) then

            drow:AddNewModifier(drow, nil, "modifier_phantom_ranger_phantom_wail_cd", { duration = modifier.talent42_baseCd - (talent42_level * modifier.talent42_cdrPerLevel) })
            local shield = drow:AddNewModifier(drow, nil, "modifier_phantom_ranger_phantom_wail_shield", { duration = modifier.talent42_shieldDuration })
            shield:SetStackCount(math.floor(drow:GetMaxHealth() * (modifier.talent42_basePercentHpShield + talent42_level * modifier.talent42_percentHpShieldPerLevel) / 100))	
  
            local enemies = FindUnitsInRadius(drow:GetTeamNumber(), drow:GetAbsOrigin(), nil, modifier.talent42_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
            for _, enemy in pairs(enemies) do

               	GameMode:DamageUnit({ caster = drow, target = enemy, ability = nil, damage = Units:GetAttackDamage(drow) * (modifier.talent42_basePercentAd + talent42_level * modifier.talent42_percentAdPerLevel) / 100, voiddmg = true, aoe = true })
               	-- local silence = GameMode:ApplyDebuff({ caster = drow, target = enemy, ability = nil, modifier_name = "modifier_silence", duration = modifier.talent42_ccDuration })
               	-- local disarm = GameMode:ApplyDebuff({ caster = drow, target = enemy, ability = nil, modifier_name = "modifier_disarmed", duration = modifier.talent42_ccDuration })
                -- silence.GetTexture = function () return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_drow_ranger/talent_42.png" end
                -- disarm.GetTexture = function () return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_drow_ranger/talent_42.png" end
                GameMode:ApplyDebuff({ caster = drow, target = enemy, ability = nil, modifier_name = "modifier_phantom_ranger_phantom_wail_cc", duration = modifier.talent42_ccDuration })
			
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

modifier_phantom_ranger_phantom_wail_cc = class({
    IsDebuff = function(self)
        return true
    end,
    IsStunDebuff = function(self)
        return true
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
        return { MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
    end,
    GetEffectName = function(self)
        return "particles/generic_gameplay/generic_stunned.vpcf"
    end,
    GetEffectAttachType = function(self)
        return PATTACH_OVERHEAD_FOLLOW
    end
})

LinkedModifiers["modifier_phantom_ranger_phantom_wail_cc"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_phantom_ranger_phantom_wail_cc:CheckState()

    return {
        [MODIFIER_STATE_STUNNED] = true
    }

end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_phantom_wail_cc:GetOverrideAnimation(params)
    return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------

-- Talent 43 - Hunter's Guile (Rank 3 Hunters Focus)

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
    -- Hunter's Guile - talent 43 variables
    self.talent43_baseChance = 0
    self.talent43_chancePerLevel = 20 / 3
    self.talent43_stealthDuration = 1
    self.talent43_cd = self.talent43_stealthDuration + 1.5
    self.talent43_baseCritDmg = 25
    self.talent43_critDmgPerLevel = 25

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_43:OnAttackLanded(params)

    if not IsServer() then return end
    if (params.attacker and params.target and not params.target:IsNull() and params.attacker == self.caster and not self.caster:HasModifier("modifier_phantom_ranger_hunters_guile_stealth_cd")) then 

        local talent43_level = 3 --TalentTree:GetHeroTalentLevel(self.caster, 43)
        local stealthProc = RollPercentage(self.talent43_baseChance + talent43_level * self.talent43_chancePerLevel)
        if not stealthProc then return end
        GameMode:ApplyBuff ({ caster = self.caster, target = self.caster, ability = nil, modifier_name = "modifier_phantom_ranger_stealth", duration = self.talent43_stealthDuration }) 
        self.caster:AddNewModifier(self.caster, nil, "modifier_phantom_ranger_hunters_guile_stealth_cd", { duration = self.talent43_cd })
    end

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_43:OnTakeDamage(damageTable)

	if not IsServer() then return end
	local drow = damageTable.attacker
    local modifier = drow:FindModifierByName("modifier_npc_dota_hero_drow_ranger_talent_43")
	if (modifier) then

		local talent43_level = 3 --TalentTree:GetHeroTalentLevel(drow, 43)
		if (drow:HasModifier("modifier_phantom_ranger_stealth") and not damageTable.fromsummon) then 

			damageTable.crit = (100 + modifier.talent43_baseCritDmg + modifier.talent43_critDmgPerLevel * talent43_level) / 100
			return damageTable

		end

	end

end

--------------------------------------------------------------------------------

modifier_phantom_ranger_hunters_guile_stealth_cd = class({
    IsDebuff = function(self)
        return true
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

LinkedModifiers["modifier_phantom_ranger_hunters_guile_stealth_cd"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------
-- Talent 44 - Herald of the Void (Rank 3 Shadow Wave)

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
    -- Herald of the Void - talent 44 variables
    self.talent44_basePercentDmgPerAS = 0.01
    self.talent44_percentDmgPerASPerLevel = 0.03
    self.talent44_basePercentCritDmgPerAS = 0.01
    self.talent44_percentCritDmgPerASPerLevel = 0.03
    self.talent44_voidDmgCap = MAXIMUM_ATTACK_SPEED * (self.talent44_basePercentDmgPerAS + 3 * self.talent44_percentDmgPerASPerLevel)

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_44:GetVoidDamageBonus()
	
	local talent44_level = 3 --TalentTree:GetHeroTalentLevel(self.caster, 44)
	return math.min(Units:GetAttackSpeed(self.caster) * (self.talent44_basePercentDmgPerAS + talent44_level * self.talent44_percentDmgPerASPerLevel) / 100, self.talent44_voidDmgCap / 100)

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_44:GetCriticalDamageBonus()
	
	local talent44_level = 3 --TalentTree:GetHeroTalentLevel(self.caster, 44)
	local talent44_percentDmgPerLevel = 0.03
	local attackSpeed = Units:GetAttackSpeed(self.caster)
	if (attackSpeed > MAXIMUM_ATTACK_SPEED) then return (Units:GetAttackSpeed(self.caster) - MAXIMUM_ATTACK_SPEED) * (self.talent44_basePercentCritDmgPerAS + talent44_level * self.talent44_percentCritDmgPerASPerLevel) / 100 else return 0 end

end

--------------------------------------------------------------------------------
-- Talent 45 - Cloak of Shadows (Rank 2 Shadow Wave)
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

function modifier_npc_dota_hero_drow_ranger_talent_45:OnCreated()

    if not IsServer() then return end
    self.caster = self:GetParent()
    -- Cloak of Shadows - talent 45 variables
    self.talent45_baseReducedDmgTaken = 20
    self.talent45_reducedDmgTakenPerLevel = 10
    self.talent45_baseStealthDuration = 0.75
    self.talent45_stealthDurationPerLevel = 0.75
    self.talent45_cd = 10

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_45:GetDamageReductionBonus()


		local talent45_level = 3 --TalentTree:GetHeroTalentLevel(self.caster, 45)
		if (self.caster:HasModifier("modifier_phantom_ranger_stealth")) then return (self.talent45_baseReducedDmgTaken + talent45_level * self.talent45_reducedDmgTakenPerLevel) / 100
        else return 0 
        end

end


--------------------------------------------------------------------------------
-- Talent 47 - Mirage (Rank 4 Soul Echo)

modifier_npc_dota_hero_drow_ranger_talent_47 = class({
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

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_47"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_47:OnCreated()

    if not IsServer() then return end
    self.caster = self:GetParent()
    -- Mirage - talent 47 variables
    self.talent47_duplicatableSpells = { "phantom_ranger_shadow_waves", "phantom_ranger_void_disciple", "phantom_ranger_phantom_arrow", "phantom_ranger_phantom_barrage", "phantom_ranger_phantom_of_vengeance", "phantom_ranger_black_arrow" }
    self.talent47_baseExtraDuration = 5
    self.talent47_extraDurationPerLevel = 0

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_47:OnAbilityFullyCast(params)

    if not IsServer() then return end
    if (params.ability and params.ability:GetCaster() == self.caster and TableContains(self.talent47_duplicatableSpells, params.ability:GetAbilityName())) then 

        local activePhantoms = FindActivePhantoms(self.caster, "modifier_phantom_ranger_soul_echo_phantom")
        if (activePhantoms) then

            local animation = params.ability:GetCastAnimation()
            local behavior = params.ability:GetBehavior()
            for _, phantom in pairs(activePhantoms) do

                if ( bit.band(behavior, bit.bor(DOTA_ABILITY_BEHAVIOR_POINT, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET)) ~= 0 ) then phantom:FaceTowards(params.ability:GetCursorPosition()) end    
                if animation then phantom:ForcePlayActivityOnce(animation) end            
                params.ability.OnSpellStart(params.ability, phantom)

            end

        end

    end

end

--------------------------------------------------------------------------------
-- Talent 48 - Deadly Vibration (Rank 3 + 4 Phantom Harmonic)
-- logic is in hero_phantom_ranger.lua -> modifier_phantom_ranger_phantom_harmonic(_stacks)

--------------------------------------------------------------------------------
-- Talent 49 - Master of the Cold Void (Rank 4 Void Disciple)

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

    if not IsServer() then return end
    self.caster = self:GetParent()
    -- Master of the Cold Void - talent 49 variables
    self.talent49_baseFrostDmg = 20
    self.talent49_frostDmgPerLevel = 0

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_49:GetFrostDamageBonus()
	local talent49_level = 0 --TalentTree:GetHeroTalentLevel(self.caster, 49)
    return (self.talent49_baseFrostDmg + talent49_level * self.talent49_frostDmgPerLevel) / 100
end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_49:OnTakeDamage(damageTable)

    if (damageTable.attacker:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_49") and (damageTable.voiddmg or (damageTable.physdmg and damageTable.ability == nil))) then

        damageTable.frostdmg = true
        return damageTable

    end

end

--------------------------------------------------------------------------------
-- Talent 50 - Avatar of the Void (Rank 4 Phantom of Vengeance)

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

function modifier_npc_dota_hero_drow_ranger_talent_50:OnCreated()

    if not IsServer() then return end
    -- Avatar of the Void - talent 50 variables
    self.talent50_basePenetration = 50
    self.talent50_penetrationPerLevel = 0

end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_50:OnTakeDamage(damageTable)

	if not IsServer() then return end
    if not damageTable.voiddmg then return end
	local drow = damageTable.attacker
    local modifier = drow:FindModifierByName("modifier_npc_dota_hero_drow_ranger_talent_50")
	if (modifier) then

		local target = damageTable.victim
		local targetVoidResist = 1 - Units:GetVoidProtection(target)
		local talent50_level = 0 --TalentTree:GetHeroTalentLevel(drow, 50)
		local voidPenetration = 0 

		if (drow:HasModifier("modifier_phantom_ranger_stealth")) then
			voidPenetration = 1
		else
			voidPenetration = (modifier.talent50_basePenetration + talent50_level * modifier.talent50_penetrationPerLevel) / 100
		end 

		local resistBeforePenetration = 0 
		local resistAfterPenetration = 0

		-- will be mixed resistance with Frost talent
		--if (TalentTree:GetHeroTalentLevel(drow, 49) > 0) then
        if (drow:FindAbilityByName("phantom_ranger_void_disciple").level >= 4) then

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
-- Talent 51 - Shadowcaster (Rank 4 Shadow Wave)
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
    return Units:GetAttackSpeed(self.hero)
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

function FindActivePhantoms(caster, filterModifier)
    local phantoms = Entities:FindAllByModel("models/heroes/drow/drow_base.vmdl")
    filterModifier = filterModifier or "modifier_phantom_ranger_phantom_of_vengeance_phantom"
    Custom_ArrayRemove(phantoms, function(i, j)
        -- Remember that you want to return whatever STAYS in the array
        return phantoms[i] and phantoms[i]:IsAlive() and not phantoms[i]:IsHero() and phantoms[i]:GetOwner() == caster and phantoms[i]:HasModifier(filterModifier)
    end)
    
    return phantoms
end

function CreatePhantomAtPoint(point, ability, phantomModifier, phantomSpeed, phantomDuration)

    if not (point and ability and phantomModifier) then return nil end
    local phantom = CreateUnitByName("npc_dota_phantom_ranger_phantom", point, true, ability.caster, ability.caster, ability.caster:GetTeamNumber())
    phantomSpeed = phantomSpeed or phantom:GetBaseMoveSpeed() 
    phantomDuration = phantomDuration or 0
    local modifierTable = {}
    modifierTable.ability = ability
    modifierTable.target = phantom
    modifierTable.caster = phantom
    modifierTable.modifier_name = phantomModifier
    modifierTable.duration = -1
    modifierTable.modifier_params = { phantomSpeed = phantomSpeed }
    local phantomModifier = GameMode:ApplyBuff(modifierTable)
    phantom:SetOwner(ability.caster)
    local modifierTable = {}
    modifierTable.ability = ability
    modifierTable.target = phantom
    modifierTable.caster = phantom
    modifierTable.modifier_name = "modifier_phantom_ranger_soul_echo_phantom_status_effect"
    modifierTable.duration = -1
    GameMode:ApplyBuff(modifierTable)
    local wearables = GetWearables(ability.caster)
    AddWearables(phantom, wearables)
    ForEachWearable(phantom, function(wearable)
        local modifierTable = {}
        modifierTable.ability = ability
        modifierTable.target = wearable
        modifierTable.caster = phantom
        modifierTable.modifier_name = "modifier_phantom_ranger_soul_echo_phantom_status_effect"
        modifierTable.duration = -1
        GameMode:ApplyBuff(modifierTable)
    end)
    local phantomIndex = phantom:entindex()
    -- if (ability:GetAbilityName() == "phantom_ranger_phantom_arrow" and ability.caster:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_46")) then 

    --     table.insert(ability.caster.phantom_arrow_table, phantomIndex) 
    --     Timers:CreateTimer(phantomDuration, function()

    --         Custom_ArrayRemove(ability.caster.phantom_arrow_table, function(i,j)
    --             return ability.caster.phantom_arrow_table[i] ~= phantomIndex 
    --         end)
    --         DestroyPhantom(phantom)

    --     end)

    -- else

        Timers:CreateTimer(phantomDuration, function()
            DestroyPhantom(phantom)
            phantomModifier:Destroy()
        end)

    -- end

    return phantom

end


function DestroyPhantom(phantom)
    if (phantom and not phantom:IsNull() and phantom:IsAlive()) then
        DestroyWearables(phantom, function()
            phantom:Destroy()
        end)
    end
end

if (IsServer() and not GameMode.TALENTS_PHANTOM_RANGER_INIT) then

    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_34, 'OnTakeDamage'))
	--GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_39, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_42, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_43, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_49, 'OnTakeDamage'), true)
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_drow_ranger_talent_50, 'OnTakeDamage'))
	GameMode.TALENTS_PHANTOM_RANGER_INIT = true

end

--------------------------------------------------------------------------------
-- -- Phantom Barrage modifiers

-- modifier_phantom_ranger_phantom_barrage_charges = class({
--     IsDebuff = function(self)
--         return false
--     end,
--     IsHidden = function(self)
--         return false
--     end,
--     IsPurgable = function(self)
--         return false
--     end,
--     RemoveOnDeath = function(self)
--         return false
--     end,
--     AllowIllusionDuplicate = function(self)
--         return false
--     end,
--     DestroyOnExpire = function(self)
--         return false
--     end,
--     DeclareFunctions = function(self)
--         return { MODIFIER_PROPERTY_TOOLTIP }
--     end
-- })

-- LinkedModifiers["modifier_phantom_ranger_phantom_barrage_charges"] = LUA_MODIFIER_MOTION_NONE

-- --------------------------------------------------------------------------------

-- function modifier_phantom_ranger_phantom_barrage_charges:OnTooltip()
--     return self:GetStackCount()
-- end

-- --------------------------------------------------------------------------------

-- function modifier_phantom_ranger_phantom_barrage_charges:OnCreated()

--     if not IsServer() then return end
--     self.ability = self:GetAbility()
--     self.thinkIntervalChanged = false
--     self:SetStackCount(0)

-- end

-- --------------------------------------------------------------------------------

-- function modifier_phantom_ranger_phantom_barrage_charges:OnIntervalThink()

--     self:IncrementStackCount()
--     if self:GetStackCount() < self.ability.maxCharges then
    
--         self:SetDuration(self.ability.chargeCd, true)
--         if (self.thinkInterval ~= self.ability.chargeCd) then 

--             self.thinkIntervalChanged = false
--             self:StartIntervalThink(self.ability.chargeCd) 

--         end

--     else

--         self:SetDuration(-1, true)
--         self:StartIntervalThink(-1)

--     end


-- end

-- --------------------------------------------------------------------------------
-- -- Phantom Barrage

-- phantom_ranger_phantom_barrage = class({
--     GetAbilityTextureName = function(self)  
--         return "phantom_ranger_phantom_barrage"
--     end
-- })


-- --------------------------------------------------------------------------------

-- function phantom_ranger_phantom_barrage:GetIntrinsicModifierName()
--     return "modifier_phantom_ranger_phantom_barrage_charges"
-- end

-- --------------------------------------------------------------------------------

-- function phantom_ranger_phantom_barrage:OnUpgrade()

--     if not IsServer() then return end
--     self.caster = self:GetCaster()
--     self.level = self:GetLevel()
--     self.damage = self:GetSpecialValueFor("damage")
--     self.radius = self:GetSpecialValueFor("radius")
--     self.chargeCd = self:GetSpecialValueFor("charge_restore_time")
--     self.maxCharges = self:GetSpecialValueFor("max_charges")
--     self.projectileSpeed = self:GetSpecialValueFor("projectile_speed")
--     -- Endless Munitions - talent 35 variables
--     self.talent35_baseCdr = 1.0
--     self.talent35_cdrPerLevel = 0.0

--     local modifier = self.caster:FindModifierByName("modifier_phantom_ranger_phantom_barrage_charges")

--     if (modifier and (modifier:GetDuration() == -1) and (modifier:GetStackCount() < self.maxCharges)) then

--         modifier:SetDuration(self.chargeCd, true)
--         modifier:StartIntervalThink(self.chargeCd)

--     end

--     if (self.level >= 2 and not self.caster:HasModifier("modifier_npc_dota_hero_drow_ranger_talent_40")) then GameMode:ApplyBuff({ caster = self.caster, target = self.caster, ability = self, modifier_name = "modifier_npc_dota_hero_drow_ranger_talent_40", duration = -1 }) end

-- end

-- --------------------------------------------------------------------------------

-- function phantom_ranger_phantom_barrage:OnSpellStart(source)

--     source = source or self.caster
--     local fromPhantom = (source ~= self.caster)

--     local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), source:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
--     if (#enemies > 0) then

--         local target 
--         local closestNormalEnemy
--         for i = 1, #enemies do

--             if (Enemies:IsBoss(enemies[i]) or Enemies:IsElite(enemies[i])) then 

--                 target = enemies[i]
--                 break

--             else

--                 closestNormalEnemy = closestNormalEnemy or enemies[i]

--             end

--         end

--         target = target or closestNormalEnemy
--         local projectile = {
--             Target = target,
--             Source = source,
--             Ability = self,
--             EffectName = "particles/units/heroes/hero_bane/bane_projectile.vpcf",
--             bDodgeable = false,
--             bProvidesVision = false,
--             iMoveSpeed = self.projectileSpeed,
--             ExtraData = { fromsummon = fromPhantom }
--         }
--         ProjectileManager:CreateTrackingProjectile(projectile)
--         source:EmitSound("Hero_Bane.Attack")

--     end

--     local charges = self.caster:FindModifierByName("modifier_phantom_ranger_phantom_barrage_charges")
--     if (charges) then
--         -- Start by ending cooldown before checking for remaining charges
--         self:EndCooldown()
--         -- If charges are at max, start the modifier countdown
--         local chargeCount = charges:GetStackCount()
--         if (chargeCount == self.maxCharges) then

--             charges:SetDuration(self.chargeCd, true)
--             charges:StartIntervalThink(self.chargeCd)

--         -- If only one charge left, start the cooldown equivalent to remaining modifier time
--         elseif chargeCount <= 1 then

--              self:StartCooldown(charges:GetRemainingTime())

--         end

--     end            
--     -- Consume a charge
--     charges:DecrementStackCount()

-- end

-- --------------------------------------------------------------------------------

-- function phantom_ranger_phantom_barrage:OnProjectileHit_ExtraData(target, location, ExtraData)

--     if (target and not target:IsNull()) then

--         GameMode:DamageUnit({ caster = self.caster, target = target, ability = self, damage = Units:GetAttackDamage(self.caster) * self.damage / 100, voiddmg = true, fromsummon = ExtraData.fromsummon })
--         target:EmitSound("Hero_Bane.ProjectileImpact")
--         if (self.level >= 3) then    

--             for i = 0, self.caster:GetAbilityCount() do

--                 local ability = self.caster:GetAbilityByIndex(i)
--                 if (ability) then

--                     local cooldownTable = {}
--                     cooldownTable.reduction = 0.5
--                     cooldownTable.ability = ability:GetAbilityName()
--                     cooldownTable.isflat = true
--                     cooldownTable.target = self.caster
--                     GameMode:ReduceAbilityCooldown(cooldownTable)
    
--                end

--             end

--         end

--         local talent35_level = 0 --TalentTree:GetHeroTalentLevel(self.caster, 35)
--         if (self.level >= 4 and (Enemies:IsBoss(target) or Enemies:IsElite(target))) then 
            
--             local reduction = self.talent35_baseCdr + talent35_level * self.talent35_cdrPerLevel
--             self:ReduceChargeCooldown(reduction)

--         end

--     end

--     return false

-- end

-- --------------------------------------------------------------------------------

-- function phantom_ranger_phantom_barrage:ReduceChargeCooldown(reduction)

--     if (reduction and reduction > 0) then

--         local charges = self.caster:FindModifierByName("modifier_phantom_ranger_phantom_barrage_charges")
--         local remainingTime = charges:GetRemainingTime()
--         if (self:IsCooldownReady()) then

--             if (remainingTime > reduction) then

--                 local resultCd = remainingTime - reduction
--                 charges:StartIntervalThink(resultCd)
--                 charges:SetDuration(resultCd, true)
--                 charges.thinkIntervalChanged = true                

--             else

--                 charges:OnIntervalThink()

--             end

--         else 

--             if (remainingTime > reduction) then 

--                 local resultCd = remainingTime - reduction
--                 GameMode:ReduceAbilityCooldown({ reduction = reduction, ability = "phantom_ranger_phantom_barrage", isflat = true, target = self.caster })
--                 charges:StartIntervalThink(resultCd)
--                 charges:SetDuration(resultCd, true)
--                 charges.thinkIntervalChanged = true

--             else

--                 self:EndCooldown()
--                 charges:OnIntervalThink()

--             end

--         end

--     end

-- end

--------------------------------------------------------------------------------
-- -- Black Arrow modifiers 

-- modifier_phantom_ranger_black_arrow_debuff = class({
--     IsDebuff = function(self)
--         return true
--     end,
--     IsHidden = function(self)
--         return false
--     end,
--     IsPurgable = function(self)
--         return false
--     end,
--     RemoveOnDeath = function(self)
--         return false
--     end,
--     AllowIllusionDuplicate = function(self)
--         return false
--     end,
--     GetAbilityTextureName = function(self)
--         return "phantom_ranger_black_arrow"
--     end,
--      GetAttributes = function(self)
--         return MODIFIER_ATTRIBUTE_MULTIPLE
--     end,
--     DeclareFunctions = function(self)
--         return { MODIFIER_EVENT_ON_ATTACKED }
--     end
-- })

-- LinkedModifiers["modifier_phantom_ranger_black_arrow_debuff"] = LUA_MODIFIER_MOTION_NONE

-- --------------------------------------------------------------------------------

-- function modifier_phantom_ranger_black_arrow_debuff:OnCreated(params)

--     if not IsServer() then return end
--     self.caster = self:GetCaster()
--     self.target = self:GetParent()
--     self.ability = self:GetAbility()
--     self.fromsummon = params.fromsummon
--     self.damage = self.ability:GetSpecialValueFor("black_arrow_damage")
--     self.baneDamage = self.ability:GetSpecialValueFor("bane_damage")
--     self.baneDuration = self.ability:GetSpecialValueFor("bane_duration")
--     self.baneMaxStacks = self.ability:GetSpecialValueFor("bane_max_stacks")
--     local tickRate = self.ability:GetSpecialValueFor("tick_rate")
--     self:StartIntervalThink (tickRate)

-- end

-- --------------------------------------------------------------------------------

-- function modifier_phantom_ranger_black_arrow_debuff:OnIntervalThink()

--     if not IsServer() then return end
--     local hasBane = self.target:FindModifierByName("modifier_phantom_ranger_black_arrow_bane")
--     local finalDamage = Units:GetAttackDamage(self.caster) * self.damage / 100
--     if (hasBane) then

--         local baneStacks = hasBane:GetStackCount()
--         finalDamage = finalDamage * (1 + baneStacks * self.baneDamage / 100)

--     end
--     GameMode:DamageUnit({ caster = self.caster, target = self.target, ability = self.ability, damage = finalDamage, voiddmg = true, fromsummon = self.fromsummon })

-- end

-- --------------------------------------------------------------------------------

-- function modifier_phantom_ranger_black_arrow_debuff:OnAttacked(params)

--     if not IsServer() then return end
--     if (params.attacker and params.target and not params.target:IsNull() and params.attacker == self.caster and params.target == self.target and self.ability.level >= 2) then

--         GameMode:ApplyStackingDebuff({ caster = self.caster, target = self.target, ability = self.ability, modifier_name = "modifier_phantom_ranger_black_arrow_bane", duration = self.baneDuration, stacks = 1, max_stacks = self.baneMaxStacks }) 

--     end

-- end

-- --------------------------------------------------------------------------------

-- modifier_phantom_ranger_black_arrow_bane = class({
--     IsDebuff = function(self)
--         return true
--     end,
--     IsHidden = function(self)
--         return false
--     end,
--     IsPurgable = function(self)
--         return false
--     end,
--     RemoveOnDeath = function(self)
--         return false
--     end,
--     AllowIllusionDuplicate = function(self)
--         return false
--     end,
--     GetTexture = function(self)
--         return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_drow_ranger/phantom_ranger_black_arrow_bane.png"
--     end,
--     DeclareFunctions = function(self)
--         return { MODIFIER_PROPERTY_TOOLTIP }
--     end
-- })

-- LinkedModifiers["modifier_phantom_ranger_black_arrow_bane"] = LUA_MODIFIER_MOTION_NONE

-- --------------------------------------------------------------------------------

-- function modifier_phantom_ranger_black_arrow_bane:OnTooltip()
--     return self:GetStackCount() * 10
-- end

-- --------------------------------------------------------------------------------
-- -- Black Arrow

-- phantom_ranger_black_arrow = class({
--     GetAbilityTextureName = function(self)  
--         return "phantom_ranger_black_arrow"
--     end,
--     GetCastAnimation = function(self)
--         return ACT_DOTA_ATTACK
--     end
-- })

-- --------------------------------------------------------------------------------

-- function phantom_ranger_black_arrow:OnUpgrade()

--     self.caster = self:GetCaster()
--     self.level = self:GeLevel()

-- end

-- --------------------------------------------------------------------------------

-- function phantom_ranger_black_arrow:OnSpellStart(source, target)

--     local duration = self:GetSpecialValueFor("black_arrow_duration")
--     local phantomSpeed = self:GetSpecialValueFor("projectile_speed")
--     source = source or self.caster
--     target = target or self:GetCursorTarget()
--     local fromPhantom = (source ~= self.caster)
--     local projectile = {
--         Target = target,
--         Source = source,
--         Ability = self,
--         EffectName = "particles/units/phantom_ranger/phantom_ranger_black_arrow.vpcf",
--         bDodgeable = false,
--         bProvidesVision = false,
--         iMoveSpeed = phantomSpeed,
--         ExtraData = { duration = duration, fromsummon = fromPhantom }
--     }
--     ProjectileManager:CreateTrackingProjectile(projectile)
--     source:EmitSound("Hero_DrowRanger.FrostArrows")

-- end

-- --------------------------------------------------------------------------------

-- function phantom_ranger_black_arrow:OnProjectileHit_ExtraData(target, location, ExtraData)

--     if (target ~= nil) then

--         modifier = GameMode:ApplyDebuff({ caster = self.caster, target = target, ability = self, modifier_name = "modifier_phantom_ranger_black_arrow_debuff", duration = ExtraData.duration, modifier_params = { fromsummon = ExtraData.fromsummon } })
--         target:EmitSound("Hero_ShadowDemon.DemonicPurge.Impact")

--     end
--     return false

-- end


-- --------------------------------------------------------------------------------
-- -- Phantom Arrow Modifiers

-- modifier_phantom_ranger_phantom_arrow_phantom = class({
--     IsDebuff = function(self)
--         return false
--     end,
--     IsHidden = function(self)
--         return true
--     end,
--     IsPurgable = function(self)
--         return false
--     end,
--     RemoveOnDeath = function(self)
--         return true
--     end,
--     AllowIllusionDuplicate = function(self)
--         return false
--     end,
--     -- GetEffectName = function(self)
--     --     return "particles/units/phantom_ranger/test/soul_echo/soul_echo_phantom.vpcf"
--     -- end,
--     -- GetEffectAttachType = function(self)
--     --     return PATTACH_ABSORIGIN_FOLLOW
--     -- end,
--     GetStatusEffectName = function(self)
--         return "particles/status_fx/status_effect_terrorblade_reflection.vpcf"
--     end,
--     StatusEffectPriority = function(self)
--         return 15
--     end,
--     CheckState = function(self)
--         return
--         {
--             [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
--             [MODIFIER_STATE_INVULNERABLE] = true,
--             [MODIFIER_STATE_NO_HEALTH_BAR] = true,
--             [MODIFIER_STATE_MAGIC_IMMUNE] = true,
--             [MODIFIER_STATE_UNSELECTABLE] = true,
--             [MODIFIER_STATE_NOT_ON_MINIMAP] = true
--         }
--     end,
--     DeclareFunctions = function(self)
--         return { MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN, MODIFIER_EVENT_ON_ATTACK_LANDED }
--     end
-- })

-- LinkedModifiers["modifier_phantom_ranger_phantom_arrow_phantom"] = LUA_MODIFIER_MOTION_NONE

-- --------------------------------------------------------------------------------

-- function modifier_phantom_ranger_phantom_arrow_phantom:OnCreated(params)

--     if not IsServer() then return end
--     self.phantom = self:GetParent()
--     self.hero = self.phantom:GetOwner()
--     self.ability = self:GetAbility()
--     self.phantomSpeed = params.phantomSpeed
--     --self.target = self.ability:GetCursorTarget()
--     --self:StartIntervalThink(0.5)

-- end

-- --------------------------------------------------------------------------------

-- -- function modifier_phantom_ranger_phantom_arrow_phantom:OnIntervalThink()

-- --     if not (self.target and (not self.target:IsNull()) and self.target:IsAlive()) then

-- --         if (TalentTree:GetHeroTalentLevel(self.hero, 46) > 0) then

-- --         Custom_ArrayRemove(self.hero.phantom_arrow_table, function(i,j)
-- --             return self.hero.phantom_arrow_table[i] ~= self.phantom:entindex() 
-- --         end)

-- --         end

-- --         DestroyPhantom(self.phantom) 

-- --     end

-- -- end

-- --------------------------------------------------------------------------------

-- function modifier_phantom_ranger_phantom_arrow_phantom:GetModifierMoveSpeed_AbsoluteMin()
--     return self.phantomSpeed
-- end

-- --------------------------------------------------------------------------------

-- function modifier_phantom_ranger_phantom_arrow_phantom:GetAttackSpeedBonus()
--     return Units:GetAttackSpeed(self.hero) * self.ability.phantomPercentAS / 100
-- end

-- --------------------------------------------------------------------------------

-- function modifier_phantom_ranger_phantom_arrow_phantom:OnAttackLanded(params)
--     if not IsServer() then return end
--     local phantom = params.attacker
--     local target = params.target
--     if (phantom ~= nil and not phantom:IsNull() and target ~= nil and phantom ~= target and phantom == self.phantom and phantom:IsAlive()) then

--         local damage = Units:GetAttackDamage(self.hero) * self.ability.phantomPercentDamage / 100
--         GameMode:DamageUnit({ caster = self.hero, target = target, damage = damage, physdmg = true, fromsummon = true })
           
--     end

-- end

-- --------------------------------------------------------------------------------
-- -- Phantom Arrow

-- phantom_ranger_phantom_arrow = class({
--     GetAbilityTextureName = function(self)  
--         return "phantom_ranger_phantom_arrow"
--     end,
--     GetCastAnimation = function(self)
--         return ACT_DOTA_ATTACK
--     end
-- })

-- --------------------------------------------------------------------------------

-- function phantom_ranger_phantom_arrow:OnUpgrade()

--     if not IsServer() then return end
--     self.caster = self:GetCaster()
--     self.phantomMS = 550
--     -- self.arrowDamage = self:GetSpecialValueFor("arrow_damage")
--     -- self.phantomDuration = self:GetSpecialValueFor("phantom_duration")
--     -- self.phantomPercentDamage = self:GetSpecialValueFor("phantom_damage")
--     -- self.phantomPercentAS = self:GetSpecialValueFor("phantom_attack_speed")
--     --self.projectileSpeed = self:GetSpecialValueFor("projectile_speed")

-- end

-- --------------------------------------------------------------------------------

-- function phantom_ranger_phantom_arrow:OnSpellStart(source, target, level, isAutomatic)

--     level = level or self:GetLevel()
--     if (not level or level < 1 or level > 4) then return end
--     self.arrowDamage = self:GetLevelSpecialValueFor("arrow_damage", level - 1)
--     self.phantomDuration = self:GetLevelSpecialValueFor("phantom_duration", level - 1)
--     self.phantomPercentDamage = self:GetLevelSpecialValueFor("phantom_damage", level - 1)
--     self.phantomPercentAS = self:GetLevelSpecialValueFor("phantom_attack_speed", level -1)
--     self.projectileSpeed = self:GetLevelSpecialValueFor("projectile_speed", level - 1)

--     if not self.caster then self:OnUpgrade() end
--     source = source or self.caster
--     target = target or self:GetCursorTarget()
--     self.isAutomatic = isAutomatic or false
--     self.caster.phantom_arrow_table = self.caster.phantom_arrow_table or {}
--     local fromPhantom = (source ~= self.caster)
--     local projectile = {
--         Target = target,
--         Source = source,
--         Ability = self,
--         EffectName = "particles/units/phantom_ranger/phantom_ranger_black_arrow.vpcf",
--         bDodgeable = false,
--         bProvidesVision = false,
--         iMoveSpeed = self.projectileSpeed,
--         ExtraData = { fromsummon = fromPhantom }
--     }
--     ProjectileManager:CreateTrackingProjectile(projectile)
--     source:EmitSound("Hero_DrowRanger.FrostArrows")

-- end

-- --------------------------------------------------------------------------------

-- function phantom_ranger_phantom_arrow:OnProjectileHit_ExtraData(target, location, ExtraData)

--     if (target ~= nil) then

--         GameMode:DamageUnit({ caster = self.caster, target = target, ability = self, damage = Units:GetAttackDamage(self.caster) * self.arrowDamage / 100, voiddmg = true, fromsummon = ExtraData.fromsummon })
--         target:EmitSound("Hero_ShadowDemon.DemonicPurge.Impact")
--         local modifier = self.caster:FindModifierByName("modifier_npc_dota_hero_drow_ranger_talent_46")
--         local talent46_level = TalentTree:GetHeroTalentLevel(self.caster, 46)
--         if (modifier and self.isAutomatic == true and #(self.caster.phantom_arrow_table) >= modifier.talent46_basePhantomLimit + talent46_level * modifier.talent46_phantomLimitIncreasePerLevel) then return false end
--         local spawnLocation = location + RandomVector(208)
--         local phantom = CreatePhantomAtPoint(spawnLocation, self, "modifier_phantom_ranger_phantom_arrow_phantom", self.phantomMS, self.phantomDuration)
--         Timers:CreateTimer(0.05, function()
--             phantom:MoveToTargetToAttack(target)
--         end, self)

--     end
--     return false

-- end

-- --------------------------------------------------------------------------------
-- -- Void Arrows

-- phantom_ranger_void_arrows = class({
--     GetAbilityTextureName = function(self)
--         return "phantom_ranger_void_arrows"
--     end
-- })

-- LinkLuaModifier( "modifier_generic_orb_effect_lua", "generic/modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )

-- --------------------------------------------------------------------------------

-- function phantom_ranger_void_arrows:OnUpgrade()

--     if not IsServer() then return end
--     self.caster = self:GetCaster()
--     self.baseDamage = self:GetSpecialValueFor("base_damage")
--     self.percentAdScaling = self:GetSpecialValueFor("ad_scaling")

-- end

-- --------------------------------------------------------------------------------

-- function phantom_ranger_void_arrows:GetIntrinsicModifierName()
--     return "modifier_generic_orb_effect_lua"
-- end

-- --------------------------------------------------------------------------------

-- function phantom_ranger_void_arrows:GetProjectileName()
--     return "particles/units/phantom_ranger/phantom_ranger_black_arrow.vpcf"
-- end

-- --------------------------------------------------------------------------------

-- function phantom_ranger_void_arrows:GetManaCost(level)

--     local manaCost = self.BaseClass.GetManaCost(self, level)
--     if not IsServer() then return manaCost end
--     if (not self.caster) then self.caster = self:GetCaster() end

--     self.talent36_level = TalentTree:GetHeroTalentLevel(self.caster, 36)
--     if (self.talent36_level > 0) then

--         local talent36_percentManaIncreasePerLevel = 100 
--         return manaCost * (100 + self.talent36_level * talent36_percentManaIncreasePerLevel) / 100

--     else 

--         return manaCost

--     end

-- end

-- --------------------------------------------------------------------------------

-- function phantom_ranger_void_arrows:OnOrbImpact(params)

--     -- Power Addiction (talent 36) dmg increase
--     local talent36_percentDmgPerLevel = 100 / 3
--     if params.target ~= nil then GameMode:DamageUnit({ caster = self.caster, target = params.target, damage = (self.baseDamage + Units:GetAttackDamage(self.caster) * self.percentAdScaling / 100) * (1 + self.talent36_level * talent36_percentDmgPerLevel / 100), voiddmg = true, ability = self }) end
--     --local sound_cast = "Hero_ObsidianDestroyer.ArcaneOrb.Impact"
--     --EmitSoundOn( sound_cast, params.target )
-- end


-- --------------------------------------------------------------------------------
-- -- Talent 36 - Power Addiction 

-- modifier_npc_dota_hero_drow_ranger_talent_36 = class({
--     IsDebuff = function(self)
--         return false
--     end,
--     IsHidden = function(self)
--         return true
--     end,
--     IsPurgable = function(self)
--         return false
--     end,
--     RemoveOnDeath = function(self)
--         return false
--     end,
--     AllowIllusionDuplicate = function(self)
--         return false
--     end,
--     GetAttributes = function(self)
--         return MODIFIER_ATTRIBUTE_PERMANENT
--     end,
--     DeclareFunctions = function(self)
--         return { MODIFIER_EVENT_ON_DEATH }
--     end
-- })

-- LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_36"] = LUA_MODIFIER_MOTION_NONE

-- --------------------------------------------------------------------------------

-- function modifier_npc_dota_hero_drow_ranger_talent_36:OnCreated()

--     if not IsServer() then return end
--     self.caster = self:GetParent()
--     -- Power Addiction - talent 36 varaibles
--     self.talent36_basePercentManaOnKill = 5
--     self.talent36_percentManaOnKillPerLevel = 5
--     self.talent36_range = 1000

-- end

-- --------------------------------------------------------------------------------

-- function modifier_npc_dota_hero_drow_ranger_talent_36:GetManaRestore()

--     local talent36_level = TalentTree:GetHeroTalentLevel(self.caster, 36)
--     return (self.talent36_basePercentManaOnKill + talent36_level * self.talent36_percentManaOnKillPerLevel) / 100

-- end

-- --------------------------------------------------------------------------------

-- function modifier_npc_dota_hero_drow_ranger_talent_36:OnDeath(params)

--     if not IsServer() then return end
--     local range = DistanceBetweenVectors(params.unit:GetAbsOrigin(), self.caster:GetAbsOrigin())
--     if  (range > self.talent36_range and params.attacker ~= self.caster) then return end
--     if (self.caster:GetTeamNumber() == params.unit:GetTeamNumber()) then return end
--     if (params.unit:IsBuilding()) then return end
--     local manaRestore = self:GetManaRestore() * self.caster:GetMaxMana()
--     if (params.attacker ~= self.caster) then manaRestore = manaRestore / 2 end
--     GameMode:HealUnitMana({ caster = self.caster, target = self.caster, ability = self:GetAbility(), heal = manaRestore }) 

-- end

-- --------------------------------------------------------------------------------
-- -- Talent 46 - Phantom Troupe

-- modifier_npc_dota_hero_drow_ranger_talent_46 = class({
--     IsDebuff = function(self)
--         return false
--     end,
--     IsHidden = function(self)
--         return true
--     end,
--     IsPurgable = function(self)
--         return false
--     end,
--     RemoveOnDeath = function(self)
--         return false
--     end,
--     AllowIllusionDuplicate = function(self)
--         return false
--     end,
--     GetAttributes = function(self)
--         return MODIFIER_ATTRIBUTE_PERMANENT 
--     end,
--     DeclareFunctions = function(self)
--         return { MODIFIER_EVENT_ON_ATTACK_LANDED }
--     end
-- })

-- LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_46"] = LUA_MODIFIER_MOTION_NONE

-- --------------------------------------------------------------------------------

-- function modifier_npc_dota_hero_drow_ranger_talent_46:OnCreated()

--     if not IsServer() then return end
--     self.caster = self:GetParent()
--     -- Phantom Troupe - talent 46 variables
--     self.talent46_baseChance = 15
--     self.talent46_chancePerLevel = 5
--     self.talent46_arrowLevel = 1
--     self.talent46_basePhantomLimit = 4
--     self.talent46_phantomLimitIncreasePerLevel = 1
--     self.talent46_procCd = 1.5

-- end

-- --------------------------------------------------------------------------------

-- function modifier_npc_dota_hero_drow_ranger_talent_46:OnAttackLanded(params)

--     if not IsServer() then return end
--     local ability = self.caster:FindAbilityByName("phantom_ranger_phantom_arrow")
--     if (not ability) then return end
--     if (params.attacker and params.target and not params.target:IsNull() and params.attacker == self.caster and not self.caster:HasModifier("modifier_phantom_ranger_phantom_troupe_proc_cd")) then 

--         self.caster.phantom_arrow_table = self.caster.phantom_arrow_table or {}
--         local talent46_level = TalentTree:GetHeroTalentLevel(self.caster, 46)
--         local phantomProc = RollPercentage(self.talent46_baseChance + talent46_level * self.talent46_chancePerLevel)
--         if not phantomProc then return end

--         self.caster:AddNewModifier(self.caster, nil, "modifier_phantom_ranger_phantom_troupe_proc_cd", { duration = self.talent46_procCd })
--         ability.OnSpellStart(ability, params.attacker, params.target, self.talent46_arrowLevel, true)

--     end

-- end

-- --------------------------------------------------------------------------------

-- modifier_phantom_ranger_phantom_troupe_proc_cd = class({
--     IsDebuff = function(self)
--         return true
--     end,
--     IsHidden = function(self)
--         return true
--     end,
--     IsPurgable = function(self)
--         return false
--     end,
--     RemoveOnDeath = function(self)
--         return true
--     end,
--     AllowIllusionDuplicate = function(self)
--         return false
--     end,
--     GetAttributes = function(self)
--         return MODIFIER_ATTRIBUTE_PERMANENT
--     end
-- })

-- LinkedModifiers["modifier_phantom_ranger_phantom_troupe_proc_cd"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------
-- -- Talent 39 - Death's Embrace


-- modifier_npc_dota_hero_drow_ranger_talent_39 = class({
--     IsDebuff = function(self)
--         return false
--     end,
--     IsHidden = function(self)
--         return true
--     end,
--     IsPurgable = function(self)
--         return false
--     end,
--     RemoveOnDeath = function(self)
--         return false
--     end,
--     AllowIllusionDuplicate = function(self)
--         return false
--     end,
--     GetAttributes = function(self)
--         return MODIFIER_ATTRIBUTE_PERMANENT
--     end
-- })

-- LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_39"] = LUA_MODIFIER_MOTION_NONE

-- --------------------------------------------------------------------------------

-- function modifier_npc_dota_hero_drow_ranger_talent_39:OnCreated()

--     if not IsServer() then return end
--     self.caster = self:GetParent()
--     -- Death's Embrace - talent 39 variables
--     self.talent39_basePercentDmg = 5
--     self.talent39_percentDmgPerLevel = 5

-- end

-- --------------------------------------------------------------------------------

-- function modifier_npc_dota_hero_drow_ranger_talent_39:OnTakeDamage(damageTable)

--  if not IsServer() then return end
--  local drow = damageTable.attacker
--     if not drow:HasAbility("phantom_ranger_black_arrow") then return end
--  local target = damageTable.victim
--     local modifier = drow:FindModifierByName("modifier_npc_dota_hero_drow_ranger_talent_39")

--  if (modifier and (target:HasModifier("modifier_phantom_ranger_shadow_waves_debuff") or target:HasModifier("modifier_phantom_ranger_black_arrow_debuff"))) then

--      local talent39_level = TalentTree:GetHeroTalentLevel(drow, 39)
--      damageTable.damage = damageTable.damage * (100 + modifier.talent39_basePercentDmg + talent39_level * modifier.talent39_percentDmgPerLevel) / 100
        
--      return damageTable
--  end

-- end

-- --------------------------------------------------------------------------------
-- -- Talent 40 - Frenetic (Rank 2 Phantom Barrage)


-- modifier_npc_dota_hero_drow_ranger_talent_40 = class({
--     IsDebuff = function(self)
--         return false
--     end,
--     IsHidden = function(self)
--         return true
--     end,
--     IsPurgable = function(self)
--         return false
--     end,
--     RemoveOnDeath = function(self)
--         return false
--     end,
--     AllowIllusionDuplicate = function(self)
--         return false
--     end,
--     GetAttributes = function(self)
--         return MODIFIER_ATTRIBUTE_PERMANENT
--     end,
--     DeclareFunctions = function(self)
--         return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
--     end
-- })

-- LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_40"] = LUA_MODIFIER_MOTION_NONE

-- --------------------------------------------------------------------------------

-- function modifier_npc_dota_hero_drow_ranger_talent_40:OnCreated()

--     if not IsServer() then return end
--     self.caster = self:GetParent()
--     -- Frenetic - talent 40 variables
--     self.talent40_basePercentHeal = 0
--     self.talent40_percentHealPerLevel = 1

-- end

-- --------------------------------------------------------------------------------

-- function modifier_npc_dota_hero_drow_ranger_talent_40:OnAbilityFullyCast(params)

--     if not IsServer() then return end
--     if (params.ability and params.ability:GetCaster() == self.caster) then 

--         local talent40_level = TalentTree:GetHeroTalentLevel(self.caster, 40)
--         GameMode:HealUnit({ caster = self.caster, target = self.caster, ability = nil, heal = self.caster:GetMaxHealth() * (self.talent40_basePercentHeal + talent40_level * self.talent40_percentHealPerLevel) / 100 })

--     end

-- end