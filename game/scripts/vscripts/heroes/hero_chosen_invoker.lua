local LinkedModifiers = {}

-- chosen_invoker_purification_brilliance modifiers

-- chosen_invoker_purification_brilliance
chosen_invoker_purification_brilliance = class({
    GetAbilityTextureName = function(self)
        return "chosen_invoker_purification_brilliance"
    end
})

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_blazing_berserker", MotionController)
end