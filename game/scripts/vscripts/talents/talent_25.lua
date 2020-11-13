LinkLuaModifier("modifier_talent_25", "talents/talent_25", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_25_buff", "talents/talent_25", LUA_MODIFIER_MOTION_NONE)

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
    end,
	DeclareFunctions = function(self)
		return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
	end
})

modifier_talent_25_buff = class({
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

function modifier_talent_25:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_25:GetCooldownReductionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
	return bonus
end

function modifier_talent_25:OnAbilityFullyCast(kv)
	if not IsServer() then
		return
	end
	if kv.unit ~= self.hero then
		return 
	end
	if kv.ability:GetCooldown(kv.ability:GetLevel()) >= 60 then
		local modifierTable = {
			caster = kv.unit,
			target = kv.unit,
			ability = nil,
			modifier_name = "modifier_talent_25_buff",
			duration = 10,
			stacks = 1,
			max_stacks = 99999
		}
		GameMode:ApplyStackingBuff(modifierTable)
		Timers:CreateTimer(10, function()
			if kv.unit:HasModifier("modifier_talent_25_buff") then
				if kv.unit:GetModifierStackCount("modifier_talent_25_buff", kv.unit) > 0 then
					kv.unit:FindModifierByName("modifier_talent_25_buff"):DecrementStackCount()
				else
					kv.unit:FindModifierByName("modifier_talent_25_buff"):Destroy()
				end
			end
		end)
	end
end

function modifier_talent_25_buff:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_25_buff:GetSpellDamageBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.12 * self:GetStackCount()
	return bonus
end

function modifier_talent_25_buff:GetHealingCausedPercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.12 * self:GetStackCount()
	return bonus
end
