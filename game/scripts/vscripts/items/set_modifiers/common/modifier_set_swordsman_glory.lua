LinkLuaModifier("modifier_set_swordsman_glory", "items/set_modifiers/common/modifier_set_swordsman_glory", LUA_MODIFIER_MOTION_NONE)

modifier_set_swordsman_glory = class({
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
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_set_swordsman_glory:OnCreated()
    if(not IsServer()) then
        return
    end
    print("Added")
end

function modifier_set_swordsman_glory:OnStackCountChanged()
    if(not IsServer()) then
        return
    end
    print("Item set part added or removed")
end

function modifier_set_swordsman_glory:OnDestroy()
    if(not IsServer()) then
        return
    end
    print("Removed")
end
