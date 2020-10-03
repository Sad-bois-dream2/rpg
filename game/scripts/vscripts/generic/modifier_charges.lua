modifier_charges = class({})

if IsServer() then
    function modifier_charges:Update()
        if self:GetDuration() == -1 then
            self:SetDuration(self.kv.replenish_time, true)
            self:StartIntervalThink(self.kv.replenish_time)
        end
    end

    function modifier_charges:OnCreated(kv)
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv
        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
        end
        self.ability = self:GetAbility()
        self.caster = self.ability:GetCaster()
    end

    function modifier_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
        }
        return funcs
    end

    function modifier_charges:OnAbilityFullyCast(params)
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
end

function modifier_charges:DestroyOnExpire()
    return false
end

function modifier_charges:IsPurgable()
    return false
end

function modifier_charges:RemoveOnDeath()
    return false
end