LinkLuaModifier("modifier_talent_14", "talents/talent_14", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_14_debuff", "talents/talent_14", LUA_MODIFIER_MOTION_NONE)

modifier_talent_14 = class({
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

function modifier_talent_14:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_14:OnPostTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_talent_14")
    if (not modifier) then
        return damageTable
    end
    local modifierTable = {
        caster = damageTable.attacker,
        target = damageTable.victim,
        ability = nil,
        duration = 3,
        modifier_name = "modifier_talent_14_debuff"
    }
    GameMode:ApplyNPCBasedDebuff(modifierTable)
end

modifier_talent_14_debuff = class({
    IsDebuff = function(self)
        return true
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_14.png"
    end
})

function modifier_talent_14_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.hero = self:GetCaster()
end

function modifier_talent_14_debuff:GetArmorBonus()
    return TalentTree:GetHeroTalentLevel(self.hero, 14) * (-2)
end

if (IsServer() and not GameMode.TALENT_14_INIT) then
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_talent_14, 'OnPostTakeDamage'))
    GameMode.TALENT_14_INIT = true
end
