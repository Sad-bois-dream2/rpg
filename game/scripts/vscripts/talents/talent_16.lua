LinkLuaModifier("modifier_talent_16", "talents/talent_16", LUA_MODIFIER_MOTION_NONE)

modifier_talent_16 = class({
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

function modifier_talent_16:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
	self:OnIntervalThink()
	self:StartIntervalThink(10)
end

function modifier_talent_16:OnIntervalThink()
	if not IsServer() then 
		return
	end
	self.secondAbility = self.hero:GetAbilityByIndex(1)	
	self.heroTeam = self.hero:GetTeamNumber()
end

function modifier_talent_16:OnAbilityFullyCast(kv)
	if (not IsServer()) then
		return
	end
	if (kv.unit ~= self.hero) then
		return
	end
	if (kv.ability ~= self.secondAbility) then
		return
	end
	local enemies = FindUnitsInRadius(self.heroTeam,
            kv.unit:GetAbsOrigin(),
            nil,
            900,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
	if #enemies > 0 then
		for i = 1, 3 do
			local enemy = enemies[RandomInt(1, #enemies)]
			--here is a projectile particle, pls dont ignore this meme
			local scale = TalentTree:GetHeroTalentLevel(self.hero, 16) * 0.6 + 0.5
			local damage = Units:GetHeroPrimaryAttribute(self.hero) * scale
			local damageTable = { 
				caster = kv.unit,
				target = enemy,
				damage = damage,
				fromtalent = 16,
				frostdmg = true,
				single = true,
				aoe = true
			}
			GameMode:DamageUnit(damageTable)
		end
	end
end
