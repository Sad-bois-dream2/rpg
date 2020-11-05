LinkLuaModifier("modifier_talent_47", "talents/talent_47", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_47_earth_res", "talents/talent_47", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_47_fire_res", "talents/talent_47", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_47_frost_res", "talents/talent_47", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_47_holy_res", "talents/talent_47", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_47_inferno_res", "talents/talent_47", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_47_nature_res", "talents/talent_47", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_47_void_res", "talents/talent_47", LUA_MODIFIER_MOTION_NONE)

modifier_talent_47 = class({
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

function modifier_talent_47:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetParent()
    self.modifiers = {
        firedmg = "modifier_talent_47_fire_res",
        frostdmg = "modifier_talent_47_frost_res",
        voiddmg = "modifier_talent_47_void_res",
        infernodmg = "modifier_talent_47_inferno_res",
        earthdmg = "modifier_talent_47_earth_res",
        holydmg = "modifier_talent_47_holy_res",
        naturedmg = "modifier_talent_47_nature_res",
    }
end

function modifier_talent_47:OnPostTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_talent_47")
    if (not modifier) then
        return
    end
    local modifierTable = {}
    modifierTable.caster = damageTable.victim
    modifierTable.target = damageTable.victim
    modifierTable.ability = nil
    modifierTable.modifier_name = nil
    modifierTable.duration = 6
    modifierTable.stacks = 1
    modifierTable.max_stacks = TalentTree:GetHeroTalentLevel(damageTable.victim, 47) + 2
    for type, buff in pairs(modifier.modifiers) do
        if (damageTable[type]) then
            modifierTable.modifier_name = buff
            GameMode:ApplyStackingBuff(modifierTable)
        end
    end
end

modifier_talent_47_fire_res = class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_47_fire.png"
    end
})

function modifier_talent_47_fire_res:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_47_fire_res:GetFireProtectionBonus()
    return self:GetStackCount() * 0.01 * TalentTree:GetHeroTalentLevel(self.hero, 47)
end

modifier_talent_47_inferno_res = class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_47_inferno.png"
    end
})

function modifier_talent_47_inferno_res:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_47_inferno_res:GetInfernoProtectionBonus()
    return self:GetStackCount() * 0.01 * TalentTree:GetHeroTalentLevel(self.hero, 47)
end

modifier_talent_47_holy_res = class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_47_holy.png"
    end
})

function modifier_talent_47_holy_res:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_47_holy_res:GetHolyProtectionBonus()
    return self:GetStackCount() * 0.01 * TalentTree:GetHeroTalentLevel(self.hero, 47)
end

modifier_talent_47_nature_res = class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_47_nature.png"
    end
})

function modifier_talent_47_nature_res:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_47_nature_res:GetNatureProtectionBonus()
    return self:GetStackCount() * 0.01 * TalentTree:GetHeroTalentLevel(self.hero, 47)
end

modifier_talent_47_void_res = class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_47_void.png"
    end
})

function modifier_talent_47_void_res:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_47_void_res:GetVoidProtectionBonus()
    return self:GetStackCount() * 0.01 * TalentTree:GetHeroTalentLevel(self.hero, 47)
end

modifier_talent_47_frost_res = class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_47_frost.png"
    end
})

function modifier_talent_47_frost_res:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_47_frost_res:GetFrostProtectionBonus()
    return self:GetStackCount() * 0.01 * TalentTree:GetHeroTalentLevel(self.hero, 47)
end

modifier_talent_47_earth_res = class({
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
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_47_earth.png"
    end
})

function modifier_talent_47_earth_res:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_47_earth_res:GetEarthProtectionBonus()
    return self:GetStackCount() * 0.01 * TalentTree:GetHeroTalentLevel(self.hero, 47)
end

if (IsServer() and not GameMode.TALENT_47_INIT) then
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_talent_47, 'OnPostTakeDamage'))
    GameMode.TALENT_47_INIT = true
end