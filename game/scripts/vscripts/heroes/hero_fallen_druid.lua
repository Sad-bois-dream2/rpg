local LinkedModifiers = {}

-- fallen_druid_wisp_companion
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
    CheckState = function(self)
        return {
            [MODIFIER_STATE_INVULNERABLE] = true,
            [MODIFIER_STATE_UNSELECTABLE] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_NO_HEALTH_BAR] = true
        }
    end,
    WISPY_STATE_ATTACHED = 1,
    WISPY_STATE_ATTACHED_TO_ALLY = 2,
    WISPY_STATE_TRAVEL_TO_TARGET = 3,
    WISPY_STATE_TRAVEL_BACK = 4
})

function modifier_fallen_druid_wisp_companion:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    if (self.wispy.state == self.WISPY_STATE_TRAVEL_BACK) then
    elseif (self.wispy.state == self.WISPY_STATE_TRAVEL_TO_TARGET) then

    else
        local position = self.caster:GetAttachmentOrigin(self.attachId)
        self.wispy:SetOrigin(position)
        local angles = self.caster:GetAttachmentAngles(self.attachId)
        self.wispy:SetAngles(angles[1], angles[2], angles[3])
        ParticleManager:SetParticleControl(self.particle, 0, position)
        ParticleManager:SetParticleControl(self.particle, 4, position)
        return
    end
end

function modifier_fallen_druid_wisp_companion:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.wispy = self:GetParent()
    self.attachId = self.caster:ScriptLookupAttachment("attach_lantern")
    self.particle = ParticleManager:CreateParticle("particles/units/fallen_druid/wisp_companion/wispy.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self.ability:AttachWispyToLantern(self.wispy)
    self:StartIntervalThink(0.05)
end

function modifier_fallen_druid_wisp_companion:OnDestroy()
    if (not IsServer()) then
        return
    end
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

LinkedModifiers["modifier_fallen_druid_wisp_companion"] = LUA_MODIFIER_MOTION_NONE

fallen_druid_wisp_companion = class({})

function fallen_druid_wisp_companion:CreateWispy()
    if (not self.wispy and IsServer()) then
        local caster = self:GetCaster()
        self.wispy = CreateUnitByName("npc_dota_fallen_druid_wispy", Vector(0, 0, 0), false, caster, caster, caster:GetTeamNumber())
        self.wispy.modifier = self.wispy:AddNewModifier(self.wispy, self, "modifier_fallen_druid_wisp_companion", {})
    end
end

function fallen_druid_wisp_companion:AttachWispyToLantern(wispy, waifu)
    wispy.holder = waifu
    wispy.modifier.state = wispy.modifier.WISPY_STATE_ATTACHED_TO_ALLY
end

function fallen_druid_wisp_companion:AttachWispyToAlly(wispy, ally)
    wispy.holder = ally
    wispy.modifier.state = wispy.modifier.WISPY_STATE_ATTACHED_TO_ALLY
end

function fallen_druid_wisp_companion:OrderWispyAttackTarget(wispy, target)
    wispy.modifier.state = wispy.modifier.WISPY_STATE_TRAVEL_TO_TARGET
    wispy.target = target
end

function fallen_druid_wisp_companion:OnUpgrade()
    self:CreateWispy()
end

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_fallen_druid", MotionController)
end
