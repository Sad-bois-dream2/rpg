LinkLuaModifier("modifier_talent_30", "talents/talent_30", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_30_aura", "talents/talent_30", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_30_aura_buff", "talents/talent_30", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_30_aura_cd", "talents/talent_30", LUA_MODIFIER_MOTION_NONE)

modifier_talent_30 = class({
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
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_30.png"
    end
})

function modifier_talent_30:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
    self:OnIntervalThink()
    self:StartIntervalThink(10)
end

function modifier_talent_30:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.sixthAbility = self.hero:GetAbilityByIndex(5)
end

function modifier_talent_30:OnAbilityFullyCast(keys)
    if (keys.unit ~= self.hero or not IsServer()) then
        return
    end
    if (keys.unit:HasModifier("modifier_talent_30_aura_cd")) then
        return
    end
    if (keys.ability == self.sixthAbility) then
        local modifierTable = {}
        modifierTable.caster = self.hero
        modifierTable.target = self.hero
        modifierTable.ability = nil
        modifierTable.modifier_name = "modifier_talent_30_aura"
        modifierTable.duration = 10
        GameMode:ApplyBuff(modifierTable)
    end
end

modifier_talent_30_aura = class({
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
    IsAura = function(self)
        return true
    end,
    GetModifierAura = function(self)
        return "modifier_talent_30_aura_buff"
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraDuration = function(self)
        return 0
    end,
    GetAuraRadius = function(self)
        return 900
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_30.png"
    end
})

function modifier_talent_30_aura:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
    local pidx = ParticleManager:CreateParticle("particles/talents/talent_30/buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.hero)
    ParticleManager:SetParticleControlEnt(pidx, 1, self.hero, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hero:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(pidx, 2, Vector(self:GetAuraRadius(), self.hero:GetPaddedCollisionRadius() + 50, 0))
    self:AddParticle(pidx, true, false, 1, true, false)
end

function modifier_talent_30_aura:GetAuraEntityReject(entity)
    return entity == self.hero
end

function modifier_talent_30_aura:OnDestroy()
    if (not IsServer()) then
        return
    end
    local modifierTable = {}
    modifierTable.caster = self.hero
    modifierTable.target = self.hero
    modifierTable.ability = nil
    modifierTable.modifier_name = "modifier_talent_30_aura_cd"
    modifierTable.duration = 25
    local addedModifier = GameMode:ApplyDebuff(modifierTable)
    if (addedModifier) then
        addedModifier:SetDuration(25, true)
    end
end

modifier_talent_30_aura_buff = class({
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
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_30.png"
    end
})

function modifier_talent_30_aura_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.auraOwner = self:GetAuraOwner()
    self.target = self:GetParent()
    local pidx = ParticleManager:CreateParticle("particles/talents/talent_30/buff_rope.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target)
    ParticleManager:SetParticleControlEnt(pidx, 0, self.auraOwner, PATTACH_POINT_FOLLOW, "attach_hitloc", self.auraOwner:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(pidx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
    self:AddParticle(pidx, true, false, 1, true, false)
end

function modifier_talent_30_aura_buff:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_talent_30_aura_buff")
    if (modifier and damageTable.damage > 0 and modifier.auraOwner) then
        local damageRedirect = damageTable.damage * ((TalentTree:GetHeroTalentLevel(self.hero, 21) * 0.05) + 0.10)
        local carrierHp = modifier.auraOwner:GetHealth() - damageRedirect
        if (carrierHp >= 1) then
            modifier.auraOwner:SetHealth(carrierHp)
            damageTable.damage = damageTable.damage - damageRedirect
        end
        return damageTable
    end
end

modifier_talent_30_aura_cd = class({
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
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_30.png"
    end
})

if (IsServer() and not GameMode.TALENT_30_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_30_aura_buff, 'OnTakeDamage'))
    GameMode.TALENT_30_INIT = true
end
