---------------------
--lycan call
---------------------

self.parent:EmitSound("lycan_lycan_ability_summon_03")

---------------------
--lycan companion
---------------------
lycan_companion = class({
    GetAbilityTextureName = function(self)
        return "lycan_companion"
    end,
    GetIntrinsicModifierName = function(self)
        return "lycan_companion"
    end,
})
self.parent:EmitSound("lycan_lycan_ally_03")

---------------------
--lycan wound
---------------------
self.parent:EmitSound("hero_bloodseeker.rupture")
---------------------
--lycan shapeshift
---------------------
self.parent:EmitSound("Hero_Lycan.Shapeshift.Cast")
---------------------
--lycan howl
---------------------
self.parent:EmitSound("Hero_Lycan.Howl")
---------------------
--lycan agility
---------------------
self.parent:EmitSound("lycan_lycan_attack_08")
---------------------
--lycan curse
---------------------

self.parent:EmitSound("lycan_lycan_ally_05")
self.parent:EmitSound("lycan_lycan_ally_04")
---------------------
--lycan double strike
---------------------
lycan_double_strike = class({
    GetAbilityTextureName = function(self)
        return "lycan_double_strike"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_lycan_double_strike"
    end,
})
---------------------
--lycan bleeding
---------------------
lycan_bleeding = class({
    GetAbilityTextureName = function(self)
        return "lycan_bleeding"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_lycan_bleeding"
    end,
})