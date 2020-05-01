local LinkedModifiers = {}


--------------------------------------------------------------------------------
-- Phantom Ranger Void Arrows

phantom_ranger_void_arrows = phantom_ranger_void_arrows or class({
    GetAbilityTextureName = function(self)
        return "dark_seer_surge"
    end,
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

function phantom_ranger_void_arrows:OnOrbFire( params )
	local caster = self:GetCaster()
	local manaCost = self:GetManaCost(self:GetLevel() - 1)
	local powerAddictionCostIncrease = TalentTree:GetHeroTalentLevel(caster, 36)
	if costIncrease ~= 0 then 
		caster:SpendMana(manaCost * powerAddictionCostIncrease, self)
	end	
end

--------------------------------------------------------------------------------

function phantom_ranger_void_arrows:OnOrbImpact( params )
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("void_damage")
	local powerAddictionDamageModifier = 1 + (TalentTree:GetHeroTalentLevel(caster, 36) / 3)
	print (powerAddictionDamageModifier)
	if params.target ~= nil then 
		GameMode:DamageUnit({ caster = caster, target = params.target, damage = damage * powerAddictionDamageModifier, voiddmg = true, ability = self })
	end
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
    end
})

--------------------------------------------------------------------------------

function modifier_phantom_ranger_hunters_focus_buff:OnCreated()
    local ability = self:GetAbility()
    self.bonus_attack_speed = MAXIMUM_ATTACK_SPEED
    self.bonus_attack_damage = self:GetAbility():GetSpecialValueFor("attack_damage") / 100
end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_hunters_focus_buff:GetAttackSpeedBonus()
	return self.bonus_attack_speed
end

--------------------------------------------------------------------------------

function modifier_phantom_ranger_hunters_focus_buff:GetAttackDamagePercentBonus()
	return self.bonus_attack_damage
end

--------------------------------------------------------------------------------


LinkedModifiers["modifier_phantom_ranger_hunters_focus_buff"] = LUA_MODIFIER_MOTION_NONE

--------------------------------------------------------------------------------
-- Hunter's Focus

phantom_ranger_hunters_focus = phantom_ranger_hunters_focus or class({
    GetAbilityTextureName = function(self)	
        return "phantom_ranger_hunters_focus"
    end,
})

function phantom_ranger_hunters_focus:OnSpellStart()
    if not IsServer() then
        return
    end
    local hunters_focus_duration = self:GetSpecialValueFor("duration")
    local caster = self:GetCaster()
    GameMode:ApplyBuff({ caster = caster, target = caster, ability = self, modifier_name = "modifier_phantom_ranger_hunters_focus_buff", duration = hunters_focus_duration })
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
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_drow_ranger/talent_36.png"
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_DEATH }
    end
})

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_36:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_36:GetManaRestore()
	return 0.05 + (0.05 * TalentTree:GetHeroTalentLevel(self.caster, 36))
end

--------------------------------------------------------------------------------

function modifier_npc_dota_hero_drow_ranger_talent_36:OnDeath( params )
	if not IsServer() then return end
	if params.attacker~=self.caster then return end
	if self:GetCaster():GetTeamNumber()==params.unit:GetTeamNumber() then return end
	if params.unit:IsBuilding() then return end
	GameMode:HealUnitMana({ caster = self.caster, target = self.caster, ability = self:GetAbility(), heal = self:GetManaRestore() * self:GetCaster():GetMaxMana() })
    
end

LinkedModifiers["modifier_npc_dota_hero_drow_ranger_talent_36"] = LUA_MODIFIER_MOTION_NONE


--------------------------------------------------------------------------------
-- Internal stuff

for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "talents/talents_phantom_ranger", MotionController)
end