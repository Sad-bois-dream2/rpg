LinkLuaModifier("modifier_inventory_item_two_handed_sword", "items/common/item_two_handed_sword", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_two_handed_sword = class({
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

function modifier_inventory_item_two_handed_sword:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_two_handed_sword:GetAttackDamageBonus()
    return self.data.attack_damage
end