LinkLuaModifier("modifier_talent_17", "talents/talent_17", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_17_spellhaste", "talents/talent_17", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_17_spelldamage", "talents/talent_17", LUA_MODIFIER_MOTION_NONE)

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
    end,
	DeclareFunctions = function(self)
		return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
	end
})

modifier_talent_17_spellhaste = class({
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

modifier_talent_17_spelldamage = class({
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

function modifier_talent_17:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
	self:OnIntervalThink()
	self:StartIntervalThink(10)
end

function modifier_talent_17:OnIntervalThink()
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

function modifier_talent_17:OnAbilityFullyCast(kv)
	if not IsServer() then
		return
	end
	if kv.unit ~= self.hero then
		return
	end
	if kv.ability == self.firstAbility or kv.ability == self.thirdAbility or kv.ability == fifthAbility then
		local modifierTable = {
			caster = kv.unit,
			target = kv.unit,
			ability = nil,
			modifier_name = "modifier_talent_17_spellhaste",
			duration = 6,
			max_stacks = 5,
			stacks = 1
		}
		GameMode:ApplyStackingBuff(modifierTable)
		Timers:CreateTimer(6, function()
			if kv.unit:HasModifier("modifier_talent_17_spellhaste") then
				if kv.unit:GetModifierStackCount("modifier_talent_17_spellhaste", kv.unit) > 0 then
					kv.unit:FindModifierByName("modifier_talent_17_spellhaste"):DecrementStackCount()
				else
					kv.unit:FindModifierByName("modifier_talent_17_spellhaste"):Destroy()
				end
			end
		end)
	elseif kv.ability == self.secondAbility or kv.ability == self.fourthAbility or kv.ability == sixthAbility then
		local modifierTable = {
			caster = kv.unit,
			target = kv.unit,
			ability = nil,
			modifier_name = "modifier_talent_17_spelldamage",
			duration = 6,
			max_stacks = 5,
			stacks = 1
		}
		GameMode:ApplyStackingBuff(modifierTable)
		Timers:CreateTimer(6, function()
			if kv.unit:HasModifier("modifier_talent_17_spelldamage") then
				if kv.unit:GetModifierStackCount("modifier_talent_17_spelldamage", kv.unit) > 0 then
					kv.unit:FindModifierByName("modifier_talent_17_spelldamage"):DecrementStackCount()
				else
					kv.unit:FindModifierByName("modifier_talent_17_spelldamage"):Destroy()
				end
			end
		end)
	end
end

function modifier_talent_17_spellhaste:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_17_spelldamage:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_17_spellhaste:GetSpellHasteBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 17) * 15 * self:GetStackCount()
	return bonus
end

function modifier_talent_17_spelldamage:GetSpellDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 17) * 0.02 * self:GetStackCount()
	return bonus
end
