LinkLuaModifier("modifier_talent_18", "talents/talent_18", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_18_cloud", "talents/talent_18", LUA_MODIFIER_MOTION_NONE)

modifier_talent_18 = class({
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

modifier_talent_18_cloud = class({
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
    end,
	DeclareFunctions = function(self)
		return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
	end,
	GetEffectName = function(self)
		return "particles/units/heroes/hero_razor/razor_rain_storm_cloud.vpcf"
	end
})

function modifier_talent_18:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
	self:OnIntervalThink()
	self:StartIntervalThink(10)
	self.cd = false
end

function modifier_talent_18:OnIntervalThink()
	if not IsServer() then 
		return
	end
	self.ulti = self.hero:GetAbilityByIndex(5)
end

function modifier_talent_18:OnAbilityFullyCast(kv)
	if (not IsServer()) then
		return
	end
	if (kv.unit ~= self:GetParent()) then
		return
	end
	if (kv.ability ~= self.ulti) then
		return
	end
	if self.cd == false then
		local modifierTable = {
			caster = self.hero,
			target = self.hero,
			ability = nil,
			modifier_name = "modifier_talent_18_cloud",
			duration = 15
		}
		GameMode:ApplyBuff(modifierTable)
		self.cd = true
		Timers:CreateTimer(30, function()
			self.cd = false
		end)
	end
end

function modifier_talent_18_cloud:OnCreated()
	if not IsServer() then
		return
	end
	self.hero = self:GetParent()
	self.heroTeam = self.hero:GetTeamNumber()
	self:OnIntervalThink()
	self:StartIntervalThink(10)
end

function modifier_talent_18_cloud:OnIntervalThink()
	if not IsServer() then
		return
	end
	self.firstAbility = self.hero:GetAbilityByIndex(0)
end

function modifier_talent_18_cloud:OnAbilityFullyCast(kv)
	if not IsServer() then
		return
	end
	if kv.unit ~= self.hero then
		return
	end
	if kv.ability ~= self.firstAbility then
		return
	end
	local enemies = FindUnitsInRadius(self.heroTeam,
            kv.unit:GetAbsOrigin(),
            nil,
            600,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
	if #enemies > 0 then
		local scale = TalentTree:GetHeroTalentLevel(self.hero, 18) * 0.5 + 0.5 
		local damage = Units:GetHeroPrimaryAttribute(self.hero) * scale
		for _, unit in pairs(enemies) do
			local damageTable = {
				caster = self.hero,
				target = unit,
				damage = damage,
				fromtalent = 18,
				holydmg = true,
				naturedmg = true,
				aoe = true,
			}
			GameMode:DamageUnit(damageTable)
			local particle = ParticleManager:CreateParticle("particles/econ/items/sven/sven_warcry_ti5/sven_warcry_cast_arc_lightning.vpcf", PATTACH_ABSORIGIN, unit)
			ParticleManager:ReleaseParticleIndex(particle)
		end
	end
end
