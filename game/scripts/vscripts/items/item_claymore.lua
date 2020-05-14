modifier_inventory_item_claymore_custom = class({
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

function modifier_inventory_item_claymore_custom:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_claymore_custom:GetAttackDamageBonus()
    return self.data.attack_damage
end

LinkLuaModifier("modifier_inventory_item_claymore_custom", "items/item_claymore", LUA_MODIFIER_MOTION_NONE)