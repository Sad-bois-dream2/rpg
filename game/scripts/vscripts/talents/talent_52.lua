LinkLuaModifier("modifier_talent_52", "talents/talent_52", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_52_frost_effect", "talents/talent_52", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_52_nature_effect", "talents/talent_52", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_52_holy_effect", "talents/talent_52", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_52_chill", "talents/talent_52", LUA_MODIFIER_MOTION_NONE)

modifier_talent_52 = class({
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

modifier_talent_52_frost_effect = class({
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
    end
})

modifier_talent_52_nature_effect = class({
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
    end
})

modifier_talent_52_holy_effect = class({
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
    end
})

modifier_talent_52_chill = class({
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

function modifier_talent_52:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
	self:StartIntervalThink(8)
	self.nature = true
	self.holy = false
	self.frost = false
	local modifierTable = {
		caster = self.hero,
		target = self.hero,
		ability = nil,
		modifier_name = "modifier_talent_52_nature_effect",
		duration = 8
	}
	GameMode:ApplyBuff(modifierTable)
end

function modifier_talent_52:OnIntervalThink()
	if not IsServer() then
		return
	end
	if self.nature == true then
		self.nature = false
		self.holy = true
		local modifierTable = {
		caster = self.hero,
		target = self.hero,
		ability = nil,
		modifier_name = "modifier_talent_52_holy_effect",
		duration = 8
	}
		GameMode:ApplyBuff(modifierTable)
	elseif self.holy == true then
		self.holy = false
		self.frost = true
		local modifierTable = {
		caster = self.hero,
		target = self.hero,
		ability = nil,
		modifier_name = "modifier_talent_52_frost_effect",
		duration = 8
	}
		GameMode:ApplyBuff(modifierTable)
	elseif self.frost == true then
		self.nature = true
		self.frost = false
		local modifierTable = {
		caster = self.hero,
		target = self.hero,
		ability = nil,
		modifier_name = "modifier_talent_52_nature_effect",
		duration = 8
	}
		GameMode:ApplyBuff(modifierTable)
	end
end

function modifier_talent_52_nature_effect:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_52_frost_effect:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_52_holy_effect:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_52_frost_effect:GetFrostDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 52) * 0.1
	return bonus
end

function modifier_talent_52_nature_effect:GetNatrueDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 52) * 0.1
	return bonus
end

function modifier_talent_52_holy_effect:GetHolyDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 52) * 0.1
	return bonus
end

function modifier_talent_52_frost_effect:OnTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_52_frost_effect")
	if not modifier then
		return
	end
	if damageTable.frostdmg then
		local modifierTable = {
			caster = damageTable.attacker,
			target = damageTable.victim,
			ability = nil,
			modifier_name = "modifier_talent_52_chill",
			duration = 3
		}
		GameMode:ApplyDebuff(modifierTable)
	end
end

function modifier_talent_52_chill:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
end

function modifier_talent_52_chill:GetMoveSpeedPercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 52) * 0.1
	return bonus
end

function modifier_talent_52_chill:GetSpellHastePercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 52) * 0.1
	return bonus
end

function modifier_talent_52_chill:GetAttackSpeedPercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 52) * 0.1
	return bonus
end

function modifier_talent_52_nature_effect:OnPostTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_52_nature_effect")
	if not modifier then
		return
	end
	if damageTable.naturedmg then
		local scale = TalentTree:GetHeroTalentLevel(damageTable.attacker, 52) * 0.1
		local healamount = scale * damageTable.damage
		local healTable = {
			caster = damageTable.attacker,
			target = damageTable.attacker,
			ability = nil,
			heal = healamount
		}
		GameMode:HealUnit(healTable)	
	end
end

function modifier_talent_52_holy_effect:OnTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_52_holy_effect")
	if not modifier then
		return
	end
	local chance = TalentTree:GetHeroTalentLevel(damageTable.attacker, 52) * 5 + 5
	local proc = RollPercentage(chance)
	if proc then
		damageTable.puredmg = true
	end
end

if (IsServer() and not GameMode.TALENT_52_INIT) then
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_52_frost_effect, 'OnTakeDamage'))
	GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_talent_52_nature_effect, 'OnPostTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_52_holy_effect, 'OnTakeDamage'))
	GameMode.TALENT_52_INIT = true
end
