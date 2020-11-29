LinkLuaModifier("modifier_talent_37", "talents/talent_37", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_37_effect", "talents/talent_37", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_37_effect_debuff", "talents/talent_37", LUA_MODIFIER_MOTION_NONE)

modifier_talent_37 = class({
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
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
        }
    end
})

function modifier_talent_37:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
    self:OnIntervalThink()
    self:StartIntervalThink(10)
end

function modifier_talent_37:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.thirdAbility = self.hero:GetAbilityByIndex(2)
end

function modifier_talent_37:OnAbilityFullyCast(keys)

    if (keys.unit ~= self.hero or not IsServer()) then
        return
    end
    if (keys.ability == self.thirdAbility) then
        local modifierTable = {}
        modifierTable.caster = self.hero
        modifierTable.target = self.hero
        modifierTable.ability = nil
        modifierTable.modifier_name = "modifier_talent_37_effect"
        modifierTable.duration = 12
        GameMode:ApplyBuff(modifierTable)
    end
end

function modifier_talent_37:GetAOEDamageBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 37) * 0.15
end

modifier_talent_37_effect = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_37.png"
    end
})

function modifier_talent_37_effect:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetParent()
    self.heroTeam = self.hero:GetTeamNumber()
    local pidx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.hero)
    ParticleManager:SetParticleControl(pidx, 1, self.hero:GetAbsOrigin())
    self:AddParticle(pidx, true, false, 1, true, false)
    self:StartIntervalThink(1)
end

function modifier_talent_37_effect:OnIntervalThink()
    if not IsServer() then
        return
    end
    local enemies = FindUnitsInRadius(self.heroTeam,
            self.hero:GetAbsOrigin(),
            nil,
            350,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local damageTable = {}
    damageTable.caster = self.hero
    damageTable.target = nil
    damageTable.fromtalent = 37
    damageTable.aoe = true
    damageTable.firedmg = true
    damageTable.damage = Units:GetHeroStrength(self.hero) * TalentTree:GetHeroTalentLevel(self.hero, 37) * 0.3
    local modifierTable = {}
    modifierTable.ability = nil
    modifierTable.caster = self.hero
    modifierTable.target = nil
    modifierTable.modifier_name = "modifier_talent_37_effect_debuff"
    modifierTable.duration = 2
    for _, enemy in pairs(enemies) do
        damageTable.target = enemy
        modifierTable.target = enemy
        GameMode:ApplyDebuff(modifierTable)
        GameMode:DamageUnit(damageTable)
    end
end

modifier_talent_37_effect_debuff = class({
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
        return { MODIFIER_PROPERTY_MISS_PERCENTAGE }
    end,
    GetModifierMiss_Percentage = function()
        return 20
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_37.png"
    end
})
