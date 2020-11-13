--Prob need better logic and need particles

LinkLuaModifier("modifier_talent_54", "talents/talent_54", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_54_effect", "talents/talent_54", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_54_freeze", "talents/talent_54", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_54_punish", "talents/talent_54", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_54_blizzard", "talents/talent_54", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_54_blizzard_effect", "talents/talent_54", LUA_MODIFIER_MOTION_NONE)

modifier_talent_54 = class({
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
    IsAura = function(self)
        return true
    end,
    GetModifierAura = function(self)
        return "modifier_talent_54_effect"
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_BASIC
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraDuration = function(self)
        return 0
    end,
    GetAuraRadius = function(self)
        return 900
    end,
	GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

modifier_talent_54_effect = class({
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
    end
})

modifier_talent_54_freeze = class({
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
	CheckStates = function(self)
		return {[MODIFIER_STATE_FROZEN] = true}
	end
})

modifier_talent_54_punish = class({
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
    end
})

modifier_talent_54_blizzard = class({
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
    IsAura = function(self)
        return true
    end,
    GetModifierAura = function(self)
        return "modifier_talent_54_blizzard_effect"
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_BASIC
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraDuration = function(self)
        return 0
    end,
    GetAuraRadius = function(self)
        return 600
    end,
})

modifier_talent_54_blizzard_effect = class({
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
    end
})

function modifier_talent_54:OnCreated()
	if not IsServer() then
		return
	end
end

function modifier_talent_54_effect:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
	self.heroTeam = self.hero:GetTeamNumber()
	self.frostProc = false
	self.holyProc = false
	self.natureProc = false
	self.holyFrostCd = false
	self.holyNatureCd = false
	self.frostNatureCd = false
end

function modifier_talent_54_effect:OnPostTakeDamage(damageTable)
	local modifier1 = damageTable.attacker:FindModifierByName("modifier_talent_54")
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_54_effect")
	if not (modifier1 and modifier) then
		return damageTable
	end
	if damageTable.fromtalent == 54 then
		return damageTable
	end
	if not (modifier.holyProc or modifier.frostProc or modifier.natureProc) then 
		if damageTable.frostdmg then
			modifier.frostProc = true
		elseif damageTable.holydmg then
			modifier.holyProc = true
		elseif damageTable.naturedmg then
			modifier.natureProc = true
		end
		return damageTable
	end
	if not modifier.holyFrostCd then
		if (damageTable.frostdmg and damageTable.holydmg) or (damageTable.frostdmg and modifier.holyProc) or (damageTable.holydmg and modifier.frostProc) then
			modifier:ProcHolyFrost(damageTable.victim)
			modifier.holyProc = false
			modifier.frostProc = false
			modifier.holyFrostCd = true
			Timers:CreateTimer(5, function()
				modifier.holyFrostCd = false
			end)
		end
	end
	if not modifier.frostNatureCd then
		if (damageTable.frostdmg and damageTable.naturedmg) or (damageTable.frostdmg and modifier.natureProc) or (damageTable.naturedmg and modifier.frostProc) then
			modifier:ProcFrostNature(damageTable.victim)
			modifier.frostProc = false
			modifier.natureProc = false
			modifier.frostNatureCd = true
			Timers:CreateTimer(5, function()
				modifier.frostNatureCd = false
			end)
		end
	end
	if not modifier.holyNatureCd then
		if (damageTable.holydmg and damageTable.naturedmg) or (damageTable.holydmg and modifier.natureProc) or (damageTable.naturedmg and modifier.holyProc) then
			modifier:ProcHolyNature(damageTable.victim)
			modifier.holyProc = false
			modifier.natureProc = false
			modifier.holyNatureCd = true
			Timers:CreateTimer(5, function()
				modifier.holyNatureCd = false
			end)
		end
	end
	return damageTable
end

function modifier_talent_54_effect:ProcHolyFrost(hTarget)
	local enemies = FindUnitsInRadius(self.heroTeam,
            hTarget:GetAbsOrigin(),
            nil,
            500,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
	if #enemies > 0 then
		local scale = TalentTree:GetHeroTalentLevel(self.hero, 54) * 1.25
		local damage = Units:GetHeroPrimaryAttribute(self.hero) * scale
		for _, unit in pairs(enemies) do
			local damageTable = {
				caster = self.hero,
				target = unit,
				fromtalent = 54,
				damage = damage,
				frostdmg = true,
				holydmg = true,
				aoe = true
			}
			GameMode:DamageUnit(damageTable)
			local modifierTable = {
				caster = self.hero,
				target = unit,
				ability = nil,
				modifier_name = "modifier_talent_54_freeze",
				duration = 1
			}
			GameMode:ApplyDebuff(modifierTable)
		end
	end
end

function modifier_talent_54_effect:ProcHolyNature(hTarget)
	local modifierTable = {
		caster = self.hero,
		target = hTarget,
		ability = nil,
		modifier_name = "modifier_talent_54_punish",
		duration = 10
	}
	GameMode:ApplyDebuff(modifierTable)
end

function modifier_talent_54_effect:ProcFrostNature(hTarget)
	CreateModifierThinker( self.hero, nil, "modifier_talent_54_blizzard", {duration = 3}, hTarget:GetAbsOrigin(), self.hero:GetTeamNumber(), false)
end

function modifier_talent_54_freeze:OnCreated()
	if not IsServer() then
		return
	end
end

function modifier_talent_54_punish:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
end

function modifier_talent_54_punish:GetAdditionalConditionalDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_54_punish")
	local bonus = 0
	if modifier then
		bonus = bonus + TalentTree:GetHeroTalentLevel(modifier.hero, 54) * 0.05
	end
	return bonus
end

function modifier_talent_54_blizzard:OnCreated()
	if not IsServer() then
		return
	end
end

function modifier_talent_54_blizzard_effect:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
	self:StartIntervalThink(1)
end

function modifier_talent_54_blizzard_effect:OnIntervalThink()
	local scale = TalentTree:GetHeroTalentLevel(self.hero, 54) * 1.5
	local damage = Units:GetHeroPrimaryAttribute(self.hero) * scale / 3
	local damageTable = {
		caster = self.hero,
		target = self:GetParent(),
		fromtalent = 54,
		damage = damage,
		frostdmg = true,
		naturedmg = true,
		aoe = true
	}
	GameMode:DamageUnit(damageTable)
end

function modifier_talent_54_blizzard_effect:GetMoveSpeedPercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 54) * 0.05
	return bonus
end

function modifier_talent_54_blizzard_effect:GetAttackSpeedPercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 54) * 0.05
	return bonus
end

function modifier_talent_54_blizzard_effect:GetSpellHastePercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 54) * 0.05
	return bonus
end

if (IsServer() and not GameMode.TALENT_54_INIT) then
	GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_talent_54_effect, 'OnPostTakeDamage'))
	GameMode.TALENT_54_INIT = true
end
