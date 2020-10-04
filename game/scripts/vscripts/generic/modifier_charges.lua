modifier_charges = class({
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
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DestroyOnExpire = function(self)
        return false
    end,

})

function modifier_charges:Update()
    if (not IsServer()) then
        return
    end
    if self:GetDuration() == -1 then
        self:SetDuration(self.kv.replenish_time, true)
        self:StartIntervalThink(self.kv.replenish_time)
    end
end

function modifier_charges:OnCreated(kv)
    if (not IsServer()) then
        return
    end
    self:SetStackCount(kv.start_count or kv.max_count)
    self.kv = kv
    if kv.start_count and kv.start_count ~= kv.max_count then
        self:Update()
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
end

function modifier_charges:OnAbilityFullyCast(params)
    if (not IsServer()) then
        return
    end
    if (params.unit == self.caster and params.ability == self.ability) then
        if (self:GetStackCount() > 0) then
            self.ability:EndCooldown()
        else
            self.ability:StartCooldown(self:GetRemainingTime() * Units:GetCooldownReduction(self.caster))
        end
        self:DecrementStackCount()
        self:Update()
    end
end

function modifier_charges:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local stacks = self:GetStackCount()
    if stacks < self.kv.max_count then
        self:SetDuration(self.kv.replenish_time, true)
        self:IncrementStackCount()

        if stacks == self.kv.max_count - 1 then
            self:SetDuration(-1, true)
            self:StartIntervalThink(-1)
        end
    end
end