LinkLuaModifier("modifier_talent_32", "talents/talent_32", LUA_MODIFIER_MOTION_NONE)

modifier_talent_32 = class({
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

function modifier_talent_32:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_32:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_talent_32")
    if (not modifier or damageTable.damage < 0) then
        return
    end
    if (damageTable.victim:HasModifier("modifier_talent_32_cd")) then
        return
    end
    local maxHealth = damageTable.victim:GetMaxHealth()
    local currentHealth = damageTable.victim:GetHealth()
    local threshold = 0.25
    local postPerc = (currentHealth - damageTable.damage) / maxHealth
    if (postPerc < threshold) then
        damageTable.damage = 0
        local modifierTable = {}
        modifierTable.caster = damageTable.victim
        modifierTable.target = damageTable.victim
        modifierTable.ability = nil
        modifierTable.modifier_name = "modifier_talent_32_effect"
        modifierTable.duration = TalentTree:GetHeroTalentLevel(damageTable.victim, 32) + 2
        GameMode:ApplyBuff(modifierTable)
        local modifierTable = {}
        modifierTable.caster = damageTable.victim
        modifierTable.target = damageTable.victim
        modifierTable.ability = nil
        modifierTable.modifier_name = "modifier_talent_32_cd"
        modifierTable.duration = 40
        local appliedModifier = GameMode:ApplyDebuff(modifierTable)
        if (appliedModifier) then
            appliedModifier:SetDuration(40, true)
        end
        return damageTable
    end
end

modifier_talent_32_effect = class({
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
        return "file://{images}/custom_game/hud/talenttree/talent_32.png"
    end
})

function modifier_talent_32_effect:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_32_effect:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_talent_32_effect")
    if (not modifier) then
        return
    end
    damageTable.damage = 0
    return damageTable
end

modifier_talent_32_cd = class({
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
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_32.png"
    end
})

if (IsServer() and not GameMode.TALENT_32_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_32_effect, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_32, 'OnTakeDamage'))
    GameMode.TALENT_32_INIT = true
end