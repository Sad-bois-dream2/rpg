LinkLuaModifier("modifier_talent_53", "talents/talent_53", LUA_MODIFIER_MOTION_NONE)

modifier_talent_53 = class({
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

function modifier_talent_53:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_53:OnTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_53")
	if not modifier then
		return 
	end
	local currentMana = damageTable.attacker:GetMana()
	local scale = TalentTree:GetHeroTalentLevel(damageTable.attacker, 53) * 0.05
	local damage = currentMana * scale
	damageTable.damage = damageTable.damage + damage
	return damageTable
end

function modifier_talent_53:GetSpellDamageBonus()
	local maxMana = self.hero:GetMaxMana()
	local scale = TalentTree:GetHeroTalentLevel(self.hero, 53) * 0.001
	local bonus = maxMana * scale / 100
	return bonus
end

function modifier_talent_53:GetHealingCausedPercentBonus()
	local maxMana = self.hero:GetMaxMana()
	local scale = TalentTree:GetHeroTalentLevel(self.hero, 53) * 0.001
	local bonus = maxMana * scale / 100
	return bonus
end

function modifier_talent_53:OnPreHeal(healTable)
	local modifier = healTable.caster:FindModifierByName("modifier_talent_53")
	if not modifier then
		return healTable
	end
	local currentMana = healTable.caster:GetMana()
	local scale = TalentTree:GetHeroTalentLevel(healTable.caster, 53) * 0.05
	local heal = currentMana * scale
	healTable.heal = healTable.heal + heal
	return healTable
end
	
if (IsServer() and not GameMode.TALENT_53_INIT) then
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_53, 'OnTakeDamage'), true)
	GameMode:RegisterPreHealEventHandler(Dynamic_Wrap(modifier_talent_53, 'OnPreHeal'))
	GameMode.TALENT_53_INIT = true
end
