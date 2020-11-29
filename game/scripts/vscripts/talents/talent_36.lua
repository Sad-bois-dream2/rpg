LinkLuaModifier("modifier_talent_36", "talents/talent_36", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_36_frost_weaken", "talents/talent_36", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_36_holy_weaken", "talents/talent_36", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_36_nature_weaken", "talents/talent_36", LUA_MODIFIER_MOTION_NONE)

modifier_talent_36 = class({
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

modifier_talent_36_frost_weaken = class({
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

modifier_talent_36_holy_weaken = class({
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

modifier_talent_36_nature_weaken = class({
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

function modifier_talent_36:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
end

function modifier_talent_36:OnPostTakeDamage(damageTable)
	local modifier = damageTable.attacker:FindModifierByName("modifier_talent_36")
	if not modifier then 
		return
	end
	local modifiers = {}
	if damageTable.frostdmg then
		table.insert(modifiers, "modifier_talent_36_frost_weaken")
	end
	if damageTable.holydmg then
		table.insert(modifiers, "modifier_talent_36_holy_weaken")
	end
	if damageTable.naturedmg then
		table.insert(modifiers, "modifier_talent_36_nature_weaken")
	end	
	if #modifiers > 0 then
			for i = 1, #modifiers do
			local modifierTable = {
				caster = damageTable.attacker,
				target = damageTable.victim,
				ability = nil,
				modifier_name = modifiers[i],
				duration = 5,
				stacks = 1,
				max_stacks = 5
			}
			GameMode:ApplyNPCBasedStackingDebuff(modifierTable)
		end
	end
	return damageTable
end

function modifier_talent_36_frost_weaken:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
end

function modifier_talent_36_holy_weaken:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
end

function modifier_talent_36_nature_weaken:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetCaster()
end

function modifier_talent_36:GetFrostProtectionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 36) * 0.01
	return bonus
end

function modifier_talent_36:GetHolyProtectionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 36) * 0.01
	return bonus
end

function modifier_talent_36:GetNatureProtectionBonus()
	local bonus = TalentTree:GetHeroTalentLevel(self.hero, 36) * 0.01
	return bonus
end

if (IsServer() and not GameMode.TALENT_36_INIT) then
	GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_talent_36, 'OnPostTakeDamage'))
	GameMode.TALENT_36_INIT = true
end
