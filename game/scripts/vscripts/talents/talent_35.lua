LinkLuaModifier("modifier_talent_35", "talents/talent_35", LUA_MODIFIER_MOTION_NONE)

modifier_talent_35 = class({
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

function modifier_talent_35:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_35:GetAdditionalConditionalDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_35")
	local bonus = 0
	if not modifier then
		return bonus
	end
	if not damageTable.ability then
		return bonus
	end
	if damageTable.ability.IsRequireCastbar and damageTable.ability:IsRequireCastbar() == true then
		bonus = bonus + TalentTree:GetHeroTalentLevel(damageTable.attacker, 35) * 0.1
	end
	return bonus
end

function modifier_talent_35:GetSpellHastePercentBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 35) * 0.2
	return bonus
end
