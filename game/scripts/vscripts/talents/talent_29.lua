LinkLuaModifier("modifier_talent_29", "talents/talent_29", LUA_MODIFIER_MOTION_NONE)

modifier_talent_29 = class({
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
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED
        }
    end
})

function modifier_talent_29:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
    self.heroTeam = self.hero:GetTeamNumber()
end

function modifier_talent_29:GetInfernoDamageBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 29) * 0.1
end

function modifier_talent_29:GetFireDamageBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 29) * 0.1
end

function modifier_talent_29:OnAttackLanded(event)
    if not IsServer() then
        return
    end
    if (event.attacker ~= self.hero or not RollPercentage(30)) then
        return
    end
    local radius = 350
    local units = FindUnitsInRadius(self.heroTeam,
            self.hero:GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local damageTable = {}
    damageTable.caster = self.hero
    damageTable.target = nil
    damageTable.damage = TalentTree:GetHeroTalentLevel(self.hero, 29) * 0.1 * Units:GetAttackDamage(self.hero)
    damageTable.firedmg = true
    damageTable.infernodmg = true
    for _, unit in pairs(units) do
        damageTable.target = unit
        GameMode:DamageUnit(damageTable)
    end
    local pidx = ParticleManager:CreateParticle("particles/talents/talent_29/explosion.vpcf", PATTACH_ABSORIGIN, self.hero)
    ParticleManager:SetParticleControl(pidx, 2, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(pidx)
end