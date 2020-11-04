LinkLuaModifier("modifier_talent_42", "talents/talent_42", LUA_MODIFIER_MOTION_NONE)

modifier_talent_42 = class({
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
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_talent_42:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetParent()
    self.heroTeam = self.hero:GetTeamNumber()
end

function modifier_talent_42:OnAttackLanded(kv)
    if not IsServer() then
        return
    end
    if (kv.attacker ~= self.hero) then
        return
    end
    local chance = TalentTree:GetHeroTalentLevel(self.hero, 42) * 15
    if (not RollPercentage(chance)) then
        return
    end
    local attackerPos = kv.attacker:GetAbsOrigin()
    local enemies = FindUnitsInRadius(self.heroTeam,
            attackerPos,
            nil,
            900,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    if (#enemies > 0) then
        local target = enemies[math.random(#enemies)]
        local pidx = ParticleManager:CreateParticle("particles/talents/talent_42/rope.vpcf", PATTACH_POINT, self.hero)
        ParticleManager:SetParticleControlEnt(pidx, 0, self.hero, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hero:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(pidx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(pidx)
        local scale = TalentTree:GetHeroTalentLevel(self.hero, 42) * 0.3
        local damage = Units:GetAttackDamage(self.hero) * scale
        local damageTable = {}
        damageTable.damage = damage
        damageTable.caster = self.hero
        damageTable.fromtalent = 42
        damageTable.target = target
        damageTable.voiddmg = true
        damageTable.single = true
        GameMode:DamageUnit(damageTable)
    end
end