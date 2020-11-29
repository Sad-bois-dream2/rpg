LinkLuaModifier("modifier_talent_49", "talents/talent_49", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_49_dot", "talents/talent_49", LUA_MODIFIER_MOTION_NONE)

modifier_talent_49 = class({
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

function modifier_talent_49:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetParent()
end

function modifier_talent_49:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_talent_49")
    if (modifier and not damageTable.ability) then
        damageTable.naturedmg = true
        return damageTable
    end
end

function modifier_talent_49:OnAttackLanded(kv)
    if not IsServer() then
        return
    end
    if (kv.attacker == self.hero and RollPercentage(TalentTree:GetHeroTalentLevel(self.hero, 49) * 15)) then
        local modifierTable = {
            caster = self.hero,
            target = kv.target,
            ability = nil,
            modifier_name = "modifier_talent_49_dot",
            duration = 3,
            stacks = 1,
            max_stacks = 99999
        }
        local modifier = GameMode:ApplyNPCBasedStackingDebuff(modifierTable)
        local duration = modifier:GetDuration()
        Timers:CreateTimer(duration, function()
            if (modifier and not modifier:IsNull()) then
                modifier:DecrementStackCount()
            end
        end)
    end
end

modifier_talent_49_dot = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_MULTIPLE
    end,
    GetTexture = function()
        return "file://{images}/custom_game/hud/talenttree/talent_49.png"
    end,
    GetEffectName = function()
        return "particles/talents/talent_49/debuff.vpcf"
    end
})

function modifier_talent_49_dot:GetStatusEffectName()
    return "particles/talents/talent_49/status_fx/status_effect_talent_49_poison_weapon.vpcf"
end

function modifier_talent_49_dot:StatusEffectPriority()
    return 15
end

function modifier_talent_49_dot:OnCreated()
    if not IsServer() then
        return
    end
    self.hero = self:GetCaster()
    self.damageTable = {
        caster = self.hero,
        target = self:GetParent(),
        fromtalent = 49,
        dot = true,
        damage = -1,
        naturedmg = true,
    }
    self:StartIntervalThink(1)
end

function modifier_talent_49_dot:OnIntervalThink()
    if not IsServer() then
        return
    end
    local scale = TalentTree:GetHeroTalentLevel(self.hero, 49) * 0.1
    local damage = Units:GetAttackDamage(self.hero) * scale * self:GetStackCount()
    self.damageTable.damage = damage * scale
    GameMode:DamageUnit(self.damageTable)
end

if (IsServer() and not GameMode.TALENT_49_INIT) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_talent_49, 'OnTakeDamage'), true)
    GameMode.TALENT_49_INIT = true
end