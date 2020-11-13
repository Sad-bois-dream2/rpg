LinkLuaModifier("modifier_talent_45", "talents/talent_45", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_45_mana_shield", "talents/talent_45", LUA_MODIFIER_MOTION_NONE)

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
    end
})

modifier_talent_45_mana_shield = class({
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
    end
})

function modifier_talent_45:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_45:OnTakeDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_45")
	if not modifier then
		return
	end
	local currentHp = damageTable.victim:GetHealth()
	local currentMp = damageTable.victim:GetMana()
	local maxMp = damageTable.victim:GetMaxMana()
	local mpPerc = currentMp / maxMp
	local hpPerc = currentHp / damageTable.victim:GetMaxHealth()
	local mpRestore = 0.5 * maxMp
	local hpRestore = 0.5 * damageTable.victim:GetMaxHealth()
	if modifier.cd == true then
		return damageTable
	end
	if damageTable.damage >= currentHp then
		damageTable.damage = 0
		if mpPerc < 0.5 then
			damageTable.victim:SetMana(mpRestore)
		end
		if hpPerc < 0.5 then
			damageTable.victim:SetHealth(hpRestore)
		end
		local modifierTable = {
			caster = damageTable.victim,
			target = damageTable.victim,
			ability = nil,
			modifier_name = "modifier_talent_45_mana_shield",
			duration = 5 + TalentTree:GetHeroTalentLevel(damageTable.victim, 45) * 2
		}
		GameMode:ApplyBuff(modifierTable)
		modifier.cd = true
		Timers:CreateTimer(100, function()
			modifier.cd = false
		end)
	end
	return damageTable
end

function modifier_talent_45_mana_shield:OnCreated()
	if not IsServer() then
		return
	end
end

function modifier_talent_45_mana_shield:OnTakeDamage(damageTable)
	local modifier = damageTable.victim:FindModifierByName("modifier_talent_45_mana_shield")
	if not modifier then
		return
	end
	local currentMp = damageTable.victim:GetMana()
	local absorbAmount = damageTable.damage * 0.6
	local manacost = absorbAmount / 6
	if manacost <= currentMp then
		damageTable.damage = damageTable.damage - absorbAmount
		damageTable.victim:SetMana(currentMp - manacost)
	else
		damageTable.damage = damageTable.damage - currentMp * 6
		damageTable.victim:SetMana(0)
		modifier:Destroy()
	end
end

if (IsServer() and not GameMode.TALENT_45_INIT) then
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_45, 'OnTakeDamage'))
	GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_45_mana_shield, 'OnTakeDamage'))
	GameMode.TALENT_45_INIT = true
end
