local LinkedModifiers = {}

-- chosen_invoker_purification_brilliance modifiers
modifier_chosen_invoker_purification_brilliance = modifier_chosen_invoker_purification_brilliance or class({
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
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end
})

function modifier_chosen_invoker_purification_brilliance:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self:GetParent()
    self.target = self.ability:GetCursorTarget()
    local tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
    self:OnIntervalThink()
end

function modifier_chosen_invoker_purification_brilliance:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    self.caster:StartGesture(ACT_DOTA_CAST_ALACRITY)
    local pidx = ParticleManager:CreateParticle("particles/units/chosen_invoker/purification_brilliance/purification_brilliance_rope.vpcf", PATTACH_POINT, self.caster)
    ParticleManager:SetParticleControlEnt(pidx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_attack2", self.caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(pidx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
    Timers:CreateTimer(1.0, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
end

function modifier_chosen_invoker_purification_brilliance:OnDestroy()
    if (not IsServer()) then
        return
    end
    self.caster:RemoveGesture(ACT_DOTA_CAST_ALACRITY)
end

LinkedModifiers["modifier_chosen_invoker_purification_brilliance"] = LUA_MODIFIER_MOTION_NONE

-- chosen_invoker_purification_brilliance
chosen_invoker_purification_brilliance = class({
    GetAbilityTextureName = function(self)
        return "chosen_invoker_purification_brilliance"
    end,
    IsRequireCastbar = function(self)
        return true
    end
})

function chosen_invoker_purification_brilliance:OnChannelFinish()
    if (not IsServer()) then
        return
    end
    self.modifier:Destroy()
end

function chosen_invoker_purification_brilliance:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    self.modifier = caster:AddNewModifier(caster, self, "modifier_chosen_invoker_purification_brilliance", { duration = self:GetChannelTime() })
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_chosen_invoker", MotionController)
end