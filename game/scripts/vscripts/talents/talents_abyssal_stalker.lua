LinkLuaModifier("modifier_abyssal_stalker_talent_40", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("abyssal_stalker_ruthless", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("abyssal_stalker_serpent_skin_poison", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_npc_dota_hero_phantom_assassin_talent_40", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_npc_dota_hero_phantom_assassin_talent_41", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_npc_dota_hero_phantom_assassin_talent_42", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE) --Serpent Skin
LinkLuaModifier("modifier_npc_dota_hero_phantom_assassin_talent_43", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE) --Gaia
LinkLuaModifier("modifier_npc_dota_hero_phantom_assassin_talent_44", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_npc_dota_hero_phantom_assassin_talent_45", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE) --Shatter
LinkLuaModifier("modifier_npc_dota_hero_phantom_assassin_talent_46", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE) --Dragon Skin
LinkLuaModifier("modifier_npc_dota_hero_phantom_assassin_talent_47", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE) --Dragon Slayer
LinkLuaModifier("modifier_npc_dota_hero_phantom_assassin_talent_48", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE) --Ruthless
LinkLuaModifier("modifier_npc_dota_hero_phantom_assassin_talent_49", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE) --Phantom Curse
LinkLuaModifier("modifier_npc_dota_hero_phantom_assassin_talent_50", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE) --Fear of Darkness
LinkLuaModifier("modifier_npc_dota_hero_phantom_assassin_talent_51", "talents/talents_abyssal_stalker.lua", LUA_MODIFIER_MOTION_NONE) --Into the Shadows
local LinkedModifiers = {}


modifier_abyssal_stalker_talent_40_agony = modifier_abyssal_stalker_talent_40_agony or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
})

modifier_npc_dota_hero_phantom_assassin_talent_40 = modifier_npc_dota_hero_phantom_assassin_talent_40 or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
})
modifier_npc_dota_hero_phantom_assassin_talent_41 = modifier_npc_dota_hero_phantom_assassin_talent_41 or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
})
modifier_npc_dota_hero_phantom_assassin_talent_42 = modifier_npc_dota_hero_phantom_assassin_talent_42 or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
	DeclareFunctions = function(self) return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
})
modifier_npc_dota_hero_phantom_assassin_talent_43 = modifier_npc_dota_hero_phantom_assassin_talent_43 or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
	DeclareFunctions = function(self) return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
})
modifier_npc_dota_hero_phantom_assassin_talent_44 = modifier_npc_dota_hero_phantom_assassin_talent_44 or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
})
modifier_npc_dota_hero_phantom_assassin_talent_45 = modifier_npc_dota_hero_phantom_assassin_talent_45 or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
	DeclareFunctions = function(self) return {MODIFIER_EVENT_ON_TAKEDAMAGE} end,
})
modifier_npc_dota_hero_phantom_assassin_talent_46 = modifier_npc_dota_hero_phantom_assassin_talent_46 or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
})
modifier_npc_dota_hero_phantom_assassin_talent_47 = modifier_npc_dota_hero_phantom_assassin_talent_47 or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
})
modifier_npc_dota_hero_phantom_assassin_talent_48 = modifier_npc_dota_hero_phantom_assassin_talent_48 or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
})
modifier_npc_dota_hero_phantom_assassin_talent_49 = modifier_npc_dota_hero_phantom_assassin_talent_49 or class({
	IsAura = function(self) return true end,
	GetAuraRadius = function(self) return 800 end,
	GetAuraSearchTeam = function(self) return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchType = function(self) return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end,
	GetModifierAura = function(self) return "abyssal_stalker_phantom_curse" end,
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
})
abyssal_stalker_phantom_curse = abyssal_stalker_phantom_curse or class({
	IsDebuff = function(self) return true end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return true end,
    AllowIllusionDuplicate = function(self) return false end,
})

abyssal_stalker_phantom_curse_effect = abyssal_stalker_phantom_curse_effect or class({
	IsDebuff = function(self) return true end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return true end,
    RemoveOnDeath = function(self) return true end,
    AllowIllusionDuplicate = function(self) return false end,
})

LinkedModifiers["abyssal_stalker_phantom_curse"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_phantom_curse_effect"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_phantom_assassin_talent_50 = modifier_npc_dota_hero_phantom_assassin_talent_50 or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
})

abyssal_stalker_fear_of_darkness = abyssal_stalker_fear_of_darkness or class({
	IsDebuff = function(self) return true end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return true end,
    RemoveOnDeath = function(self) return true end,
    AllowIllusionDuplicate = function(self) return false end,
})

abyssal_stalker_fear_of_darkness_debuff = abyssal_stalker_fear_of_darkness_debuff or class({
	IsDebuff = function(self) return true end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return true end,
    RemoveOnDeath = function(self) return true end,
    AllowIllusionDuplicate = function(self) return false end,
})

LinkedModifiers["abyssal_stalker_fear_of_darkness"] = LUA_MODIFIER_MOTION_NONE
LinkedModifiers["abyssal_stalker_fear_of_darkness_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_phantom_assassin_talent_51 = modifier_npc_dota_hero_phantom_assassin_talent_51 or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
})

abyssal_stalker_serpent_skin_poison = abyssal_stalker_serpent_skin_poison or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
})

abyssal_stalker_ruthless = abyssal_stalker_ruthless or class({
	IsDebuff = function(self) return false end,
    IsHidden = function(self) return false end,
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    AllowIllusionDuplicate = function(self) return false end,
	DeclareFunctions = function(self) return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
})	


function modifier_npc_dota_hero_phantom_assassin_talent_42:OnTakeDamage(event)
	if not IsServer() then return end
	if event.unit == self:GetParent() and event.attacker ~= self:GetParent() and not event.attacker:IsNull() then
		local chance = 30
		if chance > RandomFloat(1, 100) then
			local modifierTable = {}
			modifierTable.caster = self:GetCaster()
			modifierTable.target = event.attacker
			modifierTable.modifier_name = "abyssal_stalker_serpent_skin_poison"
			modifierTable.ability = nil
			modifierTable.duration = 3
			GameMode:ApplyDebuff(modifierTable)
		end
	end
end

function abyssal_stalker_serpent_skin_poison:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.5)
end

function abyssal_stalker_serpent_skin_poison:OnIntervalThink()
	if not IsServer() then return end
	local damageTable = {}
	damageTable.caster = self:GetCaster()
	damageTable.target = self:GetParent()
	damageTable.ability = nil
	damageTable.damage = 10000
	damageTable.naturedamage = true
	GameMode:DamageUnit(damageTable)
end
	
function modifier_npc_dota_hero_phantom_assassin_talent_43:OnTakeDamage(event)
	if not IsServer() then return end
	if event.unit == self:GetParent() and event.attacker ~= self:GetParent() and not event.attacker:IsNull() then
		local chance = 10
		if chance > RandomFloat(1, 100) then
			local modifierTable = {}
			modifierTable.caster = self:GetCaster()
			modifierTable.target = event.attacker
			modifierTable.modifier_name = "modifier_stunned"
			modifierTable.ability = nil
			modifierTable.duration = 3
			GameMode:ApplyDebuff(modifierTable)
		end
	end
end

function modifier_npc_dota_hero_phantom_assassin_talent_45:OnTakeDamage(event)
	if not IsServer() then return end
	if event.unit ~= self:GetCaster() and event.attacker == self:GetCaster() and event.unit:GetHealthPercent() < 15 and event.unit:IsFrozen() then
		local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
					  self:GetCaster():GetAbsOrigin(),
					  nil,
					  350,
					  DOTA_UNIT_TARGET_TEAM_ENEMY,
					  DOTA_UNIT_TARGET_ALL,
					  DOTA_UNIT_TARGET_FLAG_NONE,
					  FIND_ANY_ORDER,
					  false)
		for k, unit in pairs(units) do
			local damageTable = {}
			damageTable.caster = self:GetCaster()
			damageTable.target = unit
			damageTable.ability = nil
			damageTable.damage = 10000
			damageTable.voiddamage = true
			GameMode:DamageUnit(damageTable)
		end
	end
end

function modifier_npc_dota_hero_phantom_assassin_talent_48:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(3)
end
function modifier_npc_dota_hero_phantom_assassin_talent_48:OnIntervalThink()
	if not IsServer() then return end
	local modifierTable = {}
	modifierTable.caster = self:GetCaster()
	modifierTable.target = event.attacker
	modifierTable.modifier_name = "abyssal_stalker_ruthless"
	modifierTable.ability = nil
	modifierTable.duration = -1
	GameMode:ApplyDebuff(modifierTable)
end
function abyssal_stalker_ruthless:OnTakeDamage(event)
	if not IsServer() then return end
	if event.unit ~= self:GetParent() and event.attacker == self:GetParent() and not event.unit:IsNull() then
		local modifierTable = {}
		modifierTable.caster = self:GetCaster()
		modifierTable.target = event.unit
		modifierTable.modifier_name = "modifier_stunned"
		modifierTable.ability = nil
		modifierTable.duration = 1
		GameMode:ApplyDebuff(modifierTable)
		self:Destroy()
	end
end

function abyssal_stalker_phantom_curse:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(2)
end

function abyssal_stalker_phantom_curse:OnIntervalThink()
	if not IsServer() then return end
	local modifierTable = {}
	modifierTable.caster = self:GetCaster()
	modifierTable.target = self:GetParent()
	modifierTable.ability = nil
	modifierTable.modifier_name = "abyssal_stalker_phantom_curse_effect"
	modifierTable.duration = 1
	GameMode:ApplyDebuff(modifierTable)
end

function abyssal_stalker_phantom_curse_effect:CheckStates()
	return {[MODIFIER_STATE_SILENCED] = true,}
end

function modifier_npc_dota_hero_phantom_assassin_talent_47:GetFireProtectionBonus() return 1.0 end
function modifier_npc_dota_hero_phantom_assassin_talent_47:GetFrostProtectionBonus() return 1.0 end
function modifier_npc_dota_hero_phantom_assassin_talent_47:GetEarthProtectionBonus() return 1.0 end
function modifier_npc_dota_hero_phantom_assassin_talent_47:GetVoidProtectionBonus() return 1.0 end
function modifier_npc_dota_hero_phantom_assassin_talent_47:GetHolyProtectionBonus() return 1.0 end
function modifier_npc_dota_hero_phantom_assassin_talent_47:GetNatureProtectionBonus() return 1.0 end
function modifier_npc_dota_hero_phantom_assassin_talent_47:GetInfernoProtectionBonus() return 1.0 end

function modifier_npc_dota_hero_phantom_assassin_talent_50:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_npc_dota_hero_phantom_assassin_talent_50:OnTakeDamage(event)
	if not IsServer() then return end
	if event.unit ~= self:GetCaster() and event.attacker == self:GetCaster() then
		local chance = 15
		if chance > RandomFloat(1, 100) then
			local modifierTable = {}
			modifierTable.caster = self:GetCaster()
			modifierTable.target = event.unit
			modifierTable.ability = nil
			modifierTable.modifier_name = "abyssal_stalker_fear_of_darkness"
			modifierTable.duration = 1.5
			GameMode:ApplyDebuff(modifierTable)
		end
	end
end

function abyssal_stalker_fear_of_darkness:OnDestroy()
	if not IsServer() then return end
	local modifierTable = {}
	modifierTable.caster = self:GetCaster()
	modifierTable.target = self:GetParent()
	modifierTable.ability = nil
	modifierTable.modifier_name = "abyssal_stalker_fear_of_darkness_debuff"
	modifierTable.duration = 15
	GameMode:ApplyDebuff(modifierTable)
end

function abyssal_stalker_fear_of_darkness_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE} end
function abyssal_stalker_fear_of_darkness_debuff:GetBonusVisionPercentage() return -50 end





