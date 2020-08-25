local LinkedModifiers = {}

-- fallen_druid_wisp_companion
WISPY_STATE_ATTACHED_TO_WAIFU = 1
WISPY_STATE_ATTACHED_TO_ALLY = 2
WISPY_STATE_TRAVEL_TO_TARGET = 3
WISPY_STATE_TRAVEL_BACK = 4

modifier_fallen_druid_wisp_companion_ai = class({
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
        return MODIFIER_ATTRIBUTE_PERMAMENT
    end,
    CheckState = function(self)
        return
        {
            [MODIFIER_STATE_INVULNERABLE] = true,
            [MODIFIER_STATE_UNSELECTABLE] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_OUT_OF_GAME] = true,
            [MODIFIER_STATE_FLYING] = true
        }
    end,
    DeclareFunctions = function(self)
        return
        {
            MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
            MODIFIER_EVENT_ON_ATTACK_LANDED,
            MODIFIER_PROPERTY_VISUAL_Z_DELTA
        }
    end
})

function modifier_fallen_druid_wisp_companion_ai:GetVisualZDelta()
    local state = self:GetStackCount()
    if (state == WISPY_STATE_TRAVEL_BACK or state == WISPY_STATE_TRAVEL_TO_TARGET) then
        return 120
    end
    return 0
end

function modifier_fallen_druid_wisp_companion_ai:GetModifierMoveSpeed_AbsoluteMin()
    return self.ability.wispMoveSpeed
end

function modifier_fallen_druid_wisp_companion_ai:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    if (self.state == WISPY_STATE_TRAVEL_BACK) then
        local wispyPosition = self.wispy:GetAbsOrigin()
        local targetPosition = self.holder:GetAbsOrigin()
        if ((targetPosition - wispyPosition):Length2D() > 100) then
            self.wispy:MoveToPosition(targetPosition)
        else
            if (self.holder == self.caster) then
                self:ChangeState(WISPY_STATE_ATTACHED_TO_WAIFU)
            else
                self:ChangeState(WISPY_STATE_ATTACHED_TO_ALLY)
            end
        end
    elseif (self.state == WISPY_STATE_TRAVEL_TO_TARGET) then
        if (self.target and not self.target:IsNull()) then
            if (self.wispy:GetAggroTarget() ~= self.target) then
                self.wispy:MoveToTargetToAttack(self.target)
            end
        else
            self:ChangeState(WISPY_STATE_TRAVEL_BACK)
        end
    elseif (self.state == WISPY_STATE_ATTACHED_TO_ALLY) then
        local position = self.holder:GetAbsOrigin()
        self.wispy:SetAbsOrigin(position)
        local angles = self.holder:GetAnglesAsVector()
        self.wispy:SetAngles(angles[1], angles[2], angles[3])
    else
        self.wispy:Stop()
        self.wispy:SetOrigin(self.caster:GetAttachmentOrigin(self.caster:ScriptLookupAttachment("attach_lantern")))
    end
end

function modifier_fallen_druid_wisp_companion_ai:OnAttackLanded(kv)
    if IsServer() then
        local attacker = kv.attacker
        local target = kv.target
        if (attacker and target and not target:IsNull() and attacker == self.wispy) then
            self.wispy:Stop()
            self:ChangeState(WISPY_STATE_TRAVEL_BACK)
        end
    end
end

function modifier_fallen_druid_wisp_companion_ai:ChangeState(newstate)
    if (not IsServer()) then
        return
    end
    self.state = newstate
    self:SetStackCount(self.state)
end

function modifier_fallen_druid_wisp_companion_ai:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.wispy = self:GetParent()
    self.attachId = self.caster:ScriptLookupAttachment("attach_lantern")
    self.particle = ParticleManager:CreateParticle("particles/units/fallen_druid/wisp_companion/wispy.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:StartIntervalThink(0.05)
end

function modifier_fallen_druid_wisp_companion_ai:OnDestroy()
    if (not IsServer()) then
        return
    end
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    UTIL_Remove(self.wispy)
end

LinkedModifiers["modifier_fallen_druid_wisp_companion_ai"] = LUA_MODIFIER_MOTION_NONE

modifier_fallen_druid_wisp_companion = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMAMENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ATTACK_LANDED }
    end
})

function modifier_fallen_druid_wisp_companion:OnCreated(kv)
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_fallen_druid_wisp_companion:OnAttackLanded(kv)
    if IsServer() then
        local attacker = kv.attacker
        local target = kv.target
        if (attacker and target and not target:IsNull() and attacker == self.caster) then
            self.ability:OrderWispyAttackTarget(self.ability.wispy, target)
        end
    end
end

LinkedModifiers["modifier_fallen_druid_wisp_companion"] = LUA_MODIFIER_MOTION_NONE

fallen_druid_wisp_companion = class({
    GetIntrinsicModifierName = function(self)
        return "modifier_fallen_druid_wisp_companion"
    end
})

function fallen_druid_wisp_companion:CreateWispy()
    if (not self.wispy and IsServer()) then
        local caster = self:GetCaster()
        self.wispy = CreateUnitByName("npc_dota_fallen_druid_wispy", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
        self.wispy.modifier = self.wispy:AddNewModifier(self.wispy, self, "modifier_fallen_druid_wisp_companion_ai", {})
        self:AttachWispyToLantern(self.wispy, caster)
        self.wispy.modifier:ChangeState(WISPY_STATE_ATTACHED_TO_WAIFU)
        self.wispy:SetHullRadius(0)
    end
end

function fallen_druid_wisp_companion:AttachWispyToLantern(wispy, waifu)
    if (wispy and not wispy:IsNull()) then
        wispy.modifier.holder = waifu
    end
end

function fallen_druid_wisp_companion:AttachWispyToAlly(wispy, ally)
    if (wispy and not wispy:IsNull()) then
        wispy.modifiler.holder = ally
    end
end

function fallen_druid_wisp_companion:OrderWispyAttackTarget(wispy, target)
    if (not wispy or wispy:IsNull()) then
        return
    end
    if (wispy.modifier.state == WISPY_STATE_TRAVEL_TO_TARGET or wispy.modifier.state == WISPY_STATE_TRAVEL_BACK) then
        return
    end
    wispy.modifier:ChangeState(WISPY_STATE_TRAVEL_TO_TARGET)
    wispy.modifier.target = target
end

function fallen_druid_wisp_companion:OnUpgrade()
    self:CreateWispy()
    self.wispDamage = self:GetSpecialValueFor("wisp_damage") / 100
    self.wispMoveSpeed = self:GetSpecialValueFor("wisp_ms")
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_fallen_druid", MotionController)
end
