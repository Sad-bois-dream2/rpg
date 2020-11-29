LinkLuaModifier("modifier_talent_44", "talents/talent_44", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_44_first_amp", "talents/talent_44", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_44_second_amp", "talents/talent_44", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_44_third_amp", "talents/talent_44", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_44_fourth_amp", "talents/talent_44", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_44_fifth_amp", "talents/talent_44", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_44_sixth_amp", "talents/talent_44", LUA_MODIFIER_MOTION_NONE)

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
    end
})

modifier_talent_44_first_amp = class({
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

modifier_talent_44_second_amp = class({
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

modifier_talent_44_third_amp = class({
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

modifier_talent_44_fourth_amp = class({
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

modifier_talent_44_fifth_amp = class({
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

modifier_talent_44_sixth_amp = class({
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

function modifier_talent_44:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
	self:StartIntervalThink(10)
end

function modifier_talent_44:OnIntervalThink()
	if not IsServer() then
		return
	end
	self.firstAbility = self.hero:GetAbilityByIndex(0)
	self.secondAbility = self.hero:GetAbilityByIndex(1)
	self.thirdAbility = self.hero:GetAbilityByIndex(2)
	self.fourthAbility = self.hero:GetAbilityByIndex(3)
	self.fifthAbility = self.hero:GetAbilityByIndex(4)
	self.sixthAbility = self.hero:GetAbilityByIndex(5)
end

function modifier_talent_44:OnPostTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_44")
	if not modifier then
		return
	end
	if not damageTable.ability or damageTable.damage == 0 then
		return
	end
	local modifier_name = nil
	if damageTable.ability == modifier.firstAbility then
		modifier_name = "modifier_talent_44_first_amp"
	elseif damageTable.ability == modifier.secondAbility then
		modifier_name = "modifier_talent_44_second_amp"
	elseif damageTable.ability == modifier.thirdAbility then
		modifier_name = "modifier_talent_44_third_amp"
	elseif damageTable.ability == modifier.fourthAbility then
		modifier_name = "modifier_talent_44_fourth_amp"
	elseif damageTable.ability == modifier.fifthAbility then
		modifier_name = "modifier_talent_44_fifth_amp"
	elseif damageTable.ability == modifier.sixthAbility then
		modifier_name = "modifier_talent_44_sixth_amp"
	end
	local modifierTable = {
		caster = damageTable.attacker,
		target = damageTable.victim,
		ability = damageTable.ability,
		modifier_name = modifier_name,
		duration = 5,
		stacks = 1,
		max_stacks = 5
	}
	GameMode:ApplyNPCBasedStackingDebuff(modifierTable)
end

function modifier_talent_44_first_amp:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
end

function modifier_talent_44_second_amp:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
end

function modifier_talent_44_third_amp:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
end

function modifier_talent_44_fourth_amp:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
end

function modifier_talent_44_fifth_amp:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
end

function modifier_talent_44_sixth_amp:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
end


function modifier_talent_44_first_amp:GetAdditionalConditionalDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_44_first_amp")
	local bonus = 0
	if modifier then
		if not damageTable.ability then
			return bonus
		end
		if damageTable.ability == modifier:GetAbility() and damageTable.attacker == modifier:GetCaster() then
			bonus = bonus + TalentTree:GetHeroTalentLevel(modifier.hero, 44) * 0.03 * modifier:GetStackCount()
		end
	end
	return bonus
end

function modifier_talent_44_second_amp:GetAdditionalConditionalDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_44_second_amp")
	local bonus = 0
	if modifier then
		if not damageTable.ability then
			return bonus
		end
		if damageTable.ability == modifier:GetAbility() and damageTable.attacker == modifier:GetCaster() then
			bonus = bonus + TalentTree:GetHeroTalentLevel(modifier.hero, 44) * 0.03 * modifier:GetStackCount()
		end
	end
	return bonus
end

function modifier_talent_44_third_amp:GetAdditionalConditionalDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_44_third_amp")
	local bonus = 0
	if modifier then
		if not damageTable.ability then
			return bonus
		end
		if damageTable.ability == modifier:GetAbility() and damageTable.attacker == modifier:GetCaster() then
			bonus = bonus + TalentTree:GetHeroTalentLevel(modifier.hero, 44) * 0.03 * modifier:GetStackCount()
		end
	end
	return bonus
end

function modifier_talent_44_fourth_amp:GetAdditionalConditionalDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_44_fourth_amp")
	local bonus = 0
	if modifier then
		if not damageTable.ability then
			return bonus
		end
		if damageTable.ability == modifier:GetAbility() and damageTable.attacker == modifier:GetCaster() then
			bonus = bonus + TalentTree:GetHeroTalentLevel(modifier.hero, 44) * 0.03 * modifier:GetStackCount()
		end
	end
	return bonus
end

function modifier_talent_44_fifth_amp:GetAdditionalConditionalDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_44_fifth_amp")
	local bonus = 0
	if modifier then
		if not damageTable.ability then
			return bonus
		end
		if damageTable.ability == modifier:GetAbility() and damageTable.attacker == modifier:GetCaster() then
			bonus = bonus + TalentTree:GetHeroTalentLevel(modifier.hero, 44) * 0.03 * modifier:GetStackCount()
		end
	end
	return bonus
end

function modifier_talent_44_sixth_amp:GetAdditionalConditionalDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_44_sixth_amp")
	local bonus = 0
	if modifier then
		if not damageTable.ability then
			return bonus
		end
		if damageTable.ability == modifier:GetAbility() and damageTable.attacker == modifier:GetCaster() then
			bonus = bonus + TalentTree:GetHeroTalentLevel(modifier.hero, 44) * 0.03 * modifier:GetStackCount()
		end
	end
	return bonus
end

if (IsServer() and not GameMode.TALENT_44_INIT) then
	GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_talent_44, 'OnPostTakeDamage'))
	GameMode.TALENT_44_INIT = true
end
