LinkLuaModifier("modifier_talent_48", "talents/talent_48", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_48_effect", "talents/talent_48", LUA_MODIFIER_MOTION_NONE)

modifier_talent_48 = class({
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
})

function modifier_talent_48:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_48:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_talent_48")
    if (not modifier or damageTable.victim:HasModifier("modifier_talent_48_cd") or damageTable.victim:HasModifier("modifier_talent_48_effect")) then
        return
    end
    local currentHealth = damageTable.victim:GetHealth()
    if (damageTable.damage > 0 and damageTable.damage > currentHealth) then
        damageTable.damage = 0
        damageTable.victim:SetHealth(1)
        local modifierTable = {}
        modifierTable.caster = damageTable.victim
        modifierTable.target = damageTable.victim
        modifierTable.ability = nil
        modifierTable.modifier_name = "modifier_talent_48_effect"
        modifierTable.duration = TalentTree:GetHeroTalentLevel(damageTable.victim, 48) + 2
        GameMode:ApplyBuff(modifierTable)
    end
    return damageTable
end

modifier_talent_48_effect = class({
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
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_48.png"
    end
})

function modifier_talent_48_effect:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetParent()
    self.damageCount = 0
    self.healCount = 0
    self.pidx = ParticleManager:CreateParticle("particles/talents/talent_48/buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.hero)
    ParticleManager:SetParticleControlEnt(self.pidx, 18, self.hero, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hero:GetAbsOrigin(), true)
    self:AddParticle(self.pidx, true, false, 1, true, false)
    self.hero:EmitSound("Item.GuardianGreaves.Activate")
    self:OnIntervalThink()
    self:StartIntervalThink(0.5)
end

function modifier_talent_48_effect:OnIntervalThink()
    if not IsServer() then
        return
    end
    if (self.healCount > self.damageCount) then
        ParticleManager:SetParticleControl(self.pidx, 19, Vector(1, 0, 0))
    else
        ParticleManager:SetParticleControl(self.pidx, 19, Vector(0, 0, 0))
    end
end

function modifier_talent_48_effect:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_talent_48_effect")
    if (not modifier) then
        return
    end
    modifier.damageCount = modifier.damageCount + damageTable.damage
    damageTable.damage = 0
    return damageTable
end

function modifier_talent_48_effect:OnPostHeal(healTable)
    local modifier = healTable.target:FindModifierByName("modifier_talent_48_effect")
    if (not modifier) then
        return
    end
    modifier.healCount = modifier.healCount + healTable.heal
    return healTable
end

function modifier_talent_48_effect:OnDestroy()
    if not IsServer() then
        return
    end
    if (self.healCount > self.damageCount) then
        self.hero:Purge(false, true, false, true, true)
        local healTable = {}
        healTable.caster = self.hero
        healTable.target = self.hero
        healTable.heal = TalentTree:GetHeroTalentLevel(self.hero, 48) * 0.15 * self.hero:GetMaxHealth()
        healTable.ability = nil
        GameMode:HealUnit(healTable)
    else
        self.hero:ForceKill(false)
    end
end

modifier_talent_48_cd = class({
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
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_48.png"
    end
})

if (IsServer() and not GameMode.TALENT_48_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_48, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_48_effect, 'OnTakeDamage'))
    GameMode:RegisterPostHealEventHandler(Dynamic_Wrap(modifier_talent_48_effect, 'OnPostHeal'))
    GameMode.TALENT_48_INIT = true
end