-- This is example how to add modifiers to any talent, if you need it (if talent not binded to some skill or something else)
-- Don't forgot include you talents file in talents/require.lua
-- Format is:
--[[
local modifier_name = "modifier"
if(TalentTree:IsUniversalTalent(talentId)) then
    modifier_name = modifier_name.."_generic_"
else
    local heroName = hero:GetUnitName()
    modifier_name = modifier_name.."_"..heroName.."_"
end
modifier_name = modifier_name.."talent_"..tostring(talentId)
--]]
-- Examples of modifier names for generic talents: modifier_talent_25, modifier_talent_26, modifier_talent_27
-- Examples of modifier names for hero specific talents: modifier_npc_dota_hero_silencer_talent_45, modifier_npc_dota_hero_silencer_talent_46
local LinkedModifiers = {}

modifier_talent_1 = class({
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

function modifier_talent_1:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_1:GetStrengthBonus()
    local str_bonus = TalentTree:GetHeroTalentLevel(self.hero, 1) * 3
    return str_bonus or 0
end

LinkedModifiers["modifier_talent_1"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_2 = class({
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

function modifier_talent_2:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_2:GetBlockBonus()
    local agi_bonus = TalentTree:GetHeroTalentLevel(self.hero, 2) * 100
    return agi_bonus or 0
end

LinkedModifiers["modifier_talent_2"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_3 = class({
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

function modifier_talent_3:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_3:GetAttackDamageBonus()
    local int_bonus = TalentTree:GetHeroTalentLevel(self.hero, 3) * 10
    return int_bonus or 0
end

LinkedModifiers["modifier_talent_3"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_4 = class({
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

function modifier_talent_4:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_4:GetAgilityBonus()
    local agi_bonus = TalentTree:GetHeroTalentLevel(self:GetParent(), 4) * 3
    return agi_bonus or 0
end

LinkedModifiers["modifier_talent_4"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_5 = class({
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

function modifier_talent_5:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_5:GetAttackSpeedBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 5) * 10
    return bonus or 0
end

LinkedModifiers["modifier_talent_5"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_6 = class({
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
		return {MODIFIER_PROPERTY_EVASION_CONSTANT}
	end
})

function modifier_talent_6:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_6:GetModifierEvasion_Constant()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 6) * 3
    return bonus or 0
end

LinkedModifiers["modifier_talent_6"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_7 = class({
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

function modifier_talent_7:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_7:GetIntellectBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 7) * 3
    return bonus or 0
end

LinkedModifiers["modifier_talent_7"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_8 = class({
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

function modifier_talent_8:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_8:GetManaRegenerationBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 8) * 5
    return bonus or 0
end

LinkedModifiers["modifier_talent_8"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_9 = class({
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

function modifier_talent_9:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_9:GetSpellDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 9) * 0.03
    return bonus or 0
end

LinkedModifiers["modifier_talent_9"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_10 = class({
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

function modifier_talent_10:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_10:OnTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_10")
	if modifier then
		local bonus = TalentTree:GetHeroTalentLevel(damageTable.attacker, 10) * 0.1
		local primaryAttr = Units:GetHeroPrimaryAttribute(damageTable.attacker)
		local dmg = primaryAttr * bonus
		if damageTable.damage > 0 and damageTable.ability ~= nil then
			damageTable.damage = damageTable.damage + dmg
		end
		return damageTable
	end
end

LinkedModifiers["modifier_talent_10"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_11 = class({
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

function modifier_talent_11:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_11:GetArmorPercentBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 11) * 0.05
    return bonus or 0
end

LinkedModifiers["modifier_talent_11"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_12 = class({
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

function modifier_talent_12:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_12:GetDamageReductionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 12) * 0.05
	return bonus
end

LinkedModifiers["modifier_talent_12"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_13 = class({
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
	
})

function modifier_talent_13:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
	self.crit = 1.5
end

---@param damageTable DAMAGE_TABLE
function modifier_talent_13:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_talent_13")
	if modifier then
		local crit_chance = TalentTree:GetHeroTalentLevel(damageTable.attacker, 13) * 3
		local proc = RollPercentage(crit_chance)
		if ( damageTable.damage > 0 and modifier.crit and modifier.crit > 1 and proc ) then
			damageTable.crit = modifier.crit
			local victimPos = damageTable.victim:GetAbsOrigin()
			local coup_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, damageTable.victim)
			ParticleManager:SetParticleControlEnt(coup_pfx, 0, damageTable.victim, PATTACH_POINT_FOLLOW, "attach_hitloc", victimPos, true)
			ParticleManager:SetParticleControl(coup_pfx, 1, victimPos)
			ParticleManager:SetParticleControlOrientation(coup_pfx, 1, damageTable.attacker:GetForwardVector() * -1, damageTable.attacker:GetRightVector(), damageTable.attacker:GetUpVector())
			Timers:CreateTimer(1, function()
				ParticleManager:DestroyParticle(coup_pfx, false)
				ParticleManager:ReleaseParticleIndex(coup_pfx)
			end)
			EmitSoundOn("Hero_PhantomAssassin.CoupDeGrace", damageTable.victim)
			return damageTable
		end
	end
end

LinkedModifiers["modifier_talent_13"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_14 = class({
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

modifier_talent_14_debuff = class({
    IsDebuff = function(self)
        return true 
    end,
    IsHidden = function(self)
        return false 
    end,
    IsPurgable = function(self)
        return true 
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

function modifier_talent_14_debuff:GetArmorBonus()
	local caster = self:GetCaster()
	local bonus = TalentTree:GetHeroTalentLevel(caster, 14) * (-2)
	return bonus
end

function modifier_talent_14:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_14:OnTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_14")
	if modifier then
		local armorReduc = TalentTree:GetHeroTalentLevel(damageTable.attacker, 14) * 2
		local modifierTable = {}
		modifierTable.caster = damageTable.attacker
		modifierTable.target = damageTable.victim
		modifierTable.ability = nil
		modifierTable.duration = 3
		modifierTable.modifier_name = "modifier_talent_14_debuff"
		GameMode:ApplyDebuff(modifierTable)
	end
	return damageTable
end

LinkedModifiers["modifier_talent_14"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_14_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_15 = class({
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

function modifier_talent_15:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_15:GetVoidDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 15) * 0.1
    return bonus or 0
end

function modifier_talent_15:GetNatureDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 15) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_talent_15"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_16 = class({
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

function modifier_talent_16:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_16:GetSpellHasteBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 16) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_talent_16"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_17 = class({
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

function modifier_talent_17:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_17:GetHolyDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 17) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_talent_17"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_18 = class({
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

function modifier_talent_18:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_18:GetNatureDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 18) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_talent_18"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_19 = class({
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

modifier_talent_19_cd = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT 
    end
})

function modifier_talent_19:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_19:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_talent_19")
	if modifier then
		if damageTable.ability then
			local ability = damageTable.ability
			local abilityIndex = damageTable.attacker:GetAbilityByIndex(2):GetAbilityName()
			local multi = TalentTree:GetHeroTalentLevel(damageTable.attacker, 19) * 0.4 + 1
			if damageTable.attacker:HasModifier("modifier_talent_19_cd") then return end
			if ability:GetAbilityName() == abilityIndex then
				damageTable.crit = multi
				local modifierTable = {}
				modifierTable.caster = damageTable.attacker
				modifierTable.target = damageTable.attacker
				modifierTable.ability = nil
				modifierTable.modifier_name = "modifier_talent_19_cd"
				modifierTable.duration = 10
				GameMode:ApplyBuff(modifierTable)
				local victimPos = damageTable.victim:GetAbsOrigin()
				local coup_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, damageTable.victim)
				ParticleManager:SetParticleControlEnt(coup_pfx, 0, damageTable.victim, PATTACH_POINT_FOLLOW, "attach_hitloc", victimPos, true)
				ParticleManager:SetParticleControl(coup_pfx, 1, victimPos)
				ParticleManager:SetParticleControlOrientation(coup_pfx, 1, damageTable.attacker:GetForwardVector() * -1, damageTable.attacker:GetRightVector(), damageTable.attacker:GetUpVector())
					Timers:CreateTimer(1, function()
						ParticleManager:DestroyParticle(coup_pfx, false)
						ParticleManager:ReleaseParticleIndex(coup_pfx)
					end)
				EmitSoundOn("Hero_PhantomAssassin.CoupDeGrace", damageTable.victim)
				return damageTable
			end
		end
	end
end

LinkedModifiers["modifier_talent_19"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_19_cd"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_20 = class({
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

function modifier_talent_20:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_20:GetAttackDamagePercentBonus()
	local lvl = TalentTree:GetHeroTalentLevel(self.hero, 20)
	local bonus = lvl * Units:GetArmor(self.hero) * 0.07 / 100
	return bonus  or 0
end

function modifier_talent_20:GetSpellDamageBonus()
	local lvl = TalentTree:GetHeroTalentLevel(self.hero, 20)
	local bonus = lvl * Units:GetArmor(self.hero) * 0.07 / 100
	return bonus or 0
end

LinkedModifiers["modifier_talent_20"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_21 = class({
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

modifier_talent_21_debuff = class({
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

function modifier_talent_21:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_21:GetHealthBonus()
	local lvl = TalentTree:GetHeroTalentLevel(self.hero, 21) 
	local bonus = lvl * 300
	return bonus  or 0
end

function modifier_talent_21:GetArmorBonus()
	local lvl = TalentTree:GetHeroTalentLevel(self.hero, 21)
	local bonus = lvl * 3
	return bonus or 0
end

function modifier_talent_21:OnTakeDamage(damageTable)
	local target = nil
	if damageTable.attacker:FindModifierByName("modifier_talent_21") then
		target = damageTable.attacker
	elseif damageTable.victim:FindModifierByName("modifier_talent_21") then
		target = damageTable.victim
	end
	local modifierTable = {}
	modifierTable.caster = target
	modifierTable.target = target
	modifierTable.modifier_name = "modifier_talent_21_debuff"
	modifierTable.duration = 3
	modifierTable.ability = nil
	GameMode:ApplyDebuff(modifierTable)
	return damageTable
end

function modifier_talent_21_debuff:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_21_debuff:GetMoveSpeedPercentBonus()
	return -0.15
end

LinkedModifiers["modifier_talent_21"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_21_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_22 = class({
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

function modifier_talent_22:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_22:GetAttackDamagePercentBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 22) * (-0.05)
    return bonus or 0
end

function modifier_talent_22:GetAttackSpeedPercentBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 22) * 0.1
    return bonus or 0
end

function modifier_talent_22:GetSpellDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 22) * 0.05
    return bonus or 0
end

LinkedModifiers["modifier_talent_22"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_23 = class({
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

function modifier_talent_23:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_23:GetHealthBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 23) * 250
    return bonus or 0
end

function modifier_talent_23:GetSummonDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 23) * 0.1
	return bonus or 0
end

LinkedModifiers["modifier_talent_23"] = LUA_MODIFIER_MOTION_NONE


modifier_talent_24 = class({
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

function modifier_talent_24:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
	self:StartIntervalThink(0.1)
end

function modifier_talent_24:GetAdditionalConditionalDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_24")
	if modifier then
		if damageTable.ability then
			local bonus = TalentTree:GetHeroTalentLevel(damageTable.attacker, 24) * 0.07
			local abilityTable = {}
			local cdTable = {}
			for i = 0, 5 do
				local ability = damageTable.attacker:GetAbilityByIndex(i)
				local cooldown = ability:GetCooldown(ability:GetLevel())
				table.insert(abilityTable,{ability = ability, cd = cooldown})
				table.insert(cdTable, cooldown)
			end
			local lowestCd = math.min(unpack(cdTable))
			local buffAbility = {}
			for i = 1, 6 do
				if abilityTable[i].cd == lowestCd then
					table.insert(buffAbility, abilityTable[i].ability)
				end
			end
			for i = 1, #buffAbility do
				if damageTable.ability:GetAbilityName() == buffAbility[i]:GetAbilityName() then
					return bonus
				end
			end		
		end
	end
end

function modifier_talent_24:GetAttackSpeedPercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 24) * 0.05
	return bonus
end

LinkedModifiers["modifier_talent_24"] = LUA_MODIFIER_MOTION_NONE


modifier_talent_25 = class({
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

function modifier_talent_25:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_25:GetFireProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

function modifier_talent_25:GetFrostProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

function modifier_talent_25:GetEarthProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

function modifier_talent_25:GetVoidProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

function modifier_talent_25:GetHolyProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

function modifier_talent_25:GetNatureProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

function modifier_talent_25:GetInfernoProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

LinkedModifiers["modifier_talent_25"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_26 = class({
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

function modifier_talent_26:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_26:GetArmorBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 26) * 10
    return bonus or 0
end

LinkedModifiers["modifier_talent_26"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_27 = class({
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

function modifier_talent_27:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_27:GetMagicBlockBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 27) * 50
    return bonus or 0
end

LinkedModifiers["modifier_talent_27"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_28 = class({
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

function modifier_talent_28:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_28:GetStrengthPercentBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 28) * 0.05
    return bonus or 0
end

function modifier_talent_28:GetAttackDamagePercentBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 28) * 0.03
    return bonus or 0
end

LinkedModifiers["modifier_talent_28"] = LUA_MODIFIER_MOTION_NONE


modifier_talent_29 = class({
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
		return {MODIFIER_EVENT_ON_ATTACK_LANDED}
	end
})

function modifier_talent_29:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_29:GetInfernoDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 29) * 0.1
    return bonus or 0
end

function modifier_talent_29:GetFireDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 29) * 0.1
	return bonus or 0
end

function modifier_talent_29:OnAttackLanded(event)
	if not IsServer() then return end
	if event.attacker == self:GetParent() then
		local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(),
                self:GetParent():GetAbsOrigin(),
                nil,
                350,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
		local damage = TalentTree:GetHeroTalentLevel(self.hero, 29) * 0.1 * Units:GetAttackDamage(self:GetParent())
		local proc = RollPercentage(30)
		if proc then
			for _, unit in pairs(units) do
				local damageTable = {}
				damageTable.caster = self:GetParent()
				damageTable.target = unit
				damageTable.damage = damage
				damageTable.firedmg = true
				damageTable.infernodmg = true
				GameMode:DamageUnit(damageTable)
			end
		end
	end
end

LinkedModifiers["modifier_talent_29"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_30 = class({
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
        return {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
        }
    end,
})

modifier_talent_30_aura = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT 
    end,
	IsAura = function(self)
		return true
	end,
	GetModifierAura = function(self)
		return "modifier_talent_30_aura_buff"
	end,
	GetAuraSearchType = function(self)
		return DOTA_UNIT_TARGET_HERO
    end,
	GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
	IsAuraActiveOnDeath = function(self)
        return false
    end,
	GetAuraDuration = function(self)
        return 0.5
    end,
	GetAuraRadius = function(self)
        return 900
    end,
})

modifier_talent_30_aura_buff = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT 
    end
})
modifier_talent_30_aura_cd = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT 
    end
})

function modifier_talent_30_aura_buff:GetDamageReductionBonus()
	local reduc = 0.15
	return reduc
end

function modifier_talent_30:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_30:OnAbilityFullyCast(keys)
	if not IsServer() then return end
	local ability = keys.ability
	if keys.unit == self:GetParent() then
		if keys.unit:HasModifier("modifier_talent_30_aura_cd") then return end
		if ability:GetAbilityName() == keys.unit:GetAbilityByIndex(5):GetAbilityName() then
			local modifierTable = {}
			modifierTable.caster = self.hero
			modifierTable.target = self.hero
			modifierTable.ability = nil
			modifierTable.modifier_name = "modifier_talent_30_aura"
			modifierTable.duration = 10
			GameMode:ApplyBuff(modifierTable)
			local modifierTable = {}
			modifierTable.caster = self.hero
			modifierTable.target = self.hero
			modifierTable.ability = nil
			modifierTable.modifier_name = "modifier_talent_30_aura_cd"
			modifierTable.duration = 25
			GameMode:ApplyBuff(modifierTable)
		end
	end
end

function modifier_talent_30:GetFireProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 30) * 0.05
    return bonus
end

function modifier_talent_30:GetFrostProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 30) * 0.05
    return bonus
end

function modifier_talent_30:GetEarthProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 30) * 0.05
    return bonus
end

function modifier_talent_30:GetVoidProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 30) * 0.05
    return bonus
end

function modifier_talent_30:GetHolyProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 30) * 0.05
    return bonus
end

function modifier_talent_30:GetNatureProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 30) * 0.05
    return bonus
end

function modifier_talent_30:GetInfernoProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 30) * 0.05
    return bonus
end

function modifier_talent_30:GetArmorBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 30) * 3
	return bonus
end

function modifier_talent_30_aura_buff:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_talent_30_aura_buff")
    if (modifier and modifier:GetCaster() and damageTable.damage > 0) then
        local damageRedirect = damageTable.damage * 0.15
        local carrierHp = modifier:GetCaster():GetHealth() - damageRedirect
        if (carrierHp >= 1) then
            modifier:GetCaster():SetHealth(carrierHp)
            damageTable.damage = damageTable.damage - damageRedirect
        end
        return damageTable
    end
end

LinkedModifiers["modifier_talent_30"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_30_aura"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_30_aura_buff"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_30_aura_cd"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_31 = class({
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

function modifier_talent_31:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_31:GetAgilityPercentBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 31) * 0.05
    return bonus or 0
end

function modifier_talent_31:GetAttackSpeedPercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 31) * 0.03
	return bonus or 0
end

LinkedModifiers["modifier_talent_31"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_32 = class({
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

modifier_talent_32_effect = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT 
    end,
	CheckState = function(self)
		return {[MODIFIER_STATE_UNSELECTABLE] = true}
	end
})

modifier_talent_32_cd = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_talent_32:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_32:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_talent_32")
	if modifier then
		local health = damageTable.victim:GetMaxHealth()
		local cHealth = damageTable.victim:GetHealth()
		local threshold = 0.25
		local postPerc = (cHealth - damageTable.damage)/ health
		if damageTable.victim:HasModifier("modifier_talent_32_cd") then return end
		if postPerc < threshold then
			damageTable.damage = 0
			local modifierTable = {}
			modifierTable.caster = damageTable.victim
			modifierTable.target = damageTable.victim
			modifierTable.ability = nil
			modifierTable.modifier_name = "modifier_talent_32_effect"
			modifierTable.duration = 5
			GameMode:ApplyBuff(modifierTable)
			local modifierTable = {}
			modifierTable.caster = damageTable.victim
			modifierTable.target = damageTable.victim
			modifierTable.ability = nil
			modifierTable.modifier_name = "modifier_talent_32_cd"
			modifierTable.duration = 40
			GameMode:ApplyBuff(modifierTable)
			return damageTable
		end
	end
end

function modifier_talent_32_effect:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_32_effect:GetMoveSpeedPercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 32) * 0.1
	return bonus or 0
end

LinkedModifiers["modifier_talent_32"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_32_effect"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_32_cd"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_33 = class({
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

modifier_talent_33_effect = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT 
    end
})

function modifier_talent_33:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_33:GetCriticalChanceBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 33) * 0.05
    return bonus or 0
end

function modifier_talent_33:OnTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_33")
	if modifier then
		if damageTable.crit > 1 then
			if modifier:GetStackCount() > 1 then
				local modifierTable = {}
				modifierTable.caster = damageTable.attacker
				modifierTable.target = damageTable.attacker
				modifierTable.ability = nil
				modifierTable.modifier_name = "modifier_talent_33_effect"
				modifierTable.duration = 3
				GameMode:ApplyBuff(modifierTable)
				modifier:SetStackCount(0)
			else
				modifier:IncrementStackCount()
			end
		else
			modifier:SetStackCount(0)
		end
		return damageTable
	end
end

function modifier_talent_33_effect:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_33_effect:GetBaseAttackTime()
	local bonus = self.hero:GetBaseAttackTime() - TalentTree:GetHeroTalentLevel(self.hero, 33) * 0.1
	return bonus or 0
end

LinkedModifiers["modifier_talent_33"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_33_effect"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_37 = class({
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
		return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
	end
})

modifier_talent_37_aura = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
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
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return 350
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_talent_37_aura_effect"
    end,
    GetAuraDuration = function(self)
        return 0
    end,
})

modifier_talent_37_aura_effect = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
	DeclareFunctions = function(self)
		return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
	end
})

function modifier_talent_37:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_37:GetAOEDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 37) * 0.15
	return bonus
end

function modifier_talent_37:OnAbilityFullyCast(keys)
	if not IsServer() then return end
	if keys.unit == self.hero then
		local ability_name = self.hero:GetAbilityByIndex(2):GetAbilityName()
		if keys.ability:GetAbilityName() == ability_name then
			local modifierTable = {}
			modifierTable.caster = self.hero
			modifierTable.target = self.hero
			modifierTable.ability = nil
			modifierTable.modifier_name = "modifier_talent_37_aura"
			modifierTable.duration = 12
			GameMode:ApplyBuff(modifierTable)
		end
	end
end

function modifier_talent_37_aura_effect:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetCaster()
	self:StartIntervalThink(0.5)
end

function modifier_talent_37_aura_effect:OnIntervalThink()
	if not IsServer() then return end
	local damageScale = TalentTree:GetHeroTalentLevel(self.hero, 37) * 0.3
	local damage = Units:GetHeroStrength(self.hero) * damageScale
	local damageTable = {}
	damageTable.caster = self.hero
	damageTable.target = self:GetParent()
	damageTable.fromtalent = 37
	damageTable.aoe = true
	damageTable.damage = damage
	damageTable.firedmg = true
	GameMode:DamageUnit(damageTable)
end

function modifier_talent_37_aura_effect:GetModifierMiss_Percentage()
	return 20
end

LinkedModifiers["modifier_talent_37"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_37_aura"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_37_aura_effect"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_38 = class({
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

modifier_talent_38_shield = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

modifier_talent_38_cd = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_talent_38:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetParent()
end

function modifier_talent_38:OnTakeDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_38")
	if modifier then
		local proc = RollPercentage(50)
		local units = FindUnitsInRadius(modifier.hero:GetTeamNumber(),
					modifier.hero:GetAbsOrigin(),
					nil,
					1000,
					DOTA_UNIT_TARGET_TEAM_FRIENDLY,
					DOTA_UNIT_TARGET_HERO,
					DOTA_UNIT_TARGET_FLAG_NONE,
					FIND_ANY_ORDER,
					false)
		local targets = {}
		local hpTable = {}
		for _, unit in pairs(units) do			
			local hpPerc = unit:GetHealthPercent()
			table.insert(targets, {target = unit, perc = hpPerc})
			table.insert(hpTable, hpPerc)
		end
		local lowestHp = math.min(unpack(hpTable))
		local targetNeedHelp = damageTable.victim
		for i = 1, #targets do
			if targets[i].perc == lowestHp and targets[i].perc < damageTable.victim:GetHealthPercent() then
				targetNeedHelp = targets[i].target
			end
		end
		if not targetNeedHelp:IsNull() then
			if not damageTable.victim:HasModifier("modifier_talent_38_cd") then
				local modifierTable = {}
				modifierTable.caster = damageTable.victim
				modifierTable.target = targetNeedHelp
				modifierTable.ability = nil
				modifierTable.modifier_name = "modifier_talent_38_shield"
				modifierTable.duration = 10
				GameMode:ApplyBuff(modifierTable)
				local modifierTable = {}
				modifierTable.caster = damageTable.victim
				modifierTable.target = damageTable.victim
				modifierTable.ability = nil
				modifierTable.modifier_name = "modifier_talent_38_cd"
				modifierTable.duration = 25
				GameMode:ApplyBuff(modifierTable)
			end
		end
		return damageTable
	end
end

function modifier_talent_38_shield:OnCreated()
	if not IsServer() then return end
	local absorbScale = TalentTree:GetHeroTalentLevel(self:GetCaster(), 38) * 0.05
	self.absorbAmount = self:GetParent():GetMaxHealth() * absorbScale
end

function modifier_talent_38_shield:OnTakeDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_38_shield")
	if modifier then
		if modifier.absorbAmount >= damageTable.damage then
			damageTable.damage = 0
			modifier.absorbAmount = modifier.absorbAmount - damageTable.damage
		else
			damageTable.damage = damageTable.damage - modifier.absorbAmount
			modifier:Destroy()
		end
		return damageTable
	end
end

LinkedModifiers["modifier_talent_38"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_38_shield"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_38_cd"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_39 = class({
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
})

modifier_talent_39_dot = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
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
})

function modifier_talent_39:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetParent()
end

function modifier_talent_39:GetDOTDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 39) * 0.1
	return bonus
end

function modifier_talent_39:OnTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_39")
	if modifier then
		if damageTable.ability then
			local ability_name = damageTable.ability:GetAbilityName()
			local ability_index = damageTable.attacker:GetAbilityByIndex(0):GetAbilityName()
			local proc = RollPercentage(40)
			if ability_name == ability_index and proc then
				local modifierTable = {}
				modifierTable.caster = damageTable.attacker
				modifierTable.target = damageTable.victim
				modifierTable.ability = nil
				modifierTable.modifier_name = "modifier_talent_39_dot"
				modifierTable.duration = 3
				modifierTable.stacks = 1
				modifierTable.max_stacks = 99999
				GameMode:ApplyStackingDebuff(modifierTable)
				Timers:CreateTimer(3, function()
					if damageTable.victim:HasModifier("modifier_talent_39_dot") then
						damageTable.victim:FindModifierByName("modifier_talent_39_dot"):DecrementStackCount()
					end
				end)
				return damageTable
			end
		end
	end
end

function modifier_talent_39_dot:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetCaster()
	self:StartIntervalThink(0.5)
end

function modifier_talent_39_dot:OnIntervalThink()
	if not IsServer() then return end
	local scale = TalentTree:GetHeroTalentLevel(self.hero, 39) * 0.15
	local damage = Units:GetHeroPrimaryAttribute(self.hero) * scale * self:GetStackCount()
	local damageTable = {}
	damageTable.caster = self.hero
	damageTable.target = self:GetParent()
	damageTable.damage = damage
	damageTable.dot = true
	damageTable.single = true
	damageTable.fromtalent = 39
	GameMode:DamageUnit(damageTable)
end


LinkedModifiers["modifier_talent_39"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_39_dot"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_40 = class({
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
})

function modifier_talent_40:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetParent()
	self.cd = false
end

function modifier_talent_40:OnTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_40")
	if modifier then
		local chance = TalentTree:GetHeroTalentLevel(damageTable.attacker, 40) * 100
		local proc = RollPercentage(chance)
		--if proc and not modifier.cd then
			GameMode:DamageUnit(damageTable)
			--modifier.cd = true
			--Timers:CreateTimer(1, function()
				--modifier.cd = false
			--end)
		--end
	end
end

LinkedModifiers["modifier_talent_40"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_41 = class({
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
		return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
	end
})

modifier_talent_41_effect = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_talent_41:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
	self.Qcast = false
	self.Wcast = false
	self.ECast = false
end

function modifier_talent_41:OnAbilityFullyCast(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() then
		for i = 0, 2, 1 do
			local ability = keys.unit:GetAbilityByIndex(i)
			if keys.ability:GetAbilityName() == ability:GetAbilityName() then
				if i == 0 then
					self.Qcast = true
				elseif i == 1 then
					self.Wcast = true
				elseif i == 2 then
					self.Ecast = true
				end
				if self.Qcast and self.Wcast and self.Ecast then
					self.Qcast = false
					self.Wcast = false
					self.Ecast = false
					local modifierTable = {}
					modifierTable.caster = keys.unit
					modifierTable.target = keys.unit
					modifierTable.ability = nil
					modifierTable.modifier_name = "modifier_talent_41_effect"
					modifierTable.duration = 12
					GameMode:ApplyBuff(modifierTable)
				end
			end
		end
	end
end

function modifier_talent_41_effect:OnCreated()
	if not IsServer() then
		return
	end
	self:SetStackCount(1)
	self:StartIntervalThink(1)
end

function modifier_talent_41_effect:OnIntervalThink()
	if not IsServer() then 
		return
	end
	Timers:CreateTimer(11, function()
		if not self:IsNull() then
			self:DecrementStackCount()
		end
	end)
	self:IncrementStackCount()
end

function modifier_talent_41_effect:GetAttackSpeedPercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self:GetParent(), 41) * self:GetStackCount() * 0.01
	return bonus
end

function modifier_talent_41_effect:GetSpellDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self:GetParent(), 41) * self:GetStackCount() * 0.01
	return bonus
end

LinkedModifiers["modifier_talent_41"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_41_effect"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_42 = class({
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
		return {MODIFIER_EVENT_ON_ATTACK_LANDED}
	end
})

modifier_talent_42_debuff = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})


function modifier_talent_42:OnCreated()
	if not IsServer() then
		return
	end
end

function modifier_talent_42:OnAttackLanded(kv)
	if not IsServer() then
		return
	end
	if kv.attacker == self:GetParent() then
		local units = FindUnitsInRadius(kv.attacker:GetTeamNumber(),
                   kv.attacker:GetAbsOrigin(),
                   nil,
                   900,
                   DOTA_UNIT_TARGET_TEAM_ENEMY,
                   DOTA_UNIT_TARGET_ALL,
                   DOTA_UNIT_TARGET_FLAG_NONE,
                   FIND_ANY_ORDER,
                   false)
		for k, unit in pairs(units) do
			local proc = RollPercentage(50)
			local info = 
			{
				Target = unit,
				Source = kv.attacker,
				Ability = nil,	
				EffectName = "particles/econ/items/enigma/enigma_geodesic/enigma_base_attack_eidolon_geodesic.vpcf",
				iMoveSpeed = 900,
				vSourceLoc= kv.attacker:GetAbsOrigin(),         
				bDrawsOnMinimap = false,                          
					bDodgeable = true,                                
					bIsAttack = false,                                
					bVisibleToEnemies = true,                         
					bReplaceExisting = false,                         
					flExpireTime = GameRules:GetGameTime() + 10,      
				bProvidesVision = true,                          
				iVisionRadius = 0,                              
				iVisionTeamNumber = kv.attacker:GetTeamNumber()        
			}
			if proc then
				Timers:CreateTimer(3, function()
					projectile = ProjectileManager:CreateTrackingProjectile(info)
				end)
			end
		end	
	end
end

function modifier_talent_42:OnProjectileHit(hTarget)
	local scale = TalentTree:GetHeroTalentLevel(self:GetParent(), 42) * 0.3
	local damage = Units:GetAttackDamage(self:GetParent()) * scale
	if hTarget and not hTarget:IsNull() then
		local damageTable = {}
		damageTable.damage = damage
		damageTable.caster = self:GetParent()
		damageTable.fromtalent = 42
		damageTable.target = hTarget
		damageTable.voiddmg = true
		damageTable.single = true
		damageTable.physdmg = true
		GameMode:DamageUnit(damageTable)
		local modifierTable = {}
		modifierTable.caster = self:GetParent()
		modifierTable.target = hTarget
		modifierTable.ability = nil
		modifierTable.modifier_name = "modifier_talent_42_debuff"
		modifierTable.duration = 3
		modifierTable.max_stacks = 5
		modifierTable.stacks = 1
		GameMode:ApplyStackingDebuff(modifierTable)
	end
end

function modifier_talent_42_debuff:OnCreated()
	if not IsServer() then
		return 
	end
	self.hero = self:GetCaster()
end

function modifier_talent_42_debuff:GetAttackDamagePercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 42) * 0.01 * self:GetStackCount()
	return bonus * (-1)
end

LinkedModifiers["modifier_talent_42"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_42_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_43 = class({
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
})

modifier_talent_43_stack = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_talent_43:OnCreated()
	if not IsServer() then 
		return 
	end
	self.hero = self:GetParent()
end

function modifier_talent_43:OnTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_43")
	if modifier then
		if damageTable.ability then
			local modifierTable = {}
			modifierTable.caster = damageTable.attacker
			modifierTable.target = damageTable.victim
			modifierTable.ability = damageTable.ability
			modifierTable.modifier_name = "modifier_talent_43_stack"
			modifierTable.duration = 5
			modifierTable.stacks = 1
			modifierTable.max_stacks = 5
			GameMode:ApplyStackingDebuff(modifierTable)
			return damageTable
		end
	end
end

function modifier_talent_43_stack:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetCaster()
end

function modifier_talent_43_stack:GetAdditionalConditionalDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_43_stack")
	local bonus = 0
	if modifier then
		if damageTable.ability then
			if damageTable.ability:GetAbilityName() == modifier:GetAbility():GetAbilityName() then
				bonus = bonus + TalentTree:GetHeroTalentLevel(damageTable.attacker, 43) * 0.05 * self:GetStackCount()
			end
		end
	end
	return bonus
end

LinkedModifiers["modifier_talent_43"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_43_stack"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_44 = class({
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
})

function modifier_talent_44:OnCreated()
	if not IsServer() then 
		return 
	end
	self.hero = self:GetParent()
end

function modifier_talent_44:GetSpellDamageBonus()
	local modifier = self.hero:FindModifierByName("modifier_talent_44")
	if modifier then
		local bonus = 0
		local modifiers = self.hero:FindAllModifiers()
		for i = 1, #modifiers do
			if modifiers[i]:IsDebuff() == false then
					bonus = bonus + TalentTree:GetHeroTalentLevel(self.hero, 44) * 0.01
			end
		end
		return bonus
	end
end

function modifier_talent_44:GetHealingCausedPercentBonus()
	local modifier = self.hero:FindModifierByName("modifier_talent_44")
	if modifier then
		local bonus = 0
		local modifiers = self.hero:FindAllModifiers()
		for i = 1, #modifiers do
			if modifiers[i]:IsDebuff() == false then
					bonus = bonus + TalentTree:GetHeroTalentLevel(self.hero, 44) * 0.02
			end
		end
		return bonus
	end
end

LinkedModifiers["modifier_talent_44"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_45 = class({
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
		return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
	end
})

modifier_talent_45_shield_applier = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

modifier_talent_45_shield = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_talent_45:OnCreated()
	if not IsServer() then 
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_45:OnAbilityFullyCast(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self.hero then
		local abilityIndex = self.hero:GetAbilityByIndex(3):GetAbilityName()
		if keys.ability:GetAbilityName() == abilityIndex then
			local modifierTable = {}
			modifierTable.caster = self.hero
			modifierTable.target = self.hero
			modifierTable.ability = nil
			modifierTable.modifier_name = "modifier_talent_45_shield_applier"
			modifierTable.duration = -1
			GameMode:ApplyBuff(modifierTable)
		end
	end
end

function modifier_talent_45_shield_applier:OnPostHeal(healTable)
	local modifier = healTable.caster:FindModifierByName("modifier_talent_45_shield_applier")
	if modifier then
		local modifierTable = {}
		modifierTable.caster = healTable.caster
		modifierTable.target = healTable.target
		modifierTable.ability = nil
		modifierTable.modifier_name = "modifier_talent_45_shield"
		modifierTable.duration = 10
		GameMode:ApplyBuff(modifierTable)
	end
end

function modifier_talent_45_shield:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
	self.absorbAmount = TalentTree:GetHeroTalentLevel(self.hero, 45) * 0.1 * self:GetParent():GetMaxHealth()
end

function modifier_talent_45_shield:OnTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_45_shield")
	if modifier then
		if damageTable.damage <= modifier.absorbAmount then
			modifier.absorbAmount = modifier.absorbAmount - damageTable.damage
			damageTable.damage = 0
		else
			damageTable.damage = damageTable.damage - modifier.absorbAmount
			modifier:Destroy()
		end
	end
end

LinkedModifiers["modifier_talent_45"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_45_shield_applier"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_45_shield"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_46 = class({
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
		return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
	end
})

modifier_talent_46_effect = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

modifier_talent_46_debuff = class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
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

function modifier_talent_46:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetParent()
end

function modifier_talent_46:OnAbilityFullyCast(keys)
	if not IsServer() then return end
	if keys.unit == self.hero then
		local ability_name = self.hero:GetAbilityByIndex(5):GetAbilityName()
		if keys.ability:GetAbilityName() == ability_name then
			local modifierTable = {}
			modifierTable.caster = keys.unit
			modifierTable.target = keys.unit
			modifierTable.duration = 15
			modifierTable.ability = nil
			modifierTable.modifier_name = "modifier_talent_46_effect"
			GameMode:ApplyBuff(modifierTable)
			local units = FindUnitsInRadius(self.hero:GetTeamNumber(),
					self.hero:GetAbsOrigin(),
					nil,
					500,
					DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_ALL,
					DOTA_UNIT_TARGET_FLAG_NONE,
					FIND_ANY_ORDER,
					false)
			for _, unit in pairs(units) do
				local modifierTable = {}
				modifierTable.caster = self.hero
				modifierTable.target = unit
				modifierTable.ability = nil
				modifierTable.modifier_name = "modifier_talent_46_debuff"
				modifierTable.duration = 15
				GameMode:ApplyDebuff(modifierTable)
			end
		end
	end
end

function modifier_talent_46_debuff:GetArmorBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self:GetCaster(), 46) * (-1)
	return bonus
end

function modifier_talent_46_effect:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetParent()
	self:StartIntervalThink(3)
end

function modifier_talent_46_effect:OnTakeDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_46_effect")
	if modifier then
		if damageTable.attacker:HasModifier("modifier_talent_46_debuff") then
			self:IncrementStackCount()
			return damageTable
		end
	end
end

function modifier_talent_46_effect:GetArmorBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 46) * 0.5 * self:GetStackCount()
	return bonus
end

function modifier_talent_46_effect:OnIntervalThink()
	if not IsServer() then return end
	local scale = TalentTree:GetHeroTalentLevel(self.hero, 46) * 0.75
	local damage = Units:GetArmor(self.hero) * scale
	local units = FindUnitsInRadius(self.hero:GetTeamNumber(),
					self.hero:GetAbsOrigin(),
					nil,
					400,
					DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_ALL,
					DOTA_UNIT_TARGET_FLAG_NONE,
					FIND_ANY_ORDER,
					false)
	for _, unit in pairs(units) do
		local damageTable = {}
		damageTable.caster = self.hero
		damageTable.target = unit
		damageTable.fromtalent = 46
		damageTable.aoe = true
		damageTable.damage = damage
		damageTable.physdmg = true
		GameMode:DamageUnit(damageTable)
	end
end

LinkedModifiers["modifier_talent_46"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_46_effect"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_46_debuff"] = LUA_MODIFIER_MOTION_NONE


modifier_talent_47 = class({
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
})

modifier_talent_47_fire_res = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
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
})

modifier_talent_47_inferno_res = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
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
})

modifier_talent_47_holy_res = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
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
})

modifier_talent_47_nature_res = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
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
})

modifier_talent_47_void_res = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
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
})

modifier_talent_47_frost_res = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
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
})

modifier_talent_47_earth_res = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
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
})

modifier_talent_47_buff = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
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
})

function modifier_talent_47:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetParent()
end

function modifier_talent_47:OnTakeDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_47")
	if modifier then
		local modifiers = {}
		local mods = {}
		if damageTable.firedmg then
			table.insert(modifiers, "modifier_talent_47_fire_res")
		end
		if damageTable.frostdmg then
			table.insert(modifiers, "modifier_talent_47_frost_res")
		end
		if damageTable.voiddmg then
			table.insert(modifiers, "modifier_talent_47_void_res")
		end
		if damageTable.infernodmg then
			table.insert(modifiers, "modifier_talent_47_inferno_res")
		end
		if damageTable.earthdmg then
			table.insert(modifiers, "modifier_talent_47_earth_res")
		end
		if damageTable.holydmg then
			table.insert(modifiers, "modifier_talent_47_holy_res")
		end
		if damageTable.naturedmg then
			table.insert(modifiers, "modifier_talent_47_nature_res")
		end
		for k, v in pairs(modifiers) do
			table.insert(mods, v)
		end
		local max_stacks = TalentTree:GetHeroTalentLevel(damageTable.victim, 47) + 2
		for i = 1, #mods do
			local modifierTable = {}
			modifierTable.caster = damageTable.victim
			modifierTable.target = damageTable.victim
			modifierTable.ability = nil
			modifierTable.modifier_name = mods[i]
			modifierTable.duration = 6
			modifierTable.stacks = 1
			modifierTable.max_stacks = max_stacks
			GameMode:ApplyStackingBuff(modifierTable)
			Timers:CreateTimer(6, function()
				if damageTable.victim:HasModifier(mods[i]) then
					damageTable.victim:FindModifierByName(mods[i]):DecrementStackCount()
				end
			end)
			local units = FindUnitsInRadius(damageTable.victim:GetTeamNumber(),
					damageTable.victim:GetAbsOrigin(),
					nil,
					700,
					DOTA_UNIT_TARGET_TEAM_FRIENDLY,
					DOTA_UNIT_TARGET_ALL,
					DOTA_UNIT_TARGET_FLAG_NONE,
					FIND_ANY_ORDER,
					false)
			for _, unit in pairs(units) do
				local modifierTable = {}
				modifierTable.caster = damageTable.victim
				modifierTable.target = unit
				modifierTable.ability = nil
				modifierTable.modifier_name = "modifier_talent_47_buff"
				modifierTable.duration = 6
				modifierTable.max_stacks = max_stacks * 7
				modifierTable.stacks = 1
				GameMode:ApplyStackingBuff(modifierTable)
				Timers:CreateTimer(6, function()
					if modifierTable.target:HasModifier("modifier_talent_47_buff") then
						modifierTable.target:FindModifierByName("modifier_talent_47_buff"):DecrementStackCount()
					end
				end)
			end
			return damageTable
		end
	end
end

function modifier_talent_47_earth_res:GetEarthProtectionBonus()
	return self:GetStackCount() * 0.03
end

function modifier_talent_47_fire_res:GetFireProtectionBonus()
	return self:GetStackCount() * 0.03
end

function modifier_talent_47_frost_res:GetFrostProtectionBonus()
	return self:GetStackCount() * 0.03
end

function modifier_talent_47_holy_res:GetHolyProtectionBonus()
	return self:GetStackCount() * 0.03
end

function modifier_talent_47_void_res:GetVoidProtectionBonus()
	return self:GetStackCount() * 0.03
end

function modifier_talent_47_inferno_res:GetInfernoProtectionBonus()
	return self:GetStackCount() * 0.03
end

function modifier_talent_47_nature_res:GetNatureProtectionBonus()
	return self:GetStackCount() * 0.03
end

function modifier_talent_47_buff:GetSpellDamageBonus()
	local bonus = self:GetStackCount() * 0.01
	return bonus
end

LinkedModifiers["modifier_talent_47"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_47_buff"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_47_earth_res"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_47_fire_res"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_47_frost_res"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_47_holy_res"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_47_inferno_res"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_47_nature_res"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_47_void_res"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_48 = class({
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
})

modifier_talent_48_effect = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_talent_48:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetParent()
end

function modifier_talent_48:OnTakeDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_48")
	if modifier then
		local Hp = damageTable.victim:GetHealth()
		if damageTable.damage > Hp then
			damageTable.damage = 0
			damageTable.victim:SetHealth(1)
			local modifierTable = {}
			modifierTable.caster = damageTable.victim
			modifierTable.target = damageTable.victim
			modifierTable.ability = nil
			modifierTable.modifier_name = "modifier_talent_48_effect"
			modifierTable.duration = TalentTree:GetHeroTalentLevel(damageTable.victim, 48) * 2 + 2
			GameMode:ApplyBuff(modifierTable)
		end
		return damageTable
	end
end

function modifier_talent_48_effect:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetParent()
	self.damageCount = 0
	self.healCount = 0
end

function modifier_talent_48_effect:OnTakeDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_48_effect")
	if modifier then
		modifier.damageCount = modifier.damageCount + damageTable.damage
		damageTable.damage = 0
		return damageTable
	end
end

function modifier_talent_48_effect:OnPostHeal(healTable)
	local modifier = healTable.target:FindModifierByName("modifier_talent_48_effect")
	if modifier then
		modifier.healCount = modifier.healCount + healTable.healCount
		return healTable
	end
end

function modifier_talent_48_effect:OnDestroy()
	if not IsServer() then return end
	local heal = TalentTree:GetHeroTalentLevel(self.hero, 48) * 0.15 * self.hero:GetMaxHealth()
	if self.healCount >= self.damageCount then
		local healTable = {}
		healTable.caster = self.hero
		healTable.target = self.hero
		healTable.heal = heal
		healTable.ability = nil
		GameMode:HealUnit(healTable)
	else
		self.hero:ForceKill(false)
	end
end

LinkedModifiers["modifier_talent_48"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_48_effect"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_49 = class({
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
		return {MODIFIER_EVENT_ON_ATTACK_LANDED}
	end
})

modifier_talent_49_dot = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_talent_49:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetParent()
end

function modifier_talent_49:OnTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_49")
	if modifier and not damageTable.ability and damageTable.physdmg then
		damageTable.naturedmg = true
		return damageTable
	end
end

function modifier_talent_49:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker == self:GetParent() then
		local proc = RollPercentage(30)
		if proc then
			local modifierTable = {}
			modifierTable.caster = self.hero
			modifierTable.target = kv.target
			modifierTable.ability = nil
			modifierTable.modifier_name = "modifier_talent_49_dot"
			modifierTable.duration = 3
			modifierTable.stacks = 1
			modifierTable.max_stacks = 99999
			GameMode:ApplyStackingDebuff(modifierTable)
			Timers:CreateTimer(3, function()
				if kv.target:HasModifier("modifier_talent_49_dot") then
					kv.target:FindModifierByName("modifier_talent_49_dot"):DecrementStackCount()
				end
			end)
		end
	end
end

function modifier_talent_49_dot:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetCaster()
	self:StartIntervalThink(0.33)
end

function modifier_talent_49_dot:OnIntervalThink()
	if not IsServer() then return end
	local scale = TalentTree:GetHeroTalentLevel(self.hero, 49) * 0.1
	local damage = Units:GetAttackDamage(self.hero) * scale * self:GetStackCount()
	local damageTable = {}
	damageTable.caster = self.hero
	damageTable.target = self:GetParent()
	damageTable.fromtalent = 49
	damageTable.dot = true
	damageTable.single = true
	damageTable.damage = damage
	damageTable.naturedmg = true
	GameMode:DamageUnit(damageTable)
end

LinkedModifiers["modifier_talent_49"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_49_dot"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_50 = class({
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
})

function modifier_talent_50:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetParent()
end

function modifier_talent_50:GetMoveSpeedPercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 50) * 0.08
	return bonus
end

function modifier_talent_50:GetAdditionalConditionalDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_50")
	if modifier then
		local ms_enemy = Units:GetMoveSpeed(damageTable.victim)
		local ms_self = Units:GetMoveSpeed(damageTable.attacker)
		local ms_diff = ms_self - ms_enemy
		local bonus = TalentTree:GetHeroTalentLevel(self.hero, 50) * 0.001
		local amp = 0
		if ms_diff > 0 then
			amp = amp + bonus * ms_diff
			return bonus
		end
	end
end

LinkedModifiers["modifier_talent_50"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_51 = class({
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
})

modifier_talent_51_effect = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_talent_51:OnCreated()
	if not IsServer() then return end
	self.hero = self:GetParent()
end

function modifier_talent_51:OnModifierApplied(modifierTable)
	local mod = modifierTable.target:FindModifierByName("modifier_talent_51")
	if mod then
		local modifier = modifierTable.target:FindModifierByName(modifierTable.modifier_name)
		if self:IsDebuff() == false and not self.IsDebuff then
			local target = self:GetParent()
			local duration = TalentTree:GetHeroTalentLevel(target, 51) + 1
			local modifiers = {}
			modifiers.caster = target
			modifiers.target = target
			modifiers.ability = nil
			modifiers.modifier_name = "modifier_talent_51_effect"
			modifiers.stacks = 1
			modifiers.max_stacks = 99999
			modifiers.duration = duration
			GameMode:ApplyStackingBuff(modifiers)
			Timers:CreateTimer(duration, function()
				if target:HasModifier("modifier_talent_51_effect") then
					target:FindModifierByName("modifier_talent_51_effect"):DecrementStackCount()
				end
			end)
			return modifierTable
		end
	end
end

function modifier_talent_51_effect:GetSpellDamageBonus()
	return self:GetStackCount() * 0.01
end

function modifier_talent_51_effect:GetAttackDamagePercentBonus()
	return self:GetStackCount() * 0.01
end

LinkedModifiers["modifier_talent_51"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_51_effect"] = LUA_MODIFIER_MOTION_NONE


modifier_talent_52 = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_talent_52:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_52:OnModifierApplied(modifierTable)
	local modifier = modifierTable.caster:FindModifierByName("modifier_talent_52")
	if modifier then
		local chance = TalentTree:GetHeroTalentLevel(modifierTable.caster, 52) * 7
		local proc = RollPercentage(chance)
		if proc then
			if modifierTable.modifier:IsDebuff() then
				if modifierTable.stacks > 0 then
					GameMode:ApplyStackingDebuff(modifierTable)
				else
					GameMode:ApplyDebuff(modifierTable)
				end
			else
				if modifierTable.stacks > 0 then
					GameMode:ApplyStackingBuff(modifierTable)
				else
					GameMode:ApplyBuff(modifierTable)
				end
			end
		end
	end
end

function modifier_talent_52:GetDebuffAmplifictionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 52) * 0.07
	return bonus 
end

function modifier_talent_52:GetBuffAmplifictionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 52) * 0.07
	return bonus 
end

LinkedModifiers["modifier_talent_52"] = LUA_MODIFIER_MOTION_NONE

modifier_talent_53 = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return true
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
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return 1500
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_talent_53_effect"
    end,
    GetAuraDuration = function(self)
        return 0
    end,
})

modifier_talent_53_effect = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

modifier_talent_53_freeze = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
	CheckState = function(self)
		return {[MODIFIER_STATE_FROZEN] = true}
	end
})

modifier_talent_53_nature_weaken = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_talent_53_effect:OnCreated()
	if not IsServer() then 
		return
	end
	self.hero = self:GetCaster()
	self.holyProc = false
	self.natureProc = false
	self.frostProc = false
end

function modifier_talent_53_effect:GetAdditionalConditionalDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_53_effect")
	if modifier then
		local bonus = 0
		local procdmg = TalentTree:GetHeroTalentLevel(damageTable.attacker, 53) * 0.08
		if damageTable.holydmg and modifier.holyProc then
			bonus = bonus + procdmg
		end
		if damageTable.naturedmg and modifier.natureProc then
			bonus = bonus + procdmg
		end
		if damageTable.frostdmg and modifier.frostProc then
			bonus = bonus + procdmg
		end
		return bonus
	end
end

function modifier_talent_53_effect:OnTakeDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_53")
	if modifier then
		if damageTable.fromtalent == 53 then return end
		if (modifier.holyProc == false and modifier.natureProc == false and modifier.frostProc == false) then
			if damageTable.holydmg then
				modifier.holyProc = true
			end
			if damageTable.naturedmg then
				modifier.natureProc = true
			end
			if damageTable.frostdmg then
				modifier.natureProc = true
			end
		end
		if modifier.holyProc == true then
			if damageTable.frostdmg then
				modifier.holyProc = false
				modifier:ProcHolyFrost(damageTable.victim:GetAbsOrigin())
			end
			if damageTable.naturedmg then
				modifier.holyProc = false
				modifier:ProcHolyNature(damageTable.victim)
			end
		end
		if modifier.frostProc == true then
			if damageTable.frostdmg then
				modifier.frostProc = false
				modifier:ProcHolyFrost(damageTable.victim:GetAbsOrigin())
			end
			if damageTable.naturedmg then
				modifier.frostProc = false
				modifier:ProcFrostNature(damageTable.victim:GetAbsOrigin())
			end
		end
		if modifier.natureProc == true then
			if damageTable.frostdmg then
				modifier.natureProc = false
				modifier:ProcFrostNature(damageTable.victim:GetAbsOrigin())
			end
			if damageTable.holydmg then
				modifier.natureProc = false
				modifier:ProcHolyNature(damageTable.victim)
			end
		end
	end
end

function modifier_talent_53:ProcHolyFrost(hLocation)
	local scale = TalentTree:GetHeroTalentLevel(self.hero, 53) * 0.5
	local damage = Units:GetHeroPrimaryAttribute(self.hero) * scale
	local units = FindUnitsInRadius(self.hero:GetTeamNumber(),
					hLocation,
					nil,
					500,
					DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_BASIC,
					DOTA_UNIT_TARGET_FLAG_NONE,
					FIND_ANY_ORDER,
					false)
	for _, unit in pairs(units) do
		local damageTable = {}
		damageTable.caster = self.hero
		damageTable.target = unit
		damageTable.fromtalent = 53
		damageTable.damage = damage
		damageTable.frostdmg = true
		damageTable.holydmg = true
		damageTable.aoe = true
		GameMode:DamageUnit(damageTable)
		local modifierTable = {}
		modifierTable.caster = self.hero
		modifierTable.target = unit
		modifierTable.ability = nil
		modifierTable.modifier_name = "modifier_talent_53_freeze"
		modifierTable.duration = 2
		GameMode:ApplyDebuff(modifierTable)
	end
end

function modifier_talent_53:ProcHolyNature(hTarget)
	local scale = TalentTree:GetHeroTalentLevel(self.hero, 53) * 0.1
	local scaleHeal = TalentTree:GetHeroTalentLevel(self.hero, 53) * 0.5
	local heal = self.hero:GetHeroPrimaryAttribute(self.hero) * scaleHeal
	local casterLoc = self.hero:GetAbsOrigin()
	local units = FindUnitsInRadius(self.hero:GetTeamNumber(),
					hLocation,
					nil,
					800,
					DOTA_UNIT_TARGET_TEAM_FRIENDLY,
					DOTA_UNIT_TARGET_HERO,
					DOTA_UNIT_TARGET_FLAG_NONE,
					FIND_ANY_ORDER,
					false)
	local modifierTable = {}
	modifierTable.caster = self.hero
	modifierTable.target = hTarget
	modifierTable.ability = nil
	modifierTable.duration = 10
	modifierTable.modifier_name = "modifier_talent_53_nature_weaken"
	GameMode:ApplyDebuff(modifierTable)
	for _, unit in pairs(units) do
		local healTable = {}
		healTable.caster = self.hero
		healTable.target = unit
		healTable.abililty = nil
		healTable.heal = heal
		GameMode:HealUnit(healTable)
	end
end

LinkedModifiers["modifier_talent_53"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_53_effect"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_53_freeze"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["modifier_talent_53_nature_weaken"] = LUA_MODIFIER_MOTION_NONE

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "talents/talents_generic", MotionController)
end

if (IsServer() and not GameMode.TALENT_INT) then
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_10, 'OnTakeDamage'), true)
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_13, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_14, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_19, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_21, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_30_aura_buff, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_32, 'OnTakeDamage'))
	GameMode:RegisterCritDamageEventHandler(Dynamic_Wrap(modifier_talent_33, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_38, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_38_shield, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_39, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_40, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_43, 'OnTakeDamage'))
	GameMode:RegisterPostHealEventHandler(Dynamic_Wrap(modifier_talent_45_shield_applier, 'OnPostHeal'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_45_shield, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_46_effect, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_47, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_48, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_48_effect, 'OnTakeDamage'))
	GameMode:RegisterPostHealEventHandler(Dynamic_Wrap(modifier_talent_48_effect, 'OnPostHeal'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_49, 'OnTakeDamage'))
	GameMode:RegisterPostApplyModifierEventHandler(Dynamic_Wrap(modifier_talent_51, 'OnModifierApplied'))
	GameMode:RegisterPostApplyModifierEventHandler(Dynamic_Wrap(modifier_talent_52, 'OnModifierApplied'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_53_effect, 'OnTakeDamage'))
	GameMode.TALENT_INT = true
end
