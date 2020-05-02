local LinkedModifiers = {}

-- crystal_sorceress_frost_comet modifiers

-- crystal_sorceress_frost_comet
crystal_sorceress_frost_comet = class({
    GetAbilityTextureName = function(self)
        return "crystal_sorceress_frost_comet"
    end,
    IsRequireCastbar = function(self)
        return true
    end
})

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "heroes/hero_crystal_sorceress", MotionController)
end