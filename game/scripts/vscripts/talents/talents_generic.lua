-- This is example how to add modifiers to any talent, if you need it (if talent not binded to some skill or something else)
-- Don't forgot include you talents file in talents/require.lua
-- Format is:
--[[
local modifier_name = "modifier"
if(TalentTree:IsUniversalTalent(talentId)) then
    modifier_name = modifier_name.."_generic_"
else
    local heroName = hero:GetUnitName()
    modifier_name = modifier_name.."_"..heroName.."_"
end
modifier_name = modifier_name.."talent_"..tostring(talentId)
--]]
-- Examples of modifier names for generic talents: modifier_generic_talent_25, modifier_generic_talent_26, modifier_generic_talent_27
-- Examples of modifier names for hero specific talents: modifier_npc_dota_hero_silencer_talent_45, modifier_npc_dota_hero_silencer_talent_46
local LinkedModifiers = {}

modifier_generic_talent_1 = modifier_generic_talent_1 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_1:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_1:GetStrengthBonus()
    local str_bonus = TalentTree:GetHeroTalentLevel(self.hero, 1) * 10
    return str_bonus or 0
end

LinkedModifiers["modifier_generic_talent_1"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_2 = modifier_generic_talent_2 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_2:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_2:GetAgilityBonus()
    local agi_bonus = TalentTree:GetHeroTalentLevel(self.hero, 2) * 10
    return agi_bonus or 0
end

LinkedModifiers["modifier_generic_talent_2"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_3 = modifier_generic_talent_3 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_3:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_3:GetIntellectBonus()
    local int_bonus = TalentTree:GetHeroTalentLevel(self.hero, 3) * 10
    return int_bonus or 0
end

LinkedModifiers["modifier_generic_talent_3"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_4 = modifier_generic_talent_4 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_4:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_4:GetHealthBonus()
    local hp_bonus = TalentTree:GetHeroTalentLevel(self.hero, 4) * 500
    return hp_bonus or 0
end

LinkedModifiers["modifier_generic_talent_4"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_5 = modifier_generic_talent_5 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_5:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_5:GetManaBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 5) * 500
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_5"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_6 = modifier_generic_talent_6 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_6:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_6:GetMoveSpeedBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 6) * 10
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_6"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_7 = modifier_generic_talent_7 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_7:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_7:GetDamageReductionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 7) * 0.05
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_7"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_8 = modifier_generic_talent_8 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_8:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_8:GetSpellDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 8) * 0.05
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_8"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_9 = modifier_generic_talent_9 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_9:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_9:GetAttackDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 9) * 50
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_9"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_10 = modifier_generic_talent_10 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_10:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_10:GetInfernoDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 10) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_10"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_11 = modifier_generic_talent_11 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_11:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_11:GetEarthDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 11) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_11"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_12 = modifier_generic_talent_12 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_12:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end
--[[
    Idk about it atm
--]]
LinkedModifiers["modifier_generic_talent_12"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_13 = modifier_generic_talent_13 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_13:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

--[[
    Idk about it atm
--]]

LinkedModifiers["modifier_generic_talent_13"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_14 = modifier_generic_talent_14 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_14:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_14:GetFireDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 14) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_14"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_15 = modifier_generic_talent_15 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_15:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_15:GetFrostDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 15) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_15"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_16 = modifier_generic_talent_16 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_16:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_16:GetVoidDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 16) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_16"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_17 = modifier_generic_talent_17 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_17:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_17:GetHolyDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 17) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_17"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_18 = modifier_generic_talent_18 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_18:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_18:GetNatureDamageBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 18) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_18"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_25 = modifier_generic_talent_25 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_25:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_25:GetFireProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

function modifier_generic_talent_25:GetFrostProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

function modifier_generic_talent_25:GetEarthProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

function modifier_generic_talent_25:GetVoidProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

function modifier_generic_talent_25:GetHolyProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

function modifier_generic_talent_25:GetNatureProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

function modifier_generic_talent_25:GetInfernoProtectionBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 25) * 0.05
    return bonus
end

LinkedModifiers["modifier_generic_talent_25"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_26 = modifier_generic_talent_26 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_26:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_26:GetArmorBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 26) * 10
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_26"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_27 = modifier_generic_talent_27 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_27:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_27:GetMagicBlockBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 27) * 50
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_27"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_28 = modifier_generic_talent_28 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_28:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_28:GetHealthRegenerationPercentBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 28) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_28"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_29 = modifier_generic_talent_29 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_29:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_29:GetManaRegenerationPercentBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 29) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_29"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_30 = modifier_generic_talent_30 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_30:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_30:GetAttackSpeedPercentBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 30) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_30"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_31 = modifier_generic_talent_31 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_31:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_31:GetBlockBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 31) * 50
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_31"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_32 = modifier_generic_talent_32 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_32:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_32:GetAttackRangePercentBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 32) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_32"] = LUA_MODIFIER_MOTION_NONE

modifier_generic_talent_33 = modifier_generic_talent_33 or class({
    IsDebuff = function(self)
        return false -- prevent some weird shit
    end,
    IsHidden = function(self)
        return true -- make them hidden pls
    end,
    IsPurgable = function(self)
        return false -- prevent shit with that too pls
    end,
    RemoveOnDeath = function(self)
        return false -- this happens
    end,
    AllowIllusionDuplicate = function(self)
        return false -- this happens too sometimes
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT -- always add MODIFIER_ATTRIBUTE_PERMANENT to prevent weird shit.
    end
})

function modifier_generic_talent_33:OnCreated()
    if(not IsServer()) then
        return
    end
    self.hero = self:GetParent()
end

function modifier_generic_talent_33:GetSpellHasteBonus()
    local bonus = TalentTree:GetHeroTalentLevel(self.hero, 33) * 0.1
    return bonus or 0
end

LinkedModifiers["modifier_generic_talent_33"] = LUA_MODIFIER_MOTION_NONE

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "talents/talents_generic", MotionController)
end