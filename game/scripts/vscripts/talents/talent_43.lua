LinkLuaModifier("modifier_talent_43", "talents/talent_43", LUA_MODIFIER_MOTION_NONE)

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
    end
})

function modifier_talent_43:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
	self.elementCount = 0
end

function modifier_talent_43:OnTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_43")
	if not modifier then
		return damageTable
	end
	local bonus = TalentTree:GetHeroTalentLevel(damageTable.attacker, 43) * 0.3
	if damageTable.frostdmg then
		modifier.elementCount = modifier.elementCount + 1
	end
	if damageTable.holydmg then
		modifier.elementCount = modifier.elementCount + 1
	end
	if damageTable.naturedmg then
		modifier.elementCount = modifier.elementCount + 1
	end
	if damageTable.voiddmg then
		modifier.elementCount = modifier.elementCount + 1
	end
	if damageTable.infernodmg then
		modifier.elementCount = modifier.elementCount + 1
	end
	if damageTable.firedmg then
		modifier.elementCount = modifier.elementCount + 1
	end
	if damageTable.earthdmg then
		modifier.elementCount = modifier.elementCount + 1
	end
	if (modifier.elementCount > 1 and damageTable.crit > 1) then
		modifier.elementCount = 0
		damageTable.crit = damageTable.crit + bonus
		return damageTable
	else
		modifier.elementCount = 0
		return damageTable
	end
end

if (IsServer() and not GameMode.TALENT_43_INIT) then
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_43, 'OnTakeDamage'))
	GameMode.TALENT_43_INIT = true
end
