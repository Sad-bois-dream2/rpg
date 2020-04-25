local LinkedModifiers = {}

-- chosen_invoker_purification_brilliance modifiers
modifier_chosen_invoker_purification_brilliance = modifier_chosen_invoker_purification_brilliance or class({
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
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return chosen_invoker_purification_brilliance:GetAbilityTextureName()
    end,
    GetEffectName = function(self)
        return "particles/units/blazing_berserker/furious_stance/furious_stance.vpcf"
    end
})

-- chosen_invoker_purification_brilliance
chosen_invoker_purification_brilliance = class({
    GetAbilityTextureName = function(self)
        return "chosen_invoker_purification_brilliance"
    end,
    IsRequireCastbar = function(self)
        return true
    end
})

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_blazing_berserker", MotionController)
end